<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%isAjax=true%>
<!-- #include file="../_inclds/globals.asp"-->
<%recLimit = Int(request.querystring("recLimit"))%>
<div class="dashboardObjectContainer elnDashObj" style="width:100%;"><div class="objHeader elnHead"><a href="<%=mainAppPath%>/table_pages/show-witnessRequests.asp" style="text-decoration:none;"><h2><%=witnessRequestsLabel%></h2></a></div>
<div class="objBody" style="padding:0;">
	<%
	sortBy = "id"
	pageNum = 1

	Call getconnected

	Set rec = server.CreateObject("ADODB.RecordSet")
	rec.pageSize = recLimit
	rec.CacheSize = recLimit
	rec.CursorLocation = 3
	strQuery = "SELECT TOP 5 experimentTypeId, experimentId, name, experimentOwner, dateSubmitted, requestTypeId FROM witnessRequestsView as wr WHERE requesteeId="&SQLClean(session("userId"),"N","S") & " AND accepted=0 and denied=0 and not exists (SELECT * from witnessRequestsView WHERE (accepted=1 or denied=1) and experimentId=wr.experimentId and experimentTypeId=wr.experimentTypeId) order by wr.dateSubmitted desc"
	rec.open strQuery,conn,0,1
	counter = recLimit * pageNum - recLimit
	If Not rec.eof then
		rec.absolutePage = pageNum
		eofFlag = False
	Else
		eofFlag = True
	End if

	%>
	<%If Not eofFlag then%>
	<table class="experimentsTable" style="width:100%;">
	<%
	Set experimentTypeMap = JSON.Parse("{}")
	For intRec = 1 To rec.pageSize
		If Not rec.eof then
			check = true
			if rec("experimentTypeId") = "5" then
				expRevision = getExperimentRevisionNumber(rec("experimentTypeId"),rec("experimentId"))
				check = checkIfAllSigned(rec("experimentId"), rec("experimentTypeId"), expRevision)
			end if
			if check then
				counter = counter + 1
				
				If Not experimentTypeMap.Exists(CStr(rec("experimentTypeId"))) Then
					prefix = GetPrefix(rec("experimentTypeId"))
					
					Set thisType = JSON.Parse("{}")
					thisType.Set "prefix", prefix
					thisType.Set "expView", GetExperimentView(prefix)
					thisType.Set "page", GetExperimentPage(prefix)
					
					experimentTypeMap.Set CStr(rec("experimentTypeId")), thisType
				End If
				
				Set thisConfig = experimentTypeMap.Get(CStr(rec("experimentTypeId")))
				prefix = thisConfig.Get("prefix")
				expView = thisConfig.Get("expView")
				page = thisConfig.Get("page")
				
				%>
					<tr>
						<td class="counterCell">
							<%=counter%>.
						</td>
						<td class="experimentCell">
							<a href="<%=mainAppPath%>/<%=page%>?id=<%=rec("experimentId")%>"><%=rec("name")%></a>
						</td>
						<td class="statusCell">
							<%=GetFullExpType(rec("experimentTypeId"), rec("requestTypeId"))%>
						</td>
						<td class="statusCell">
							<%=rec("experimentOwner")%>
						</td>
						<td class="statusCell">
							<div id="witnessRequests_<%=rec("experimentTypeId")%>_<%=rec("experimentId")%>">
								<script>setElementContentToDateString("<%="witnessRequests_"&rec("experimentTypeId")&"_"&rec("experimentId")%>", "<%=rec("dateSubmitted")%>",<%If session("useGMT") Then%>true<%else%>false<%end if %>);</script>
							</div>
						</td>
					</tr>
				<%If rec("experimentTypeId") = 1 then%>
				<tr><td colspan="6" align="center" valign="center"><div id="WITNESSRQRXNHolder_<%=rec("experimentId")%>">
				<script type="text/javascript">
					$(document).ready(function() {
						console.log(<%=rec("experimentId")%>);
						elRXN = document.getElementById("WITNESSRQRXNHolder_<%=rec("experimentId")%>");
						var loadingImg = new Image();
						loadingImg.id = "img_<%=rec("experimentId")%>";
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
			end if
			rec.movenext
		End if
	Next

	theText = detailsLabel&"..."
	If counter > 0 then%>
	<tr class="dashLastRow">
		<td colspan="8" align="right" class="dashLastRow"><a href="<%=mainAppPath%>/table_pages/show-witnessRequests.asp"><%=theText%></a></td>
	</tr>
	<% End if%>
	</table>
	<% Else %>
	<table class="experimentsTable" style="width:100%;">
		<tr>
			<td style="padding-left: 10px;">You have no pending witness requests.</td>
		</tr>
	</table>
	<% End if %>
</div>
</div>
