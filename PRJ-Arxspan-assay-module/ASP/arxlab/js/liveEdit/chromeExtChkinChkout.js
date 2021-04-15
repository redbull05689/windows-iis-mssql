//Check for chrome extension 8/24/16

function randomString(length, chars) {
    var mask = '';
    if (chars.indexOf('a') > -1) mask += 'abcdefghijklmnopqrstuvwxyz';
    if (chars.indexOf('A') > -1) mask += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (chars.indexOf('#') > -1) mask += '0123456789';
    if (chars.indexOf('!') > -1) mask += '~`!@#$%^&*()_+-={}[]:";\'<>?,./|\\';
    var result = '';

    for (var i = length; i > 0; --i) result += mask[Math.floor(Math.random() * mask.length)];
    return result;
}

function isTopWindow()
{
	return window == window.top;
}

var liveEditController = function(self) {
	self.token_ = '';
	self.hostInterval = null;
	self.callbackInterval = null;
	self.extensionInterval = null;
	
	self.browserAllowed = false;
	self.extensionInstalled = false;
	self.hostAppInstalled = false;
	self.extensionVersion = "";

	self.isCheckedOutCallback = {};
	self.receivingDataCallback = {};
	self.checkInUploadCallback = {};
	self.installCheckCallbacks = [];
	
	self.browserInfo = getBrowserInfo();
	console.log("browserInfo ::", self.browserInfo[0]);
	if (self.browserInfo[0] == "Chrome") {
		self.browserAllowed = true;
	}

	self.setCheckInUploadCallback = function(func, args) {
		console.log("native messaging handler registering check in callback");
		self.checkInUploadCallback = {'runThis':func,'passThis':args};
		console.log("checkInUploadCallback: ", self.checkInUploadCallback);
	};
	
	self.setReceivingDataCallback = function(func, args) {
		console.log("native messaging handler registering receiving data callback");
		self.receivingDataCallback = {'runThis':func,'passThis':args};
		console.log("receivingDataCallback: ", self.receivingDataCallback);
	};
	
	self.setIsCheckedOutCallback = function(func, args) {
		console.log("native messaging handler registering checked out callback");
		self.isCheckedOutCallback = {'runThis':func,'passThis':args};
		console.log("isCheckedOutCallback: ", self.isCheckedOutCallback);
	};
	
	self.addInstalledCallback = function(func, args) {
		if(!isTopWindow())
		{
			console.log("CANNOT ADD CALLBACK TO IFRAMES or windows that are not the top window");
			return;
		}
		if(!self.browserAllowed)
		{
			console.log("Browser not Allowed");
			return;
		}
		
		console.log("native messaging handler registering install check callback");
		var objToAdd = {'runThis':func,'passThis':args};
		self.installCheckCallbacks.push(objToAdd);
		self.queueCallbacks();
	};
	
	self.queueCallbacks = function() {
		console.log("queuing callbacks");
		if(self.callbackInterval == null) {
			console.log("adding the callback to the array");
			self.callbackInterval = window.setInterval(this._runCallbacks, 250);
		}
	};
	
	self._runCallbacks = function() {
		console.log("checking install callbacks: ", self.hostAppInstalled, " and ", self.extensionInstalled);
		if(self.hostAppInstalled && self.extensionInstalled)
		{
			var cbFailed = [];
			console.log("running " + self.installCheckCallbacks.length + " install callbacks");
			
			$.each(self.installCheckCallbacks, function(i, callbackInfo) {
				console.log("running install callback: ", i);
				try
				{
					var cbRet = callbackInfo['runThis'](callbackInfo['passThis']);
					if(cbRet != true)
						cbFailed.push(callbackInfo);
				}
				catch(err)
				{
					console.log("function call failed: ", err);
				}
			});
			
			self.installCheckCallbacks = cbFailed;
			if(cbFailed.length == 0)
			{
				console.log('canceling install callback interval');
				window.clearInterval(self.callbackInterval);
				self.callbackInterval = null;
			}
		}
	};

	self.handleExtensionState = function (msg) {
		if(msg.extensionState == 'installed') {
			self.extensionInstalled = true;
			self.extensionVersion = msg.version;
			console.log("Arxspan Live-Edit-Extension with "+msg.version+" version is installed.." );
			if (self.extensionVersion < 1.07) {
				alert("Please update your live edit extension");
				//TODO: add a better error message
			}
		}
		window.clearInterval(self.extensionInterval);
	};

	self.handleHostAppState = function (msg) {
		window.liveEditInstalled = false;
		console.log("handleHostAppState: ", msg.hostAppState);
		if(msg.hostAppState == 'installed') {
			self.hostAppInstalled = true;
			self.extensionInstalled = true;	
			console.log("Extension & Host State :: " + self.extensionInstalled +", "+ self.hostAppInstalled);
			if(self.extensionInstalled && self.hostAppInstalled) {
				window.liveEditInstalled = true;
			}
		}else if(msg.hostAppState == 'fileOpened') {
			if(self.isCheckedOutCallback.hasOwnProperty('runThis')) {
				var theArgs = {};
				if(self.isCheckedOutCallback.hasOwnProperty('passThis')) {
					theArgs = self.isCheckedOutCallback['passThis'];
				}

				self.isCheckedOutCallback['runThis'](msg, theArgs);
			}
		}
		window.clearInterval(self.hostInterval);
	};

	var uploadFileData="";
	self.handleCheckInUpload = function(msg) {
		console.log("native messaging MSG: ", msg);
		// Receive the chunks
		if(msg['chunk'] == -1) {
			//console.log("Received chunk# ",msg['chunk']);
			uploadFileData += msg['filedata']
			if(self.checkInUploadCallback.hasOwnProperty('runThis')) {
				var theArgs = {};
				if(self.checkInUploadCallback.hasOwnProperty('passThis')) {
					theArgs = self.checkInUploadCallback['passThis'];
				}

				self.checkInUploadCallback['runThis'](msg, uploadFileData, theArgs);
			}
			uploadFileData="";
		} else {
			console.log("Received chunk# ",msg['chunk']);
			uploadFileData += msg['filedata'];

			if(self.receivingDataCallback.hasOwnProperty('runThis')) {
				var theArgs = {};
				if(self.receivingDataCallback.hasOwnProperty('passThis')) {
					theArgs = self.receivingDataCallback['passThis'];
				}

				self.receivingDataCallback['runThis'](msg, theArgs);
			}
			
			window.postMessage({ message_type: 'checkin', url: msg['url'], filename: msg['filename'], filelabel: msg['filelabel'], attachmentId: msg['attachmentId'], description: Encoder.htmlEncode(msg['description']), experimentType: msg['experimentType'], sort: msg['sortOrder'], folderId: msg['folderId'], ext: msg['ext'], chunk: parseInt(msg['chunk']) + 1}, '*');
		}
	};

	self.handleNativeMessage = function(event) {
		if(event.data.hasOwnProperty('direction') && event.data.direction == "from-content-script"){
			var msg = {};
			msg=event.data.message;
			console.log("handleNativeMessage4 :: ", msg);
			if (msg.message_type == 'extension_state') {
				self.handleExtensionState(msg);
			} else if (msg.message_type == 'hostapp_hello') {
				console.log("HostApp hello received");
				self.handleHostAppState(msg);
			} else if (msg.message_type == 'hostapp_Success') {
				console.log("HostApp file opened");
				self.handleHostAppState(msg);
			} else if (msg.message_type == 'checkin_upload') {
				console.log("Check In Upload message received");
				self.handleCheckInUpload(msg);
			} else if (msg.message_type == 'hostapp_print') {
				console.log("Message from host :: " + msg.hostAppState);
			} else if (msg.message_type == 'disconnect') {
				console.log("Native message disconnect :: ", msg.message);
			} else if (msg.message_type == 'error') {
				errorMessage = "Unknown Error";
				if(msg.message !== undefined){
					errorMessage = msg.message;
				}
				if(msg.error_description !== undefined){
					errorMessage = msg.error_description;
				}
				console.log("Native message connection error occured :: ", errorMessage);

				if (errorMessage.includes("because it is being used by another process")){
					swal("Live Edit Error", "The File is Locked.\r\n\r\nIf the file is open in another application, please close it.", "error");
				}else if (errorMessage.includes("Attempting to use a disconnected port object")){
					swal("Live Edit Error", "Are you using the latest version of the Live Edit Host? Please update by visiting the \"Live Edit Installation\" link under Tools in the left navigation bar and then refresh this page and try to check out your file again.\r\n\r\nIf the error persists, please contact support with the following error message:\r\n\r\n"+errorMessage, "error");
				}else{
					swal("Live Edit Error", "Please try your request again. If the error persists, please contact support with the following error message:\r\n\r\n" + errorMessage, "error");
				}
				
			}
		}
	};

	self.init = function(token) {
		self.token_ = token;

		if (self.browserAllowed && isTopWindow())
		{
			var OSmac = isMacintosh();
			var OSwin = isWindows();
			if (OSmac)	{
				$(".opSysWin").hide();
			}else if (OSwin)	{
				$(".opSysMac").hide();
			}

			window.addEventListener('message', self.handleNativeMessage, false);
			self.extensionInterval = window.setInterval(self.checkforExtension, 250);
			self.hostInterval = window.setInterval(self.checkForHostApp, 250);
		}
	};

	self.checkforExtension =  function() {
		console.log("Checking for Extension token ::", self.token_);
		window.postMessage({ message_type: "hello-ext", token: self.token_}, window.location.href);
	};

	self.checkForHostApp =  function() {
		console.log("Checking for Host ::", self.token_);
		window.postMessage({ message_type: "hello", token: self.token_}, window.location.href);
	};

	return self;
};

var showLiveEdit = false;
var liveEditor = new liveEditController(liveEditController || {});
liveEditor.init(randomString(32, '#aA'));

function defaultIsCheckedOutCallback(msg, theArgs) {
	console.log("Hide Checkout btn and show checkin btn..");
	doCheckOut_chrome(msg['attachmentId'], msg['experimentType']);
}

function defaultReceivingDataCallback(msg, theArgs) {
	if ($('#Loading_'+msg['attachmentId'])[0].style.display == "none"){
		$('#Loading_'+msg['attachmentId'])[0].style.display="inline";
	}
}

function defaultInstallCheckCallback(browserAllowed, extensionInstalled, hostAppInstalled) {
//		This code needs to be added into an installCheckCallback when the button is put on the page	
	console.log("btnDisplayCheck...");
	btnDisplayCheck(browserAllowed, extensionInstalled, hostAppInstalled);
}

function defaultCheckInUploadCallback(uploadFileData, theArgs)
{
	buf = _base64ToArrayBuffer(uploadFileData);
	var http = new XMLHttpRequest();
	
	formData = new FormData();
	var blob = new Blob([buf], {type : "text/plain"});
	//check if its a chemistry cdx file or experiment attachment
	if ((msg['attachmentId']).split("_").length > 1){
		formData.append(msg['attachmentId'], blob);
		unsavedChanges=false;
		//rxnSubmit();
		waitForRXN(); //maybe?
	}
	else {
		formData.append('file1_'+msg['attachmentId'], blob, msg['filename']);
		
		formData.append('fileLabel', msg['filelabel']);
		formData.append('description', Encoder.htmlEncode(msg['description']));
		formData.append('sortOrder', msg['sortOrder']);
		//url = "/arxlab/experiments/upload-file.asp?PID=12ED929112DF442E&experimentId=27323&experimentType=2&attachmentId=139762&path=F1/F2/F3/&random=0.3735362"
		//Need to get this from native messaging host variable but as a work around getting it from the URL
		formData.append('path', ((msg['url'].split("&"))[4].split("="))[1]);
	}
	
	http.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {
			var response = this.responseText;
			//post the message to delete the file
			if ((msg['attachmentId']).split("_").length > 1){
				window.postMessage({ message_type: 'delete', file: msg.experimentType + '-' + msg.attachmentId}, '*');
			}else{
				window.postMessage({ message_type: 'delete', file: msg.experimentType + '-' + msg.attachmentId + msg.ext}, '*');
			}
			
			//Update the status of the file and toggle the buttons
			doCheckIn_chrome(msg['attachmentId'], msg['experimentType']);
		}
	}
	http.open("POST", msg['url'], false);
	//http.onprogress = updateProgress;
	http.send(formData);
	if ($('#Loading_'+msg['attachmentId']).length != 0 && $('#Loading_'+msg['attachmentId'])[0].style.display == "inline"){
		$('#Loading_'+msg['attachmentId'])[0].style.display="none";  
	}
}

function _base64ToArrayBuffer(base64) {
    var binary_string =  window.atob(base64);
    var len = binary_string.length;
    var bytes = new Uint8Array( len );
    for (var i = 0; i < len; i++)        {
        bytes[i] = binary_string.charCodeAt(i);
    }
    return bytes.buffer;
}

