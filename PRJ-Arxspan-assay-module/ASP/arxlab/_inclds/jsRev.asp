<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
'This looks for a file on the root and reads the jsRev from it. 
'NOTE: This is set by CICD.
'NOTE: CICD puts the commit ID in the file. 
rootPath = getCompanySpecificSingleAppConfigSetting("rootPath", session("companyId"))
set fs=Server.CreateObject("Scripting.FileSystemObject")
On Error Resume Next
set t=fs.OpenTextFile(rootPath & "\jsRev.txt",1)
jsRev = t.ReadAll
t.Close
set t=fs.OpenTextFile(rootPath & "\branchRef.txt",1)
branchRef = t.ReadAll
t.Close
jsRev = Left(jsRev,10)
If Err.Number <> 0 or jsRev = "" Then
jsRev = "DEV"
End If
%>