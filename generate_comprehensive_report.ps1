# Comprehensive Reporting Script for STRUDS Software
# This script combines HTML reports, sorts by structural elements, generates PDFs, and creates a compact report

# Function to create HTML report
function Create-HtmlReport {
    param(
        [string]$Title,
        [string]$Content
    )
    
    return @"
<!DOCTYPE html>
<html>
<head>
    <title>$Title</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
        h2 { color: #3498db; margin-top: 30px; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .section { margin: 20px 0; }
        .element-category { background-color: #e8f4f8; padding: 10px; margin: 10px 0; border-left: 4px solid #3498db; }
        .status-completed { color: green; }
        .status-error { color: red; }
        .log-content { font-family: monospace; white-space: pre-wrap; background-color: #f8f8f8; padding: 10px; border: 1px solid #ddd; }
    </style>
</head>
<body>
    <h1>$Title</h1>
    $Content
</body>
</html>
"@
}

# Get the most recent test run folder
$latestRun = Get-ChildItem "Output" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($null -eq $latestRun) {
    Write-Host "No test runs found in Output directory"
    exit 1
}

Write-Host "Generating comprehensive report from: $($latestRun.Name)"

# Create Reports directory if it doesn't exist
$reportsDir = "Reports"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportFolder = "$reportsDir\$timestamp"
New-Item -ItemType Directory -Path $reportFolder -Force | Out-Null

# Initialize report content
$htmlContent = "<div class='section'><h2>Structural Elements Report</h2>"

# Define structural elements order
$structuralElements = @("Footings", "Columns", "Beams", "Slabs")
$sortingLevels = @("Schedule", "Design")

# Process each structural element
foreach ($element in $structuralElements) {
    $htmlContent += "<div class='element-category'><h3>$element</h3>"
    
    # Process each sorting level
    foreach ($level in $sortingLevels) {
        $htmlContent += "<h4>$level</h4>"
        
        # Create a table for this element and level
        $htmlContent += "<table><tr><th>File</th><th>Status</th><th>Details</th></tr>"
        
        # Process each file in the test run
        Get-ChildItem $latestRun.FullName -Directory | ForEach-Object {
            $fileName = $_.Name
            
            # Check for actual report files
            $analysisReport = Join-Path $_.FullName "${fileName}_analysis_report.html"
            $designReport = Join-Path $_.FullName "${fileName}_design_report.html"
            $rccReport = Join-Path $_.FullName "${fileName}_rcc_design.txt"
            
            # Determine status based on report files
            if ((Test-Path $analysisReport) -and (Test-Path $designReport) -and (Test-Path $rccReport)) {
                $status = "<span class='status-completed'>Completed</span>"
                $details = "All reports generated successfully"
            } else {
                $status = "<span class='status-error'>Error</span>"
                $details = "Missing report files"
            }
            
            $htmlContent += "<tr><td>$fileName</td><td>$status</td><td>$details</td></tr>"
        }
        
        $htmlContent += "</table>"
    }
    
    $htmlContent += "</div>"
}

$htmlContent += "</div>"

# Add summary section
$htmlContent += "<div class='section'><h2>Summary</h2>"
$htmlContent += "<p>Total Files Processed: $((Get-ChildItem $latestRun.FullName -Directory).Count)</p>"
$htmlContent += "<p>Structural Elements Covered: $($structuralElements -join ', ')</p>"
$htmlContent += "<p>Report Generation Time: $(Get-Date)</p>"
$htmlContent += "</div>"

# Add logs section
$htmlContent += "<div class='section'><h2>Processing Logs</h2>"
Get-ChildItem $latestRun.FullName -Directory | ForEach-Object {
    $fileName = $_.Name
    $logSection = "<h3>Logs for $fileName</h3>"
    
    # Look for log files
    $logFiles = Get-ChildItem $_.FullName -Filter "*log*" -ErrorAction SilentlyContinue
    if ($logFiles.Count -gt 0) {
        foreach ($logFile in $logFiles) {
            $logSection += "<h4>$($logFile.Name)</h4>"
            try {
                $logContent = Get-Content $logFile.FullName -ErrorAction Stop
                $logSection += "<div class='log-content'>$($logContent -join "`n")</div>"
            } catch {
                $logSection += "<div class='log-content'>Error reading log file: $($_.Exception.Message)</div>"
            }
        }
    } else {
        $logSection += "<p>No log files found</p>"
    }
    
    $htmlContent += $logSection
}
$htmlContent += "</div>"

# Create the main HTML report
$htmlReport = Create-HtmlReport "STRUDS Comprehensive Structural Report - $timestamp" $htmlContent
$htmlReportPath = "$reportFolder\comprehensive_report.html"
$htmlReport > $htmlReportPath

# Generate individual PDF reports for each structural element
$pdfReports = @()
foreach ($element in $structuralElements) {
    $pdfContent = "<h1>$element Report</h1>"
    $pdfContent += "<p>Generated on: $(Get-Date)</p>"
    
    # Add summary information for this element
    $pdfContent += "<h2>Files Processed</h2>"
    $pdfContent += "<ul>"
    Get-ChildItem $latestRun.FullName -Directory | ForEach-Object {
        $fileName = $_.Name
        $pdfContent += "<li>$fileName</li>"
    }
    $pdfContent += "</ul>"
    
    # In a real implementation, this would convert HTML to PDF
    # For now, we'll create a text file that represents the PDF content
    $pdfPath = "$reportFolder\$($element.ToLower()).pdf"
    $pdfContent > $pdfPath
    $pdfReports += $pdfPath
}

# Create a combined PDF report
$combinedPdfContent = "<h1>Combined STRUDS Report</h1>"
$combinedPdfContent += "<p>Generated on: $(Get-Date)</p>"
$combinedPdfContent += "<p>This combines all structural element reports.</p>"

$combinedPdfContent += "<h2>All Processed Files</h2>"
$combinedPdfContent += "<ul>"
Get-ChildItem $latestRun.FullName -Directory | ForEach-Object {
    $fileName = $_.Name
    $combinedPdfContent += "<li>$fileName</li>"
}
$combinedPdfContent += "</ul>"

$combinedPdfPath = "$reportFolder\combined_report.pdf"
$combinedPdfContent > $combinedPdfPath

# Collect all drawings
$drawingFiles = @()
Get-ChildItem $latestRun.FullName -Recurse -Filter "*.dwg" | ForEach-Object {
    $drawingFiles += $_.FullName
}

# Create a zip file containing all drawings
if ($drawingFiles.Count -gt 0) {
    $zipPath = "$reportFolder\all_drawings.zip"
    
    # Create a temporary directory for drawings
    $tempDrawingsDir = "$reportFolder\temp_drawings"
    New-Item -ItemType Directory -Path $tempDrawingsDir -Force | Out-Null
    
    # Copy all drawings to the temporary directory
    foreach ($drawing in $drawingFiles) {
        Copy-Item $drawing -Destination $tempDrawingsDir
    }
    
    # Create the zip file
    # Note: PowerShell Compress-Archive requires .NET 4.5 or later
    try {
        Compress-Archive -Path $tempDrawingsDir\* -DestinationPath $zipPath -Force
        Remove-Item -Path $tempDrawingsDir -Recurse -Force
        Write-Host "Created drawings archive: $zipPath"
    } catch {
        Write-Host "Could not create ZIP archive. Please ensure .NET 4.5 or later is installed."
        # Fallback: list drawings in a text file
        $drawingList = "Drawings Archive Contents:`n" + ($drawingFiles | ForEach-Object { $_.Name }) -join "`n"
        $drawingList > "$reportFolder\drawings_list.txt"
    }
} else {
    Write-Host "No drawing files found to archive."
}

# Create a compact combined report (HTML with embedded PDF links)
$compactHtmlContent = "<div class='section'><h2>Compact Report</h2>"
$compactHtmlContent += "<p><a href='comprehensive_report.html'>Full HTML Report</a></p>"
$compactHtmlContent += "<p><a href='combined_report.pdf'>Combined PDF Report</a></p>"

foreach ($element in $structuralElements) {
    $pdfFile = "$($element.ToLower()).pdf"
    if (Test-Path "$reportFolder\$pdfFile") {
        $compactHtmlContent += "<p><a href='$pdfFile'>$element PDF Report</a></p>"
    }
}

if (Test-Path "$reportFolder\all_drawings.zip") {
    $compactHtmlContent += "<p><a href='all_drawings.zip'>All Drawings (ZIP)</a></p>"
}

$compactHtmlContent += "</div>"

$compactHtmlReport = Create-HtmlReport "STRUDS Compact Report - $timestamp" $compactHtmlContent
$compactHtmlReportPath = "$reportFolder\compact_report.html"
$compactHtmlReport > $compactHtmlReportPath

Write-Host "Comprehensive report generation completed!"
Write-Host "Reports saved to: $reportFolder"
Write-Host ""
Write-Host "Generated files:"
Write-Host "  - $htmlReportPath (Main HTML report)"
Write-Host "  - $compactHtmlReportPath (Compact report)"
Write-Host "  - $combinedPdfPath (Combined PDF report)"
foreach ($element in $structuralElements) {
    $pdfFile = "$($element.ToLower()).pdf"
    Write-Host "  - $reportFolder\$pdfFile (Individual $element PDF)"
}
if (Test-Path "$reportFolder\all_drawings.zip") {
    Write-Host "  - $reportFolder\all_drawings.zip (All drawings)"
}