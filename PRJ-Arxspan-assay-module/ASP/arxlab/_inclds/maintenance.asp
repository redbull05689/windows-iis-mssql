<%
On Error Resume Next
Dim strDirectory, counter  
Dim objFSO, objFolder, objFile  
dim Maintenance
'directory to look in
strDirectory = "C:\Maintenance"
counter = 0  
Set objFSO = CreateObject("Scripting.FileSystemObject")  
Set objFolder = objFSO.GetFolder(strDirectory)  
counter = objFolder.Files.Count
Maintenance = false
if counter > 0 then
    Maintenance = true
end if 
%>