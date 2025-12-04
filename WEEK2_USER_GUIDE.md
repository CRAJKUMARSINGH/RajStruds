# Week 2 User Guide

## Welcome to the Enhanced STRUDS Automation System!

Week 2 brings major improvements to make your workflow faster and easier.

---

## 🆕 What's New

### 1. Drag-and-Drop File Upload
No more manual file copying! Just drag your .bld files and drop them.

### 2. Color-Coded Logs
Errors are red, warnings are yellow, success is green. Easy to spot issues!

### 3. Job History
See all your past jobs, filter by status, and track statistics.

### 4. Persistent Storage
Jobs are saved to database. Server restarts won't lose your data!

---

## 📖 Quick Start

### Step 1: Upload Files

**Option A: Drag and Drop**
1. Open http://localhost:5000
2. Drag .bld files from your folder
3. Drop them on the upload zone
4. Click "Upload All"

**Option B: Browse Files**
1. Click "Browse Files" button
2. Select .bld files
3. Click "Upload All"

**Result:** Files are automatically copied to Test_Input_files folder!

### Step 2: Start Processing

1. Click "Start Batch Run" button
2. Watch the color-coded logs:
   - 🔵 Blue = Information
   - ✅ Green = Success
   - ⚠️ Yellow = Warning
   - ❌ Red = Error
3. See progress bar update in real-time
4. Wait for completion

### Step 3: View Results

1. When complete, download your reports
2. All output files are available
3. Statistics are displayed

### Step 4: Check Job History

1. Click "History" button in the header
2. See all your past jobs
3. Filter by status:
   - All jobs
   - Complete
   - Error
   - Running
4. View statistics for each job

---

## 🎨 Understanding the Color-Coded Logs

### Blue (Info) 🔵
```
[10:30:00] Processing file...
[10:30:01] Launching PowerShell script...
```
**Meaning:** Normal information, everything is working

### Green (Success) ✅
```
[10:30:05] ✓ PowerShell script completed successfully
[10:30:06] Complete
```
**Meaning:** Operation succeeded, all good!

### Yellow (Warning) ⚠️
```
[10:30:03] WARNING: Beam B23 exceeds deflection limits
```
**Meaning:** Not critical, but needs attention

### Red (Error) ❌
```
[10:30:04] ERROR: Foundation F4 failing in bearing capacity
```
**Meaning:** Critical issue, needs immediate attention

---

## 📊 Job History Features

### View All Jobs
- See every job you've run
- Jobs are saved permanently
- Survives server restarts

### Filter by Status
- **All:** See everything
- **Complete:** Only successful jobs
- **Error:** Only failed jobs
- **Running:** Currently processing

### Job Information
Each job shows:
- Job ID (e.g., PS-1733234567890)
- Status badge (Complete, Error, Running)
- Start time and date
- Duration
- Files processed (e.g., 10/10)
- Statistics:
  - HTML Reports generated
  - PDF Reports generated
  - DXF Drawings generated
- Error count
- Warning count

### Real-Time Updates
- Job history refreshes every 5 seconds
- See running jobs update live
- No need to refresh page

---

## 💡 Tips and Tricks

### Tip 1: Upload Multiple Files at Once
You can upload up to 50 files at once. Just select them all!

### Tip 2: Watch for Red Logs
If you see red logs, scroll up to find the error details.

### Tip 3: Check Job History
Before starting a new job, check history to see if you've already processed these files.

### Tip 4: Filter Errors
In Job History, click "Error" tab to quickly find failed jobs.

### Tip 5: Use the Statistics
The statistics tell you exactly what was generated:
- HTML Reports = Design reports
- PDF Reports = Converted reports
- DXF Drawings = CAD drawings

---

## 🔧 Troubleshooting

### Problem: Files Won't Upload
**Solution:**
1. Check file extension (.bld only)
2. Check file size (max 50MB per file)
3. Try uploading fewer files at once

### Problem: Can't See Logs
**Solution:**
1. Logs appear when processing starts
2. Make sure you clicked "Start Batch Run"
3. Check browser console for errors

### Problem: Job History is Empty
**Solution:**
1. Run at least one job first
2. Wait for job to complete
3. Click "History" button
4. If still empty, check server logs

### Problem: Server Restarted, Lost Jobs
**Solution:**
Don't worry! Jobs are saved to database.
1. Restart server
2. Click "History"
3. All jobs are still there ✅

---

## 📱 Keyboard Shortcuts

- **Tab:** Navigate between fields
- **Enter:** Start processing (when button is focused)
- **Esc:** Cancel file selection

---

## 🎯 Best Practices

### Before Processing
1. ✅ Upload files first
2. ✅ Check file list
3. ✅ Verify file count
4. ✅ Click "Start Batch Run"

### During Processing
1. ✅ Watch the logs
2. ✅ Look for red errors
3. ✅ Note any warnings
4. ✅ Wait for completion

### After Processing
1. ✅ Check statistics
2. ✅ Download reports
3. ✅ Review any errors
4. ✅ Check job history

---

## 📈 Understanding Statistics

### HTML Reports
Number of HTML design reports generated.
- Typical: 100-200 per job
- Includes: Design reports, schedules, summaries

### PDF Reports
Number of PDF reports generated.
- Typical: 50-100 per job
- Includes: Converted HTML reports

### DXF Drawings
Number of DXF CAD drawings generated.
- Typical: 40-80 per job
- Includes: Foundation, column, beam, slab details

---

## 🚀 Advanced Features

### Concurrent Jobs
You can run multiple jobs at the same time!
1. Start first job
2. Upload more files
3. Start second job
4. Both run in parallel

### Job Filtering
Use filters to find specific jobs:
- **Complete:** Find successful jobs
- **Error:** Find failed jobs
- **Running:** See active jobs

### Search (Coming Soon)
Search jobs by:
- Job ID
- Date range
- File names
- Error messages

---

## 📞 Getting Help

### Check the Logs
Logs tell you exactly what's happening. Look for:
- Error messages (red)
- Warning messages (yellow)
- Success messages (green)

### Check Job History
See if similar jobs succeeded or failed before.

### Check Documentation
- WEEK2_QUICK_START.md - Quick start guide
- WEEK2_IMPLEMENTATION_SUMMARY.md - Technical details
- WEEK2_COMPLETE.md - Feature list

---

## 🎉 Enjoy the New Features!

Week 2 makes STRUDS automation:
- ⚡ Faster (drag-and-drop upload)
- 👁️ Clearer (color-coded logs)
- 📊 Trackable (job history)
- 💾 Reliable (persistent storage)

**Happy processing!** 🚀

---

## Quick Reference Card

### File Upload
```
Drag files → Drop → Upload All → Done!
```

### Start Processing
```
Upload files → Start Batch Run → Watch logs → Download results
```

### View History
```
Click "History" → Filter by status → View job details
```

### Understand Logs
```
🔵 Blue = Info
✅ Green = Success
⚠️ Yellow = Warning
❌ Red = Error
```

---

**Version:** Week 2 Complete  
**Date:** December 4, 2025  
**Status:** Production Ready ✅
