
Dim filesys
Set filesys = CreateObject("Scripting.FileSystemObject")
If WScript.Arguments.Count = 0 Then

  If Not filesys.FileExists("LoRA_average_weights.txt") Then

    Set filetxt = filesys.CreateTextFile("LoRA_average_weights.txt", True)
    
    WScript.Echo "NOTE: LoRA_average_weights.txt was just created." & vbCrlf & _
                  "      copy-paste the results of the inspection into it, and then save it." & vbCrlf & _
                  "      after that, run this script file again."
    WScript.Quit

  '***** This is the 3rd way to use this script, to have it parse the contents of LoRA_average_weights.txt and display it
  Else

    X = int(0)
    Set objFile = filesys.OpenTextFile("LoRA_average_weights.txt", 1, False)

    Set filetxt = filesys.CreateTextFile("LoRA_average_weights.bat", True)
    Set filetxtCSV = filesys.CreateTextFile("LoRA_average_weights.csv", True)


    filetxtCSV.WriteLine("LoRA filename," & _
	"UNet attention weight average magnitude," & _
	"UNet attention weight average strength," & _
	"Text Encoder weight average magnitude," & _
	"Text Encoder weight average strength")


    filetxt.WriteLine("@ECHO OFF")
    filetxt.WriteLine()


    filetxt.WriteLine("ECHO[")


    csvToPut = "NULL"

    Do Until objFile.AtEndOfStream
        line = objFile.ReadLine
        If filesys.FileExists(line) Then
          fileName = filesys.GetFileName(line)
          csvToPut = fileName
          UNETWAM = "NULL"
          UNETWAS = "NULL"
          TEWAM = "NULL"
          TEWAS = "NULL"
          

          X = X + 1
          If X > 1 Then
            filetxt.WriteLine("ECHO ----------------------")
          End If
          filetxt.WriteLine("ECHO " & fileName)
        End If



      If instr(lCase(line), "unet weight average magnitude") Then

        parts = split(line, ": ")
        csvToPut = csvToPut & "," & parts(1)
        filetxt.WriteLine("ECHO " & parts(0) & vbTab & parts(1))

      ElseIf instr(lCase(line), "unet weight average strength") Then

        parts = split(line, ": ")
        csvToPut = csvToPut & "," & parts(1)
        filetxt.WriteLine("ECHO " & parts(0) & vbTab & parts(1))

      ElseIf instr(lCase(line), "text encoder") Then
 
        If instr(lCase(line), "weight average magnitude") Then

          parts = split(line, ": ")
          csvToPut = csvToPut & "," & parts(1)
          filetxt.WriteLine("ECHO " & parts(0) & vbTab & parts(1))

        ElseIf instr(lCase(line), "weight average strength") Then

          parts = split(line, ": ")
          csvToPut = csvToPut & "," & parts(1)
          filetxt.WriteLine("ECHO " & parts(0) & vbTab & parts(1))

        filetxtCSV.WriteLine(csvToPut)


        End If


      End If

    Loop

    objFile.Close

    filetxtCSV.Close

    filetxt.WriteLine("ECHO ----------------------")
    filetxt.WriteLine("ECHO[")
    filetxt.WriteLine("PAUSE")
    filetxt.WriteLine()

    filetxt.Close

    CreateObject("Wscript.Shell").Run "LoRA_average_weights.bat", 1, False

    wscript.quit

  End If


End If

Dim method, cd, folderPath, folder, files, file, jsonData, objFile


cd = filesys.GetAbsolutePathName(".")

folderPath = cd & "\meta"

method = WScript.Arguments(0)


' Check if the folder exists
If Not fileSys.FolderExists(folderPath) Then
    WScript.Echo "ERROR: The meta folder does not exist" & vbCrlf _
               & vbTab & "This script is used by option 2 in the LoRA_Inspector batch file"
    WScript.Quit
End If


' method 1 is to use the json formatter, otherwise the folder path to move the JSON files to is provided


' ***** OPTION 2 STUFF IS HERE TO MOVE THE FILES *****
If method <> "1" Then

  loraPath = WScript.Arguments(0)

  ' Get a reference to the folder with the script's outputs of json files
  Set folder = filesys.GetFolder(folderPath)
  
  ' Get the collection of JSON files in the folder
  Set files = folder.Files


  'A folder was passed to the script
  If filesys.FolderExists(loraPath) Then
    ' Get a reference to the folder where the LoRA files are
    Set loraFolder = filesys.GetFolder(loraPath)
  
    ' Get the collection of LoRA safetensors files
    Set loraFiles = loraFolder.Files
  
    Y = int(0)
    For Each loraFile in loraFiles
      If LCase(filesys.GetExtensionName(loraFile.Name)) = "safetensors" Then
        Y = Y + 1
      End If
    Next
  
    X = int(0)
    For Each loraFile in loraFiles

      If LCase(filesys.GetExtensionName(loraFile.Name)) = "safetensors" Then
        X = X + 1     
        wscript.echo "[" & X & " of " & Y & "] " & loraFile.Name & ".json"

        moveLoraFile loraFile.Name, loraPath

      End If

    Next

  'A single file was passed to the script
  ElseIf filesys.FileExists(loraPath) Then

    Set loraFile = filesys.GetFile(loraPath)
    wscript.echo "[1 of 1] " & loraFile.Name & ".json"

    loraFolder = loraFile.ParentFolder.Path

    moveLoraFile loraFile.Name, loraFolder

  End If

    wscript.quit
End If

' ***** OPTION 1 STUFF IS BELOW TO FORMAT THE JSON FILES *****


Set jsonObj = CreateObject("Scripting.Dictionary")
Set json = CreateObject("Scripting.Dictionary")

' Get a reference to the folder with the script's outputs of json files
Set folder = filesys.GetFolder(folderPath)

' Get the collection of JSON files in the folder
Set files = folder.Files

Y = int(0)
For Each file in files
    If LCase(fileSys.GetExtensionName(file.Name)) = "json" Then
        Y = Y + 1
    End If
Next

' Check if there are no JSON files in the folder
If Y = 0 Then
    WScript.Echo "ERROR: There are no JSON files in the folder" & vbCrlf _
               & vbTab & "This script is used by option 2 in the LoRA_Inspector batch file"
    WScript.Quit
End If



X = int(0)
For Each file in files
  If LCase(filesys.GetExtensionName(file.Name)) = "json" Then
    X = X + 1

    wscript.echo "[" & X & " of " & Y & "] " & file.Name
    ' Open the file for reading
    Set objFile = filesys.OpenTextFile(file.Path)

    ' Read the contents of the file
    jsonData = objFile.ReadAll
    If InStr(jsonData, vbCrLf) Then
      wscript.echo vbTab & "Skipped, already contains carriage returns"
    Else
      formattedJson = FormatJson(jsonData)

      ' Close the file
      objFile.Close

      wscript.sleep(1000)

      Set filetxt = filesys.CreateTextFile(file.Path, True)
      filetxt.WriteLine(formattedJson)
      filetxt.Close
      wscript.echo vbTab & "JSON has been formatted"

    End If

  End If
Next

objFile.Close

wscript.quit



' Function to format the JSON data with carriage returns and tabs
Function FormatJson(jsonData)
    Dim formattedJson
    Dim x
    Dim i

    x = 0 ' Number of tabs for indentation
    formattedJson = "" ' Formatted JSON string

    For i = 1 To Len(jsonData)
        Dim currentChar
        currentChar = Mid(jsonData, i, 1)

        If currentChar = "{" Then
            formattedJson = formattedJson & vbCrLf & String(x, vbTab) & currentChar & vbCrLf & String(x + 1, vbTab)
            x = x + 1
        ElseIf currentChar = "}" Then
            formattedJson = formattedJson & vbCrLf & String(x - 1, vbTab) & currentChar
            x = x - 1
        ElseIf currentChar = "," Then
            formattedJson = formattedJson & currentChar & vbCrLf & String(x, vbTab)
        Else
            formattedJson = formattedJson & currentChar
        End If
    Next

    FormatJson = formattedJson
End Function



' Clean up the dictionary objects
Set jsonObj = Nothing
Set json = Nothing

Sub moveLoraFile(loraFileName, destinationFolder)

        For Each file in files

          If Len(file.name) > Len(loraFileName) Then
            If loraFileName = Left(file.name, Len(loraFileName)) Then
  
              message = "JSON file has been moved"

  
              If filesys.FileExists(destinationFolder & "\" & loraFileName & ".json") Then

                On Error Resume Next
                filesys.DeleteFile(destinationFolder & "\" & loraFileName & ".json")
                If Err.Number <> 0 Then
                   message = "ERROR: NOT ABLE TO DELETE EXISTING FILE. Error #" & Err.Number & vbCrlf & _
                              vbTab & Err.Description
                   Err.Clear
                   On Error GoTo 0
                Else
                  message = message & " " & chr(40) & "existing file was replaced" & chr(41)
                End If

                wscript.sleep(1000)
              End If

          
              On Error Resume Next
              filesys.MoveFile file, destinationFolder & "\" & loraFileName & ".json"
              If Err.Number <> 0 Then
                   message = "ERROR: NOT ABLE TO COPY FILE. Error #" & Err.Number & vbCrlf & _
                              vbTab & Err.Description
                 Err.Clear
                 On Error GoTo 0
              End If

              wscript.Echo vbTab & message


            End If
          End If

        Next


End Sub
