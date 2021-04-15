<!-- #include virtual="/_inclds/sessionInit.asp" -->

<%isAjax=true%>
<!-- #include file="../_inclds/globals.asp"-->

<%

    userId = request.form("userId")
    email = request.form("email")
    pass = request.form("pass")
    expId = request.form("expId")
    expType = request.form("expType")
    expRev = request.form("expRev")
    sso = request.form("sso")

	Call getConnectedAdm
    Set rec = server.CreateObject("ADODB.RecordSet")
    strQuery = buildCompanyUserQuery(session("companyId"), request.form("email"), request.form("pass"))
    rec.open strQuery, connAdm, 3, 3
    if not rec.eof then
        a = addSignature(expId,expType,expRev,userId)
        response.write(a)
    ElseIf sso = "True" Then        
        Set ssoRec = server.CreateObject("ADODB.RecordSet")
        ssoQuery = "SELECT * FROM experimentSignatures WHERE userId = " & SQLClean(session("userId"),"N","S") & " AND experimentId=" & SQLClean(expId,"N","S") & " AND experimentType = " & SQLClean(expType,"N","S")

        ssoRec.open ssoQuery, connAdm, 3, 3
        if not ssoRec.eof then
            a = addSignature(expId,expType,expRev,userId)
            response.write(a)
        else
            response.status = "500 Internal Server Error"
        end if
        Set ssoRec = nothing
    else
        response.status = "500 Internal Server Error"
    end if    
    set rec = nothing

    Function buildCompanyUserQuery(userCompany, userEmail, userPassword)
        If userCompany <= 0 Then
            companyQuery = " in (SELECT companyId FROM(" & getCompanyQuery(userEmail) & ")q)"
        Else
            companyQuery = "=" & SQLClean(userCompany,"N","S")
        End If
        
        buildCompanyUserQuery = "SELECT * FROM usersView WHERE email="&SQLClean(userEmail,"T","S")& " AND password="&SQLClean(userPassword,"PW","S")& " AND companyId"
        buildCompanyUserQuery = buildCompanyUserQuery & companyQuery
        buildCompanyUserQuery = buildCompanyUserQuery & " AND password is not null and (companyId<>4 or id=115 or email=" & SQLClean("support@arxspan.com","T","S") & ") and ((limitLoginAttempts=0 or limitLoginAttempts is null) or (limitLoginAttempts=1 and (loginAttempts<=maxLoginAttempts or loginAttempts is null))) and companyId<>62"
    End Function

%>