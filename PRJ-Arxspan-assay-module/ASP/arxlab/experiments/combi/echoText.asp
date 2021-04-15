<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../_inclds/globals.asp"-->
<%
Function SimpleBinaryToString(Binary)
  'SimpleBinaryToString converts binary data (VT_UI1 | VT_ARRAY Or MultiByte string)
  'to a string (BSTR) using MultiByte VBS functions
  Dim I, S
  For I = 1 To LenB(Binary)
    S = S & Chr(AscB(MidB(Binary, I, 1)))
  Next
  SimpleBinaryToString = S
End Function

Set Upload = Server.CreateObject("Persits.Upload")
Upload.Save
Set File = Upload.Files("file")
response.write(SimpleBinaryToString(file.binary))
%>