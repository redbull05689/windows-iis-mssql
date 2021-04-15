function ArxDraw(parentDiv,data,fd){
	//required for every widget
	//constructor function
	//every widget will be called with its parentDiv which is the parent div id
	//the data from the field in inventory that the widget occupies
	//and the javascript form object from which the widget is called
	//the constructor should use the this variable to set global variables for the widget
	//every other class method should begin with "self=this;" to avoid 'this' scope issues
	//every variable that is not a local variable to a class method should use this/self
	this.parentDiv = parentDiv;
	this.data = data;
	//this.userInfo = fd.userInfo;
	this.formId = fd.fid;
	console.log("ArxDraw:"+ parentDiv + ", "+ data +", "+ fd.fid);
	if(this.data!=""){
		//if data exists set self.data to widget form value
		this.data = JSON.parse(data);
	}else{
		//initialize data if data is not present
		this.data = {};
		this.data.numBoxes = 0;
		this.data.text = "";
	}
}

ArxDraw.prototype.drawSquares = function(){
	//draw a number of the number of squares specified in self.data.numBoxes in the boxHolder div
	var self = this;
	$('#'+self.parentDiv+" .boxHolder").empty();
	for(var i=0;i<self.data.numBoxes;i++){
		$('#'+self.parentDiv+" .boxHolder").append("<div class='box'>&nbsp;</div>");
	}	
}

ArxDraw.prototype.makeHTML = function(){
	//required for every widget
	//must return an HTML element that contains all the initial widget HTML
	var self = this;
	console.log("Make HTML:"+ self);
	return $('<div class="arxDrawContainer">' +
                '<h1>This is a widget</h1>' + 
                '<label>Add some text</label>' +
                '<textarea id="'+self.parentDiv+'_ta"></textarea>' +
				'<input type="file" id="arxD_fileOpen" name="arxD_fileOpen"' +
                '<label>Number of squares</label>' +
                '<select class="numBoxes">' +
                '   <option value="1">1</option>' +
                '   <option value="2">2</option>' +
                '   <option value="3">3</option>' +
                '   <option value="4">4</option>' +
                '</select>' +
                '<label>Boxes</label>' +
                '<div class="boxHolder"></div>' +
                '<input type="button" value="Save" class="saveButton"></div>')[0];
};

ArxDraw.prototype.drawHTML = function(){
	//required for every widget
	//must attach all initial widget HTML to self.parentDiv
	//also should run any functions that need to be run after the HTML is drawn
	//and attach any event listeners that need to be attached to elements in the HTML
	var self = this;
	console.log("Draw HTML:"+ self);
	$('#' + self.parentDiv).append(self.makeHTML());
	self.postDraw();
	self.attachEventListeners();
};

ArxDraw.prototype.attachEventListeners = function(){
	//attaches event listeners.  called after HTML is loaded
	var self = this;
    $('#'+self.parentDiv+' .saveButton').on('click',function(){
		//this is how you call a backend javascript function
		//function should be the name of the function that you with to call
		//anything that will require you to access or save form data should include formId
		//all other key value pairs are for your own use and can be accessed with "params = JSON.parse(jsGet("params"));" on the backend
		pl = {
			"function": "saveArxDrawData",
			"formId": self.formId,
			"data": self.data
		}
		//restCallA() is an asynchronous call with a call back.  restCall() may be used for synchronous calls. just omit the callback
		restCallA("/userFunctions","POST",pl,function(response){
			if (response["success"]){
				alert("data saved");
			}	
		});
    });
	//make the numBoxes select update the data appropriately
    $('#'+self.parentDiv+' .numBoxes').on('change',function(){
		self.data.numBoxes = $(this).val();
		self.drawSquares();
    });
	//make the textarea update the data appropriately
    $('#'+self.parentDiv+'_ta').on('change keyup paste',function(){
		self.data.text = $(this).val();
    });
}

ArxDraw.prototype.postDraw = function(){
	//handles functions to be run after HTML is loaded
	//is called after HTML is loaded
	var self = this;
	//set the values in the object to match the data
	$('#'+self.parentDiv+' .numBoxes').val(self.data.numBoxes);
	$('#'+self.parentDiv+'_ta').val(self.data.text);

	self.drawSquares();
};