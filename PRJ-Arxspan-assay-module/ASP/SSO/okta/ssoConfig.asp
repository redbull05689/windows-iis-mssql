<%
isArxLoginScript = True

Select Case whichServer
	Case "DEV"
		redirectURI = "https://stage.arxspan.com/SSO/okta/gw.asp"
	Case "MODEL"
		redirectURI = "https://model.arxspan.com/SSO/okta/gw.asp"
	Case "BETA"
		redirectURI = "https://beta.arxspan.com/SSO/okta/gw.asp"
	Case "PROD"
		redirectURI = "https://eln.arxspan.com/SSO/okta/gw.asp"
End Select

scope = "openid email profile"

Select Case session("authClient")
	Case "DEMO"
		baseAuthURL = "https://arxspan.oktapreview.com"
		Select Case whichServer
			Case "DEV"
				authCompanyId = "13"
			Case "MODEL"
				authCompanyId = "51"
		End Select
	Case "INTELLIA"
		baseAuthURL = "https://intelliatx.okta.com"
		Select Case whichServer
			Case "PROD"
				authCompanyId = "98"
		End Select
	Case "EPIZYME"
		baseAuthURL = "https://epizyme.okta.com"
		Select Case whichServer
			Case "PROD"
				authCompanyId = "59"
		End Select
	Case "DIMENSION"
		baseAuthURL = "https://dimensiontx.okta.com"
		Select Case whichServer
			Case "PROD"
				authCompanyId = "70"
		End Select
	Case "FLEXION"
		baseAuthURL = "https://flexion.okta.com"
		Select Case whichServer
			Case "PROD"
				authCompanyId = "125"
		End Select
End Select
%>
