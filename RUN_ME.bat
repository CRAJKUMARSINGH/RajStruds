@echo off
REM ============================================================================
REM STRUDS MASTER ONE-CLICK AUTOMATION - QUICK LAUNCHER
REM ============================================================================

echo.
echo ============================================================================
echo  STRUDS MASTER ONE-CLICK AUTOMATION
echo ============================================================================
echo.
echo This will run the complete STRUDS automation workflow:
echo   1. Batch testing of all .bld files
echo   2. Report generation and collection
echo   3. DXF to PDF conversion
echo   4. Report organization and combination
echo   5. Final output packaging
echo.
echo Press Ctrl+C to cancel, or
pause

echo.
echo Starting automation...
echo.

powershell.exe -ExecutionPolicy Bypass -File ".\master_one_click.ps1"

echo.
echo ============================================================================
echo  AUTOMATION COMPLETE
echo ============================================================================
echo.
echo Check the FINAL_OUTPUT folder for results.
echo Open the MASTER_COMBINED_REPORT.html file in your browser.
echo.
pause
