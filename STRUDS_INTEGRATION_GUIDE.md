# STRUDS Software Integration Guide

## Purpose
This guide explains how to integrate the master_one_click.ps1 script with your actual STRUDS software installation.

## Understanding STRUDS Output

### Typical STRUDS Workflow:
1. **strudwin.exe** - Main GUI, creates .bld files
2. **strudana.exe** - Performs structural analysis
3. **design.exe** - Performs RCC design calculations
4. **postpro.exe** - Generates reports and drawings

### Expected STRUDS Output Files:

#### HTML Reports (typically 10-50 pages each):
- Footing schedule and design reports
- Column schedule and design reports
- Beam schedule and design reports
- Slab schedule and design reports
- Load analysis reports
- Deflection reports
- Reinforcement schedules

#### PDF Reports:
- Detailed calculation sheets
- Design summary reports
- Code compliance reports
- Material quantity reports

#### DXF/DWG Drawings:
- Foundation plans
- Column layout and details
- Beam layout and details
- Slab reinforcement details
- Section drawings
- Detail drawings

## Integration Steps

### Step 1: Locate STRUDS Output Directories

First, run STRUDS manually on one test file and note where it saves outputs:

```powershell
# Run this to find STRUDS output locations:
Get-ChildItem -Path "C:\" -Recurse -Filter "*.html" -ErrorAction SilentlyContinue | 
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-1) } | 
    Select-Object FullName
```

Common STRUDS output locations:
- `C:\STRUDS\Output\`
- `C:\Program Files\STRUDS\Reports\`
- Same directory as .bld file
- User's Documents folder

### Step 2: Update Script - Analysis Execution

In `master_one_click.ps1`, find this section (around line 120):

```powershell
# CURRENT (simulation):
Write-Step "Running structural analysis..."
Start-Sleep -Milliseconds 500

Write-Step "Performing RCC design..."
Start-Sleep -Milliseconds 500

Write-Step "Generating reports and drawings..."
Start-Sleep -Milliseconds 500
```

Replace with:

```powershell
# REAL STRUDS EXECUTION:
Write-Step "Running structural analysis..."
$analysisResult = & ".\strudana.exe" "$($testFile.FullName)" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Analysis failed for $($testFile.Name): $analysisResult"
    continue
}

Write-Step "Performing RCC design..."
$designResult = & ".\design.exe" "$($testFile.FullName)" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Design failed for $($testFile.Name): $designResult"
    continue
}

Write-Step "Generating reports and drawings..."
$postproResult = & ".\postpro.exe" "$($testFile.FullName)" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Report generation failed for $($testFile.Name): $postproResult"
    continue
}

# Wait for STRUDS to finish writing files
Start-Sleep -Seconds 2
```

### Step 3: Update Script - Report Collection

Find the report collection section (around line 180) and update with actual STRUDS paths:

```powershell
# EXAMPLE - Update paths based on your STRUDS installation:

# Determine where STRUDS saved reports for this file
$strudsOutputDir = "C:\STRUDS\Output\$fileName"  # Adjust this path!

# Footing reports
New-DirectoryIfNotExists "$fileRawFolder\Footings"
Copy-Item "$strudsOutputDir\Footing_Schedule*.html" "$fileRawFolder\Footings\" -ErrorAction SilentlyContinue
Copy-Item "$strudsOutputDir\Footing_Design*.html" "$fileRawFolder\Footings\" -ErrorAction SilentlyContinue
Copy-Item "$strudsOutputDir\Footing_Design*.pdf" "$fileRawFolder\Footings\" -ErrorAction SilentlyContinue
Copy-Item "$strudsOutputDir\Footing*.dxf" "$fileRawFolder\Footings\" -ErrorAction SilentlyContinue

# Column reports
New-DirectoryIfNotExists "$fileRawFolder\Columns"
Copy-Item "$strudsOutputDir\Column_Schedule*.html" "$fileRawFolder\Columns\" -ErrorAction SilentlyContinue
Copy-Item "$strudsOutputDir\Column_Design*.html" "$fileRawFolder\Columns\" -ErrorAction SilentlyContinue
Copy-Item "$strudsOutputDir\Column_Design*.pdf" "$fileRawFolder\Columns\" -ErrorAction SilentlyContinue
Copy-Item "$strudsOutputDir\Column*.dxf" "$fileRawFolder\Columns\" -ErrorAction SilentlyContinue

# Beam reports
New-DirectoryIfNotExists "$fileRawFolder\Beams"
Copy-Item "$strudsOutputDir\Beam_Schedule*.html" "$fileRawFolder\Beams\" -ErrorAction SilentlyContinue
Copy-Item "$strudsOutputDir\Beam_Design*.html" "$fileRawFolder\Beams\" -ErrorAction SilentlyContinue
Copy-Item "$strudsOutputDir\Beam_Design*.pdf" "$fileRawFolder\Beams\" -ErrorAction SilentlyContinue
Copy-Item "$strudsOutputDir\Beam*.dxf" "$fileRawFolder\Beams\" -ErrorAction SilentlyContinue

# Slab reports
New-DirectoryIfNotExists "$fileRawFolder\Slabs"
Copy-Item "$strudsOutputDir\Slab_Schedule*.html" "$fileRawFolder\Slabs\" -ErrorAction SilentlyContinue
Copy-Item "$strudsOutputDir\Slab_Design*.html" "$fileRawFolder\Slabs\" -ErrorAction SilentlyContinue
Copy-Item "$strudsOutputDir\Slab_Design*.pdf" "$fileRawFolder\Slabs\" -ErrorAction SilentlyContinue
Copy-Item "$strudsOutputDir\Slab*.dxf" "$fileRawFolder\Slabs\" -ErrorAction SilentlyContinue

# Copy any additional reports
Copy-Item "$strudsOutputDir\*.html" "$fileRawFolder\" -ErrorAction SilentlyContinue
Copy-Item "$strudsOutputDir\*.pdf" "$fileRawFolder\" -ErrorAction SilentlyContinue
Copy-Item "$strudsOutputDir\*.dxf" "$fileRawFolder\" -ErrorAction SilentlyContinue
```

### Step 4: Implement DXF to PDF Conversion

Find the DXF conversion section (around line 260) and implement actual conversion:

#### Option A: Using AutoCAD Core Console

```powershell
# Create plot script
$plotScript = @"
_-PLOT
_Y
Model
DWG To PDF.pc3
A4
L
N
W
0,0
1000,1000
F
C
Y
.
Y
N
N
N
Y
$pdfPath
N
Y
"@

$plotScriptPath = "$env:TEMP\plot_script.scr"
$plotScript > $plotScriptPath

# Execute AutoCAD Core Console
& "C:\Program Files\Autodesk\AutoCAD 2024\accoreconsole.exe" /i "$($dxfFile.FullName)" /s "$plotScriptPath"

# Clean up
Remove-Item $plotScriptPath -ErrorAction SilentlyContinue
```

#### Option B: Using Teigha File Converter

```powershell
# Download from: https://www.opendesign.com/guestfiles/oda_file_converter
$teighaPath = "C:\Program Files\ODA\Teigha File Converter\TeighaFileConverter.exe"

& $teighaPath `
    "$($dxfFile.DirectoryName)" `
    "$pdfDir" `
    "ACAD2018" `
    "PDF" `
    "1" `
    "1" `
    "$($dxfFile.Name)"
```

#### Option C: Using LibreCAD (if available)

```powershell
& "C:\Program Files\LibreCAD\librecad.exe" `
    --export-format=pdf `
    --export-file="$pdfPath" `
    "$($dxfFile.FullName)"
```

### Step 5: Test Integration

1. **Test with one file first:**
   ```powershell
   # Create a test version
   Copy-Item master_one_click.ps1 test_integration.ps1
   
   # Modify to process only one file
   # Add at line 115:
   $testFiles = $testFiles | Select-Object -First 1
   
   # Run test
   .\test_integration.ps1
   ```

2. **Verify outputs:**
   - Check RAW_REPORT folder for collected reports
   - Verify reports are actual STRUDS output (not placeholders)
   - Confirm DXF files are present
   - Check PDF conversion worked

3. **Review logs:**
   - Check for any error messages
   - Verify all files were processed
   - Confirm execution times are reasonable

### Step 6: Handle STRUDS-Specific File Naming

STRUDS may use specific naming conventions. Update the file matching patterns:

```powershell
# Example: If STRUDS names files like "FOOTING_SCHEDULE_001.html"
$footingSchedules = Get-ChildItem $strudsOutputDir -Filter "FOOTING_SCHEDULE*.html"
$footingDesigns = Get-ChildItem $strudsOutputDir -Filter "FOOTING_DESIGN*.html"

# Copy with better error handling
foreach ($file in $footingSchedules) {
    try {
        Copy-Item $file.FullName "$fileRawFolder\Footings\" -Force
        Write-Step "  Copied: $($file.Name)"
    } catch {
        Write-Error "  Failed to copy: $($file.Name) - $_"
    }
}
```

## Common Issues and Solutions

### Issue 1: STRUDS Executables Not Found
```powershell
# Add path verification at script start:
$requiredExes = @("strudana.exe", "design.exe", "postpro.exe")
foreach ($exe in $requiredExes) {
    if (!(Test-Path $exe)) {
        Write-Error "Required executable not found: $exe"
        Write-Host "Please ensure STRUDS is installed and executables are in script directory"
        exit 1
    }
}
```

### Issue 2: STRUDS Takes Long Time
```powershell
# Add timeout handling:
$process = Start-Process -FilePath ".\strudana.exe" `
    -ArgumentList "$($testFile.FullName)" `
    -PassThru `
    -NoNewWindow

$timeout = 300  # 5 minutes
if (!$process.WaitForExit($timeout * 1000)) {
    $process.Kill()
    Write-Error "Analysis timed out after $timeout seconds"
}
```

### Issue 3: Reports Not Found
```powershell
# Add diagnostic output:
Write-Host "Looking for reports in: $strudsOutputDir"
$foundFiles = Get-ChildItem $strudsOutputDir -Recurse
Write-Host "Found $($foundFiles.Count) files:"
$foundFiles | ForEach-Object { Write-Host "  - $($_.FullName)" }
```

### Issue 4: DXF Conversion Fails
```powershell
# Add fallback: just copy DXF files without conversion
if (!(Test-Path $pdfPath)) {
    Write-Warning "PDF conversion failed, copying DXF instead"
    Copy-Item $dxfFile.FullName "$pdfDir\$($dxfFile.Name)" -Force
}
```

## Testing Checklist

Before running on all files:

- [ ] STRUDS executables are accessible
- [ ] Test with 1 file successfully
- [ ] Reports are collected correctly
- [ ] DXF files are found
- [ ] PDF conversion works
- [ ] Combined HTML report displays correctly
- [ ] All links in HTML work
- [ ] ZIP archive contains all drawings
- [ ] Execution time is acceptable
- [ ] Error handling works properly

## Performance Optimization

### Parallel Processing (for multiple files):

```powershell
# Replace the foreach loop with parallel processing:
$testFiles | ForEach-Object -Parallel {
    $testFile = $_
    # ... processing code ...
} -ThrottleLimit 4  # Process 4 files at a time
```

### Incremental Processing:

```powershell
# Skip files that were already processed:
$processedFiles = Get-Content "processed_files.txt" -ErrorAction SilentlyContinue
$testFiles = $testFiles | Where-Object { 
    $processedFiles -notcontains $_.Name 
}
```

## Support

If you encounter issues:

1. Run STRUDS manually to verify it works
2. Check STRUDS documentation for command-line usage
3. Verify file paths and naming conventions
4. Test with a single simple file first
5. Check Windows Event Viewer for application errors
6. Review PowerShell execution policy settings

## Next Steps

After successful integration:

1. Document your specific STRUDS paths and settings
2. Create a backup of the working script
3. Set up scheduled execution if needed
4. Train team members on usage
5. Establish archiving procedures for old reports
