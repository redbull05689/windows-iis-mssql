<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="../_inclds/globals.asp"-->
<%recLimit = Int(request.querystring("recLimit"))%>
<div class="dashboardObjectContainer elnDashObj" style="width:100%;"><div class="objHeader elnHead"><a href="<%=mainAppPath%>/table_pages/show-watchlist.asp" style="text-decoration:none;"><h2><%=watchlistLabel%></h2></a></div>
<div class="objBody" style="padding:0;">
	<%				
		strQuery = "select * from(" &_
		"select t.*, e.dateUpdated, e.molData, e.name, e.userExperimentName, e.requestTypeId, u.firstName, u.lastName, s.name as status from " &_
		"(SELECT id, userId, experimentId, experimentType," &_
		"(SELECT COUNT(n.id) from noteAddedNotifications n WHERE n.experimentType=f.experimentType AND n.experimentId=f.experimentId AND n.userId=f.userId AND (dismissed=0 or dismissed is null)) as newNoteCount," &_
		"(SELECT COUNT(n.id) from attachmentAddedNotifications n WHERE n.experimentType=f.experimentType AND n.experimentId=f.experimentId AND n.userId=f.userId AND (dismissed=0 or dismissed is null)) as newAttachmentCount," &_
		"(SELECT COUNT(n.id) from experimentSavedNotifications n WHERE n.experimentType=f.experimentType AND n.experimentId=f.experimentId AND n.userId=f.userId AND (dismissed=0 or dismissed is null)) as newSaveCount," &_
		"(SELECT COUNT(n.id) from commentNotifications n WHERE n.experimentType=f.experimentType AND n.experimentId=f.experimentId AND n.userId=f.userId AND (dismissed=0 or dismissed is null)) as newCommentCount " &_
		"FROM experimentFavorites f WHERE f.userId=" & SQLClean(session("userId"),"T","S") & ") t " &_
		"INNER JOIN allExperiments e on e.legacyId=t.experimentId AND e.experimentType=t.experimentType " &_
		"INNER JOIN statuses s on e.statusId=s.id " &_
		"INNER JOIN users u on u.id=t.userId" &_
		") q"
		
		Set rec = Server.CreateObject("ADODB.RecordSet")
		rec.CursorLocation = adUseClient
		rec.open strQuery,conn,adOpenStatic,adLockReadOnly,adCmdText
		If rec.eof Then
		%>
			<tr>
			<td>
				<p style="margin-left:10px;">Watchlist is empty.</p>
			</td>
			</tr>
		<%
            response.end()
		End if
		
		If recLimit = "" Then
			recLimit = 1000
		End If
        
		rec.sort = "id desc"
		counter = 0
		%>
		<table class="experimentsTable" style="width:100%;">
		<%
		Set experimentTypeMap = JSON.Parse("{}")
		Do While Not rec.eof And counter < recLimit
			counter = counter + 1
			If Not experimentTypeMap.Exists(CStr(rec("experimentType"))) Then
				
				Set thisType = JSON.Parse("{}")
				prefix = GetPrefix(rec("experimentType"))
				thisType.Set "prefix", prefix
				thisType.Set "expView", GetExperimentView(prefix)
				thisType.Set "page", GetExperimentPage(prefix)
				thisType.Set "fullExpType", GetFullExpType(rec("experimentType"), rec("requestTypeId"))
				
				experimentTypeMap.Set CStr(rec("experimentType")), thisType
			End If
			
			Set thisConfig = experimentTypeMap.Get(CStr(rec("experimentType")))
			prefix = thisConfig.Get("prefix")
			expView = thisConfig.Get("expView")
			experimentPage = thisConfig.Get("page")
			expTypeName = thisConfig.Get("fullExpType")
			%>
				<tr>
					<td class="experimentCell" style="padding-left:6px;">
						<%
						name = rec("name")

						If (Not IsNull(rec("userExperimentName"))) And rec("userExperimentName") <> "" Then
				    		name = name & " - " & rec("userExperimentName")
						End If
						%>
						<a href="<%=mainAppPath%>/<%=experimentPage%>?id=<%=Trim(rec("experimentId"))%>"><%=name%></a>
					</td>
					<td class="statusCell">
						<%=rec("status")%>
					</td>
					<td class="experimentTypeCell">
						<%=expTypeName%>
					</td>
					<td class="submittedCell">
						<%=rec("firstName") & " " & rec("lastName")%>
					</td>
					<td class="updatedCell">
						<div id="watchList_<%=rec("experimentType")%>_<%=rec("experimentId")%>">
							<script>setElementContentToDateString("<%="watchList_"&rec("experimentType")&"_"&rec("experimentId")%>", "<%=rec("dateUpdated")%>",<%If session("useGMT") Then%>true<%else%>false<%end if %>);</script>
						</div>
					</td>
					<td>
					<%
					numNotesAdded = rec("newNoteCount")
					numAttachmentsAdded = rec("newAttachmentCount")
					numSaves = rec("newSaveCount")
					numCommentsAdded = rec("newCommentCount")
					%>
					<div>
						<div class="actionIconHolder">
							<span class="textOnImage overlayText"><%=numSaves%></span>
							<img src="images/cow-save.gif" alt="Saves" title="Saves">
						</div>
						<div class="actionIconHolder">
							<span class="textOnImage overlayText"><%=numNotesAdded%></span>
							<img src="images/cow-note.gif" alt="Notes" title="Notes"> 
						</div>
						<div class="actionIconHolder">					
							<span class="textOnImage overlayText"><%=numAttachmentsAdded%></span>
							<img src="images/cow-attachment.gif" alt="Attachments" title="Attachments">
						</div>
						<div class="actionIconHolder">
							<span class="textOnImage overlayText"><%=numCommentsAdded%></span>
							<img src="images/cow-comment.gif" alt="Comments" title="Comments">
						</div>
					</div>

					</td>
					<td>
						<a href="javascript:void(0);" onclick="deleteWatchlistItem(<%=rec("id")%>)"> <img src="images/delete.png" class="png" height="12" width="12" border="0"></a>
					</td>
				</tr>
				<%If rec("experimentType") = 1 then%>
				<tr><td colspan="6" align="center" valign="center"><div id="WATCHLISTRXNHolder_<%=rec("id")%>">
				<script type="text/javascript">
					$(document).ready(function() {
						console.log(<%=rec("id")%>);
						elRXN = document.getElementById("WATCHLISTRXNHolder_<%=rec("id")%>");
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
			rec.moveNext()
			Loop
			theText = detailsLabel&"..."
		%>
		<%If counter > 0 then%>
		<tr class="dashLastRow">
			<td colspan="8" align="right" class="dashLastRow"><a href="<%=mainAppPath%>/table_pages/show-watchlist.asp"><%=theText%></a></td>
		</tr>
		<%End if%>
		</table>
</div>
</div>