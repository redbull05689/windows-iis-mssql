<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/_inclds/globals.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->

<%

    userId = request.form("userId")
    email = request.form("email")
    pass = request.form("pass")
    expId = request.form("expId")
    expType = request.form("expType")
    expRev = request.form("expRev")

    Set rec = server.CreateObject("ADODB.RecordSet")
    Call getconnectedadm
    strQuery = "SELECT email, password FROM users WHERE id=" & userId
    'rec.open strQuery, connadm, 3, 3
    if false then 'not rec.eof then
        response.write(rec("email"))
        response.write(" ")
        response.write(rec("password"))
    else
        response.write(userId)
        response.write(" ")
        response.write(email)
        response.write(" ")
        response.write(pass)
        response.write(" ")
        response.write(expId)
        response.write(" ")
        response.write(expType)
        response.write(" ")
        response.write(expRev)
    end if
%>