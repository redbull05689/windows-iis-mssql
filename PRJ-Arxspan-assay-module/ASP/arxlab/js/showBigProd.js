var computeFrameOffset = function(win, dims) {
    // initialize our result variable
    if (typeof dims === 'undefined') {
        var dims = { top: 0, left: 0 };
    }

    // find our <iframe> tag within our parent window
    var frames = win.parent.document.getElementsByTagName('iframe');
    var frame;
    var found = false;

    for (var i=0, len=frames.length; i<len; i++) {
        frame = frames[i];
        if (frame.contentWindow == win) {
            found = true;
            break;
        }
    }

    // add the offset & recur up the frame chain
    if (found) {
        var rect = frame.getBoundingClientRect();
        dims.left += rect.left;
        dims.top += rect.top;
        if (win !== top) {
            computeFrameOffset(win.parent, dims);
        }
    }
    return dims;
};

function showBigProd(imgEl,exId)
{
	docEl = document;
	topOffset = 0;
	leftOffset = 0;
	theEl = document.getElementById("prodZoomImage");
	if(!theEl){
		theEl = window.parent.document.getElementById("prodZoomImage");
		topOffset += computeFrameOffset(window).top;
		leftOffset += computeFrameOffset(window).left;
		docEl = window.parent.document;
	}
	if(!theEl){
		theEl = window.parent.window.parent.document.getElementById("prodZoomImage");
		topOffset += computeFrameOffset(window.parent.window.parent).top;
		leftOffset += computeFrameOffset(window.parent.window.parent).left;
		docEl = window.parent.window.parent.document;
	}
	theEl.src = "/arxlab/images/blank.gif";
	prodZoomIeSucks = document.getElementById("prodZoom");
	if(!prodZoomIeSucks){
		prodZoomIeSucks = window.parent.document.getElementById("prodZoom");
	}
	if(!prodZoomIeSucks){
		prodZoomIeSucks = window.parent.window.parent.document.getElementById("prodZoom");
	}
	imgParent = imgEl.parentNode
	//imgParent.style.position = 'relative';
	//imgParent.appendChild(prodZoomIeSucks.parentNode.removeChild(prodZoomIeSucks))
	theEl.src = "/arxlab/experiments/ajax/load/getProdsBig.asp?experimentId="+exId+"&random="+Math.random();
	prodZoomIeSucks.style.zIndex = '1000000000';
	prodZoomIeSucks.style.display = 'block';
	var scrollTop = docEl.body.scrollTop || docEl.documentElement.scrollTop;
	var scrollLeft = docEl.body.scrollLeft || docEl.documentElement.scrollLeft;
	prodZoomIeSucks.style.top = topOffset + imgParent.getBoundingClientRect().top-20 + scrollTop +'px';
	prodZoomIeSucks.style.left = leftOffset + imgParent.getBoundingClientRect().left-200 + scrollLeft +'px';
}

function showBigRXN(imgEl,exId)
{
	console.log("exId ::"+ exId);
	console.log("imgEl ::", imgEl);
	docEl = document;
	topOffset = 0;
	leftOffset = 0;
	theEl = document.getElementById("prodZoomImage");
	if(!theEl){
		theEl = window.parent.document.getElementById("prodZoomImage");
		topOffset += computeFrameOffset(window).top;
		leftOffset += computeFrameOffset(window).left;
		docEl = window.parent.document;
	}
	if(!theEl){
		theEl = window.parent.window.parent.document.getElementById("prodZoomImage");
		topOffset += computeFrameOffset(window.parent.window.parent).top;
		leftOffset += computeFrameOffset(window.parent.window.parent).left;
		docEl = window.parent.window.parent.document;
	}
	theEl.src = "/arxlab/images/blank.gif"
	RXNZoomIeSucks = document.getElementById("prodZoom");
	if(!RXNZoomIeSucks){
		RXNZoomIeSucks = window.parent.document.getElementById("prodZoom");
	}
	if(!RXNZoomIeSucks){
		RXNZoomIeSucks = window.parent.window.parent.document.getElementById("prodZoom");
	}
	imgParent = imgEl.parentNode
	//imgParent.style.position = 'relative';
	//imgParent.appendChild(RXNZoomIeSucks.parentNode.removeChild(RXNZoomIeSucks))
	theEl.src = "/arxlab/experiments/ajax/load/getRXN.asp?experimentId="+exId+"&random="+Math.random();
	RXNZoomIeSucks.style.zIndex = '1000000000';
	RXNZoomIeSucks.style.display = 'block';
	var scrollTop = docEl.body.scrollTop || docEl.documentElement.scrollTop;
	var scrollLeft = docEl.body.scrollLeft || docEl.documentElement.scrollLeft;
	RXNZoomIeSucks.style.top = topOffset + imgParent.getBoundingClientRect().top-20 + scrollTop +'px';
	RXNZoomIeSucks.style.left = leftOffset + imgParent.getBoundingClientRect().left-200 + scrollLeft +'px';
}