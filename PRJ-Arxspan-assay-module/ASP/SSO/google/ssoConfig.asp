<%
isArxLoginScript = True

Select Case whichServer
	Case "DEV"
		redirectURI = "https://stage.arxspan.com/SSO/google/gw.asp"
	Case "MODEL"
		redirectURI = "https://model.arxspan.com/SSO/google/gw.asp"
	Case "BETA"
		redirectURI = "https://beta.arxspan.com/SSO/google/gw.asp"
	Case "PROD"
		redirectURI = "https://eln.arxspan.com/SSO/google/gw.asp"
End Select

scope = "openid email profile"
baseAuthURL = "https://accounts.google.com/o/oauth2/v2/"
baseTokenURL = "https://www.googleapis.com/oauth2/v4/"

Select Case session("authClient")
	Case "BROAD"
		Select Case whichServer
			Case "PROD"
				authCompanyId = "62"
			Case "BETA"
				authCompanyId = "56"
			Case "MODEL"
				authCompanyId = "56"
			Case "DEV"
				authCompanyId = "20"
		End Select
End Select
%>
