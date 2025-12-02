# Assessment Script for STRUDS Software Testing
# This script analyzes the output from batch testing to assess software performance and identify shortcomings

# Get the most recent test run folder
$latestRun = Get-ChildItem "Output" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($null -eq $latestRun) {
    Write-Host "No test runs found in Output directory"
    exit 1
}

Write-Host "Assessing test results from: $($latestRun.Name)"
Write-Host "----------------------------------------"

# Initialize counters
$totalFiles = 0
$successfulAnalyses = 0
$successfulDesigns = 0
$successfulRCC = 0
$successfulDrawings = 0
$failedFiles = @()

# Process each test file output
Get-ChildItem $latestRun.FullName -Directory | ForEach-Object {
    $fileFolder = $_.Name
    $folderPath = Join-Path $latestRun.FullName $fileFolder
    
    $totalFiles++
    $fileSuccess = $true
    
    Write-Host "Checking results for: $fileFolder"
    
    # Check for analysis report
    $analysisReport = Join-Path $folderPath "${fileFolder}_analysis_report.txt"
    if (Test-Path $analysisReport) {
        $successfulAnalyses++
        Write-Host "  + Analysis report: Found"
    } else {
        Write-Host "  - Analysis report: Missing"
        $fileSuccess = $false
    }
    
    # Check for design report
    $designReport = Join-Path $folderPath "${fileFolder}_design_report.txt"
    if (Test-Path $designReport) {
        $successfulDesigns++
        Write-Host "  + Design report: Found"
    } else {
        Write-Host "  - Design report: Missing"
        $fileSuccess = $false
    }
    
    # Check for RCC design
    $rccDesign = Join-Path $folderPath "${fileFolder}_rcc_design.txt"
    if (Test-Path $rccDesign) {
        $successfulRCC++
        Write-Host "  + RCC design: Found"
    } else {
        Write-Host "  - RCC design: Missing"
        $fileSuccess = $false
    }
    
    # Check for drawing
    $drawing = Join-Path $folderPath "${fileFolder}_drawing.dwg"
    if (Test-Path $drawing) {
        $successfulDrawings++
        Write-Host "  + Drawing: Found"
    } else {
        Write-Host "  - Drawing: Missing"
        $fileSuccess = $false
    }
    
    # Track failed files
    if (-not $fileSuccess) {
        $failedFiles += $fileFolder
    }
    
    Write-Host ""
}

# Generate summary report
Write-Host "=== TEST ASSESSMENT SUMMARY ==="
Write-Host "Test run: $($latestRun.Name)"
Write-Host "Total files processed: $totalFiles"
Write-Host ""
Write-Host "Successful completions:"
Write-Host "  Analysis reports: $successfulAnalyses/$totalFiles ($([math]::Round(($successfulAnalyses/$totalFiles)*100, 2))%)"
Write-Host "  Design reports: $successfulDesigns/$totalFiles ($([math]::Round(($successfulDesigns/$totalFiles)*100, 2))%)"
Write-Host "  RCC designs: $successfulRCC/$totalFiles ($([math]::Round(($successfulRCC/$totalFiles)*100, 2))%)"
Write-Host "  Drawings: $successfulDrawings/$totalFiles ($([math]::Round(($successfulDrawings/$totalFiles)*100, 2))%)"
Write-Host ""

# Identify shortcomings
Write-Host "=== SHORTCOMINGS IDENTIFIED ==="
if ($failedFiles.Count -gt 0) {
    Write-Host "Files with incomplete processing:"
    $failedFiles | ForEach-Object { Write-Host "  - $_" }
    Write-Host ""
}

# Recommendations based on results
Write-Host "=== RECOMMENDATIONS ==="
if ($successfulAnalyses -lt $totalFiles) {
    Write-Host "- Investigate analysis module failures"
}
if ($successfulDesigns -lt $totalFiles) {
    Write-Host "- Review design calculation routines"
}
if ($successfulRCC -lt $totalFiles) {
    Write-Host "- Examine RCC design implementation"
}
if ($successfulDrawings -lt $totalFiles) {
    Write-Host "- Check drawing generation component"
}

# Save assessment report
$assessmentReport = "Output\assessment_report_$($latestRun.Name).txt"
"Test Assessment Report - $($latestRun.Name)" > $assessmentReport
"Generated on: $(Get-Date)" >> $assessmentReport
"" >> $assessmentReport
"Summary:" >> $assessmentReport
"Total files processed: $totalFiles" >> $assessmentReport
"Analysis reports: $successfulAnalyses/$totalFiles" >> $assessmentReport
"Design reports: $successfulDesigns/$totalFiles" >> $assessmentReport
"RCC designs: $successfulRCC/$totalFiles" >> $assessmentReport
"Drawings: $successfulDrawings/$totalFiles" >> $assessmentReport
"" >> $assessmentReport
"Shortcomings:" >> $assessmentReport
if ($failedFiles.Count -gt 0) {
    "Files with incomplete processing:" >> $assessmentReport
    $failedFiles | ForEach-Object { "  - $_" >> $assessmentReport }
} else {
    "No significant shortcomings identified" >> $assessmentReport
}

Write-Host "Assessment report saved to: $assessmentReport"