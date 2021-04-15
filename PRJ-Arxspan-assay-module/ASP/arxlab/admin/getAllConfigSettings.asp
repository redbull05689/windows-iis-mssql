<%
    ' Helper function to construct an adminSvc setting URL. These are used as keys in the cache.
    function buildCacheKeyUrl(adminSvcUrl, settingName)
        buildCacheKeyUrl = adminSvcUrl & "/appConfig/settings/" & settingName & "/"
    end function

    ' Start by fetching all of the config settings.
    cfgSettings = getAllCfgSettings(session("companyId"))

    ' That comes back as a string, so parse it into JSON next and fetch the
    ' adminSvcEndpoint while we're at it.
    set cfgJson = JSON.parse(cfgSettings)
    adminSvcEndpoint = getAdminSvcEndpoint()

    ' Construct the list of cached items.
    set cacheList = JSON.parse("[]")

    if Application("UseCaching") then
        for each cfgObj in cfgJson
            ' Construct the object for this item.
            set cacheObj = JSON.parse("{}")

            ' Grab the setting's name and use it to build the adminSvc URL for it.
            settingName = cfgObj.get("Name")
            urlNoCompanyId = buildCacheKeyUrl(adminSvcEndpoint, settingName)

            ' We'll start with the companyId URL.
            cacheKey = urlNoCompanyId & session("companyId")

            ' Check the cache for this entry. If it isn't there, construct the URL
            ' for the default company ID, 0, and check that as well.
            missingCacheEntry = IsEmpty(Application(cacheKey))
            if missingCacheEntry Then
                cacheKey = urlNoCompanyId & "0"
                missingCacheEntry = IsEmpty(Application(cacheKey))
            end if

            ' Finally, if we do have this entry in the cache, populate the cacheObj
            ' with the appropriate values, then push the object into the cacheList.
            if not missingCacheEntry Then
                cacheObj.set "Name", settingName
                cacheObj.set "Key", cacheKey
                cacheObj.set "Value", UnescapeValue(Application(cacheKey))
                cacheObj.set "DateSet", CStr(Application(cacheKey & "_dateCached"))

                ' We need to JSON stringify the cacheObject before pushing it in because
                ' otherwise the HTML is given a list of [Object object]s.
                cacheList.push(JSON.stringify(cacheObj))
            end if
        next
    end if

    stringifiedCacheList = JSON.stringify(cacheList)
%>