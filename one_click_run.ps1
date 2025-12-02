# One-Click STRUDS Testing and Reporting System
# This script runs the complete workflow in a single execution

Write-Host "========================================" -ForegroundColor Green
Write-Host "STRUDS ONE-CLICK TESTING AND REPORTING" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Record start time
$startTime = Get-Date
Write-Host "Starting process at: $startTime" -ForegroundColor Cyan
Write-Host ""

# Step 1: Run batch processing
Write-Host "Step 1: Running batch processing..." -ForegroundColor Yellow
& ".\batch_test.ps1"
Write-Host "✓ Batch processing completed" -ForegroundColor Green

Write-Host ""

# Step 2: Run assessment
Write-Host "Step 2: Running assessment..." -ForegroundColor Yellow
& ".\assess_tests.ps1"
Write-Host "✓ Assessment completed" -ForegroundColor Green

Write-Host ""

# Step 3: Generate comprehensive reports
Write-Host "Step 3: Generating comprehensive reports..." -ForegroundColor Yellow
& ".\generate_comprehensive_report.ps1"
Write-Host "✓ Comprehensive reports generated" -ForegroundColor Green

Write-Host ""

# Step 4: Generate illustrated combined report
Write-Host "Step 4: Generating illustrated combined report..." -ForegroundColor Yellow
& ".\combine_illustrated_report.ps1"
Write-Host "✓ Illustrated combined report generated" -ForegroundColor Green

Write-Host ""

# Step 5: Download all reports
Write-Host "Step 5: Downloading all reports..." -ForegroundColor Yellow
& ".\download_all_reports.ps1"
Write-Host "✓ All reports downloaded" -ForegroundColor Green

Write-Host ""

# Record end time and calculate duration
$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "========================================" -ForegroundColor Green
Write-Host "PROCESS COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Start time: $startTime" -ForegroundColor Cyan
Write-Host "End time: $endTime" -ForegroundColor Cyan
Write-Host "Total duration: $($duration.Minutes) minutes and $($duration.Seconds) seconds" -ForegroundColor Cyan
Write-Host ""

# Summary of what was created
Write-Host "Generated outputs:" -ForegroundColor Yellow
Write-Host "  ✓ Batch processing results in timestamped Output folder" -ForegroundColor Green
Write-Host "  ✓ Assessment reports" -ForegroundColor Green
Write-Host "  ✓ Comprehensive reports in timestamped Reports folder" -ForegroundColor Green
Write-Host "  ✓ Illustrated combined report in Combined_Illustrated_Report folder" -ForegroundColor Green
Write-Host "  ✓ All reports collected in Downloaded_Reports folder" -ForegroundColor Green
Write-Host ""

Write-Host "To view results:" -ForegroundColor Yellow
Write-Host "  1. Open Combined_Illustrated_Report\index.html for the illustrated report" -ForegroundColor White
Write-Host "  2. Check Downloaded_Reports for all collected reports" -ForegroundColor White
Write-Host "  3. See Reports folder for timestamped comprehensive reports" -ForegroundColor White
Write-Host "  4. See Output folder for individual file results" -ForegroundColor White
Write-Host ""

Write-Host "ONE-CLICK PROCESS COMPLETED!" -ForegroundColor Green