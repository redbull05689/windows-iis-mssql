function toggleGroup(groupId)
{
	el = document.getElementById("groupListUsers-"+groupId)
	link = document.getElementById("expandGroupLink-"+groupId)
	if(el)
	{
		if (el.style.display == "none")
		{
			el.style.display = "block";
			link.innerHTML = "&ndash;"
		}
		else
		{
			el.style.display = "none";
			link.innerHTML = "+"
		}
	}
}

function checkAll(el)
{
	if (el.checked)
	{
		els = document.getElementsByTagName("input")
		for(i=0;i<els.length;i++)
		{
			if(els[i].type == 'checkbox')
			{
				els[i].checked = true;
			}
		}
	}
	else
	{
		els = document.getElementsByTagName("input")
		for(i=0;i<els.length;i++)
		{
			if(els[i].type == 'checkbox')
			{
				els[i].checked = false;
			}
		}
	}
}

function groupCheck(groupId)
{
	el = document.getElementById("listGroupCheckGroup-"+groupId)
	els = document.getElementsByClassName("groupCheckUser")
	for(i=0;i<=els.length;i++)
	{
		if (els[i] != undefined)
		{
			if (els[i].getAttribute("group") == groupId)
			{
				els[i].checked = el.checked
			}
		}
	}
}

function userCheck(groupId,userId)
{
	els = document.getElementsByClassName("groupCheckUser")
	for(i=0;i<els.length;i++)
	{
		if (els[i].id == "listGroupCheckUser-"+userId && els[i].getAttribute("group") == groupId)
		{
			if (!els[i].checked)
			{
				document.getElementById("listGroupCheckGroup-"+els[i].getAttribute("group")).checked = false
			}			
		}
	}
}

function populatePerms(D){
	if (D!=""){
		if(D.hasOwnProperty("userIds")){
			for(var i=0;i<D["userIds"].length;i++){
				userChecks = document.getElementsByClassName("groupCheckUser");
				for(var j=0;j<userChecks.length;j++){
					if(userChecks[j].getAttribute("userid")==D["userIds"][i]){
						el = userChecks[j];
						el.checked = true;
						//el.onclick();
						groupId = el.getAttribute("group");
						el = document.getElementById("groupListUsers-"+groupId)
						link = document.getElementById("expandGroupLink-"+groupId)
						el.style.display = "block";
						link.innerHTML = "&ndash;"
					}
				}
			}
		}
		if(D.hasOwnProperty("groupIds")){
			for(var i=0;i<D["groupIds"].length;i++){
				el = document.getElementById("listGroupCheckGroup-"+D["groupIds"][i]);
				el.checked = true;
				el.onclick();
			}
		}
	}
}

function inList(item,list){
	r = false;
	for(var i=0;i<list.length;i++){
		if (list[i]==item){
			r = true;
		}
	}
	return r;
}

function getPermValue(theField)
{
	groupList = []
	userList = []
	allUserList = []
	groupNames = []
	userNames = []
	groups = document.getElementsByClassName("groupCheck")
	for(i=0;i<=groups.length;i++)
	{
		if (groups[i] != undefined)
		{
			if (groups[i].checked)
			{
				groupList.push(parseInt(groups[i].getAttribute("group")))
				groupNames.push(groups[i].getAttribute("checkName"))
				els = document.getElementsByClassName("groupCheckUser")
				for(j=0;j<=els.length;j++)
				{
					if (els[j] != undefined)
					{
						if (els[j].checked && els[j].getAttribute("group") == groups[i].getAttribute("group"))
						{
							allUserList.push(els[j].getAttribute("userId"))
						}
					}
				}
			}
			else
			{
				els = document.getElementsByClassName("groupCheckUser")
				for(j=0;j<=els.length;j++)
				{
					if (els[j] != undefined)
					{
						if (els[j].checked && els[j].getAttribute("group") == groups[i].getAttribute("group"))
						{
							if (!inList(els[j].getAttribute("userId"),userList)){
								userList.push(parseInt(els[j].getAttribute("userId")))
								userNames.push(els[j].getAttribute("checkName"))
							}
							allUserList.push(els[j].getAttribute("userId"))
						}
					}
				}
			}
		}
	}
	r = {}
	r["groupIds"] = groupList;
	r["userIds"] = userList;
	r["groupNames"] = groupNames;
	r["userNames"] = userNames;
	return r
}

function setGroups()
{
	groupList = []
	userList = []
	allUserList = []
	groups = document.getElementsByClassName("groupCheck")
	for(i=0;i<=groups.length;i++)
	{
		if (groups[i] != undefined)
		{
			if (groups[i].checked)
			{
				groupList.push(groups[i].getAttribute("group"))
				els = document.getElementsByClassName("groupCheckUser")
				for(j=0;j<=els.length;j++)
				{
					if (els[j] != undefined)
					{
						if (els[j].checked && els[j].getAttribute("group") == groups[i].getAttribute("group"))
						{
							allUserList.push(els[j].getAttribute("userId"))
						}
					}
				}
			}
			else
			{
				els = document.getElementsByClassName("groupCheckUser")
				for(j=0;j<=els.length;j++)
				{
					if (els[j] != undefined)
					{
						if (els[j].checked && els[j].getAttribute("group") == groups[i].getAttribute("group"))
						{
							userList.push(els[j].getAttribute("userId"))
							allUserList.push(els[j].getAttribute("userId"))
						}
					}
				}
			}
		}
	}
	document.getElementById("groupIds").value = groupList.join(",")
	document.getElementById("userIds").value = userList.join(",")
	document.getElementById("allUserIds").value = allUserList.join(",")
	document.getElementById("numUsers").innerHTML = userList.length;
	document.getElementById("numGroups").innerHTML = groupList.length;
}