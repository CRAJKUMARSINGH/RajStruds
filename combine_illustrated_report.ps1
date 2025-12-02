# Combine Illustrated Report Script for STRUDS Software
# This script combines all HTML reports into a single illustrated report sorted by structural elements

# Get the most recent test run folder
$latestRun = Get-ChildItem "Output" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($null -eq $latestRun) {
    Write-Host "No test runs found in Output directory"
    exit 1
}

# Create combined reports directory
$combinedDir = "Combined_Illustrated_Report"
New-Item -ItemType Directory -Path $combinedDir -Force | Out-Null

Write-Host "Combining reports from: $($latestRun.Name)"
Write-Host "Output will be saved to: $combinedDir"

# Function to create the main index page
function Create-MainIndex {
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
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .header { background-color: #2c3e50; color: white; padding: 20px; text-align: center; }
        .nav { background-color: #3498db; padding: 10px; }
        .nav a { color: white; text-decoration: none; margin-right: 20px; }
        .nav a:hover { text-decoration: underline; }
        .container { background-color: white; padding: 20px; margin: 20px 0; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        .element-section { margin: 30px 0; border-left: 5px solid #3498db; padding-left: 15px; }
        .element-title { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
        .file-section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; }
        .file-title { background-color: #e8f4f8; padding: 10px; margin: 0; }
        iframe { width: 100%; height: 400px; border: 1px solid #ccc; margin: 10px 0; }
        .footer { text-align: center; padding: 20px; color: #7f8c8d; }
    </style>
</head>
<body>
    <div class="header">
        <h1>$Title</h1>
        <p>Generated on: $(Get-Date)</p>
    </div>
    <div class="nav">
        <a href="#footings">Footings</a>
        <a href="#columns">Columns</a>
        <a href="#beams">Beams</a>
        <a href="#slabs">Slabs</a>
    </div>
    <div class="container">
        $Content
    </div>
    <div class="footer">
        <p>STRUDS Structural Analysis and Design Reports</p>
    </div>
</body>
</html>
"@
}

# Function to create element section
function Create-ElementSection {
    param(
        [string]$ElementName,
        [string]$Content
    )
    
    return @"
<div class="element-section">
    <h2 id="$($ElementName.ToLower())">$ElementName</h2>
    $Content
</div>
"@
}

# Define structural elements order
$structuralElements = @("Footings", "Columns", "Beams", "Slabs")
$sortingLevels = @("Schedule", "Design")

# Initialize main content
$mainContent = ""

# Process each structural element
foreach ($element in $structuralElements) {
    $elementContent = ""
    
    # Process each sorting level
    foreach ($level in $sortingLevels) {
        $levelContent = "<h3>$level</h3>"
        
        # Process each file in the test run
        Get-ChildItem $latestRun.FullName -Directory | ForEach-Object {
            $fileName = $_.Name
            $fileSection = "<div class='file-section'>"
            $fileSection += "<h4 class='file-title'>$fileName</h4>"
            
            # Add analysis report iframe
            $analysisReport = Join-Path $_.FullName "${fileName}_analysis_report.html"
            if (Test-Path $analysisReport) {
                # Copy the report to combined directory
                $destAnalysis = "$combinedDir\${fileName}_analysis_report.html"
                Copy-Item $analysisReport $destAnalysis -Force
                
                $fileSection += "<h5>Analysis Report</h5>"
                $fileSection += "<iframe src='${fileName}_analysis_report.html'></iframe>"
            }
            
            # Add design report iframe
            $designReport = Join-Path $_.FullName "${fileName}_design_report.html"
            if (Test-Path $designReport) {
                # Copy the report to combined directory
                $destDesign = "$combinedDir\${fileName}_design_report.html"
                Copy-Item $designReport $destDesign -Force
                
                $fileSection += "<h5>Design Report</h5>"
                $fileSection += "<iframe src='${fileName}_design_report.html'></iframe>"
            }
            
            # Add RCC design content
            $rccReport = Join-Path $_.FullName "${fileName}_rcc_design.txt"
            if (Test-Path $rccReport) {
                # Copy the report to combined directory
                $destRCC = "$combinedDir\${fileName}_rcc_design.txt"
                Copy-Item $rccReport $destRCC -Force
                
                # Read RCC content and format it
                $rccContent = Get-Content $rccReport | ForEach-Object { "<p>$_</p>" }
                $fileSection += "<h5>RCC Design</h5>"
                $fileSection += "<div style='background-color: #f8f8f8; padding: 10px; border: 1px solid #ddd; font-family: monospace;'>$($rccContent -join '')</div>"
            }
            
            $fileSection += "</div>"
            $levelContent += $fileSection
        }
        
        $elementContent += $levelContent
    }
    
    # Add element section to main content
    $mainContent += Create-ElementSection $element $elementContent
}

# Create the main index page
$indexContent = Create-MainIndex "STRUDS Illustrated Combined Report" $mainContent
$indexContent > "$combinedDir\index.html"

# Copy all drawing files to the combined directory
$drawingFiles = Get-ChildItem $latestRun.FullName -Recurse -Filter "*.dwg"
if ($drawingFiles.Count -gt 0) {
    New-Item -ItemType Directory -Path "$combinedDir\drawings" -Force | Out-Null
    foreach ($drawing in $drawingFiles) {
        Copy-Item $drawing.FullName "$combinedDir\drawings\" -Force
    }
    Write-Host "Copied $($drawingFiles.Count) drawing files to $combinedDir\drawings"
}

Write-Host "Combined illustrated report generation completed!"
Write-Host "Report saved to: $combinedDir\index.html"
Write-Host ""
Write-Host "To view the report:"
Write-Host "1. Open $combinedDir\index.html in a web browser"
Write-Host "2. The report contains all analysis, design, and RCC reports"
Write-Host "3. Navigate using the element links at the top"