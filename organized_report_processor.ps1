# Organized Report Processor for STRUDS Software
# This script handles the complete workflow of downloading, organizing, and combining reports
# in timestamped folders as specified

# Function to get current timestamp for folder naming
function Get-Timestamp {
    return Get-Date -Format "yyyyMMdd_HHmmss"
}

# Function to create directory if it doesn't exist
function New-DirectoryIfNotExists {
    param([string]$Path)
    if (!(Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

# Get current timestamp
$timestamp = Get-Timestamp

# Step 1: Create RAW_REPORT folder with timestamped subfolder
$rawReportBase = "RAW_REPORT"
$rawReportFolder = "$rawReportBase\$timestamp"
New-DirectoryIfNotExists $rawReportBase
New-DirectoryIfNotExists $rawReportFolder

Write-Host "========================================" -ForegroundColor Green
Write-Host "ORGANIZED REPORT PROCESSOR" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Raw reports will be saved to: $rawReportFolder" -ForegroundColor Cyan
Write-Host ""

# Get the most recent test run folder
$latestRun = Get-ChildItem "Output" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($null -eq $latestRun) {
    Write-Host "No test runs found in Output directory" -ForegroundColor Red
    exit 1
}

# Step 2: Download/copy all reports to RAW_REPORT timestamped subfolder
Write-Host "Step 1: Copying all reports to RAW_REPORT\$timestamp..." -ForegroundColor Yellow

# Copy all reports from the latest test run to RAW_REPORT folder
Copy-Item -Path "$($latestRun.FullName)\*" -Destination $rawReportFolder -Recurse -Force
Write-Host "SUCCESS: All reports copied to RAW_REPORT\$timestamp" -ForegroundColor Green

# Count files copied
$rawFileCount = (Get-ChildItem -Recurse $rawReportFolder -File).Count
Write-Host "  Total files copied: $rawFileCount" -ForegroundColor White
Write-Host ""

# Step 3: Process and combine reports into FINAL_OUTPUT with timestamped subfolder
$finalOutputBase = "FINAL_OUTPUT"
$finalOutputFolder = "$finalOutputBase\$timestamp"
New-DirectoryIfNotExists $finalOutputBase
New-DirectoryIfNotExists $finalOutputFolder

Write-Host "Step 2: Processing and combining reports..." -ForegroundColor Yellow

# Run the improved HTML combiner to preserve original formatting
if (Test-Path "improved_html_combiner.ps1") {
    Write-Host "Running improved HTML combiner..." -ForegroundColor Yellow
    powershell -ExecutionPolicy Bypass -File ".\improved_html_combiner.ps1"
    
    # Copy the improved combined reports to FINAL_OUTPUT
    $improvedReports = "Improved_Combined_Reports"
    if (Test-Path $improvedReports) {
        Copy-Item -Path "$improvedReports\*" -Destination $finalOutputFolder -Recurse -Force
        Write-Host "SUCCESS: Improved combined reports copied to FINAL_OUTPUT\$timestamp" -ForegroundColor Green
    }
} else {
    # Fallback to the advanced combined reports if improved version doesn't exist
    $advancedReports = "Advanced_Combined_Reports"
    if (Test-Path $advancedReports) {
        # Copy the entire advanced reports directory to FINAL_OUTPUT
        Copy-Item -Path "$advancedReports\*" -Destination $finalOutputFolder -Recurse -Force
        Write-Host "SUCCESS: Advanced combined reports copied to FINAL_OUTPUT\$timestamp" -ForegroundColor Green
    } else {
        Write-Host "WARNING: Advanced combined reports not found" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Step 3: Creating summary file..." -ForegroundColor Yellow

$summaryContent = "STRUDS Report Processing Summary`n"
$summaryContent += "==============================`n"
$summaryContent += "Processing completed on: $(Get-Date)`n"
$summaryContent += "Timestamp: $timestamp`n"
$summaryContent += "`nDirectories created:`n"
$summaryContent += "- RAW_REPORT\$timestamp`n"
$summaryContent += "- FINAL_OUTPUT\$timestamp`n"
$summaryContent += "`nFiles processed:`n"
$summaryContent += "- Raw reports: $rawFileCount files`n"
$summaryContent += "`nCombined reports location:`n"
$summaryContent += "- Main combined report: FINAL_OUTPUT\$timestamp\index.html`n"

$summaryContent > "$finalOutputFolder\PROCESSING_SUMMARY.txt"
Write-Host "SUCCESS: Summary file created: FINAL_OUTPUT\$timestamp\PROCESSING_SUMMARY.txt" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "PROCESSING COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Raw reports saved to:" -ForegroundColor Yellow
Write-Host "  RAW_REPORT\$timestamp" -ForegroundColor White
Write-Host ""
Write-Host "Combined reports saved to:" -ForegroundColor Yellow
Write-Host "  FINAL_OUTPUT\$timestamp" -ForegroundColor White
Write-Host ""
Write-Host "To view results:" -ForegroundColor Yellow
Write-Host "  1. Open FINAL_OUTPUT\$timestamp\index.html for the main combined report" -ForegroundColor White
Write-Host "  2. Check RAW_REPORT\$timestamp for original reports" -ForegroundColor White
Write-Host "  3. See PROCESSING_SUMMARY.txt for detailed information" -ForegroundColor White
Write-Host ""
Write-Host "ORGANIZED REPORT PROCESSING COMPLETED!" -ForegroundColor Green