
<%
    If whichServer = "PROD" then
%>

<script src="js/React/react.production.min.js" crossorigin="anonymous"></script>
<script src="js/React/react-dom.production.min.js"></script>
<script src="js/React/react-table.js"></script>
<script src="js/React/material-Ui.js" crossorigin="anonymous"></script>

<%
    Else
%>

<script src="js/React/react.development.js" crossorigin="anonymous"></script>
<script src="js/React/react-dom.development.js"></script>
<script src="js/React/react-table.js"></script>
<script src="js/React/material-Ui.js" crossorigin="anonymous"></script>

<%
    End If
%>
