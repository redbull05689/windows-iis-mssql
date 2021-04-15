<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
ran1 = CHR(RandomNumber(97,122))
session(ran1) = CHR(RandomNumber(97,122))

Response.Write ran1 & " " & Session(ran1)

Function RandomNumber(LowNumber, HighNumber)
    RANDOMIZE
    RandomNumber = Round((HighNumber - LowNumber + 1) * Rnd + LowNumber)
End Function
%>