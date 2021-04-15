<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%

'things to do:
'take in a multi row paste from excell 
'take in a single row copy
'on request output a set of data that can be parsed into multiple rows(with sub rows)
'note for parse
'push all to upper

'excell/google sheets copy and paste the same way 
'each cell is seperated with ascii code 9 ----> tab 
'each row ends with ascii code 13 ----> CR ---> return on a keaboard
'each new row starts with ascii code 10 ---> LF


'start by accepting in a string and converting that to csv or if internal just bypass the set to csv



 strID = Request.Form("msg")
 
if Left(strID,2) = "01" then
session("Clipboard")  = mid(strID,3)
response.write(session("Clipboard"))
ElseIf Left(strID,2) = "02" then
response.write(session("Clipboard"))
ElseIf Left(strID,2) = "03" then
session("UserClipboard")  = mid(strID,3)
response.write(session("UserClipboard"))
ElseIf Left(strID,2) = "04" then
response.write(session("UserClipboard"))
end if 











%>