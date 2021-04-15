
<%
    ' fnc to get groups
   function getGroups() 

        Set nRec = server.CreateObject("ADODB.RecordSet")
        strQuery = "SELECT groupId, groupName FROM groupMembersView WHERE userId="&SQLClean(session("userId"),"N","S")&" ORDER BY groupName"
        nRec.open strQuery,conn,3,3
        
        Set groupList = JSON.parse("[]")
        
        Do While Not nRec.eof
            groupId = nRec("groupId")
            groupName = nRec("groupName")

            Set groupObj = JSON.parse("{}")

                groupObj.set "groupId", groupId
                groupObj.set "groupName", groupName
                groupList.push(groupObj)

            nRec.movenext
        Loop
        nRec.close
        getGroups = JSON.stringify(groupList)
      
    End function 
%>