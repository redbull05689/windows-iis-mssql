<%
    ' Uses a regex to trim whitespace from either side of the input string.
    function trimWhiteSpace(str)
        Set myRegExp = New RegExp
        myRegExp.IgnoreCase = True
        myRegExp.Global = True
        myRegExp.Pattern = "^\s+|\s+$"
        trimWhiteSpace = myRegExp.Replace(str, "")
    end function
%>