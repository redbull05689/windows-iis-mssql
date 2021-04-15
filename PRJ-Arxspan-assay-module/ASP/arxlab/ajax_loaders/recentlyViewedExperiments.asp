<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%isAjax=true%>
<!-- #include file="../_inclds/globals.asp"-->
<%recLimit = Int(request.querystring("recLimit"))%>
<%
Response.ContentType = "text/html"
Response.AddHeader "Content-Type", "text/html;charset=UTF-8"
Response.CodePage = 65001
Response.CharSet = "UTF-8"
%>
<div class="dashboardObjectContainer elnDashObj" style="width:100%;"><div class="objHeader elnHead"><a href="<%=mainAppPath%>/table_pages/show-recentlyViewedExperiments.asp" style="text-decoration:none;"><h2><%=recentlyViewedExperimentsLabel%></h2></a></div>
<div class="objBody" style="padding:0;">

	<%				
		Set rec = Server.CreateObject("ADODB.RecordSet")
		If recLimit = "" Then
			recLimit = 1000
		End If
		strQuery = "SELECT"
		If subsectionId="dashboard" Then
			strQuery = strQuery & " top 100"
		End if
		strQuery = strQuery &" typeId,experimentId,notebookId,userId,status,id,fullName,requestTypeId FROM recentlyViewedExperimentsView WHERE companyId="&SQLClean(session("companyId"),"N","S")&" and userId="&SQLClean(session("userId"),"N","S") & " and visible=1 ORDER BY id  desc"
		st2 = timer
		rec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
		counter = 0
		%>
		<table class="experimentsTable" style="width:100%;">
		<%
		If rec.eof Then
		%>
			<tr>
			<td>
				<p>No Results.</p>
			</td>
			</tr>
		<%
		End if
		
		Set experimentTypeMap = JSON.Parse("{}")
		
		Do While Not rec.eof And counter < recLimit
			hasView = canViewExperiment(rec("typeId"),rec("experimentId"),session("userId"))
			hasNotebookInvitation = hasNotebookInviteRead(rec("notebookId"),session("userId"))
			If hasView Or hasNotebookInvitation then

			counter = counter + 1
			%>
				<tr>
					<td class="counterCell">
						<%=counter%>.
					</td>
					<td class="experimentCell dashboard">
						<%
						If Not experimentTypeMap.Exists(CStr(rec("typeId"))) Then
							prefix = GetPrefix(rec("typeId"))
							
							Set thisType = JSON.Parse("{}")
							thisType.Set "prefix", prefix
							thisType.Set "expView", GetExperimentView(prefix)
							thisType.Set "page", GetExperimentPage(prefix)
							
							experimentTypeMap.Set CStr(rec("typeId")), thisType
						End If
						
						Set thisConfig = experimentTypeMap.Get(CStr(rec("typeId")))
						prefix = thisConfig.Get("prefix")
						expView = thisConfig.Get("expView")
						page = thisConfig.Get("page")

						Set dRec = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT details,name,dateSubmitted,firstName,lastName,userExperimentName from " & expView & " WHERE id="&SQLClean(rec("experimentId"),"N","S")
						dRec.open strQuery,conn,0,-1
						If Not dRec.eof Then
							details = dRec("details")
							name = dRec("name")
							dateSubmitted = dRec("dateSubmitted")
						End if
						%>
						<%
						If (Not IsNull(dRec("userExperimentName"))) And dRec("userExperimentName") <> "" Then
							name = name & " - " & dRec("userExperimentName")
						End If
						
						If IsNull(details) Then
							details = ""
						Else
							details = Replace(details,"""","")
						End If
						title = details & "&#13;" & dRec("firstName") & " " & dRec("lastName")
						%>
						
						<a href="<%=mainAppPath%>/<%=page%>?id=<%=Trim(rec("experimentId"))%>" title="<%=title%>" <%=experimentStatusImg(rec("status"))%>><%=name%></a>
						
					</td>
					<td class="experimentDescriptionCell multiLineSpacing" title="<%=details%>"><%=maxChars(details, 80)%>
					</td>
					<td class="experimentTypeCell">
						<%=GetFullExpType(rec("typeId"),rec("requestTypeId"))%>
					</td>
					<td class="submittedCell">
						<%=dRec("firstName") & " " & dRec("lastName")%>
					</td>
					<td class="updatedCell">
						<div id="recentlyViewed_<%=rec("typeId")%>_<%=rec("experimentId")%>">
							<script>setElementContentToDateString("<%="recentlyViewed_"&rec("typeId")&"_"&rec("experimentId")%>", "<%=dateSubmitted%>",<%If session("useGMT") Then%>true<%else%>false<%end if %>);</script>
						</div>
					</td>
					
				</tr>
				<%If rec("typeId") = 1 then%>
				<tr><td colspan="6" align="center" valign="center"><div id="RXNHolder_<%=rec("id")%>">
				<script type="text/javascript">
					$(document).ready(function() {
						console.log(<%=rec("id")%>);
						elRXN = document.getElementById("RXNHolder_<%=rec("id")%>");
						var loadingImg = new Image();
						loadingImg.id = "img_<%=rec("id")%>";
						loadingImg.src = window.location.origin + "/arxlab/images/loading_big.gif"
						loadingImg.style.width = '100px';
						loadingImg.style.height = '100px';
						l = document.createElement("a");
						l.appendChild(loadingImg);
						elRXN.appendChild(l);

						getCdxDashboard('<%=rec("experimentId")%>', elRXN.id, loadingImg.id);
					});
						
					function IsImageOk(img) {
						if (!img.complete) {
							return false;
						}
						if (typeof img.naturalWidth != "undefined" && img.naturalWidth == 0) {
							return false;
						}
						return true;
					}

					function addEvent(obj, evType, fn, useCapture){
					  if (obj.addEventListener){
						obj.addEventListener(evType, fn, useCapture);
						return true;
					  } else if (obj.attachEvent){
						var r = obj.attachEvent("on"+evType, fn);
						return r;
					  } else {
						alert("Handler could not be attached");
					  }
					}

					imgCheck = function(){
						for (var i = 0; i < document.images.length; i++) {
							if (!IsImageOk(document.images[i])) {
								document.images[i].style.visibility = "hidden";
							}
						}
					}

					addEvent(window, "load", function() {
						imgCheck();
					});
				</script>
				</div></td></tr>
				<%end if%>
			<%
			End if
			rec.moveNext()
			Loop
			theText = detailsLabel&"..."
		%>
		<%If counter > 0 then%>
		<tr class="dashLastRow">
			<td colspan="7" align="right" class="dashLastRow"><a href="<%=mainAppPath%>/table_pages/show-recentlyViewedExperiments.asp"><%=theText%></a></td>
		</tr>
		<%End if%>
	</table>
</div>
</div>