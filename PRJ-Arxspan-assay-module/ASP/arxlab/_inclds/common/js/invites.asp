<!DOCTYPE html>
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<script type="text/javascript">
	function getInvites()
	{
		if("<%=projectId%>" == "")
		{
			table = getFile("<%=mainAppPath%>/notebooks/ajax/load/notebookInvitesTable.asp?id=<%=notebookId%>&random="+Math.random())
			document.getElementById("invitesDiv").innerHTML = table;
		}
		else
		{
			table = getFile("<%=mainAppPath%>/projects/ajax/load/projectInvitesTable.asp?id=<%=projectId%>&random="+Math.random())
			document.getElementById("invitesDiv").innerHTML = table;
		}
	}
</script>

<script type="text/javascript">
	var reactants = [];
	var products = [];
	var mols = [];

function showShare()
{
	document.getElementById("shareNotebookDiv").style.display = "block";
	document.getElementById("shareNotebookLink").style.borderColor = "#ccc #999 #999 #ccc"; 
	document.getElementById("shareNotebookLink").style.backgroundColor = "#eeeeee"; 
	document.getElementById("shareNotebookLink").onclick = hideShare
}

function hideShare()
{
	document.getElementById("shareNotebookDiv").style.display = "none";
	document.getElementById("shareNotebookLink").style.borderColor = "#DFDFDF"; 
	document.getElementById("shareNotebookLink").style.backgroundColor = "white"; 
	document.getElementById("shareNotebookLink").onclick = showShare
	document.getElementById("canRead").checked = false;
	document.getElementById("canWrite").checked = false;
	document.getElementById("canShare").checked = false;
	document.getElementById("canShareShare").checked = false;
	clearGroups()
	document.getElementById("numUsers").innerHTML = '0';
	document.getElementById("numGroups").innerHTML = '0';
}


	function cancelInvite(id)
	{
		document.getElementById('cancelForm_'+id).submit();
		waitForCancel();
	}


	function waitForCancel()
	{
		try
		{
			result = window.frames['submitFrame'].document.getElementById("resultsDiv").innerHTML
			if (result == "success")
			{
				window.frames['submitFrame'].document.getElementById("resultsDiv").innerHTML = "";
				setTimeout('getInvites()',200)
			}
			else
			{
				setTimeout('waitForCancel()',150)
			}
		}
		catch(err)
		{
			setTimeout('waitForCancel()',150)
		}
	}

	function changeInvite(id)
	{
		document.getElementById('changeForm_'+id).submit();
		waitForCancel();
	}

	function changeShareInvite(id)
	{
		document.getElementById('shareChangeForm_'+id).submit();
		waitForCancel();
	}


	function waitForCancel()
	{
		try
		{
			result = window.frames['submitFrame'].document.getElementById("resultsDiv").innerHTML
			if (result == "success")
			{
				window.frames['submitFrame'].document.getElementById("resultsDiv").innerHTML = "";
				setTimeout('getInvites()',200);
				setTimeout('location.reload(true)', 200);
			}
			else
			{
				setTimeout('waitForCancel()',150);
			}
		}
		catch(err)
		{
			setTimeout('waitForCancel()',150);
		}
	}

	function deleteSubmit()
	{
		sweetAlert(
        {
            title: "Are you sure?",
            text: "Are you sure you would like to delete this notebook?",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#5CB85C',
            confirmButtonText: 'Yes',
            cancelButtonText: 'No'
        },
        function(isConfirm) {
            if (isConfirm) {
                sForm = document.getElementById("deleteForm");
				sForm.submit();
				waitForDelete();
				return false;
            }
		})
	}

	function waitForDelete()
	{
		try
		{
			result = window.frames['submitFrame'].document.getElementById("resultsDiv").innerHTML
			//stuff after submit
			if(result == "success")
			{
				window.frames['submitFrame'].document.getElementById("resultsDiv").innerHTML = "";
				reloadSubmitFrame()
				window.location.href = 'dashboard.asp'
				//getInvites()
				//hideShare()
			}
			else
			{
				if (result == "")
				{
					setTimeout('waitForDelete()',150)
				}
				else
				{
					alert(result)
				}
			}
		}
		catch(err)
		{
			//alert(err)
			setTimeout('waitForDelete()',150)
		}
	}

	function clearGroups()
	{
		els = document.getElementsByClassName("groupCheck")
		for(i=0;i<=els.length;i++)
		{
			try
			{
				els[i].checked = false;
			}
			catch(err){}
		}
		els = document.getElementsByClassName("groupCheckUser")
		for(i=0;i<=els.length;i++)
		{
			try
			{
				els[i].checked = false;
			}
			catch(err){}
		}
	}


	function shareSubmit()
	{
		<%'take form and put the whole form into the hidden iframe for background saving%>
		sForm = document.getElementById("shareForm");
		sForm.submit();
		waitForSave();
		return false;
	}

	function waitForSave()
	{
		try
		{
			result = window.frames['submitFrame'].document.getElementById("resultsDiv").innerHTML
			//stuff after submit
			if(result == "success")
			{
				window.frames['submitFrame'].document.getElementById("resultsDiv").innerHTML = "";
				reloadSubmitFrame();
				getInvites();
				hideShare();
			}
			else
			{
				if (result == "")
				{
					setTimeout('waitForSave()',150)
				}
				else
				{
					alert(result);
					reloadSubmitFrame();
					getInvites();
				}
			}
		}
		catch(err)
		{
			//alert(err)
			setTimeout('waitForSave()',150)
		}
	}
	function reloadSubmitFrame()
	{
		f = document.getElementById("submitFrame")
		f.src = f.src
	}

function notebookAccept()
{
	document.getElementById("notebookAcceptStatus").value="1";
	document.getElementById("acceptForm").submit();
	waitForNotebookAccept();
}

function waitForNotebookAccept()
{
		try
		{
			result = window.frames['submitFrame'].document.getElementById("resultsDiv").innerHTML
			if(result == "success")
			{location.reload(true)}	else{alert(result)}
		}
		catch(err)
		{
			//alert(err)
			setTimeout('waitForNotebookAccept()',150)
		}
}

function notebookDecline()
{
	if (confirm("Are you sure you want to decline this invitation?"))
	{
		document.getElementById("notebookAcceptStatus").value="0";
		document.getElementById("acceptForm").submit()
		waitForNotebookDecline();
	}
}

function waitForNotebookDecline()
{
		try
		{
			result = window.frames['submitFrame'].document.getElementById("resultsDiv").innerHTML
			if(result == "success")
			{location.reload(true)}	else{alert(result)}
		}
		catch(err)
		{
			//alert(err)
			setTimeout('waitForNotebookDecline()',150)
		}
}

function changeOwner()
{
	if (confirm("Are you sure you wish to change the owner of this notebook?"))
	{
		newUserId = document.getElementById("changeNotebookUserId")
		newUserId = newUserId.options[newUserId.selectedIndex].value
		notebookId = document.getElementById("notebookIdForChange").value
		ret = getFile("<%=mainAppPath%>/notebooks/ajax/do/changeNotebookOwner.asp?notebookId="+notebookId+"&newUserId="+newUserId+"&rand="+Math.random())
		document.getElementById("notebookOwnerSpan").innerHTML = ret;
		document.getElementById('ownerDiv').style.display='block';
		document.getElementById('changeOwnerDiv').style.display = 'none'
		document.location.href = document.location.href;
	}
}

</script>
</html>