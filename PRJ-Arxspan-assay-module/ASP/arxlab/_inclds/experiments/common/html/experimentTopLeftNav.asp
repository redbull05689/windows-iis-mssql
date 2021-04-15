<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../globals.asp"-->
<!-- #include file="../../common/functions/fnc_getExperimentLink.asp"-->
<%
notebookId = request.querystring("notebookId")
experimentId = request.queryString("experimentId")
experimentType = request.querystring("experimentType")

If canViewExperiment(experimentType,experimentId,session("userId")) Or ownsExp Then

Call getconnected
Set recNoteBook = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT typeId, experimentId FROM notebookIndex WHERE notebookId="&SQLClean(notebookId,"N","S") & " AND visible=1 ORDER BY id ASC"
recNoteBook.open strQuery,conn,adOpenStatic,adLockReadOnly

nextLink = ""
prevLink = ""
lastLink = ""
firstLink = ""
If Not recNoteBook.eof Then
	' last link
	recNoteBook.moveLast
	lastLink = getExperimentLink(recNoteBook("typeId"), recNoteBook("experimentId"))
	
	' first link
	recNoteBook.moveFirst
	firstLink = getExperimentLink(recNoteBook("typeId"), recNoteBook("experimentId"))
	
	' find the current one
	recNoteBook.find("experimentId='" & Trim(experimentId) & "'")
	If Not recNoteBook.eof Then
		jumpForward = 2
		recNoteBook.move(-1)
		If Not recNoteBook.bof Then
			prevLink = getExperimentLink(recNoteBook("typeId"), recNoteBook("experimentId"))
		Else
			jumpForward = 1
			recNoteBook.moveFirst
		End If
		
		If Not recNoteBook.eof Then
			recNoteBook.move(jumpForward)
			If Not recNoteBook.eof Then
				nextLink = getExperimentLink(recNoteBook("typeId"), recNoteBook("experimentId"))
			End If
		End If
	End If	
End If
%>
		<%
		If prevLink <> "" Then
		%>
			<a href="<%=firstLink%>" title="First Page in this Notebook" class="expLink">First</a> | <a href="<%=prevLink%>" title="Previous Page in this Notebook" class="expLink">Previous</a><%=c%>
		<%
		End If
		
		If nextLink <> "" Then
			If prevLink <> "" Then
				%> | <%
			End If
		%>
			<a href="<%=nextLink%>" title="Next Page in this Notebook" class="expLink">Next</a> | <a href="<%=lastLink%>" title="Last Page in this Notebook" class="expLink">Last</a>	
		<%
		End If
		If prevLink <> "" Or nextLink <> "" Then
			%> Notebook Page <%
		End If
		%>
<%End If%>