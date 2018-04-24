#AutoIt3Wrapper_Change2CUI=y

#include <Array.au3>
#include <StringConstants.au3>
#include <WinAPIHObj.au3>
#include <WinAPIProc.au3>

Local $aAdjust, $processes, $pids = 0
Local $pattern = $cmdline[1]
Local $wd = $cmdline[2] 

if $cmdline[0] = 0 then
    ConsoleWrite(@CRLF & "Usage: kill_by_wd.exe <pattern> <working directory>" & @CRLF)
    Exit
EndIf

ConsoleWrite(@CRLF)
ConsoleWrite("Search pattern: " & $pattern & @CRLF)
ConsoleWrite("Working directory: " & $wd & @CRLF)

; Enable "SeDebugPrivilege" privilege for obtain full access rights to another processes
Local $hToken = _WinAPI_OpenProcessToken(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
_WinAPI_AdjustTokenPrivileges($hToken, $SE_DEBUG_NAME, $SE_PRIVILEGE_ENABLED, $aAdjust)

$processes = ProcessList()
For $i = 2 To $processes[0][0] ;item at position 1 is "[System Process]"

    $process = $processes[$i][0]
    $pid = $processes[$i][1]
    $dir = _WinAPI_GetProcessWorkingDirectory($pid)
    $cmdline = _WinAPI_GetProcessCommandLine($pid) 

    if StringCompare($dir, $wd, 0) = 0 and StringInStr($cmdline, $pattern, 0) > 0 and StringCompare($process, @ScriptName, 0) <> 0 then
        
        ;ConsoleWrite(@CRLF & "Working directory: " & $dir)
        ;ConsoleWrite(@CRLF & "Command line: " & $cmdline)
        
        ConsoleWrite(@CRLF & "Attempting to kill process " & $process & " (" & $pid & "): ")
        
        ProcessClose($pid)

        if @error = 0 Then
            ConsoleWrite("Success")
        Else
            ConsoleWrite("Error: " & @error)
        EndIf
    EndIf
Next

_WinAPI_AdjustTokenPrivileges($hToken, $aAdjust, 0, $aAdjust)
_WinAPI_CloseHandle($hToken)

ConsoleWrite(@crlf)
_ArrayDisplay($pids, 'pids')
