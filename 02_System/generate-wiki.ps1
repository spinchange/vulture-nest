<#
.SYNOPSIS
    Compiles wiki markdown notes into static HTML pages.
.DESCRIPTION
    Reads all markdown files in 01_Wiki, extracts YAML frontmatter, converts a
    supported markdown subset to HTML, resolves wikilinks, injects graph
    neighbors from the PoShWiKi SQLite database, and writes HTML files into
    03_Web/public using 03_Web/template.html.
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/generate-wiki.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

try {
    if ($PSVersionTable.PSEdition -ne 'Core') {
        throw "generate-wiki.ps1 requires PowerShell 7 (pwsh). Current edition: $($PSVersionTable.PSEdition)."
    }

    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $VaultRoot = Split-Path -Parent $PSScriptRoot
    $WikiPath = Join-Path $VaultRoot '01_Wiki'
    $TemplatePath = Join-Path $VaultRoot '03_Web/template.html'
    $OutputDirectory = Join-Path $VaultRoot '03_Web/public'
    $DbPath = $env:POSHWIKI_DB_PATH
    if ([string]::IsNullOrWhiteSpace($DbPath)) {
        $DbPath = Join-Path $VaultRoot '00_Raw/PoShWiKi/wiki.db'
    }

    $LibPath = Join-Path $VaultRoot '00_Raw/PoShWiKi/lib'
    $Script:SqliteLoaded = $false

    function Import-SqliteAssemblies {
        if ($Script:SqliteLoaded) {
            return
        }

        if ('Microsoft.Data.Sqlite.SqliteConnection' -as [type]) {
            $Script:SqliteLoaded = $true
            return
        }

        $dlls = @(
            'SQLitePCLRaw.core.dll',
            'SQLitePCLRaw.provider.e_sqlite3.dll',
            'SQLitePCLRaw.batteries_v2.dll',
            'Microsoft.Data.Sqlite.dll'
        )

        foreach ($dll in $dlls) {
            $path = Join-Path $LibPath $dll
            if (-not (Test-Path $path)) {
                throw "Required SQLite assembly not found: $path"
            }

            try {
                Add-Type -Path $path -ErrorAction Stop
            } catch [System.InvalidOperationException] {
                # Safe when the assembly is already loaded.
            }
        }

        $os = if ($IsWindows) { 'win' } elseif ($IsLinux) { 'linux' } elseif ($IsMacOS) { 'osx' } else { 'unknown' }
        $arch = [Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLowerInvariant()
        $runtimeArch = switch ($arch) {
            'x64' { 'x64' }
            'arm64' { 'arm64' }
            'x86' { 'x86' }
            'arm' { 'arm' }
            default { $arch }
        }

        $nativeLibName = if ($IsWindows) { 'e_sqlite3.dll' } elseif ($IsMacOS) { 'libe_sqlite3.dylib' } else { 'libe_sqlite3.so' }
        $nativePath = Join-Path $LibPath "runtimes/$os-$runtimeArch/native/$nativeLibName"

        if (-not (Test-Path $nativePath)) {
            throw "Required native SQLite library not found: $nativePath"
        }

        try {
            [Runtime.InteropServices.NativeLibrary]::Load($nativePath) | Out-Null
        } catch {
            Write-Verbose "Native library already loaded or deferred to SQLitePCL: $_"
        }

        [SQLitePCL.Batteries]::Init()

        if (-not ('Microsoft.Data.Sqlite.SqliteConnection' -as [type])) {
            throw "SQLite types failed to load from $LibPath."
        }

        $Script:SqliteLoaded = $true
    }

    function Get-SqliteConnection {
        $connection = [Microsoft.Data.Sqlite.SqliteConnection]::new("Data Source=$DbPath")
        $connection.Open()
        return $connection
    }

    function Invoke-SqliteQuery {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Query,
            [hashtable]$Parameters = @{}
        )

        $connection = Get-SqliteConnection
        try {
            $command = $connection.CreateCommand()
            $command.CommandText = $Query
            foreach ($key in $Parameters.Keys) {
                $command.Parameters.AddWithValue("@$key", $Parameters[$key]) | Out-Null
            }

            $reader = $command.ExecuteReader()
            try {
                $results = @()
                while ($reader.Read()) {
                    $row = [ordered]@{}
                    for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                        $row[$reader.GetName($i)] = if ($reader.IsDBNull($i)) { $null } else { $reader.GetValue($i) }
                    }
                    $results += [PSCustomObject]$row
                }

                return @($results)
            }
            finally {
                $reader.Close()
                $reader.Dispose()
            }
        }
        finally {
            $connection.Close()
            $connection.Dispose()
        }
    }

    function Get-NormalizedContent {
        param([Parameter(Mandatory = $true)][string]$Path)
        return ((Get-Content -Path $Path -Raw) -replace "`0", '') -replace "`r`n", "`n"
    }

    function ConvertTo-HtmlSafe {
        param([AllowNull()][object]$Value)
        $safeValue = if ($null -eq $Value) { '' } else { [string]$Value }
        return [System.Net.WebUtility]::HtmlEncode($safeValue)
    }

    function Get-HtmlFileName {
        param([Parameter(Mandatory = $true)][string]$NoteName)
        return ([uri]::EscapeDataString($NoteName) -replace '%2F', '/') + '.html'
    }

    function New-WikiAnchor {
        param(
            [Parameter(Mandatory = $true)][string]$Target,
            [Parameter(Mandatory = $true)][string]$Label,
            [string]$CssClass = 'wikilink'
        )

        $href = ConvertTo-HtmlSafe (Get-HtmlFileName -NoteName $Target)
        $safeLabel = ConvertTo-HtmlSafe $Label
        $safeClass = ConvertTo-HtmlSafe $CssClass
        return "<a href=""$href"" class=""$safeClass"">$safeLabel</a>"
    }

    function Parse-FrontmatterValue {
        param([Parameter(Mandatory = $true)][string]$RawValue)

        $trimmed = $RawValue.Trim()
        if ($trimmed -match '^\[(.*)\]$') {
            $inner = $Matches[1].Trim()
            if ([string]::IsNullOrWhiteSpace($inner)) {
                return @()
            }

            return @(
                $inner -split ',' |
                ForEach-Object { $_.Trim().Trim("'`"") } |
                Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
            )
        }

        return $trimmed.Trim("'`"")
    }

    function Split-Frontmatter {
        param([Parameter(Mandatory = $true)][string]$Content)

        $match = [regex]::Match($Content, '^(?s)---\n(.*?)\n---\n?')
        $frontmatter = [ordered]@{}
        $body = $Content

        if ($match.Success) {
            $frontmatterText = $match.Groups[1].Value
            $body = $Content.Substring($match.Length).TrimStart("`n")

            foreach ($line in ($frontmatterText -split "`n")) {
                if ([string]::IsNullOrWhiteSpace($line)) {
                    continue
                }

                $parts = $line -split ':\s*', 2
                if ($parts.Count -ne 2) {
                    continue
                }

                $key = $parts[0].Trim()
                $value = Parse-FrontmatterValue -RawValue $parts[1]
                $frontmatter[$key] = $value
            }
        }

        return [PSCustomObject]@{
            Frontmatter = $frontmatter
            Body        = $body
        }
    }

    function Convert-InlineMarkdown {
        param([Parameter(Mandatory = $true)][string]$Text)

        $encoded = ConvertTo-HtmlSafe $Text
        $encoded = [regex]::Replace($encoded, '\[\[([^\]|]+)\|([^\]]+)\]\]', {
            param($match)
            New-WikiAnchor -Target $match.Groups[1].Value.Trim() -Label $match.Groups[2].Value.Trim()
        })
        $encoded = [regex]::Replace($encoded, '\[\[([^\]]+)\]\]', {
            param($match)
            $target = $match.Groups[1].Value.Trim()
            New-WikiAnchor -Target $target -Label $target
        })
        $encoded = [regex]::Replace($encoded, '\*\*(.+?)\*\*', '<strong>$1</strong>')
        $encoded = [regex]::Replace($encoded, '(?<!`)`([^`]+)`(?!`)', '<code>$1</code>')
        return $encoded
    }

    function Get-ListItemData {
        param([Parameter(Mandatory = $true)][string]$Line)

        if ($Line -match '^(\s*)([-*])\s+(.+)$') {
            $indent = $Matches[1].Replace("`t", '    ').Length
            return [PSCustomObject]@{
                Type    = 'ul'
                Level   = [math]::Floor($indent / 2)
                Content = $Matches[3]
            }
        }

        if ($Line -match '^(\s*)(\d+)\.\s+(.+)$') {
            $indent = $Matches[1].Replace("`t", '    ').Length
            return [PSCustomObject]@{
                Type    = 'ol'
                Level   = [math]::Floor($indent / 2)
                Content = $Matches[3]
            }
        }

        return $null
    }

    function Close-OpenLists {
        param(
            [System.Collections.Generic.List[string]]$Html,
            [System.Collections.Generic.List[object]]$Stack,
            [int]$TargetDepth = 0
        )

        while ($Stack.Count -gt $TargetDepth) {
            $list = $Stack[$Stack.Count - 1]
            $Html.Add('</li>')
            $Html.Add("</$($list.Type)>")
            $Stack.RemoveAt($Stack.Count - 1)
        }
    }

    function Convert-MarkdownToHtml {
        param([Parameter(Mandatory = $true)][string]$Markdown)

        $lines = $Markdown -split "`n"
        $html = New-Object System.Collections.Generic.List[string]
        $listStack = New-Object System.Collections.Generic.List[object]
        $paragraphLines = New-Object System.Collections.Generic.List[string]
        $codeFenceOpen = $false
        $codeLines = New-Object System.Collections.Generic.List[string]

        function Flush-Paragraph {
            if ($paragraphLines.Count -eq 0) {
                return
            }

            $joined = ($paragraphLines -join ' ').Trim()
            if ($joined) {
                $html.Add("<p>$(Convert-InlineMarkdown -Text $joined)</p>")
            }
            $paragraphLines.Clear()
        }

        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]

            if ($codeFenceOpen) {
                if ($line -match '^```') {
                    $codeFenceOpen = $false
                    $codeText = ConvertTo-HtmlSafe ($codeLines -join "`n")
                    $html.Add("<pre><code>$codeText</code></pre>")
                    $codeLines.Clear()
                }
                else {
                    $codeLines.Add($line)
                }
                continue
            }

            if ($line -match '^```') {
                Flush-Paragraph
                Close-OpenLists -Html $html -Stack $listStack -TargetDepth 0
                $codeFenceOpen = $true
                $codeLines.Clear()
                continue
            }

            if ([string]::IsNullOrWhiteSpace($line)) {
                Flush-Paragraph
                Close-OpenLists -Html $html -Stack $listStack -TargetDepth 0
                continue
            }

            if ($line -match '^(#{1,6})\s+(.+)$') {
                Flush-Paragraph
                Close-OpenLists -Html $html -Stack $listStack -TargetDepth 0
                $level = $Matches[1].Length
                $text = Convert-InlineMarkdown -Text $Matches[2].Trim()
                $html.Add("<h$level>$text</h$level>")
                continue
            }

            $listItem = Get-ListItemData -Line $line
            if ($listItem) {
                Flush-Paragraph

                while ($listStack.Count -gt ($listItem.Level + 1)) {
                    $current = $listStack[$listStack.Count - 1]
                    $html.Add('</li>')
                    $html.Add("</$($current.Type)>")
                    $listStack.RemoveAt($listStack.Count - 1)
                }

                if ($listStack.Count -eq ($listItem.Level + 1)) {
                    $html.Add('</li>')
                    if ($listStack[$listStack.Count - 1].Type -ne $listItem.Type) {
                        $current = $listStack[$listStack.Count - 1]
                        $html.Add("</$($current.Type)>")
                        $listStack.RemoveAt($listStack.Count - 1)
                    }
                }

                while ($listStack.Count -lt $listItem.Level) {
                    $html.Add('<ul>')
                    $listStack.Add([PSCustomObject]@{ Type = 'ul' })
                    $html.Add('<li>')
                }

                if ($listStack.Count -eq $listItem.Level) {
                    $html.Add("<$($listItem.Type)>")
                    $listStack.Add([PSCustomObject]@{ Type = $listItem.Type })
                }

                $html.Add("<li>$(Convert-InlineMarkdown -Text $listItem.Content.Trim())")
                continue
            }

            if ($line -match '^\s*---\s*$') {
                Flush-Paragraph
                Close-OpenLists -Html $html -Stack $listStack -TargetDepth 0
                $html.Add('<hr>')
                continue
            }

            $paragraphLines.Add($line.Trim())
        }

        Flush-Paragraph
        Close-OpenLists -Html $html -Stack $listStack -TargetDepth 0

        if ($codeFenceOpen) {
            $codeText = ConvertTo-HtmlSafe ($codeLines -join "`n")
            $html.Add("<pre><code>$codeText</code></pre>")
        }

        return ($html -join [Environment]::NewLine)
    }

    function Convert-FrontmatterToHtml {
        param([hashtable]$Frontmatter)

        if (-not $Frontmatter -or $Frontmatter.Count -eq 0) {
            return '<span class="fm-field"><span class="fm-key">meta</span><span class="fm-val">none</span></span>'
        }

        $items = foreach ($entry in $Frontmatter.GetEnumerator()) {
            $rawValue = if ($entry.Value -is [System.Collections.IEnumerable] -and $entry.Value -isnot [string]) {
                ($entry.Value | ForEach-Object { [string]$_ }) -join ', '
            }
            else {
                [string]$entry.Value
            }

            $statusClass = if ($entry.Key -eq 'status') { " status-$($rawValue.ToLowerInvariant())" } else { '' }
            "<span class=""fm-field""><span class=""fm-key"">$(ConvertTo-HtmlSafe $entry.Key)</span><span class=""fm-val$statusClass"">$(ConvertTo-HtmlSafe $rawValue)</span></span>"
        }

        return ($items -join [Environment]::NewLine)
    }

    function Get-GraphNeighbors {
        param([Parameter(Mandatory = $true)][string]$NoteName)

        $outgoing = Invoke-SqliteQuery -Query @'
SELECT DISTINCT Target
FROM Links
WHERE Source = @NoteName
ORDER BY Target COLLATE NOCASE;
'@ -Parameters @{ NoteName = $NoteName }

        $incoming = Invoke-SqliteQuery -Query @'
SELECT DISTINCT Source
FROM Links
WHERE Target = @NoteName
ORDER BY Source COLLATE NOCASE;
'@ -Parameters @{ NoteName = $NoteName }

        return [PSCustomObject]@{
            Outgoing = @($outgoing | ForEach-Object { $_.Target })
            Incoming = @($incoming | ForEach-Object { $_.Source })
        }
    }

    function Convert-GraphNeighborsToHtml {
        param(
            [string[]]$Incoming,
            [string[]]$Outgoing
        )

        $sections = New-Object System.Collections.Generic.List[string]

        if ($Incoming.Count -gt 0) {
            $sections.Add('<span class="graph-section-label">Links To This Note</span>')
            $sections.Add('<ul>')
            foreach ($note in $Incoming) {
                $sections.Add("<li>$(New-WikiAnchor -Target $note -Label $note -CssClass '')</li>")
            }
            $sections.Add('</ul>')
        }

        if ($Outgoing.Count -gt 0) {
            $sections.Add('<span class="graph-section-label">Links From This Note</span>')
            $sections.Add('<ul>')
            foreach ($note in $Outgoing) {
                $sections.Add("<li>$(New-WikiAnchor -Target $note -Label $note -CssClass '')</li>")
            }
            $sections.Add('</ul>')
        }

        if ($sections.Count -eq 0) {
            return '<div class="graph-empty">No graph neighbors recorded in PoShWiKi.</div>'
        }

        return ($sections -join [Environment]::NewLine)
    }

    Import-SqliteAssemblies

    if (-not (Test-Path $TemplatePath)) {
        throw "Template not found: $TemplatePath"
    }

    if (-not (Test-Path $OutputDirectory)) {
        New-Item -ItemType Directory -Path $OutputDirectory | Out-Null
    }

    $template = Get-NormalizedContent -Path $TemplatePath
    $wikiFiles = Get-ChildItem -Path $WikiPath -Filter '*.md' | Sort-Object Name
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $results = New-Object System.Collections.Generic.List[object]

    foreach ($file in $wikiFiles) {
        $noteName = $file.BaseName
        $content = Get-NormalizedContent -Path $file.FullName
        $parts = Split-Frontmatter -Content $content
        $frontmatter = $parts.Frontmatter
        $title = if ($frontmatter.Contains('title') -and -not [string]::IsNullOrWhiteSpace([string]$frontmatter['title'])) {
            [string]$frontmatter['title']
        }
        else {
            $noteName
        }

        $bodyHtml = Convert-MarkdownToHtml -Markdown $parts.Body
        $frontmatterHtml = Convert-FrontmatterToHtml -Frontmatter $frontmatter
        $neighbors = Get-GraphNeighbors -NoteName $noteName
        $graphHtml = Convert-GraphNeighborsToHtml -Incoming $neighbors.Incoming -Outgoing $neighbors.Outgoing

        $safeTitle = ConvertTo-HtmlSafe $title
        $pageHtml = $template
        $pageHtml = $pageHtml.Replace('{{TITLE}}', $safeTitle)
        $pageHtml = $pageHtml.Replace('{{CONTENT}}', $bodyHtml)
        $pageHtml = $pageHtml.Replace('{{FRONTMATTER}}', $frontmatterHtml)
        $pageHtml = $pageHtml.Replace('{{GRAPH_NEIGHBORS}}', $graphHtml)

        $outputPath = Join-Path $OutputDirectory (Get-HtmlFileName -NoteName $noteName)
        [System.IO.File]::WriteAllText($outputPath, $pageHtml, $utf8NoBom)

        $results.Add([PSCustomObject]@{
            Note       = $noteName
            Title      = $title
            OutputPath = $outputPath
            Incoming   = $neighbors.Incoming.Count
            Outgoing   = $neighbors.Outgoing.Count
        })
    }

    Write-Host "Compiled $($results.Count) wiki pages into $OutputDirectory" -ForegroundColor Green
    $results
}
catch {
    Write-Error $_
    exit 1
}
