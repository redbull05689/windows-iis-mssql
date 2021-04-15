
/**
 * Constructor for a field text box element. Instantiated with:
 * <FieldTextBox
 * {props go here}
 * />
 * @param {*} props The React props for this element. They are: fieldid, labelname, value, onChange.
 */
function FieldTextBox(props) {

	var fieldId = props.fieldid;
	var displayText = props.labelname;
	var value = props.value;

	return (	
		<div className="editorField" fieldid={fieldId}>
			<label className="editorFieldLabel">{displayText}</label>
			<input
				type="text"
				className="editorFieldInput"
				onChange={props.onChange}
				value={value}
			>
			</input>
		</div>
	);
}

/**
 * Constructor for a data type selector element. Instantiated with:
 * <DataTypeSelector
 * {props go here}
 * />
 * @param {*} props The React props for this element. They are: fieldId, labelName, value, onChange.
 */
function DataTypeSelector(props) {

	var dataTypes = window.dataTypesArray;
	var fieldId = props.fieldId;
	var displayText = props.labelName;

	return (	
		<div className="editorField" fieldid={fieldId}>
			<label className="editorFieldLabel">{displayText}</label>
			<select
				className="editorFieldDropdown dataTypeDropdown"
                onChange={props.onChange}
                value={props.value}
			>
				{dataTypes.map(function(dataType) {
					return (
						<option
							value={dataType.id}
							key={dataType.id}
						>
							{dataType.displayName}
						</option>
					)
				})}
			</select>
		</div>
	);
}

/**
 * Constructor for a checkbox element. Instantiated with:
 * <FieldCheckBox
 * {props go here}
 * />
 * @param {*} props The React props for this element. They are: fieldId, displayText, checked, onChange.
 */
function FieldCheckBox(props) {

	var fieldId = props.fieldId;
	var displayText = props.displayText;
	var elemName = `dropdownEditor_${fieldId}_cb`;

	return (
		<div className="editorField" fieldid={fieldId}>
			<input
				type="checkbox"
				className="editorFieldCheckbox"
				name={elemName}
				id={elemName}
				onChange={props.onChange}
				checked={props.checked==1}
			>
			</input>
			<label
				className="editorFieldLabel"
				htmlFor={elemName}
			>
				{displayText}
			</label>
		</div>
	);
}

/**
 * Constructor for a checkbox element. Instantiated with:
 * <FieldDropdownEditorRow
 * {props go here}
 * />
 * @param {*} props The React props for this element. They are: value, index, setDropdownNameFn, dropdownsSynced, setDisabledFn, deleteDropdownFn
 */
function FieldDropdownEditorRow(props) {
	return (
		<tr>
			<td>
				<input
					type="text"
					className="optionDisplayName"
					value={props.value}
					index={props.index}
					onChange={props.setDropdownNameFn}
					disabled={props.dropdownsSynced}
				></input>
			</td>
			<td>
				<input
					type="checkbox"
					className="optionIsDisabled"
					checked={props.disabled}
					index={props.index}
					onChange={props.setDisabledFn}
					disabled={props.dropdownsSynced}
				></input>
			</td>
			<td>
				<button
					className="editorSectionTableRowDeleteButton"
					hidden={props.dropdownsSynced}
					index={props.index}
					onClick={props.deleteDropdownFn}
				>
					Delete
				</button>
			</td>
		</tr>
	);
}

/**
 * Constructor for a submit button element. Instantiated with:
 * <SubmitButton
 * {props go here}
 * />
 * @param {*} props The React props for this element. Only needs a submitFn.
 */
function SubmitButton(props) {
    return(
        <button className="dropdownEditorSubmit submitButton btn btn-success" onClick={props.submitFn}>
            Submit
        </button>
    )
}

/**
 * Constructor for a cancel button element. Instantiated with:
 * <CancelButton
 * {props go here}
 * />
 * @param {*} props The React props for this element. Only needs a cancelFn.
 */
function CancelButton(props) {
    return(
        <button className="dropdownEditorCancel cancelButton btn btn-danger" onClick={props.cancelFn}>
            Cancel
        </button>
    )
}

/**
 * Field Editor class. Encompasses text boxes, checkboxes, and the data type selector.
 */
class FieldEditor extends React.Component {

    /**
     * Constructor for the field editor.
     */
	constructor(props) {
		super(props);
	}

    /**
     * Renders a FieldTextBox.
     * @param {int} fieldId This field's ID.
     * @param {string} labelName The label's name.
     * @param {function(event)} onChange The onChange event for this text box.
     * @param {*} value The value to use, if any.
     */
	renderTextBox(fieldId, labelName, onChange, value) {
		return (
			<FieldTextBox
				fieldid={fieldId}
				labelname={labelName}
				onChange={onChange}
				value={value}
			/>
		)
	}

    /**
     * Renders a FieldCheckBox.
     * @param {int} fieldId This field's ID.
     * @param {string} labelName The label's name.
     * @param {function(event)} onChange The onChange event for this check box.
     * @param {*} value The value to use, if any.
     */
	renderCheckBox(fieldId, labelName, onChange, value) {
		return (
			<FieldCheckBox
				fieldId={fieldId}
				displayText={labelName}
				onChange={onChange}
				checked={value}
			/>
		)
    }
    
    /**
     * Renders the data type selector.
     * @param {int} fieldId This field's ID.
     * @param {string} labelName The label's name.
     * @param {function(event)} onChange The onChange event for this select.
     * @param {*} value The value to use, if any.
     */
	renderSelect(fieldId, labelName, onChange, value) {
		return (
			<DataTypeSelector
				fieldId={fieldId}
				labelName={labelName}
				onChange={onChange}
				value={value}
			/>
		)
	}

    /**
     * The render function.
     */
	render() {
		
		var fieldId = this.props.fieldId;
		var labelName = this.props.labelName;
		var callbackFn = this.props.callbackFn;
		var value = this.props.value;

		var inputType = this.props.inputType;
		var renderedElement;

		if (inputType == "text") {
			renderedElement = this.renderTextBox(fieldId, labelName, callbackFn, value);
		} else if (inputType == "checkbox") {
			renderedElement = this.renderCheckBox(fieldId, labelName, callbackFn, value);
		} else if (inputType == "select") {
			renderedElement = this.renderSelect(fieldId, labelName, callbackFn, value);
		}

		return (
			<div className="editorField" fieldid={fieldId}>
				{renderedElement}
			</div>
		)
	}

}

/**
 * Dropdown editor component.
 */
class FieldDropdownEditor extends React.Component {

    /**
     * Basic constructor
     * @param {*} props 
     */
	constructor(props) {
		super(props);
	}

    /**
     * Render function.
     */
	render() {

        // Make a copy of the dropdowns array and sort that in alphabetical order by displayName.
		var dropdowns = window.dropdownsArray.slice().sort((x, y) => x.displayName > y.displayName ? 1 : -1);

		return (
			<div className="fieldDropdownOptionsSection">
				<label className="editorSectionLabel">Dropdown Options</label>
				<div className="editorSection dropdownOption" sectionid="dropdownOptions">
					<div className="aboveEditorTableButtonsContainer">
						<button className="newDropdownOptionButton basicActionButton" onClick={this.props.addDropdownFn}>+ New Option</button>
						<select
							id="savedDropdownsListDropdown"
							className="savedDropdownsListDropdown"
                            onChange={this.props.changeExistingDropdownFn}
                            value={this.props.value}
						>
							<option value={null}>-- Custom Dropdown --</option>
							{dropdowns.map(function(dropdown, dropdownIndex) {
								if (dropdown.disabled === 0) {
									return (
										<option
											value={dropdown.id}
											key={dropdown.id}
										>
											{dropdown.displayName}
										</option>
									)
								}
							})}
						</select>
						<input
							type="checkbox"
							name="savedDropdownsListSyncCheckbox"
							className="savedDropdownsListSyncCheckbox"
							id="savedDropdownsListSyncCheckbox"
							onChange={this.props.dropdownSyncFn}
						></input>
						<label htmlFor="savedDropdownsListSyncCheckbox" className="savedDropdownsListSyncCheckbox">Keep Synced with Dropdown</label>
					</div>
					<div className="editorSectionTableContainer dropdownOptionsTableContainer">
						<table className="editorSectionTable dropdownOptionsTable dataTable" id="dropdownOptionsTable">
							<thead>
								<tr>
									<th>Option Name</th>
									<th>Disabled</th>
									<th></th>
								</tr>
							</thead>
							<tbody>
								{this.props.dropdowns.map(
									(x, index) =>
										<FieldDropdownEditorRow
											value={x.displayName}
											disabled={x.disabled}
											dropdownsSynced={this.props.dropdownsSynced}
											key={index}
											index={index}
											setDropdownNameFn={this.props.setDropdownNameFn}
											setDisabledFn={this.props.setDisabledFn}
											deleteDropdownFn={this.props.deleteDropdownFn}
										/>
									)
								}
							</tbody>
						</table>
					</div>
				</div>
			</div>
		);
	}

}

/**
 * The Field Editor Container.
 */
class FieldEditorContainer extends React.Component {

    /**
     * The constructor.
     * @param {*} props 
     */
	constructor(props) {
        super(props);
        
        // Check if we have an existing field ID. If not, default to 0 for the database.
        var fieldId = this.props.fieldId;
        fieldId = fieldId === null ? 0 : fieldId;

        // Set up default values for a new field.
		var displayName = "";
		var hoverText = "";
		var dataTypeId = this.props.dataTypeId == null ? 1 : this.props.dataTypeId;
		var dropdowns = [];
		var dropDownId = 0;
		var keepSyncedWithDropdown = 0;
		var isUnique = 0;
		var useSalts = 0;
		var structureBoxWidth = "";
		var structureBoxHeight = "";
		var disabled = 0;

        // If we're looking at an existing field, then find the corresponding field and replace the values as necessary.
		if (fieldId !== 0) {
            var thisField = fieldsArray.find(x => x.id == fieldId);
            
			displayName = thisField.displayName;
			hoverText = thisField.hoverText;
			dataTypeId = thisField.dataTypeId;
			dropDownId = thisField.dropDownId !== null ? thisField.dropDownId : dropDownId;
			keepSyncedWithDropdown = thisField.dropdownId !== null;
			isUnique = thisField.isUnique;
			useSalts = thisField.useSalts;
			structureBoxWidth = thisField.strucutreBoxWidth;
			structureBoxHeight = thisField.structureBoxHeight;
			disabled = thisField.disabled;

            // Construct the options array based on this field's options.
			var options = thisField.options === null ? [] : thisField.options;
			$.each(options, function(index, option) {
				dropdowns.push({
                    id: option.dropdownOptionId,
                    dropDownId: thisField.dropDownId,
                    displayName: option.displayName,
                    hoverText: null,
                    disabled: option.disabled
                });
			});
		}

        // Now instantiate this component's state. This will basically be the JSON we're sending to the ConfigService,
        // sans userId and connectionId.
		this.state = {
            id: fieldId,
			displayName: displayName,
			hoverText: hoverText,
			dataTypeId: dataTypeId,
            dropDownId: dropDownId,
            dropDown: {
                id: dropDownId,
                displayName: null,
                disabled: 0,
                hoverText: null,
                maskValues: null,
                hidden: 1,
                dropDownMaskings: null,
                dropDownOptions: dropdowns
            },
			keepSyncedWithDropdown: keepSyncedWithDropdown,
			isUnique: isUnique,
			useSalts: useSalts,
			structureBoxWidth: structureBoxWidth,
			structureBoxHeight: structureBoxHeight,
            disabled: disabled,
            hasStructure: null,
            dataType: null,
            requestItemTypeFields: null,
            requestTypeFields: null,
            requestTypeFieldDepends_dest: null,
            requestTypeFieldDepends_source: null
        }
        
	}

    /**
     * Render method for the dropdown editor.
     * @param {function} addDropdownFn 
     * @param {function} setDropdownNameFn 
     * @param {function} setDisabledFn 
     * @param {function} changeExistingDropdownFn 
     * @param {function} dropdownSyncFn 
     * @param {function} deleteDropdownFn 
     */
	renderDropdownEditor(addDropdownFn, setDropdownNameFn, setDisabledFn, changeExistingDropdownFn, dropdownSyncFn, deleteDropdownFn) {
		return (
			<FieldDropdownEditor
                dropdowns={this.state.dropDown.dropDownOptions}
                value={this.state.dropDownId}
				dropdownsSynced={this.state.keepSyncedWithDropdown}
				addDropdownFn={addDropdownFn}
				setDropdownNameFn={setDropdownNameFn}
				setDisabledFn={setDisabledFn}
				changeExistingDropdownFn={changeExistingDropdownFn}
				dropdownSyncFn={dropdownSyncFn}
				deleteDropdownFn={deleteDropdownFn}
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

    /**
     * On change handler for the data type selector.
     * @param {*} evt 
     */
	changeDataType(evt) {
		this.setState({dataTypeId: evt.target.value})
	}

    /**
     * Adds a new dropdown option to the state, re-rendering the dropdown component.
     */
	addDropdownOption() {
        var dropdowns = this.state.dropDown.dropDownOptions;
		dropdowns.push({
            id: 0,
            dropDownId: this.state.dropDown.id,
            displayName: "",
            hoverText: null,
            disabled: 0
        });

        var thisDropDown = this.state.dropDown;
        thisDropDown["dropDownOptions"] = dropdowns;
		this.setState({dropDown: thisDropDown});
	}

    /**
     * On change handler for the dropdown editor text boxes.
     * @param {*} evt 
     */
	setDropdownName(evt) {
		var key = evt.target.getAttribute("index");
		var dropdowns = this.state.dropDown.dropDownOptions;
		var thisDropdownOption = dropdowns[key];
		thisDropdownOption.displayName = evt.target.value;
        dropdowns[key] = thisDropdownOption;
        
        var thisDropDown = this.state.dropDown;
        thisDropDown["dropDownOptions"] = dropdowns;

		this.setState({dropDown: thisDropDown});
	}

    /**
     * On change handler for the dropdown disabled checkbox..
     * @param {*} evt 
     */
	setDropdownDisabled(evt) {
		var key = evt.target.getAttribute("index");
		var dropdowns = this.state.dropDown.dropDownOptions;
		var thisDropdownOption = dropdowns[key];
		thisDropdownOption.disabled = utilities().boolToInt(evt.target.checked);
        dropdowns[key] = thisDropdownOption;
        
        var thisDropDown = this.state.dropDown;
        thisDropDown["dropDownOptions"] = dropdowns;

		this.setState({dropDown: thisDropDown});
	}

    /**
     * On change handler for the existing dropdowns select.
     * @param {*} evt 
     */
	changeExistingDropdown(evt) {
        var selectedVal = evt.target.value;
        
        // Set up a new array; we might end up not having any dropdowns to display.
		var newDropdowns = [];

        // Find the selected dropdown and pull out the necessary information from it, if it exists.
		var selectedDropdown = dropdownsArray.find(x => x.id == selectedVal);
		if (selectedDropdown !== undefined) {

            var thisDropdownId = this.state.dropDown.id;

			$.each(selectedDropdown.options, function(index, dropdown) {
				newDropdowns.push({
                    id: dropdown.dropdownOptionid,
                    dropDownId: thisDropdownId,
                    displayName: dropdown.displayName,
                    hoverText: null,
                    disabled: dropdown.disabled
                });
			})
        }
        
        var thisDropDown = this.state.dropDown;
        thisDropDown["dropDownOptions"] = newDropdowns;

		this.setState({dropDownId: selectedVal, dropDown: thisDropDown});
	}

    /**
     * On click handler for the keep synced checkbox.
     * @param {*} evt 
     */
	setDropdownSync(evt) {
		this.setState({keepSyncedWithDropdown: utilities().boolToInt(evt.target.checked)});
	}

    /**
     * Deletes a given dropdown option.
     * @param {*} evt 
     */
	deleteDropdown(evt) {
		var key = evt.target.getAttribute("index");
		var newDropdowns = [];

        // There's got to be a more elegant way of removing a single dropdown option than this.
		$.each(this.state.dropDown.dropDownOptions, function(index, dropdown) {
			if (index != key) {
				newDropdowns.push(dropdown);
			}
        });
        
        var newDropDown = this.state.dropDown;
        this.state.dropDown["dropDownOptions"] = newDropdowns

		this.setState({dropDown: newDropDown});
    }
    
    /**
     * Submits this field to the configService.
     */
    submitFieldEditor() {

        // Package up the data in the format we want.
        var data = {
            userId: globalUserInfo.userId,
            connectionId: connectionId,
			field: this.state,
			appName: "Configuration"
        }

        // Submit the data, passing in the state of this component so we have access to it down the chain.
        ajaxModule().submitField(data).then(function(response, currState = data.field) {

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
				notificationTitle = `Successfully updated field ${currState.displayName}.`;
			}
			else {
				notificationTitle = `Successfully created new field ${currState.displayName}.`;
			}
			window.upsertSavedFieldNotification.update({ 'title': notificationTitle, 'message': "", type: "success" })
			
			swal({
				title: "Field successfully updated",
				type: "success",
				confirmButtonText: "Ok",
				timer: 1100
			});
			setTimeout(function () {
				window.upsertSavedFieldNotification.close();
			}, 4000);

			// Commenting this out because it can't really reach hideFieldEditor from inside this callback function,
			// but also I don't think it really needs to if it's just reloading the page after?
			//this.hideFieldEditor();

			// Reload the page so the latest changes can be seen.
			location.reload();

        }).catch(function () {
            // TODO: replace this.state here with something that would actually work.

            console.log("error");
            if (this.state.id) {
                notificationTitle = 'Failed to update field "' + this.state.displayName + '".';
            }
            else {
                notificationTitle = 'Failed to create new field "' + this.state.displayName + '".';
            }
            window.upsertSavedFieldNotification.update({ 'title': notificationTitle, 'message': "", type: "danger" })
        });
    }

    /**
     * Hides the field editor.
     */
    hideFieldEditor() {        
        ReactDOM.unmountComponentAtNode(document.getElementById("reactFieldEditor"));
    }

    /**
     * Render function.
     */
	render() {

        // Render the each of the field editors, or null if certain conditions are met.
		var displayName = renderFieldEditor("displayName", "Field Name", (i) => setTextState(i, "displayName", this), "text", this.state.displayName);
		var hoverText = renderFieldEditor("hoverText", "Hover Text", (i) => setTextState(i, "hoverText", this), "text", this.state.hoverText);

        // If we already have a data type, then we're looking at an existing field and we don't actually need to
        // choose a new data type.
        var dataTypes = this.props.dataTypeId === null ? renderFieldEditor("dataTypeId", "Data Type", i => this.changeDataType(i), "select", this.props.dataTypeId) : null;

        // Render the dropdown editor if the current data type ID is the drop down data type ID.
		var dropdownEditor = (
			this.state.dataTypeId == dataTypeEnums.DROP_DOWN ?
				this.renderDropdownEditor(
					() => this.addDropdownOption(),
					(i) => this.setDropdownName(i),
					(i) => this.setDropdownDisabled(i),
					(i) => this.changeExistingDropdown(i),
					(i) => this.setDropdownSync(i),
					(i) => this.deleteDropdown(i)
				) :
				null
			);

		var isUnique = renderFieldEditor("isUnique", "Is Unique", i => setCheckboxState(i, "isUnique", this), "checkbox", this.state.isUnique);
		var disabled = renderFieldEditor("disabled", "Disabled", i => setCheckboxState(i, "disabled", this), "checkbox", this.state.disabled);

        // Structure editor field info. Instantiate the variables for now.
        var useSalts;
		var structureBoxWidth;
		var structureBoxHeight;

        // If we're making a new structure field, then set up the Field Editor components for them.
		if (this.state.dataTypeId==dataTypeEnums.STRUCTURE) {						
			useSalts = renderFieldEditor("useSalts", "Use Salts", i => this.setCheckboxState(i, "useSalts"), "checkbox", this.state.useSalts);
			structureBoxWidth = renderFieldEditor("structureBoxWidth", "Structure Box Width (in pixels)", (i) => setTextState(i, "structureBoxWidth", this), "text", this.state.structureBoxWidth);
			structureBoxHeight = renderFieldEditor("structureBoxHeight", "Structure Box Height (in pixels)", (i) => setTextState(i, "structureBoxHeight", this), "text", this.state.structureBoxHeight);
        }
        
        // Now create the submit and cancel buttons.
        var submitButton = this.renderSubmit(() => this.submitFieldEditor());
        var cancelButton = this.renderCancel(() => this.hideFieldEditor());

		return(
			<div className="dropdownEditorContainer card makeVisible isSavedField">
				{displayName}
				{hoverText}
				{dataTypes}
				{dropdownEditor}
				{isUnique}
				{useSalts}
				{structureBoxWidth}
				{structureBoxHeight}
                {disabled}
                <div className="bottomButtons">
                    {submitButton}
                    {cancelButton}
                </div>
			</div>
		)
	}
}