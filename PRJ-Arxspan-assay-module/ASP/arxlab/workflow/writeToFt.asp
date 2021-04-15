<%
preSetKey = "seashellsbytheseashore"

sentKey = Request.ServerVariables("http_arxspankey")
if sentKey <> preSetKey then
    response.write "{""result"": ""failure""}"
    response.end
end if

folderName = "inbox-ft"
folderLocation = Replace("C:\{folderName}\", "{folderName}", folderName)
data = Request.Form("data")

fileName = Replace("{guid}.json", "{guid}", CreateGUID)
WriteToFile folderLocation, fileName, data

response.write "{""result"": ""success""}"
response.end

' This function will return a plain GUID, e.g., 47BC69BD-06A5-4617-B730-B644DBCD40A9.
Function CreateGUID
  Dim TypeLib
  Set TypeLib = CreateObject("Scriptlet.TypeLib")
  CreateGUID = Mid(TypeLib.Guid, 2, 36)
End Function

Function WriteToFile(folderLoc, fileName, contents)
    set fs=Server.CreateObject("Scripting.FileSystemObject")
    set tfile=fs.OpenTextFile(folderLoc & fileName, 8, true, -1)
    tfile.WriteLine(contents)
    tfile.close
    set tfile=nothing
    set fs=Nothing
End Function

%>