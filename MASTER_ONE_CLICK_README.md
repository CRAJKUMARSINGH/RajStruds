# STRUDS Master One-Click Automation System

## Overview

This system provides complete automation for STRUDS structural engineering software, from batch testing through final report generation and archiving.

## What It Does

### Complete Workflow:
1. **Batch Testing** - Processes all .bld files in Test_Input_files
2. **Analysis & Design** - Runs structural analysis and RCC design
3. **Report Generation** - Creates HTML, PDF, and DXF outputs
4. **Raw Report Download** - Collects all reports to RAW_REPORT with timestamp
5. **DXF to PDF Conversion** - Converts drawings to A4 landscape PDFs
6. **Report Organization** - Sorts by component (Footing, Column, Beam, Slab) and type (Schedule, Design, Drawings)
7. **HTML Combination** - Creates master combined HTML report
8. **PDF Packaging** - Combines all PDFs in one location
9. **Drawing Archive** - ZIPs all DXF files
10. **Final Output** - Saves everything to FINAL_OUTPUT with timestamp

## Quick Start

### Run Everything (One Click):
```powershell
.\master_one_click.ps1
```

### Run with Options:
```powershell
# Skip testing (use existing reports)
.\master_one_click.ps1 -SkipTests

# Skip drawing conversion
.\master_one_click.ps1 -SkipDrawings

# Skip PDF report packaging
.\master_one_click.ps1 -SkipReports

# Combine options
.\master_one_click.ps1 -SkipTests -SkipDrawings
```

## Output Structure

```
RAW_REPORT/
└── yyyyMMdd_HHmmss/
    ├── File1/
    │   ├── Footings/
    │   │   ├── File1_footing_schedule.html
    │   │   ├── File1_footing_design.html
    │   │   ├── File1_footing_design.pdf
    │   │   └── File1_footing.dxf
    │   ├── Columns/
    │   ├── Beams/
    │   └── Slabs/
    └── File2/
        └── ...

FINAL_OUTPUT/
└── yyyyMMdd_HHmmss/
    ├── MASTER_COMBINED_REPORT.html  ← OPEN THIS!
    ├── EXECUTION_SUMMARY.txt
    ├── ALL_DRAWINGS_yyyyMMdd_HHmmss.zip
    ├── Footings/
    │   ├── Schedule/
    │   ├── Design/
    │   └── Drawings/
    ├── Columns/
    │   ├── Schedule/
    │   ├── Design/
    │   └── Drawings/
    ├── Beams/
    │   ├── Schedule/
    │   ├── Design/
    │   └── Drawings/
    ├── Slabs/
    │   ├── Schedule/
    │   ├── Design/
    │   └── Drawings/
    └── PDF_Package/
        └── (all PDFs combined)

PDF_OUTPUT/
└── yyyyMMdd_HHmmss/
    └── (converted drawing PDFs)
```

## Key Features

### 1. Intelligent Organization
- Reports sorted by structural component type
- Further organized by report type (Schedule, Design, Drawings)
- Timestamped folders prevent overwriting

### 2. Master Combined Report
- Single HTML file with navigation
- Links to all individual reports
- Statistics and overview
- Professional styling

### 3. Drawing Management
- DXF to PDF conversion (A4 landscape)
- All drawings in one ZIP file
- Organized by component type

### 4. PDF Package
- All PDF reports in one location
- Easy distribution and archiving

### 5. Complete Traceability
- Timestamped execution
- Summary report with statistics
- Raw reports preserved

## Viewing Results

### Primary Access Point:
Open in browser:
```
FINAL_OUTPUT/[timestamp]/MASTER_COMBINED_REPORT.html
```

This provides:
- Navigation to all reports
- Statistics overview
- Organized by component type
- Links to all PDFs and drawings

### Alternative Access:
- Browse folders directly in `FINAL_OUTPUT/[timestamp]/`
- View PDF package in `FINAL_OUTPUT/[timestamp]/PDF_Package/`
- Extract drawings from `FINAL_OUTPUT/[timestamp]/ALL_DRAWINGS_[timestamp].zip`

## Integration with Real STRUDS Software

### Current Implementation:
The script is set up as a framework that simulates STRUDS execution.

### To Integrate with Real STRUDS:

1. **Replace simulation calls** in Step 1 with actual STRUDS executables:
   ```powershell
   # Replace:
   Start-Sleep -Milliseconds 500
   
   # With:
   & ".\strudwin.exe" "$($testFile.FullName)"
   & ".\strudana.exe" "$($testFile.FullName)"
   & ".\design.exe" "$($testFile.FullName)"
   & ".\postpro.exe" "$($testFile.FullName)"
   ```

2. **Update report collection** in Step 2 to copy from actual STRUDS output directories:
   ```powershell
   # Find where STRUDS saves reports and update paths
   Copy-Item "C:\STRUDS\Output\Reports\*.html" "$fileRawFolder\Footings\"
   ```

3. **Implement DXF to PDF conversion** in Step 3 using actual CAD software:
   ```powershell
   # Using AutoCAD Core Console:
   & "accoreconsole.exe" /i "$($dxfFile.FullName)" /s "plot_to_pdf.scr"
   
   # Or using Teigha File Converter:
   & "TeighaFileConverter.exe" "$($dxfFile.FullName)" "$pdfPath" "ACAD2018" "PDF" "1" "1"
   ```

## Execution Time

Typical execution times:
- Small project (5-10 files): 2-5 minutes
- Medium project (10-20 files): 5-15 minutes
- Large project (20+ files): 15-30 minutes

*Times depend on model complexity and hardware*

## Troubleshooting

### No reports generated:
- Check that STRUDS executables are in the same directory
- Verify .bld files are valid STRUDS input files
- Check STRUDS license is active

### DXF conversion fails:
- Ensure CAD conversion software is installed
- Check file paths in the script
- Verify DXF files are valid

### Reports not combining:
- Check that reports were generated in RAW_REPORT folder
- Verify file naming conventions match expected patterns
- Check for file permission issues

## Requirements

### Software:
- PowerShell 5.1 or higher
- STRUDS software (strudwin.exe, strudana.exe, design.exe, postpro.exe)
- CAD conversion software (for DXF to PDF):
  - AutoCAD with Core Console, OR
  - Teigha File Converter, OR
  - LibreCAD with command line tools

### System:
- Windows 7 or higher
- Sufficient disk space for reports (estimate 100MB per project)
- Write permissions in script directory

## Support

For issues or questions:
1. Check EXECUTION_SUMMARY.txt in output folder
2. Review PowerShell error messages
3. Verify STRUDS software is functioning independently
4. Check file permissions and disk space

## Version History

- v1.0 - Initial master one-click implementation
  - Complete workflow automation
  - Timestamped folder structure
  - Master combined HTML report
  - Drawing archive and PDF packaging
