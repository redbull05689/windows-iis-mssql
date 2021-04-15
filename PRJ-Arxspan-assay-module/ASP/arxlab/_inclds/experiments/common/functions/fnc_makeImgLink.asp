<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function makeImgLink(imgId,experimentType,pre)
    'Makes an image link for in-line CKEditor fields based on whether or not imgId is a presave ID or not.
    makeImgLink = "/arxlab/experiments/ajax/load/getImage.asp?id="&imgId&"&amp;experimentType="&experimentType
    
    If pre Then
        makeImgLink = makeImgLink&"&amp;pre=true"
    End If

end function
%>