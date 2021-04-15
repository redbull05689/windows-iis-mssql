<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="registration/_inclds/lib_reg.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"--><%
jChemRegDB = getCompanySpecificSingleAppConfigSetting("jChemRegDataBaseName", session("companyId"))
regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
regNumberPrefix = getCompanySpecificSingleAppConfigSetting("regNumberPrefix", session("companyId"))
Set rec = server.CreateObject("ADODB.RecordSet")
projId = request.form("id")
strQuery = "SELECT * " &_
"FROM linksProjectReg " &_
"WHERE projectId={projectId} "
strQuery = Replace(strQuery, "{projectId}", projId)
whichTable = regMoleculesTable
rec.open strQuery,conn

isAdministrator = isAdminUser(session("userId"))

cdIds = "("

Do While Not rec.eof
    cdIds = cdIds & rec("cd_id") & ","
    rec.movenext
Loop


cdIds = LEFT(cdIds, len(cdIds) - 1) & ")"
rec.close

regStrQuery = "SELECT cd_id,reg_id,cd_timestamp,groupId,just_reg,just_batch,cd_molweight FROM " & regMoleculesTable & " WHERE projectId =" & projId 

If cdIds <> ")" Then
	regStrQuery = regStrQuery & " UNION " &  "SELECT cd_id,reg_id,cd_timestamp,groupId,just_reg,just_batch,cd_molweight FROM " & regMoleculesTable & " WHERE cd_id in " & cdIds
End If

Set idRec = server.CreateObject("ADODB.RecordSet")

idRec.open regStrQuery, jchemRegConn,adUseClient,adLockReadOnly

Do While Not idRec.eof

    Set structureGroupIds = JSON.parse(getGroupIdsThatHaveStructure())

    cd_id = idRec("cd_id")
    molweight = ""
    reg_id = idRec("reg_id")
    date_created = idRec("cd_timestamp")
    
    group_id = Null
	If whichTable = regMoleculesTable Then
		group_id = idRec("groupId")
	End If
    
    hasStructure = False
    If structureGroupIds.Exists(group_id) Or IsNull(group_id) Then
        hasStructure = True
    End If

    reg_number = idRec("just_reg")
    batch_number = idRec("just_batch")

    if hasStructure then

        groupIdQuery = "SELECT * FROM groupCustomFields WHERE id="&SQLClean(groupId,"N","S")&" and not groupPrefix is null and groupPrefix <> ''"
        Set groupIdRec = server.CreateObject("ADODB.RecordSet")
        groupIdRec.open groupIdQuery,jchemRegConn,3,3
            If Not groupIdRec.eof then
                groupPrefix = groupIdRec("groupPrefix")
            Else
                groupPrefix = regNumberPrefix
            End if
        groupIdRec.close
        
        chem_structure = CX_getSvgByCdId(jChemRegDB, regMoleculesTable, cd_id, 200, 200)
        molweight = Round(idRec("cd_molweight"), 2)
    Else
        idQuery = "SELECT * FROM groupCustomFieldFields WHERE isIdentity=1 AND groupId="&SQLClean(group_id,"N","S")
        set fieldRec = server.CreateObject("ADODB.RecordSet")
        fieldRec.open idQuery, jchemRegConn, 3,3 
        Do While Not fieldRec.eof
            Set nameRec = server.CreateObject("ADODB.RecordSet")
            nameQuery = "SELECT * FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(cd_id,"N","S")
            nameRec.open nameQuery,jchemRegConn,3,3

            chem_structure = nameRec(CStr(fieldRec("actualField")))
            
            nameRec.close
            Set nameRec = nothing
            fieldRec.movenext
        loop
        fieldRec.close

        idQuery = "SELECT * FROM groupCustomFields WHERE id="&SQLClean(group_id,"N","S")&" and not groupPrefix is null and groupPrefix <> ''"
        fieldRec.open idQuery,jchemRegConn,3,3
        If Not fieldRec.eof then
            groupPrefix = fieldRec("groupPrefix")
        Else
            groupPrefix = regNumberPrefix
        End if
        fieldRec.close

        chem_structure = chem_structure
    end if

    delete_link = ""
    If projectOwner or (session("canDelete") and session("role")="Admin") Then
        delete_link = "<a href='javascript:void(0);' onclick='deleteProjectMolecule(" & projId & ", " & cd_id & ")'> <img src='" & mainAppPath & "/images/cross_2_1x.png' class='png' height='12' width='12' border='0'></a>"
    End if
    
    reg_link = makeRegLink(groupPrefix, reg_number, batch_number)
    
    response.write(reg_link & ":::" &_
                    chem_structure & ":::" &_
                    molweight & ":::" &_
                    date_created & ":::" &_
                    delete_link & ";;;")

    idRec.movenext
Loop

'response.write cdIds
response.end
%>