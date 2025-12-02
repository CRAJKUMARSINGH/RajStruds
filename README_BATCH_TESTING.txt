STRUDS Software Batch Testing System
===================================

This system automates the testing of your STRUDS structural engineering software
using all input files in the Test_Input_files directory.

Features:
- Processes all .bld files in batch mode
- Generates analysis reports, design reports, RCC designs, and drawings
- Saves all output in timestamped folders for easy tracking
- Provides progress feedback during processing

Setup Instructions:
1. Ensure all required STRUDS executables are in the main directory
2. Verify that Test_Input_files directory contains all .bld files to be tested
3. Check that the Output directory exists (will be created automatically if missing)

Running the Batch Test:
1. Open PowerShell as Administrator
2. Navigate to the STRUDS directory:
   cd C:\Users\Rajkumar\RajStruds
3. Execute the batch testing script:
   .\batch_test.ps1

Output Structure:
- All results are saved in the Output directory
- Each run creates a timestamped folder (YYYYMMDD_HHMMSS format)
- Within each timestamped folder, there's a subfolder for each input file
- Each file's subfolder contains all generated reports and drawings

Customization:
To integrate with the actual STRUDS software:
1. Edit batch_test.ps1
2. Uncomment and modify the execution line:
   # & ".\strudwin.exe" "/input:Test_Input_files\$inputFile" "/output:$fileOutputFolder"
3. Adjust parameters according to the STRUDS command-line interface

Troubleshooting:
- If you receive execution policy errors, run:
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
- Ensure Windows PowerShell is being used (not PowerShell Core)
- Check that all file paths are correct and accessible