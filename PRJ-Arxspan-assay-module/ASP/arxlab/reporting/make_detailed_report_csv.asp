<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="functions/fnc_get_report_data_csv.asp"-->
<%
server.ScriptTimeout = 10000
Response.Clear()
Response.Buffer = True
Response.AddHeader"content-disposition", "attachment;filename=detailed_report.csv"
Response.Charset = ""
Response.ContentType = "application/text"

' write out the headers
response.write("Experiment Type," &_
				"Last Name," &_
				"First Name," &_
				"User Email," &_
				"Notebook Name," &_
				"Notebook Description," &_
				"Experiment Name," &_
				"Experiment Description," &_
				"Status," &_
				"Reopened," &_
				"Requested Witness," &_
				"User Experiment Name," &_
				"Experiment Note," &_
				"Notebook Parent Project Name," &_
				"Notebook Parent Project Description," &_
				"Notebook Project Name," &_
				"Notebook Project Description," &_
				"Project Name," &_
				"Project Description," &_
				"Parent Project Name," &_
				"Parent Project Description," &_
				"Date Created," &_
				"Date Last Modified," &_
				"Sign Close Date," &_
				"Witnessed Date," &_
				vbCrLf)

set inputData = JSON.parse(request.form("data"))

' get some values from the input data
set groups = inputData.get("groups")
dateType = SQLClean(inputData.get("typeDate"), "T", "T")
set statusArray = inputData.get("status")
dateBefore = SQLClean(inputData.get("dateBefore"), "T", "T")
dateAfter = SQLClean(inputData.get("dateAfter"), "T", "T")
idStr = inputData.get("userIds")

' process for each experiment type
set expTypes = inputData.get("expTypes")

' hack to get this to cooperate with me and go through the experiment
dim expTypesDim
redim expTypesDim(expTypes.length - 1)
for i=0 to expTypes.length - 1
	expTypesDim(i) = expTypes.get(i)
next

for each expType in expTypesDim

	thisExpType = CSTR(expType)
	thisReqType = ""
    thisReqName = ""

	thisExpTypeDim = Split(thisExpType, "_")
	if Ubound(thisExpTypeDim) > 0 Then
		thisExpType = thisExpTypeDim(0)
		thisReqType = thisExpTypeDim(1)
		thisReqName = thisExpTypeDim(2)
	end if

    Call getReportData(thisExpType, idStr, thisReqType, statusArray, thisReqName, groups, dateType, dateBefore, dateAfter)
Next
%>