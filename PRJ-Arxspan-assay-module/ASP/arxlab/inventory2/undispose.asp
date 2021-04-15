<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
titleData = "Arxspan Inventory"
%>
<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="_inclds/header.asp"-->
<script>
    //Hide the left nav
    $("#aNav").hide();
    $("#tree").hide();
    $("#contentTable tbody tr td div").first().append('<td style="background: white;" ><a href= "index.asp">back to main page</a></td>');
</script>


<h1>Undispose</h1>
<br />
<p>Enter Barcodes to undispose sepearted by linebreaks or commas</p>
<p><small>It can be very slow</small></p>
<form action="/undispose.asp" id="undisposeForm">
    <textarea rows="10" cols="50" id="undisposeIDs" name="ids" form="undispose"></textarea>
    <br />
    <input type="button" value="Submit Barcodes to Undispose" onClick="submitUndispose();"/>
</form>
<br />
<div id="response"></div>


<script>

function findBarcode(barcodeValue){

}

function submitUndispose(){
    $("#response").html("<h3>Start</h3>");

    vals = $("#undisposeIDs").val();
    valsArray = vals.split(/[\n,]+/);
    console.log("valsArray");
    console.log(valsArray);
    valsArray.forEach(function(barcode){
        console.log("finding ID for barcode: " + barcode);
        $("#response").append("<p>finding ID for barcode: " + barcode + "</p>");
        if(barcode !== ""){
            payload = {};
            payload["rpp"] = 1;
            payload["action"] = "next";
            payload["collection"] = "inventoryItems";
            payload["list"] = true;
            query = {};
            query["barcode"] = barcode.replace(/\n/,"").trim();
            query["disposed"] = {"$ne":"false"};
            payload["query"] = query;
            restCallA("/getList/","POST",payload,function(r){
                console.log(r);
                if (typeof r != 'undefined'){
                    if (typeof r.forms != 'undefined'){
                        if (typeof r.forms[0] != 'undefined'){
                            theId = r.forms[0].id
                            $("#response").append("<p>Found ID: " + theId + "</p>");
                            thepayload = {};
                            thepayload['connectionId'] = connectionId;
                            thepayload['ids'] = theId.toString();
                            
                            console.log("Sending thePayload: ");
                            console.log(thepayload);
                            console.log("end thepayload")

                            $.ajax({
                                url: 'invp.asp',
                                type: 'POST',
                                dataType: 'html',
                                data: {
                                    //async: "async",
                                    verb: "POST",
                                    url: "/undispose/",
                                    data: JSON.stringify(thepayload),
                                    r: Math.random()
                                },
                                async: true
                            })
                            .done(function(response) {
                                $("#response").append(response);
                            })
                        }
                    }
                }
            });
        }
    })
  
}
</script>




<!-- #include file="_inclds/footer.asp"-->