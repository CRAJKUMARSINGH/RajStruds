# Advanced Report Combiner for STRUDS Software
# This script combines detailed engineering reports from STRUDS software
# It's designed to work with actual detailed reports (10+ pages each)

# Function to create the main index page with professional styling
function Create-ProfessionalIndex {
    param(
        [string]$Title,
        [string]$Content
    )
    
    return @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$Title</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f8f9fa; color: #333; line-height: 1.6; }
        .header { background: linear-gradient(135deg, #2c3e50, #1a2530); color: white; padding: 2rem 0; text-align: center; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        .header h1 { font-size: 2.5rem; margin-bottom: 0.5rem; }
        .header p { font-size: 1.1rem; opacity: 0.9; }
        .nav-container { background-color: #3498db; padding: 1rem 0; position: sticky; top: 0; z-index: 100; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .nav { max-width: 1200px; margin: 0 auto; display: flex; justify-content: center; flex-wrap: wrap; }
        .nav a { color: white; text-decoration: none; margin: 0 1rem; padding: 0.5rem 1rem; border-radius: 4px; transition: all 0.3s ease; }
        .nav a:hover { background-color: rgba(255,255,255,0.2); }
        .container { max-width: 1200px; margin: 2rem auto; padding: 0 1rem; }
        .element-section { background: white; margin: 2rem 0; border-radius: 8px; box-shadow: 0 5px 15px rgba(0,0,0,0.08); overflow: hidden; }
        .element-header { background: linear-gradient(135deg, #3498db, #2980b9); color: white; padding: 1.5rem; }
        .element-header h2 { font-size: 1.8rem; margin: 0; }
        .level-section { padding: 1.5rem; border-bottom: 1px solid #eee; }
        .level-section:last-child { border-bottom: none; }
        .level-section h3 { color: #2c3e50; margin-bottom: 1rem; padding-bottom: 0.5rem; border-bottom: 2px solid #3498db; }
        .file-card { background: #f8f9fa; border-radius: 6px; padding: 1.5rem; margin: 1rem 0; border-left: 4px solid #3498db; transition: transform 0.3s ease, box-shadow 0.3s ease; }
        .file-card:hover { transform: translateY(-3px); box-shadow: 0 8px 25px rgba(0,0,0,0.12); }
        .file-title { color: #2c3e50; margin-top: 0; font-size: 1.3rem; }
        .report-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 1rem; margin: 1rem 0; }
        .report-card { background: white; border-radius: 6px; padding: 1rem; box-shadow: 0 2px 8px rgba(0,0,0,0.08); border-top: 3px solid #3498db; }
        .report-card h4 { color: #2c3e50; margin-top: 0; }
        .report-card p { color: #7f8c8d; font-size: 0.9rem; }
        .report-link { display: inline-block; background: #3498db; color: white; padding: 0.5rem 1rem; border-radius: 4px; text-decoration: none; margin-top: 0.5rem; transition: background 0.3s ease; }
        .report-link:hover { background: #2980b9; }
        .iframe-container { margin: 1rem 0; border: 1px solid #ddd; border-radius: 4px; overflow: hidden; }
        .iframe-container iframe { width: 100%; height: 600px; border: none; }
        .text-report { background: #f8f9fa; padding: 1.5rem; border-radius: 6px; border-left: 4px solid #27ae60; font-family: 'Courier New', monospace; white-space: pre-wrap; max-height: 400px; overflow: auto; }
        .drawing-gallery { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 1rem; margin: 1rem 0; }
        .drawing-thumb { background: white; border-radius: 6px; padding: 1rem; text-align: center; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
        .drawing-thumb img { max-width: 100%; height: 150px; object-fit: cover; border-radius: 4px; }
        .drawing-thumb p { margin: 0.5rem 0 0; font-size: 0.9rem; color: #7f8c8d; }
        .footer { background: #2c3e50; color: white; text-align: center; padding: 2rem; margin-top: 3rem; }
        .stats { display: flex; justify-content: space-around; flex-wrap: wrap; background: #e3f2fd; padding: 1rem; border-radius: 6px; margin: 1rem 0; }
        .stat-item { text-align: center; }
        .stat-number { font-size: 2rem; font-weight: bold; color: #3498db; }
        .stat-label { font-size: 0.9rem; color: #7f8c8d; }
        @media (max-width: 768px) {
            .nav { flex-direction: column; align-items: center; }
            .nav a { margin: 0.25rem 0; }
            .report-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>$Title</h1>
        <p>Generated on: $(Get-Date)</p>
    </div>
    <div class="nav-container">
        <div class="nav">
            <a href="#overview">Overview</a>
            <a href="#footings">Footings</a>
            <a href="#columns">Columns</a>
            <a href="#beams">Beams</a>
            <a href="#slabs">Slabs</a>
            <a href="#drawings">Drawings</a>
        </div>
    </div>
    <div class="container">
        $Content
    </div>
    <div class="footer">
        <p>STRUDS Structural Engineering Reports</p>
        <p>Advanced Report Combiner System</p>
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
    <div class="element-header">
        <h2 id="$($ElementName.ToLower())">$ElementName</h2>
    </div>
    $Content
</div>
"@
}

# Function to create a professional file card
function Create-FileCard {
    param(
        [string]$FileName,
        [string]$Content
    )
    
    return @"
<div class="file-card">
    <h3 class="file-title">$FileName</h3>
    $Content
</div>
"@
}

# Get the most recent test run folder
$latestRun = Get-ChildItem "Output" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($null -eq $latestRun) {
    Write-Host "No test runs found in Output directory"
    exit 1
}

# Create advanced reports directory
$advancedDir = "Advanced_Combined_Reports"
New-Item -ItemType Directory -Path $advancedDir -Force | Out-Null

Write-Host "Creating advanced combined reports from: $($latestRun.Name)"
Write-Host "Output will be saved to: $advancedDir"

# Define structural elements order
$structuralElements = @("Footings", "Columns", "Beams", "Slabs")
$sortingLevels = @("Schedule", "Design")

# Initialize main content with overview
$mainContent = @"
<div id="overview">
    <h2>Project Overview</h2>
    <div class="stats">
        <div class="stat-item">
            <div class="stat-number">$((Get-ChildItem $latestRun.FullName -Directory).Count)</div>
            <div class="stat-label">Structural Files</div>
        </div>
        <div class="stat-item">
            <div class="stat-number">$($structuralElements.Count)</div>
            <div class="stat-label">Element Types</div>
        </div>
        <div class="stat-item">
            <div class="stat-number">$((Get-ChildItem $latestRun.FullName -Recurse -Filter "*.dwg").Count)</div>
            <div class="stat-label">Drawings</div>
        </div>
        <div class="stat-item">
            <div class="stat-number">$((Get-ChildItem $latestRun.FullName -Recurse -Filter "*.pdf").Count + (Get-ChildItem $latestRun.FullName -Recurse -Filter "*.html").Count)</div>
            <div class="stat-label">Reports</div>
        </div>
    </div>
    <p>This comprehensive report combines all structural analysis and design reports generated by the STRUDS software. Each structural element type is organized with its corresponding schedules and design documents.</p>
</div>
"@

# Process each structural element
foreach ($element in $structuralElements) {
    $elementContent = ""
    
    # Process each sorting level
    foreach ($level in $sortingLevels) {
        $levelContent = "<div class='level-section'><h3>$level</h3>"
        
        # Process each file in the test run
        Get-ChildItem $latestRun.FullName -Directory | ForEach-Object {
            $fileName = $_.Name
            $fileContent = ""
            
            # Check for various report types that would exist in real STRUDS output
            $reports = @()
            
            # Analysis reports (HTML)
            $analysisReport = Join-Path $_.FullName "${fileName}_analysis_report.html"
            if (Test-Path $analysisReport) {
                $destAnalysis = "$advancedDir\${fileName}_analysis_report.html"
                Copy-Item $analysisReport $destAnalysis -Force
                $reports += @{
                    Type = "Analysis Report"
                    Format = "HTML"
                    File = "${fileName}_analysis_report.html"
                    Description = "Detailed structural analysis results including load cases, deflections, and stability checks"
                }
            }
            
            # Design reports (HTML)
            $designReport = Join-Path $_.FullName "${fileName}_design_report.html"
            if (Test-Path $designReport) {
                $destDesign = "$advancedDir\${fileName}_design_report.html"
                Copy-Item $designReport $destDesign -Force
                $reports += @{
                    Type = "Design Report"
                    Format = "HTML"
                    File = "${fileName}_design_report.html"
                    Description = "Structural design calculations and code compliance verification"
                }
            }
            
            # RCC design reports (TXT)
            $rccReport = Join-Path $_.FullName "${fileName}_rcc_design.txt"
            if (Test-Path $rccReport) {
                $destRCC = "$advancedDir\${fileName}_rcc_design.txt"
                Copy-Item $rccReport $destRCC -Force
                $reports += @{
                    Type = "RCC Design"
                    Format = "Text"
                    File = "${fileName}_rcc_design.txt"
                    Description = "Reinforced concrete design calculations and reinforcement details"
                }
            }
            
            # PDF reports (if they exist in real STRUDS output)
            $pdfReports = Get-ChildItem $_.FullName -Filter "*.pdf" -ErrorAction SilentlyContinue
            foreach ($pdf in $pdfReports) {
                $destPdf = "$advancedDir\$($pdf.Name)"
                Copy-Item $pdf.FullName $destPdf -Force
                $reports += @{
                    Type = "Detailed Report"
                    Format = "PDF"
                    File = $pdf.Name
                    Description = "Comprehensive engineering report with detailed calculations"
                }
            }
            
            # DXF/DWG drawings (if they exist in real STRUDS output)
            $drawingFiles = Get-ChildItem $_.FullName -Include "*.dxf","*.dwg" -ErrorAction SilentlyContinue
            foreach ($drawing in $drawingFiles) {
                $destDrawing = "$advancedDir\$($drawing.Name)"
                Copy-Item $drawing.FullName $destDrawing -Force
                $reports += @{
                    Type = "Drawing"
                    Format = "CAD"
                    File = $drawing.Name
                    Description = "Structural drawings and detailing"
                }
            }
            
            # If we found reports, create a card for this file
            if ($reports.Count -gt 0) {
                $fileContent += "<div class='report-grid'>"
                foreach ($report in $reports) {
                    $fileContent += @"
<div class="report-card">
    <h4>$($report.Type) ($($report.Format))</h4>
    <p>$($report.Description)</p>
    <a href="$($report.File)" class="report-link" target="_blank">View Report</a>
</div>
"@
                }
                $fileContent += "</div>"
                
                # Add iframes for HTML reports
                foreach ($report in $reports) {
                    if ($report.Format -eq "HTML") {
                        $fileContent += @"
<div class="iframe-container">
    <iframe src="$($report.File)"></iframe>
</div>
"@
                    }
                }
                
                # Add text content for TXT reports
                foreach ($report in $reports) {
                    if ($report.Format -eq "Text") {
                        $textContent = Get-Content "$advancedDir\$($report.File)" -ErrorAction SilentlyContinue
                        if ($textContent) {
                            $fileContent += "<div class='text-report'>$($textContent -join "`n")</div>"
                        }
                    }
                }
                
                $levelContent += Create-FileCard $fileName $fileContent
            }
        }
        
        $levelContent += "</div>"
        $elementContent += $levelContent
    }
    
    # Add element section to main content
    $mainContent += Create-ElementSection $element $elementContent
}

# Add drawings section
$drawingsContent = "<div class='level-section'><h3>Structural Drawings</h3>"
$drawingsContent += "<div class='drawing-gallery'>"

$drawingFiles = Get-ChildItem $latestRun.FullName -Recurse -Include "*.dwg","*.dxf" -ErrorAction SilentlyContinue
foreach ($drawing in $drawingFiles) {
    $destDrawing = "$advancedDir\$($drawing.Name)"
    Copy-Item $drawing.FullName $destDrawing -Force
    
    $drawingsContent += @"
<div class="drawing-thumb">
    <p>$($drawing.Name)</p>
    <p>Size: $([math]::Round($drawing.Length/1024, 2)) KB</p>
</div>
"@
}

$drawingsContent += "</div></div>"
$mainContent += Create-ElementSection "Drawings" $drawingsContent

# Create the main index page
$indexContent = Create-ProfessionalIndex "STRUDS Advanced Combined Engineering Reports" $mainContent
$indexContent > "$advancedDir\index.html"

Write-Host "Advanced combined report generation completed!"
Write-Host "Report saved to: $advancedDir\index.html"
Write-Host ""
Write-Host "To view the report:"
Write-Host "1. Open $advancedDir\index.html in a web browser"
Write-Host "2. The report contains all analysis, design, and RCC reports"
Write-Host "3. Navigate using the element links at the top"
Write-Host "4. All individual reports are linked and can be viewed in separate tabs"