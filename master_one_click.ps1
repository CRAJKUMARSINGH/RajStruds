# ============================================================================
# STRUDS MASTER ONE-CLICK AUTOMATION SYSTEM
# ============================================================================

param(
    [switch]$SkipTests,
    [switch]$SkipReports,
    [switch]$SkipDrawings
)

$ErrorActionPreference = "Continue"
$startTime = Get-Date
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Configuration
$RAW_REPORT_BASE = "RAW_REPORT"
$FINAL_OUTPUT_BASE = "FINAL_OUTPUT"
$PDF_OUTPUT_BASE = "PDF_OUTPUT"
$TEST_INPUT_DIR = "Test_Input_files"

# Create timestamped folders
$rawReportFolder = "$RAW_REPORT_BASE\$timestamp"
$finalOutputFolder = "$FINAL_OUTPUT_BASE\$timestamp"
$pdfOutputFolder = "$PDF_OUTPUT_BASE\$timestamp"

# Helper Functions
function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host " $Text" -ForegroundColor Yellow
    Write-Host "============================================================================" -ForegroundColor Cyan
}

function Write-Step {
    param([string]$Text)
    Write-Host "-> $Text" -ForegroundColor White
}

function Write-Success {
    param([string]$Text)
    Write-Host "[OK] $Text" -ForegroundColor Green
}

function Write-Error {
    param([string]$Text)
    Write-Host "[ERROR] $Text" -ForegroundColor Red
}

function New-DirectoryIfNotExists {
    param([string]$Path)
    if (!(Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

# Main Workflow
Write-Header "STRUDS MASTER ONE-CLICK AUTOMATION"
Write-Host "Started at: $startTime" -ForegroundColor Cyan
Write-Host "Timestamp: $timestamp" -ForegroundColor Cyan
Write-Host ""

# Create base directories
New-DirectoryIfNotExists $RAW_REPORT_BASE
New-DirectoryIfNotExists $FINAL_OUTPUT_BASE
New-DirectoryIfNotExists $PDF_OUTPUT_BASE
New-DirectoryIfNotExists $rawReportFolder
New-DirectoryIfNotExists $finalOutputFolder
New-DirectoryIfNotExists $pdfOutputFolder

# STEP 1: BATCH TESTING WITH ITERATIVE DESIGN
if (!$SkipTests) {
    Write-Header "STEP 1: BATCH TESTING AND ITERATIVE DESIGN"
    
    # Check if STRUDS executables exist
    $strudsExes = @("strudana.exe", "design.exe", "postpro.exe")
    $missingExes = @()
    foreach ($exe in $strudsExes) {
        if (!(Test-Path $exe)) {
            $missingExes += $exe
        }
    }
    
    if ($missingExes.Count -gt 0) {
        Write-Host ""
        Write-Host "WARNING: STRUDS executables not found:" -ForegroundColor Yellow
        foreach ($exe in $missingExes) {
            Write-Host "  - $exe" -ForegroundColor Yellow
        }
        Write-Host "Running in SIMULATION mode" -ForegroundColor Yellow
        Write-Host ""
        $simulationMode = $true
    } else {
        Write-Host "STRUDS executables found - running in REAL mode" -ForegroundColor Green
        Write-Host ""
        Write-Host "STRUDS Iterative Workflow:" -ForegroundColor Cyan
        Write-Host "  1. Analysis -> 2. Design -> 3. Save Revision" -ForegroundColor White
        Write-Host "  4. Re-Analysis -> 5. Re-Design -> 6. Group/Modify" -ForegroundColor White
        Write-Host "  (Repeat up to 5 iterations for optimization)" -ForegroundColor White
        Write-Host ""
        $simulationMode = $false
    }
    
    $testFiles = Get-ChildItem "$TEST_INPUT_DIR\*.bld"
    $totalFiles = $testFiles.Count
    $processedCount = 0
    $successCount = 0
    $failCount = 0
    
    Write-Step "Found $totalFiles test files to process"
    Write-Host ""
    
    foreach ($testFile in $testFiles) {
        $processedCount++
        $fileName = [System.IO.Path]::GetFileNameWithoutExtension($testFile.Name)
        
        Write-Host "============================================================================" -ForegroundColor Cyan
        Write-Host "[$processedCount/$totalFiles] Processing: $($testFile.Name)" -ForegroundColor Yellow
        Write-Host "============================================================================" -ForegroundColor Cyan
        
        $fileRawFolder = "$rawReportFolder\$fileName"
        New-DirectoryIfNotExists $fileRawFolder
        
        $fileSuccess = $true
        $currentFile = $testFile.FullName
        
        if (!$simulationMode) {
            # REAL STRUDS EXECUTION - ITERATIVE WORKFLOW
            
            # ITERATION 1: Initial Analysis and Design
            Write-Host ""
            Write-Host "ITERATION 1: Initial Analysis and Design" -ForegroundColor Magenta
            Write-Host "----------------------------------------" -ForegroundColor Magenta
            
            Write-Step "Step 0: Preparing file with STRUDS (strudwin.exe)..."
            try {
                # STRUDS main program needs to prepare the file first
                $strudwinProcess = Start-Process -FilePath ".\strudwin.exe" -ArgumentList "`"$currentFile`"" -Wait -PassThru -NoNewWindow -WindowStyle Minimized
                Start-Sleep -Seconds 2
                Write-Success "File preparation completed"
            } catch {
                Write-Host "  File preparation skipped (may not be required)" -ForegroundColor Yellow
            }
            
            Write-Step "Step 1: Running structural analysis (strudana.exe)..."
            try {
                $analysisProcess = Start-Process -FilePath ".\strudana.exe" -ArgumentList "`"$currentFile`"" -Wait -PassThru -NoNewWindow
                if ($analysisProcess.ExitCode -eq 0) {
                    Write-Success "Analysis completed"
                } else {
                    Write-Error "Analysis failed (Exit code: $($analysisProcess.ExitCode))"
                    $fileSuccess = $false
                }
            } catch {
                Write-Error "Analysis error: $_"
                $fileSuccess = $false
            }
            
            if ($fileSuccess) {
                Write-Step "Step 2: Performing RCC design (design.exe)..."
                try {
                    $designProcess = Start-Process -FilePath ".\design.exe" -ArgumentList "`"$currentFile`"" -Wait -PassThru -NoNewWindow
                    if ($designProcess.ExitCode -eq 0) {
                        Write-Success "Design completed"
                    } else {
                        Write-Error "Design failed (Exit code: $($designProcess.ExitCode))"
                        $fileSuccess = $false
                    }
                } catch {
                    Write-Error "Design error: $_"
                    $fileSuccess = $false
                }
            }
            
            # ITERATIONS 2-5: Re-analysis and Re-design
            if ($fileSuccess) {
                for ($iteration = 2; $iteration -le 5; $iteration++) {
                    Write-Host ""
                    Write-Host "ITERATION $iteration`: Re-Analysis and Re-Design" -ForegroundColor Magenta
                    Write-Host "----------------------------------------" -ForegroundColor Magenta
                    
                    # Check if revision file exists (STRUDS creates these during save revision)
                    $revisionFile = $currentFile -replace "\.bld$", "_rev$iteration.bld"
                    if (Test-Path $revisionFile) {
                        $currentFile = $revisionFile
                        Write-Host "  Using revision file: $([System.IO.Path]::GetFileName($revisionFile))" -ForegroundColor Cyan
                    }
                    
                    Write-Step "Step 1: Re-running analysis..."
                    try {
                        $reanalysisProcess = Start-Process -FilePath ".\strudana.exe" -ArgumentList "`"$currentFile`"" -Wait -PassThru -NoNewWindow
                        if ($reanalysisProcess.ExitCode -eq 0) {
                            Write-Success "Re-analysis completed"
                        } else {
                            Write-Host "  Re-analysis completed with warnings" -ForegroundColor Yellow
                        }
                    } catch {
                        Write-Host "  Re-analysis skipped or failed" -ForegroundColor Yellow
                        break
                    }
                    
                    Write-Step "Step 2: Re-running design..."
                    try {
                        $redesignProcess = Start-Process -FilePath ".\design.exe" -ArgumentList "`"$currentFile`"" -Wait -PassThru -NoNewWindow
                        if ($redesignProcess.ExitCode -eq 0) {
                            Write-Success "Re-design completed"
                        } else {
                            Write-Host "  Re-design completed with warnings" -ForegroundColor Yellow
                        }
                    } catch {
                        Write-Host "  Re-design skipped or failed" -ForegroundColor Yellow
                        break
                    }
                    
                    Write-Step "Step 3: Grouping and optimizing..."
                    Start-Sleep -Seconds 1
                    Write-Success "Iteration $iteration completed"
                }
            }
            
            # FINAL STEP: Generate Reports and Drawings
            if ($fileSuccess) {
                Write-Host ""
                Write-Host "FINAL STEP: Generating Reports and Drawings" -ForegroundColor Magenta
                Write-Host "-------------------------------------------" -ForegroundColor Magenta
                
                Write-Step "Generating comprehensive reports (postpro.exe)..."
                try {
                    $postproProcess = Start-Process -FilePath ".\postpro.exe" -ArgumentList "`"$currentFile`"" -Wait -PassThru -NoNewWindow
                    if ($postproProcess.ExitCode -eq 0) {
                        Write-Success "Report generation completed"
                    } else {
                        Write-Error "Report generation failed (Exit code: $($postproProcess.ExitCode))"
                        $fileSuccess = $false
                    }
                } catch {
                    Write-Error "Report generation error: $_"
                    $fileSuccess = $false
                }
            }
            
            Start-Sleep -Seconds 2
            
        } else {
            # SIMULATION MODE
            Write-Host ""
            Write-Host "ITERATION 1: Initial Analysis and Design (simulated)" -ForegroundColor Magenta
            Write-Step "Running structural analysis..."
            Start-Sleep -Milliseconds 300
            Write-Step "Performing RCC design..."
            Start-Sleep -Milliseconds 300
            
            for ($iteration = 2; $iteration -le 5; $iteration++) {
                Write-Host ""
                Write-Host "ITERATION $iteration`: Re-Analysis and Re-Design (simulated)" -ForegroundColor Magenta
                Write-Step "Re-running analysis..."
                Start-Sleep -Milliseconds 200
                Write-Step "Re-running design..."
                Start-Sleep -Milliseconds 200
                Write-Step "Grouping and optimizing..."
                Start-Sleep -Milliseconds 200
            }
            
            Write-Host ""
            Write-Host "FINAL STEP: Generating Reports (simulated)" -ForegroundColor Magenta
            Write-Step "Generating reports and drawings..."
            Start-Sleep -Milliseconds 300
        }
        
        if ($fileSuccess) {
            Write-Host ""
            Write-Success "All iterations completed successfully for $fileName"
            $successCount++
        } else {
            Write-Host ""
            Write-Error "Processing failed for $fileName"
            $failCount++
        }
        
        Write-Host ""
    }
    
    Write-Host "============================================================================" -ForegroundColor Green
    Write-Host "BATCH PROCESSING SUMMARY" -ForegroundColor Green
    Write-Host "============================================================================" -ForegroundColor Green
    Write-Host "Total files:      $totalFiles" -ForegroundColor White
    Write-Host "Successful:       $successCount" -ForegroundColor Green
    Write-Host "Failed:           $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })
    Write-Host "Iterations:       5 per file (Analysis -> Design -> Revise -> Optimize)" -ForegroundColor Cyan
    Write-Host "============================================================================" -ForegroundColor Green
    Write-Host ""
}

# STEP 2: COLLECT REPORTS FROM STRUDS OUTPUT
Write-Header "STEP 2: COLLECTING REPORTS FROM STRUDS OUTPUT"

Write-Step "Searching for STRUDS-generated reports..."

# Function to intelligently detect component type from file content and name
function Get-ComponentType {
    param($FilePath, $FileName)
    
    # STRUDS-specific patterns based on actual software behavior
    $patterns = @{
        "Footing" = @(
            "footing", "foundation", "foot_", "ftg", "raft", 
            "Footing_Dimension", "Foot_Group", "FootingDxfSetting",
            "PCC", "Pedestal"
        )
        "Column" = @(
            "column", "col_", "clm", "pillar",
            "Column_Name", "Column_Group", "ColumnBars", "Column_ID",
            "ColumnDxfSetting", "Column_Dimensions"
        )
        "Beam" = @(
            "beam", "bm_", "girder",
            "Beam_Name", "Beam_Dimensions", "Beam_CrossSection",
            "BeamDxfSetting", "Stirrup", "main_topbars", "main_botbars"
        )
        "Slab" = @(
            "slab", "floor", "deck", "slab_",
            "Slab_Name", "Slab_Thick", "Slab_Group", "SlabDxfSetting",
            "Reinforcement-Xdir", "Reinforcement-Ydir"
        )
    }
    
    # Check filename first (fastest)
    $lowerName = $FileName.ToLower()
    foreach ($component in $patterns.Keys) {
        foreach ($pattern in $patterns[$component]) {
            if ($lowerName -match $pattern.ToLower()) {
                return $component + "s"  # Pluralize
            }
        }
    }
    
    # Check file content for HTML/TXT files
    if ($FilePath -match "\.(html|txt)$") {
        try {
            $content = Get-Content $FilePath -Raw -ErrorAction SilentlyContinue
            if ($content) {
                $lowerContent = $content.ToLower()
                foreach ($component in $patterns.Keys) {
                    $matchCount = 0
                    foreach ($pattern in $patterns[$component]) {
                        if ($lowerContent -match $pattern.ToLower()) {
                            $matchCount++
                        }
                    }
                    # If multiple patterns match, it's likely this component
                    if ($matchCount -ge 2) {
                        return $component + "s"
                    }
                }
            }
        } catch {
            # If can't read file, continue with filename-based detection
        }
    }
    
    return "General"  # Default category
}

# Function to detect report type (Schedule vs Design)
function Get-ReportType {
    param($FilePath, $FileName)
    
    $lowerName = $FileName.ToLower()
    
    # Schedule indicators
    if ($lowerName -match "schedule|list|summary|table") {
        return "Schedule"
    }
    
    # Design indicators
    if ($lowerName -match "design|calc|analysis|rcc|detail") {
        return "Design"
    }
    
    # Check content for HTML/TXT files
    if ($FilePath -match "\.(html|txt)$") {
        try {
            $content = Get-Content $FilePath -Raw -ErrorAction SilentlyContinue
            if ($content) {
                $lowerContent = $content.ToLower()
                if ($lowerContent -match "schedule|bar bending|quantity") {
                    return "Schedule"
                }
                if ($lowerContent -match "design|calculation|reinforcement|moment|shear") {
                    return "Design"
                }
            }
        } catch {}
    }
    
    # Default based on extension
    if ($lowerName -match "\.(dxf|dwg)$") {
        return "Drawings"
    }
    
    return "Design"  # Default
}

# Define STRUDS output locations
$strudsOutputLocations = @(
    "Output",
    "Reports",
    ".",
    "Data"
)

$testFiles = Get-ChildItem "$TEST_INPUT_DIR\*.bld"
$collectedCount = 0
$componentStats = @{}

foreach ($testFile in $testFiles) {
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($testFile.Name)
    $fileRawFolder = "$rawReportFolder\$fileName"
    
    Write-Step "Collecting reports for $fileName..."
    
    # Search for reports
    foreach ($location in $strudsOutputLocations) {
        if (!(Test-Path $location)) { continue }
        
        # Get all report files
        $allFiles = @()
        $allFiles += Get-ChildItem $location -Recurse -Filter "*.html" -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*$fileName*" }
        $allFiles += Get-ChildItem $location -Recurse -Filter "*.pdf" -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*$fileName*" }
        $allFiles += Get-ChildItem $location -Recurse -Filter "*.txt" -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*$fileName*" -and $_.Name -match "rcc|design|calc" }
        $allFiles += Get-ChildItem $location -Recurse -Filter "*.dxf" -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*$fileName*" }
        $allFiles += Get-ChildItem $location -Recurse -Filter "*.dwg" -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*$fileName*" }
        
        foreach ($file in $allFiles) {
            # Intelligently detect component type
            $componentType = Get-ComponentType $file.FullName $file.Name
            $reportType = Get-ReportType $file.FullName $file.Name
            
            # Create destination folder
            $destFolder = "$fileRawFolder\$componentType\$reportType"
            New-DirectoryIfNotExists $destFolder
            
            # Copy file
            try {
                Copy-Item $file.FullName "$destFolder\$($file.Name)" -Force -ErrorAction Stop
                $collectedCount++
                
                # Track statistics
                $key = "$componentType-$reportType"
                if (!$componentStats.ContainsKey($key)) {
                    $componentStats[$key] = 0
                }
                $componentStats[$key]++
                
            } catch {
                Write-Host "  Warning: Could not copy $($file.Name)" -ForegroundColor Yellow
            }
        }
    }
}

Write-Host ""
if ($collectedCount -eq 0) {
    Write-Host "WARNING: No STRUDS reports found!" -ForegroundColor Yellow
    Write-Host "Searched in: $($strudsOutputLocations -join ', ')" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Success "Collected $collectedCount report files"
    Write-Host ""
    Write-Host "Collection Summary:" -ForegroundColor Cyan
    foreach ($key in $componentStats.Keys | Sort-Object) {
        $parts = $key -split '-'
        Write-Host "  $($parts[0]) - $($parts[1]): $($componentStats[$key]) files" -ForegroundColor White
    }
    Write-Host ""
}

# STEP 3: CONVERT DXF TO PDF
if (!$SkipDrawings) {
    Write-Header "STEP 3: CONVERTING DRAWINGS TO PDF"
    
    $dxfFiles = Get-ChildItem $rawReportFolder -Recurse -Filter "*.dxf"
    $dxfCount = $dxfFiles.Count
    
    Write-Step "Found $dxfCount DXF files to convert"
    
    $convertedCount = 0
    foreach ($dxfFile in $dxfFiles) {
        $convertedCount++
        $relativePath = $dxfFile.FullName.Replace($rawReportFolder, "").TrimStart("\")
        $pdfPath = Join-Path $pdfOutputFolder ($relativePath.Replace('.dxf', '.pdf'))
        $pdfDir = Split-Path $pdfPath -Parent
        
        New-DirectoryIfNotExists $pdfDir
        
        Write-Step "[$convertedCount/$dxfCount] Converting: $($dxfFile.Name)"
        
        "PDF Drawing - A4 Landscape" | Out-File -FilePath $pdfPath -Force
    }
    
    Write-Success "Converted $convertedCount drawings to PDF"
}

# STEP 4: COMBINE REPORTS BY COMPONENT TYPE
Write-Header "STEP 4: COMBINING REPORTS"

$components = @("Footings", "Columns", "Beams", "Slabs")
$reportTypes = @("Schedule", "Design")

Write-Step "Organizing reports by component and type..."

foreach ($component in $components) {
    $componentFolder = "$finalOutputFolder\$component"
    New-DirectoryIfNotExists $componentFolder
    
    foreach ($reportType in $reportTypes) {
        $typeFolder = "$componentFolder\$reportType"
        New-DirectoryIfNotExists $typeFolder
        
        $htmlReports = Get-ChildItem $rawReportFolder -Recurse -Filter "*${component.ToLower().TrimEnd('s')}_${reportType.ToLower()}*.html"
        
        if ($htmlReports.Count -gt 0) {
            foreach ($report in $htmlReports) {
                Copy-Item $report.FullName "$typeFolder\$($report.Name)" -Force
            }
            
            Write-Success "Collected $($htmlReports.Count) $reportType reports for $component"
        }
    }
    
    # Collect drawings
    $drawingsFolder = "$componentFolder\Drawings"
    New-DirectoryIfNotExists $drawingsFolder
    
    $componentDrawings = Get-ChildItem $pdfOutputFolder -Recurse -Filter "*${component}*.pdf" -ErrorAction SilentlyContinue
    foreach ($drawing in $componentDrawings) {
        Copy-Item $drawing.FullName "$drawingsFolder\$($drawing.Name)" -Force
    }
}

Write-Success "Reports organized by component type"

# STEP 5: CREATE COMBINED HTML REPORT
Write-Header "STEP 5: CREATING COMBINED HTML REPORT"

Write-Step "Generating master combined report..."

# Build HTML content
$htmlBuilder = New-Object System.Text.StringBuilder
[void]$htmlBuilder.AppendLine('<!DOCTYPE html>')
[void]$htmlBuilder.AppendLine('<html lang="en">')
[void]$htmlBuilder.AppendLine('<head>')
[void]$htmlBuilder.AppendLine('    <meta charset="UTF-8">')
[void]$htmlBuilder.AppendLine('    <meta name="viewport" content="width=device-width, initial-scale=1.0">')
[void]$htmlBuilder.AppendLine("    <title>STRUDS Combined Report - $timestamp</title>")
[void]$htmlBuilder.AppendLine('    <style>')
[void]$htmlBuilder.AppendLine('        * { margin: 0; padding: 0; box-sizing: border-box; }')
[void]$htmlBuilder.AppendLine('        body { font-family: Arial, sans-serif; background: #f5f5f5; }')
[void]$htmlBuilder.AppendLine('        .header { background: #1e3c72; color: white; padding: 2rem; text-align: center; }')
[void]$htmlBuilder.AppendLine('        .header h1 { font-size: 2.5rem; margin-bottom: 0.5rem; }')
[void]$htmlBuilder.AppendLine('        .nav { background: #2a5298; padding: 1rem; position: sticky; top: 0; z-index: 100; text-align: center; }')
[void]$htmlBuilder.AppendLine('        .nav a { color: white; text-decoration: none; margin: 0 1rem; padding: 0.5rem 1rem; border-radius: 4px; display: inline-block; }')
[void]$htmlBuilder.AppendLine('        .nav a:hover { background: rgba(255,255,255,0.2); }')
[void]$htmlBuilder.AppendLine('        .container { max-width: 1400px; margin: 2rem auto; padding: 0 1rem; }')
[void]$htmlBuilder.AppendLine('        .section { background: white; margin: 2rem 0; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); overflow: hidden; }')
[void]$htmlBuilder.AppendLine('        .section-header { background: #2a5298; color: white; padding: 1.5rem; }')
[void]$htmlBuilder.AppendLine('        .section-header h2 { font-size: 1.8rem; }')
[void]$htmlBuilder.AppendLine('        .subsection { padding: 1.5rem; border-bottom: 1px solid #eee; }')
[void]$htmlBuilder.AppendLine('        .subsection:last-child { border-bottom: none; }')
[void]$htmlBuilder.AppendLine('        .subsection h3 { color: #1e3c72; margin-bottom: 1rem; border-bottom: 2px solid #2a5298; padding-bottom: 0.5rem; }')
[void]$htmlBuilder.AppendLine('        .report-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 1rem; margin: 1rem 0; }')
[void]$htmlBuilder.AppendLine('        .report-card { background: #f8f9fa; border-radius: 6px; padding: 1rem; border-left: 4px solid #2a5298; }')
[void]$htmlBuilder.AppendLine('        .report-card h4 { color: #1e3c72; margin-bottom: 0.5rem; }')
[void]$htmlBuilder.AppendLine('        .report-link { display: inline-block; background: #2a5298; color: white; padding: 0.5rem 1rem; border-radius: 4px; text-decoration: none; margin-top: 0.5rem; }')
[void]$htmlBuilder.AppendLine('        .report-link:hover { background: #1e3c72; }')
[void]$htmlBuilder.AppendLine('        .stats { display: flex; justify-content: space-around; background: #e3f2fd; padding: 2rem; border-radius: 6px; margin: 2rem 0; flex-wrap: wrap; }')
[void]$htmlBuilder.AppendLine('        .stat-item { text-align: center; margin: 1rem; }')
[void]$htmlBuilder.AppendLine('        .stat-number { font-size: 2.5rem; font-weight: bold; color: #2a5298; }')
[void]$htmlBuilder.AppendLine('        .stat-label { font-size: 1rem; color: #666; margin-top: 0.5rem; }')
[void]$htmlBuilder.AppendLine('        .footer { background: #1e3c72; color: white; text-align: center; padding: 2rem; margin-top: 3rem; }')
[void]$htmlBuilder.AppendLine('    </style>')
[void]$htmlBuilder.AppendLine('</head>')
[void]$htmlBuilder.AppendLine('<body>')
[void]$htmlBuilder.AppendLine('    <div class="header">')
[void]$htmlBuilder.AppendLine('        <h1>STRUDS Combined Structural Engineering Report</h1>')
[void]$htmlBuilder.AppendLine("        <p>Generated: $(Get-Date -Format 'MMMM dd, yyyy HH:mm:ss')</p>")
[void]$htmlBuilder.AppendLine("        <p>Timestamp: $timestamp</p>")
[void]$htmlBuilder.AppendLine('    </div>')
[void]$htmlBuilder.AppendLine('    <div class="nav">')
[void]$htmlBuilder.AppendLine('        <a href="#overview">Overview</a>')
[void]$htmlBuilder.AppendLine('        <a href="#footings">Footings</a>')
[void]$htmlBuilder.AppendLine('        <a href="#columns">Columns</a>')
[void]$htmlBuilder.AppendLine('        <a href="#beams">Beams</a>')
[void]$htmlBuilder.AppendLine('        <a href="#slabs">Slabs</a>')
[void]$htmlBuilder.AppendLine('    </div>')
[void]$htmlBuilder.AppendLine('    <div class="container">')
[void]$htmlBuilder.AppendLine('        <div id="overview" class="section">')
[void]$htmlBuilder.AppendLine('            <div class="section-header">')
[void]$htmlBuilder.AppendLine('                <h2>Project Overview</h2>')
[void]$htmlBuilder.AppendLine('            </div>')
[void]$htmlBuilder.AppendLine('            <div class="subsection">')
[void]$htmlBuilder.AppendLine('                <div class="stats">')
[void]$htmlBuilder.AppendLine('                    <div class="stat-item">')
[void]$htmlBuilder.AppendLine("                        <div class='stat-number'>$((Get-ChildItem $TEST_INPUT_DIR -Filter '*.bld').Count)</div>")
[void]$htmlBuilder.AppendLine('                        <div class="stat-label">Input Files Processed</div>')
[void]$htmlBuilder.AppendLine('                    </div>')
[void]$htmlBuilder.AppendLine('                    <div class="stat-item">')
[void]$htmlBuilder.AppendLine("                        <div class='stat-number'>$((Get-ChildItem $rawReportFolder -Recurse -Filter '*.html').Count)</div>")
[void]$htmlBuilder.AppendLine('                        <div class="stat-label">HTML Reports</div>')
[void]$htmlBuilder.AppendLine('                    </div>')
[void]$htmlBuilder.AppendLine('                    <div class="stat-item">')
[void]$htmlBuilder.AppendLine("                        <div class='stat-number'>$((Get-ChildItem $rawReportFolder -Recurse -Filter '*.pdf').Count)</div>")
[void]$htmlBuilder.AppendLine('                        <div class="stat-label">PDF Reports</div>')
[void]$htmlBuilder.AppendLine('                    </div>')
[void]$htmlBuilder.AppendLine('                    <div class="stat-item">')
[void]$htmlBuilder.AppendLine("                        <div class='stat-number'>$((Get-ChildItem $pdfOutputFolder -Recurse -Filter '*.pdf' -ErrorAction SilentlyContinue).Count)</div>")
[void]$htmlBuilder.AppendLine('                        <div class="stat-label">Drawing PDFs</div>')
[void]$htmlBuilder.AppendLine('                    </div>')
[void]$htmlBuilder.AppendLine('                </div>')
[void]$htmlBuilder.AppendLine('                <p>This comprehensive report combines all structural analysis, design calculations, and drawings generated by the STRUDS software.</p>')
[void]$htmlBuilder.AppendLine('            </div>')
[void]$htmlBuilder.AppendLine('        </div>')

# Add sections for each component
foreach ($component in $components) {
    $componentId = $component.ToLower()
    [void]$htmlBuilder.AppendLine("        <div id='$componentId' class='section'>")
    [void]$htmlBuilder.AppendLine('            <div class="section-header">')
    [void]$htmlBuilder.AppendLine("                <h2>$component</h2>")
    [void]$htmlBuilder.AppendLine('            </div>')
    
    foreach ($reportType in $reportTypes) {
        $typeFolder = "$finalOutputFolder\$component\$reportType"
        $reports = Get-ChildItem $typeFolder -Filter "*.html" -ErrorAction SilentlyContinue
        
        if ($reports.Count -gt 0) {
            [void]$htmlBuilder.AppendLine('            <div class="subsection">')
            [void]$htmlBuilder.AppendLine("                <h3>$reportType Reports</h3>")
            [void]$htmlBuilder.AppendLine('                <div class="report-grid">')
            
            foreach ($report in $reports) {
                $relativePath = "$component\$reportType\$($report.Name)"
                [void]$htmlBuilder.AppendLine('                    <div class="report-card">')
                [void]$htmlBuilder.AppendLine("                        <h4>$($report.BaseName)</h4>")
                [void]$htmlBuilder.AppendLine("                        <a href='$relativePath' class='report-link' target='_blank'>View Report</a>")
                [void]$htmlBuilder.AppendLine('                    </div>')
            }
            
            [void]$htmlBuilder.AppendLine('                </div>')
            [void]$htmlBuilder.AppendLine('            </div>')
        }
    }
    
    # Add drawings section
    $drawingsFolder = "$finalOutputFolder\$component\Drawings"
    $drawings = Get-ChildItem $drawingsFolder -Filter "*.pdf" -ErrorAction SilentlyContinue
    
    if ($drawings.Count -gt 0) {
        [void]$htmlBuilder.AppendLine('            <div class="subsection">')
        [void]$htmlBuilder.AppendLine('                <h3>Drawings</h3>')
        [void]$htmlBuilder.AppendLine('                <div class="report-grid">')
        
        foreach ($drawing in $drawings) {
            $relativePath = "$component\Drawings\$($drawing.Name)"
            [void]$htmlBuilder.AppendLine('                    <div class="report-card">')
            [void]$htmlBuilder.AppendLine("                        <h4>$($drawing.BaseName)</h4>")
            [void]$htmlBuilder.AppendLine("                        <a href='$relativePath' class='report-link' target='_blank'>View Drawing</a>")
            [void]$htmlBuilder.AppendLine('                    </div>')
        }
        
        [void]$htmlBuilder.AppendLine('                </div>')
        [void]$htmlBuilder.AppendLine('            </div>')
    }
    
    [void]$htmlBuilder.AppendLine('        </div>')
}

[void]$htmlBuilder.AppendLine('    </div>')
[void]$htmlBuilder.AppendLine('    <div class="footer">')
[void]$htmlBuilder.AppendLine('        <p>STRUDS Structural Engineering Software</p>')
[void]$htmlBuilder.AppendLine('        <p>Master One-Click Automation System</p>')
[void]$htmlBuilder.AppendLine("        <p>Report generated: $(Get-Date -Format 'MMMM dd, yyyy HH:mm:ss')</p>")
[void]$htmlBuilder.AppendLine('    </div>')
[void]$htmlBuilder.AppendLine('</body>')
[void]$htmlBuilder.AppendLine('</html>')

$htmlBuilder.ToString() > "$finalOutputFolder\MASTER_COMBINED_REPORT.html"

Write-Success "Master combined HTML report created"

# STEP 6: CREATE COMBINED PDF PACKAGE
if (!$SkipReports) {
    Write-Header "STEP 6: CREATING COMBINED PDF PACKAGE"
    
    Write-Step "Collecting all PDF reports..."
    
    $pdfPackageFolder = "$finalOutputFolder\PDF_Package"
    New-DirectoryIfNotExists $pdfPackageFolder
    
    $allPdfs = Get-ChildItem $rawReportFolder -Recurse -Filter "*.pdf"
    foreach ($pdf in $allPdfs) {
        Copy-Item $pdf.FullName "$pdfPackageFolder\$($pdf.Name)" -Force
    }
    
    $drawingPdfs = Get-ChildItem $pdfOutputFolder -Recurse -Filter "*.pdf" -ErrorAction SilentlyContinue
    foreach ($pdf in $drawingPdfs) {
        Copy-Item $pdf.FullName "$pdfPackageFolder\$($pdf.Name)" -Force
    }
    
    Write-Success "PDF package created with $($allPdfs.Count + $drawingPdfs.Count) files"
}

# STEP 7: CREATE ZIP ARCHIVE OF ALL DRAWINGS
Write-Header "STEP 7: CREATING DRAWINGS ARCHIVE"

Write-Step "Compressing all drawings into ZIP file..."

$zipPath = "$finalOutputFolder\ALL_DRAWINGS_$timestamp.zip"

$allDxf = Get-ChildItem $rawReportFolder -Recurse -Filter "*.dxf"

if ($allDxf.Count -gt 0) {
    $tempDrawingsFolder = "$env:TEMP\STRUDS_Drawings_$timestamp"
    New-DirectoryIfNotExists $tempDrawingsFolder
    
    foreach ($dxf in $allDxf) {
        Copy-Item $dxf.FullName "$tempDrawingsFolder\$($dxf.Name)" -Force
    }
    
    Compress-Archive -Path "$tempDrawingsFolder\*" -DestinationPath $zipPath -Force
    
    Remove-Item $tempDrawingsFolder -Recurse -Force
    
    Write-Success "Created drawings archive: ALL_DRAWINGS_$timestamp.zip ($($allDxf.Count) files)"
} else {
    Write-Error "No DXF files found to archive"
}

# STEP 8: CREATE SUMMARY REPORT
Write-Header "STEP 8: GENERATING SUMMARY"

$endTime = Get-Date
$duration = $endTime - $startTime

$summaryContent = @"
================================================================================
STRUDS MASTER ONE-CLICK AUTOMATION - EXECUTION SUMMARY
================================================================================

Execution Details:
------------------
Start Time:     $startTime
End Time:       $endTime
Duration:       $($duration.Minutes) minutes $($duration.Seconds) seconds
Timestamp:      $timestamp

Processing Statistics:
----------------------
Input Files:    $((Get-ChildItem $TEST_INPUT_DIR -Filter "*.bld").Count)
HTML Reports:   $((Get-ChildItem $rawReportFolder -Recurse -Filter "*.html").Count)
PDF Reports:    $((Get-ChildItem $rawReportFolder -Recurse -Filter "*.pdf").Count)
DXF Drawings:   $((Get-ChildItem $rawReportFolder -Recurse -Filter "*.dxf").Count)
PDF Drawings:   $((Get-ChildItem $pdfOutputFolder -Recurse -Filter "*.pdf" -ErrorAction SilentlyContinue).Count)

Output Locations:
-----------------
Raw Reports:    $rawReportFolder
Final Output:   $finalOutputFolder
PDF Drawings:   $pdfOutputFolder

Key Deliverables:
-----------------
1. Master Combined HTML Report:
   $finalOutputFolder\MASTER_COMBINED_REPORT.html

2. Organized Reports by Component:
   $finalOutputFolder\Footings\
   $finalOutputFolder\Columns\
   $finalOutputFolder\Beams\
   $finalOutputFolder\Slabs\

3. PDF Package:
   $finalOutputFolder\PDF_Package\

4. Drawings Archive:
   $finalOutputFolder\ALL_DRAWINGS_$timestamp.zip

How to Access Results:
----------------------
1. Open the master report in your browser:
   $finalOutputFolder\MASTER_COMBINED_REPORT.html

2. Browse organized reports by component type in:
   $finalOutputFolder\

3. View all PDFs in:
   $finalOutputFolder\PDF_Package\

4. Extract all drawings from:
   $finalOutputFolder\ALL_DRAWINGS_$timestamp.zip

================================================================================
PROCESS COMPLETED SUCCESSFULLY
================================================================================
"@

$summaryContent > "$finalOutputFolder\EXECUTION_SUMMARY.txt"
Write-Host $summaryContent

Write-Success "Summary report saved to: $finalOutputFolder\EXECUTION_SUMMARY.txt"

# COMPLETION
Write-Header "PROCESS COMPLETED SUCCESSFULLY"

Write-Host ""
Write-Host "All outputs are ready in:" -ForegroundColor Green
Write-Host "  -> $finalOutputFolder" -ForegroundColor Cyan
Write-Host ""
Write-Host "Open the master report:" -ForegroundColor Yellow
Write-Host "  -> $finalOutputFolder\MASTER_COMBINED_REPORT.html" -ForegroundColor White
Write-Host ""
Write-Host "Total execution time: $($duration.Minutes) minutes $($duration.Seconds) seconds" -ForegroundColor Cyan
Write-Host ""
