<%
Select Case whichServer
	Case "DEV"
		redirectURI = "https://dev.arxspan.com/SSO/centrify/gw.asp"
	Case "MODEL"
		redirectURI = "https://model.arxspan.com/SSO/centrify/gw.asp"
	Case "BETA"
		redirectURI = "https://beta.arxspan.com/SSO/centrify/gw.asp"
	Case "PROD"
		redirectURI = "https://eln.arxspan.com/SSO/centrify/gw.asp"
End select
state = getRandomString(32)
session("state") = state
Select Case session("authClient")
	Case "RELAY"
		Select Case whichServer
			Case "MODEL"
				baseAuthURL = "https://pod14.centrify.com/Oauth"
				clientId = "a6f3d1ce-dfd8-4286-869a-d138c326419d_AAJ0172"
				clientSecret = "oAeUbdLXAODQXHg"
				scope = "openid email"
				authCompanyId = "51"
		End Select
	Case "REVOLUTION"
		baseAuthURL = "https://aai0015.my.idaptive.app/Oauth"
		scope = "openid email"
		Select Case whichServer
			Case "MODEL"
				authCompanyId = "62"
				clientId = "646cf83f-07a3-4fce-bfb1-e11a148548fc_AAI0015"
				clientSecret = "o13Lx00M2zB942X4pf9e880v2AY9JHPh8y1M"
			Case "PROD"
				authCompanyId = "109"
				clientId= "9bb0893a-af35-44d8-8e77-2b508557be26_AAI0015"
				clientSecret = "mfG3I4zERqlEYAZJn8doKODP91U08LXLa69f"
		End Select
	Case "MAGENTA"
		baseAuthURL = "https://pod4.centrify.com/Oauth"
		scope = "openid email"
		Select Case whichServer
			Case "PROD"
				authCompanyId = "103"
				clientId= "f02e3a18-332b-4a1c-adc5-27da099bbd17_AAK0642"
				clientSecret = "gPG90u24^bNL"
		End Select
End Select
session("baseAuthURL") = baseAuthURL
session("clientId") = clientId
session("clientSecret") = clientSecret
session("redirectURI") = redirectURI
session("scope") = scope
session("authCompanyId") = authCompanyId
%>
