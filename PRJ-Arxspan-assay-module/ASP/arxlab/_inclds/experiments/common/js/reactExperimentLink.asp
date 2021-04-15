<div id="reactLinkingBtnDiv" companyid="<%=session("companyId")%>" objecttype="5" objectid="<%=allExpId%>" appname="ELN" ></div>

<script>
    $.ajax({url: '/node/Linking'}).then(function(resp) {
        $("#reactLinkingBtnDiv").html(resp)
    })
</script>