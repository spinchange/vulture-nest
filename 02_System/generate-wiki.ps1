<#
.SYNOPSIS
    Compiles wiki markdown notes into static HTML pages (Incremental).
.DESCRIPTION
    Reads all markdown files in 01_Wiki, extracts YAML frontmatter, converts a
    supported markdown subset to HTML, resolves wikilinks, injects graph
    neighbors from the PoShWiKi SQLite database, and writes HTML files into
    03_Web/public using 03_Web/template.html.
.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/generate-wiki.ps1
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$Force
)

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
    $LlmsTxtRootPath = Join-Path $VaultRoot 'llms.txt'
    $LlmsTxtPublicPath = Join-Path $OutputDirectory 'llms.txt'
    $SearchIndexPublicPath = Join-Path $OutputDirectory 'search-index.json'
    $PortalBaseUrl = 'https://spinchange.github.io/vulture-nest'
    $RepoBaseUrl = 'https://github.com/spinchange/vulture-nest'
    $DbPath = $env:POSHWIKI_DB_PATH
    if ([string]::IsNullOrWhiteSpace($DbPath)) {
        $DbPath = Join-Path $VaultRoot '00_Raw/PoShWiKi/wiki.db'
    }

    $LibPath = Join-Path $VaultRoot '00_Raw/PoShWiKi/lib'
    $Script:SqliteLoaded = $false

    function Import-SqliteAssemblies {
        if ($Script:SqliteLoaded) { return }
        if ('Microsoft.Data.Sqlite.SqliteConnection' -as [type]) { $Script:SqliteLoaded = $true; return }
        
        $dlls = @('SQLitePCLRaw.core.dll', 'SQLitePCLRaw.provider.e_sqlite3.dll', 'SQLitePCLRaw.batteries_v2.dll', 'Microsoft.Data.Sqlite.dll')
        foreach ($dll in $dlls) {
            $path = Join-Path $LibPath $dll
            if (Test-Path $path) {
                try {
                    [System.Reflection.Assembly]::LoadFrom($path) | Out-Null
                } catch {
                    Add-Type -Path $path -ErrorAction SilentlyContinue
                }
            }
        }
        
        $os = if ($IsWindows) { 'win' } elseif ($IsLinux) { 'linux' } else { 'osx' }
        $arch = [Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLower()
        $nativeLibName = if ($IsWindows) { 'e_sqlite3.dll' } elseif ($IsMacOS) { 'libe_sqlite3.dylib' } else { 'libe_sqlite3.so' }
        $nativePath = Join-Path $LibPath "runtimes/$os-$arch/native/$nativeLibName"
        
        if (Test-Path $nativePath) {
            try { [Runtime.InteropServices.NativeLibrary]::Load($nativePath) | Out-Null } catch {}
        }
        
        try { [SQLitePCL.Batteries]::Init() } catch {}
        $Script:SqliteLoaded = $true
    }

    function Get-SqliteConnection {
        $connection = [Microsoft.Data.Sqlite.SqliteConnection]::new("Data Source=$DbPath")
        $connection.Open()
        return $connection
    }

    function Invoke-SqliteQuery {
        param([string]$Query, [hashtable]$Parameters = @{})
        $connection = Get-SqliteConnection
        try {
            $command = $connection.CreateCommand()
            $command.CommandText = $Query
            foreach ($key in $Parameters.Keys) { $command.Parameters.AddWithValue("@$key", $Parameters[$key]) | Out-Null }
            $reader = $command.ExecuteReader()
            try {
                $results = @()
                while ($reader.Read()) {
                    $row = [ordered]@{}
                    for ($i = 0; $i -lt $reader.FieldCount; $i++) { $row[$reader.GetName($i)] = if ($reader.IsDBNull($i)) { $null } else { $reader.GetValue($i) } }
                    $results += [PSCustomObject]$row
                }
                return @($results)
            } finally { $reader.Close(); $reader.Dispose() }
        } finally { $connection.Close(); $connection.Dispose() }
    }

    function Get-NormalizedContent {
        param([string]$Path)
        return ((Get-Content -Path $Path -Raw) -replace "`0", '') -replace "`r`n", "`n"
    }

    function ConvertTo-HtmlSafe {
        param([object]$Value)
        $safeValue = if ($null -eq $Value) { '' } else { [string]$Value }
        return [System.Net.WebUtility]::HtmlEncode($safeValue)
    }

    function Get-HtmlFileName {
        param([string]$NoteName)
        return ([uri]::EscapeDataString($NoteName) -replace '%2F', '/') + '.html'
    }

    function Get-PortalUrl {
        param([string]$NoteName)
        return "$PortalBaseUrl/$(Get-HtmlFileName -NoteName $NoteName)"
    }

    function Get-RepoBlobUrl {
        param([string]$RelativePath)
        $normalized = ($RelativePath -replace '\\', '/')
        $segments = $normalized -split '/'
        $escapedSegments = $segments | ForEach-Object { [uri]::EscapeDataString($_) }
        return "$RepoBaseUrl/blob/main/$($escapedSegments -join '/')"
    }

    function New-WikiAnchor {
        param([string]$Target, [string]$Label, [string]$CssClass = 'wikilink')
        $href = ConvertTo-HtmlSafe (Get-HtmlFileName -NoteName $Target)
        $safeLabel = ConvertTo-HtmlSafe $Label
        $safeClass = ConvertTo-HtmlSafe $CssClass
        return "<a href=""$href"" class=""$safeClass"">$safeLabel</a>"
    }

    function Parse-FrontmatterValue {
        param([string]$RawValue)
        $trimmed = $RawValue.Trim()
        if ($trimmed -match '^\[(.*)\]$') {
            $inner = $Matches[1].Trim()
            if ([string]::IsNullOrWhiteSpace($inner)) { return @() }
            return @($inner -split ',' | ForEach-Object { $_.Trim().Trim("'`"") } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        }
        return $trimmed.Trim("'`"")
    }

    function Split-Frontmatter {
        param([string]$Content)
        $match = [regex]::Match($Content, '^(?s)---\n(.*?)\n---\n?')
        $frontmatter = [ordered]@{}
        $body = $Content
        if ($match.Success) {
            $frontmatterText = $match.Groups[1].Value
            $body = $Content.Substring($match.Length).TrimStart("`n")
            foreach ($line in ($frontmatterText -split "`n")) {
                if ([string]::IsNullOrWhiteSpace($line)) { continue }
                $parts = $line -split ':\s*', 2
                if ($parts.Count -ne 2) { continue }
                $frontmatter[$parts[0].Trim()] = Parse-FrontmatterValue -RawValue $parts[1]
            }
        }
        return [PSCustomObject]@{ Frontmatter = $frontmatter; Body = $body }
    }

    function Convert-InlineMarkdown {
        param([string]$Text)
        $encoded = ConvertTo-HtmlSafe $Text
        # 1. Standard Markdown Links: [Label](URL)
        $encoded = [regex]::Replace($encoded, '\[([^\]]+)\]\(([^)]+)\)', '<a href="$2">$1</a>')
        # 2. Wikilinks with Aliases: [[Target|Label]]
        $encoded = [regex]::Replace($encoded, '\[\[([^\]|]+)\|([^\]]+)\]\]', { param($match) New-WikiAnchor -Target $match.Groups[1].Value.Trim() -Label $match.Groups[2].Value.Trim() })
        # 3. Standard Wikilinks: [[Target]]
        $encoded = [regex]::Replace($encoded, '\[\[([^\]]+)\]\]', { param($match) $target = $match.Groups[1].Value.Trim(); New-WikiAnchor -Target $target -Label $target })
        # 4. Bold and Code
        $encoded = [regex]::Replace($encoded, '\*\*(.+?)\*\*', '<strong>$1</strong>')
        $encoded = [regex]::Replace($encoded, '(?<!`)`([^`]+)`(?!`)', '<code>$1</code>')
        return $encoded
    }

    function Get-ListItemData {
        param([string]$Line)
        if ($Line -match '^(\s*)([-*])\s+(.+)$') { return [PSCustomObject]@{ Type = 'ul'; Level = [math]::Floor($Matches[1].Replace("`t", '    ').Length / 2); Content = $Matches[3] } }
        if ($Line -match '^(\s*)(\d+)\.\s+(.+)$') { return [PSCustomObject]@{ Type = 'ol'; Level = [math]::Floor($Matches[1].Replace("`t", '    ').Length / 2); Content = $Matches[3] } }
        return $null
    }

    function Close-OpenLists {
        param($Html, $Stack, $TargetDepth = 0)
        while ($Stack.Count -gt $TargetDepth) { $list = $Stack[$Stack.Count - 1]; $Html.Add('</li>'); $Html.Add("</$($list.Type)>"); $Stack.RemoveAt($Stack.Count - 1) }
    }

    function Convert-MarkdownToHtml {
        param([string]$Markdown)
        $lines = $Markdown -split "`n"
        $html = New-Object System.Collections.Generic.List[string]
        $listStack = New-Object System.Collections.Generic.List[object]
        $paragraphLines = New-Object System.Collections.Generic.List[string]
        $tableLines = New-Object System.Collections.Generic.List[string]
        $codeFenceOpen = $false
        $codeLines = New-Object System.Collections.Generic.List[string]
        function Flush-Paragraph {
            if ($paragraphLines.Count -eq 0) { return }
            $joined = ($paragraphLines -join ' ').Trim()
            if ($joined) { $html.Add("<p>$(Convert-InlineMarkdown -Text $joined)</p>") }
            $paragraphLines.Clear()
        }
        function Flush-Table {
            if ($tableLines.Count -eq 0) { return }
            $rows = @($tableLines | ForEach-Object { $_ })
            $tableLines.Clear()
            $splitRow = [scriptblock]{
                param([string]$Row)
                $parts = @($Row -split '\|')
                if ($parts.Count -gt 0 -and [string]::IsNullOrWhiteSpace($parts[0])) { $parts = $parts[1..($parts.Count - 1)] }
                if ($parts.Count -gt 0 -and [string]::IsNullOrWhiteSpace($parts[-1])) { $parts = $parts[0..($parts.Count - 2)] }
                return @($parts | ForEach-Object { $_.Trim() })
            }
            $hasSeparator = $false
            if ($rows.Count -ge 2) {
                $sepCells = @($rows[1] -split '\|' | Where-Object { $_.Trim() -ne '' })
                $hasSeparator = $sepCells.Count -gt 0 -and ($sepCells | Where-Object { $_.Trim() -notmatch '^:?-+:?$' }).Count -eq 0
            }
            $html.Add('<table>')
            if ($hasSeparator) {
                $headerCells = & $splitRow $rows[0]
                $html.Add('<thead><tr>')
                foreach ($cell in $headerCells) { $html.Add("<th>$(Convert-InlineMarkdown -Text $cell)</th>") }
                $html.Add('</tr></thead><tbody>')
                for ($r = 2; $r -lt $rows.Count; $r++) {
                    $cells = & $splitRow $rows[$r]
                    $html.Add('<tr>')
                    foreach ($cell in $cells) { $html.Add("<td>$(Convert-InlineMarkdown -Text $cell)</td>") }
                    $html.Add('</tr>')
                }
                $html.Add('</tbody>')
            } else {
                $html.Add('<tbody>')
                foreach ($row in $rows) {
                    $cells = & $splitRow $row
                    $html.Add('<tr>')
                    foreach ($cell in $cells) { $html.Add("<td>$(Convert-InlineMarkdown -Text $cell)</td>") }
                    $html.Add('</tr>')
                }
                $html.Add('</tbody>')
            }
            $html.Add('</table>')
        }
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            
            # Special Log Entry Parser: - **YYYY-MM-DD HH:mm**: Description
            if ($line -match '^\s*-\s*\*\*(\d{4}-\d{2}-\d{2}\s\d{2}:\d{2})\*\*:\s*(.+)$') {
                Flush-Paragraph; Close-OpenLists -Html $html -Stack $listStack -TargetDepth 0
                $timestamp = $Matches[1]
                $entryBody = Convert-InlineMarkdown -Text $Matches[2].Trim()
                $html.Add("<div class=""log-entry""><span class=""log-time"">$timestamp</span><span class=""log-content"">$entryBody</span></div>")
                continue
            }

            if ($codeFenceOpen) {
                if ($line -match '^```') { $codeFenceOpen = $false; $html.Add("<pre><code>$(ConvertTo-HtmlSafe ($codeLines -join "`n"))</code></pre>"); $codeLines.Clear() }
                else { $codeLines.Add($line) }
                continue
            }
            if ($line -match '^```') { Flush-Paragraph; Close-OpenLists -Html $html -Stack $listStack -TargetDepth 0; $codeFenceOpen = $true; $codeLines.Clear(); continue }
            if ($line -match '^\s*\|') { Flush-Paragraph; Close-OpenLists -Html $html -Stack $listStack -TargetDepth 0; $tableLines.Add($line); continue }
            if ($tableLines.Count -gt 0) { Flush-Table }
            if ([string]::IsNullOrWhiteSpace($line)) { Flush-Paragraph; Close-OpenLists -Html $html -Stack $listStack -TargetDepth 0; continue }
            if ($line -match '^(#{1,6})\s+(.+)$') { Flush-Paragraph; Close-OpenLists -Html $html -Stack $listStack -TargetDepth 0; $html.Add("<h$($Matches[1].Length)>$(Convert-InlineMarkdown -Text $Matches[2].Trim())</h$($Matches[1].Length)>"); continue }
            $listItem = Get-ListItemData -Line $line
            if ($listItem) {
                Flush-Paragraph
                while ($listStack.Count -gt ($listItem.Level + 1)) { $current = $listStack[$listStack.Count - 1]; $html.Add('</li>'); $html.Add("</$($current.Type)>"); $listStack.RemoveAt($listStack.Count - 1) }
                if ($listStack.Count -eq ($listItem.Level + 1)) { $html.Add('</li>'); if ($listStack[$listStack.Count - 1].Type -ne $listItem.Type) { $current = $listStack[$listStack.Count - 1]; $html.Add("</$($current.Type)>"); $listStack.RemoveAt($listStack.Count - 1) } }
                while ($listStack.Count -lt $listItem.Level) { $html.Add('<ul>'); $listStack.Add([PSCustomObject]@{ Type = 'ul' }); $html.Add('<li>') }
                if ($listStack.Count -eq $listItem.Level) { $html.Add("<$($listItem.Type)>"); $listStack.Add([PSCustomObject]@{ Type = $listItem.Type }) }
                $html.Add("<li>$(Convert-InlineMarkdown -Text $listItem.Content.Trim())")
                continue
            }
            if ($line -match '^\s*---\s*$') { Flush-Paragraph; Close-OpenLists -Html $html -Stack $listStack -TargetDepth 0; $html.Add('<hr>'); continue }
            $paragraphLines.Add($line.Trim())
        }
        Flush-Paragraph; Close-OpenLists -Html $html -Stack $listStack -TargetDepth 0; if ($tableLines.Count -gt 0) { Flush-Table }
        if ($codeFenceOpen) { $html.Add("<pre><code>$(ConvertTo-HtmlSafe ($codeLines -join "`n"))</code></pre>") }
        return ($html -join [Environment]::NewLine)
    }

    function Convert-MarkdownToSearchText {
        param([string]$Markdown)
        $text = $Markdown
        $text = [regex]::Replace($text, '(?s)```.*?```', ' ')
        $text = [regex]::Replace($text, '\[\[([^\]|]+)\|([^\]]+)\]\]', '$2')
        $text = [regex]::Replace($text, '\[\[([^\]]+)\]\]', '$1')
        $text = [regex]::Replace($text, '\[([^\]]+)\]\(([^)]+)\)', '$1')
        $text = [regex]::Replace($text, '(?m)^\s{0,3}#{1,6}\s*', '')
        $text = [regex]::Replace($text, '(?m)^\s*[-*+]\s+', '')
        $text = [regex]::Replace($text, '(?m)^\s*\d+\.\s+', '')
        $text = $text -replace '\*\*', ''
        $text = $text -replace '`', ''
        $text = $text -replace '\|', ' '
        $text = [System.Net.WebUtility]::HtmlDecode($text)
        $text = [regex]::Replace($text, '\s+', ' ').Trim()
        return $text
    }

    function New-SearchIndexEntry {
        param(
            [string]$NoteName,
            [string]$Title,
            [hashtable]$Frontmatter,
            [string]$Body
        )

        $aliases = @()
        if ($Frontmatter.Contains('aliases')) {
            $rawAliases = $Frontmatter['aliases']
            if ($rawAliases -is [System.Array]) { $aliases = @($rawAliases | ForEach-Object { [string]$_ }) }
            elseif ($null -ne $rawAliases -and -not [string]::IsNullOrWhiteSpace([string]$rawAliases)) { $aliases = @([string]$rawAliases) }
        }

        $bodyText = Convert-MarkdownToSearchText -Markdown $Body
        $excerpt = if ($bodyText.Length -gt 220) { $bodyText.Substring(0, 220) + '…' } else { $bodyText }
        $searchParts = @($Title, $NoteName, ($aliases -join ' '), $excerpt, $bodyText) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

        return [PSCustomObject]@{
            note    = $NoteName
            title   = $Title
            url     = Get-HtmlFileName -NoteName $NoteName
            aliases = $aliases
            type    = if ($Frontmatter.Contains('type')) { [string]$Frontmatter['type'] } else { '' }
            status  = if ($Frontmatter.Contains('status')) { [string]$Frontmatter['status'] } else { '' }
            excerpt = $excerpt
            search  = (($searchParts -join ' ') -replace '\s+', ' ').Trim().ToLowerInvariant()
        }
    }

    function Convert-FrontmatterToHtml {
        param([hashtable]$Frontmatter)
        if (-not $Frontmatter -or $Frontmatter.Count -eq 0) { return '<span class="fm-field"><span class="fm-key">meta</span><span class="fm-val">none</span></span>' }
        $items = foreach ($entry in $Frontmatter.GetEnumerator()) {
            $rawValue = if ($entry.Value -is [System.Collections.IEnumerable] -and $entry.Value -isnot [string]) { ($entry.Value | ForEach-Object { [string]$_ }) -join ', ' } else { [string]$entry.Value }
            $statusClass = if ($entry.Key -eq 'status') { " status-$($rawValue.ToLowerInvariant())" } else { '' }
            "<span class=""fm-field""><span class=""fm-key"">$(ConvertTo-HtmlSafe $entry.Key)</span><span class=""fm-val$statusClass"">$(ConvertTo-HtmlSafe $rawValue)</span></span>"
        }
        return ($items -join [Environment]::NewLine)
    }

    function Get-GraphNeighbors {
        param([string]$NoteName)
        $outgoing = Invoke-SqliteQuery -Query 'SELECT DISTINCT Target FROM Links WHERE Source = @NoteName ORDER BY Target COLLATE NOCASE;' -Parameters @{ NoteName = $NoteName }
        $incoming = Invoke-SqliteQuery -Query 'SELECT DISTINCT Source FROM Links WHERE Target = @NoteName ORDER BY Source COLLATE NOCASE;' -Parameters @{ NoteName = $NoteName }
        return [PSCustomObject]@{ Outgoing = @($outgoing | ForEach-Object { $_.Target }); Incoming = @($incoming | ForEach-Object { $_.Source }) }
    }

    function Convert-GraphNeighborsToHtml {
        param([string[]]$Incoming, [string[]]$Outgoing)
        $sections = New-Object System.Collections.Generic.List[string]
        if ($Incoming.Count -gt 0) { $sections.Add('<span class="graph-section-label">Links To This Note</span>'); $sections.Add('<ul>'); foreach ($note in $Incoming) { $sections.Add("<li>$(New-WikiAnchor -Target $note -Label $note -CssClass '')</li>") }; $sections.Add('</ul>') }
        if ($Outgoing.Count -gt 0) { $sections.Add('<span class="graph-section-label">Links From This Note</span>'); $sections.Add('<ul>'); foreach ($note in $Outgoing) { $sections.Add("<li>$(New-WikiAnchor -Target $note -Label $note -CssClass '')</li>") }; $sections.Add('</ul>') }
        if ($sections.Count -eq 0) {
            return '<div class="graph-empty">No graph neighbors recorded.</div>'
        }
        return ($sections -join [Environment]::NewLine)
    }

    function New-LlmsTxtContent {
        param(
            [System.IO.FileInfo[]]$WikiFiles,
            [System.IO.FileInfo[]]$SystemMarkdownFiles
        )

        $allMarkdownFiles = @($WikiFiles) + @($SystemMarkdownFiles)
        $portalPages = @(Get-ChildItem -Path $OutputDirectory -File -Filter '*.html')
        $generatedAt = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

        $sections = @(
            @{ Name = 'Wiki Index'; PortalNote = 'index'; Description = 'Primary navigation hub for MOCs, specs, framework clusters, literature, and raw-source pointers.' }
            @{ Name = 'System Index'; PortalNote = 'system-index'; Description = 'Operational index for scripts, maintenance surfaces, health tooling, and execution seams.' }
            @{ Name = 'Dashboard'; Url = "$PortalBaseUrl/dashboard.html"; Description = 'Live health metrics, density signals, and portal telemetry.' }
            @{ Name = 'System Log'; PortalNote = 'log'; Description = 'Durable session history of agent and human actions.' }
            @{ Name = 'Visitor Directives'; PortalNote = 'visitor-directives'; Description = 'Collaboration protocol and write constraints for visiting agents.' }
            @{ Name = 'Tool Registry'; PortalNote = 'tool-registry'; Description = 'Machine-readable inventory of PowerShell automation capabilities.' }
        )

        $clusters = @(
            @{ Name = 'Agentic Frameworks'; PortalNote = 'agentic-frameworks-moc'; Description = 'Framework comparison surface spanning ADK, OpenAI Agents SDK, Swarm, orchestration patterns, and execution models.' }
            @{ Name = 'MCP Cluster'; PortalNote = 'mcp-moc'; Description = 'Protocol, transports, primitives, security, SDKs, and implementation guidance for Model Context Protocol.' }
            @{ Name = 'Programming Languages'; PortalNote = 'programming-languages-moc'; Description = 'Architectural routing across Rust, Python, PowerShell, TypeScript, and adjacent language clusters.' }
            @{ Name = 'Multi-Agent Patterns'; PortalNote = 'multi-agent-patterns-moc'; Description = 'Pattern language for delegation, handoff, parallelism, safety, and human approval.' }
            @{ Name = 'Execution Topology'; PortalNote = 'graph-orchestration'; Description = 'When to use explicit workflow control, deterministic orchestration, and code-execution agents.' }
        )

        $lines = New-Object System.Collections.Generic.List[string]
        $lines.Add('# vulture-nest')
        $lines.Add('')
        $lines.Add('> A YANP-compliant knowledge vault and multi-agent engineering substrate with a compiled wiki, operational scripts, and a static portal.')
        $lines.Add('')
        $lines.Add("Generated: $generatedAt")
        $lines.Add("Repository: $RepoBaseUrl")
        $lines.Add("Portal: $PortalBaseUrl/index.html")
        $lines.Add("Machine-readable file: $PortalBaseUrl/llms.txt")
        $lines.Add('')
        $lines.Add('## What This Is')
        $lines.Add('')
        $lines.Add('The vault treats notes as audited technical artifacts rather than loose prose. Permanent notes live in `01_Wiki/`, system automation and operational records live in `02_System/`, source captures live in `00_Raw/`, and the static public portal is generated into `03_Web/public/`.')
        $lines.Add('')
        $lines.Add('## Current Surface')
        $lines.Add('')
        $lines.Add("- Wiki notes: $($WikiFiles.Count)")
        $lines.Add("- System markdown surfaces: $($SystemMarkdownFiles.Count)")
        $lines.Add("- Total markdown surfaces in compiled portal scope: $($allMarkdownFiles.Count)")
        $lines.Add("- Public HTML pages currently generated: $($portalPages.Count)")
        $lines.Add('')
        $lines.Add('## Start Here')
        $lines.Add('')
        foreach ($section in $sections) {
            $url = if ($section.ContainsKey('PortalNote')) { Get-PortalUrl -NoteName $section.PortalNote } else { $section.Url }
            $lines.Add("- [$($section.Name)]($url): $($section.Description)")
        }
        $lines.Add('')
        $lines.Add('## Major Clusters')
        $lines.Add('')
        foreach ($cluster in $clusters) {
            $lines.Add("- [$($cluster.Name)]($(Get-PortalUrl -NoteName $cluster.PortalNote)): $($cluster.Description)")
        }
        $lines.Add('')
        $lines.Add('## Protocol Rules For Agents')
        $lines.Add('')
        $lines.Add('- Filenames in `01_Wiki/` are lowercase kebab-case and filename stems must remain unique across the vault.')
        $lines.Add('- Internal links use wikilinks in source notes and compile to static HTML in the portal.')
        $lines.Add('- Notes in `01_Wiki/` require YAML frontmatter with at least `title`, `author`, `date`, `status`, `type`, and `aliases`.')
        $lines.Add('- Graph integrity and note compliance are enforced by PowerShell maintenance scripts rather than by convention alone.')
        $lines.Add('')
        $lines.Add('## Key Source And Repo Surfaces')
        $lines.Add('')
        $lines.Add("- [README]($(Get-RepoBlobUrl -RelativePath 'README.md')): high-level project framing and live portal links.")
        $lines.Add("- [Wiki Index Source]($(Get-RepoBlobUrl -RelativePath '01_Wiki/index.md')): source markdown for the main navigation hub.")
        $lines.Add("- [System Index Source]($(Get-RepoBlobUrl -RelativePath '02_System/system-index.md')): source markdown for operational and tooling navigation.")
        $lines.Add("- [Visitor Directives Source]($(Get-RepoBlobUrl -RelativePath '02_System/visitor-directives.md')): collaboration contract for guest agents.")
        $lines.Add("- [Portal Generator]($(Get-RepoBlobUrl -RelativePath '02_System/generate-wiki.ps1')): static site compiler for wiki and system markdown.")
        $lines.Add('')
        $lines.Add('## Retrieval Guidance')
        $lines.Add('')
        $lines.Add('- Use the portal index for broad navigation and the system index for tooling and maintenance tasks.')
        $lines.Add('- Start from root hubs (`rust`, `python`, `powershell`, `typescript`, `agent-development-kit`, `mcp-moc`) before dropping into narrow subnotes.')
        $lines.Add('- Prefer literature notes (`lit-*`) when you need source-grounded summaries, and permanent notes when you need vault-local synthesis or decision rules.')
        return ($lines -join [Environment]::NewLine) + [Environment]::NewLine
    }

    Import-SqliteAssemblies
    if (-not (Test-Path $TemplatePath)) { throw "Template not found: $TemplatePath" }
    if (-not (Test-Path $OutputDirectory)) { New-Item -ItemType Directory -Path $OutputDirectory | Out-Null }

    $template = Get-NormalizedContent -Path $TemplatePath
    $wikiFiles = @(Get-ChildItem -Path $WikiPath -File -Filter '*.md' | Sort-Object Name)
    $systemMarkdownFiles = @(Get-ChildItem -Path $PSScriptRoot -File -Filter '*.md' | Sort-Object Name)
    $compiledMarkdownFiles = @($wikiFiles) + @($systemMarkdownFiles)
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $results = New-Object System.Collections.Generic.List[object]
    $searchEntries = New-Object System.Collections.Generic.List[object]

    foreach ($file in $compiledMarkdownFiles) {
        $noteName = $file.BaseName
        $content = Get-NormalizedContent -Path $file.FullName
        $parts = Split-Frontmatter -Content $content
        $title = if ($parts.Frontmatter.Contains('title')) { [string]$parts.Frontmatter['title'] } else { $noteName }
        $searchEntries.Add((New-SearchIndexEntry -NoteName $noteName -Title $title -Frontmatter $parts.Frontmatter -Body $parts.Body))

        $outputPath = Join-Path $OutputDirectory (Get-HtmlFileName -NoteName $noteName)
        if (-not $Force -and (Test-Path $outputPath)) {
            if ($file.LastWriteTime -le (Get-Item $outputPath).LastWriteTime) { continue }
        }
        Write-Host "Compiling $noteName..." -ForegroundColor Gray
        $bodyHtml = Convert-MarkdownToHtml -Markdown $parts.Body
        $frontmatterHtml = Convert-FrontmatterToHtml -Frontmatter $parts.Frontmatter
        $neighbors = Get-GraphNeighbors -NoteName $noteName
        $graphHtml = Convert-GraphNeighborsToHtml -Incoming $neighbors.Incoming -Outgoing $neighbors.Outgoing
        $pageHtml = $template.Replace('{{TITLE}}', (ConvertTo-HtmlSafe $title)).Replace('{{CONTENT}}', $bodyHtml).Replace('{{FRONTMATTER}}', $frontmatterHtml).Replace('{{GRAPH_NEIGHBORS}}', $graphHtml)
        [System.IO.File]::WriteAllText($outputPath, $pageHtml, $utf8NoBom)
        $results.Add([PSCustomObject]@{ Note = $noteName; Title = $title; OutputPath = $outputPath; Incoming = $neighbors.Incoming.Count; Outgoing = $neighbors.Outgoing.Count })
    }

    $llmsTxtContent = New-LlmsTxtContent -WikiFiles $wikiFiles -SystemMarkdownFiles $systemMarkdownFiles
    [System.IO.File]::WriteAllText($LlmsTxtRootPath, $llmsTxtContent, $utf8NoBom)
    [System.IO.File]::WriteAllText($LlmsTxtPublicPath, $llmsTxtContent, $utf8NoBom)
    $searchIndexJson = [string](ConvertTo-Json -InputObject $searchEntries.ToArray() -Depth 6 -Compress)
    Set-Content -LiteralPath $SearchIndexPublicPath -Value $searchIndexJson -Encoding utf8

    if ($results.Count -gt 0) { Write-Host "Compiled $($results.Count) wiki pages into $OutputDirectory" -ForegroundColor Green }
    else { Write-Host "No HTML changes detected. Portal is up to date." -ForegroundColor Cyan }
    Write-Host "Refreshed llms.txt at repo root and public portal output." -ForegroundColor Green
    Write-Host "Refreshed static search index at $SearchIndexPublicPath" -ForegroundColor Green
    return $results
} catch { Write-Error $_; exit 1 }
