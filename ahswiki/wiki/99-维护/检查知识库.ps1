param([string]$WikiRoot = (Split-Path -Parent $PSScriptRoot))

$ErrorActionPreference = 'Stop'
$WikiRoot = (Resolve-Path -LiteralPath $WikiRoot).Path
$vaultRoot = Split-Path -Parent $WikiRoot
$allFiles = @(Get-ChildItem -LiteralPath $vaultRoot -Recurse -File -Force | Where-Object { $_.FullName -notmatch '\\(\.git|\.obsidian|\.trash)\\' })
$wikiMd = @($allFiles | Where-Object { $_.FullName.StartsWith($WikiRoot + '\') -and $_.Extension -eq '.md' })
$curated = @($wikiMd | Where-Object { $_.FullName -notmatch '\\90-原始资料\\' })
$business = @($wikiMd | Where-Object { $_.FullName.Substring($WikiRoot.Length + 1) -match '^0[1-7]-' })
$indexText = Get-Content -LiteralPath (Join-Path $WikiRoot '00-导航\INDEX.md') -Raw
$manifest = Get-Content -LiteralPath (Join-Path $WikiRoot '99-维护\source-manifest.json') -Raw | ConvertFrom-Json
$baseline = Get-Content -LiteralPath (Join-Path $WikiRoot '99-维护\2026-09-19-整理前校验.json') -Raw | ConvertFrom-Json
$problems = [System.Collections.Generic.List[object]]::new()
$linkCount = 0

foreach ($file in $curated) {
    $body = Get-Content -LiteralPath $file.FullName -Raw
    $body = [regex]::Replace($body, '(?s)```.*?```', '')
    foreach ($match in [regex]::Matches($body, '\[\[([^\]]+)\]\]')) {
        $linkCount++
        $link = ($match.Groups[1].Value -split '\|', 2)[0].TrimEnd('\')
        $target = ($link -split '#', 2)[0].Trim()
        if (!$target) { continue }
        $normalized = $target.Replace('/', '\')
        if ($normalized.Contains('\')) {
            $candidates = @((Join-Path $vaultRoot $normalized), (Join-Path $file.DirectoryName $normalized))
            $found = @($candidates | Where-Object { (Test-Path -LiteralPath $_ -PathType Leaf) -or (Test-Path -LiteralPath ($_ + '.md') -PathType Leaf) }).Count -gt 0
        } else {
            $foundFiles = @($allFiles | Where-Object { $_.Name -eq $target -or ($_.Extension -eq '.md' -and $_.BaseName -eq $target) })
            $found = $foundFiles.Count -gt 0
            if ($foundFiles.Count -gt 1) { $problems.Add([pscustomobject]@{kind='ambiguous_link';file=$file.FullName;target=$target}) }
        }
        if (!$found) { $problems.Add([pscustomobject]@{kind='missing_wikilink';file=$file.FullName;target=$target}) }
    }
    foreach ($match in [regex]::Matches($body, '(?<!!)\]\(([^)]+)\)')) {
        $target = $match.Groups[1].Value.Trim('<','>')
        if ($target -match '^[a-zA-Z][a-zA-Z0-9+.-]*:' -or $target.StartsWith('#')) { continue }
        $target = [uri]::UnescapeDataString(($target -split '#',2)[0])
        if ($target -and !(Test-Path -LiteralPath (Join-Path $file.DirectoryName $target))) { $problems.Add([pscustomobject]@{kind='missing_markdown_link';file=$file.FullName;target=$target}) }
    }
}

$originalBusinessUnchanged = 0
$navigationChanged = @()
foreach ($old in $baseline) {
    $same = (Test-Path -LiteralPath $old.path) -and ((Get-FileHash -LiteralPath $old.path -Algorithm SHA256).Hash -eq $old.sha256)
    if ($old.path -match '\\00-导航\\') { if (!$same) { $navigationChanged += $old.path }; continue }
    if ($same) { $originalBusinessUnchanged++ } else { $problems.Add([pscustomobject]@{kind='original_business_changed';file=$old.path}) }
}

$newPages = @()
foreach ($file in $business) {
    if (!$indexText.Contains('[[' + $file.BaseName + ']]')) { $problems.Add([pscustomobject]@{kind='missing_from_index';file=$file.FullName}) }
    $body = Get-Content -LiteralPath $file.FullName -Raw
    if ($body -match '(?m)^type: knowledge\s*$') {
        $newPages += $file.FullName
        foreach ($field in @('material_kind','updated','review_status','confidentiality','source_ids')) {
            if ($body -notmatch ('(?m)^' + $field + ':')) { $problems.Add([pscustomobject]@{kind='missing_metadata';file=$file.FullName;field=$field}) }
        }
        $sourceIds = @([regex]::Matches($body, '(?m)^  - (FS-\d+)\s*$') | ForEach-Object { $_.Groups[1].Value })
        if ($sourceIds.Count -eq 0) { $problems.Add([pscustomobject]@{kind='missing_source_id';file=$file.FullName}) }
        foreach ($id in $sourceIds) {
            $entry = @($manifest.sources | Where-Object source_id -eq $id)
            if ($entry.Count -ne 1 -or !$entry[0].md_path) { $problems.Add([pscustomobject]@{kind='source_not_readable';file=$file.FullName;source_id=$id}) }
        }
    }
}

$hashes = @()
foreach ($source in $manifest.sources) {
    foreach ($field in @('json_path','md_path','binary_path')) {
        if ($source.$field) {
            $path = Join-Path $WikiRoot $source.$field
            if (!(Test-Path -LiteralPath $path -PathType Leaf)) { $problems.Add([pscustomobject]@{kind='missing_source_file';source_id=$source.source_id;path=$source.$field}); continue }
            $hashes += [pscustomobject]@{source_id=$source.source_id;field=$field;path=$source.$field;sha256=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash}
        }
    }
}

$secretValueCount = 0
$replacementCharacterFiles = @()
foreach ($file in @($allFiles | Where-Object { $_.FullName.StartsWith($WikiRoot + '\') -and $_.Extension -in @('.md','.json') })) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    if ($text.Contains([char]0xFFFD)) { $replacementCharacterFiles += $file.FullName }
    foreach ($match in [regex]::Matches($text, '(?i)(?:disposable_login_token|access_token|refresh_token|app_secret|client_secret)=([^\s&)"<>\\]+)')) {
        if ($match.Groups[1].Value -ne '[REDACTED]') { $secretValueCount++ }
    }
}
if ($secretValueCount -gt 0) { $problems.Add([pscustomobject]@{kind='unredacted_credential_query';count=$secretValueCount}) }
if ($replacementCharacterFiles.Count -gt 0) { $problems.Add([pscustomobject]@{kind='unicode_replacement_character';files=$replacementCharacterFiles}) }

[pscustomobject]@{
    checked_on=(Get-Date).ToString('yyyy-MM-dd')
    checked_at=(Get-Date).ToString('o')
    baseline_batch='2026-09-19'
    wiki_root=$WikiRoot
    business_pages=$business.Count
    new_knowledge_pages=$newPages.Count
    original_business_unchanged=$originalBusinessUnchanged
    intentionally_changed_navigation=$navigationChanged
    checked_curated_markdown=$curated.Count
    checked_wikilinks=$linkCount
    registered_sources=$manifest.sources.Count
    source_files_checked=$hashes.Count
    unredacted_credential_query_values=$secretValueCount
    problems=@($problems.ToArray())
    source_hashes=$hashes
    exclusions=@('Historical raw/ references are documented source debt, not resolved links.','Imported raw source links and remote media are not checked for availability.','No visual Obsidian rendering or business-owner approval is asserted.')
} | ConvertTo-Json -Depth 8
