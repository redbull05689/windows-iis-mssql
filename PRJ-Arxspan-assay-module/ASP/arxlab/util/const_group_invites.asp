<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<%
if session("userId") = "2" And 1=2 then

	call getconnectedAdm
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery  = "SELECT * FROM notebooks WHERE id in (select notebookId from notebookIndexView WHERE userId=773) and id not in (select notebookId from groupNotebookInvitesView WHERE companyId=9)"
	'553,535,464,465,466,467,477,938,948,949,950,951,952,953,954,955,956,957,958,959,960,961,962,963,964,965,973,974,975,976,977,978,979,980,981,982,989,992,993,994,998,999,1000,1001,1002,1003,1004,1005,1006,976,977,978,979,980,981,982,554,555,556,557,558,559,560,561,562,563,564,565,566,567,568,569,571,572,573,574,575,576,633,634,635,636,637,642,643,644,645,646,647,648,649,650,651,729,730,731,732,733,734,735,744,745,746,747,748,749,750,751,756,757,758,759,760,761,762
	rec.open strQuery,connAdm,3,3
	Do While Not rec.eof
		strQuery2 = "INSERT INTO groupNotebookInvites(notebookId,sharerId,shareeId,accepted,denied,canRead,canWrite,readOnly) values(" &_
						SQLClean(rec("id"),"N","S") & "," &_
						SQLClean(rec("userId"),"N","S") & "," &_
						SQLClean("71","N","S") & ",1,0,1,0,1)"
		response.write(strQuery)
		connAdm.execute(strQuery2)
		rec.movenext
	loop
	call disconnectadm
end If
%>