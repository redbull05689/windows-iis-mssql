<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
hrefStr = "show-notebook.asp?inFrame=true&id="&notebookId&"&rpp="&resultsPerPage&"&s="&s&"&d="&sortDir&"&strSearch="&request.querystring("strSearch")
%>
		<tr>
		<td colspan="8" align="right">	
	<%if pageNum > 1 then %>	
			<a href="javascript:void(0);" onclick="htmlStr = getFile('<%=hrefStr & "&pageNum=1"%>');document.getElementById('showNotebookTable').innerHTML=htmlStr;delayedRunJS(htmlStr);"><img src="images/resultset_first.gif" alt="First" border="0"></a>
			
			<a href="javascript:void(0);" onclick="htmlStr = getFile('<%=hrefStr & "&pageNum=" & pageNum-1%>');document.getElementById('showNotebookTable').innerHTML=htmlStr;delayedRunJS(htmlStr);" title="Previous Page"><img src="images/resultset_previous.gif" alt="Previous" border="0"></A>
	<%end if
	if pageNum < rec.pageCount then%>
			<a href="javascript:void(0);" onclick="htmlStr = getFile('<%=hrefStr & "&pageNum=" & pageNum + 1%>');document.getElementById('showNotebookTable').innerHTML=htmlStr;delayedRunJS(htmlStr);" title="Next Page"><img src="images/resultset_next.gif" border="0" alt="Next"></A>
			
			<a href="javascript:void(0);" onclick="htmlStr = getFile('<%=hrefStr & "&pageNum=" & rec.pageCount%>');document.getElementById('showNotebookTable').innerHTML=htmlStr;delayedRunJS(htmlStr);"><img src="images/resultset_last.gif" border="0" alt="Last"></a>	
	<%end if%>
		</td>
		</tr>