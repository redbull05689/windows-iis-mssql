<%
' gets the configuration data from the cache if UseCaching is set to true, otherwise, it gets it from the admin (web) service
function getCfgData(url)
	If Application("UseCaching") = True Then
		cacheKey = url
		cacheKeyTime = cacheKey & "_DateCached"
		If (IsEmpty(Application(cacheKey))) Or ((Not IsEmpty(Application(cacheKeyTime))) And (DateDiff("n", Application(cacheKeyTime), Now()) > Application("MaxCacheAge"))) Then
            ' get the data from the admin service
			dataToCache = getCfgDataFromWebService(url)

            ' add the data to the cache
			Application.Lock
			Application(cacheKey) = dataToCache
			Application(cacheKeyTime) = Now()
			Application.UnLock
		End If

        ' return the cached data
        getCfgData = Application(cacheKey)
	Else
        ' fetch the data from the admin service and return it
		getCfgData = getCfgDataFromWebService(url)
	End If
end Function

function getCfgDataFromWebService(url)
    Set http = CreateObject("MSXML2.ServerXMLHTTP")
    
    http.open "GET", url, True

    http.setRequestHeader "Content-Type","application/json"
    http.setRequestHeader "Content-Length",Len(data)
    http.SetTimeouts 180000,180000,180000,180000
    ' ignore ssl cert errors
    http.setOption 2, 13056
    http.send data
	http.waitForResponse(60)

    ' If we don't have a valid response from the adminSvc, then the data
    ' retrieved can't be used.
    if http.status <> 200 then
        response.write "Bad response from AdminSvc."
        response.end
    else
        getCfgDataFromWebService = http.responseText
    end if
End Function

function checkIfWorkflowManager(userId)
    adminSvcEndpoint = getAdminSvcEndpoint()
    cfgUrl = adminSvcEndpoint & "/users/" & userId & "/isMemberOfWorkflowManagers"
    checkIfWorkflowManager = getCfgData(cfgUrl)
end function

' Function to fetch all app config settings.
function getAllCfgSettings(companyId)
    adminSvcEndpoint = getAdminSvcEndpoint()
    ' If we don't have a number as our company ID, then default to 0.
    companyId = normalizeIntSetting(companyId)
    cfgUrl = adminSvcEndpoint & "/appconfig/settings/" & companyId
    settingList = getCfgData(cfgUrl)
    getAllCfgSettings = settingList
end function

' Retrieves the given settingName from the admin service if it has yet to be fetched
' using the company ID 0, which tells the admin svc to fetch from the global defaults.
function getDefaultSingleAppConfigSetting(settingName)
    companyId = "0"
    if session("overrideDb") = "BROAD" then
        companyId = "62"
    end if
    getDefaultSingleAppConfigSetting = getCompanySpecificSingleAppConfigSetting(settingName, companyId)
end function

' Retrieves the given settingName from the admin service if it has yet to be fetched for
' the given companyId.
function getCompanySpecificSingleAppConfigSetting(settingName, companyId)
    ' Sanity check to make sure we have an actual setting name so we're not operating on an empty string.
    if settingName = "" then
        response.write "Cannot fetch blank setting name."
        response.end
    else
        ' If we don't have a number as our company ID, then default to 0.
        companyId = normalizeIntSetting(companyId)
        adminSvcEndpoint = getAdminSvcEndpoint()
        cfgUrl = adminSvcEndpoint & "/appConfig/settings/" & settingName & "/" & CStr(companyId) ' Making absolutely sure that the company ID is a string.
        setting = getCfgData(cfgUrl)
        getCompanySpecificSingleAppConfigSetting = unescapeValue(setting)
    end if
end function

' Retrieves the elnDataBaseServerIp from the admin service if it has yet to be fetched.
function getElnDataBaseServerIp()
    getElnDataBaseServerIp = getDefaultSingleAppConfigSetting("elnDataBaseServerIp")
end function

' Retrieves the elnDataBaseName from the admin service if it has yet to be fetched.
function getElnDataBaseName()
    getElnDataBaseName = getDefaultSingleAppConfigSetting("elnDataBaseName")
end function

' Retrieves the elnDataBaseUserName from the admin service if it has yet to be fetched.
function getElnDataBaseUserName()
    getElnDataBaseUserName = getDefaultSingleAppConfigSetting("elnDataBaseUserName")
end function

' Retrieves the elnDataBaseUserPassword from the admin service if it has yet to be fetched.
function getElnDataBaseUserPassword()
    getElnDataBaseUserPassword = getDefaultSingleAppConfigSetting("elnDataBaseUserPassword")
end function

' Retrieves the elnDataBaseAdminUserName from the admin service if it has yet to be fetched.
function getElnDataBaseAdminUserName()
    getElnDataBaseAdminUserName = getDefaultSingleAppConfigSetting("elnDataBaseAdminUserName")
end function

' Retrieves the elnDataBaseAdminPassword from the admin service if it has yet to be fetched.
function getElnDataBaseAdminPassword()
    getElnDataBaseAdminPassword = getDefaultSingleAppConfigSetting("elnDataBaseAdminPassword")
end function

' Retrieves the logDataBaseServerIp from the admin service if it has yet to be fetched.
function getLogDataBaseServerIp()
    getLogDataBaseServerIp = getDefaultSingleAppConfigSetting("logDataBaseServerIp")
end function

' Retrieves the logDataBaseName from the admin service if it has yet to be fetched.
function getLogDataBaseName()
    getLogDataBaseName = getDefaultSingleAppConfigSetting("logDataBaseName")
end function

' Retrieves the logDataBaseUserName from the admin service if it has yet to be fetched.
function getLogDataBaseUserName()
    getLogDataBaseUserName = getDefaultSingleAppConfigSetting("logDataBaseUserName")
end function

' Retrieves the logDataBasePassword from the admin service if it has yet to be fetched.
function getLogDataBasePassword()
    getLogDataBasePassword = getDefaultSingleAppConfigSetting("logDataBasePassword")
end function

' Retrieves the logTableName from the admin service if it has yet to be fetched.
function getlogTableName()
    getlogTableName = getDefaultSingleAppConfigSetting("logTableName")
end function

' Retrieves the adminServiceEndpointUrl from the environment variables if it has yet to be fetched.
function getAdminSvcEndpoint()
    if session("adminServiceEndpointUrl") = "" then
        set scriptShell = createobject("WScript.Shell")
        session("adminServiceEndpointUrl") = scriptShell.ExpandEnvironmentStrings("%ARXSPAN_ADMIN_SVC_ENDPOINT_URL%")
        set scriptShell = nothing
    end if
    getAdminSvcEndpoint = session("adminServiceEndpointUrl")
end function

' Unescapes values coming back from the AdminSvc.
' 5248 - Stripping out double-quotes so that the application doesn't try to use the values with quotation marks.
function unescapeValue(valToUnescape)
    unescapeValue = Replace(valToUnescape, "\\", "\")
    unescapeValue = Replace(unescapeValue, """", "")
end function

' Helper function to check a company-specific boolean setting.
function checkBoolSettingForCompany(settingName, companyId)
    setting = getCompanySpecificSingleAppConfigSetting(settingName, companyId)
    returnBool = CStr(setting) = "1"
    checkBoolSettingForCompany = returnBool
end function

' Helper function to normalize int settings to output as integers.
function normalizeIntSetting(setting)
    normalizedSetting = 0
    if isNumeric(setting) then
        normalizedSetting = CInt(setting)
    end if
    normalizeIntSetting = normalizedSetting
end function
%>