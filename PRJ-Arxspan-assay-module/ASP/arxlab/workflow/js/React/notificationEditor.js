
window.openNotificationEditor = function(requestTypeId){


	class NotificationTable extends React.Component{
		

		constructor(props){
			super(props);
			
			this.state = {
				whoCodes: this.props.whoCodes,
				eventCodes: this.props.eventCodes,
				typeCodes: this.props.typeCodes,
				notifications: this.props.Notifications,
				requestTypeId: this.props.requestTypeId,
				preserveNotifications: this.props.preserveNotifications
			}
			
			this.updateWhoState = this.updateWhoState.bind(this);
			this.updateEventState = this.updateEventState.bind(this);
			this.updateTypeLevlState = this.updateTypeLevlState.bind(this);
			this.updateFieldIdState = this.updateFieldIdState.bind(this);
			this.updateCheckboxState = this.updateCheckboxState.bind(this);
			this.submitEditor = this.submitEditor.bind(this);
			this.deleteRow = this.deleteRow.bind(this);
		};
		
		blankRow = {
			id: 0,
			whoId: -1,
			userType: -1,
			notificationTrigger: -1,
			typeLvl: -1,
			fieldId: -1,
			}

		updateWhoState(rowId,val,userType){

			let notificationTemp = Object.assign([], this.state.notifications);
			notificationTemp[parseInt(rowId)]['whoId'] = parseInt(val);
			notificationTemp[parseInt(rowId)]['userType'] = parseInt(userType);
			notificationTemp[rowId]['notificationTrigger'] = -1;
			notificationTemp[rowId]['typeLvl'] = -1;
			notificationTemp[rowId]["fieldId"] = -1;
			if (parseInt(rowId) == notificationTemp.length-1)
			{
				notificationTemp.push(JSON.parse(JSON.stringify(this.blankRow)))
			}
			this.setState({
				notifications: notificationTemp
			})
		}

		updateEventState(rowId,val){

			var notificationTemp = this.state.notifications;
			notificationTemp[rowId]['notificationTrigger'] = parseInt(val);
			notificationTemp[rowId]['typeLvl'] = -1;
			notificationTemp[rowId]["fieldId"] = -1;
			if (val == 1)
			{
				notificationTemp[rowId]['typeLvl'] = 1;
			}
			this.setState({
				notifications: notificationTemp
			})
		}

		updateTypeLevlState(rowId,val){

			var notificationTemp = this.state.notifications;
			notificationTemp[rowId]['typeLvl'] = parseInt(val);
			notificationTemp[rowId]["fieldId"] = -1;
			if (val == 2)
			{
				var fieldsInQuestion = window.requestTypesArray.find(x=>x.id == parseInt(this.props.requestTypeId)).fields;
				if (fieldsInQuestion.length == 1)
				{
					notificationTemp[rowId]["fieldId"] = fieldsInQuestion[0]["requestTypeFieldId"];
				}
			}
			else if (val == 4)
			{
				var itemsInQuestion = window.requestTypesArray.find(x=>x.id == parseInt(this.props.requestTypeId)).requestItemTypes;
				if (itemsInQuestion.length == 1)
				{
					var myItem = itemsInQuestion[0];
					myItem = window.requestItemTypesArray.find(x => x.id == myItem.requestItemTypeId);
					var fieldsInQuestion = myItem.fields;
					if(fieldsInQuestion.length == 1)
					{
						notificationTemp[rowId]["fieldId"] = fieldsInQuestion[0]["requestTypeFieldId"];
					}
				}
			}
			this.setState({
				notifications: notificationTemp
			})
		}

		updateFieldIdState(rowId,val, itemTypeId=0){

			var notificationTemp = this.state.notifications;
			notificationTemp[rowId]['fieldId'] = parseInt(val);
			if (itemTypeId != 0)
			{
				notificationTemp[rowId]['requestTypeItemId'] = parseInt(itemTypeId);
			}
			this.setState({
				notifications: notificationTemp
			})
		}

		updateCheckboxState(rowId,val,key){

			var notificationTemp = this.state.notifications;
			notificationTemp[rowId][key] = val ? 1 : 0;
			this.setState({
				notifications: notificationTemp
			})
		}

		deleteRow(rowId){

			var notificationTemp = this.state.notifications;
			notificationTemp.splice(rowId,1);
			this.setState({
				notifications: notificationTemp
			})
		}

		submitEditor(){

			notificationSubmitionModule().submitNotificationEditor(this.state);

		}

		render(){
			return(


				<div>
					<ReactTable
						data={this.state.notifications}
						columns = {[{
							Header: "Event setup",
							columns: [{
								Header: "Who",
								accessor: "whoId",
								Cell: row => (
									<WhoDropDownCell 
									whoCodes= {this.state.whoCodes}
									updateWhoState = {this.updateWhoState}
									row = {row}
									/>
								)
							},
							{
								Header: "Event Type",
								accessor: "notificationTrigger",
								Cell: row => (
									<EventDropDownCell 
									eventCodes = {this.state.eventCodes}
									updateEventState = {this.updateEventState}
									row = {row}
									/>
								)
							},
							{
								Header: "Type Level",
								accessor: "typeLvl",
								Cell: row => (
									<TypeDropDownCell 
									updateTypeLevlState = {this.updateTypeLevlState}
									row = {row}
									/>
								)
							},
							{
								Header: "Field",
								accessor: "fieldId",
								Cell: row => (
									<FieldDropDownCell
										requestTypeId = {this.state.requestTypeId}
										updateFieldIdState = {this.updateFieldIdState}
										row = {row} 
									/>
								)
								
							}]},
							{
								Header: "Notification setup",
								columns: this.props.typeCodes.map(function(x){
									return(
										{
											Header: x.codeDescription,
											accessor: x.codeDescription,
											Cell: row => (
												<NotificationTypeCheckBox 
												updateCheckboxState = {this.updateCheckboxState}
												Name = {x.codeDescription}
												row = {row}
												/>
											)
										}
									)
								},this)
							},
							{
								Header: "",
								columns: [{
									Header: "",
									width: 85,
									Cell: row => (
										<DeleteRowCell 
										row = {row}
										deleteRow = {this.deleteRow}
										/>
									)
								}]
							}
						]}
						defaultPageSize = {10}
						style={{
							height: "75%" // This will force the table body to overflow and scroll, since there is not enough room
						  }}
						className = "-striped -highlight show-scroll" 
					/>
					<br />
					<NotificationModalBtns updateFN={this.submitEditor} />
				</div>
			);
		}

	}





	var serviceObj = {
		configService: true,
	};

	var notificationCodes = []
  var codeParams = {
			appName: "Workflow",
			setName: "userType"
  };
	notificationCodes.push(ajaxModule().getCodes(codeParams));
	codeParams.setName = "workflowNotificationTrigger";
	notificationCodes.push(ajaxModule().getCodes(codeParams));
	codeParams.setName = "notificationType";
  notificationCodes.push(ajaxModule().getCodes(codeParams));

	var Notifications = [];
	if (window.CurrentPageMode == 'editRequestTypes')
	{
		Notifications = notificationLoadingModule().getNotificationsForTableFromDOM(window.requestTypesArray.find(x => x.id == requestTypeId));
		var preserveNotifications = notificationLoadingModule().removeUserSettings(Notifications, true);
		Notifications = notificationLoadingModule().removeUserSettings(Notifications, false);
		Notifications = notificationLoadingModule().prossesNotifications(Notifications);
	}
	else 
	{
		 Notifications = notificationLoadingModule().getNotificationsForTableFromJSON(window.requestTypesArray.find(x => x.id == requestTypeId));
		 var preserveNotifications = Notifications;
		 Notifications = notificationLoadingModule().prossesNotifications(Notifications);
		 Notifications = notificationLoadingModule().whatMattersToMe(Notifications);
	}
    

	Promise.all(notificationCodes).then(function(codes){

		Notifications = groupNotificationsByFieldNames(Notifications, requestTypeId);
		codes = utilities().decodeServiceResponce(codes);

		//this is what actualy puts things in the dom 
 		 ReactDOM.render(
            <NotificationModal>
				 <NotificationTable 
                        whoCodes = {codes[0]} 
                        eventCodes = {codes[1]} 
                        typeCodes = {codes[2]} 
                        Notifications = {Notifications}
						requestTypeId = {requestTypeId}
						preserveNotifications = {preserveNotifications}
                    />
            </NotificationModal>,
			document.getElementById("reactTest")); 

			

		$('#notificationEditorModal').modal().show();
		

	});

}


function DeleteRowCell(props){


	function deleteRow(evt){
		props.deleteRow(evt.target.attributes.rowid.nodeValue);
	};


	if (props.row.row.whoId == -1)
	{
		return(
			<div>
			
			</div>
		)
	}
	else 
	{
		return(
			<div>
				<button 
				index="0" 
				className="btn btn-danger fa fa-trash-o" 
				rowid = {props.row.index}
				onClick = {deleteRow}
				></button>
			</div>
		)
	}
}


function WhoDropDownCell(props){
	

	function updateWho(evt){
		props.updateWhoState(evt.target.attributes.rowid.nodeValue, evt.target.value,evt.target.selectedOptions[0].attributes.usertype.nodeValue);
	};
	return(
		
		<select className="custom-select max-Width"
		value = {props.row.value}
		rowid = {props.row.index}
		onChange = {updateWho}>
			<option key={-1} value={-1}>New Notification</option>
			{props.whoCodes.map(function(x){
					if(x.codeValue == 1)
					{
						return (
							
							<optgroup key={x.codeValue} label={x.codeDescription}>
								<GroupsOptions />
							</optgroup>
							
						);
					}
					else if (x.codeValue == 2)
					{
						return (
							<optgroup key={x.codeValue} label={x.codeDescription}>
								<UserOptions />
							</optgroup>
						);
					}
			})}
			<optgroup key="Other" label="Other">
				<OtherOptions />
			</optgroup>
		</select>
		
	);
	
}

function EventDropDownCell(props){


	function updateEvent(evt){
		props.updateEventState(evt.target.attributes.rowid.nodeValue, evt.target.value);
	}

	if (props.row.row.whoId == -1)
	{
		return(
			<div key="groupKey2">
				
			</div>
		);
	}
	else 
	{
		return(
			
				<select className="custom-select max-Width"
					value = {props.row.value}
					rowid = {props.row.index}
					onChange = {updateEvent}
				>
					<option value = {-1}>Select Event</option>
					{props.eventCodes.map(function(x){
						return (
							<option value = {x.codeValue} key = {x.codeValue}>{x.codeDescription}</option>
						);
					})}
				</select>
			
		);
	}
	
}


function TypeDropDownCell(props){
		

	
	var requestTypeOption = {disciption: "Request Type", value: "1"}
	var requestTypeFieldOption = {disciption: "Request Type Field", value: "2"}
	var requestTypeItemOption = {disciption: "Request Type Item", value: "3"}
	var requestTypeItemFieldOption = {disciption: "Request Type Item Field", value: "4"}
	var Levels = [{disciption: "Select Type Level", value: "-1"}]

	if (props.row.row.notificationTrigger == -1)
	{}
	else if (props.row.row.notificationTrigger == 1)
	{
		Levels.push(requestTypeOption);
	}
	else if (props.row.row.notificationTrigger == 2)
	{
		Levels.push(requestTypeFieldOption);
		Levels.push(requestTypeItemFieldOption);
	}
	else if (props.row.row.notificationTrigger == 3)
	{
		Levels.push(requestTypeOption);
		Levels.push(requestTypeItemOption);
	}
	else
	{
		Levels.push(requestTypeOption);
		Levels.push(requestTypeFieldOption);
		Levels.push(requestTypeItemOption);
		Levels.push(requestTypeItemFieldOption);
	}

	function updateEvent(evt){
		props.updateTypeLevlState(evt.target.attributes.rowid.nodeValue, evt.target.value);
	}

		if(props.row.row.notificationTrigger == -1)
		{
			return( 	
				<div key="groupKey3">
				
				</div>
			);
		}
		else
		{
			return(
		
				<select className="custom-select max-Width"
				value = {props.row.value}
				rowid = {props.row.index}
				onChange = {updateEvent}
				>
					{Levels.map(function(x){
						return (
							<option value = {x.value} key = {x.disciption}>{x.disciption}</option>
						);
					})}
				</select>
			
			);
		}
}



function FieldDropDownCell(props){

	


	if(props.row.row.typeLvl == 2 || props.row.row.typeLvl == 4)
	{

		if (parseInt(props.requestTypeId) != -1)
		{

			if (props.row.row.typeLvl == 2)
			{
				function updateEvent(evt){
					props.updateFieldIdState(evt.target.attributes.rowid.nodeValue, evt.target.value);
				}
				var requestTypeFields = window.requestTypesArray.find(x => x.id == props.requestTypeId)['fields'];

				//this is temparary remove after dups are resolved
				
				var tempArr = []
				$.each(requestTypeFields, function(i,item){
					var inside = tempArr.find(x => x.requestTypeFieldId == item['requestTypeFieldId']);
					if (!inside)
					{
						tempArr.push(item);
					}
				})
				
				requestTypeFields = tempArr;
				requestTypeFields = sortByKey(requestTypeFields, "displayName");

				return(
				
					<select className="custom-select max-Width"
						value = {props.row.value}
						rowid = {props.row.index}
						onChange = {updateEvent}
					>
						<option value = "-1" key = "none">Select Field</option>
						{requestTypeFields.map(function(x){
							return (
								<option value = {x.requestTypeFieldId} key = {x.displayName}>{x.displayName}</option>
							);
						})}
						
		
					</select>
				);
			}
			else if (props.row.row.typeLvl == 4) 
			{

				function updateEvent(evt){
					props.updateFieldIdState(evt.target.attributes.rowid.nodeValue, evt.target.value, evt.target.selectedOptions[0].attributes.itemtypeid.nodeValue);
				}
				var requestType = window.requestTypesArray.find(x => x.id == props.requestTypeId);
				var requestItemTypes = requestType['requestItemTypes']

				var fields = requestItemTypes.map(function(u){
					var itemTypeField = window.requestItemTypesArray.find(x => x.id == u.requestItemTypeId)['fields'];
					itemTypeField = sortByKey(itemTypeField, "displayName");
					return (
						<optgroup key={u.requestItemTypeId} label={u.requestItemName}>
							{itemTypeField.map(function(x){
								return(
									<option value = {x.requestTypeFieldId} itemtypeid = {u.requestItemId} key = {x.displayName}>{x.displayName}</option>
								)
							})}
						</optgroup>
					);
				});

				return(
				
					<select className="custom-select max-Width"
						value = {props.row.value}
						rowid = {props.row.index}
						onChange = {updateEvent}
					>
						<option value = "-1" key = "none">Select Field</option>
						{fields}
					</select>
				);

			}


		}
		else
		{
			return(
				<div></div>
			)
		} 

	}
	else
	{

		if(props.row.row.typeLvl == 3)
		{
			function updateEvent(evt){
				props.updateFieldIdState(evt.target.attributes.rowid.nodeValue, evt.target.value);
			}
			var requestType = window.requestTypesArray.find(x => x.id == props.requestTypeId);
			var requestItemTypes = requestType['requestItemTypes']

			var requestTypeOptions =  requestItemTypes.map(function(x){
				return(
					<option value = {x.requestItemId} key = {x.requestItemName}>{x.requestItemName}</option>
				);
			});

			return(
			
				<select className="custom-select max-Width"
					value = {props.row.value}
					rowid = {props.row.index}
					onChange = {updateEvent}
				>
					<option value = "-1" key = "none">Select Item</option>
					{requestTypeOptions}
				</select>
			);
		}
		else
		{
			return(
				<div></div>
			)
		}
	} 

	
}

function NotificationTypeCheckBox(props){

				
	function updateEvent(evt){
		props.updateCheckboxState(evt.target.attributes.rowid.nodeValue, evt.target.checked, evt.target.name);
	}

	
	if(props.row.row.typeLvl == 1)
	{
		return(
			<div className="center-Align">
				<label className="switch">
					<input type="checkbox" 
					name={props.Name}
					key={props.Name}
					rowid = {props.row.index}
					checked={props.row.value == 1} 
					onChange = {updateEvent}
					/>
					<span className="slider round" ></span>
				</label>
			</div>
		);
		
	}
	else if((props.row.row.typeLvl == 2 || props.row.row.typeLvl == 4 || props.row.row.typeLvl == 3) && props.row.row.fieldId != -1)
	{
		return(
			<div className="center-Align">
				<label className="switch">
					<input type="checkbox" 
					name={props.Name}
					key={props.Name}
					rowid = {props.row.index}
					checked={props.row.value == 1} 
					onChange = {updateEvent}
					/>
					<span className="slider round"></span>
				</label>
			</div>
		);
		
	}
	else
	{
		return(
			<div></div>
		);
	}
	
}

/**
 * Groups Notifications by type level and field name.
 * @param {*} Notifications The notifications array
 * @param {*} requestTypeId The current request type ID
 */
function groupNotificationsByFieldNames(Notifications, requestTypeId) {

	// Filter down Notifications into various bins.
	var fieldNotifications = Notifications.filter(x => x.fieldId > -1);
	var typeNotifications = fieldNotifications.filter(x => x.typeLvl == 1);
	var requestFieldNotifications = fieldNotifications.filter(x => x.typeLvl == 2);
	var itemTypeNotifications = fieldNotifications.filter(x => x.typeLvl == 3);
	var itemFieldNotifications = fieldNotifications.filter(x => x.typeLvl == 4);
	var fieldlessNotifications = Notifications.filter(x => !fieldNotifications.includes(x));

	// Sort the bins we care about.
	var sortedRequestFieldNotifications = sortNotificationsArray(requestFieldNotifications, "fieldId", requestTypeId);
	var sortedItemFieldNotifications = sortNotificationsArray(itemFieldNotifications, "fieldId", requestTypeId);
	var sortedTypeNotifications = sortTypesArray(typeNotifications, "fieldId");
	var sortedItemTypeNotifications = sortItemTypesArray(itemTypeNotifications, "fieldId");

	// Concat it all.
	return sortedRequestFieldNotifications.concat(sortedItemFieldNotifications, sortedTypeNotifications, sortedItemTypeNotifications, fieldlessNotifications);
}

/**
 * Sort the field notifications array by display name.
 * @param {*} arr The array to sort
 * @param {*} key The key to sort on
 * @param {*} requestTypeId The request type whose fields we want to sort
 */
function sortNotificationsArray(arr, key, requestTypeId) {

	var thisRequestType = requestTypesArray.find(x => x.id == requestTypeId);
	var thisRequestTypeFields = thisRequestType["fields"];

	$.each(thisRequestType["requestItemTypes"], function(i, requestItemType) {
		var requestItemTypeId = requestItemType["requestItemTypeId"];
		var thisRequestItemType = requestItemTypesArray.find(x => x.id == requestItemTypeId);
		thisRequestTypeFields = thisRequestTypeFields.concat(thisRequestItemType.fields);
	});

	return utilities().sortHelper(arr, key, (x) => fieldIdToFieldName(thisRequestTypeFields, x));
}

/**
 * Sort the request types array by display name.
 * @param {*} arr The array to sort
 * @param {*} key The key to sort on
 */
function sortTypesArray(arr, key) {
	return utilities().sortHelper(arr, key, (x) => getRequestTypeDisplayName(x));
}

/**
 * Sort the request item types array by display name.
 * @param {*} arr The array to sort
 * @param {*} key The key to sort on
 */
function sortItemTypesArray(arr, key) {
	return utilities().sortHelper(arr, key, (x) => getRequestItemTypeDisplayName(x));
}

/**
 * Helper function to find field name from field ID
 * @param {*} fields the array of fields to look in
 * @param {*} requestTypeFieldId The field ID to find.
 */
function fieldIdToFieldName(fields, requestTypeFieldId) {
	var fieldFound = fields.find(x => x.requestTypeFieldId == requestTypeFieldId);
	if (fieldFound == undefined){
		return undefined
	}
	else{
		return fieldFound["displayName"].toLowerCase(); 
	}
}

/**
 * Helper function to get a request type display name.
 * @param {*} requestTypeId The request type ID to find
 */
function getRequestTypeDisplayName(requestTypeId) {
	return requestTypesArray.find(x => x.id == requestTypeId)["displayName"].toLowerCase();
}

/**
 * Helper function to get a request item type display name.
 * @param {*} requestItemTypeId The request item type ID to find.
 */
function getRequestItemTypeDisplayName(requestItemTypeId) {
	return requestItemTypesArray.find(x => x.id == requestItemTypeId)["displayName"].toLowerCase();
}