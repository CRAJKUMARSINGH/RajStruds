# STRUDS Complete Workflow Guide

## Understanding STRUDS Execution

STRUDS is a GUI-based software that requires interactive operation. The automated script works best with files that have already been processed through STRUDS GUI.

## Recommended Workflow

### Option 1: Manual STRUDS Processing + Automated Report Collection (RECOMMENDED)

1. **Process files in STRUDS GUI:**
   - Open STRUDS (strudwin.exe)
   - Load each .bld file from Test_Input_files
   - Run Analysis (Menu → Analysis)
   - Run Design (Menu → Design)
   - Save revisions as needed
   - Generate reports (Menu → Reports)
   - Repeat for all files

2. **Run automated collection and organization:**
   ```powershell
   .\master_one_click.ps1 -SkipTests
   ```
   
   This will:
   - Collect all generated reports from Output folder
   - Organize by component type (Footings, Columns, Beams, Slabs)
   - Create master combined HTML report
   - Convert DXF to PDF
   - Package everything in FINAL_OUTPUT

### Option 2: Batch Processing with STRUDS Command Line (If Available)

If your STRUDS version supports command-line batch processing:

1. **Run full automation:**
   ```powershell
   .\master_one_click.ps1
   ```

2. **The script will:**
   - Process all .bld files through STRUDS executables
   - Run 5 iterations per file for optimization
   - Collect and organize all reports
   - Create combined outputs

### Option 3: Hybrid Approach

1. **Process a few files manually in STRUDS to verify setup**

2. **Use the script for collection:**
   ```powershell
   .\master_one_click.ps1 -SkipTests
   ```

3. **Review the organized output**

4. **Process remaining files in batches**

## STRUDS Iterative Design Process

### Standard STRUDS Workflow:
```
1. Open .bld file in strudwin.exe
2. Run Analysis (generates $$STRANA.SOL and other files)
3. Run Design (uses analysis results)
4. Review results
5. Modify design if needed
6. Save Revision (creates new .bld file)
7. Repeat steps 2-6 for optimization (typically 3-5 iterations)
8. Generate final reports and drawings
```

### What Each STRUDS Program Does:

**strudwin.exe** (Main GUI)
- Opens and edits .bld files
- Prepares analysis files
- Coordinates all operations
- Interactive design modifications

**strudana.exe** (Analysis Engine)
- Requires files prepared by strudwin.exe
- Performs structural analysis
- Creates $$STRANA.SOL file
- Calculates forces, moments, deflections

**design.exe** (Design Engine)
- Uses analysis results
- Performs RCC design calculations
- Determines reinforcement
- Checks code compliance

**postpro.exe** (Report Generator)
- Creates HTML reports
- Generates PDF documents
- Produces DXF/DWG drawings
- Creates schedules and details

## File Structure STRUDS Creates

```
Working Directory/
├── $$STRANA.SOL          ← Analysis solution file (required for design)
├── $$STRANA.LST          ← Analysis listing
├── $$DESIGN.DAT          ← Design data
├── MOD1.ERR              ← Error log
└── [filename].bld        ← Input file

Output/
└── [timestamp]/
    └── [filename]/
        ├── [filename]_analysis_report.html
        ├── [filename]_design_report.html
        ├── [filename]_rcc_design.txt
        └── [filename]_drawing.dwg
```

## Troubleshooting

### Error: "File $$STRANA.SOL not found"
**Cause:** Analysis hasn't been run yet or files not prepared properly

**Solution:**
1. Open file in strudwin.exe first
2. Run Analysis from menu
3. Then run design.exe or use automation script

### Error: "Execution order not proper"
**Cause:** Trying to run executables without GUI preparation

**Solution:**
- Use strudwin.exe to open and prepare files first
- OR use `-SkipTests` flag to only collect existing reports

### Error: "Analysis files list not found"
**Cause:** Working directory doesn't have required STRUDS files

**Solution:**
- Ensure you're running from STRUDS installation directory
- Check that .bld file is in correct location
- Verify STRUDS is properly installed

## Best Practices

### For Small Projects (1-10 files):
1. Process manually in STRUDS GUI
2. Use script for report collection and organization
3. Review combined output

### For Medium Projects (10-50 files):
1. Process first few files manually to verify setup
2. Use script with `-SkipTests` for organization
3. Process remaining files in batches
4. Run script after each batch

### For Large Projects (50+ files):
1. Set up template files in STRUDS
2. Process in batches of 10-20 files
3. Use script for collection after each batch
4. Combine all batches at end

## Command Reference

### Run full automation (if STRUDS supports batch):
```powershell
.\master_one_click.ps1
```

### Collect and organize existing reports only:
```powershell
.\master_one_click.ps1 -SkipTests
```

### Skip drawing conversion:
```powershell
.\master_one_click.ps1 -SkipTests -SkipDrawings
```

### Skip PDF packaging:
```powershell
.\master_one_click.ps1 -SkipTests -SkipReports
```

## Output Structure

After running the script, you'll find:

```
RAW_REPORT/[timestamp]/
└── Collected reports organized by file and component

FINAL_OUTPUT/[timestamp]/
├── MASTER_COMBINED_REPORT.html  ← Open this in browser!
├── EXECUTION_SUMMARY.txt
├── ALL_DRAWINGS_[timestamp].zip
├── Footings/
│   ├── Schedule/
│   ├── Design/
│   └── Drawings/
├── Columns/
├── Beams/
├── Slabs/
└── PDF_Package/
```

## Tips for Efficient Workflow

1. **Use STRUDS GUI for complex designs** - The GUI provides better control and visualization

2. **Use automation for report organization** - Let the script handle collection and organization

3. **Process similar files together** - Group files by building type or complexity

4. **Review first file completely** - Verify setup before processing entire batch

5. **Keep backups** - The script creates timestamped folders, so nothing is overwritten

6. **Check EXECUTION_SUMMARY.txt** - Review statistics after each run

7. **Open MASTER_COMBINED_REPORT.html** - Single point of access for all reports

## Support

For STRUDS software issues:
- Refer to STRUDS_Manual.chm
- Check STRUDS help files
- Contact STRUDS support

For automation script issues:
- Check EXECUTION_SUMMARY.txt
- Review error messages in console
- Verify file paths and permissions
- Ensure STRUDS has generated reports before collection
