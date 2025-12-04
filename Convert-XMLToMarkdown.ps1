<#
.SYNOPSIS
    Convert JaCoCo XML files from Pester tests to Markdown for display within GitHub.
.DESCRIPTION
    This GitHub Action takes a coverage.xml file in the JaCoCo schema and converts it for display in Markdown.

    These Markdown tables are very simple, summarizing the JaCoCo XML in three levels:
     - Summary, coverage of all lines, instructions, methods, and classes
     - Coverage by Class (File), listing each class and its coverage by lines, instructions, methods, and classes
     - Coverage by Method, listing each method and its class, name, line number, and coverage by lines, instructions, and methods.

    At this time, this Action does not support conversion of other Code Coverage report types, though if there is enough interest this may be expanded.

.PARAMETER Path
    Specifies the path for the coverage.xml file to convert to Markdown. Required. Defaults to '.\_results\coverage.xml'.

.PARAMETER Title
    Specifies the title of the Markdown Report. For example, providing the repository name. Defaults to 'Code Coverage (JaCoCo)'

.PARAMETER Output
    Specifies the location of the Markdown output file. Required. Defaults to '.\_results\coverage.md'

.PARAMETER MaxHeadingLevel
    The topmost heading that should be included in the report. e.g. 1 for H1 (#), 2 for H2 (##), and so on. All other headings will be placed relative to the top level. Defaults to 3 (###)

.PARAMETER MinLinePercent
    Specifies the minimum coverage threshold for lines. If the actual coverage is below this threshold, the action will fail. Defaults to 0.0

.PARAMETER MinInstructionPercent
    Specifies the minimum coverage threshold for instructions. If the actual coverage is below this threshold, the action will fail.

.PARAMETER MinMethodPercent
    Specifies the minimum coverage threshold for methods. If the actual coverage is below this threshold, the action will fail.

.PARAMETER MinClassPercent
    Specifies the minimum coverage threshold for classes. If the actual coverage is below this threshold, the action will fail.

.EXAMPLE
    .\Convert-XMLToMarkdown.ps1 -Path .\tests\coverage_test2.xml

.EXAMPLE
    .\Convert-XMLToMarkdown.ps1 -Path .\tests\coverage_test2.xml -Output .\_reports\coverage_test2.md

.EXAMPLE
    .\Convert-XMLToMarkdown.ps1 -Path .\tests\coverage_test2.xml -Output .\_reports\coverage_test2.md -Title "Test Code Coverage Report 2 (Passing) (JaCoCo)"

.EXAMPLE
    .\Convert-XMLToMarkdown.ps1 -Path .\tests\coverage_test2.xml -Output .\_reports\coverage_test2.md -Title "Test Code Coverage Report 2 (Passing) (JaCoCo)" -MaxHeadingLevel 1
.EXAMPLE
    .\Convert-XMLToMarkdown.ps1 -Path .\tests\coverage_test2.xml -Output .\_reports\coverage_test2.md -Title "Test Code Coverage Report 2 (Passing) (JaCoCo)" -MaxHeadingLevel 1 -MinLinePercent 80.0 -MinInstructionPercent 75.0 -MinMethodPercent 70.0 -MinClassPercent 100.0
#>
param(
    # Formatting and I/O
    [Parameter(Mandatory=$true)] [string] $Path,  # e.g., .\coverage.xml
    [Parameter()] [string] $Output = ".\_reports\coverage.md",
    [Parameter()] [string] $Title = 'Code Coverage (JaCoCo)',
    [Parameter()] [Int16] $MaxHeadingLevel = 3,
    # Failure Thresholds (percentages), minimum code coverage definitions
    [Parameter()] [double] $MinLinePercent = 0.0, # e.g., 80.0
    [Parameter()] [double] $MinInstructionPercent = 0.0, # e.g., 75.0
    [Parameter()] [double] $MinMethodPercent = 0.0, # e.g., 70.0
    [Parameter()] [double] $MinClassPercent = 0.0 # e.g., 100.0
)

function Get-CounterObject {
    <#
    .SYNOPSIS
        Converts a parsed XML node object into a PSCustomObject for transfer to Markdown.

    .DESCRIPTION
        The XML node object must have a regular format.

        This function requires the node to have a `counter` list of objects. Each object must have the attributes `missed`, `covered`, and `type`.

        Returns a PSCustomObject that is ready for conversion to Markdown.

    .PARAMETER Node
        A parsed XML node object. Required.

    .OUTPUTS
        [PSCustomObject]@{
            Type = [str]
            Missed = [int]
            Covered = [int]
            Total = [int]
            Percent = [double]
        }

    .EXAMPLE
        Get-CounterObject $doc.report

    .EXAMPLE
        Get-CounterObject -Node $doc.report
    #>
    param(
        [Parameter(Mandatory=$true)] [System.Object[]] $Node
    )

    $result = @{}
    foreach ($counter in $Node.counter) {
        $missed = [int]$counter.missed
        $covered = [int]$counter.covered
        $total = $missed + $covered
        $pct = if ($total -gt 0) { [math]::Round(100.0 * $covered / $total, 1) } else { 0.0 }
        $result[$counter.type] = [pscustomobject]@{
            Type = $counter.type
            Missed = $missed
            Covered = $covered
            Total = $total
            Percent = $pct
        }
    }
    
    return $result
}

function Format-CounterRow {
    <#
    .SYNOPSIS
        Creates a formatted Markdown table row from a parsed PowerShell Object.
    
    .DESCRIPTION
        This function is really just a wrapper for the Summary table section. The Class and Method coverage tables have their own structures and population procedures.

        The passed object MUST have the following structure:

        $object = {
            INSTRUCTION = @{
                Covered = [int]
                Total = [int]
                Percent = [double]
            }
            LINE = @{
                Covered = [int]
                Total = [int]
                Percent = [double]
            }
            METHOD = @{
                Covered = [int]
                Total = [int]
                Percent = [double]
            }
            CLASS = @{
                Covered = [int]
                Total = [int]
                Percent = [double]
            }
        }

        This function does not require a return statement as it passes the resulting value back to the success output stream (pipeline).

    .PARAMETER counter
        The PowerShell Object that represents the overall counter object for the code coverage report. See structure above.

    .PARAMETER label
        The label to give for this table row, under the `Scope` heading.

    .EXAMPLE
        Format-CounterRow -counter $overall -label "Total"
    
    .EXAMPLE
        $md += (Format-CounterRow -counter $overall -label "Total")
    #>
    param(
        [Parameter()] [System.Object] $counter,
        [Parameter()] [string] $label
    )
    $instruction = $counter['INSTRUCTION']
    $line = $counter['LINE']
    $method = $counter['METHOD']
    $class = $counter['CLASS']
    
@"
| $label | $($line.Covered)/$($line.Total) ($($line.Percent)%) | $($instruction.Covered)/$($instruction.Total) ($($instruction.Percent)%) | $($method.Covered)/$($method.Total) ($($method.Percent)%) | $($class.Covered)/$($class.Total) ($($class.Percent)%) |
"@
}

function Format-EscapeMarkdown {
    <#
    .SYNOPSIS
        Formats a string for use in Markdown by escaping dangerous sequences and adding HTML character entities as replacements for semantic characters that need to be rendered as text.

    .PARAMETER mdString
        The Markdown string to format.

    .OUTPUTS
        [string]

    .EXAMPLE
        Format-EscapeMarkdown -mdString $markdownRow
    #>
    param(
        [Parameter(Mandatory=$true)] [string] $mdString
    )

    if (-not $mdString) {
        # should never trigger, but just in case
        return ""
    }

    # replacing common elements and adding HTML character entities where needed
    $mdString = $mdString -replace '\|','\|'
    $mdString = $mdString -replace '<','&lt;' -replace '>','&gt;'

    return $mdString
}

# Get and Parse XML as PowerShell object
[xml]$doc = Get-Content -Path $Path -Encoding UTF8
$reportName = $doc.report.name

# Get overall counters
$overall = Get-CounterObject -Node $doc.report

# Parse package for class and method counters
$rowsByClass = New-Object System.Collections.Generic.List[string]
$methodRows  = New-Object System.Collections.Generic.List[string]

foreach ($pkg in $doc.report.package) {
    foreach ($cls in $pkg.class) {
        $className = $cls.name
        $classCounters = Get-CounterObject -Node $cls
        $rowsByClass.Add( (Format-CounterRow -counter $classCounters -label (Format-EscapeMarkdown $className)) )

        foreach ($method in $cls.method) {
            $mCounters = Get-CounterObject -Node $method
            $mName = Format-EscapeMarkdown $method.name
            $mLine = [int]$method.line
            $lineC = $mCounters['LINE']
            $instructionC = $mCounters['INSTRUCTION']
            $methodC = $mCounters['METHOD']

            $methodRows.Add(@"
| $className | $mName | $mLine | $($lineC.Covered)/$($lineC.Total) ($($lineC.Percent)%) | $($instructionC.Covered)/$($instructionC.Total) ($($instructionC.Percent)%) | $($methodC.Covered)/$($methodC.Total) ($($methodC.Percent)%) |
"@)
        }
    }
}

# --- Build Markdown ---
$md = @()
$md += "$("#" * $MaxHeadingLevel) $Title"
$md += ""
$md += "**Report:** $reportName"
$md += ""

# Summary table
$md += "$("#" * ($MaxHeadingLevel + 1)) Summary"
$md += "| Scope | Lines | Instructions | Methods | Classes |"
$md += "| :--- | ---: | ---: | ---: | ---: |"
$md += (Format-CounterRow -counter $overall -label "Total")

# Per-class table
$md += ""
$md += "$("#" * ($MaxHeadingLevel + 1)) Coverage by Class"
$md += "| Class | Lines | Instructions | Methods | Classes |"
$md += "| :--- | ---: | ---: | ---: | ---: |"
$md += $rowsByClass

# Per-method table
$md += ""
$md += "$("#" * ($MaxHeadingLevel + 1)) Coverage by Method"
$md += "| Class | Method | Line | Lines | Instructions | Methods |"
$md += "| :--- | :--- | ---: | ---: | ---: | ---: |"
$md += $methodRows

# --- Threshold evaluation ---
$linePct = $overall['LINE'].Percent
$instructionPct = $overall['INSTRUCTION'].Percent
$methodPct = $overall['METHOD'].Percent
$classPct = $overall['CLASS'].Percent

$thresholdFailures = @()

if ($MinLinePercent -gt 0 -and $linePct -lt $MinLinePercent) {
    $thresholdFailures += "Line coverage $($linePct)% < min $($MinLinePercent)%"
}
if ($MinInstructionPercent -gt 0 -and $instructionPct -lt $MinInstructionPercent) {
    $thresholdFailures += "Instruction coverage $($instructionPct)% < min $($MinInstructionPercent)%"
}
if ($MinMethodPercent -gt 0 -and $methodPct -lt $MinMethodPercent) {
    $thresholdFailures += "Method coverage $($methodPct)% < min $($MinMethodPercent)%"
}
if ($MinClassPercent -gt 0 -and $classPct -lt $MinClassPercent) {
    $thresholdFailures += "Class coverage $($classPct)% < min $($MinClassPercent)%"
}

if ($thresholdFailures.Count -gt 0) {
    $md += ""
    $md += "$("#" * ($MaxHeadingLevel + 1)) ❌ Coverage Thresholds Failed"
    foreach ($msg in $thresholdFailures) { $md += "- $msg" }
    $md += ""
    $md += "> Build failed due to coverage thresholds."

    # Ensure the markdown goes out even on failure
    $mdTextOnFail = ($md -join "`n")
    New-Item -ItemType Directory -Path (Split-Path -Path $Output) -Force | Out-Null
    $mdTextOnFail | Set-Content -Path $Output -Encoding UTF8

    Write-Error ("Coverage thresholds not met: " + ($thresholdFailures -join "; "))
    exit 1 # the step fails
} else {
    $md += ""
    $md += "$("#" * ($MaxHeadingLevel + 1)) ✅ Coverage Thresholds Passed!"
    $md += "> Build is passing, all coverage thresholds were met!"
    Write-Output "Build is passing, all coverage thresholds were met!"
}

# --- Normal (success) outputs ---
$mdText = ($md -join "`n")
New-Item -ItemType Directory -Path (Split-Path -Path $Output) -Force | Out-Null
$mdText | Set-Content -Path $Output -Encoding UTF8

Write-Host "Markdown coverage written to: $Output"
# SIG # Begin signature block
# MIIIygYJKoZIhvcNAQcCoIIIuzCCCLcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDTQ/LIIsVV/HSS
# VlMwYSOBX75Vn0fZ8B4EPDLZSSzNf6CCBhYwggYSMIIE+qADAgECAhNTAAAIMGYI
# 4CzI2+4ZAAIAAAgwMA0GCSqGSIb3DQEBCwUAMEExFTATBgoJkiaJk/IsZAEZFgVs
# b2NhbDETMBEGCgmSJomT8ixkARkWA3NjYjETMBEGA1UEAxMKc2NiLURDMi1DQTAe
# Fw0yNTA5MTkxMjUzMDNaFw0yNjA5MTkxMjUzMDNaMHYxFTATBgoJkiaJk/IsZAEZ
# FgVsb2NhbDETMBEGCgmSJomT8ixkARkWA3NjYjETMBEGA1UECxMKU3R5bGVjcmFm
# dDEOMAwGA1UECxMFVXNlcnMxCzAJBgNVBAsTAklUMRYwFAYDVQQDEw1EYWxsYXMg
# VGF5bG9yMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1o1y3CvlC3fs
# xLcTuR2d7QZpVqqnd7NMljTVCkq6tTYOyMrBq233OaNpMToPXON4vB5tVa4MjRx8
# 8vIXoIJzBYZRcP5mcgEuaUDoVM/L0mzoVEAW22GJ1zS+DQ9P1PlJU5IMbUg6uBGj
# iwoRmcpEIPxMtyQyeyShlrExrqUlsOpQUXLhYrOT6RZsPjPADLXcpZrK6V0YYqK4
# bwAsVXypFoaeI5pyp0q+7RsgkeJQFc0KOR+TFhxIBEkQ78CZLWa/GFJgrYEvkAUL
# vpLCstPgen/pzyC4pdk8oSF2HchspZXj7ah6ccm0ovdokAO36vMfDc2F4XZ0IN1S
# dd/znOPZFQIDAQABo4ICzDCCAsgwPgYJKwYBBAGCNxUHBDEwLwYnKwYBBAGCNxUI
# g42bY4W6tw+D9Zk2hfqRS4bw4QiBOYf6sB6DpqNgAgFmAgEAMBMGA1UdJQQMMAoG
# CCsGAQUFBwMDMA4GA1UdDwEB/wQEAwIHgDAbBgkrBgEEAYI3FQoEDjAMMAoGCCsG
# AQUFBwMDMB0GA1UdDgQWBBQxuHYCZPy85IZOgPEYo4HydX0sczAfBgNVHSMEGDAW
# gBR7lUjYG+psfTElRbr6wjO8lri3NzCBwgYDVR0fBIG6MIG3MIG0oIGxoIGuhoGr
# bGRhcDovLy9DTj1zY2ItREMyLUNBLENOPURDNixDTj1DRFAsQ049UHVibGljJTIw
# S2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1z
# Y2IsREM9bG9jYWw/Y2VydGlmaWNhdGVSZXZvY2F0aW9uTGlzdD9iYXNlP29iamVj
# dENsYXNzPWNSTERpc3RyaWJ1dGlvblBvaW50MIG6BggrBgEFBQcBAQSBrTCBqjCB
# pwYIKwYBBQUHMAKGgZpsZGFwOi8vL0NOPXNjYi1EQzItQ0EsQ049QUlBLENOPVB1
# YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRp
# b24sREM9c2NiLERDPWxvY2FsP2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFz
# cz1jZXJ0aWZpY2F0aW9uQXV0aG9yaXR5MDEGA1UdEQQqMCigJgYKKwYBBAGCNxQC
# A6AYDBZkdGF5bG9yQHN0eWxlY3JhZnQuY29tME8GCSsGAQQBgjcZAgRCMECgPgYK
# KwYBBAGCNxkCAaAwBC5TLTEtNS0yMS0xMTIyNzUyODYyLTM5MTY0MDc2MjItMTM4
# MTUxODYxOC00MzkzMA0GCSqGSIb3DQEBCwUAA4IBAQAzFmTiPMjoKgWKEBzfOnYR
# oJeXcWpItVqoPqwRSiKi8GGxJtHon6mcSTS8n7Rss35N+IBHt+1LQiVQ7mm5XybG
# 4IGPs+u3sWM3ZIqH/ky6HJ9LM6rE0J0FmgYnw4qYC/KkmEY+j+tm2ZLRNBEiC5N9
# jbWtxEkV8OPx7yxKyJHCK4D3NmfnOyu5IACAwoa2suDDHY8blKm0GQNEoF8sq2L6
# pL79eo2gh6KXwbM3mzipEBTjRR7ho++V8hstdgtZ+Q2YQQwYyOdnQlIUwUIULsJp
# UXMquzW1AibSiH+WKBVY4FI8DzyQwi7awrhZmP1V7ye54Aiz4jD2XifRQz4q6pgv
# MYICCjCCAgYCAQEwWDBBMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxEzARBgoJkiaJ
# k/IsZAEZFgNzY2IxEzARBgNVBAMTCnNjYi1EQzItQ0ECE1MAAAgwZgjgLMjb7hkA
# AgAACDAwDQYJYIZIAWUDBAIBBQCggYQwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKA
# ADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYK
# KwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgI4bzBDFIzpGeAQHMA8pfuw9bKYFW
# Z+OBvKh33Cxm2FkwDQYJKoZIhvcNAQEBBQAEggEAffaSXm6vOKmNZSfHT3YJaG29
# ZX+gsRbmlQPtWZ5qphzTLVN0+hwuO6EPdJleaNmxhRqP9/+FJo9eOQuisagdYKxK
# 56F6+xa2qfQ7EWie0DY9Zv/0MICxy3MtGfKtmXRG2jb5JMpG1UBXftMFc+VChwVY
# 0iFqtPTbmn1yVBMsBQ/3wZaLIkXuwIitZvumr1Vs5y20hkgeIcJDVRhPL1HYnMhZ
# ZaQm3DvbWZJ6RAC8YZcjQoqFoznsNMtA/RN/eF6ARakELGVzXNFEa+JKt+ZUYCpu
# PxD9GExwbyxRcogvUmOQOC2wZ8JOVsYGZq9jNeWDPlJgKDLrUd9hxMTGvEjYWA==
# SIG # End signature block
