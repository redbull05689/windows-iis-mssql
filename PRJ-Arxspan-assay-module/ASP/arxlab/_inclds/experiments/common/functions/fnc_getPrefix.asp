<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="fnc_workflowComms.asp"-->
<%
Function GetPrefix(experimentType)
  GetPrefix = ""

  If (experimentType <> "") And (not IsObject(Session("prefix_" & experimentType))) Then
    Set prefixRec = server.CreateObject("ADODB.RecordSet")
    strQuery = "SELECT prefix " &_
                "FROM experimentTypes " &_
                "WHERE id=" & experimentType
    testQuery = strQuery
    prefixRec.open strQuery, conn
    
    If Not prefixRec.eof Then
      Session("prefix_" & experimentType) = prefixRec("prefix")
    End If
    prefixRec.close
  End If

  GetPrefix = Session("prefix_" & experimentType)
End Function

Function GetAbbreviation(experimentType)
  GetAbbreviation = ""

  If not IsObject(Session("abbrv_" & experimentType)) Then
    Set abbRec = server.CreateObject("ADODB.RecordSet")
    strQuery = "SELECT abbrivName " &_
                "FROM experimentTypes " &_
                "WHERE id=" & experimentType
    abbRec.open strQuery, conn
    
    If Not abbRec.eof Then
      Session("abbrv_" & experimentType) = abbRec("abbrivName")
    End If
    abbRec.close
  End If

  GetAbbreviation = Session("abbrv_" & experimentType)
End Function

Function GetTypeId(expTypeName)
  GetTypeId = ""

  If (expTypeName <> "") And (not IsObject(Session("id_" & expTypeName))) Then

    ' chemistry exps don't actually have a prefix, so catch that here and
    ' set the value accordingly.
    if expTypeName = "chem" then
      Session("id_" & expTypeName) = "1"
    else
      Set prefixRec = server.CreateObject("ADODB.RecordSet")
      strQuery = "SELECT id " &_
                  "FROM experimentTypes " &_
                  "WHERE prefix=" & SQLCLEAN(expTypeName, "T", "S")
      testQuery = strQuery
      prefixRec.open strQuery, conn
      
      If Not prefixRec.eof Then
        Session("id_" & expTypeName) = prefixRec("id")
      End If
      prefixRec.close
    end if
  End If

  GetTypeId = Session("id_" & expTypeName)
End Function

Function GetFullExpType(experimentType, requestTypeId)
  GetFullExpType = ""

  If cStr(experimentType) = "5" Then
    if (requestTypeId <> "") then
      configUrl = "/requesttypes?{rid}&includeDisabled=false&isConfigPage=false&appName=ELN"
      configUrl = Replace(configUrl, "{rid}", "requestTypeId=" & requestTypeId)
      configInfo = configGet(configUrl)
      Set customData = JSON.parse(configInfo)
      For i=0 To customData.length - 1
        Set thisType = customData.Get(i)
        If Not IsObject(Session("custType_" & thisType.Get("id"))) Then
          Session("custType_" & thisType.Get("id")) = thisType.Get("displayName")
        End If
      Next
  	  GetFullExpType = Session("custType_" & requestTypeId)
    end if
  Else
	  If not IsObject(Session("expType_" & experimentType)) Then
		  Set expRec = server.CreateObject("ADODB.RecordSet")
		  strQuery = "SELECT type " &_
				"FROM experimentTypes " &_
				"WHERE id=" & experimentType
		  expRec.open strQuery, conn
		  
		  If Not expRec.eof Then
			Session("expType_" & experimentType) = expRec("type")
		  End If
		  expRec.close
	  End If

	  GetFullExpType = Session("expType_" & experimentType)
  End If
End Function

Function GetFullName(prefix, name, isDBName)
    If prefix = "" And isDBName Then
        name = CapitalizeFirstLetter(name)
    End If
    GetFullName = prefix & name
End Function

Function CapitalizeFirstLetter(text)
  CapitalizeFirstLetter = UCase(Left(text, 1)) & LCase(Right(text, Len(text) - 1))
End Function

Function GetExperimentPage(prefix)
  If prefix <> "" Then
    GetExperimentPage = prefix & "-experiment.asp"
  Else
    GetExperimentPage = session("expPage")
  End If
End Function

Function GetUploadPage(prefix)
  uploadSuffix = "upload-file.asp"
  If prefix <> "" Then
    uploadSuffix = "-" & uploadSuffix
  End If
  GetUploadPage = prefix & uploadSuffix
End Function

Function GetSubsectionId(prefix)
  If prefix <> "" Then
    GetSubsectionId = prefix & "-experiment"
  Else
    GetSubsectionId = "experiment"
  End If
End Function

Function GetExperimentView(prefix)
  If prefix <> "" Then
    GetExperimentView = prefix & "ExperimentsView"
  Else
    GetExperimentView = "experimentView"
  End If
End Function
%>