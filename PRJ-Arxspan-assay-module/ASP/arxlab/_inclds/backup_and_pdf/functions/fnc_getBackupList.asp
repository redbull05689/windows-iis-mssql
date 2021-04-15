<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%

Function getProjectChildren(id,startIdString)
	Set D2 = new LD

	Set rec2 = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM linksProjectNotebooksView WHERE projectId="&SQLClean(id,"N","S")
	rec2.open strQuery,conn,3,3
	Do While Not rec2.eof
		Set D3 = new LD
		D3.addKeys("id,name,type,arxlabId")
		D3.addValues(startIdString&"_n"&Int(rec2("notebookId"))&","&Replace(rec2("name"),","," ")&",notebook,"&rec2("notebookId"))

		Set D4 = new LD
		Set rec3 = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM notebookIndexView WHERE notebookId="&SQLClean(rec2("notebookId"),"N","S")& " AND beenExported <> 1"
		rec3.open strQuery,conn,3,3
		Do While Not rec3.eof
			Set D5 = new LD
			D5.addKeys("id,name,type,arxlabId,subType,experimentType")
			Select Case rec3("typeId")
				Case "1"
					tStr = "c"
				Case "2"
					tStr = "b"
				Case "3"
					tStr = "f"
				Case "4"
					tStr = "a"
				Case "5"
					tStr = "w"
			End select
			D5.addValues(startIdString&"_n"&rec2("notebookId")&"_e"&tStr&Int(rec3("experimentId"))&","&Replace(rec3("name"),","," ")&",experiment,"&rec3("experimentId")&","&tStr&","&rec3("typeId"))
			D4.addItem(D5)
			rec3.movenext
		Loop
		rec3.close
		Set rec3 = Nothing
		
		D3.addPair "children",D4

		D2.addItem(D3)
		rec2.movenext
	Loop
	rec2.close
	Set rec2 = Nothing

	Set rec2 = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM linksProjectExperimentsView WHERE projectId="&SQLClean(id,"N","S")
	rec2.open strQuery,conn,3,3
	Do While Not rec2.eof
		Set D3 = new LD
		D3.addKeys("id,name,type,arxlabId,subType,experimentType")
		Select Case rec2("typeId")
			Case "1"
				tStr = "c"
			Case "2"
				tStr = "b"
			Case "3"
				tStr = "f"
			Case "4"
				tStr = "a"
			Case "5"
				tStr = "w"
		End select
		D3.addValues(startIdString&"_e"&tStr&Int(rec2("experimentId"))&","&Replace(rec2("name"),","," ")&",experiment,"&rec2("experimentId")&","&tStr&","&rec2("typeId"))
		D2.addItem(D3)
		rec2.movenext
	Loop
	rec2.close
	Set rec2 = Nothing
	

	Set getProjectChildren = D2
End Function

function getBackupList(topLevel,searchTerm,returnType)
	Select Case topLevel
		Case "sage"
			If request.servervariables("REMOTE_ADDR") = "8.20.189.188" Or request.servervariables("REMOTE_ADDR") = "72.85.242.42" then
				Set rec = server.CreateObject("ADODB.RecordSet")
				If searchTerm = "" then
					strQuery = "SELECT * FROM projectsView WHERE parentProjectId is NULL and companyId=1 AND visible = 1"
				Else
					strQuery = "SELECT * FROM projectsView WHERE parentProjectId is NULL and companyId=1 AND visible = 1 AND name like "&SQLClean(searchTerm,"L","S")
				End If
				rec.open strQuery,conn,3,3
				Set L = new LD
				Do While Not rec.eof
					Set D = new LD
					D.addKeys("id,name,type,arxlabId")
					D.addValues("L_p"&rec("id")&","&Replace(rec("name"),","," ")&",project,"&rec("id"))

					Set D2 = getProjectChildren(rec("id"),"L_p"&rec("id"))
					
					Set rec5 = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT * FROM projectsView WHERE parentProjectId="&SQLClean(rec("id"),"N","S")
					rec5.open strQuery,conn,3,3
					Do While Not rec5.eof
						Set D6 = new LD
						D6.addKeys("id,name,type,arxlabId")
						D6.addValues("L_p"&rec("id")&"_p"&rec5("id")&","&Replace(rec5("name"),","," ")&",tab,"&rec("id"))
						Set D7 = getProjectChildren(rec5("id"),"L_p"&rec("id")&"_p"&rec5("id"))
						D6.addPair "children",D7
						D2.addItem(D6)
						rec5.movenext
					loop
					rec5.close
					Set rec5 = nothing

					rec.movenext
					D.addPair "children",D2
					L.addItem(D)
				Loop
			End if
		Case "project"
			Set rec = server.CreateObject("ADODB.RecordSet")
			If searchTerm = "" then
				strQuery = "SELECT * FROM projectsView WHERE parentProjectId is NULL and companyId="&SQLClean(session("companyId"),"N","S") & " AND visible = 1"
			Else
				strQuery = "SELECT * FROM projectsView WHERE parentProjectId is NULL and companyId="&SQLClean(session("companyId"),"N","S") & " AND visible = 1 AND name like "&SQLClean(searchTerm,"L","S")
			End if
			rec.open strQuery,conn,3,3
			Set L = new LD
			Do While Not rec.eof
				Set D = new LD
				D.addKeys("id,name,type,arxlabId")
				D.addValues("L_p"&rec("id")&","&Replace(rec("name"),","," ")&",project,"&rec("id"))

				Set D2 = getProjectChildren(rec("id"),"L_p"&rec("id"))
				
				Set rec5 = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM projectsView WHERE parentProjectId="&SQLClean(rec("id"),"N","S")
				rec5.open strQuery,conn,3,3
				Do While Not rec5.eof
					Set D6 = new LD
					D6.addKeys("id,name,type,arxlabId")
					D6.addValues("L_p"&rec("id")&"_p"&rec5("id")&","&Replace(rec5("name"),","," ")&",tab,"&rec("id"))
					Set D7 = getProjectChildren(rec5("id"),"L_p"&rec("id")&"_p"&rec5("id"))
					D6.addPair "children",D7
					D2.addItem(D6)
					rec5.movenext
				loop
				rec5.close
				Set rec5 = nothing

				rec.movenext
				D.addPair "children",D2
				L.addItem(D)
			Loop

		Case "notebook"
			Set rec = server.CreateObject("ADODB.RecordSet")
			If searchTerm = "" then
				strQuery = "SELECT * FROM notebookView WHERE companyId="&SQLClean(session("companyId"),"N","S") & " AND visible=1 ORDER BY name ASC"
			Else
				strQuery = "SELECT * FROM notebookView WHERE companyId="&SQLClean(session("companyId"),"N","S") & " AND name like "&SQLClean(searchTerm,"L","S")&" AND visible=1 ORDER BY name ASC"
			End if
			rec.open strQuery,conn,3,3
			Set L = new LD
			Do While Not rec.eof
				Set D = new LD
				D.addKeys("id,name,type,arxlabId")
				D.addValues("L_n"&rec("id")&","&Replace(rec("name"),","," ")&",notebook,"&rec("id"))

				Set D2 = new LD

				Set rec2 = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * from notebookIndexView WHERE notebookId=" & SQLClean(rec("id"),"N","S") & " AND companyId="&SQLClean(session("companyId"),"N","S")& " AND visible=1 ORDER by name ASC"
				rec2.open strQuery,conn,3,3
				Do While Not rec2.eof
					Set D3 = new LD
					D3.addKeys("id,name,type,arxlabId,subType,experimentType")
					Select Case rec2("typeId")
						Case "1"
							tStr = "c"
						Case "2"
							tStr = "b"
						Case "3"
							tStr = "f"
						Case "4"
							tStr = "a"
						Case "5"
							tStr = "w"
					End select
					D3.addValues("L_n"&rec("id")&"_e"&tStr&Int(rec2("experimentId"))&","&Replace(rec2("name"),","," ")&",experiment,"&rec2("experimentId")&","&tStr&","&rec2("typeId"))
					D2.addItem(D3)
					rec2.movenext
				loop
				rec2.close
				Set rec2 = nothing

				rec.movenext
				D.addPair "children",D2
				L.addItem(D)
			Loop

		Case "manager"
			Set rec = server.CreateObject("ADODB.RecordSet")
			If searchTerm = "" then
				strQuery = "SELECT * FROM usersView WHERE (roleNumber=1 or roleNumber=2 ) AND companyId="&SQLClean(session("companyId"),"N","S") & " ORDER BY fullName DESC"
			Else
				strQuery = "SELECT * FROM usersView WHERE (roleNumber=1 or roleNumber=2 ) AND companyId="&SQLClean(session("companyId"),"N","S") & " AND fullName like "&SQLClean(searchTerm,"L","S")&" ORDER BY fullName DESC"
			End If
			rec.open strQuery,conn,3,3
			Set L = new LD
			Do While Not rec.eof
				Set D = new LD
				D.addKeys("id,name,type,arxlabId")
				D.addValues("L_u"&rec("id")&","&Replace(rec("fullName"),","," ")&",user,"&rec("id"))

				Set D2 = new LD

				Set rec2 = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * from notebookView WHERE id in ("&getManagerNotebooks(rec("id"))&") AND companyId="&SQLClean(session("companyId"),"N","S")& " AND visible=1 ORDER by name ASC"
				rec2.open strQuery,conn,3,3
				Do While Not rec2.eof
					Set D3 = new LD
					D3.addKeys("id,name,type,arxlabId")
					D3.addValues("L_u"&rec("id")&"_n"&rec2("id")&","&Replace(rec2("name")& " - "&rec2("firstName")&" " &rec2("lastName"),","," ")&",notebook,"&rec2("id"))
					Set D4 = new LD

					Set rec3 = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT * from notebookIndexView WHERE notebookId=" & SQLClean(rec2("id"),"N","S") & " AND companyId="&SQLClean(session("companyId"),"N","S")& " AND visible=1 ORDER by name ASC"
					rec3.open strQuery,conn,3,3
					Do While Not rec3.eof
						Set D5 = new LD
						D5.addKeys("id,name,type,arxlabId,subType,experimentType")
						Select Case rec3("typeId")
							Case "1"
								tStr = "c"
							Case "2"
								tStr = "b"
							Case "3"
								tStr = "f"
							Case "4"
								tStr = "a"
							Case "5"
								tStr = "w"
						End select
						D5.addValues("L_n"&rec("id")&"_u"&rec("id")&"_e"&tStr&Int(rec3("experimentId"))&","&Replace(rec3("name")& " - "&rec3("firstName")&" " &rec3("lastName"),","," ")&",experiment,"&rec3("experimentId")&","&tStr&","&rec3("typeId"))
						D4.addItem(D5)
						rec3.movenext
					Loop
					rec3.close
					Set rec3 = nothing
					
					D3.addPair "children",D4

					D2.addItem(D3)

					rec2.movenext
				Loop
				rec2.close
				Set rec2 = nothing

				rec.movenext
				D.addPair "children",D2
				L.addItem(D)
			Loop

	End Select
	If returnType="object" Then
		Set getBackupList = L
	else
		getBackupList = L.serialize("js")
	End if
end function
%>