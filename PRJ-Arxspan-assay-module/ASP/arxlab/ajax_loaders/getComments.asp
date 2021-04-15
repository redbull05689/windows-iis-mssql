<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%


call getconnectedadm
experimentId =  request.Form("experimentId")
experimentType =  request.Form("experimentType")

	Set comRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id, userId, userName, dateSubmitted, comment, parentCommentId, deleted FROM experimentCommentsView WHERE experimentType="&SQLClean(experimentType,"N","S")& " AND experimentId="&SQLClean(experimentId,"N","S")& " AND comment NOT LIKE '#%' " & "AND requestFieldId IS null " & "ORDER BY id ASC"

'get all the comments

	comRec.open strQuery,conn,0,-1
	   Dim commentStr 
        commentStr= "["
	Do While Not comRec.eof
        commentIsDeleted = "false"
        if comRec("deleted") then
            commentIsDeleted = "true"
        end if
        commentStr = commentStr & "{"& """" & "deleted" & """" & ":" & commentIsDeleted 
		commentStr = commentStr & ","& """" & "userId" & """" & ":" & comRec("userId") 
        commentStr = commentStr & ","& """" & "id" & """" & " :" & comRec("id")  
        commentStr = commentStr & ","& """" & "userName" &""""& ": " & """" & comRec("userName") & """" 
        commentStr = commentStr & ","& """" &"dateSubmitted" & """" & ": " & """" & comRec("dateSubmitted") & """"  
        commentStr = commentStr & "," & """" & "attachment" & """" & ":["

'get all the attachments of the selected comment
set attRec = server.CreateObject("ADODB.RecordSet")
   attQuery = "SELECT id,filename FROM commentAttachments WHERE commentId=" & comRec("id")
   attRec.open attQuery,conn,3,3
   Do While Not attRec.eof
            commentStr = commentStr & "{" & """" & "attachmentId" & """" & ": " & attRec("id")
            commentStr = commentStr & "," & """" & "filename" & """" & ":"
            commentStr = commentStr & """"& attRec("filename") & """"
            commentStr = commentStr & "}"
            attRec.movenext
            If Not attRec.eof Then
                commentStr  = commentStr  & ","
            End if
        Loop

        commentStr = commentStr & "]"
        if isnull(comRec("parentCommentId"))  then
        	commentStr = commentStr & "," & """" & "parentCommentId" & """" & ": 0"  
        else
            commentStr = commentStr & "," & """" & "parentCommentId" & """" & ":" & comRec("parentCommentId") 
        end if
        commentStr = commentStr & "," & """" & "comment" & """" & ": " & """" & comRec("comment") & """" & "}"
        comRec.moveNext

       If Not comRec.eof Then
            commentStr  = commentStr  & ","
        End if
    loop         
    commentStr = commentStr & "]"
    response.contentType = "application/json charset=utf-8"
    response.write(commentStr)
	comRec.close
	Set comRec = nothing



	%>	