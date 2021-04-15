<%
' This login has been deprecated. redirect the user to the MSKCC SAML login

set scriptShell = createobject("WScript.Shell")
whichServer = scriptShell.ExpandEnvironmentStrings("%WHICHSERVER%")
Set scriptShell = Nothing

urlhost = "eln"
if whichServer = "DEV" then
	urlhost = "stage"
elseif whichServer = "MODEL" then
	urlhost = "model"
elseif whichServer = "BETA" then
	urlhost = "beta"
elseif whichServer = "PROD" then
	urlhost = "eln"
end if

Response.Redirect "https://" & urlhost & ".arxspan.com/saml/mskcc"
%>