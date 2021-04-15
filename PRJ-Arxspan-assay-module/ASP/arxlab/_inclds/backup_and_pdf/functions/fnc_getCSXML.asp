<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="../../experiments/common/functions/fnc_convertToCDXML.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<!-- #include file="../../../_inclds/escape_and_filter/functions/fnc_decodeBase64Motobit.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
Function clean(instring)

' if instring is null, the Replace function calls will explode
' this will ensure we return at least an empty string when we are building the XML
If isNull(inString) Then
	instring = ""
End If

instring = Replace(instring,Chr(38),"&amp;")
instring = Replace(instring,"&apos;",chrw(39))
instring = Replace(instring,"&iexcl;",chrw(161))
instring = Replace(instring,"&cent;",chrw(162))
instring = Replace(instring,"&pound;",chrw(163))
instring = Replace(instring,"&curren;",chrw(164))
instring = Replace(instring,"&yen;",chrw(165))
instring = Replace(instring,"&brvbar;",chrw(166))
instring = Replace(instring,"&sect;",chrw(167))
instring = Replace(instring,"&uml;",chrw(168))
instring = Replace(instring,"&copy;",chrw(169))
instring = Replace(instring,"&ordf;",chrw(170))
instring = Replace(instring,"&laquo;",chrw(171))
instring = Replace(instring,"&not;",chrw(172))
instring = Replace(instring,"&shy;",chrw(173))
instring = Replace(instring,"&reg;",chrw(174))
instring = Replace(instring,"&macr;",chrw(175))
instring = Replace(instring,"&deg;",chrw(176))
instring = Replace(instring,"&plusmn;",chrw(177))
instring = Replace(instring,"&sup2;",chrw(178))
instring = Replace(instring,"&sup3;",chrw(179))
instring = Replace(instring,"&acute;",chrw(180))
instring = Replace(instring,"&micro;",chrw(181))
instring = Replace(instring,"&para;",chrw(182))
instring = Replace(instring,"&middot;",chrw(183))
instring = Replace(instring,"&cedil;",chrw(184))
instring = Replace(instring,"&sup1;",chrw(185))
instring = Replace(instring,"&ordm;",chrw(186))
instring = Replace(instring,"&raquo;",chrw(187))
instring = Replace(instring,"&frac14;",chrw(188))
instring = Replace(instring,"&frac12;",chrw(189))
instring = Replace(instring,"&frac34;",chrw(190))
instring = Replace(instring,"&iquest;",chrw(191))
instring = Replace(instring,"&Agrave;",chrw(192))
instring = Replace(instring,"&Aacute;",chrw(193))
instring = Replace(instring,"&Acirc;",chrw(194))
instring = Replace(instring,"&Atilde;",chrw(195))
instring = Replace(instring,"&Auml;",chrw(196))
instring = Replace(instring,"&Aring;",chrw(197))
instring = Replace(instring,"&AElig;",chrw(198))
instring = Replace(instring,"&Ccedil;",chrw(199))
instring = Replace(instring,"&Egrave;",chrw(200))
instring = Replace(instring,"&Eacute;",chrw(201))
instring = Replace(instring,"&Ecirc;",chrw(202))
instring = Replace(instring,"&Euml;",chrw(203))
instring = Replace(instring,"&Igrave;",chrw(204))
instring = Replace(instring,"&Iacute;",chrw(205))
instring = Replace(instring,"&Icirc;",chrw(206))
instring = Replace(instring,"&Iuml;",chrw(207))
instring = Replace(instring,"&ETH;",chrw(208))
instring = Replace(instring,"&Ntilde;",chrw(209))
instring = Replace(instring,"&Ograve;",chrw(210))
instring = Replace(instring,"&Oacute;",chrw(211))
instring = Replace(instring,"&Ocirc;",chrw(212))
instring = Replace(instring,"&Otilde;",chrw(213))
instring = Replace(instring,"&Ouml;",chrw(214))
instring = Replace(instring,"&times;",chrw(215))
instring = Replace(instring,"&Oslash;",chrw(216))
instring = Replace(instring,"&Ugrave;",chrw(217))
instring = Replace(instring,"&Uacute;",chrw(218))
instring = Replace(instring,"&Ucirc;",chrw(219))
instring = Replace(instring,"&Uuml;",chrw(220))
instring = Replace(instring,"&Yacute;",chrw(221))
instring = Replace(instring,"&THORN;",chrw(222))
instring = Replace(instring,"&szlig;",chrw(223))
instring = Replace(instring,"&agrave;",chrw(224))
instring = Replace(instring,"&aacute;",chrw(225))
instring = Replace(instring,"&acirc;",chrw(226))
instring = Replace(instring,"&atilde;",chrw(227))
instring = Replace(instring,"&auml;",chrw(228))
instring = Replace(instring,"&aring;",chrw(229))
instring = Replace(instring,"&aelig;",chrw(230))
instring = Replace(instring,"&ccedil;",chrw(231))
instring = Replace(instring,"&egrave;",chrw(232))
instring = Replace(instring,"&eacute;",chrw(233))
instring = Replace(instring,"&ecirc;",chrw(234))
instring = Replace(instring,"&euml;",chrw(235))
instring = Replace(instring,"&igrave;",chrw(236))
instring = Replace(instring,"&iacute;",chrw(237))
instring = Replace(instring,"&icirc;",chrw(238))
instring = Replace(instring,"&iuml;",chrw(239))
instring = Replace(instring,"&eth;",chrw(240))
instring = Replace(instring,"&ntilde;",chrw(241))
instring = Replace(instring,"&ograve;",chrw(242))
instring = Replace(instring,"&oacute;",chrw(243))
instring = Replace(instring,"&ocirc;",chrw(244))
instring = Replace(instring,"&otilde;",chrw(245))
instring = Replace(instring,"&ouml;",chrw(246))
instring = Replace(instring,"&divide;",chrw(247))
instring = Replace(instring,"&oslash;",chrw(248))
instring = Replace(instring,"&ugrave;",chrw(249))
instring = Replace(instring,"&uacute;",chrw(250))
instring = Replace(instring,"&ucirc;",chrw(251))
instring = Replace(instring,"&uuml;",chrw(252))
instring = Replace(instring,"&yacute;",chrw(253))
instring = Replace(instring,"&thorn;",chrw(254))
instring = Replace(instring,"&yuml;",chrw(255))
instring = Replace(instring,"&OElig;",chrw(338))
instring = Replace(instring,"&oelig;",chrw(339))
instring = Replace(instring,"&Scaron;",chrw(352))
instring = Replace(instring,"&scaron;",chrw(353))
instring = Replace(instring,"&Yuml;",chrw(376))
instring = Replace(instring,"&fnof;",chrw(402))
instring = Replace(instring,"&circ;",chrw(710))
instring = Replace(instring,"&tilde;",chrw(732))
instring = Replace(instring,"&Alpha;",chrw(913))
instring = Replace(instring,"&Beta;",chrw(914))
instring = Replace(instring,"&Gamma;",chrw(915))
instring = Replace(instring,"&Delta;",chrw(916))
instring = Replace(instring,"&Epsilon;",chrw(917))
instring = Replace(instring,"&Zeta;",chrw(918))
instring = Replace(instring,"&Eta;",chrw(919))
instring = Replace(instring,"&Theta;",chrw(920))
instring = Replace(instring,"&Iota;",chrw(921))
instring = Replace(instring,"&Kappa;",chrw(922))
instring = Replace(instring,"&Lambda;",chrw(923))
instring = Replace(instring,"&Mu;",chrw(924))
instring = Replace(instring,"&Nu;",chrw(925))
instring = Replace(instring,"&Xi;",chrw(926))
instring = Replace(instring,"&Omicron;",chrw(927))
instring = Replace(instring,"&Pi;",chrw(928))
instring = Replace(instring,"&Rho;",chrw(929))
instring = Replace(instring,"&Sigma;",chrw(931))
instring = Replace(instring,"&Tau;",chrw(932))
instring = Replace(instring,"&Upsilon;",chrw(933))
instring = Replace(instring,"&Phi;",chrw(934))
instring = Replace(instring,"&Chi;",chrw(935))
instring = Replace(instring,"&Psi;",chrw(936))
instring = Replace(instring,"&Omega;",chrw(937))
instring = Replace(instring,"&alpha;",chrw(945))
instring = Replace(instring,"&beta;",chrw(946))
instring = Replace(instring,"&gamma;",chrw(947))
instring = Replace(instring,"&delta;",chrw(948))
instring = Replace(instring,"&epsilon;",chrw(949))
instring = Replace(instring,"&zeta;",chrw(950))
instring = Replace(instring,"&eta;",chrw(951))
instring = Replace(instring,"&theta;",chrw(952))
instring = Replace(instring,"&iota;",chrw(953))
instring = Replace(instring,"&kappa;",chrw(954))
instring = Replace(instring,"&lambda;",chrw(955))
instring = Replace(instring,"&mu;",chrw(956))
instring = Replace(instring,"&nu;",chrw(957))
instring = Replace(instring,"&xi;",chrw(958))
instring = Replace(instring,"&omicron;",chrw(959))
instring = Replace(instring,"&pi;",chrw(960))
instring = Replace(instring,"&rho;",chrw(961))
instring = Replace(instring,"&sigmaf;",chrw(962))
instring = Replace(instring,"&sigma;",chrw(963))
instring = Replace(instring,"&tau;",chrw(964))
instring = Replace(instring,"&upsilon;",chrw(965))
instring = Replace(instring,"&phi;",chrw(966))
instring = Replace(instring,"&chi;",chrw(967))
instring = Replace(instring,"&psi;",chrw(968))
instring = Replace(instring,"&omega;",chrw(969))
instring = Replace(instring,"&thetasym;",chrw(977))
instring = Replace(instring,"&upsih;",chrw(978))
instring = Replace(instring,"&piv;",chrw(982))
instring = Replace(instring,"&ensp;",chrw(8194))
instring = Replace(instring,"&emsp;",chrw(8195))
instring = Replace(instring,"&thinsp;",chrw(8201))
instring = Replace(instring,"&zwnj;",chrw(8204))
instring = Replace(instring,"&zwj;",chrw(8205))
instring = Replace(instring,"&lrm;",chrw(8206))
instring = Replace(instring,"&rlm;",chrw(8207))
instring = Replace(instring,"&ndash;",chrw(8211))
instring = Replace(instring,"&mdash;",chrw(8212))
instring = Replace(instring,"&lsquo;",chrw(8216))
instring = Replace(instring,"&rsquo;",chrw(8217))
instring = Replace(instring,"&sbquo;",chrw(8218))
instring = Replace(instring,"&ldquo;",chrw(8220))
instring = Replace(instring,"&rdquo;",chrw(8221))
instring = Replace(instring,"&bdquo;",chrw(8222))
instring = Replace(instring,"&dagger;",chrw(8224))
instring = Replace(instring,"&Dagger;",chrw(8225))
instring = Replace(instring,"&bull;",chrw(8226))
instring = Replace(instring,"&hellip;",chrw(8230))
instring = Replace(instring,"&permil;",chrw(8240))
instring = Replace(instring,"&prime;",chrw(8242))
instring = Replace(instring,"&Prime;",chrw(8243))
instring = Replace(instring,"&lsaquo;",chrw(8249))
instring = Replace(instring,"&rsaquo;",chrw(8250))
instring = Replace(instring,"&oline;",chrw(8254))
instring = Replace(instring,"&frasl;",chrw(8260))
instring = Replace(instring,"&euro;",chrw(8364))
instring = Replace(instring,"&image;",chrw(8465))
instring = Replace(instring,"&weierp;",chrw(8472))
instring = Replace(instring,"&real;",chrw(8476))
instring = Replace(instring,"&trade;",chrw(8482))
instring = Replace(instring,"&alefsym;",chrw(8501))
instring = Replace(instring,"&larr;",chrw(8592))
instring = Replace(instring,"&uarr;",chrw(8593))
instring = Replace(instring,"&rarr;",chrw(8594))
instring = Replace(instring,"&darr;",chrw(8595))
instring = Replace(instring,"&harr;",chrw(8596))
instring = Replace(instring,"&crarr;",chrw(8629))
instring = Replace(instring,"&lArr;",chrw(8656))
instring = Replace(instring,"&uArr;",chrw(8657))
instring = Replace(instring,"&rArr;",chrw(8658))
instring = Replace(instring,"&dArr;",chrw(8659))
instring = Replace(instring,"&hArr;",chrw(8660))
instring = Replace(instring,"&forall;",chrw(8704))
instring = Replace(instring,"&part;",chrw(8706))
instring = Replace(instring,"&exist;",chrw(8707))
instring = Replace(instring,"&empty;",chrw(8709))
instring = Replace(instring,"&nabla;",chrw(8711))
instring = Replace(instring,"&isin;",chrw(8712))
instring = Replace(instring,"&notin;",chrw(8713))
instring = Replace(instring,"&ni;",chrw(8715))
instring = Replace(instring,"&prod;",chrw(8719))
instring = Replace(instring,"&sum;",chrw(8721))
instring = Replace(instring,"&minus;",chrw(8722))
instring = Replace(instring,"&lowast;",chrw(8727))
instring = Replace(instring,"&radic;",chrw(8730))
instring = Replace(instring,"&prop;",chrw(8733))
instring = Replace(instring,"&infin;",chrw(8734))
instring = Replace(instring,"&ang;",chrw(8736))
instring = Replace(instring,"&and;",chrw(8743))
instring = Replace(instring,"&or;",chrw(8744))
instring = Replace(instring,"&cap;",chrw(8745))
instring = Replace(instring,"&cup;",chrw(8746))
instring = Replace(instring,"&int;",chrw(8747))
instring = Replace(instring,"&there4;",chrw(8756))
instring = Replace(instring,"&sim;",chrw(8764))
instring = Replace(instring,"&cong;",chrw(8773))
instring = Replace(instring,"&asymp;",chrw(8776))
instring = Replace(instring,"&ne;",chrw(8800))
instring = Replace(instring,"&equiv;",chrw(8801))
instring = Replace(instring,"&le;",chrw(8804))
instring = Replace(instring,"&ge;",chrw(8805))
instring = Replace(instring,"&sub;",chrw(8834))
instring = Replace(instring,"&sup;",chrw(8835))
instring = Replace(instring,"&nsub;",chrw(8836))
instring = Replace(instring,"&sube;",chrw(8838))
instring = Replace(instring,"&supe;",chrw(8839))
instring = Replace(instring,"&oplus;",chrw(8853))
instring = Replace(instring,"&otimes;",chrw(8855))
instring = Replace(instring,"&perp;",chrw(8869))
instring = Replace(instring,"&sdot;",chrw(8901))
instring = Replace(instring,"&lceil;",chrw(8968))
instring = Replace(instring,"&rceil;",chrw(8969))
instring = Replace(instring,"&lfloor;",chrw(8970))
instring = Replace(instring,"&rfloor;",chrw(8971))
instring = Replace(instring,"&lang;",chrw(9001))
instring = Replace(instring,"&rang;",chrw(9002))
instring = Replace(instring,"&loz;",chrw(9674))
instring = Replace(instring,"&spades;",chrw(9824))
instring = Replace(instring,"&clubs;",chrw(9827))
instring = Replace(instring,"&hearts;",chrw(9829))
instring = Replace(instring,"&diams;",chrw(9830))
instring = Replace(instring,"&diams;",chrw(9830))
instring = Replace(instring,"&diams;",chrw(9830))
instring = Replace(instring,vbcrlf,"\par ")
instring = Replace(instring,"&nbsp;","")

instring = Replace(instring,"<","&lt;")
instring = Replace(instring,">","&gt;")
instring = Replace(instring,"""","&quot;")

instring = Replace(instring,Chr(24),"")
instring = Replace(instring,Chr(4),"")
instring = Replace(instring,Chr(3),"")
instring = Replace(instring,Chr(2),"")
instring = Replace(instring,Chr(1),"")
	Set RegEx = New regexp
	RegEx.Pattern = "&amp;\s{0,100}amp;"
	RegEx.Global = True
	RegEx.IgnoreCase = True
	instring = RegEx.Replace(instring,"&amp;")
	clean = instring
End function
Function cdXMLGetParam(param,xmlData)
	'nxq this is a duplicate function
	On Error Resume next
	Set RegEx = New regexp
	RegEx.Pattern = param&"=""(.*?)"""
	RegEx.Global = True
	RegEx.IgnoreCase = True
	set matches = RegEx.Execute(xmlData)
	Set RegEx = Nothing
	cdXMLGetParam = Trim(matches(0).SubMatches(0))
	If Err.number <> 0 Then
		cdXMLGetParam = "Error Occured"
	End If
	On Error goto 0
End function

Function processWorkflowRequestSectionBACKUP(companyId, experimentId)
	requestXmlData = ""

	'get the correct row for the specified revision of this experiment
	Set expRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT requestId, requestRevisionNumber FROM custExperiments WHERE id=" & SQLClean(experimentId, "N", "S")
	expRec.open strQuery, connadm, 3, 3

	If Not expRec.eof Then
		requestId = expRec("requestId")
		requestRevisionNumber = expRec("requestRevisionNumber")

		' Use latest if zero
		if requestRevisionNumber = 0 then
			revQuery = "select top 1 revisionId " &_
						"from " &_
							"(select * " &_
							"from [ARXSPAN-ORDERS-" & whichServer & "].dbo.requestFields " &_
							"where requestId=" & requestId & ") f " &_
						"inner join [ARXSPAN-ORDERS-" & whichServer & "].dbo.requestFieldValues v " &_
						"on f.id=v.requestFieldsId " &_
						"order by revisionId desc"

			Set revRec = server.CreateObject("ADODB.RecordSet")
			revRec.open revQuery, connadm, 3, 3
			If not revRec.eof then
				requestRevisionNumber = revRec("revisionId")
			end if
			revRec.close
		end if

		If requestId > 0 And requestRevisionNumber > 0 Then
			requestUrl = "/requests/{requestId}/revision/{revisionId}/elasticSearch?appName=ELN"
			requestUrl = Replace(requestUrl, "{requestId}", CSTR(requestId))
			requestUrl = Replace(requestUrl, "{revisionId}", CSTR(requestRevisionNumber))
			requestObj = appServiceGet(requestUrl)
			
			Set requestData = JSON.parse(requestObj)
			If requestData.Exists("result") Then
				If requestData.Get("result") = "success" Then
					If requestData.Exists("data") Then
						Set values = JSON.parse(requestData.get("data"))
						
						If values.Exists("requestTypeName") Then
							requestXmlData = requestXmlData & "<object>"
							requestXmlData = requestXmlData & "<field name=""formJSON""/>"
							requestXmlData = requestXmlData & "<propertyInstances>"
							
							requestXmlData = requestXmlData & "<propertyInstance value=""" & requestData.get("data")
							requestXmlData = requestXmlData & """ ><property name=""formJSONData""/></propertyInstance>"

							requestXmlData = requestXmlData & "</propertyInstances>"
							requestXmlData = requestXmlData & "</object>"
						end if
					End If
				End If
			End If
		End If


	End If

	expRec.close()
	Set expRec = nothing

	processWorkflowRequestSectionBACKUP = requestXmlData
End Function

Function makeWrapper(companyId,experimentType,experimentId)
    ' This function makes a wrapper tag for the experiment XML that contains
    ' Notebook information, Project information Experiment header information, and Author information
    tableName = ""
	Select Case experimentType
		Case "1"
            tableName = "experimentView"
        Case "2"
            tableName = "bioExperimentsView"
        Case "3"
            tableName = "freeExperimentsView"
        Case "4"
            tableName = "analExperimentsView"
        Case "5"
            tableName = "custExperimentsView"
	End Select
	
    xmlStr = "<wrapper>"
    Set xmlRec = server.CreateObject("ADODB.Recordset")
    strQuery = "SELECT * from " & tableName & " WHERE id=" & SQLClean(experimentId,"N","S")
    xmlRec.open strQuery,conn,3,3
    If Not xmlRec.eof Then
         xmlStr = xmlStr &_
                    "<dateUpdated>" & clean(xmlRec("dateUpdated")) & "</dateUpdated>" &_
                    "<dateCreated>" & clean(xmlRec("dateSubmitted")) & "</dateCreated>" &_
                    "<userId>" & clean(xmlRec("userId")) & "</userId>" &_
                    "<userEmail>" & clean(xmlRec("email")) & "</userEmail>" &_
                    "<userName>" & clean(xmlRec("firstName")) & " " & clean(xmlRec("lastName")) & "</userName>" &_
                    "<experimentId>" & clean(xmlRec("id")) & "</experimentId>" &_
                    "<notebookName>" & clean(xmlRec("notebookName")) & "</notebookName>" &_
                    "<notebookId>" & clean(xmlRec("notebookId")) & "</notebookId>" &_
                    "<experimentName>" & clean(xmlRec("userExperimentName")) & "</experimentName>" &_
                    "<experimentDescription>" & xmlRec("details") & "</experimentDescription>" &_
                    "<experimentStatus>" & clean(xmlRec("status")) & "</experimentStatus>" &_
                    "<experimentStatusId>" & clean(xmlRec("statusId")) & "</experimentStatusId>"

		projectStr = "<projects>"
        Set projects = New LD
        strQuery = "SELECT DISTINCT projectName from linksProjectExperimentsView WHERE experimentId=" & xmlRec("id") & " and typeId="&experimentType
        Set pRec = server.CreateObject("ADODB.Recordset")
        pRec.open strQuery,conn,3,3
        Do While Not pRec.eof
            projectName = pRec("projectName")
            If Not projects.InList(projectName) Then
                projects.addItem(projectName)
                projectStr = projectStr & "<project>" & projectName & "</project>"
            End If
            pRec.movenext
        Loop
        pRec.close
        
        strQuery = "SELECT DISTINCT projectName from linksProjectNotebooksView WHERE notebookId=" & xmlRec("notebookId")
        pRec.open strQuery,conn,3,3
        Do While Not pRec.eof
            projectName = pRec("projectName")
            If Not projects.InList(projectName) Then
                projects.addItem(projectName)
                projectStr = projectStr & "<project>" & projectName & "</project>"
            End If
            pRec.movenext
        Loop
		pRec.close
		Set pRec = Nothing
		projectStr = projectStr & "</projects>"
        xmlStr = xmlStr & projectStr
    End If
    
    xmlStr = xmlStr & "</wrapper>"
    makeWrapper = xmlStr
End Function

Function addFileName(fileName, fileDesc)

	' Add FileName
	fnData =          "<object>"
	fnData = fnData & " <field name=""FileName""/>"
	fnData = fnData & " <styledText>"
	fnData = fnData & "  <data>{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil Courier New;}{\f1\fnil\fcharset0 Arial;}}\viewkind4\uc1\pard\f0\fs20 "&clean(removeTags(fileName))&"\par}</data>" 
	fnData = fnData & "  <text>"&clean(fileName)&"</text>"
	fnData = fnData & " </styledText>"
	fnData = fnData & "</object>"

	' Add FileDesc
	fnData = fnData & "<object>"
	fnData = fnData & " <field name=""FileDescription""/>"
	fnData = fnData & " <styledText>"
	fnData = fnData & "  <data>{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil Courier New;}{\f1\fnil\fcharset0 Arial;}}\viewkind4\uc1\pard\f0\fs20 "&clean(removeTags(fileDesc))&"\par}</data>" 
	fnData = fnData & "  <text>"&clean(fileDesc)&"</text>"
	fnData = fnData & " </styledText>"
	fnData = fnData & "</object>"

	addFileName = fnData

end Function


Function getCSXML(companyId,experimentType,experimentId)
'create a xml file for the cambridgesoft notebook
	getCSXML = False
	Call getconnected
    
	xmlData = "<?xml version=""1.0"" encoding=""iso-8859-1"" ?>"
	' return what we have so far
    xmlData = xmlData & makeWrapper(companyId,experimentType,experimentId)
	response.write(xmlData)
	xmlData = ""

	Select Case experimentType
		Case "1"
			'chemistry experiment

			'get the experiment data
			Set xmlRec = server.CreateObject("ADODB.Recordset")
			strQuery = "SELECT * from experiments WHERE id=" & SQLClean(experimentId,"N","S")
			xmlRec.open strQuery,conn,3,3
			
			'add the reaction section with the reaction cdxml from experiment
			cdXMLData = Replace(xmlRec("cdx"),"\""","""")
			xmlData = xmlData & "<collection name="""&clean(xmlRec("name"))&""" inboxSectionCount=""0"" noteSectionCount=""0"">"
			xmlData = xmlData & "<collectionType name=""Chemistry Experiment"" />"
			xmlData = xmlData & "<sectionSetView sectionCount=""3"">"
			xmlData = xmlData & "<section name=""Reaction"" active=""true"">"
			xmlData = xmlData & "<sectionType name=""Reaction"" />"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""Reaction""/>"
			xmlData = xmlData & "<chemicalStructure>"
			xmlData = xmlData & "<![CDATA["
			xmlData = xmlData & cdXMLData
			xmlData = xmlData & "]]>"
			xmlData = xmlData & "</chemicalStructure>"
			xmlData = xmlData & "</object>"

            reactionMolarity = ""
            If xmlRec("reactionMolarity") <> "" Then
                reactionMolarity = server.htmlEncode(xmlRec("reactionMolarity"))
            End If
            
            pressure = ""
            If xmlRec("pressure") <> "" Then
                pressure = server.htmlEncode(xmlRec("pressure"))
            End If
            
            temperature = ""
            If xmlRec("temperature") <> "" Then
                temperature = server.htmlEncode(xmlRec("temperature"))
            End If

			'create reaction properties section
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""Reaction Conditions"" />"
			xmlData = xmlData & "<propertyInstances>"
			xmlData = xmlData & "<propertyInstance value="""&reactionMolarity&""">"
			xmlData = xmlData & "<property name=""Reaction Molarity""/>"
			xmlData = xmlData & "</propertyInstance>"
			xmlData = xmlData & "<propertyInstance value="""&pressure&""" >"
			xmlData = xmlData & "<property name=""Pressure"" />"
			xmlData = xmlData & "</propertyInstance>"
			xmlData = xmlData & "<propertyInstance value="""&temperature&""">"
			xmlData = xmlData & "<property name=""Temperature"" />"
			xmlData = xmlData & "</propertyInstance>"
			xmlData = xmlData & "</propertyInstances>"
			xmlData = xmlData & "</object>"

			'create preparation section
			xmlData = xmlData &"<object>"
			xmlData = xmlData &"<field name=""Preparation"" />"
			xmlData = xmlData &"<styledText>"
			xmlData = xmlData &"<data>{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Arial;}} \viewkind4\uc1\pard\fs16 "&clean(removeTags(xmlRec("preparation")))&"\par}</data>" 
			xmlData = xmlData &"<text></text>"
			xmlData = xmlData &"</styledText>"
			xmlData = xmlData &"</object>"

			xmlRec.close
			Set xmlRec = nothing

			'add stochiometry data 'nxq reagents are not handled here

			'create stochiometry headers for reactants
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""Reactants"" />"
			xmlData = xmlData & "<tableSection pivotType=""1"" propertyCount=""14"" rowCount=""2"">"
			xmlData = xmlData & "<tableProperty visible=""true"">"
			xmlData = xmlData & "<property name=""Name"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty visible=""true"">"
			xmlData = xmlData & "<property name=""Molecular Formula"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty visible=""true"">"
			xmlData = xmlData & "<property name=""Limiting?"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty visible=""true"">"
			xmlData = xmlData & "<property name=""Stereo"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty visible=""true"">"
			xmlData = xmlData & "<property name=""Molecular Weight"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty visible=""true"">"
			xmlData = xmlData & "<property name=""Equivalents"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty visible=""true"">"
			xmlData = xmlData & "<property name=""W&#58;W"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty visible=""true"">"
			xmlData = xmlData & "<property name=""Moles"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty visible=""true"">"
			xmlData = xmlData & "<property name=""Sample Mass"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty visible=""true"">"
			xmlData = xmlData & "<property name=""Volume"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty visible=""true"">"
			xmlData = xmlData & "<property name=""Molarity"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty visible=""true"">"
			xmlData = xmlData & "<property name=""Density"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty visible=""true"">"
			xmlData = xmlData & "<property name=""% by Weight"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty visible=""true"">"
			xmlData = xmlData & "<property name=""Formula Mass"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty visible=""true"">"
			xmlData = xmlData & "<property name=""Reactant Mass"" />"
			xmlData = xmlData & "</tableProperty>"

			'add stochimetry data for reactants
			Set xmlRec = server.createobject("ADODB.RecordSet")
			strQuery = "SELECT * FROM reactants WHERE experimentId="&SQLClean(experimentId,"N","S")
			xmlRec.open strQuery,conn,3,3
			counter = 0
			'loop through reactants
			Do While Not xmlRec.eof
				'get molecule id from reaction data
				If xmlRec("userAdded") = 0 And cdXMLGetParam("ReactionStepReactants",cdXMLData) <> "Error Occured" Then
					If counter <= UBound(Split(cdXMLGetParam("ReactionStepReactants",cdXMLData)," ")) then
						tagId = Split(cdXMLGetParam("ReactionStepReactants",cdXMLData)," ")(counter)
					Else
						tagId = ""
					End if
				Else
					tagId = ""
				End if
				'create tag with the correct id from the reaction
				xmlData = xmlData & "<tableRow ><tags ID="""&tagId&""" parentID="""&tagId&""" parentCoefficient=""1"" />"
				'change the 1s and 0s in the db to true and false
				If xmlRec("limit") = 1 Then
					limit = "true"
				Else
					limit = "false"
				End If
				If xmlRec("updated") = 1 Then
					updated = "true"
				Else
					updated = "false"
				End if

				'add data
				xmlData = xmlData & " <tableCell value=""" & clean(xmlRec("name")) & """/>"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("molecularFormula") & """/>"
				xmlData = xmlData & " <tableCell value=""" & limit & """/>"
				xmlData = xmlData & " <tableCell value=""" & updated & """/>"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("molecularWeight") & """/>"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("equivalents") & """/>"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("weightRatio") & """/>"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("moles") & """/>"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("sampleMass") & """/>"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("volume") & """/>"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("molarity") & """/>"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("density") & """/>"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("percentWT") & """/>"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("formulaMass") & """/>"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("reactantMass") & """/>"
				xmlData = xmlData & "</tableRow>"
				If xmlRec("userAdded") = 0 then
					counter = counter + 1
				End if
				xmlRec.movenext
			loop
			xmlRec.close

			If companyId <> "19" Then
			



				'add stochimetry data for reagents
				Set xmlRec = server.createobject("ADODB.RecordSet")
				strQuery = "SELECT * FROM reagents WHERE experimentId="&SQLClean(experimentId,"N","S")
				xmlRec.open strQuery,conn,3,3
				counter = 0
				'loop through reactants
				Do While Not xmlRec.eof
					'get molecule id from reaction data
					If xmlRec("userAdded") = 0 Then
						reagentsString = ""
						if cdXMLGetParam("ReactionStepObjectsAboveArrow",cdXMLData) <> "" And cdXMLGetParam("ReactionStepObjectsAboveArrow",cdXMLData)<>"Error Occurred" then
							If counter <= UBound(Split(cdXMLGetParam("ReactionStepObjectsAboveArrow",cdXMLData)," ")) then
								reagentsString = reagentsString & Trim(cdXMLGetParam("ReactionStepObjectsAboveArrow",cdXMLData))
							End if
						End if
						if cdXMLGetParam("ReactionStepObjectsBelowArrow",cdXMLData) <> "" And cdXMLGetParam("ReactionStepObjectsBelowArrow",cdXMLData)<>"Error Occurred" then
							If counter <= UBound(Split(cdXMLGetParam("ReactionStepObjectsBelowArrow",cdXMLData)," ")) then
								reagentsString = reagentsString & " " & Trim(cdXMLGetParam("ReactionStepObjectsBelowArrow",cdXMLData))
							End if
						End if
						If counter<= UBound(Split(reagentsString," ")) then
							tagId = Split(reagentsString," ")(counter)
						End if
					Else
						tagId = ""
					End if
					'create tag with the correct id from the reaction
					xmlData = xmlData & "<tableRow><tags ID="""&tagId&""" parentID="""&tagId&""" parentCoefficient=""1"" />"
					'change the 1s and 0s in the db to true and false
					If xmlRec("limit") = 1 Then
						limit = "true"
					Else
						limit = "false"
					End If
					If xmlRec("updated") = 1 Then
						updated = "true"
					Else
						updated = "false"
					End if

					'add data
					xmlData = xmlData & " <tableCell value=""" & clean(xmlRec("name")) & """/>"
					xmlData = xmlData & " <tableCell value=""" & xmlRec("molecularFormula") & """/>"
					xmlData = xmlData & " <tableCell value=""" & limit & """/>"
					xmlData = xmlData & " <tableCell value=""" & updated & """/>"
					xmlData = xmlData & " <tableCell value=""" & xmlRec("molecularWeight") & """/>"
					xmlData = xmlData & " <tableCell value=""" & xmlRec("equivalents") & """/>"
					xmlData = xmlData & " <tableCell value=""" & xmlRec("weightRatio") & """/>"
					xmlData = xmlData & " <tableCell value=""" & xmlRec("moles") & """/>"
					xmlData = xmlData & " <tableCell value=""" & xmlRec("sampleMass") & """/>"
					xmlData = xmlData & " <tableCell value=""" & xmlRec("volume") & """/>"
					xmlData = xmlData & " <tableCell value=""" & xmlRec("molarity") & """/>"
					xmlData = xmlData & " <tableCell value=""" & xmlRec("density") & """/>"
					xmlData = xmlData & " <tableCell value=""" & xmlRec("percentWT") & """/>"
					xmlData = xmlData & " <tableCell value=""" & xmlRec("formulaMass") & """/>"
					xmlData = xmlData & " <tableCell value=""" & xmlRec("reactantMass") & """/>"
					xmlData = xmlData & "</tableRow>"
					If xmlRec("userAdded") = 0 then
						counter = counter + 1
					End if
					xmlRec.movenext
				loop
				xmlRec.close
				Set xmlRec = nothing




			End if


			Set xmlRec = nothing
			xmlData = xmlData &"</tableSection></object>"



			If companyId = "19" then
			'create stochiometry headers for reagents
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""Reagents"" />"
			xmlData = xmlData & "<tableSection pivotType=""1"" propertyCount=""14"" rowCount=""2"">"
			xmlData = xmlData & "<tableProperty visible=""true"">"
			xmlData = xmlData & "<property name=""Name"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty height=""0"" width=""1020"" visible=""true"">"
			xmlData = xmlData & "<property name=""Molecular Formula"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty height=""0"" width=""660"" visible=""true"">"
			xmlData = xmlData & "<property name=""Limiting?"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty height=""0"" width=""555"" visible=""true"">"
			xmlData = xmlData & "<property name=""Stereo"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty height=""0"" width=""705"" visible=""true"">"
			xmlData = xmlData & "<property name=""Molecular Weight"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty height=""0"" width=""705"" visible=""true"">"
			xmlData = xmlData & "<property name=""Equivalents"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty height=""0"" width=""705"" visible=""true"">"
			xmlData = xmlData & "<property name=""W&#58;W"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty height=""0"" width=""990"" visible=""true"">"
			xmlData = xmlData & "<property name=""Moles"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty height=""0"" width=""1200"" visible=""true"">"
			xmlData = xmlData & "<property name=""Sample Mass"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty height=""0"" width=""1080"" visible=""true"">"
			xmlData = xmlData & "<property name=""Volume"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty height=""0"" width=""675"" visible=""true"">"
			xmlData = xmlData & "<property name=""Molarity"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty height=""0"" width=""675"" visible=""true"">"
			xmlData = xmlData & "<property name=""Density"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty height=""0"" width=""510"" visible=""true"">"
			xmlData = xmlData & "<property name=""% by Weight"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty height=""0"" width=""600"" visible=""true"">"
			xmlData = xmlData & "<property name=""Formula Mass"" />"
			xmlData = xmlData & "</tableProperty>"
			xmlData = xmlData & "<tableProperty height=""0"" width=""5895"" visible=""true"">"
			xmlData = xmlData & "<property name=""Reactant Mass"" />"
			xmlData = xmlData & "</tableProperty>"



			'add stochimetry data for reagents
			Set xmlRec = server.createobject("ADODB.RecordSet")
			strQuery = "SELECT * FROM reagents WHERE experimentId="&SQLClean(experimentId,"N","S")
			xmlRec.open strQuery,conn,3,3
			counter = 0
			'loop through reactants
			Do While Not xmlRec.eof
				'get molecule id from reaction data
				If xmlRec("userAdded") = 0 Then
			        reagentsString = ""
			        if cdXMLGetParam("ReactionStepObjectsAboveArrow",cdXMLData) <> "" And cdXMLGetParam("ReactionStepObjectsAboveArrow",cdXMLData)<>"Error Occurred" then
						If counter <= UBound(Split(cdXMLGetParam("ReactionStepObjectsAboveArrow",cdXMLData)," ")) then
							reagentsString = reagentsString & Trim(cdXMLGetParam("ReactionStepObjectsAboveArrow",cdXMLData))
						End if
					End if
			        if cdXMLGetParam("ReactionStepObjectsBelowArrow",cdXMLData) <> "" And cdXMLGetParam("ReactionStepObjectsBelowArrow",cdXMLData)<>"Error Occurred" then
						If counter <= UBound(Split(cdXMLGetParam("ReactionStepObjectsBelowArrow",cdXMLData)," ")) then
							reagentsString = reagentsString & " " & Trim(cdXMLGetParam("ReactionStepObjectsBelowArrow",cdXMLData))
						End if
					End If
					If counter<= UBound(Split(reagentsString," ")) then
						tagId = Split(reagentsString," ")(counter)
					End if
				Else
					tagId = ""
				End if
				'create tag with the correct id from the reaction
				xmlData = xmlData & "<tableRow height=""330"" width=""0""><tags ID="""&tagId&""" parentID="""&tagId&""" parentCoefficient=""1"" />"
				'change the 1s and 0s in the db to true and false
				If xmlRec("limit") = 1 Then
					limit = "true"
				Else
					limit = "false"
				End If
				If xmlRec("updated") = 1 Then
					updated = "true"
				Else
					updated = "false"
				End if

				'add data
				xmlData = xmlData & " <tableCell value=""" & clean(xmlRec("name")) & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("molecularFormula") & """ />"
				xmlData = xmlData & " <tableCell value=""" & limit & """ />"
				xmlData = xmlData & " <tableCell value=""" & updated & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("molecularWeight") & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("equivalents") & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("weightRatio") & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("moles") & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("sampleMass") & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("volume") & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("molarity") & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("density") & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("percentWT") & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("formulaMass") & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("reactantMass") & """ />"
				xmlData = xmlData & "</tableRow>"
				If xmlRec("userAdded") = 0 then
					counter = counter + 1
				End if
				xmlRec.movenext
			loop
			xmlRec.close
			Set xmlRec = nothing
			xmlData = xmlData &"</tableSection></object>"

			End if


			'create headers for products stochiometry data
			xmlData = xmlData &"<object>"
			xmlData = xmlData &"<field name=""Products"" /> "
			xmlData = xmlData &"<tableSection pivotType=""1"" propertyCount=""11"" rowCount=""1"">"
			xmlData = xmlData &"<tableProperty height=""0"" width=""2800"" visible=""true"">"
			xmlData = xmlData &"<property name=""Name"" /> "
			xmlData = xmlData &"</tableProperty>"
			xmlData = xmlData &"<tableProperty height=""0"" width=""1020"" visible=""true"">"
			xmlData = xmlData &"<property name=""Molecular Formula"" /> "
			xmlData = xmlData &"</tableProperty>"
			xmlData = xmlData &"<tableProperty height=""0"" width=""990"" visible=""true"">"
			xmlData = xmlData &"<property name=""Actual Mass"" /> "
			xmlData = xmlData &"</tableProperty>"
			xmlData = xmlData &"<tableProperty height=""0"" width=""1020"" visible=""true"">"
			xmlData = xmlData &"<property name=""Actual Moles"" /> "
			xmlData = xmlData &"</tableProperty>"
			xmlData = xmlData &"<tableProperty height=""0"" width=""870"" visible=""true"">"
			xmlData = xmlData &"<property name=""% Yield"" /> "
			xmlData = xmlData &"</tableProperty>"
			xmlData = xmlData &"<tableProperty height=""0"" width=""675"" visible=""true"">"
			xmlData = xmlData &"<property name=""% Purity"" /> "
			xmlData = xmlData &"</tableProperty>"
			xmlData = xmlData &"<tableProperty height=""0"" width=""720"" visible=""true"">"
			xmlData = xmlData &"<property name=""Molecular Weight"" /> "
			xmlData = xmlData &"</tableProperty>"
			xmlData = xmlData &"<tableProperty height=""0"" width=""720"" visible=""true"">"
			xmlData = xmlData &"<property name=""Equivalents"" /> "
			xmlData = xmlData &"</tableProperty>"
			xmlData = xmlData &"<tableProperty height=""0"" width=""720"" visible=""true"">"
			xmlData = xmlData &"<property name=""W&#58;W"" /> "
			xmlData = xmlData &"</tableProperty>"
			xmlData = xmlData &"<tableProperty height=""0"" width=""765"" visible=""true"">"
			xmlData = xmlData &"<property name=""Theoretical Moles"" /> "
			xmlData = xmlData &"</tableProperty>"
			xmlData = xmlData &"<tableProperty height=""0"" width=""915"" visible=""true"">"
			xmlData = xmlData &"<property name=""Theoretical Mass"" /> "
			xmlData = xmlData &"</tableProperty>"
			xmlData = xmlData &"<tableProperty height=""0"" width=""6945"" visible=""true"">"
			xmlData = xmlData &"<property name=""Formula Mass"" /> "
			xmlData = xmlData &"</tableProperty>"


			'add products stochiometry data
			Set xmlRec = server.createobject("ADODB.RecordSet")
			strQuery = "SELECT * FROM products WHERE experimentId="&SQLClean(experimentId,"N","S")
			xmlRec.open strQuery,conn,3,3
			counter = 0
			'loop through all the products
			Do While Not xmlRec.eof
				'get the id for the molecule from the reaction data
				If xmlRec("userAdded") = 0 And cdXMLGetParam("ReactionStepProducts",cdXMLData) <> "Error Occured" Then
					If counter <= UBound(Split(cdXMLGetParam("ReactionStepProducts",cdXMLData)," ")) then
						tagId = Split(cdXMLGetParam("ReactionStepProducts",cdXMLData)," ")(counter)
					Else
						tagId = ""
					End if
				Else
					tagId = ""
				End if
				'create the container for the molecule with the correct id and add the stochiometry data
				xmlData = xmlData & "<tableRow height=""330"" width=""0""><tags ID="""&tagId&""" parentID="""&tagId&""" parentCoefficient=""1"" />"
				xmlData = xmlData & " <tableCell value=""" & clean(xmlRec("name")) & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("molecularFormula") & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("actualMass") & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("actualMoles") & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("yield") & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("purity") & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("molecularWeight") & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("equivalents") & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("theoreticalMoles") & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("theoreticalMass") & """ />"
				xmlData = xmlData & " <tableCell value=""" & xmlRec("formulaMass") & """ />"
				xmlData = xmlData & "</tableRow>"
				If xmlRec("userAdded") = "0" then
					counter = counter + 1
				End if
				xmlRec.movenext
			loop
			xmlRec.close
			Set xmlRec = nothing

			xmlData = xmlData &"</tableSection></object>"

			'add the headers for the solvents stochimetry
			xmlData = xmlData &"<object>"
			xmlData = xmlData &"<field name=""Solvents"" />"
			xmlData = xmlData &"<tableSection pivotType=""1"" propertyCount=""3"" rowCount=""1"">"
			xmlData = xmlData &"<tableProperty height=""0"" width=""825"" visible=""true"">"
			xmlData = xmlData &"<property name=""Name"" />"
			xmlData = xmlData &"</tableProperty>"
			xmlData = xmlData &"<tableProperty height=""0"" width=""480"" visible=""true"">"
			xmlData = xmlData &"<property name=""Ratio"" />"
			xmlData = xmlData &"</tableProperty>"
			xmlData = xmlData &"<tableProperty height=""0"" width=""5505"" visible=""true"">"
			xmlData = xmlData &"<property name=""Volume"" />"
			xmlData = xmlData &"</tableProperty>"

			'add the solvents stochiometry data
			Set xmlRec = server.createobject("ADODB.RecordSet")
			strQuery = "SELECT * FROM solvents WHERE experimentId="&SQLClean(experimentId,"N","S")
			xmlRec.open strQuery,conn,3,3
			counter = 0
			'loop through all the solvents
			Do While Not xmlRec.eof
				'add the stochiometry data for the solvents
				xmlData = xmlData &"<tableRow height=""330"" width=""0"">"
				xmlData = xmlData &"<tags />"
				xmlData = xmlData &"<tableCell value="""&clean(xmlRec("name"))&""" backColor=""-1"" tag="""" />"
				xmlData = xmlData &"<tableCell value="""&xmlRec("ratio")&""" backColor=""-1"" tag="""" />"
				xmlData = xmlData &"<tableCell value="""&xmlRec("volume")&""" backColor=""-1"" tag="""" />"
				xmlData = xmlData &"</tableRow>"
				counter = counter + 1
				xmlRec.movenext
			loop
			xmlRec.close
			Set xmlRec = nothing

			xmlData = xmlData &"</tableSection>"
			xmlData = xmlData &"</object>"
			xmlData = xmlData & "</section>"

		Case "2"
			'biology experiment

			'get the experiment data
			Set xmlRec = server.CreateObject("ADODB.Recordset")
			strQuery = "SELECT * from bioExperimentsView WHERE id=" & SQLClean(experimentId,"N","S")
			xmlRec.open strQuery,conn,3,3
			
			'add experiment header information
			xmlData = "<collection name="""&clean(xmlRec("name"))&""" inboxSectionCount=""0"" noteSectionCount=""0"">"
			xmlData = xmlData & "<collectionType name=""Biology Experiment"" />"
			xmlData = xmlData & "<sectionSetView sectionCount=""2"">"
			xmlData = xmlData & "<section name=""Header"" active=""true"">"
			xmlData = xmlData & "<sectionType name=""Header"" />"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""Experiment Header""/>"
			xmlData = xmlData & "<propertyInstances>"
			xmlData = xmlData & "<propertyInstance value="""&clean(xmlRec("notebookName"))&""" ><property name=""Project""/></propertyInstance>"
			xmlData = xmlData & "<propertyInstance value="""&clean(xmlRec("name"))&""" ><property name=""Title""/></propertyInstance>"
			xmlData = xmlData & "<propertyInstance value="""&xmlRec("dateSubmitted")&""" ><property name=""Creation Date""/></propertyInstance>"
			xmlData = xmlData & "</propertyInstances>"
			xmlData = xmlData & "</object>"

			'add the summary and protocol text to the description field of the camsoft enotebook
			xmlData = xmlData &"<object>"
			xmlData = xmlData &"<field name=""Description"" />"
			xmlData = xmlData &"<styledText>"
			xmlData = xmlData &"<data>{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Arial;}}\viewkind4\uc1\pard\fs16PROTOCOL \par "&clean(removeTags(xmlRec("protocol")))&"\par \par SUMMARY \par "&clean(removeTags(xmlRec("summary")))&"\par}</data>" 
			xmlData = xmlData &"<text></text>"
			xmlData = xmlData &"</styledText>"
			xmlData = xmlData &"</object>"
			xmlData = xmlData &"</section>"

			xmlRec.close
			Set xmlRec = nothing


		Case "3"
			'free/concept experiment
			
			'get the experiment data
			Set xmlRec = server.CreateObject("ADODB.Recordset")
			strQuery = "SELECT * from freeExperimentsView WHERE id=" & SQLClean(experimentId,"N","S")
			xmlRec.open strQuery,conn,3,3
			
			'set the experiment header info
			xmlData = "<collection name="""&clean(xmlRec("name"))&""" inboxSectionCount=""0"" noteSectionCount=""0"">"
			xmlData = xmlData & "<collectionType name=""Concept Experiment"" />"
			xmlData = xmlData & "<sectionSetView sectionCount=""2"">"
			xmlData = xmlData & "<section name=""Header"" active=""true"">"
			xmlData = xmlData & "<sectionType name=""Header"" />"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""Experiment Header""/>"
			xmlData = xmlData & "<propertyInstances>"
			xmlData = xmlData & "<propertyInstance value="""&xmlRec("notebookName")&""" ><property name=""Project""/></propertyInstance>"
			xmlData = xmlData & "<propertyInstance value="""&clean(xmlRec("name"))&""" ><property name=""Title""/></propertyInstance>"
			xmlData = xmlData & "<propertyInstance value="""&xmlRec("dateSubmitted")&""" ><property name=""Creation Date""/></propertyInstance>"
			xmlData = xmlData & "</propertyInstances>"
			xmlData = xmlData & "</object>"

			'add the description text to the enotebook description field
			xmlData = xmlData &"<object>"
			xmlData = xmlData &"<field name=""Description"" />"
			xmlData = xmlData &"<styledText>"
			xmlData = xmlData &"<data>{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Arial;}}\viewkind4\uc1\pard\fs16DESCRIPTION \par "&clean(removeTags(xmlRec("description")))&"\par \par}</data>" 
			xmlData = xmlData &"<text></text>"
			xmlData = xmlData &"</styledText>"
			xmlData = xmlData &"</object>"
			xmlData = xmlData &"</section>"

			xmlRec.close
			Set xmlRec = nothing
		Case "4"
			'analytical experiment

			'get the experiment data
			Set xmlRec = server.CreateObject("ADODB.Recordset")
			strQuery = "SELECT * from analExperimentsView WHERE id=" & SQLClean(experimentId,"N","S")
			xmlRec.open strQuery,conn,3,3
			
			'add experiment header information
			xmlData = "<collection name="""&clean(xmlRec("name"))&""" inboxSectionCount=""0"" noteSectionCount=""0"">"
			xmlData = xmlData & "<collectionType name=""Analytical Experiment"" />"
			xmlData = xmlData & "<sectionSetView sectionCount=""2"">"
			xmlData = xmlData & "<section name=""Header"" active=""true"">"
			xmlData = xmlData & "<sectionType name=""Header"" />"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""Experiment Header""/>"
			xmlData = xmlData & "<propertyInstances>"
			xmlData = xmlData & "<propertyInstance value="""&xmlRec("notebookName")&"""><property name=""Project""/></propertyInstance>"
			xmlData = xmlData & "<propertyInstance value="""&clean(xmlRec("name"))&""" ><property name=""Title""/></propertyInstance>"
			xmlData = xmlData & "<propertyInstance value="""&xmlRec("dateSubmitted")&"""><property name=""Creation Date""/></propertyInstance>"
			xmlData = xmlData & "</propertyInstances>"
			xmlData = xmlData & "</object>"

			'add the summary and protocol text to the description field of the camsoft enotebook
			xmlData = xmlData &"<object>"
			xmlData = xmlData &"<field name=""Description"" />"
			xmlData = xmlData &"<styledText>"
			xmlData = xmlData &"<data>{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Arial;}}\viewkind4\uc1\pard\fs16PROTOCOL \par "&clean(removeTags(xmlRec("protocol")))&"\par \par SUMMARY \par "&removeTags(clean(xmlRec("summary")))&"\par}</data>" 
			xmlData = xmlData &"<text></text>"
			xmlData = xmlData &"</styledText>"
			xmlData = xmlData &"</object>"
			xmlData = xmlData &"</section>"

			xmlRec.close
			Set xmlRec = nothing

		Case "5"
			'custom experiment
			'get the experiment data
			Set xmlRec = server.CreateObject("ADODB.Recordset")
			strQuery = "SELECT * from custExperimentsView WHERE id=" & SQLClean(experimentId,"N","S")
			xmlRec.open strQuery,conn,3,3
			
			'set the experiment header info
			xmlData = "<collection name="""&clean(xmlRec("name"))&""" inboxSectionCount=""0"" noteSectionCount=""0"">"
			xmlData = xmlData & "<collectionType name=""Custom Experiment"" />"
			xmlData = xmlData & "<sectionSetView sectionCount=""2"">"
			xmlData = xmlData & "<section name=""Header"" active=""true"">"
			xmlData = xmlData & "<sectionType name=""Header"" />"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""Experiment Header""/>"
			xmlData = xmlData & "<propertyInstances>"
			xmlData = xmlData & "<propertyInstance value="""&xmlRec("notebookName")&""" ><property name=""Project""/></propertyInstance>"
			xmlData = xmlData & "<propertyInstance value="""&clean(xmlRec("name"))&""" ><property name=""Title""/></propertyInstance>"
			xmlData = xmlData & "<propertyInstance value="""&clean(xmlRec("details"))&""" ><property name=""Experiment Description""/></propertyInstance>"
			xmlData = xmlData & "<propertyInstance value="""&xmlRec("dateSubmitted")&""" ><property name=""Creation Date""/></propertyInstance>"
			xmlData = xmlData & "</propertyInstances>"
			xmlData = xmlData & "</object>"

			xmlData = xmlData & processWorkflowRequestSectionBACKUP(companyId, experimentId)
			
			xmlData = xmlData & "</section>"

			xmlRec.close
			Set xmlRec = nothing
	End select

	' return what we have so far
	response.write(xmlData)
	'response.end()
	xmlData = ""

	'embed attachments in the xml file

	Set xmlRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM notebookIndexView WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND typeId="&SQLClean(experimentType,"N","S")
	xmlRec.open strQuery,conn,3,3
	If Not xmlRec.eof then
		companyId = xmlRec("companyId")
	End if
	xmlRec.close
	Set xmlRec = nothing

	Set xmlRec = server.CreateObject("ADODB.RecordSet")
	'get the right attachment table
	prefix = GetPrefix(experimentType)
	attachmentTable = GetFullName(prefix, "attachments", true)
	strQuery = "SELECT * FROM " & attachmentTable & " WHERE experimentId="&SQLClean(experimentId,"N","S")
	xmlRec.open strQuery,conn,3,3
	'loop through all the attachments
	Do While Not xmlRec.eof
		'get the filepath to the attachment
		abbreviation = GetAbbreviation(experimentType)		
		filepath = uploadRootRoot & "\" &companyId &"\"&xmlRec("userId")&"\"&xmlRec("experimentId")&"\"&xmlRec("revisionNumber")&"\" & abbreviation & "\"&xmlRec("actualFilename")
		set fs=Server.CreateObject("Scripting.FileSystemObject")

		if fs.FileExists(filepath) Then
			'if file exists open it in a stream and get a string of the file base64 encoded
			Set adoStream = CreateObject("ADODB.Stream")  
			adoStream.Open()  
			adoStream.Type = 1  
			adoStream.LoadFromFile(filepath)
			Set objXML = CreateObject("MSXml2.DOMDocument")
			Set objDocElem = objXML.createElement("Base64Data")
			objDocElem.dataType = "bin.base64"
			objDocElem.nodeTypedValue = adoStream.Read()
			randomize
			string64 = objDocElem.text
			'get the file extension and complete the string format "[file_extension];[b64 data]"
			imageData = getFileExtension(xmlRec("actualFilename")) & ";" & string64
			adoStream.Close
			Set adoStream = Nothing  
		End if

		xten = Replace(LCase(getFileExtension(xmlRec("filename"))),".","")
		If xten="jpg" Or xten="jpeg" or xten="gif" Or xten="png" Or xten="tif" Or xten="tiff" Or xten="bmp" Or xten="emf" Or xten="wmf" Or xten="svg" then
			'embed these extensions as images
			'add the attachment name
			xmlData = xmlData & "<section name="""&clean(xmlRec("name"))&""" active=""true"">"
			xmlData = xmlData & "<sectionType name=""Image""/>"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""Image""/>"
			'add the image data
			xmlData = xmlData & "<image data="""&imageData&"""/>"
			xmlData = xmlData & "</object>"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""Notes""/>"
			xmlData = xmlData & "<styledText>"
			'response.write("<data>{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Arial;}} \viewkind4\uc1\pard\fs16 "&Replace(xmlRec("description"),vbcrlf,"\par ")&"\par}</data>" )
			'add the attachment description text
			xmlData = xmlData &"<data>{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil Courier New;}{\f1\fnil\fcharset0 Arial;}}\viewkind4\uc1\pard\f0\fs20 "&clean(removeTags(xmlRec("description")))&"\par}</data>" 
			xmlData = xmlData & "<text>"&clean(xmlRec("description"))&"</text>"
			xmlData = xmlData & "</styledText>"
			xmlData = xmlData & "</object>"
			' file names
			xmlData = xmlData & addFileName(xmlRec("filename"), xmlRec("name"))
			xmlData = xmlData & "</section>"

		elseIf xten="xls" Or xten="xlsx" or xten="csv" Then
			'embed an excel file
			'add the attachement name
			xmlData = xmlData & "<section name="""&clean(xmlRec("name"))&""" active=""true"">"
			xmlData = xmlData & "<sectionType name=""MS Excel Spreadsheet""/>"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""MS Excel Spreadsheet""/>"
			'embed the file data
			xmlData = xmlData & "<document type=""2"">"&string64&"</document>"
			xmlData = xmlData & "</object>"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""Notes""/>"
			xmlData = xmlData & "<styledText>"
			'response.write("<data>{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Arial;}} \viewkind4\uc1\pard\fs16 "&Replace(xmlRec("description"),vbcrlf,"\par ")&"\par}</data>" )
			'add the attachment description text
			xmlData = xmlData &"<data>{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil Courier New;}{\f1\fnil\fcharset0 Arial;}}\viewkind4\uc1\pard\f0\fs20 "&clean(removeTags(xmlRec("description")))&"\par}</data>" 
			xmlData = xmlData & "<text>"&xmlRec("description")&"</text>"
			xmlData = xmlData & "</styledText>"
			xmlData = xmlData & "</object>"
			' file names
			xmlData = xmlData & addFileName(xmlRec("filename"), xmlRec("name"))
			xmlData = xmlData & "</section>"

		elseIf xten="doc" Or xten="docx" Then
			'embed a word doc
			'add the attachment name
			xmlData = xmlData & "<section name="""&clean(xmlRec("name"))&""" active=""true"">"
			xmlData = xmlData & "<sectionType name=""MS Word Document""/>"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""MS Word Document""/>"
			'embed the file data
			xmlData = xmlData & "<document type=""1"">"&string64&"</document>"
			xmlData = xmlData & "</object>"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""Links""/>"
			xmlData = xmlData & "<propertyInstances/>"
			xmlData = xmlData & "</object>"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""Notes""/>"
			xmlData = xmlData & "<styledText>"
			'response.write("<data>{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Arial;}} \viewkind4\uc1\pard\fs16 "&Replace(xmlRec("description"),vbcrlf,"\par ")&"\par}</data>" )
			'add the attachment description text
			xmlData = xmlData &"<data>{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil Courier New;}{\f1\fnil\fcharset0 Arial;}}\viewkind4\uc1\pard\f0\fs20 "&clean(removeTags(xmlRec("description")))&"\par}</data>" 
			xmlData = xmlData & "<text>"&clean(xmlRec("description"))&"</text>"
			xmlData = xmlData & "</styledText>"
			xmlData = xmlData & "</object>"
			' file names
			xmlData = xmlData & addFileName(xmlRec("filename"), xmlRec("name"))
			xmlData = xmlData & "</section>"

		elseIf xten="cdx" Or xten="cdxml" Then
			'embed a word doc
			'add the attachment name
			xmlData = xmlData & "<section name="""&clean(xmlRec("name"))&""" active=""true"">"
			xmlData = xmlData & "<sectionType name=""Captured ChemImage"" />"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""Images"" />"
			xmlData = xmlData & "<subsection>"
			xmlData = xmlData & "<sectionSetView sectionCount=""1"">"
			xmlData = xmlData & "<section name="""&clean(xmlRec("name"))&""" active=""true"">"
			xmlData = xmlData & "<sectionType name=""ChemImage"" />"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""Image"" />"
			
			if xten="cdx" then
				cdxmlData = convertToCDXML(string64, "base64:cdx")
			else ' cdxml
				cdxmlData = decodeBase64(string64)
			end if
			
			xmlData = xmlData & "<chemicalStructure extension="""&xten&"""><![CDATA["& Replace(cdXMLData,"Comment=""-""","")&"]]>"&"</chemicalStructure>"
			xmlData = xmlData & "</object>"
			xmlData = xmlData & "</section>"
			xmlData = xmlData & "</sectionSetView>"
			xmlData = xmlData & "</subsection>"
			xmlData = xmlData & "</object>"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""Metadata"" />"
			xmlData = xmlData & "<propertyInstances>"
			xmlData = xmlData & "<propertyInstance>"
			xmlData = xmlData & "<property name=""Date"" />"
			xmlData = xmlData & "</propertyInstance>"
			xmlData = xmlData & "<propertyInstance>"
			xmlData = xmlData & "<property name=""Document"" />"
			xmlData = xmlData & "</propertyInstance>"
			xmlData = xmlData & "<propertyInstance>"
			xmlData = xmlData & "<property name=""Frequency"" />"
			xmlData = xmlData & "</propertyInstance>"
			xmlData = xmlData & "</propertyInstances>"
			xmlData = xmlData & "</object>"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""Notes""/>"
			xmlData = xmlData & "<styledText>"
			'response.write("<data>{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Arial;}} \viewkind4\uc1\pard\fs16 "&Replace(xmlRec("description"),vbcrlf,"\par ")&"\par}</data>" )
			'add the attachment description text
			xmlData = xmlData &"<data>{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil Courier New;}{\f1\fnil\fcharset0 Arial;}}\viewkind4\uc1\pard\f0\fs20 "&clean(removeTags(xmlRec("description")))&"\par}</data>" 
			xmlData = xmlData & "<text>"&clean(xmlRec("description"))&"</text>"
			xmlData = xmlData & "</styledText>"
			xmlData = xmlData & "</object>"
			' file names
			xmlData = xmlData & addFileName(xmlRec("filename"), xmlRec("name"))
			xmlData = xmlData & "</section>"

		elseif xten="ppt" Or xten="pptx" Then
			'embed a powerpoint file
			'add the attachment name
			xmlData = xmlData & "<section name="""&clean(xmlRec("name"))&""" active=""true"">"
			xmlData = xmlData & "<sectionType name=""MS PowerPoint""/>"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""MS PowerPoint""/>"
			'embed the file data
			xmlData = xmlData & "<document type=""3"">"&string64&"</document>"
			xmlData = xmlData & "</object>"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""Notes""/>"
			xmlData = xmlData & "<styledText>"
			'response.write("<data>{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Arial;}} \viewkind4\uc1\pard\fs16 "&Replace(xmlRec("description"),vbcrlf,"\par ")&"\par}</data>" )
			'add the attachment description text
			xmlData = xmlData &"<data>{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil Courier New;}{\f1\fnil\fcharset0 Arial;}}\viewkind4\uc1\pard\f0\fs20 "&clean(removeTags(xmlRec("description")))&"\par}</data>" 
			xmlData = xmlData & "<text>"&clean(xmlRec("description"))&"</text>"
			xmlData = xmlData & "</styledText>"
			xmlData = xmlData & "</object>"
			' file names
			xmlData = xmlData & addFileName(xmlRec("filename"), xmlRec("name"))
			xmlData = xmlData & "</section>"

		elseif xten="pdf" Then
			'embed a powerpoint file
			'add the attachment name
			xmlData = xmlData & "<section name="""&clean(xmlRec("name"))&""" active=""true"">"
			xmlData = xmlData & "<sectionType name=""PDF""/>"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""PDF""/>"
			'embed the file data
			xmlData = xmlData & "<document type=""4"">"&string64&"</document>"
			xmlData = xmlData & "</object>"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""Notes""/>"
			xmlData = xmlData & "<styledText>"
			'response.write("<data>{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Arial;}} \viewkind4\uc1\pard\fs16 "&Replace(xmlRec("description"),vbcrlf,"\par ")&"\par}</data>" )
			'add the attachment description text
			xmlData = xmlData &"<data>{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil Courier New;}{\f1\fnil\fcharset0 Arial;}}\viewkind4\uc1\pard\f0\fs20 "&clean(removeTags(xmlRec("description")))&"\par}</data>" 
			xmlData = xmlData & "<text>"&clean(xmlRec("description"))&"</text>"
			xmlData = xmlData & "</styledText>"
			xmlData = xmlData & "</object>"
			xmlData = xmlData & addFileName(xmlRec("filename"), xmlRec("name"))
			xmlData = xmlData & "</section>"
		
		else ' Other/unknown file type
			'add the attachment name
			xmlData = xmlData & "<section name="""&clean(xmlRec("name"))&""" active=""true"">"
			xmlData = xmlData & "<sectionType name=""" & xten & """/>"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""" & xten & """/>"
			'embed the file data
			xmlData = xmlData & "<document>"&string64&"</document>"
			xmlData = xmlData & "</object>"
			xmlData = xmlData & "<object>"
			xmlData = xmlData & "<field name=""Notes""/>"
			xmlData = xmlData & "<styledText>"
			'add the attachment description text
			xmlData = xmlData &"<data>{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil Courier New;}{\f1\fnil\fcharset0 Arial;}}\viewkind4\uc1\pard\f0\fs20 "&clean(removeTags(xmlRec("description")))&"\par}</data>" 
			xmlData = xmlData & "<text>"&clean(xmlRec("description"))&"</text>"
			xmlData = xmlData & "</styledText>"
			xmlData = xmlData & "</object>"
			' file names
			xmlData = xmlData & addFileName(xmlRec("filename"), xmlRec("name"))
			xmlData = xmlData & "</section>"
		End if

		'return what we have so far
		response.write(xmlData)
		xmlData = ""

		'nxq only embeds office documents and images
		xmlRec.moveNext
	Loop
	xmlRec.close
	Set xmlRec = nothing

	xmlData = xmlData & "</sectionSetView>"
	xmlData = xmlData & "</collection>"
	response.write(xmlData)
	xmlData = ""

	'return the xml file string
	getCSXML = True
	
End Function
%>