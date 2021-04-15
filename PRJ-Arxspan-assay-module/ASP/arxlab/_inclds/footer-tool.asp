<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
If isExperimentPage then
	%>
	<!-- #include file="experiments/common/asp/saveExperimentJSON.asp"-->
	<%
End If
%>
<%
On Error Resume Next
Call disconnectlog
Call disconnect
Call disconnectadm
Call disconnectJchem
Call disconnectJchemReg
On Error goto 0
%>
<%If sectionID <> "home" Then %></div></td></tr></table> <%End If%>
</div>

<%If sectionID = "home" Then %>
<div class="footerDiv">   

			<div class="footerContent">
			
			<div class="footerText" style="margin-right:100px;">
			<h3>Flexible</h3>
			<ul>
				<li>Platform independent
				<li>Location independent
				<li>Scaleable licensing
			</ul>
			
			</div>
			<div class="footerText" ><h3>Secure</h3>
			<ul>
				<li>Full SSL Communication
				<li>Private tunnel compatible
				<li>SAS70 certified data center
			</ul>
						
			
			</div>
			<div class="footerText"><h3>Affordable</h3>
			<ul>
				<li>Client agnostic
				<li>Tablet &amp; handheld compatible
				<li>SaaS Delivery - No hardware, No software
			</ul>
			
			
			</div>
			
			
			</div>
			

</div><%End if%>

<div class="footerCopyRight">
	<div class="footerCopyRightText"> <% If whichServer = "MODEL" Then %> Branch: <%=branchRef%> | Commit Id: <%=jsRev%> | <% End If %>  Page loaded in <%=timer()-st%> seconds&nbsp;&nbsp;&nbsp;&copy;<%=year(now())%> Arxspan.   All Rights Reserved. &mdash; 5a Crystal Pond Road, Southborough, MA  01772 &mdash; 617-297-7023 </div>
</div>

</div>
<%if session("hasELN") then%>
<%If Split(request.servervariables("SCRIPT_NAME"),"/")(UBound(Split(request.servervariables("SCRIPT_NAME"),"/")))<>"force-change-password.asp" then%>
<script type="text/javascript">
var warningSack = new sack();
	function warning()
	{
		warningSack.requestFile = "<%=mainAppPath%>/ajax_checkers/warning.asp?random="+Math.random()
		warningSack.onCompletion = warningDone;
		warningSack.runAJAX();
	}

	function warningDone()
	{
		if (warningSack.response != "")
			{
				if (warningSack.response.indexOf("warning###")>-1)
				{
					alert(warningSack.response.replace("warning###",""))					
				}
			}
	}

	warningInterval = setInterval('warning()',300000)
	warning()
</script>
<%End if%>
<%End if%>
<script type="text/javascript" src="<%=mainAppPath%>/js/select2-3.5.1/select2.js?<%=jsRev%>"></script>
</body>
</html>
