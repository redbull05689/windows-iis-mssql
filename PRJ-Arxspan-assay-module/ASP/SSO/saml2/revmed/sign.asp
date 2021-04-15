<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../arxlab/_inclds/globals.asp"-->
<%
isArxLoginScript = True

dim redirectTo
Select Case whichServer
	' session("SSORedirectURL") = where the C# should send the user when its done
	' redirectTo = where to hit the C# for signing
	Case "DEV"
		session("SSORedirectURL") = "https://stage.arxspan.com/SSO/saml2/revmed/finalize.asp"
		redirectTo = "https://stage.arxspan.com/saml/revmed/signPDF/"
	Case "MODEL"
		session("SSORedirectURL") = "https://model.arxspan.com/SSO/saml2/revmed/finalize.asp"
		redirectTo = "https://model.arxspan.com/saml/revmed/signPDF/"
	Case "BETA"
		session("SSORedirectURL") = "https://beta.arxspan.com/SSO/saml2/revmed/finalize.asp"
		redirectTo = "https://beta.arxspan.com/saml/revmed/signPDF/"
	Case "PROD"
		session("SSORedirectURL") = "https://eln.arxspan.com/SSO/saml2/revmed/finalize.asp"
		redirectTo = "https://eln.arxspan.com/saml/revmed/signPDF/"
end select

session("SSOstate") = request.querystring("state")
session("SSOTempKey") = CreateGUID
session("SSOPageKey") = request.querystring("key")
session.Save()

' This function will return a plain GUID, e.g., 47BC69BD-06A5-4617-B730-B644DBCD40A9.
Function CreateGUID
  Dim TypeLib
  Set TypeLib = CreateObject("Scriptlet.TypeLib")
  CreateGUID = Mid(TypeLib.Guid, 2, 36)
End Function


%>
<script type="text/javascript">
	var redirectTo = "<%=redirectTo%>";
	console.log('redirecting to: ' + redirectTo);
	window.location = redirectTo;
</script>