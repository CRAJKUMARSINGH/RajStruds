# Download All Reports Script for STRUDS Software
# This script copies all generated reports to a single directory for easy access

# Get the most recent test run folder
$latestRun = Get-ChildItem "Output" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($null -eq $latestRun) {
    Write-Host "No test runs found in Output directory"
    exit 1
}

# Get the most recent reports folder
$latestReports = Get-ChildItem "Reports" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($null -eq $latestReports) {
    Write-Host "No reports found in Reports directory"
    exit 1
}

# Create a downloads directory
$downloadsDir = "Downloaded_Reports"
New-Item -ItemType Directory -Path $downloadsDir -Force | Out-Null

Write-Host "Downloading all reports to: $downloadsDir"

# Copy all reports from the latest test run (with force to overwrite)
Copy-Item -Path "$($latestRun.FullName)\*" -Destination $downloadsDir -Recurse -Force
Write-Host "Copied test results from: $($latestRun.Name)"

# Copy all consolidated reports (with force to overwrite)
Copy-Item -Path "$($latestReports.FullName)\*" -Destination $downloadsDir -Recurse -Force
Write-Host "Copied consolidated reports from: $($latestReports.Name)"

# Create a summary file
$summaryContent = "STRUDS Reports Download Summary`n"
$summaryContent += "=============================`n"
$summaryContent += "Downloaded on: $(Get-Date)`n"
$summaryContent += "Source test run: $($latestRun.Name)`n"
$summaryContent += "Source reports: $($latestReports.Name)`n"
$summaryContent += "`nFiles downloaded:`n"

Get-ChildItem -Recurse $downloadsDir | ForEach-Object {
    if ($_ -is [System.IO.FileInfo]) {
        $summaryContent += "- $($_.FullName.Replace($downloadsDir, ''))`n"
    }
}

$summaryContent > "$downloadsDir\DOWNLOAD_SUMMARY.txt"

Write-Host "Download complete!"
Write-Host "All reports have been copied to: $downloadsDir"
Write-Host "Summary file created: $downloadsDir\DOWNLOAD_SUMMARY.txt"