<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->

<%
' Make a request to the draft table to check if there's an existing draft
' and check if the current user is the author of said draft.
isDraftAuthor = true
draftExists = false
draftAuthor = ""

strQuery = "SELECT experimentJSON, unsavedChanges " &_
        "FROM experimentDrafts " &_
        "WHERE experimentId= ? " &_
        "AND experimentType= ?"

Set cmd = server.createobject("ADODB.Command")
cmd.ActiveConnection = connAdm
cmd.CommandText = strQuery
cmd.CommandType = adCmdText

cmd.Parameters.Append(cmd.CreateParameter("@experimentId", adInteger, adParamInput, len(experimentId), experimentId))
cmd.Parameters.Append(cmd.CreateParameter("@experimentType", adInteger, adParamInput, len(experimentType), experimentType))

set rec = cmd.execute

if not rec.eof then
    draftExists = not isNull(rec("unsavedChanges"))
    set expDraft = JSON.parse(rec("experimentJSON"))
    draftAuthor = CSTR(expDraft.get("userId"))

    if draftAuthor <> "" then
        isDraftAuthor = (draftAuthor = CSTR(session("userId")))
        rec.close

        nameQuery = "SELECT firstName + ' ' + lastName as username FROM users WHERE id=?"
        
        Set nameCmd = server.createobject("ADODB.Command")
        nameCmd.ActiveConnection = connAdm
        nameCmd.CommandText = strQuery
        nameCmd.CommandType = adCmdText
        nameCmd.commandText = nameQuery
        nameCmd.Parameters.Append(cmd.CreateParameter("@userId", adInteger, adParamInput, len(draftAuthor), draftAuthor))

        set rec = nameCmd.execute
        draftAuthor = rec("username")
        rec.close

    end if
end if

set rec = nothing
%>