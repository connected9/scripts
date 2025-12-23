@echo off
:: Force elevation if not running as Administrator
:: This block will re-launch the script with admin rights

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

setlocal enabledelayedexpansion
title System Maintenance and Repair Utility
color 0A

@echo off
setlocal enabledelayedexpansion
title System Maintenance and Repair Utility
color 0A

:: Check for administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    color 0C
    echo.
    echo ═══════════════════════════════════════════════════════════════
    echo   ERROR: Administrator privileges required!
    echo ═══════════════════════════════════════════════════════════════
    echo.
    echo   This script must be run as Administrator.
    echo   Right-click and select "Run as Administrator"
    echo.
    pause
    exit /b 1
)

:: Create log directory
set "LOG_DIR=%SystemDrive%\SystemMaintenance_Logs"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
set "LOG_FILE=%LOG_DIR%\maintenance_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.log"
set "LOG_FILE=%LOG_FILE: =0%"

:: Initialize variables
set TOTAL_STEPS=6
set CURRENT_STEP=0

:: Display header
cls
call :print_header

:: Log start time
echo [%date% %time%] System Maintenance Script Started >> "!LOG_FILE!"
echo. >> "!LOG_FILE!"

:: ═══════════════════════════════════════════════════════════════
:: STEP 1: DISM Component Cleanup
:: ═══════════════════════════════════════════════════════════════
set /a CURRENT_STEP=1
call :print_step_header "DISM - Component Store Cleanup" %CURRENT_STEP% %TOTAL_STEPS%
echo   Command: DISM /Online /Cleanup-Image /StartComponentCleanup
echo   This will clean up superseded components
echo.
echo   ► RUNNING - Please wait, this may take several minutes...
echo   ► Watch the output below for real-time progress
echo.
echo ───────────────────────────────────────────────────────────────
echo [%date% %time%] Starting DISM Component Cleanup >> "!LOG_FILE!"

DISM /Online /Cleanup-Image /StartComponentCleanup /NoRestart 2>&1 | powershell -NoProfile -Command "$input | Tee-Object -FilePath '!LOG_FILE!' -Append"
set DISM_CLEANUP_RESULT=%errorlevel%
echo ───────────────────────────────────────────────────────────────
echo.

if %DISM_CLEANUP_RESULT% equ 0 (
    call :print_success "Component cleanup completed successfully"
    echo [%date% %time%] DISM Cleanup completed successfully >> "!LOG_FILE!"
) else (
    call :print_error "Component cleanup failed (Exit Code: %DISM_CLEANUP_RESULT%)"
    echo [%date% %time%] DISM Cleanup failed with exit code: %DISM_CLEANUP_RESULT% >> "!LOG_FILE!"
)
call :print_progress %CURRENT_STEP% %TOTAL_STEPS%
timeout /t 2 /nobreak >nul

:: ═══════════════════════════════════════════════════════════════
:: STEP 2: DISM ScanHealth
:: ═══════════════════════════════════════════════════════════════
set /a CURRENT_STEP=2
call :print_step_header "DISM - Scan Health" %CURRENT_STEP% %TOTAL_STEPS%
echo   Command: DISM /Online /Cleanup-Image /ScanHealth
echo   This will scan for component store corruption
echo.
echo   ► RUNNING - Please wait, this may take several minutes...
echo   ► Watch the output below for real-time progress
echo.
echo ───────────────────────────────────────────────────────────────
echo [%date% %time%] Starting DISM ScanHealth >> "!LOG_FILE!"

DISM /Online /Cleanup-Image /ScanHealth /NoRestart 2>&1 | powershell -NoProfile -Command "$input | Tee-Object -FilePath '!LOG_FILE!' -Append"
set DISM_SCAN_RESULT=%errorlevel%
echo ───────────────────────────────────────────────────────────────
echo.

if %DISM_SCAN_RESULT% equ 0 (
    call :print_success "Health scan completed successfully"
    echo [%date% %time%] DISM ScanHealth completed successfully >> "!LOG_FILE!"
) else (
    call :print_error "Health scan failed (Exit Code: %DISM_SCAN_RESULT%)"
    echo [%date% %time%] DISM ScanHealth failed with exit code: %DISM_SCAN_RESULT% >> "!LOG_FILE!"
)
call :print_progress %CURRENT_STEP% %TOTAL_STEPS%
timeout /t 2 /nobreak >nul

:: ═══════════════════════════════════════════════════════════════
:: STEP 3: DISM CheckHealth
:: ═══════════════════════════════════════════════════════════════
set /a CURRENT_STEP=3
call :print_step_header "DISM - Check Health" %CURRENT_STEP% %TOTAL_STEPS%
echo   Command: DISM /Online /Cleanup-Image /CheckHealth
echo   This will check for component store corruption flags
echo.
echo   ► RUNNING - Please wait, this may take several minutes...
echo   ► Watch the output below for real-time progress
echo.
echo ───────────────────────────────────────────────────────────────
echo [%date% %time%] Starting DISM CheckHealth >> "!LOG_FILE!"

DISM /Online /Cleanup-Image /CheckHealth /NoRestart 2>&1 | powershell -NoProfile -Command "$input | Tee-Object -FilePath '!LOG_FILE!' -Append"
set DISM_CHECK_RESULT=%errorlevel%
echo ───────────────────────────────────────────────────────────────
echo.

if %DISM_CHECK_RESULT% equ 0 (
    call :print_success "Health check completed successfully"
    echo [%date% %time%] DISM CheckHealth completed successfully >> "!LOG_FILE!"
) else (
    call :print_error "Health check failed (Exit Code: %DISM_CHECK_RESULT%)"
    echo [%date% %time%] DISM CheckHealth failed with exit code: %DISM_CHECK_RESULT% >> "!LOG_FILE!"
)
call :print_progress %CURRENT_STEP% %TOTAL_STEPS%
timeout /t 2 /nobreak >nul

:: ═══════════════════════════════════════════════════════════════
:: STEP 4: DISM RestoreHealth
:: ═══════════════════════════════════════════════════════════════
set /a CURRENT_STEP=4
call :print_step_header "DISM - Restore Health" %CURRENT_STEP% %TOTAL_STEPS%
echo   Command: DISM /Online /Cleanup-Image /RestoreHealth
echo   This will repair component store corruption
echo.
echo   ► RUNNING - Please wait, this may take 15-30 minutes...
echo   ► Watch the output below for real-time progress
echo.
echo ───────────────────────────────────────────────────────────────
echo [%date% %time%] Starting DISM RestoreHealth >> "!LOG_FILE!"

DISM /Online /Cleanup-Image /RestoreHealth /NoRestart 2>&1 | powershell -NoProfile -Command "$input | Tee-Object -FilePath '!LOG_FILE!' -Append"
set DISM_RESTORE_RESULT=%errorlevel%
echo ───────────────────────────────────────────────────────────────
echo.

if %DISM_RESTORE_RESULT% equ 0 (
    call :print_success "Health restoration completed successfully"
    echo [%date% %time%] DISM RestoreHealth completed successfully >> "!LOG_FILE!"
) else (
    call :print_error "Health restoration failed (Exit Code: %DISM_RESTORE_RESULT%)"
    echo [%date% %time%] DISM RestoreHealth failed with exit code: %DISM_RESTORE_RESULT% >> "!LOG_FILE!"
)
call :print_progress %CURRENT_STEP% %TOTAL_STEPS%
timeout /t 2 /nobreak >nul

:: ═══════════════════════════════════════════════════════════════
:: STEP 5: System File Checker
:: ═══════════════════════════════════════════════════════════════
set /a CURRENT_STEP=5
call :print_step_header "SFC - System File Checker" %CURRENT_STEP% %TOTAL_STEPS%
echo   Command: SFC /scannow
echo   This will scan and repair system files
echo.
echo   ► RUNNING - Please wait, this may take 10-20 minutes...
echo   ► Watch the output below for real-time progress
echo.
echo ───────────────────────────────────────────────────────────────
echo [%date% %time%] Starting SFC >> "!LOG_FILE!"

SFC /scannow 2>&1 | powershell -NoProfile -Command "$input | Tee-Object -FilePath '!LOG_FILE!' -Append"
set SFC_RESULT=%errorlevel%
echo ───────────────────────────────────────────────────────────────
echo.

if %SFC_RESULT% equ 0 (
    call :print_success "System file check completed successfully"
    echo [%date% %time%] SFC completed successfully >> "!LOG_FILE!"
) else (
    call :print_error "System file check completed with warnings (Exit Code: %SFC_RESULT%)"
    echo [%date% %time%] SFC completed with exit code: %SFC_RESULT% >> "!LOG_FILE!"
)
call :print_progress %CURRENT_STEP% %TOTAL_STEPS%
timeout /t 2 /nobreak >nul

:: ═══════════════════════════════════════════════════════════════
:: STEP 6: CHKDSK (Final Step - Requires Reboot)
:: ═══════════════════════════════════════════════════════════════
set /a CURRENT_STEP=6
call :print_step_header "CHKDSK - Disk Check and Repair (FINAL STEP)" %CURRENT_STEP% %TOTAL_STEPS%
echo   Command: CHKDSK C: /F /V /R /offlinescanandfix
echo   This will scan and fix disk errors (REQUIRES RESTART)
echo.
echo   WARNING: This command will schedule a disk check on next reboot.
echo            The system will need to restart to complete this operation.
echo.
echo ───────────────────────────────────────────────────────────────
echo [%date% %time%] Starting CHKDSK >> "!LOG_FILE!"

CHKDSK C: /F /V /R /offlinescanandfix 2>&1 | powershell -NoProfile -Command "$input | Tee-Object -FilePath '!LOG_FILE!' -Append"
set CHKDSK_RESULT=%errorlevel%
echo ───────────────────────────────────────────────────────────────
echo.

if %CHKDSK_RESULT% equ 0 (
    call :print_success "CHKDSK scheduled successfully"
    echo [%date% %time%] CHKDSK scheduled successfully (Exit Code: %CHKDSK_RESULT%) >> "!LOG_FILE!"
) else (
    call :print_warning "CHKDSK exit code: %CHKDSK_RESULT%"
    echo [%date% %time%] CHKDSK completed with exit code: %CHKDSK_RESULT% >> "!LOG_FILE!"
)
call :print_progress %CURRENT_STEP% %TOTAL_STEPS%

:: ═══════════════════════════════════════════════════════════════
:: Summary
:: ═══════════════════════════════════════════════════════════════
echo.
echo.
echo ═══════════════════════════════════════════════════════════════
echo   MAINTENANCE SUMMARY
echo ═══════════════════════════════════════════════════════════════
echo.
call :print_result "DISM Component Cleanup" %DISM_CLEANUP_RESULT%
call :print_result "DISM ScanHealth" %DISM_SCAN_RESULT%
call :print_result "DISM CheckHealth" %DISM_CHECK_RESULT%
call :print_result "DISM RestoreHealth" %DISM_RESTORE_RESULT%
call :print_result "System File Checker" %SFC_RESULT%
call :print_result "CHKDSK (Scheduled)" %CHKDSK_RESULT%
echo.
echo ───────────────────────────────────────────────────────────────
echo   Log file saved to:
echo   %LOG_FILE%
echo ───────────────────────────────────────────────────────────────
echo.

:: Log completion
echo. >> "!LOG_FILE!"
echo [%date% %time%] System Maintenance Script Completed >> "!LOG_FILE!"

:: Prompt for restart
echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║                                                               ║
echo ║                    RESTART REQUIRED                           ║
echo ║                                                               ║
echo ║  CHKDSK has been scheduled and requires a system restart      ║
echo ║  to complete the disk check and repair process.               ║
echo ║                                                               ║
echo ║  The disk check will run automatically on next boot and       ║
echo ║  may take 30 minutes to several hours depending on disk size. ║
echo ║                                                               ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
echo   Would you like to restart now?
echo.
echo   [Y] Yes - Restart now and run CHKDSK
echo   [N] No  - Restart later manually
echo.

choice /C YN /N /M "   Your choice: "

if errorlevel 2 (
    echo.
    echo   Restart postponed. Please restart your computer manually
    echo   to complete the CHKDSK operation.
    echo.
    echo [%date% %time%] User chose to restart later >> "!LOG_FILE!"
    pause
    exit /b 0
)

if errorlevel 1 (
    echo.
    echo   Restarting system in 10 seconds...
    echo   Press Ctrl+C to cancel.
    echo.
    echo [%date% %time%] System restart initiated by user >> "!LOG_FILE!"
    timeout /t 10
    shutdown /r /t 0 /c "System Maintenance - CHKDSK scheduled"
    exit /b 0
)

color 0A
pause
exit /b 0

:: ═══════════════════════════════════════════════════════════════
:: FUNCTIONS
:: ═══════════════════════════════════════════════════════════════

:print_header
cls
echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║                                                               ║
echo ║     SYSTEM MAINTENANCE AND REPAIR UTILITY v2.1                ║
echo ║                                                               ║
echo ║     This script will perform comprehensive system             ║
echo ║     diagnostics and repairs with LIVE OUTPUT.                 ║
echo ║                                                               ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
goto :eof

:print_step_header
cls
echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║  STEP %~2/%~3: %~1
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
goto :eof

:print_progress
set /a percent=(%~1*100)/%~2
set /a bars=%~1*50/%~2
set "progress_bar="
for /l %%i in (1,1,%bars%) do set "progress_bar=!progress_bar!█"
set /a remaining=50-%bars%
for /l %%i in (1,1,%remaining%) do set "progress_bar=!progress_bar!░"

echo.
echo   Total Progress: [!progress_bar!] %percent%%%
echo.
goto :eof

:print_success
color 0A
echo   [✓] %~1
goto :eof

:print_error
color 0C
echo   [✗] %~1
color 0A
goto :eof

:print_warning
color 0E
echo   [!] %~1
color 0A
goto :eof

:print_result
if %~2 equ 0 (
    echo   [✓] %~1: SUCCESS
) else (
    echo   [✗] %~1: FAILED ^(Exit Code: %~2^)
)
goto :eof