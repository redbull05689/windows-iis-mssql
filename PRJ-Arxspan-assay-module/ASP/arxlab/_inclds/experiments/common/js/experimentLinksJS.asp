<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
function newLink(formId)
{
	f = document.getElementById("submitFrame2")
	f.src = f.src
	document.getElementById(formId).submit();
	waitForNewLink();
}

function waitForNewLink()
{
	try
	{
		result = window.frames["submitFrame2"].document.getElementById("resultsDiv").innerHTML
		if (result == "success")
		{
			loadExperimentLinks("experimentLinks");
			unsavedChanges = true;
		}
		else
		{
			alert(result)
			//setTimeout('waitForNewLink()',150)
		}
		f = document.getElementById("submitFrame2")
		f.src = f.src
	}
	catch(err)
	{
		setTimeout('waitForNewLink()',150)
	}
}

function newRegLink(formId)
{
	f = document.getElementById("submitFrame2")
	f.src = f.src
	document.getElementById(formId).submit();
	waitForNewRegLink();
}

function waitForNewRegLink()
{
	try
	{
		result = window.frames["submitFrame2"].document.getElementById("resultsDiv").innerHTML
		if (result == "success")
		{
			getRegLinks();
			unsavedChanges = true;
		}
		else
		{
			alert(result)
			//setTimeout('waitForNewLink()',150)
		}
		f = document.getElementById("submitFrame2")
		f.src = f.src
	}
	catch(err)
	{
		setTimeout('waitForNewRegLink()',150)
	}
}

function deleteLink(linkExperimentType,linkExperimentId)
{
	f = document.getElementById("submitFrame2")
	f.src = f.src
	document.getElementById("delLinkType").value = linkExperimentType
	document.getElementById("delLinkId").value = linkExperimentId
	document.getElementById("deleteLinkForm").submit();
	waitForDeleteLink();
}

function waitForDeleteLink()
{
	try
	{
		result = window.frames["submitFrame2"].document.getElementById("resultsDiv").innerHTML
		if (result == "success")
		{
			//loadExperimentLinks(); No need to refresh - it's just deleted and we already removed the link's row from the DOM
			//unsavedChanges = true;
			loadExperimentLinks('experiment');
		}
		else
		{
			alert(result)
			//setTimeout('waitForNewLink()',150)
		}
		f = document.getElementById("submitFrame2")
		f.src = f.src
	}
	catch(err)
	{
		setTimeout('waitForDeleteLink()',150)
	}
}

function deleteRegLink(regNumber)
{
	f = document.getElementById("submitFrame2")
	f.src = f.src
	document.getElementById("delRegNumber").value = regNumber;
	document.getElementById("deleteRegLinkForm").submit();
	waitForDeleteRegLink();
}

function waitForDeleteRegLink()
{
	try
	{
		result = window.frames["submitFrame2"].document.getElementById("resultsDiv").innerHTML
		if (result == "success")
		{
			loadExperimentLinks('registration');
		}
		else
		{
			alert(result)
			//setTimeout('waitForNewLink()',150)
		}
		f = document.getElementById("submitFrame2")
		f.src = f.src
	}
	catch(err)
	{
		setTimeout('waitForDeleteRegLink()',150)
	}
}

/**
 * Deletes the passed in link ID.
 * @param {number} linkId The ID of the link to delete.
 */
function deleteLinkFromSvc(linkId) {
	return new Promise(function(resolve, reject) {
		$.ajax({
			url: "/arxlab/workflow/invp.asp",
			data: {
				url: "/links/" + linkId + "?&appName=ELN",
				verb: "DELETE",
				serialUUID: uuidv4(),
				config: true,
				linkService: true
			},
			type: "POST"
		}).done(function(response) {
			resolve(response);
		})
	})
}

/**
 * Deletes the passed in request link ID and then reloads the request link table.
 * @param {number} linkId The ID of the link to delete.
 */
function deleteRequestLink(linkId) {
	deleteLinkFromSvc(linkId).then(function(response) {
		loadExperimentLinks("request");
	});
}

function getInventoryLinks()
{
	links = getFile("<%=mainAppPath%>/experiments/ajax/load/getInventoryLinks.asp?id=<%=experimentId%>&type=<%=experimentType%>&random="+Math.random());
	document.getElementById("inventoryLinksTD").innerHTML = links;
}