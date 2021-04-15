
function MaskRow(props) {

    var maskSetting = props.masksetting;
    var maskValue = "";

    if (maskSetting != undefined && maskSetting != "") {
        maskValue = maskSetting.displayName;
    }

    return(
        <tr groupid={props.groupid}>
            <td>
                <div className="groupNameContainer">{window.groupsList.find(x => x.id == props.groupid).name}</div>
            </td>
            <td>
                <input
                    type="text"
                    className="maskValueInput"
                    value={maskValue}
                    dropdownoptionindex={props.dropdownoptionindex}
                    dropdownoptionid={props.dropdownoptionid}
                    groupid={props.groupid}
                    onChange={props.setMaskValueFn}                    
                    onBlur={props.maskValidationOnBlurFn}
                    >
                </input>
            </td>
        </tr>
    )
}

class MaskEditor extends React.Component {
    
    constructor(props) {
        super(props);
    }

    render() {
        return (
            <div className="dropdownOptionMaskSettingsContainer makeVisible">
                <div className="dropdownOptionMasksSection" id="dropdownOptionMasksEditorSection">
                    <label className="editorSectionLabel">Option Masks for "{this.props.displayName}"</label>
                    <div className="editorSection dropdownOption" sectionid="dropdownOptionMasks">
                        <div className="editorSectionTableContainer">
                            <table className="editorSectionTable restrictAccessTable dropdownOptionMasksTable dropdownOptionMaskSettingsTable dataTable" id="dropdownOptionMasksTable">
                                <thead>
                                    <tr>
                                        <th>Group Name</th>
                                        <th>Mask Value</th>
                                    </tr>
                                </thead>
                                <tbody>{
                                    window.groupsList.map(x => 
                                        <MaskRow
                                            groupid={x.id}
                                            key={x.id}
                                            masksetting={this.props.currentMaskSettings.find(y => y.groupId == x.id)}
                                            dropdownoptionindex={this.props.dropdownOptionIndex}
                                            dropdownoptionid={this.props.dropdownOptionId}
                                            setMaskValueFn={this.props.setMaskValueFn}
                                            maskValidationOnBlurFn={this.props.maskValidationOnBlurFn}
                                        />
                                    )
                                }</tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <button className="basicActionButton cancelChangesButton" onClick={this.props.hideMaskEditorFn}>Hide Mask Editor</button>
            </div>
        )
    }
}

function DropdownEditorRow(props) {
	return (
		<tr>
			<td>
				<input
					type="text"
					className="optionDisplayName"
					value={props.value}
					index={props.index}
					onChange={props.setDropdownNameFn}
				></input>
			</td>
			<td>
				<input
					type="checkbox"
					className="optionIsDisabled"
					checked={props.disabled}
					index={props.index}
					onChange={props.setDisabledFn}
				></input>
			</td>
			<td>
				<button
					className="basicActionButton manageMaskButton"
                    index={props.index}
                    dropdownindex={props.index}
					onClick={props.manageMaskFn}
				>
					Manage
				</button>
			</td>
			<td>
				<button
					className="editorSectionTableRowDeleteButton"
					hidden={props.dropdownOptionId != 0}
					index={props.index}
					onClick={props.deleteDropdownFn}
				>
					Delete
				</button>
			</td>
		</tr>
	);
}

class DropdownEditor extends React.Component {

    constructor(props) {
        super(props);
    }

    renderMaskEditor(displayName, dropdownOptionIndex, currentMaskSettings, setMaskValueFn, hideMaskEditorFn, dropdownOptionId, maskValidationOnBlurFn) {
        return(
            <MaskEditor                
                displayName={displayName}
                dropdownOptionIndex={dropdownOptionIndex}
                currentMaskSettings={currentMaskSettings}
                setMaskValueFn={setMaskValueFn}
                hideMaskEditorFn={hideMaskEditorFn}
                dropdownOptionId={dropdownOptionId}
                maskValidationOnBlurFn={maskValidationOnBlurFn}
            />
        )
    }

    render() {

        var maskEditor;

        if (this.props.maskOptionId != null) {
            maskEditor = this.renderMaskEditor(
                this.props.maskName,
                this.props.maskOptionId,
                this.props.maskSettings,
                this.props.setMaskValueFn,
                this.props.hideMaskEditorFn,
                this.props.dropdownOptions[this.props.maskOptionId].id,
                this.props.maskValidationOnBlurFn
            )
        }

        return (
            <div className="dropdownEditor">
                <label className="editorSectionLabel">Dropdown Options</label>
                <div className="editorSection" sectionid="dropdownOptions">
                    <div className="aboveEditorTableButtonsContainer">
						<button className="newDropdownOptionButton basicActionButton" onClick={this.props.addDropdownFn}>+ New Option</button>
                    </div>
                    <div className="editorSectionTableContainer dropdownOptionsTableContainer">
                        <table className = "editorSectionTable dropdownOptionsTable dataTable" id="dropdownOptionsTable">
                            <thead>
                                <tr>
                                    <th>Option Name</th>
                                    <th>Disabled</th>
                                    <th>Masking</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                                {this.props.dropdownOptions.map(
                                    (x, index) => 
                                    <DropdownEditorRow
                                        value={x.displayName}
                                        disabled={x.disabled}
                                        key={index}
                                        index={index}
                                        dropdownOptionId={x.dropdownOptionId}
                                        deleteDropdownFn={this.props.deleteDropdownFn}
                                        setDropdownNameFn={this.props.setDropdownNameFn}
                                        setDisabledFn={this.props.setDisabledFn}
                                        manageMaskFn={this.props.manageMaskFn}
                                    />
                                )}
                            </tbody>
                        </table>
                    </div>
					
                </div>
                {maskEditor}
            </div>
        );
    }
}

class DropdownEditorContainer extends React.Component {

    constructor(props) {
        super(props);

        var dropDownId = this.props.dropDownId === null ? 0 : this.props.dropDownId;
        var dropdownDisplayName = "";
        var hoverText = "";
        var disabled = 0;
        var maskValues = 0;
        var dropDownOptionsArray = [{
            disabled: 0,
            displayName: "",
            id: 0,
            dropDownId: dropDownId,
            dropDownOptionMaskings: []
        }];

        if (dropDownId != 0) {
            var thisDropdown = window.dropdownsArray.find(x => x.id == dropDownId);
            dropdownDisplayName = thisDropdown.displayName;
            hoverText = thisDropdown.hoverText;
            disabled = thisDropdown.disabled;
            maskValues = thisDropdown.isMasked;
            dropDownOptionsArray = thisDropdown.options;

            dropDownOptionsArray = dropDownOptionsArray.map(function(dropDown) {
                
                var maskSettingsArray = dropDown.maskSettings;

                if (maskSettingsArray == null) {
                    maskSettingsArray = [];
                }

                maskSettingsArray = maskSettingsArray.map(function(maskSetting) {
                    return {
                        displayName: maskSetting.maskValue,
                        groupId: maskSetting.groupId,
                        dropDownOptionId: dropDown.dropdownOptionId
                    }
                });

                return {
                    disabled: dropDown.disabled,
                    displayName: dropDown.displayName,
                    dropDownId: dropDownId,
                    id: dropDown.dropdownOptionId,
                    dropDownOptionMaskings: maskSettingsArray
                }
            });
        }

        this.state = {
            id: dropDownId,
            displayName: dropdownDisplayName,
            disabled: utilities().boolToInt(disabled),
            hoverText: hoverText,
            maskValues: maskValues,
            dropDownOptions: dropDownOptionsArray,
            currentOptionMask: null,
            errors: {}
        }
    }

	addDropdownOption() {
        var dropdowns = this.state.dropDownOptions;
		dropdowns.push({
            id: 0,
            displayName: "",
            disabled: 0,
            dropDownOptionMaskings: []
        });

		this.setState({dropDownOptions: dropdowns});
	}

	deleteDropdown(evt) {
		var key = evt.target.getAttribute("index");
		var newDropdowns = [];

        // There's got to be a more elegant way of removing a single dropdown option than this.
		$.each(this.state.dropDownOptions, function(index, dropdown) {
			if (index != key) {
				newDropdowns.push(dropdown);
			}
        });
        
		this.setState({dropDownOptions: newDropdowns});
    }

    setDropdownNameFn(evt) {        
        var key = evt.target.getAttribute("index");
        var dropdowns = this.state.dropDownOptions;
        
        var thisDropdown = dropdowns[key];
        thisDropdown.displayName = evt.target.value;

        this.setState({dropDownOptions: dropdowns});
    }

    setDisabledFn(evt) {
        var key = evt.target.getAttribute("index");
        var dropdowns = this.state.dropDownOptions;

        var thisDropdown = dropdowns[key];
        thisDropdown.disabled = utilities().boolToInt(evt.target.checked);

        this.setState({dropDownOptions: dropdowns});

        $.each(this.state.dropDownOptions, (dropDownOptionIndex, dropDownOption) => {

            if (dropDownOption.disabled == 0) {
                $.each(dropDownOption.dropDownOptionMaskings, (ddomIndex, ddoMasking) => {
                    var maskVal = ddoMasking.displayName;
                    var maskOptionId = ddoMasking.dropDownOptionId;
                    var maskGroupId = ddoMasking.groupId;
    
                    this.maskValidationFn(maskVal, maskGroupId, maskOptionId, dropDownOptionIndex);
                })
            }
        })
    }

    manageMaskFn(evt) {
        this.setState({currentOptionMask: evt.target.getAttribute("dropdownindex")})
    }

    setMaskValueFn(evt) {
        var currGroupId = evt.target.getAttribute("groupid");
        var currDropdownOptionIndex = evt.target.getAttribute("dropdownoptionindex");
        var currDropdownId = evt.target.getAttribute("dropdownoptionid");
        var stateDropDownOptions = this.state.dropDownOptions;
        var currDropdown = stateDropDownOptions[currDropdownOptionIndex];
        var currDropdownMasks = currDropdown.dropDownOptionMaskings;

        var currDropdownMaskObject = currDropdownMasks.find(x => x.groupId == currGroupId);
        var currMaskId = currDropdownId;

        if (currDropdownMaskObject == undefined) {
            currDropdownMaskObject = {
                groupId: currGroupId,
                dropDownOptionId: currMaskId,
                displayName: evt.target.value
            };
            currDropdownMasks.push(currDropdownMaskObject);
        } else {
            currDropdownMaskObject.displayName = evt.target.value;    
        }

        if (currDropdownMaskObject.displayName == "") {
            currDropdownMasks = currDropdownMasks.filter(x => x != currDropdownMaskObject);
        }

        stateDropDownOptions[currDropdownOptionIndex].dropDownOptionMaskings = currDropdownMasks
        this.setState({dropDownOptions: stateDropDownOptions});
    }

    hideMaskEditorFn(evt) {
        this.setState({currentOptionMask: null});
    }

    maskValidationOnBlurFn(evt) {
        console.log(evt)
        var currentMaskValue = evt.target.value;
        var currentGroupId = evt.target.getAttribute("groupId");
        var currentDropdownId = evt.target.getAttribute("dropdownOptionId");
        var currentDropdownIndex = evt.target.getAttribute("dropdownOptionIndex");

        if (this.state.dropDownOptions.find(x => x.id == currentDropdownId && x.disabled == 0)) {
            this.maskValidationFn(currentMaskValue, currentGroupId, currentDropdownId, currentDropdownIndex);
        }
    }

    maskValidationFn(currentMaskValue, currentGroupId, currentDropdownId, currentDropdownIndex) {
        var currentErrors = this.state.errors;

        var invalidMaskName = false;
        var invalidGroupMask = false;

        var dropdownsArray = this.state.dropDownOptions.filter(x => x.disabled == 0 && x.id != currentDropdownId);

        if (dropdownsArray.find(x => x.displayName == currentMaskValue)) {
            invalidMaskName = true;
        }

        $.each(dropdownsArray, function(dropdownIndex, dropdown) {
            var dropdownMasks = dropdown.dropDownOptionMaskings;
            if (dropdownMasks.filter(x => x.groupId == currentGroupId && x.displayName == currentMaskValue).length > 0 && currentDropdownIndex != dropdownIndex) {
                if (currentMaskValue != "")
                {
                    invalidGroupMask = true;
                    return false;
                }
            }
        })

        if (invalidMaskName || invalidGroupMask) {

            if (!Object.keys(currentErrors).includes(currentDropdownId)) {
                currentErrors[currentDropdownId] = [];
            }

            var currentDropdownErrors = currentErrors[currentDropdownId];

            if (!currentDropdownErrors.includes(currentGroupId)) {
                currentDropdownErrors.push(currentGroupId);
            }

            currentErrors[currentDropdownId] = currentDropdownErrors;

            this.setState({errors: currentErrors});

            if (invalidMaskName) {
                swal("Invalid Mask Value", "Value matches a real option value", "error");
                return;
            }
            else if (invalidGroupMask) {
                swal("Invalid Mask Value", "Value matches another mask value for this group", "error");
                return;
            }
        } else {
            if (Object.keys(currentErrors).includes(currentDropdownId)) {
                var newErrors = currentErrors[currentDropdownId].filter(x => x != currentGroupId);

                if (newErrors.length > 0) {
                    currentErrors[currentDropdownId] = newErrors;
                } else {
                    delete currentErrors[currentDropdownId];
                }

                this.setState({errors: currentErrors});
            }
        }

    }

    renderDropdownEditor(maskName, maskOptionId, maskSettings, deleteDropdownFn, addDropdownFn, setDropdownNameFn, setDisabledFn, manageMaskFn, setMaskValueFn, hideMaskEditorFn, maskValidationOnBlurFn) {
        return (
            <DropdownEditor
                dropdownOptions={this.state.dropDownOptions}
                deleteDropdownFn={deleteDropdownFn}
                addDropdownFn={addDropdownFn}
                setDropdownNameFn={setDropdownNameFn}
                setDisabledFn={setDisabledFn}
                manageMaskFn={manageMaskFn}
                maskName={maskName}
                maskOptionId={maskOptionId}
                maskSettings={maskSettings}
                setMaskValueFn={setMaskValueFn}
                hideMaskEditorFn={hideMaskEditorFn}
                maskValidationOnBlurFn={maskValidationOnBlurFn}
            />
        )
    }

    /**
     * Render method for the submit button.
     * @param {function} submitFn 
     */
    renderSubmit(submitFn) {
        return (
            <SubmitButton 
                submitFn={submitFn}
            />
        )
    }

    /**
     * Render method for the cancel button.
     * @param {function} cancelFn 
     */
    renderCancel(cancelFn) {
        return (
            <CancelButton
                cancelFn={cancelFn}
            />
        )
    }

    hideDropdownEditor() {        
        ReactDOM.unmountComponentAtNode(document.getElementById("reactDropdownEditor"));
    }

    submitDropdownEditor() {
        var data = {
            userId: globalUserInfo.userId,
            connectionId: connectionId,
            dropDown: this.state,
            appName: "Configuration"
        };

        // Submit the data, passing in the state of this component so we have access to it down the chain.
        ajaxModule().submitDropdown(data).then(function(response, currState = data.dropDown) {

            // Second verse, same as the first. We want to make sure we have access to this.state, so declare it here and
            // pass it into the next .then()
            var currState = currState;
            var serviceObj = {
                configService: false,
            };
            
            console.log("success");
            
            // Create the upsertSavedFieldNotification
            window.upsertSavedFieldNotification = $.notify({
                title: notificationTitle,
                message: ""
            }, {
                delay: 0,
                type: "yellowNotification"
            });

            // Figure out what our notification title is, then show the notification.
            var notificationTitle = "";
            if (currState.id) {
                notificationTitle = `Successfully updated dropdown ${currState.displayName}.`;
            }
            else {
                notificationTitle = `Successfully created new dropdown ${currState.displayName}.`;
            }
            window.upsertSavedFieldNotification.update({ 'title': notificationTitle, 'message': "", type: "success" })
            
            swal({
                title: "Dropdown successfully updated",
                type: "success",
                confirmButtonText: "Ok",
                timer: 1100
            });
            setTimeout(function () {
                window.upsertSavedFieldNotification.close();
            }, 4000);

            ReactDOM.unmountComponentAtNode(document.getElementById("reactDropdownEditor"));

            // Reload the page so the latest changes can be seen.
            location.reload();

        }).catch(function () {
            // TODO: replace this.state here with something that would actually work.

            console.log("error");
            if (this.state.id) {
                notificationTitle = 'Failed to update dropdown "' + this.state.displayName + '".';
            }
            else {
                notificationTitle = 'Failed to create new dropdown "' + this.state.displayName + '".';
            }
            window.upsertSavedFieldNotification.update({ 'title': notificationTitle, 'message': "", type: "danger" })
        });
    }

    /**
     * Hides the field editor.
     */
    hideDropdownEditor() {        
        ReactDOM.unmountComponentAtNode(document.getElementById("reactDropdownEditor"));
    }

    render() {

        // Render the each of the field editors, or null if certain conditions are met.
		var displayName = renderFieldEditor("displayName", "Dropdown Name", (i) => setTextState(i, "displayName", this), "text", this.state.displayName);
        var hoverText = renderFieldEditor("hoverText", "Dropdown Hover Text", (i) => setTextState(i, "hoverText", this), "text", this.state.hoverText);
        var maskingBox = renderFieldEditor("maskValues", "Dropdown Masking", (i) => setCheckboxState(i, "maskValues", this), "checkbox", this.state.maskValues);

        var maskName;
        var maskSettings;

        if (this.state.currentOptionMask != null) {

            var thisDropdown = this.state.dropDownOptions[this.state.currentOptionMask];
            maskName = thisDropdown.displayName;
            maskSettings = thisDropdown.dropDownOptionMaskings;
        }

        var dropdownEditor = this.renderDropdownEditor(
            maskName,
            this.state.currentOptionMask,
            maskSettings,
            (i) => this.deleteDropdown(i),
            ()  => this.addDropdownOption(),
            (i) => this.setDropdownNameFn(i),
            (i) => this.setDisabledFn(i),
            (i) => this.manageMaskFn(i),
            (i) => this.setMaskValueFn(i),
            (i) => this.hideMaskEditorFn(i),
            (i) => this.maskValidationOnBlurFn(i)
        );
        
        var disabled = renderFieldEditor("disabled", "Disabled", (i) => setCheckboxState(i, "disabled", this), "checkbox", this.state.disabled);
        
        // Now create the submit and cancel buttons.
        var submitButton = Object.keys(this.state.errors).length == 0 ? this.renderSubmit(() => this.submitDropdownEditor()) : null;
        //var submitButton = this.renderSubmit(() => this.submitDropdownEditor());
        var cancelButton = this.renderCancel(() => this.hideDropdownEditor());

        return (
            <div className="dropdownEditorContainer card makeVisible">
                {displayName}
                {hoverText}
                {maskingBox}
                {dropdownEditor}
                {disabled}
                <div className="bottomButtons">
                    {submitButton}
                    {cancelButton}
                </div>
            </div>
        )
    }

}