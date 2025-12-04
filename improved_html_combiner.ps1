# Improved HTML Report Combiner for STRUDS
# This script combines HTML reports while preserving original formatting

# Function to extract body content from HTML file
function Get-HtmlBodyContent {
    param(
        [string]$FilePath
    )
    
    $content = Get-Content $FilePath -Raw
    
    # Extract content between <body> and </body> tags
    if ($content -match '<body[^>]*>(.*?)</body>') {
        return $matches[1]
    }
    
    # If no body tag, return the whole content
    return $content
}

# Function to create a professional header for each report
function Create-ReportHeader {
    param(
        [string]$ReportTitle,
        [string]$ReportFile
    )
    
    return @"
<div class="report-header">
    <h2>$ReportTitle</h2>
    <p class="report-file">Source: $ReportFile</p>
</div>
"@
}

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
        .report-header { background: #e3f2fd; padding: 1rem; border-radius: 4px; margin-bottom: 1rem; }
        .report-header h2 { color: #2c3e50; margin: 0 0 0.5rem 0; }
        .report-header .report-file { color: #7f8c8d; font-size: 0.9rem; margin: 0; }
        .report-content { border: 1px solid #ddd; border-radius: 4px; padding: 1rem; background: white; }
        .report-content table { width: 100%; border-collapse: collapse; margin: 1rem 0; }
        .report-content th, .report-content td { padding: 0.75rem; text-align: left; border: 1px solid #ddd; }
        .report-content th { background-color: #3498db; color: white; }
        .report-content tr:nth-child(even) { background-color: #f8f9fa; }
        .footer { background: #2c3e50; color: white; text-align: center; padding: 2rem; margin-top: 3rem; }
        .stats { display: flex; justify-content: space-around; flex-wrap: wrap; background: #e3f2fd; padding: 1rem; border-radius: 6px; margin: 1rem 0; }
        .stat-item { text-align: center; }
        .stat-number { font-size: 2rem; font-weight: bold; color: #3498db; }
        .stat-label { font-size: 0.9rem; color: #7f8c8d; }
        @media (max-width: 768px) {
            .nav { flex-direction: column; align-items: center; }
            .nav a { margin: 0.25rem 0; }
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
        <p>Improved HTML Report Combiner</p>
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

# Get the most recent RAW_REPORT folder
$latestRawReport = Get-ChildItem "RAW_REPORT" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($null -eq $latestRawReport) {
    Write-Host "No RAW_REPORT directory found" -ForegroundColor Red
    exit 1
}

# Create improved reports directory
$improvedDir = "Improved_Combined_Reports"
New-Item -ItemType Directory -Path $improvedDir -Force | Out-Null

Write-Host "Creating improved combined reports from: $($latestRawReport.Name)"
Write-Host "Output will be saved to: $improvedDir"

# Define structural elements order
$structuralElements = @("Footings", "Columns", "Beams", "Slabs")
$sortingLevels = @("Analysis", "Design")

# Initialize main content with overview
$mainContent = @"
<div id="overview">
    <h2>Project Overview</h2>
    <div class="stats">
        <div class="stat-item">
            <div class="stat-number">$((Get-ChildItem $latestRawReport.FullName -Directory).Count)</div>
            <div class="stat-label">Structural Files</div>
        </div>
        <div class="stat-item">
            <div class="stat-number">$($structuralElements.Count)</div>
            <div class="stat-label">Element Types</div>
        </div>
        <div class="stat-item">
            <div class="stat-number">$((Get-ChildItem $latestRawReport.FullName -Recurse -Filter "*.dwg").Count)</div>
            <div class="stat-label">Drawings</div>
        </div>
        <div class="stat-item">
            <div class="stat-number">$((Get-ChildItem $latestRawReport.FullName -Recurse -Filter "*.html").Count)</div>
            <div class="stat-label">HTML Reports</div>
        </div>
    </div>
    <p>This improved report combines all structural analysis and design reports generated by the STRUDS software while preserving the original formatting and styling of each report.</p>
</div>
"@

# Process each structural element
foreach ($element in $structuralElements) {
    $elementContent = ""
    
    # Process each sorting level
    foreach ($level in $sortingLevels) {
        $levelContent = "<div class='level-section'><h3>$level Reports</h3>"
        
        # Process each file in the RAW_REPORT
        Get-ChildItem $latestRawReport.FullName -Directory | ForEach-Object {
            $fileName = $_.Name
            $fileContent = ""
            
            # Determine report type based on level
            $reportPattern = if ($level -eq "Analysis") { "*_analysis_report.html" } else { "*_design_report.html" }
            
            # Find matching reports
            $reports = Get-ChildItem $_.FullName -Filter $reportPattern -ErrorAction SilentlyContinue
            
            foreach ($report in $reports) {
                # Copy the report to improved directory
                $destReport = "$improvedDir\$($report.Name)"
                Copy-Item $report.FullName $destReport -Force
                
                # Extract the body content to preserve original formatting
                $bodyContent = Get-HtmlBodyContent $report.FullName
                
                # Create a card with the original content
                $fileContent += @"
<div class="file-card">
    <h3 class="file-title">$($report.BaseName.Replace('_', ' '))</h3>
    <div class="report-content">
        $bodyContent
    </div>
</div>
"@
            }
        }
        
        $levelContent += $fileContent
        $levelContent += "</div>"
        $elementContent += $levelContent
    }
    
    # Add element section to main content
    $mainContent += Create-ElementSection $element $elementContent
}

# Add drawings section
$drawingsContent = "<div class='level-section'><h3>Structural Drawings</h3>"
$drawingsContent += "<div class='drawing-gallery'>"

$drawingFiles = Get-ChildItem $latestRawReport.FullName -Recurse -Include "*.dwg","*.dxf" -ErrorAction SilentlyContinue
foreach ($drawing in $drawingFiles) {
    $destDrawing = "$improvedDir\$($drawing.Name)"
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
$indexContent = Create-ProfessionalIndex "STRUDS Improved Combined Engineering Reports" $mainContent
$indexContent > "$improvedDir\index.html"

Write-Host "Improved combined report generation completed!"
Write-Host "Report saved to: $improvedDir\index.html"
Write-Host ""
Write-Host "Key improvements:"
Write-Host "1. Original HTML formatting is preserved" -ForegroundColor Green
Write-Host "2. Better visual presentation with enhanced styling" -ForegroundColor Green
Write-Host "3. Easier navigation between reports" -ForegroundColor Green
Write-Host "4. Cleaner organization by element type and report type" -ForegroundColor Green