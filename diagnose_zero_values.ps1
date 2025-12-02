# Diagnostic Script for Zero Value Detection in STRUDS Reports
# This script scans all reports to identify where "ALL AMOUNT IS ZERO" errors occur

# Function to scan HTML files for zero values
function Scan-HtmlForZeros {
    param(
        [string]$FilePath
    )
    
    $content = Get-Content $FilePath -Raw
    $zerosFound = @()
    
    # Look for patterns that might indicate zero values where they shouldn't be
    if ($content -match "0(\.0+)?\s*(kN|kNm|m|mm|cm|%|kg)") {
        $zerosFound += "Potential zero values found with units"
    }
    
    # Look for tables with all zero values
    if ($content -match "<td>\s*0(\.0+)?\s*</td>" -and ($content -match "<td>\s*[1-9]" | Measure-Object).Count -eq 0) {
        $zerosFound += "Table with all zero values detected"
    }
    
    return $zerosFound
}

# Function to scan TXT files for zero values
function Scan-TxtForZeros {
    param(
        [string]$FilePath
    )
    
    $content = Get-Content $FilePath
    $zerosFound = @()
    
    # Look for lines with zero values in engineering contexts
    foreach ($line in $content) {
        if ($line -match ":\s*0(\.0+)?\s*(kN|kNm|m|mm|cm|%|kg)" -or 
            $line -match "Load:\s*0(\.0+)?" -or 
            $line -match "Axial\s*Load:\s*0(\.0+)?" -or
            $line -match "Moment:\s*0(\.0+)?" -or
            $line -match "Size:\s*0(\.0+)?\s*x\s*0(\.0+)?") {
            $zerosFound += "Zero value found in line: $line"
        }
    }
    
    return $zerosFound
}

Write-Host "========================================" -ForegroundColor Green
Write-Host "STRUDS ZERO VALUE DIAGNOSTIC TOOL" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Get the most recent RAW_REPORT folder
$latestRawReport = Get-ChildItem "RAW_REPORT" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($null -eq $latestRawReport) {
    Write-Host "No RAW_REPORT directory found" -ForegroundColor Red
    exit 1
}

Write-Host "Scanning reports in: $($latestRawReport.Name)" -ForegroundColor Cyan
Write-Host ""

# Track issues found
$issuesFound = 0
$filesChecked = 0

# Scan all subdirectories
$subDirs = Get-ChildItem $latestRawReport.FullName -Directory

foreach ($dir in $subDirs) {
    Write-Host "Checking directory: $($dir.Name)" -ForegroundColor Yellow
    
    # Check HTML files
    $htmlFiles = Get-ChildItem $dir.FullName -Filter "*.html" -ErrorAction SilentlyContinue
    foreach ($htmlFile in $htmlFiles) {
        $filesChecked++
        $zeros = Scan-HtmlForZeros $htmlFile.FullName
        if ($zeros.Count -gt 0) {
            Write-Host "  Issues found in: $($htmlFile.Name)" -ForegroundColor Red
            foreach ($zero in $zeros) {
                Write-Host "    - $zero" -ForegroundColor Red
            }
            $issuesFound++
        }
    }
    
    # Check TXT files
    $txtFiles = Get-ChildItem $dir.FullName -Filter "*.txt" -ErrorAction SilentlyContinue
    foreach ($txtFile in $txtFiles) {
        $filesChecked++
        $zeros = Scan-TxtForZeros $txtFile.FullName
        if ($zeros.Count -gt 0) {
            Write-Host "  Issues found in: $($txtFile.Name)" -ForegroundColor Red
            foreach ($zero in $zeros) {
                Write-Host "    - $zero" -ForegroundColor Red
            }
            $issuesFound++
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "DIAGNOSTIC SCAN COMPLETE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Files checked: $filesChecked" -ForegroundColor White
if ($issuesFound -gt 0) {
    Write-Host "Issues found: $issuesFound" -ForegroundColor Red
} else {
    Write-Host "Issues found: $issuesFound" -ForegroundColor Green
}
Write-Host ""

if ($issuesFound -eq 0) {
    Write-Host "No zero value issues detected in reports." -ForegroundColor Green
    Write-Host "The 'FOR ALL AMOUNT IS ZERO' error may be occurring in the STRUDS software itself" -ForegroundColor Yellow
    Write-Host "rather than in the generated reports." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Possible causes:" -ForegroundColor Cyan
    Write-Host "1. Input data files may have all zero values" -ForegroundColor Cyan
    Write-Host "2. STRUDS calculation engine may have an initialization error" -ForegroundColor Cyan
    Write-Host "3. Material properties or load definitions may be set to zero" -ForegroundColor Cyan
    Write-Host "4. Geometry definitions in input files may be invalid" -ForegroundColor Cyan
} else {
    Write-Host "Zero value issues detected. Please review the affected files." -ForegroundColor Yellow
}