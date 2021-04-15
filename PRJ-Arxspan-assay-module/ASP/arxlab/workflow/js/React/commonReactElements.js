//$ browserify arxlab/workflow/js/React/commonReactElements.js -t babelify --outfile arxlab/workflow/js/React/bundle.js
//watchify arxlab/workflow/js/React/commonReactElements.js -o arxlab/workflow/js/React/commonReactElementsBundle.js -v

//basic function that creats a modal using babel/ react
function NotificationModal(props){
	return(

		<div className="modal fade in" id="notificationEditorModal" role="dialog">
			<div className="modal-dialog">
				<div className="modal-content card">
					<div className="modal-body">
						<h1>Notification Editor</h1>
						<div>
						
							{props.children}

						</div>
					</div>
				</div>
			</div>
		</div>

	);
}


function NotificationModalBtns(props){

	function closeNotificationEditor(){
		$('#notificationEditorModal').modal().hide();
		$('.modal-backdrop').hide();
		ReactDOM.unmountComponentAtNode(document.getElementById("reactTest"));
	}

	function updateEvent(evt){
		props.updateFN();
	}
	
	return(
		<div className="bottomButtons">
			<button className="submitUpdateButton btn btn-success" id="reactModalUpdateBtn" onClick={updateEvent}>Update Notification Settings</button>
			<button className="cancelChangesButton btn btn-danger" id="reactModalCloseBtn"  onClick={closeNotificationEditor} >Cancel Changes</button>
		</div>

	)
}



function TestModal(props){
	return (
		<div className="modal fade in" id="notificationEditorModal" role="dialog">
			<div className="modal-dialog">
				<div className="modal-content">
					<div className="modal-body">
						<p>Loading...</p>
					</div>
					<div className="modal-footer">
						<button type="button" className="btn btn-default" data-dismiss="modal">Close</button>
					</div>
				</div>
			</div>
		</div>
	);
}

function sortByKey(array, key) {
    return array.sort(function(a, b) {
	var x = a[key]; var y = b[key];
        return ((x < y) ? -1 : ((x > y) ? 1 : 0));
    });
}

function GroupsOptions(props){
	if(window.CurrentPageMode == 'editRequestTypes')
	{
		return(
			sortByKey(window.groupsList, 'name').map(function(group){
				return(
					<option value = {group.id} key={group.id} id={group.id} usertype={1}>{group.name}</option>	
				);
			})
		);
	}
	else
	{
		var myGroups = window.groupsList.filter(x => globalUserInfo["userGroups"].includes(x.id));
		return(
			sortByKey(myGroups, 'name').map(function(group){
				return(
					<option value = {group.id} key={group.id} id={group.id} usertype={1}>{group.name}</option>	
				);
			})
		)
	}
}

function UserOptions(props){
	if(window.CurrentPageMode == 'editRequestTypes')
	{
		return(
			sortByKey(window.usersList, "fullName").map(function(user){
				return(
					<option value = {user.id} key={user.id} id={user.id} usertype={2}>{user.fullName}</option>	
				);
			})
		);
	}
	else
	{
		var myUser = window.usersList.find(x => x.id == globalUserInfo["userId"]);
		return(
			<option value = {myUser.id} key={myUser.id} id={myUser.id} usertype={2}>{myUser.fullName}</option>	
		);
	}
}


function OtherOptions(props){
	return(
		<option value={1} key={1} id={1} usertype={3}>Requester</option>
	);
}



/**
 * Render method for a field editor.
 * @param {int} fieldId 
 * @param {string} labelName 
 * @param {function} callbackFn 
 * @param {string} inputType 
 * @param {*} value 
 */
function renderFieldEditor(fieldId, labelName, callbackFn, inputType, value) {
	return (
		<FieldEditor
			fieldId={fieldId}
			labelName={labelName}
			callbackFn={callbackFn}
			inputType={inputType}
			value={value}
		/>
	)
}

/**
 * On change handler for the editor field text boxes.
 * @param {*} evt 
 * @param {*} key The fieldId of this field, used so we can edit the correct field parameter.
 */
function setTextState(evt, key, containerElem) {
    var stateObj = {};
    stateObj[key] = evt.target.value;
    containerElem.setState(stateObj);
}

/**
 * On change handler for the editor field check boxes.
 * @param {*} evt 
 * @param {*} key The fieldId of this field, used so we can edit the correct field parameter.
 */
function setCheckboxState(evt, key, containerElem) {
    var stateObj = {};
    stateObj[key] = utilities().boolToInt(evt.target.checked);
    containerElem.setState(stateObj);
}