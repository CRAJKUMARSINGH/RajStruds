# Fix Script for "FOR ALL AMOUNT IS ZERO" Error in STRUDS
# This script validates input files and ensures proper values are set

# Function to check if a directory exists and create it if not
function New-DirectoryIfNotExists {
    param([string]$Path)
    if (!(Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

# Function to validate STRUDS input files
function Validate-InputFiles {
    param(
        [string]$InputPath
    )
    
    Write-Host "Validating input files in: $InputPath" -ForegroundColor Cyan
    Write-Host ""
    
    $validationIssues = 0
    $filesProcessed = 0
    
    # Get all files in the input path (not just directories)
    $inputFiles = Get-ChildItem $InputPath -Include "*.bld","*.inp","*.str","*.dat" -ErrorAction SilentlyContinue
    
    foreach ($file in $inputFiles) {
        $filesProcessed++
        Write-Host "  Processing: $($file.Name)" -ForegroundColor White
        
        # Read the file content
        $content = Get-Content $file.FullName -Raw
        
        # Check for common patterns that might cause zero values
        if ($content -match "LOAD\s*=\s*0" -or $content -match "FORCE\s*=\s*0" -or 
            $content -match "MOMENT\s*=\s*0" -or $content -match "PRESSURE\s*=\s*0") {
            Write-Host "    WARNING: Zero load values detected" -ForegroundColor Red
            $validationIssues++
        }
        
        if ($content -match "E\s*=\s*0" -or $content -match "MODULUS\s*=\s*0") {
            Write-Host "    WARNING: Zero modulus values detected" -ForegroundColor Red
            $validationIssues++
        }
        
        if ($content -match "DENSITY\s*=\s*0" -or $content -match "WEIGHT\s*=\s*0") {
            Write-Host "    WARNING: Zero density/weight values detected" -ForegroundColor Red
            $validationIssues++
        }
        
        # Check for geometry definitions with zero dimensions
        if ($content -match "WIDTH\s*=\s*0" -or $content -match "HEIGHT\s*=\s*0" -or 
            $content -match "DEPTH\s*=\s*0" -or $content -match "LENGTH\s*=\s*0") {
            Write-Host "    WARNING: Zero dimension values detected" -ForegroundColor Red
            $validationIssues++
        }
    }
    
    Write-Host ""
    Write-Host "Validation complete:" -ForegroundColor Cyan
    Write-Host "  Files processed: $filesProcessed" -ForegroundColor White
    if ($validationIssues -gt 0) {
        Write-Host "  Issues found: $validationIssues" -ForegroundColor Red
    } else {
        Write-Host "  Issues found: $validationIssues" -ForegroundColor Green
    }
    Write-Host ""
    
    return $validationIssues
}

# Function to create sample input files with proper values
function Create-SampleInputFiles {
    param(
        [string]$OutputPath
    )
    
    Write-Host "Creating sample input files with proper values..." -ForegroundColor Cyan
    
    # Create sample directory
    $sampleDir = "$OutputPath\SAMPLE_INPUTS"
    New-DirectoryIfNotExists $sampleDir
    
    # Create a sample STRUDS input file with proper values
    $sampleContent = @"
STRUDS INPUT FILE
=================

STRUCTURE_DEFINITION
TITLE = Sample Building Structure
UNITS = kN, m, C

MATERIAL_PROPERTIES
CONCRETE_GRADE = M25
STEEL_GRADE = Fe415
CONCRETE_MODULUS = 25000000
STEEL_MODULUS = 200000000
CONCRETE_DENSITY = 25
STEEL_DENSITY = 78.5

LOAD_DEFINITIONS
DEAD_LOAD_FACTOR = 1.5
LIVE_LOAD_FACTOR = 1.5
WIND_LOAD_FACTOR = 1.2
SEISMIC_LOAD_FACTOR = 1.2

NODE_COORDINATES
1, 0.0, 0.0, 0.0
2, 5.0, 0.0, 0.0
3, 0.0, 0.0, 3.0
4, 5.0, 0.0, 3.0

ELEMENT_PROPERTIES
COLUMN_SECTION = 0.3 0.3  # Width Height in meters
BEAM_SECTION = 0.3 0.45   # Width Height in meters
SLAB_THICKNESS = 0.15      # Thickness in meters

LOAD_CASES
DEAD_LOAD = 12.5  # kN/m2
LIVE_LOAD = 5.0   # kN/m2
WIND_LOAD = 1.2   # kN/m2
SEISMIC_LOAD = 2.0 # kN/m2

ANALYSIS_PARAMETERS
ANALYSIS_TYPE = 3D_FRAME
ITERATIONS = 100
TOLERANCE = 0.001

END_OF_FILE
"@
    
    $sampleContent > "$sampleDir\sample_structure.str"
    Write-Host "Sample input file created: $sampleDir\sample_structure.str" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "Sample file contains proper non-zero values for:" -ForegroundColor Cyan
    Write-Host "  - Material properties (modulus, density)" -ForegroundColor White
    Write-Host "  - Load definitions (dead, live, wind, seismic)" -ForegroundColor White
    Write-Host "  - Element dimensions (sections, thickness)" -ForegroundColor White
    Write-Host "  - Node coordinates" -ForegroundColor White
}

Write-Host "========================================" -ForegroundColor Green
Write-Host "STRUDS ZERO VALUE FIX SCRIPT" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check if Test_Input_files folder exists
$testFolder = "Test_Input_files"
if (Test-Path $testFolder) {
    Write-Host "Found test folder. Validating input files..." -ForegroundColor Cyan
    $issues = Validate-InputFiles $testFolder
    
    if ($issues -gt 0) {
        Write-Host "Input validation issues detected. Creating sample files with proper values..." -ForegroundColor Yellow
        Create-SampleInputFiles "."
    } else {
        Write-Host "All input files appear to have valid values." -ForegroundColor Green
    }
} else {
    Write-Host "No test folder found. Creating sample input files with proper values..." -ForegroundColor Yellow
    Create-SampleInputFiles "."
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "FIX SCRIPT EXECUTION COMPLETE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Recommendations to fix 'FOR ALL AMOUNT IS ZERO' error:" -ForegroundColor Cyan
Write-Host "1. Ensure all input files have non-zero values for loads and properties" -ForegroundColor White
Write-Host "2. Check that material properties (E, density) are properly defined" -ForegroundColor White
Write-Host "3. Verify that geometric dimensions are non-zero" -ForegroundColor White
Write-Host "4. Confirm load factors and combinations are correctly specified" -ForegroundColor White
Write-Host "5. Review node coordinates and element connectivity" -ForegroundColor White
Write-Host ""
Write-Host "Use the sample input files in SAMPLE_INPUTS directory as reference." -ForegroundColor Green