<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%subSectionId= request.querystring("subSectionId")%>
<%If subSectionId="force-change-password" then
	response.end
End if%>
<!-- #include virtual="/arxlab/_inclds/globals.asp"-->
<%
''412015
Set navRec2 = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT n.myExperimentsMore,n.sharedExperimentsMore,n.recentExperiments FROM navStates n JOIN users u on n.userId=u.id WHERE u.companyId="&SQLClean(session("companyId"),"N","S")&" and n.userId="&SQLClean(session("userId"),"N","S")
navRec2.CursorLocation = adUseClient
navRec2.open strQuery,conn,adOpenStatic,adLockReadOnly,adCmdText
If Not navRec2.eof Then
	If navRec2("myExperimentsMore") Then
		myExperimentsMoreFlag = true
	End If
	If navRec2("sharedExperimentsMore") Then
		sharedExperimentsMoreFlag = true
	End If
	If navRec2("recentExperiments") Then
		recentExperimentsFlag = true
	End if
End If
navRec2.close
Set navRec2 = Nothing
''/412015
%>
<%
strQuery = "SELECT typeId, experimentId, left(details,1000) as details, fullName, name, id, dateSubmitted, userExperimentName, status, ownerId FROM recentlyViewedExperimentsView WHERE companyId="&SQLClean(session("companyId"),"N","S")&" and userId="&SQLClean(session("userId"),"N","S") & " and visible=1 GROUP BY typeId, experimentId, details, fullName, name, id, dateSubmitted, userExperimentName, status, ownerId"
Set navRecentRec = server.CreateObject("ADODB.RecordSet")
navRecentRec.CursorLocation = adUseClient
navRecentRec.open strQuery,conn,adOpenStatic,adLockReadOnly,adCmdText

sortBy = "recentlyViewed"
If userOptions.exists("leftNavSort") Then
	sortBy = userOptions.Get("leftNavSort")
End If
Select Case sortBy
	Case "recentlyViewed"
		orderStr = "id DESC"
	Case "dateCreated"
		orderStr = "dateSubmitted DESC"
End Select
navRecentRec.Sort = orderStr

Set experimentTypeMap = JSON.Parse("{}")
%>
<div id="navRecentExperiments"<%If Not recentExperimentsFlag then%> style="display:none;"<%else%> style="display:block;"<%End if%>>
	<div class="navSubSectionTabAction">								
			<a id="navMyExperimentsLink" href="javascript:void(0);" onclick="if(document.getElementById('navMyExperiments').style.display == 'none'){navToggle('navMyExperiments');this.className='active';s=document.getElementById('navSharedExperiments');s.style.display='none';sa=document.getElementById('navSharedExperimentsLink');sa.className='';setUserOption('navSharedExperiments',false);}" <%If Not userOptions.Get("navSharedExperiments") then%>class="active"<%End if%>><%=myExperimentsLabel%></a>
			<a id="navSharedExperimentsLink" href="javascript:void(0);" onclick="if(document.getElementById('navSharedExperiments').style.display == 'none'){navToggle('navSharedExperiments');this.className='active';m=document.getElementById('navMyExperiments');m.style.display='none';ma=document.getElementById('navMyExperimentsLink');ma.className='';setUserOption('navSharedExperiments',true);}" <%If userOptions.Get("navSharedExperiments") then%>class="active"<%End if%>><%=UCase(sharedLabel)%></a>
			
	</div>
	<div id="navMyExperiments" <%If userOptions.Get("navSharedExperiments") then%>style="display:none;"<%End if%>>
		<ul>
		<%
		counter = 0
		Do While Not navRecentRec.eof And counter < 12
			If CLng(navRecentRec("ownerId")) = CLng(session("userId")) Then
				If canViewExperiment(navRecentRec("typeId"),navRecentRec("experimentId"),session("userId")) then
					counter = counter + 1
					If counter > 5 Then
						className = "navMyExperimentsMore"
					Else
						className = ""
					End if
					%>
						<%
						displayName = navRecentRec("name")
						If (Not IsNull(navRecentRec("userExperimentName"))) And navRecentRec("userExperimentName")<> "" Then
							displayName = displayName & " - " & navRecentRec("userExperimentName")
						End If
						%>
						<li class="<%=className%>" <%If counter>5 And Not myExperimentsMoreFlag then%>style="display:none;"<%End if%> <%If counter>5 And myExperimentsMoreFlag then%>style="display:inline;"<%End if%>>
							<%
								If Not experimentTypeMap.Exists(CStr(navRecentRec("typeId"))) Then
									
									Set thisType = JSON.Parse("{}")
									prefix = GetPrefix(navRecentRec("typeId"))
									thisType.Set "prefix", prefix
									thisType.Set "page", GetExperimentPage(prefix)
									
									experimentTypeMap.Set CStr(navRecentRec("typeId")), thisType
								End If
								
								Set thisConfig = experimentTypeMap.Get(CStr(navRecentRec("typeId")))
								prefix = thisConfig.Get("prefix")
								expPage = thisConfig.Get("page")
							%>
							<a href="<%=mainAppPath%>/<%=expPage%>?id=<%=Trim(navRecentRec("experimentId"))%>" title="<%=displayToolTip(navRecentRec("details"), navRecentRec("fullName"))%>" <%=experimentStatusImg(navRecentRec("status"))%>><%=displayName%></a>
						</li>
					<%
				End if
			End If
			navRecentRec.movenext
		Loop
		navRecentRec.movefirst
		%>
		</ul>
		<%If counter > 5 then%>
			<div class="navSectionFooter navFooter"><a style="font-weight: bold;" id="navMyExperimentsMoreLink" href="javascript:void(0);" onclick="navViewMore('navMyExperimentsMore');return false;"><%If Not myExperimentsMoreFlag then%><%=UCase(viewMoreLabel)%> >><%else%><< VIEW LESS<%End if%></a></div>
		<%End if%>
		<div class="navSectionFooter navFooter">
			<a style="font-weight: bold;" href="<%=mainAppPath%>/table_pages/show-experiments.asp?m=y"><%=UCase(viewAllLabel)%> >></a>
		</div>
	</div>

	<div id="navSharedExperiments" <%If Not userOptions.Get("navSharedExperiments") then%>style="display:none;"<%End if%>>
		<ul>
		<%
		counter = 0
		Do While Not navRecentRec.eof And counter < 12
			If CLng(navRecentRec("ownerId")) <> CLng(session("userId")) Then
				counter = counter + 1
				If counter > 5 Then
					className = "navSharedExperimentsMore"
				Else
					className = ""
				End if
				%>
					<li class="<%=className%>" <%If counter>5 And Not sharedExperimentsMoreFlag then%>style="display:none;"<%End if%> <%If counter>5 And sharedExperimentsMoreFlag then%>style="display:inline;"<%End if%>>
						<%
						If Not experimentTypeMap.Exists(CStr(navRecentRec("typeId"))) Then
							
							Set thisType = JSON.Parse("{}")
							prefix = GetPrefix(navRecentRec("typeId"))
							thisType.Set "prefix", prefix
							thisType.Set "page", GetExperimentPage(prefix)
							
							experimentTypeMap.Set CStr(navRecentRec("typeId")), thisType
						End If
						
						Set thisConfig = experimentTypeMap.Get(CStr(navRecentRec("typeId")))
						prefix = thisConfig.Get("prefix")
						expPage = thisConfig.Get("page")
						%>
						<a href="<%=mainAppPath%>/<%=expPage%>?id=<%=Trim(navRecentRec("experimentId"))%>" title="<%=displayToolTip(navRecentRec("details"), navRecentRec("fullName"))%>" <%=experimentStatusImg(navRecentRec("status"))%>><%=navRecentRec("name")%></a>
					</li>
				<%
				End If
			navRecentRec.movenext
		Loop
		navRecentRec.close
		Set navRecentRec = nothing
		%>
		</ul>
		<%If counter > 5 then%>
			<div class="navSectionFooter navFooter"><a style="font-weight: bold;" id="navSharedExperimentsMoreLink" href="javascript:void(0);" onclick="navViewMore('navSharedExperimentsMore');return false;"><%If Not sharedExperimentsMoreFlag then%><%=UCase(viewMoreLabel)%> >><%else%><< VIEW LESS<%End if%></a></div>
		<%End if%>
		<div class="navSectionFooter navFooter">
			<a style="font-weight: bold;" href="<%=mainAppPath%>/table_pages/show-experiments.asp?m=n"><%=UCase(viewAllLabel)%> >></a>
		</div>
	</div>
</div>
<%
strQuery = "SELECT f.id, f.experimentType as typeId, f.experimentId, e.name, s.name as status FROM experimentFavorites f INNER JOIN allExperiments e ON e.legacyId=f.experimentId AND e.experimentType=f.experimentType INNER JOIN statuses s on s.id=e.statusId WHERE f.userId="&SQLClean(session("userId"),"N","S") & " and e.visible=1"
'strQuery = "SELECT id, typeId, experimentId, name, status FROM experimentFavoritesView WHERE userId="&SQLClean(session("userId"),"N","S") & " and visible=1"
Set navRecentRec = server.CreateObject("ADODB.RecordSet")
navRecentRec.CursorLocation = adUseClient
navRecentRec.open strQuery,conn,adOpenStatic,adLockReadOnly,adCmdText
navRecentRec.Sort = "id desc"
counter = 0
%>
<div id="favoriteExperimentsList" style="display:none;">
	<ul>
	<%
	Do While Not navRecentRec.eof And counter < 5
		counter = counter + 1
		%>
			<li>
				<%
				If Not experimentTypeMap.Exists(CStr(navRecentRec("typeId"))) Then
					
					Set thisType = JSON.Parse("{}")
					prefix = GetPrefix(navRecentRec("typeId"))
					thisType.Set "prefix", prefix
					thisType.Set "page", GetExperimentPage(prefix)
					
					experimentTypeMap.Set CStr(navRecentRec("typeId")), thisType
				End If
				
				Set thisConfig = experimentTypeMap.Get(CStr(navRecentRec("typeId")))
				prefix = thisConfig.Get("prefix")
				expPage = thisConfig.Get("page")
				%>
				<a href="<%=mainAppPath%>/<%=expPage%>?id=<%=Trim(navRecentRec("experimentId"))%>" <%=experimentStatusImg(navRecentRec("status"))%>><%=navRecentRec("name")%></a>
			</li>
		<%
		navRecentRec.movenext
	Loop
	navRecentRec.close
	Set navRecentRec = nothing
	%>
	</ul>
	<%If counter = 5 Then%>
	<div class="navSectionFooter navFooter"><a style="font-weight: bold;" href="<%=mainAppPath%>/table_pages/show-watchlist.asp"><%=UCase(viewAllLabel)%> >></a></div>
	<%End if%>
</div>