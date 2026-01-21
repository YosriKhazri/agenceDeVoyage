@echo off
echo Extracting database from Android emulator...
echo.

set ADB_PATH=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe

echo Step 1: Copying database to accessible location...
%ADB_PATH% shell "run-as com.example.agence_de_voayage cp databases/travel_agency.db /data/local/tmp/travel_agency.db"

echo Step 2: Changing permissions...
%ADB_PATH% shell "chmod 666 /data/local/tmp/travel_agency.db"

echo Step 3: Pulling database to current directory...
%ADB_PATH% pull /data/local/tmp/travel_agency.db travel_agency.db

if exist travel_agency.db (
    echo.
    echo SUCCESS! Database extracted to: %CD%\travel_agency.db
    echo.
    echo You can now open it with:
    echo - DB Browser for SQLite (https://sqlitebrowser.org/)
    echo - Or Android Studio Database Inspector
) else (
    echo.
    echo ERROR: Failed to extract database
    echo Make sure the app is running on the emulator
)

pause

