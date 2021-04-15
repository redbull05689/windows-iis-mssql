<%
isArxLoginScript = True

Select Case whichServer
	Case "DEV"
		redirectURI = "https://stage.arxspan.com/SSO/azure/gw.asp"
	Case "MODEL"
		redirectURI = "https://model.arxspan.com/SSO/azure/gw.asp"
	Case "BETA"
		redirectURI = "https://beta.arxspan.com/SSO/azure/gw.asp"
	Case "PROD"
		redirectURI = "https://eln.arxspan.com/SSO/azure/gw.asp"
End Select

scope = "openid email"

Select Case session("authClient")
	Case "AZURE_SSO_TEST"
		baseAuthURL = "https://login.windows.net/7513c6bd-04e9-47d5-9a41-c4d2e0fb5547/oauth2"
		Select Case whichServer
			Case "MODEL"
				authCompanyId = "64"
		End Select
	Case "CONSTELLATION"
		baseAuthURL = "https://login.windows.net/7513c6bd-04e9-47d5-9a41-c4d2e0fb5547/oauth2"
		Select Case whichServer
			Case "PROD"
				authCompanyId = "9"
		End Select
	Case "MAGENTA"
		baseAuthURL = "https://login.windows.net/28e14203-9ef4-4aad-8a5e-7af9327920e0/oauth2"
		Select Case whichServer
			Case "PROD"
				authCompanyId = "103"
		End Select
End Select
%>
