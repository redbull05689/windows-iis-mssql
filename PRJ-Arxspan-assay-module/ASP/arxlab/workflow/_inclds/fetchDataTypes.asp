<script>
    var dtPromise = [];
    var dataTypeModule = function(dataTypeJson) {

        var findDataTypeId = function(displayName) {
            dataTypeObject = dataTypeJson.find(x => x.displayName == displayName);
            return dataTypeObject !== undefined ? dataTypeObject["id"] : -1;
        }

        var TEXT = findDataTypeId("Text");
        var LONG_TEXT = findDataTypeId("Long Text");
        var INTEGER = findDataTypeId("Integer");
        var REAL_NUMBER = findDataTypeId("Real Number");
        var DROP_DOWN = findDataTypeId("Drop Down");
        var FILE_ATTACHMENT = findDataTypeId("File Attachment");
        var DATE = findDataTypeId("Date");
        var STRUCTURE = findDataTypeId("Structure");
        var RICH_TEXT = findDataTypeId("Rich Text");
        var USER_LIST = findDataTypeId("User List");
        var CO_AUTHORS = findDataTypeId("Co-Authors");
        var NOTEBOOK = findDataTypeId("Notebook");
        var PROJECT = findDataTypeId("Project");
        var EXPERIMENT = findDataTypeId("Experiment");
        var REGISTRATION = findDataTypeId("Registration");
        var REQUEST = findDataTypeId("Request");
        var FOREIGN_LINK = findDataTypeId("Foreign Link");
        var UNIQUE_ID = findDataTypeId("Unique ID");
        var BIOSPIN_EDITOR = findDataTypeId("BioSpin Editor");

        return {
            TEXT: TEXT,
            LONG_TEXT: LONG_TEXT,
            INTEGER: INTEGER,
            REAL_NUMBER: REAL_NUMBER,
            DROP_DOWN: DROP_DOWN,
            FILE_ATTACHMENT: FILE_ATTACHMENT,
            DATE: DATE,
            STRUCTURE: STRUCTURE,
            RICH_TEXT: RICH_TEXT,
            USER_LIST: USER_LIST,
            CO_AUTHORS: CO_AUTHORS,
            NOTEBOOK: NOTEBOOK,
            PROJECT: PROJECT,
            EXPERIMENT: EXPERIMENT,
            REGISTRATION: REGISTRATION,
            REQUEST: REQUEST,
            FOREIGN_LINK: FOREIGN_LINK,
            UNIQUE_ID: UNIQUE_ID,
            BIOSPIN_EDITOR: BIOSPIN_EDITOR
        }
    }


    dtPromise.push( new Promise(function(resolve, reject) {
        var serviceUrl = `/datatypes`;
        serviceUrl += `?userId=<%=session("userId")%>`;
        //serviceUrl += `&connectionId=<%=session("connectionId")%>`;
        serviceUrl += `&appName=Workflow`;

        var serviceObj = {
            configService: true
        }
        
        utilities().makeAjaxGet(serviceUrl, serviceObj).then(function(response) {
            response = utilities().decodeServiceResponce(response);
            window.dataTypesArray = response;
            window.dataTypeEnums = new dataTypeModule( response );
            window.textFields = [dataTypeEnums.TEXT, dataTypeEnums.LONG_TEXT, dataTypeEnums.RICH_TEXT];
            resolve(true);
        });
    }));

    var applicationEnum = {
        REQUEST: 1,
        REGISTRATION: 2,
        PROJECT: 3,
        NOTEBOOK: 4,
        EXPERIMENT: 5,
        INVENTORY: 6,
        ASSAY: 7,
        REQUEST_FIELD: 8,
        REQUEST_ITEM_FIELD: 9,
    }

</script>