STRUDS COMPREHENSIVE REPORTING SYSTEM
==================================

This system generates comprehensive reports from STRUDS software test results, organizing them by structural elements and providing multiple output formats.

FEATURES:
- Combines HTML reports sorted by structural elements (Footings, Columns, Beams, Slabs)
- Adds sorting levels (Schedule, Design)
- Generates PDF reports for each structural element
- Creates a combined report with all HTML and PDF files
- Archives all drawing files in a single ZIP file

USAGE INSTRUCTIONS:
1. Ensure you have run the batch testing system first (batch_test.ps1)
2. Run the comprehensive reporting script:
   powershell -ExecutionPolicy Bypass -File .\generate_comprehensive_report.ps1
3. Find the generated reports in the Reports\[timestamp] directory

OUTPUT FILES:
- comprehensive_report.html: Main HTML report with all structural elements
- compact_report.html: Navigation page linking to all reports
- combined_report.pdf: Combined PDF of all structural element reports
- Individual PDFs: footings.pdf, columns.pdf, beams.pdf, slabs.pdf
- all_drawings.zip: Archive containing all drawing files

STRUCTURE:
The reports are organized by:
1. Structural Elements:
   - Footings
   - Columns
   - Beams
   - Slabs
2. Sorting Levels:
   - Schedule
   - Design

CUSTOMIZATION:
To integrate with actual STRUDS report data:
1. Modify the script to parse actual report files instead of generating sample data
2. Update the element detection logic to identify structural elements from report content
3. Implement actual HTML to PDF conversion using tools like wkhtmltopdf

REQUIREMENTS:
- Windows PowerShell 3.0 or later
- .NET Framework 4.5 or later (for ZIP archive creation)