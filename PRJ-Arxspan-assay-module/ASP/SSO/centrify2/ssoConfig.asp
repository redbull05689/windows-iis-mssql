<%
isArxLoginScript = True

Select Case whichServer
	Case "DEV"
		redirectURI = "https://stage.arxspan.com/SSO/centrify2/gw.asp"
	Case "MODEL"
		redirectURI = "https://model.arxspan.com/SSO/centrify2/gw.asp"
	Case "PROD"
		redirectURI = "https://eln.arxspan.com/SSO/centrify2/gw.asp"
End Select

scope = "openid email"

Select Case session("authClient")
	Case "RELAY"
		baseAuthURL = "https://aaj0172.my.centrify.com/OAuth2/"
		applicationId = "ArxspanELNOpenID"
		Select Case whichServer
			Case "PROD"
				authCompanyId = "61"
		End Select
End Select
%>
