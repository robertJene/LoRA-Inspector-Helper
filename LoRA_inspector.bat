@ECHO OFF

IF NOT EXIST "lora-inspector.py" (
  ECHO[
  ECHO File does not exist, or this batch was ran from another folder:
  ECHO lora-inspector.py
  ECHO[
  PAUSE
  GOTO endOfLine
)


IF NOT EXIST "LoRA_inspector_helper.vbs" (
  ECHO[
  ECHO File does not exist, or this batch was ran from another folder:
  ECHO LoRA_inspector_helper.vbs
  ECHO[
  PAUSE
  GOTO endOfLine
)


IF NOT EXIST "%UserProfile%\AppData\Local\RTools" MKDIR "%UserProfile%\AppData\Local\RTools"
IF EXIST "%UserProfile%\AppData\Local\RTools\Booted.txt" GOTO BOOTED

Start /Separate conhost LoRA_inspector.bat
> "%UserProfile%\AppData\Local\RTools\Booted.txt" ECHO booted
EXIT

:BOOTED
TITLE LoRA_inspector

Set folderPath=NULL


:ROOT
Set afterFolderAsk=ROOT
cls
ECHO[
ECHO LoRA inspector -^> ROOT MENU
ECHO[
ECHO LoRA path:
ECHO %folderPath%
ECHO[
ECHO f. Set/change the path to the LoRA file or folder with LoRA's
ECHO[
ECHO 1. Inspect (find the average weights)
ECHO 2. Inspect (find the average weights) ^> THEN EXIT SO YOU CAN COPY-PASTE
ECHO 3. Save Metadata to JSON file^(s^)
ECHO[

Set Choice=
Set /p Choice=Type the option and press enter (exit to quit): 

IF /I "%Choice%"=="exit" GOTO endOfLine

Set exitAfter=False

IF /I "%Choice%"=="f" GOTO rootGetFolderPath
IF /I "%Choice%"=="1" GOTO inspectLoras
IF /I "%Choice%"=="2" GOTO inspectLorasCheckExisting
IF /I "%Choice%"=="3" GOTO saveMetadataToFiles

ECHO[
ECHO "%Choice%" is invalid. Please try again.
ECHO[
PAUSE

GOTO ROOT


:rootGetFolderPath

cls
ECHO[
ECHO LoRA inspector -^> GET LORA PATH OR FOLDER WITH LoRA FILE^(S^)
ECHO[
ECHO Enter the full path to the Lora File, or the folder with LoRA files.
ECHO      ^*^*^*^*^* make sure there are no double-quotes! ^*^*^*^*^*
ECHO           enter x or ROOT to go to ROOT MENU
ECHO           enter exit to go to quit
ECHO[

Set /P Choice=: 

IF /I "%Choice%"=="x" GOTO ROOT
IF /I "%Choice%"=="root" GOTO ROOT
IF /I "%Choice%"=="exit" GOTO endOfLine

IF NOT EXIST "%Choice%" GOTO rootNofolderPath

Set folderPath=%Choice%
Set Choice=

GOTO %afterFolderAsk%

:rootNofolderPath
ECHO[
ECHO ERROR: Could not find a file or folder with this path:
ECHO %Choice%
Set Choice=
ECHO[
PAUSE
GOTO rootGetFolderPath
REM *****************************************************************************

REM ***** INSPECT LORAS *****
:inspectLorasCheckExisting
REM @ECHO ON
cls
ECHO[
ECHO LoRA inspector -^> INSPECT LORA^(s^)
ECHO[

set X=0

IF EXIST "LoRA_average_weights.txt" set /a X+=1
IF EXIST "LoRA_average_weights.csv" set /a X+=1
IF EXIST "LoRA_average_weights.bat" set /a X+=1

REM no previous files exist
IF "%X%"=="0" (
  Set X=
  Set exitAfter=True
  GOTO inspectLoras
)

ECHO ***** WARNING *****
ECHO[
IF "%X%"=="1" (
  ECHO 1 file exists from a previous run and will be deleted if you proceed:
) ELSE (
  ECHO %X% files exist from a previous run and will be deleted if you proceed:
)
ECHO[

IF EXIST "LoRA_average_weights.txt" ECHO LoRA_average_weights.txt
IF EXIST "LoRA_average_weights.csv" ECHO LoRA_average_weights.csv
IF EXIST "LoRA_average_weights.bat" ECHO LoRA_average_weights.txt

ECHO[

ECHO NOTE: If you don't want to delete the file(s), rename the file(s)
ECHO       that you want to keep before running this option.
ECHO[

Set YN=

REM IF "%X%"=="1" (
  Set /P YN=Do you want to delete the file(s) and continue? (Y/N, X = cancel, exit = quit): 
REM ) ELSE (
REM   Set /P YN=Do you want to delete the files and continue? (Y/N, X = cancel, exit = quit): 
REM )


ECHO[

IF /I "%YN%"=="Y" (
  DEL "LoRA_average_weights.*" /F /Q
  Set exitAfter=True
  GOTO inspectLoras
)

IF /I "%YN%"=="N" GOTO ROOT
IF /I "%YN%"=="X" GOTO ROOT

IF /I "%YN%"=="exit" GOTO endOfLine

ECHO[
ECHO "%YN$" is invalid. Please try again.
ECHO[
PAUSE
GOTO inspectLorasCheckExisting


PAUSE
GOTO ROOT






REM ***** INSPECT LORAS *****

:inspectLoras
Set afterFolderAsk=inspectLoras
cls
ECHO[
ECHO ECHO LoRA inspector -^> INSPECT LORA^(s^)
ECHO[
ECHO path:
ECHO %folderPath%
ECHO[


IF /I "%folderPath%"=="NULL" GOTO rootGetFolderPath
REM IF "%folderPath%"=="" GOTO rootGetFolderPath

IF "%exitAfter%"=="True" GOTO inspectLorasAskYN

:inspectLorasNow

CLS
ECHO[

python.exe "lora-inspector.py" -w "%folderPath%"
ECHO[
cscript.exe //NOLOGO LoRA_inspector_helper.vbs

ECHO[

IF "%exitAfter%"=="True" GOTO endOfLine

PAUSE

goto ROOT

:inspectLorasAskYN
cls

ECHO[
ECHO ***** NOTICE: THE SCRIPT TAKES AWHILE FOR MANY LoRA's, DO NOT CLOSE THIS WINDOW *****
ECHO[
ECHO       Instructions:
ECHO       1. Run this on a folder with LoRA files in it
ECHO       2. When it is done, press Ctr+A to select all, then Ctrl+C to copy
ECHO       3. Open LoRA_average_weights.txt and press Ctrl+V to paste
ECHO       4. Run LoRA_inspector_helper.vbs to create the CSV and batch file
ECHO[
ECHO       NOTE- if you don't have LoRA_average_weights.txt yet, simply
ECHO             run LoRA_inspector_helper.vbs to create it
ECHO[

Set YN=
Set /P YN=Are you sure you want to continue? (Y/N, X = cancel, exit = quit): 
ECHO[

IF /I "%YN%"=="Y" GOTO inspectLorasNow
IF /I "%YN%"=="N" GOTO ROOT
IF /I "%YN%"=="X" GOTO ROOT

IF /I "%YN%"=="exit" GOTO endOfLine

ECHO[
ECHO "%YN%" is invalid. Please try again.
ECHO[
PAUSE

GOTO inspectLorasAskYN



REM ***** SAVE METADATA TO FILES *****
:saveMetadataToFiles


Set afterFolderAsk=saveMetadataToFiles
cls
ECHO[
ECHO ECHO LoRA inspector -^> SAVE METADATA TO FILE^(S^)
ECHO[
ECHO path:
ECHO %folderPath%
ECHO[

IF /I "%folderPath%"=="NULL" GOTO rootGetFolderPath
IF "%folderPath%"=="" GOTO rootGetFolderPath

python.exe "lora-inspector.py" -s "%folderPath%"
ECHO[
@ECHO OFF
ECHO[
ECHO formatting JSON file^(s^)...
ECHO[
                      
cscript.exe //NOLOGO "LoRA_inspector_helper.vbs" 1
ECHO[
PAUSE

:saveMetadataToFilesAskMove
cls
ECHO[
ECHO ECHO LoRA inspector -^> metdadata saved -^> OPTION TO MOVE FILE^(S^)
ECHO[
ECHO ***** Now you have the option to move the file^(s^) *****
ECHO[
Set YN=
ECHO Do you want to move the formatted JSON file^(s^) to the LoRA folder,
ECHO and rename them to match the LoRA file^(s^)?
Set /P YN=Type the option and press enter (Y/N, X = cancel, exit = quit): 
ECHO[

IF /I "%YN%"=="Y" GOTO saveMetadataToFilesMoveTheFiles
IF /I "%YN%"=="N" GOTO ROOT
IF /I "%YN%"=="X" GOTO ROOT

IF /I "%YN%"=="exit" GOTO endOfLine

ECHO[
ECHO "%YN%" is invalid. Please try again.
ECHO[
PAUSE
GOTO saveMetadataToFilesAskMove

:saveMetadataToFilesMoveTheFiles
cls
ECHO[
ECHO ECHO LoRA inspector -^> metdadata saved -^> MOVING FILE^(S^)
ECHO[
cscript.exe //NOLOGO "LoRA_inspector_helper.vbs" "%folderPath%"
ECHO[
PAUSE

GOTO ROOT

:endOfLine
SET exitAfter=
SET YN=
SET Choice=
SET folderPath=
SET var=
SET valid=
SET count=
SET afterFolderAsk=
SET X=
@ECHO ON
CALL cmd.exe /k

