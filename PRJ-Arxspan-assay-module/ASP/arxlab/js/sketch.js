IS_IPAD = navigator.userAgent.match(/iPad/i) != null;
IS_IPHONE = (navigator.userAgent.match(/iPhone/i) != null) || (navigator.userAgent.match(/iPod/i) != null);
if (IS_IPAD) {
  IS_IPHONE = false;
}
function newSketch(attachmentId,pre){
	experimentType = document.getElementById("experimentType");
	experimentId = document.getElementById("experimentId");
	dims = [.9,.8];
	el = document.getElementById("theSketch");
	if(el){
		el.parentNode.removeChild(el);
	}
	document.getElementById("sketchAttachmentId").value = "";
	document.getElementById("sketchPre").value = "";
	canvasNaturalWidth = getPopupSize("sketchDiv",dims).width-10;
	canvasNaturalHeight = getPopupSize("sketchDiv",dims).height-80;
	canvasWidth = canvasNaturalWidth;
	canvasHeight = canvasNaturalHeight;
	document.getElementById("replaceSketchHolder").style.display="none";
	if(attachmentId){
		document.getElementById("replaceSketchHolder").style.display="block";
		document.getElementById("replaceSketch").checked = true;
		document.getElementById("sketchAttachmentId").value = attachmentId;
		var img = new Image();
		img.onload = function () {
			imgWidth = $(this)[0].naturalWidth;
			imgHeight = $(this)[0].naturalHeight;
			imgResized = false;
			if(!(imgWidth<=canvasNaturalWidth&&imgHeight<=canvasNaturalHeight)){
				imgResized = true;
				originalImgWidth = imgWidth;
				originalImgHeight = imgHeight;
				theZoom = 1;
				while(!(imgWidth<=canvasNaturalWidth&&imgHeight<=canvasNaturalHeight)){
					theZoom -= .01;
					imgWidth = parseInt(originalImgWidth*theZoom);
					imgHeight = parseInt(originalImgHeight*theZoom);
				}
				alert("The image has been resized because it was too big to fit on your screen.  If you replace your attachment with the annotated version you will lose some resolution.  If you would like to replace the image anyways check the box that says 'Replace Attachment.'");
				document.getElementById("replaceSketch").checked = false;
			}
			canvas.setAttribute("width",imgWidth);
			canvas.setAttribute("height",imgHeight);
			$("#sketchHolder")[0].style.width=imgWidth+"px";
			$("#sketchHolder")[0].style.height=imgHeight+"px";
			$("#sketchHolder")[0].style.marginLeft=((canvasNaturalWidth-imgWidth)/2)+"px";
			$("#sketchHolder")[0].style.marginTop=((canvasNaturalHeight-imgHeight)/2)+"px";
			context.drawImage(this, 0, 0, imgWidth, imgHeight);
		}
		extra = "";
		if(pre){
			extra = "&pre="+pre;
			document.getElementById("sketchPre").value = "true";
		}
		img.src = getFile('/arxlab/experiments/ajax/load/getImageBase64.asp?id='+attachmentId+"&experimentType="+experimentType.value+"&rand="+Math.random()+extra);
	}

	canvas = document.createElement("canvas");
	canvas.setAttribute("width",canvasWidth);
	canvas.setAttribute("height",canvasHeight);
	canvas.setAttribute("id","theSketch");
	canvas.setAttribute("style","-ms-touch-action:none;");
	var context = canvas.getContext('2d');


	var Mouse = false;

    // create a drawer which tracks touch movements
    var drawer = {
        isDrawing: false,
        touchstart: function (coors) {
			context.beginPath();

			
			if (Mouse == false)
			{

				var p = $("#theSketch");
				var pos = p.offset();
				coors.x = coors.x - pos.left;
				coors.y = coors.y - pos.top;

			}

			context.moveTo(coors.x, coors.y);
			//this stops the background from scrolling so that you can use toutch to draw
			//note "stop-scrolling" is already used and makes the scroll bar dissapear moving the canvice and drawing small lines. 
			//this makes sure the canvice does not move although the background is scrolled all the way to the top.
			$("body").addClass("stop-scrollingMain")
            this.isDrawing = true;
        },
        touchmove: function (coors) {
            if (this.isDrawing) {
				context.strokeStyle = sketchColor;
				if (Mouse == false)
				{
					var p = $("#theSketch");
					var pos = p.offset();
					coors.x = coors.x - pos.left;
					coors.y = coors.y - pos.top;
				}
                context.lineTo(coors.x, coors.y);
                context.stroke();
            }
        },
        touchend: function (coors) {
            if (this.isDrawing) {

				if (Mouse == false)
				{
					var p = $("#theSketch");
					var pos = p.offset();
					coors.x = coors.x - pos.left;
					coors.y = coors.y - pos.top;
				}
				Mouse = false;
				//this.touchmove(coors);
				//re enable scrolling
				$("body").removeClass("stop-scrollingMain")
				this.isDrawing = false;
				Mouse = false;
            }
        }
    };
    // create a function to pass touch events and coordinates to drawer
    function draw(event) { 
		
			
		
        var type = null;
        // map mouse events to touch events
        switch(event.type){
            case "mousedown":
                    event.touches = [];
                    event.touches[0] = { 
                        pageX: event.pageX-$("#sketchHolder").offset().left,
                        pageY: event.pageY-$("#sketchHolder").offset().top
					};
					Mouse = true;
                    type = "touchstart";                  
            break;
            case "mousemove":                
                    event.touches = [];
                    event.touches[0] = { 
                        pageX: event.pageX-$("#sketchHolder").offset().left,
                        pageY: event.pageY-$("#sketchHolder").offset().top
					};
					
                    type = "touchmove";                
            break;
			case "mouseup":         
					Mouse = false;
                    event.touches = [];
                    event.touches[0] = { 
                        pageX: event.pageX-$("#sketchHolder").offset().left,
                        pageY: event.pageY-$("#sketchHolder").offset().top
					};
					
					type = "touchend";
					
            break;
        }    
		
		
		

        // touchend clear the touches[0], so we need to use changedTouches[0]
        var coors;
        if(event.type === "touchend") {
			if (IS_IPAD){
				coors = {
					x: event.changedTouches[0].pageX-$("#sketchHolder").offset().left,
					y: event.changedTouches[0].pageY-$("#sketchHolder").offset().top
				};
			}else{
				coors = {
					x: event.changedTouches[0].pageX,
					y: event.changedTouches[0].pageY
				};
			}
		}
        else {
            // get the touch coordinates
			if (IS_IPAD){
				coors = {
					x: event.touches[0].pageX-$("#sketchHolder").offset().left,
					y: event.touches[0].pageY-$("#sketchHolder").offset().top
				};
			}else{
				coors = {
					x: event.touches[0].pageX,
					y: event.touches[0].pageY
				};
			}
		}
        type = type || event.type
        // pass the coordinates to the appropriate handler
        drawer[type](coors);
    }
    
	//Get the session variable if the user already set
	var isTouchAvailable = getFile('ajax_doers/user_settings/switchTouchAvailable.asp?get=1&rand='+ Math.random());
	
    // detect touch capabilities
    var touchAvailable = ('createTouch' in document) || ('ontouchstart' in window);
			
    // attach the touchstart, touchmove, touchend event listeners.
    if(touchAvailable){
		/*
		canvas.addEventListener('touchstart', draw, false);
        canvas.addEventListener('touchmove', draw, false);
		canvas.addEventListener('touchend', draw, false); 
		*/
		//ELN-1193 The sketch/annotate function does not work because of windows 10 
		if (isTouchAvailable == ""){
			swal({
				title: "",
				text: "Is your monitor touch enabled?",
				type: 'warning',
				showCancelButton: true,
				confirmButtonText: "Yes",
				cancelButtonText: "No",
			},
            function (isConfirm) {
				if (isConfirm) {
					varIsTouchAvailable = getFile('ajax_doers/user_settings/switchTouchAvailable.asp?set=1&rand='+ Math.random());
					
					isTouchAvailable = true;
					canvasAddEventListener(true, draw)
				} 
				else{
                    // dismiss can be 'overlay', 'cancel', 'close', 'esc', 'timer'
                    varIsTouchAvailable = getFile('ajax_doers/user_settings/switchTouchAvailable.asp?set=0&rand='+ Math.random());
                    canvasAddEventListener(false, draw)
                }
			})
		}
		else{
			canvasAddEventListener(isTouchAvailable, draw);
		}
	}    
    // attach the mousedown, mousemove, mouseup event listeners.
    else {
		isTouchAvailable = false;
		varIsTouchAvailable = getFile('ajax_doers/user_settings/switchTouchAvailable.asp?set=0&rand='+ Math.random());
		canvasAddEventListener(isTouchAvailable, draw)
    }

    // prevent elastic scrolling --- this is treated as passive and does not work because of it
    document.body.addEventListener('touchmove', function (event) {
		if($("#sketchDiv")[0].style.display != "none"){
			
			event.preventDefault();
		}else{
			return true;
		}
	},   {passive: false}); // end body.onTouchMove
	
	//secondary attempt to stop scrolling in event handalers for toutch


	document.getElementById("sketchHolder").appendChild(canvas);
	showPopupPercentage("sketchDiv",dims);
}



function canvasAddEventListener(isTouchAvailable, draw){
	if(isTouchAvailable == "True"){

		canvas.addEventListener('touchstart', draw, false);
		canvas.addEventListener('touchmove', draw, false);
		canvas.addEventListener('touchend', draw, false);

	}
	//disabled this so that way there is always an option to use a mouse
	//else{
		canvas.addEventListener('mousedown', draw, false);
        canvas.addEventListener('mousemove', draw, false);
        canvas.addEventListener('mouseup', draw, false);
	//}
}

function saveSketch(){
	experimentType = document.getElementById("experimentType");
	experimentId = document.getElementById("experimentId");
	if(document.getElementById("sketchAttachmentId").value){
		if(document.getElementById("replaceSketch").checked==false){
			document.getElementById("sketchAttachmentId").value = "";
			document.getElementById("sketchPre").value = "";
		}
	}
	document.getElementById("base64AttachmentFormSketch").action = "/arxlab/experiments/upload-file.asp?experimentId="+experimentId.value+"&experimentType="+experimentType.value+"&base64=true&random="+Math.random()+"&attachmentId="+document.getElementById("sketchAttachmentId").value+"&pre="+document.getElementById("sketchPre").value;
	document.getElementById("base64FileSketch").value = document.getElementById("theSketch").toDataURL().replace("data:image/png;base64,","");
	document.getElementById("fileNameBase64Sketch").value = "new sketch";
	document.getElementById("base64FileExtensionSketch").value = "png";
	if(document.getElementById("sketchAttachmentId").value){
		fn = "file_";
		if(document.getElementById("sketchPre").value){
			fn+="p_";
		}
		fn+=document.getElementById("sketchAttachmentId").value+"_name";
		document.getElementById("fileNameBase64Sketch").value = document.getElementById(fn).value;
	}
	document.getElementById("base64FileCKEditorIdSketch").value = "";
	document.getElementById("base64AttachmentFormSketch").submit();
	unsavedChanges = true;
	waitForUpload(0);
	hidePopup("sketchDiv");
}