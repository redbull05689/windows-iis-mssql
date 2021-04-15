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

    this.allTranslations = [],  this.allORFs = [], this.REmappingArray = [],  this.fileName;

    this.n = 0, this.helmCounter = 0; this.draggerTop = 0; this.autoScroll = false; this.linearDraggerTop = 'bottom';

    this.objAmenoAcid = JSON.parse(aminoAcidDescription);
    this.objRestEnz = JSON.parse(restrictedEnzymes);

    this.startId2 = 0;
    this.endId2 = 20;

    this.fText = [];
    this.ribbonCompArray = [];
    this.wordsInALine = 100;
           
    this.mappingRadius = 180; //Circular map radius 300
    this.mapWidth = 1350; //Linear map line width

    this.offsetArray = [];

    this.canvas2ItemArray = [];
    this.canvas3ItemArray = [];
    this.canvas4ItemArray = [];

    this.highLightStylesArray = [];
    this.canvas2MouseClick = false;
    this.canvas2ClickId;

    this.drawCutArray = [];
    
    this.amenoAcidIds = {};
    /** Wrap text for ribbon view, "id" is to check if its modified in complimentary part of the display **/
    this.a = this.b = 50;
    this.by = this.ax = 80;
    this.fs = 16;
    this.breakLineWidth = 70;
    this.bLW = [0]; // keep track of the spacing between the rows
    this.itemsBtwRow = []; // how many items present between each row
    
    this.spinner = null;
    this.gotoBasePairScroll = false;
    this._spinnerDiv;

    //console.log("ArxDraw loading Values length:"+ this.data.length );
    //console.log("ArxDraw loading Values:"+ this.data );
    if(this.data!=""){
        //if data exists set self.data to widget form value
        
        this.data = JSON.parse(data);
    }else{
        //initialize data if data is not present
        this.data = {};
        this.data.result = [],  this.data.fStrJSON = [],  this.data.featureMappingArray = [], this.data.displayName = "", this.data.basePairs = "",  this.data.featuresInMapView = [],  this.data.isPlasmid = "";
    }
}


ArxDraw.prototype.makeHTML = function(){
    //required for every widget
    //must return an HTML element that contains all the initial widget HTML
    var self = this;
    return $('<div class="arxDrawContainer" id="'+self.parentDiv+'_arxDrawContainer">' +
                '<div class="arxD_menuButtonRight"><a href="#"> Details </a></div>' +
                '<br>'+
                '<input type="file" id="'+self.parentDiv+'_fileOpen" class="arxD_fileOpen"  style="display: none">' +
                
                '<div id="'+self.parentDiv+'_topNavbar" class="arxD_topNavbar">' +
                    '<ul id="'+self.parentDiv+'_menuBar" class="arxD_menuBar">' +
                        '<li class="arxD_menuButton" id="'+self.parentDiv+'_open" ><a href="#"> Open </a></li>' +
                        '<li class="arxD_menuButton"><a href="#" id="jQModal"> New </a></li>' +
                        //'<li class="arxD_menuButton" ><a href="#" onclick="save();"> Save </a></li>' +
                    '</ul>' +
                '</div>' +
                
                
                '<div id="'+self.parentDiv+'_uploadSpinner" class="arxD_uploadSpinner" style="display: none;"></div>' +
                '<div id="'+self.parentDiv+'_progressBar" class="arxD_progressBar default" style="display: none;" ><div></div></div>'+
                '<div id="'+self.parentDiv+'_dragDrop" class="arxD_dragDrop"><br>Drag and Drop GENBANK file to display..</div>' +

                '<div id="'+self.parentDiv+'_circularMap" style="display: none;">' +
                     '<canvas id="'+self.parentDiv+'_c1" height="600px"></canvas>' +
                '</div>' +

                '<div class="arxD_detailsPopup" id="'+self.parentDiv+'_display">' +
                    '<ul id="'+self.parentDiv+'_displayTabs" class="arxD_displayTabs">' +
                        '<li id="'+self.parentDiv+'_mapViewTab" class="arxD_displayTabViews mapView active"><a href="#"> Map View </a></li>' +
                        '<li id="'+self.parentDiv+'_SequenceViewTab" class="arxD_displayTabViews sequenceView"><a href="#"> Sequence View </a></li>' +
                        '<li id="'+self.parentDiv+'_LinearViewTab" class="arxD_displayTabViews linearView"><a href="#"> Linear View </a></li>' +
                        '<li id="'+self.parentDiv+'_FeaturesViewTab" class="arxD_FeaturesViewTab"><a href="#"> Features </a></li>' +
                        '<li id="'+self.parentDiv+'_EnzymesViewTab" class="arxD_EnzymesViewTab"><a href="#"> Enzymes </a></li>' +
                        '<li id="'+self.parentDiv+'_Close" ><a href="#"> X </a></li>' +
                    '</ul>' +
                    '<div class="arxD_tab_content_parent"><div id="'+self.parentDiv+'_FView" class="arxD_tab_content_fView" style="display: none"></div></div>' +
                    '<div class="arxD_tab_content_parent"><div id="'+self.parentDiv+'_EView" class="arxD_tab_content_eView" style="display: none"></div></div>' +
        
                    '<div id="'+self.parentDiv+'_MSLView" class="arxD_MSLView">' +
                        '<div id="'+self.parentDiv+'_leftNav" class="arxD_left">' +
                            '<dl id="'+self.parentDiv+'_leftMenu" class="arxD_leftMenu">' +
                                '<dt class="showEnzymes"><a href="#" id="'+self.parentDiv+'_showHideRE">Show Enzymes</a></dt>' +
                                '<dt class="hideFeatures"><a href="#" id="'+self.parentDiv+'_showHideFeatures">Hide Features</a></dt>' +
                                '<dt id="'+self.parentDiv+'_trans" style="display: none"> <span>Translations</span></dt>' +
                                '<dd id="'+self.parentDiv+'_transSubMenu" style="display: none">' +
                                    '<ul>' +
                                        '<li>' +
                                            '<div>' +
                                                '<label> <input type="radio" name="arxD_translations" id="'+self.parentDiv+'_translations" value="0" checked>None</label>' +
                                            '</div>' +
                                        '</li>' +
                                        '<li>' +
                                            '<div>' +
                                                '<label> <input type="radio" name="arxD_translations" id="'+self.parentDiv+'_translations1" value="1" >Frame+1</label>' +
                                            '</div>' +
                                        '</li>' +
                                        '<li>' +
                                            '<div>' +
                                                '<label> <input type="radio" name="arxD_translations" id="'+self.parentDiv+'_translations2" value="3" >Top 3 Frames</label>' +
                                            '</div>' +
                                        '</li>' +
                                        '<li>' +
                                            '<div>' +
                                                '<label> <input type="radio" name="arxD_translations" id="'+self.parentDiv+'_translations3" value="-3" >Bottom 3 Frames</label>' +
                                            '</div>' +
                                        '</li>' +
                                        '<li>' +
                                            '<div>' +
                                                '<label> <input type="radio" name="arxD_translations" id="'+self.parentDiv+'_translations4" value="6" >All 6 Frames</label>' +
                                            '</div>' +
                                        '</li>' +
                                    '</ul>' +
                                '</dd>' +
                                '<dt id="'+self.parentDiv+'_amino" style="display: none"> <span>AminoAcid</span></dt>' +
                                '<dd id="'+self.parentDiv+'_aminoSubMenu" style="display: none">' +
                                    '<ul>' +
                                        '<li>' +
                                            '<div>' +
                                                '<label> <input type="radio" name="arxD_aminoACid" id="'+self.parentDiv+'_singleLetterTranslations" value="single" >1 Letter</label>' +
                                            '</div>' +
                                        '</li>' +
                                        '<li>' +
                                            '<div>' +
                                                '<label> <input type="radio" name="arxD_aminoACid" id="'+self.parentDiv+'_threeLetterTranslations" value="three" checked>3 Letter</label>' +
                                            '</div>' +
                                        '</li>' +
                                    '</ul>' +
                                '</dd>' +
                            '</dl>' +
                        '</div>' +

                        '<div id="'+self.parentDiv+'_middle" class="arxD_middle arxD_tab_content">' +

                            '<div id="'+self.parentDiv+'_mapView" class="arxD_tab_pane active">' +
                                '<div id="'+self.parentDiv+'_mapViewControl" class="arxD_well">' +
                                    '<span><label style="float:left;">Rotation:</label><div id="'+self.parentDiv+'_rotationSlider" class="arxD_Slider" style="float:left;"></div></span>' +
                                    '<span><label style="float:left;">Zoom:</label><div id="'+self.parentDiv+'_zoomSlider" class="arxD_Slider"></div></span>' +
                                '</div>' +
                                
                                '<div id="'+self.parentDiv+'_wrapper1" class="arxD_wrapper"> ' +
                                    '<div id="'+self.parentDiv+'_mapViewCanvas" >' +
                                         '<canvas id="'+self.parentDiv+'_c3" width="1530" height="600"></canvas>' +
                                    '</div>' +
                                '</div>' +
                            '</div>' +
                            
                            '<div id="'+self.parentDiv+'_sequenceView" class="arxD_tab_pane">' +
                                '<div class="arxD_well" id="sequenceviewcontrol" >' +
                                    '&nbsp; <input type="checkbox" id="'+self.parentDiv+'_showComplementary" class="showComplementary" value="1" onclick="self.toggleDisplayComplementary()" checked> <span> &nbsp; Show Complementary &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </span>' +
                                    '<input type="text" id="'+self.parentDiv+'_goToBasePair" size="5" value="asd" >&nbsp; <input type="button" id="'+self.parentDiv+'_goToBasePairBtn" value="GoTo Base Pair"> <span style="float:right" id="basePairInfo"></span>' +
                                '</div>' +
                                
                                '<div id="'+self.parentDiv+'_wrapperXY" class="arxD_wrapper" >' +
                                    '<div id="'+self.parentDiv+'_sequenceViewCanvas" style="width:1500px;">' +
                                        '<div id="'+self.parentDiv+'_canvasPushDiv" style="height:1px;"> </div>' +
                                        '<canvas id="'+self.parentDiv+'_c2" width="1530" height="2800" style=""></canvas>' +
                                    '</div>' +
                                '</div>' +
                            '</div>' +

                            '<div id="'+self.parentDiv+'_linearView" class="arxD_tab_pane">' +
                                '<div class="arxD_well" id="linearviewcontrol" >' +
                                    '<span><label style="float:left;">Zoom:</label><div id="'+self.parentDiv+'_linearZoomSlider" class="arxD_Slider"></div></span>' +
                                '</div>' +
                                
                                '<div id="'+self.parentDiv+'_wrapper2" class="arxD_wrapper_linear"> ' +
                                    '<div id="'+self.parentDiv+'_linearViewCanvas" >' +
                                        '<canvas id="'+self.parentDiv+'_c4" width="1530" height="400"></canvas>' +
                                    '</div>' +
                                '</div>' +
                            '</div>' +

                            '<div class="arxD_well" id="'+self.parentDiv+'_selectionDetails" style="margin-bottom: 2px; display: block">' +
                                '<p><b>BASE PAIRS: </b><span id="'+self.parentDiv+'_bases"></span> <span id="'+self.parentDiv+'_selectionInfo"></span></p>' +
                            '</div> ' +
                        '</div>' +
                    '</div>' +
        
                    '<div id="'+self.parentDiv+'_dialogForm" title="Enter valid base pairs">' +
                        '<form>' +
                            '<fieldset>' +
                                '<textarea id="'+self.parentDiv+'_modalTA" rows="5" cols="25"></textarea>' +

                                '<input type="submit" tabindex="-1" style="position:absolute; top:-1000px">' +
                            '</fieldset>' +
                        '</form>' +
                    '</div>' +
                '</div>' +
                '</div>'+
            '</div>')[0];
};

ArxDraw.prototype.drawHTML = function(){
    //required for every widget
    //must attach all initial widget HTML to self.parentDiv
    //also should run any functions that need to be run after the HTML is drawn
    //and attach any event listeners that need to be attached to elements in the HTML
    var self = this;
    $('#' + self.parentDiv).append(self.makeHTML());
    self.postDraw();
    self.attachEventListeners();
};



ArxDraw.prototype.attachEventListeners = function(){
    //attaches event listeners.  called after HTML is loaded
    var self = this;
    
    /** Scroll bar for sequence view - http://manos.malihu.gr/jquery-custom-content-scroller **/
    var scrollCheck = false;
    
    var clickCount = 0;

    $("li#"+self.parentDiv+"_open").on("click", function(event) { 
        console.log("OPEN BUTTON CLICKED");
        //document.getElementById('arxD_fileOpen').click();
        $("#"+self.parentDiv+'_fileOpen').click();
    });

    $("li.arxD_displayTabViews").on("click", function(event) {   
        var view = $(this).closest("li").attr("class").split(" ")[1];
        console.log("BEFORE ADD REMOVE");
        self.arxD_addRemoveClassActive($(this).closest("li").attr("id"), view); 
        console.log("DISPLAY VIEWS: " + view + ", " + $(this).closest("li").attr("id") );
        self.arxD_checkLeftMenuTabs(view);
        console.log(" mcs.top :" + self.draggerTop);
    });
    
    $("li.arxD_FeaturesViewTab").on("click", function(event) { 
        console.log("BEFORE ADD REMOVE");
        self.arxD_addRemoveClassActive($(this).closest("li").attr("id"), "FeaturesView");    
        $("#"+self.parentDiv+"_MSLView").attr("style", "display: none");
        $("#"+self.parentDiv+"_EView").attr("style", "display: none");
        $("#"+self.parentDiv+"_FView").attr("style", "display: block");
    });

    $("li.arxD_EnzymesViewTab").on("click", function(event) {  
        console.log("BEFORE ADD REMOVE");
        self.arxD_addRemoveClassActive($(this).closest("li").attr("id"), "EnzymesView");   
        $("#"+self.parentDiv+"_MSLView").attr("style", "display: none");
        $("#"+self.parentDiv+"_FView").attr("style", "display: none");
        $("#"+self.parentDiv+"_EView").attr("style", "display: block");
    });

    $("li.arxD_displayEnzymes").on("click", function(event) {   
        
        var tab = ($(this).closest("li").attr("id")).split("_")[1] ; 
        
        if (tab == "displayEnzymeLocTabs") {
            $("#"+self.parentDiv+'_enzymeLoc').attr("style", "display: block");
            $("#"+self.parentDiv+'_enzymeLines').attr("style", "display: none");
            $("#"+self.parentDiv+'_displayEnzymeLocTabs').addClass("active");
            $("#"+self.parentDiv+'_displayEnzymeLinesTabs').removeClass("active");
        }
        else {
            $("#"+self.parentDiv+'_enzymeLoc').attr("style", "display: none");
            $("#"+self.parentDiv+'_enzymeLines').attr("style", "display: block");
            $("#"+self.parentDiv+'_displayEnzymeLocTabs').removeClass("active");
            $("#"+self.parentDiv+'_displayEnzymeLinesTabs').addClass("active");
        }
    });

    $("div.arxD_menuButtonRight").on("click", function(event) {
        console.log("clickCount: "+ clickCount);
        $.blockUI({
            message: $('#'+self.parentDiv+'_display'), 
            css: { 
                border: '3px solid #aaa',
                height: '80%',
                width: '70%',
                top: '5%',
                left: '15%',
                textAlign: 'left',
                backgroundColor: '#ffffff', 
                '-webkit-border-radius': '10px', 
                '-moz-border-radius': '10px', 
                opacity: .95, 
                cursor: 'default',
                color: '#000000' 
            },
            onOverlayClick: $.unblockUI
        });
        if (clickCount == 0) {
            //$(".arxD_wrapper").height($('#'+self.parentDiv+'_display').height() * 0.7);
        }
        clickCount++;
        $(".arxD_wrapper").height($( window ).height() * 0.55);
        $(".arxD_wrapper_linear").height($( window ).height() * 0.55);

        console.log("SCROLL HEIGHT: "+$(".arxD_wrapper")[0].scrollHeight +", " + $('#'+self.parentDiv+'_wrapper1').height() +", " + $(".arxD_wrapper").height() +", " + $(".arxD_wrapper_linear")[0].scrollHeight+", " + $('#'+self.parentDiv+'_wrapper2').height()  +", " + $(".arxD_wrapper_linear").height() );
        //SCROLL HEIGHT: 881, 538, 538, 0, 538.45, 538.45
        
        

        //console.log("Canvas HEIGHT: " + self.canvas2.getHeight() +", " + self.canvas3.getHeight() + ", " + self.canvas4.getHeight())
        //3147, 881.1, 572
        //$('#'+self.parentDiv+'_wrapper2').scrollTop($(".arxD_wrapper_linear")[0].scrollHeight);
    });

    $("#"+self.parentDiv+"_Close").click(function() { 
        $.unblockUI(); 
        return false; 
    });

    $('input[type=radio][name=arxD_translations]').on('change', function(){
        $("#"+self.parentDiv+"_transSubMenu").attr("style", "display:none");
        $("#"+self.parentDiv+"_goToBasePair").val('');
        console.log("TRANSLATIONS: "+ $(this).val());
        if ($(this).val()) {
            if (self.canvas2.getObjects().length > 0) {
                self.startSpinner();
                setTimeout(function(){
                    var text = self.canvas2.item(2).totalText;
                    self.wrapCanvasText(self.startId2, self.endId2, text, 1, false);
                },35); 
            }
        }
    });

    $('input[type=radio][name=arxD_aminoACid]').on('change', function(){
        $("#"+self.parentDiv+"_aminoSubMenu").attr("style", "display:none");
        $("#"+self.parentDiv+"_goToBasePair").val('');
        console.log("Letter Trans value: "+ $(this).val());
        if ($(this).val()) {
            if (self.canvas2.getObjects().length > 0) {
                self.startSpinner();
                setTimeout(function(){
                    var text = self.canvas2.item(2).totalText;
                    self.wrapCanvasText(self.startId2, self.endId2, text, 1, false);
                },35); 
            }
        }
    });

    $("#"+self.parentDiv+"_showHideFeatures").on("click", function(event) { 
        $("#"+self.parentDiv+"_goToBasePair").val('');  
        if ( $("#"+self.parentDiv+"_showHideFeatures").text() == 'Show Features' ) {
            $("#"+self.parentDiv+"_showHideFeatures").text('Hide Features');
        }
        else {
            $("#"+self.parentDiv+"_showHideFeatures").text('Show Features');
        }
        
        if (self.canvas2.getObjects().length > 0) {
            self.startSpinner();
            var text = self.canvas2.item(2).totalText;
            self.wrapCanvasText(self.startId2, self.endId2, text, 1, true);
        }
    });


    $("#"+self.parentDiv+"_showHideRE").on("click", function(event) {
        $("#"+self.parentDiv+"_goToBasePair").val('');
        if ( $("#"+self.parentDiv+"_showHideRE").text() == 'Show Enzymes' ) {
            $("#"+self.parentDiv+"_showHideRE").text('Hide Enzymes');
            totalBP = self.canvas4.item(0).item(1).text;
        }
        else {
            $("#"+self.parentDiv+"_showHideRE").text('Show Enzymes');
        }
        
        if (self.canvas2.getObjects().length > 0) {
            self.startSpinner();
            self.wrapCanvasText(self.startId2, self.endId2, self.data.result, 1, true);
        }
    });

    
    $("#"+self.parentDiv+"_trans").on('mouseenter', function(event) {  
        $("#"+self.parentDiv+"_transSubMenu").attr("style", "display:block");
    });

    $("#"+self.parentDiv+"_trans").on('mouseleave', function(event) {  
        $("#"+self.parentDiv+"_transSubMenu").attr("style", "display:none");
    });

    $("#"+self.parentDiv+"_amino").on('mouseenter', function(event) {        
        $("#"+self.parentDiv+"_aminoSubMenu").attr("style", "display:block");
    });

    $("#"+self.parentDiv+"_amino").on('mouseleave', function(event) {        
        $("#"+self.parentDiv+"_aminoSubMenu").attr("style", "display:none");
    });

    $("#"+self.parentDiv+"_transSubMenu").on('mouseenter', function(event) {        
        $("#"+self.parentDiv+"_transSubMenu").attr("style", "display:block");
    });

    $("#"+self.parentDiv+"_transSubMenu").on('mouseleave', function(event) {        
        $("#"+self.parentDiv+"_transSubMenu").attr("style", "display:none");
    });

    $("#"+self.parentDiv+"_aminoSubMenu").on('mouseenter', function(event) {        
        $("#"+self.parentDiv+"_aminoSubMenu").attr("style", "display:block");
    });

    $("#"+self.parentDiv+"_aminoSubMenu").on('mouseleave', function(event) {        
        $("#"+self.parentDiv+"_aminoSubMenu").attr("style", "display:none");
    });

    
    $("#"+self.parentDiv+"_goToBasePairBtn").on("click", function(event) {
        var basePair = $("#"+self.parentDiv+"_goToBasePair").val();
        console.log("basePair: "+basePair);
        self.goToBasePairFn(basePair);
    });


    dialog = $( "#"+self.parentDiv+"_dialogForm" ).dialog({
        autoOpen: false,
        height: 300,
        width: 350,
        modal: true,
        buttons: {
            Parse: arxD_modalFn,
            Cancel: function() {
                dialog.dialog("close");
            },
        },
        close: function() {
            form[ 0 ].reset();
        }
    });
     
    form = dialog.find( "form" ).on( "submit", function( event ) {
        event.preventDefault();
    });
     
    $('#jQModal').click(function(){ $('div#'+self.parentDiv+'_dialogForm').dialog('open'); });
        
    function arxD_modalFn() {
        var t = $('#'+self.parentDiv+'_modalTA').val();
        dialog.dialog("close");
        dropzone.remove();

        $('#'+self.parentDiv+'_topNavbar').hide();
        $('.arxD_menuButtonRight').show();
        //$('#'+self.parentDiv+'_display').show();
        $('#'+self.parentDiv+'_circularMap').show();
        self.wrapCanvasText(0, 20, t, 1, true);
    }


    // Do some initializing stuff
    fabric.Object.prototype.set({
        transparentCorners: false,
        cornerColor: 'rgba(102,153,255,0.5)',
        cornerSize: 12,
        padding: 5
    });


    dropzone = $('#'+self.parentDiv+'_dragDrop');

    $("#"+self.parentDiv+"_fileOpen").change(function() {
        var files = $("#"+self.parentDiv+'_fileOpen').prop("files")
        var fileName = files[0].name;
        var contents = "";
        var extension = files[0].name.split('.').pop().toLowerCase();
        
        if (files && extension == "gb") {
            $('#'+self.parentDiv+'_progressBar').show();
            self.progressBar( 20, "Uploading..", $('#'+self.parentDiv+'_progressBar') );
            console.log("Progress Bar: Uploading..");
            self.startSpinner();
            console.log("FILE NAME: "+fileName);

            self.sendParseRequest(files);
        } else { 
            swal({
                title: "",
                text: '<span>Only Genbank files are supported at this time.<span>',
                html: true
            });
        }
    });
    
        
    dropzone.on('dragover', function() {
        //add hover class when drag over
        dropzone.addClass('hover');
        return false;
    });
    dropzone.on('dragleave', function() {
        //remove hover class when drag out
        dropzone.removeClass('hover');
        return false;
    });


    dropzone.on('drop', function(e) {
        //prevent browser from open the file when drop off
        e.stopPropagation();
        e.preventDefault();
        
        //retrieve uploaded files data
        var files = e.originalEvent.dataTransfer.files;
        var fileName = files[0].name;
        var contents = "";
        var extension = files[0].name.split('.').pop().toLowerCase();
        
        if (files && extension == "gb") {
            $('#'+self.parentDiv+'_progressBar').show();
            self.progressBar( 20, "Uploading..", $('#'+self.parentDiv+'_progressBar') );
            console.log("Progress Bar: Uploading..");
            self.startSpinner();
            console.log("FILE NAME: "+fileName);

            self.sendParseRequest(files);

        } else { 
            swal({
                title: "",
                text: '<span>Only Genbank files are supported at this time.<span>',
                html: true
            });
        }
    });

/** Mouse movements on canvases **/
self.canvas2.on('mouse:down', function(e) {
    if (self.canvas2MouseClick == true) {
        self.canvas2MouseClick = false;
        if (self.canvas2ClickId) {
            self.applyFeatureHighLight(self.canvas2ClickId.item(0).highLightId, false);
            self.canvas2ClickId = '';
            $('#'+self.parentDiv+'_selectionInfo').html("");
        }
    }
    
    if (self.canvas2MouseClick == false)  {
        if (e.target && e.target.isType('group') && e.target.id == 100 && e.target.item(0).type != "line") {
            self.applyFeatureHighLight(e.target.item(0).highLightId, true);
            self.showFeatureDetails(e);
            var s = JSON.parse(self.data.fStrJSON[parseInt(e.target.item(0).arrId)])['segment'];
            
            if (!isNaN(s.substring(0,1))) { 
                var fStart = s.split("..")[0];
                var fEnd = s.split("..")[1];
            }
            else if (s.split("(")[0] == "join") { //join(1323..1789,1872..2025,2162..2636)
                fSegments = s.split("(")[1].substr(0, (s.split("(")[1].length-1)).split(",");
                var fStart = fSegments[0].split("..")[0];
                var fEnd = fSegments[fSegments.length-1].split("..")[1];
            }
            else if (s.split("(")[0] == "complement") { //complement(29727..30005)
                var fStart = s.split("(")[1].split("..")[0];
                var fEnd = s.split("(")[1].split("..")[1].substr(0,(s.split("(")[1].split("..")[1].length - 1));
            }
            
            $('#'+self.parentDiv+'_selectionInfo').html( "&nbsp;&nbsp;&nbsp;<b>START:</b> "+ fStart +"&nbsp;&nbsp;&nbsp;<b>ENDS:</b> "+ fEnd +"&nbsp;&nbsp;&nbsp;<b>LENGTH:</b> "+ ((fEnd - fStart)+1) + "&nbsp;&nbsp;&nbsp;<b>GC:</b> "+ self.gc( (fStart - 1), fEnd) +"%");
            
            self.canvas2MouseClick = true;
            self.canvas2ClickId = e.target;
        }
    }
});

self.canvas2.on('mouse:move', function(e) {
    if ( e.target && e.target.isType('group') && ( e.target._objects.length == 4 || e.target._objects.length == 5 ) && ( e.target.item(0).isType('text') ) ) {
        if (e.target.item(0).info.length > 0) {
            var info = e.target.item(0).info;
            //console.log("info: "+e.target.item(0).info);//1#2#114#1#1-2#1-6#sticky#90 == getTheStartRow+"#"+getTheEndRow+"#"+getTheStartPos+"#"+getTheEndPos+"#"+cutStartRow+"-"+cutStartPos+"#"+cutEndRow+"-"+cutEndPos+"#"+cutType+"#"+lineBreak
            //0#0#8#14#0-5#0-1#sticky#0,140,302,464,626,788,950,1112,1274,1436,1598#0,4,11,18,25,32,39,46,53,60,67
            //0#1#98#4#0-1#1--1#blunt#80

            
            var getTheStartRow = info.split("#")[0];
            var getTheEndRow = info.split("#")[1];
            var selStart = info.split("#")[2];
            var selEnd = info.split("#")[3];
            var cutStartRow = info.split("#")[4].split("-")[0];
            var cutStart = info.split("#")[4].split("-")[1];
            var cutEndRow = info.split("#")[5].split("-")[0];
            var cutEnd = info.split("#")[5].split("-")[1];
            var cutType = info.split("#")[6];
            var lineBreak = info.split("#")[7].split(",");
            var itemsBtwRow = info.split("#")[8].split(","); 
            self.applyFeatureHighLight(e.target.item(0).highLightIds, true);
                
            var backgroundXOffset = 0;
            var backgroundYOffset = 0;

            console.log("Canvas2 mouse move: "+ info);
            
            if (cutType == "blunt" && cutStartRow == cutEndRow && parseInt(getTheStartRow) == cutStartRow){
                var x1 = parseInt(self.offsetArray[(parseInt(selStart)+parseInt(cutStart))]);
                var y1 = parseInt(lineBreak[cutStartRow  - self.startId2]);
                var y2 = y1 + 22 + 20 -1;
                
                if( $('#'+self.parentDiv+'_showComplementary').attr('checked') ) {
                    self.drawBluntCut(0, y1, 0, y2, x1, (y1));
                }
            }
            else if (cutType == "blunt" && cutStartRow == cutEndRow && parseInt(getTheEndRow) == cutStartRow){
                var x1 = parseInt(self.offsetArray[(parseInt(cutStart))]);
                var y1 = parseInt(lineBreak[cutStartRow  - self.startId2]);
                var y2 = y1 + 22 + 20 -1;
                
                if( $('#'+self.parentDiv+'_showComplementary').attr('checked') ) {
                    self.drawBluntCut(0, y1, 0, y2, x1, (y1));
                }
            }
            else if (cutType == "blunt" && cutStartRow != cutEndRow){
                var x1 = parseInt(self.offsetArray[(parseInt(cutStart))]);
                var y1 = parseInt(lineBreak[cutStartRow  - self.startId2]);
                var y2 = y1 + 22 + 20 -1;
                
                if( $('#'+self.parentDiv+'_showComplementary').attr('checked') ) {
                    self.drawBluntCut(0, y1, 0, y2, x1, (y1));
                }
            }
            else if (cutType == "sticky" && cutStartRow == cutEndRow && parseInt(getTheStartRow) == cutStartRow && parseInt(cutEnd) > parseInt(cutStart) ){
                console.log("(getTheStartRow) === cutStartRow ================= parseInt(cutEnd) > parseInt(cutStart)");
                var x1 = parseInt(self.offsetArray[(parseInt(selStart)+parseInt(cutStart))]);
                var y1 = parseInt(lineBreak[cutStartRow - self.startId2]);
                var y2 = y1 + 22 -1;
                var x2 = parseInt(self.offsetArray[(parseInt(selStart)+parseInt(cutEnd))]);
                
                if( $('#'+self.parentDiv+'_showComplementary').attr('checked') ) {
                    self.drawCut(0, y1, 0, y2, x1, (y1));
                    self.drawCut(0, y2, (x2-x1), y2, x1, (y2));
                    self.drawCut((x2-x1), y2, (x2-x1), (y2+20), x2, (y2));
                }
            }
            else if ( cutType == "sticky" && cutStartRow == cutEndRow && parseInt(getTheStartRow) == cutStartRow && parseInt(cutEnd) < parseInt(cutStart) ){ //For restricted enzyme Pst1
                console.log("(getTheStartRow) === cutStartRow");
                var x1 = parseInt(self.offsetArray[(parseInt(selStart)+parseInt(cutStart))]);
                var y1 = parseInt(lineBreak[cutStartRow - self.startId2]);
                var y2 = y1 + 22 -1;
                var x2 = parseInt(self.offsetArray[(parseInt(selStart)+parseInt(cutEnd))]);
                
                if( $('#'+self.parentDiv+'_showComplementary').attr('checked') ) {
                    self.drawCut(0, y1, 0, y2, x1, (y1));
                    self.drawCut(0, y2, (x2-x1), y2, x2, (y2));
                    self.drawCut((x2-x1), y2, (x2-x1), (y2+20), x2, (y2));
                }
            }
            else if ( cutType == "sticky" && cutStartRow > cutEndRow && parseInt(getTheStartRow) < cutStartRow ){ 
                console.log("(getTheStartRow) < cutStartRow");
                var x1 = parseInt(self.offsetArray[(parseInt(selStart)+parseInt(cutEnd))]);
                var y1 = parseInt(lineBreak[cutEndRow - self.startId2]);
                var y2 = y1 + 22 -1;
                //var x2 = parseInt(self.offsetArray[(parseInt(selStart)+parseInt(cutEnd))]);
                var x2 = parseInt(self.offsetArray[self.wordsInALine]);
                var y3 = parseInt(lineBreak[cutStartRow - self.startId2]);
                var y4 = y3 + 22 -1;
                var x3 = parseInt(self.offsetArray[0]);
                var x4 = parseInt(self.offsetArray[(parseInt(cutStart))]);

                console.log("Restriction Enzymes: "+ x1 + ", " + x2 );
                console.log("Restriction Enzymes: "+ y1 + ", " + y2 );
                
                if( $('#'+self.parentDiv+'_showComplementary').attr('checked') ) {
                    //self.drawCut(0, y1, 0, y2, x1, (y1));
                    //self.drawCut(0, y2, (x2-x1), y2, x2, (y2));
                    //self.drawCut((x2-x1), y2, (x2-x1), (y2+20), x2, (y2));

                    //self.drawCut(0, y1, 0, y2, x1, (y1));
                    self.drawCut(0, y2, (x1-x2), y2, x1, (y2));
                    self.drawCut((x2-x1), y2, (x2-x1), (y2+20), x1, (y2));
                    self.drawCut(0, y4, (x4-x3), y4, x3, (y4));
                    self.drawCut(0, y3, 0, y4, x4,(y4-21));
                }
            }
            else if (cutType == "sticky" && cutStartRow == cutEndRow && parseInt(getTheStartRow) < cutStartRow){
                var x1 = parseInt(self.offsetArray[parseInt(cutStart)]);
                var y1 = parseInt(lineBreak[cutStartRow - self.startId2]);
                var y2 = y1 + 22 -1;
                var x2 = parseInt(self.offsetArray[parseInt(cutEnd)]);

                console.log("Restriction Enzymes: "+ x1 + ", " + x2 );
                console.log("Restriction Enzymes: "+ y1 + ", " + y2 );
                
                if( $('#'+self.parentDiv+'_showComplementary').attr('checked') ) {
                    self.drawCut(0, y1, 0, y2, x1, (y1));
                    self.drawCut(0, y2, (x2-x1), y2, x1, (y2));
                    self.drawCut((x2-x1), y2, (x2-x1), (y2+20), x2, (y2));
                }
            }
            else if (cutType == "sticky" && cutStartRow < cutEndRow){   
                console.log("ENZYMES: cutStartRow < cutEndRow " ); 
                var x1 = parseInt(self.offsetArray[(parseInt(selStart)+parseInt(cutStart))]);
                var y1 = parseInt(lineBreak[cutStartRow - self.startId2]);
                var y2 = y1 + 22 -1;
                var x2 = parseInt(self.offsetArray[self.wordsInALine]);
                var y3 = parseInt(lineBreak[cutEndRow - self.startId2]) + 22 - 1;
                var y4 = y3 + 22 -1;
                var x3 = parseInt(self.offsetArray[0]);
                var x4 = parseInt(self.offsetArray[(parseInt(cutEnd))]);

                console.log("Restriction Enzymes: "+ x1 + ", " + x2 + ", " +x3  + ", " +x4);
                console.log("Restriction Enzymes: "+ y1 + ", " + y2 + ", " +y3  + ", " +y4);
                
                if( $('#'+self.parentDiv+'_showComplementary').attr('checked') ) {
                    self.drawCut(0, y1, 0, y2, x1, (y1));
                    self.drawCut(0, y2, (x2-x1), y2, x1, (y2));
                    self.drawCut(0, y3, (x4-x3), y3, x3, (y3));
                    self.drawCut(0, y3, 0, y4, x4,(y4-21));
                }
            }
            else {
                console.log("ELSE ELSE");
            }
            self.canvas2.renderAll();
        }
    }
    else if (e.target && e.target.isType('group') && e.target.id == 100 && e.target.item(0).type != "line")
    {
        if (!self.canvas2MouseClick) {
            self.applyFeatureHighLight(e.target.item(0).highLightId, true);
        }
        self.showFeatureDetails(e);
    }
    else if (e.target && e.target.isType('i-text') && e.target.id == 200)
    {
        self.applyTranslationHighLight(e.target.movePos, e.target.highlightId, true);
        self.showAmenoAcid(e);
    }
    else if (e.target && e.target.isType('rect') && e.target.id == 111)
    {
        var pointer = self.canvas2.getPointer(e.e);
        var posX = pointer.x;
        var posY = pointer.y;
        var amenoAcid = "";
        var hId = "";
        
        amenoAcidIdsArray = self.amenoAcidIds[e.target.orfRow+"_"+e.target.orfNum];
        for (var i =0; i < amenoAcidIdsArray.length; i ++) {
            var obj = self.canvas2.item(amenoAcidIdsArray[i]);
            if (obj.isType('i-text')) {
                if ( obj.left < posX && obj.right > posX ){
                    if ( obj.top < posY && obj.bottom > posY ){
                        amenoAcid = obj.name;
                        hId = obj.highlightId;
                        //check if the details are displayed in case of moving ameno acid name
                        if ($('#'+self.parentDiv+'_orfDetails').length) {
                            $('#'+self.parentDiv+'_showORFamenoText').text(amenoAcid);
                        }
                        self.applyTranslationHighLight(obj.movePos, obj.highlightId, true);
                    }
                }
            }
        }
        self.showORFDetails(e, amenoAcid, hId);
    }
});



self.canvas2.on('mouse:out', function(e) {
    if (e.target.isType('group') && (e.target._objects.length == 4 || e.target._objects.length == 5)) {
                
        if (e.target.item(0).isType('text')) {
            
            self.applyFeatureHighLight(e.target.item(0).highLightIds, false);
            
            if (self.drawCutArray.length > 0) {
                self.drawCutArray.reverse();
                for(var l = 0; l < self.drawCutArray.length; l++){
                    if (self.canvas2.item(parseInt(self.drawCutArray[l])-1) && self.canvas2.item(parseInt(self.drawCutArray[l])-1).type == "line"){
                        self.canvas2.item(parseInt(self.drawCutArray[l])-1).remove();
                    }
                    self.canvas2.renderAll();
                }
                self.drawCutArray = [];
            }
        }
    }
    else if (e.target.isType('group') && (e.target.id == 100) && e.target.item(0).type != "line") {
        $('#'+self.parentDiv+'_featureDetails').remove();
        if (!this.canvas2MouseClick) {
            self.applyFeatureHighLight(e.target.item(0).highLightId, false);
        }
    }
    else if (e.target.isType('i-text') && e.target.id == 200) {
        $('#'+self.parentDiv+'_amenoAcid').remove();
        self.removeTranslationHighLight(e.target.highlightId, false);
    }
    else if (e.target && e.target.isType('rect') && e.target.id == 111) {
        if ($('#'+self.parentDiv+'_showORFhId').text() > 0) {
            self.removeTranslationHighLight($('#'+self.parentDiv+'_showORFhId').text(), false);
        }
        $('#'+self.parentDiv+'_orfDetails').remove();
    }
});


/** Showing the info with mouse over the FEATURE maps canvas3 **/
self.canvas3.on('mouse:move', function(e) {
    if( e.target && e.target.type == "group" && e.target.type != "line" && e.target.item(0).id == 100 ) {
        self.showDetails(e);
    }
    else if( e.target && e.target.type == "group" && e.target.type != "line" && e.target.item(1).id == 11011 ) {
        self.showRestrictionEnzymeDetails(e);
    }
});

self.canvas3.on('mouse:out', function(e) {
    if(e.target && e.target.type == "group" && e.target.type != "line" && e.target.item(0).id == 100 ) {
        $('#'+self.parentDiv+'_showFeatureDetails').remove();
    }
    else if(e.target && e.target.type == "group" && e.target.type != "line" && e.target.item(1).id == 11011 ) {
        $('#'+self.parentDiv+'_showRestrictionEnzymeDetails').remove();
    }
});



/** Showing the info with mouse over canvas4 **/
self.canvas4.on('mouse:move', function(e) {
    if(e.target && e.target.type == "group" && e.target.type != "line" && e.target.item(0).id == 100 ) {
        self.showDetailsC4(e);
    }
    else if(e.target && e.target.type == "group" && e.target.type != "line" && e.target.item(1).id == 11011 ) {
        self.showRestrictionEnzymeDetailsC4(e);
    }
});

self.canvas4.on('mouse:out', function(e) {
    if(e.target && e.target.type == "group" && e.target.type != "line" && e.target.item(0).id == 100 ) {
        $('#'+self.parentDiv+'_showFeatureDetailsC4').remove();
    }
    else if(e.target && e.target.type == "group" && e.target.type != "line" && e.target.item(1).id == 11011 ) {
        $('#'+self.parentDiv+'_showRestrictionEnzymeDetailsC4').remove();
    }
});

}

ArxDraw.prototype.sendParseRequest = function(files) {
    var self = this;
    var r = new FileReader();
    r.onload = function(e) {
        contents = e.target.result;
        self.data.fileText = contents;
        self.data.fileName = files[0].name;
        self.progressBar( 20, "Uploading..", $('#'+self.parentDiv+'_progressBar') );
        //Upload the files to the server and then send the file name as response for further calculations
        pl_upload = {
            "function": "uploadFile",
            "formId": self.formId,
            "data": self.data
        }

        var updateProgress = function (event) {
            if (event.lengthComputable) {
                var complete = event.loaded/event.total;
            } else {
                console.log("File upload size unknown");
            }
            self.progressBar(Math.round(45*complete)+25, "Uploading..", $('#'+self.parentDiv+'_progressBar') );
        }

        self.restCallAsyncUpload("/userFunctions","POST",pl_upload,updateProgress,function(response){
            if (response["success"]){
                self.progressBar( 70, "Parsing the data..", $('#'+self.parentDiv+'_progressBar') );
                console.log("Progress Bar: Parsing the data.." + response["success"]);
                pl = {
                    "function": "parse",
                    "formId": self.formId,
                    "data": response["success"]
                }   
                //restCallA() is an asynchronous call with a call back.  restCall() may be used for synchronous calls. just omit the callback
                restCallA("/userFunctions","POST",pl,function(response){
                    if (response["success"]){
                        self.progressBar( 80, "Displaying the data..", $('#'+self.parentDiv+'_progressBar') );
                        console.log("Progress Bar: Displaying the data..");
                        dropzone.remove();
                        $('#'+self.parentDiv+'_topNavbar').hide();
                        $('.arxD_menuButtonRight').show();
                        //$('#'+self.parentDiv+'_display').show();
                        $('#'+self.parentDiv+'_circularMap').show();
                        
                        var r = response;
                        self.data.displayName = r.success[0].displayName;
                        self.data.basePairs = r.success[0].basePairs;
                        self.data.isPlasmid = r.success[0].isPlasmid;
                        self.data.result = r.success[0].result;
                        self.data.fStrJSON = r.success[0].fStrJSON;
                        self.data.featureMappingArray = r.success[0].featureMappingArray;
                        self.data.featuresInMapView = r.success[0].featuresInMapView;
                        
                        if (self.data.isPlasmid != true || self.data.isPlasmid != 1 || self.data.isPlasmid != "1") {
                           /* $("#arxD_displayTabs li:eq(0)").hide();
                            $('#arxD_mapView').remove();
                            $('#arxD_sequenceView').show(); */
                        }
                        
                        self.data.featuresInMapView.sort( self.sort_by('startPos', false, parseInt) ); 
                        self.findFMAOverlap_mapView(self.data.featuresInMapView);
                        self.wrapCanvasText(0, 20, self.data.result, 1, true);
                        
                        $('#'+self.parentDiv+'_goToBasePair').val("");
                        $('#'+self.parentDiv+'_basePairInfo').html( self.data.displayName + "&nbsp; &nbsp; &nbsp; &nbsp;" + self.data.basePairs +" bp" );
                        $('#'+self.parentDiv+'_bases').html( self.data.basePairs );
                                        
                        self.allTranslations = self.getAllAmenoAcidTranslations(self.data.result, self.wordsInALine);
                        self.allORFs = self.ORF(self.allTranslations);
                        
                        self.progressBar( 95, "Displaying the data..", $('#'+self.parentDiv+'_progressBar') );
                        //var noOfRows = Math.floor(window.innerHeight / 20); //20 is td height
                        var noOfRows = Math.floor($("#"+self.parentDiv+"_middle").height()/20);
                        self.displayFeatures(self.data.featuresInMapView, noOfRows);
                        self.displayEnzymes(self.REmappingArray, noOfRows);
                        self.progressBar( 100, "Displaying the data..", $('#'+self.parentDiv+'_progressBar') );
                        
                        setTimeout(function() {
                            $('#'+self.parentDiv+'_progressBar').hide();
                            console.log("Progress Bar: Hiding..");
                        }, 1500);
                        
                    }
                });
            }
        });   
    }
    r.readAsText(files[0]);
}


ArxDraw.prototype.progressBar = function(percent, text, element) {
    var progressBarWidth = (percent * element.width() / 100) + "px";
    //element.find('div').animate({ width: progressBarWidth }, 50).html(text);
    element.find('div').width( progressBarWidth ).html(text);
    console.log("UPDATED PROGRESS BAR WIDTH: "+ element.find('div').width() + ", " + progressBarWidth);
}


ArxDraw.prototype.gc = function(s, c) {
    var self = this;
    var resultStr = self.data.result.slice(s,c).split("");
    var gcCount = 0;
    for (var i = 0; i < resultStr.length; i++) {
        if (resultStr[i] == 'g' || resultStr[i] == 'c') {
            gcCount = gcCount + 1;
        }
    }
    return ((gcCount * 100)/resultStr.length).toFixed(2);
}


ArxDraw.prototype.goToBasePairFn = function() {
    var self = this;
    var text = self.canvas2.item(2).totalText;

    var totalBP = parseInt((self.canvas3.item(0).item(1).text).split(" ")[0]);
    var basePair = parseInt($("#"+self.parentDiv+"_goToBasePair").val());
    console.log("BASE PAIR: "+ $.isNumeric(basePair));
    if ($.isNumeric(basePair) && basePair > 0 && basePair < totalBP) {
    
        var hId = Math.floor((basePair)/self.wordsInALine);

        if (hId > 5) {
            self.startId2 = hId - 5;    // Draw 5 rows before the actual basepair
            self.endId2 = self.startId2 + 20;
            
            self.wrapCanvasText(self.startId2, self.endId2, text, 1, false);
            //var basePairPos = ((basePair-1) - (self.wordsInALine*(self.startId2+5))) -1; 
            var basePairPos = (basePair % self.wordsInALine);
            if (basePairPos == 0) {
                basePairPos = self.wordsInALine - 1;
                var x = 4;
            }
            else {
                basePairPos = basePairPos - 1;
                var x = 5;
            }

            self.highLight(self.itemsBtwRow[x], basePairPos, parseInt(basePairPos), "yellow", false);
            
            //Need to move the scroll bar ('scrollTo',{y:"450",x:"250"});
            if (basePairPos >= self.wordsInALine/2) {
                var xPos = "right";
            }else {
                var xPos = "left";
            }
            self.gotoBasePairScroll = true;
            
            $("#"+self.parentDiv+"_canvasPushDiv").height( parseInt(($("#"+self.parentDiv+"_sequenceViewCanvas").height() * (self.startId2))/self.fText.length)+'px' );
            
            $("#"+self.parentDiv+"_wrapperXY").mCustomScrollbar("update");
            var xyx = self.bLW[x-1] + (parseInt(($("#"+self.parentDiv+"_sequenceViewCanvas").height() * (self.startId2))/self.fText.length));
            
            //$("#"+self.parentDiv+"_wrapperXY").mCustomScrollbar("scrollTo", { y: parseInt(($("#"+self.parentDiv+"_sequenceViewCanvas").height() * (hId))/self.fText.length), x: xPos });
            $("#"+self.parentDiv+"_wrapperXY").mCustomScrollbar("scrollTo", { y: xyx, x: xPos });
        }
        else {
            self.startId2 = 0;
            self.endId2 = self.startId2 + 20;
            
            self.wrapCanvasText(self.startId2, self.endId2, text, 1, false);
            //var basePairPos = (parseInt(basePair-1) - (self.wordsInALine*(hId))) -1; 
            var basePairPos = (basePair % self.wordsInALine);
            if (basePairPos == 0) {
                basePairPos = self.wordsInALine - 1;
                var x = hId - 1;
            }
            else {
                basePairPos = basePairPos - 1;
                var x = hId;
            }
            self.highLight(self.itemsBtwRow[x], basePairPos, parseInt(basePairPos), "yellow", false);
            
            //Need to move the scroll bar 
            if (basePairPos >= self.wordsInALine/2) {
                var xPos = "right";
            }else {
                var xPos = "left";
            }
            self.gotoBasePairScroll = true;
            
            $("#"+self.parentDiv+"_canvasPushDiv").height( parseInt(($("#"+self.parentDiv+"_sequenceViewCanvas").height() * (self.startId2))/self.fText.length)+'px' );
            $("#"+self.parentDiv+"_wrapperXY").mCustomScrollbar("update");
            
            if (x == 0) {
                var xyx = "top";
            }
            else {
                var xyx = self.bLW[x-1] + (parseInt(($("#"+self.parentDiv+"_sequenceViewCanvas").height() * (self.startId2))/self.fText.length));
            }
            console.log("BASE PAIRS: "+ x +", "+ xyx);
            //$("#"+self.parentDiv+"_wrapperXY").mCustomScrollbar("scrollTo", { y: parseInt(($("#"+self.parentDiv+"_sequenceViewCanvas").height() * (hId))/self.fText.length), x: xPos });
            $("#"+self.parentDiv+"_wrapperXY").mCustomScrollbar("scrollTo", { y: xyx, x: xPos });
        }
        
        console.log("BASE PAIR POS: "+ basePairPos);
        //self.draggerTop = parseInt(($("#"+self.parentDiv+"_sequenceViewCanvas").height() * (hId))/self.fText.length);
        self.draggerTop = xyx;
    }
    else {
        //swal('Please enter a valid base pair location.');
        swal({
            title: "",
            text: '<span>Please enter a valid base pair location.<span>',
            html: true
        });
        $("#"+self.parentDiv+"_goToBasePair").val('');
    }
}


ArxDraw.prototype.showORFDetails = function(e, amenoAcid, hId) {
    var self = this;
    if (!$('#'+self.parentDiv+'_orfDetails').length) {
        if (amenoAcid != "") {
            var displayValue = "<span id='"+self.parentDiv+"_showORFamenoText'>"+ amenoAcid + "</span><span id='"+self.parentDiv+"_showORFhId' style='display:none'>"+ hId + "</span><br>" + e.target.orfDetails;
        }
        else {
            var displayValue = e.target.orfDetails;
        }
        $('#'+self.parentDiv+'_display').append("<div id='"+self.parentDiv+"_orfDetails' class='arxD_showDetails'>"+displayValue+"</div>");
    }
    self.moveshowORFDetails(e);
}

ArxDraw.prototype.swalSimpleAlert = function(messageContent, messageTitle){
    window.latestSwalMessageContent = messageContent;
    window.latestSwalMessageTitle = messageTitle;
    if(typeof messageTitle == "undefined"){
        messageTitle = "";
    }
    swal({
        title: messageTitle,
        text: messageContent,
        //type: "error",
        confirmButtonText: "Ok",
        showCancelButton: false,
        html: true,
        //allowOutsideClick: true,
    });
}

ArxDraw.prototype.moveshowORFDetails = function(e) {
    var self = this;
    var codes = self.getMouse(e);
    var coords = ({'top':codes[1]+10,'left': (codes[0] - $('#'+self.parentDiv+'_display').offset().left) });
    if (coords != ""){
        var top = coords.top;
        var left = coords.left;
        $('#'+self.parentDiv+'_orfDetails').show();
        $('#'+self.parentDiv+'_orfDetails').css({top: top, left: left});
    }
    $("#"+self.parentDiv+"_orfDetails").delay(5000).hide(5);
}

ArxDraw.prototype.showAmenoAcid = function(e) {
    var self = this;
    if (!$('#'+self.parentDiv+'_amenoAcid').length) {
        var displayValue = e.target.name;
        $('#'+self.parentDiv+'_display').append("<div id='"+self.parentDiv+"_amenoAcid' class='arxD_showDetails'>"+displayValue+"</div>");
    }
    self.moveShowAmenoAcid(e);
}

ArxDraw.prototype.moveShowAmenoAcid = function(e) {
    var self = this;
    var codes = self.getMouse(e);
    var coords = ({'top':codes[1]+10,'left': (codes[0] - $('#'+self.parentDiv+'_display').offset().left) });
    if (coords != ""){
        var top = coords.top;
        var left = coords.left;
        $('#'+self.parentDiv+'_amenoAcid').show();
        $('#'+self.parentDiv+'_amenoAcid').css({top: top, left: left});
    }
    $("#"+self.parentDiv+"_amenoAcid").delay(5000).hide(5);
}


ArxDraw.prototype.applyTranslationHighLight = function(pos, id, visible) {
    var self = this;
    self.canvas2.item(id).visible = visible;
    self.canvas2.item(id).set('left', pos);
    self.canvas2.item(id).setCoords();
    self.canvas2.renderAll();
}

ArxDraw.prototype.removeTranslationHighLight = function(id) {
    var self = this;
    if (self.canvas2.item(id)) {
        self.canvas2.item(id).visible = false;
        self.canvas2.renderAll();
    }
}

ArxDraw.prototype.showFeatureDetails = function(e) {
    var self = this;
    var seg = JSON.parse(self.data.fStrJSON[parseInt(e.target.item(0).arrId)])['segment'];

    if ( (self.data.fStrJSON[parseInt(e.target.item(0).arrId)]).hasOwnProperty('label') ) {
        var label = JSON.parse(self.data.fStrJSON[parseInt(e.target.item(0).arrId)])['label'];
    }
    else {
        var label = JSON.parse(self.data.fStrJSON[parseInt(e.target.item(0).arrId)])['feature'];
    }
    
    var s1 =  seg.split("..")[1];
    if( s1.indexOf(')') !== -1 ) {
        s1 = s1.split(")")[0];
    }

    var s2 =  seg.split("..")[0];
    if( s2.indexOf('(') !== -1 ) {
        s2 = s2.split("(")[1];
    }

    //var noBases = parseInt(seg.split("..")[1]) - parseInt(seg.split("..")[0]);
    var noBases = s1 - s2;
    if (!$('#'+self.parentDiv+'_featureDetails').length) {
        var displayValue = label +"<br>"+seg+" = "+ noBases + " bp";
        $('#'+self.parentDiv+'_display').append("<div id='"+self.parentDiv+"_featureDetails' class='arxD_showDetails'>"+displayValue+"</div>");
    }
    self.moveFeatureDetails(e);
}

ArxDraw.prototype.moveFeatureDetails = function(e) {
    var self = this;
    var codes = self.getMouse(e);
    var coords = ({'top':codes[1]+10,'left': (codes[0] - $('#'+self.parentDiv+'_display').offset().left) });
    if (coords != ""){
        var top = coords.top;
        var left = coords.left;
        $('#'+self.parentDiv+'_featureDetails').css({top: top, left: left});
    }
    $("#"+self.parentDiv+"_featureDetails").delay(5000).hide(5);
}

ArxDraw.prototype.highLight = function(i, s, e, c, arrayPush) {
    var self = this;
    if (i >= 0) {
        var ss = "";
        for ( var p = s; p <= e; p++ ){
            ss = ss + '"'+p+'": {"textBackgroundColor": "'+c+'"}';
            if ( p < e ) {
                ss = ss + ",";
            }
        }
        if (arrayPush == true) {
            self.highLightStylesArray.push(i+"#"+ss.replace(/green/g, "white"));
        }
        self.applyHighLight(i,ss);
    }
}

ArxDraw.prototype.applyFeatureHighLight = function(ids, visible) {
    var self = this;
    var highLightItemIds = String(ids).split("#");
    //console.log("highLightItemIds :["+highLightItemIds+"], "+startId2+", "+endId2);
    //id starts from 2 because the first 2 values are startId2 and endId2
    if (highLightItemIds[0] == self.startId2 && highLightItemIds[1] == self.endId2) {
        for (var i = 2; i < highLightItemIds.length; i ++ ) {
            self.canvas2.item(parseInt(highLightItemIds[i])).visible = visible;
        }
        self.canvas2.renderAll();
    }
}


ArxDraw.prototype.applyHighLight = function(i,sss){
    var self = this;
    ss = JSON.parse('{"0":{' + sss + '}}');
    var obj = self.canvas2.item(parseInt(i)+1);
    
    if (!obj) return;
    obj.set('styles', ss);
            
    var obj2 = self.canvas2.item(parseInt(i)+1+1);
    if (!obj2) return;
    obj2.set('styles', ss);
    self.canvas2.renderAll();
}


ArxDraw.prototype.getMouse = function(e) {
    return [e.e.clientX, e.e.clientY];
}


ArxDraw.prototype.showDetails = function(e) {
    var self = this;
    if (!$('#'+self.parentDiv+'_showFeatureDetails').length) {
        $('#'+self.parentDiv+'_display').append("<div id='"+self.parentDiv+"_showFeatureDetails' class='arxD_showDetails'>"+e.target.item(0).fName+"<br>"+e.target.item(0).sigment+ " </div>");
    }
    //console.log("canvas3 showDetails with test: "+ e.target.item(0).fName +", "+ e.target.item(0).sigment);
    self.moveDetails(e, self.parentDiv+"_showFeatureDetails");
}

ArxDraw.prototype.showRestrictionEnzymeDetails = function(e) {
    var self = this;
    if (!$('#'+self.parentDiv+'_showRestrictionEnzymeDetails').length) {
        var seqCut = "";
        var cut = e.target.item(1).cut;
        seqCut = cut.replace("^", "<sup>^</sup>")
        seqCut = seqCut +"<br>";
        
        compSeq = self.getComplementaryStr(e.target.item(1).sequence) ;
        
        seqCut = seqCut + compSeq.slice( 0, (e.target.item(1).sequence.length - e.target.item(1).cutPosition) ) + "<sub>^</sub>" + compSeq.slice((e.target.item(1).sequence.length - e.target.item(1).cutPosition));
        
        $('#'+self.parentDiv+'_display').append("<div id='"+self.parentDiv+"_showRestrictionEnzymeDetails' class='arxD_showDetails'>"+e.target.item(1).text +"<br>"+"<div style='line-height: 18px; '>"+ seqCut +"</div></div>");
    }
    self.moveDetails(e, self.parentDiv+"_showRestrictionEnzymeDetails");
}

ArxDraw.prototype.moveDetails = function(e, id) {
    var self = this;
    if (self.data.isPlasmid == true || self.data.isPlasmid == 1) {
        var codes = self.getMouse(e);
        var coords = ({'top':codes[1]-10, 'left': (codes[0] - $('#'+self.parentDiv+'_display').offset().left) });
    }
    else {
        var codes = self.getMouse(e);
        var coords = ({'top':codes[1]+10,'left':codes[0]+10});
        var coords = ({'top':self.canvas3.item(0).top + 160, 'left':codes[0]+10});
    }
    if (coords != ""){
        var top = coords.top;
        var left = coords.left;
        $('#' + id).show();
        $('#' + id).css({top: top, left: left});
    }
    //console.log("canvas3 coords: "+coords.top +", "+coords.left);
    $('#' + id).delay(5000).hide(5);
}



ArxDraw.prototype.showDetailsC4 = function(e) {
    var self = this;
    if (!$('#'+self.parentDiv+'_showFeatureDetailsC4').length) {
        $('#'+self.parentDiv+'_display').append("<div id='"+self.parentDiv+"_showFeatureDetailsC4' class='arxD_showDetails'>"+e.target.item(0).fName+"<br>"+e.target.item(0).sigment+"</div>");
    }
    self.moveDetailsC4(e, self.parentDiv+"_showFeatureDetailsC4");
}

ArxDraw.prototype.showRestrictionEnzymeDetailsC4 = function(e) {
    var self = this;
    if (!$('#'+self.parentDiv+'_showRestrictionEnzymeDetailsC4').length) {
        var seqCut = "";
        var cut = e.target.item(1).cut;
        seqCut = cut.replace("^", "<sup>^</sup>")
        seqCut = seqCut +"<br>";
        
        compSeq = self.getComplementaryStr(e.target.item(1).sequence) ;
        
        seqCut = seqCut + compSeq.slice( 0, (e.target.item(1).sequence.length - e.target.item(1).cutPosition) ) + "<sub>^</sub>" + compSeq.slice((e.target.item(1).sequence.length - e.target.item(1).cutPosition));
        
        $('#'+self.parentDiv+'_display').append("<div id='"+self.parentDiv+"_showRestrictionEnzymeDetailsC4' class='arxD_showDetails'>"+e.target.item(1).text +"<br>"+"<div style='line-height: 18px; '>"+ seqCut +"</div></div>");
    }
    self.moveDetailsC4(e, self.parentDiv+"_showRestrictionEnzymeDetailsC4");
}

ArxDraw.prototype.moveDetailsC4 = function(e, id) {
    var self = this;
    var codes = self.getMouse(e);
    
    var coords = ({ 'top':codes[1]+10 , 'left': (codes[0] - $('#'+self.parentDiv+'_display').offset().left) });
    
    if (coords != ""){
        var top = coords.top;
        var left = coords.left;
        console.log("Top:"+top+", Left:"+left);
        $('#' + id).show();
        $('#' + id).css({top: top, left: left});
    }
    $('#' + id).delay(5000).hide(5);
}


ArxDraw.prototype.getObjPosition = function(e) {
    var self = this;
    if (e.type == "group") {
        var bRect = e.getBoundingRect();
        var offset = canvas.calcOffset();
        if (e.item(0).type == "polygon") {
            var left = offset._offset.left + bRect.left + bRect.width + 5;
            var top = offset._offset.top + bRect.top + bRect.height/2 - 10;
            return {left: left, top: top};
        }
        else if (e.item(0).type == "rect" || e.item(0).type == "circle") {
            var left = offset._offset.left + bRect.left + bRect.width/2 - 2;
            var top = offset._offset.top + bRect.top - bRect.height/2;
            return{left: left, top: top};
        }
    }
    else {return("");}
}


ArxDraw.prototype.postDraw = function(){
    //handles functions to be run after HTML is loaded
    //is called after HTML is loaded
    var self = this;
       
    startTime = new Date()/1000;
    //cannot read property 'msie' of undefined jquery - Following lines to fix the error while loading..
    jQuery.browser = {};
    (function () {
        jQuery.browser.msie = false;
        jQuery.browser.version = 0;
        if (navigator.userAgent.match(/MSIE ([0-9]+)\./)) {
            jQuery.browser.msie = true;
            jQuery.browser.version = RegExp.$1;
        }
    })();

    //Define the canvases
    self.canvas1 = new fabric.Canvas(self.parentDiv+'_c1');
    self.canvas2 = new fabric.Canvas(self.parentDiv+'_c2');
    self.canvas3 = new fabric.Canvas(self.parentDiv+'_c3');
    self.canvas4 = new fabric.Canvas(self.parentDiv+'_c4');

    self.canvas1.selection = false;
    self.canvas1.renderOnAddRemove = false;
    self.canvas1.renderOnAddition = false;
    self.canvas1.stateful = false;

    self.canvas2.selection = false;
    self.canvas2.renderOnAddRemove = false;
    self.canvas2.renderOnAddition = false;
    self.canvas2.stateful = false;

    self.canvas3.selection = false;
    self.canvas3.renderOnAddition = false;
    self.canvas3.renderOnAddRemove = false;
    self.canvas3.stateful = false;
    self.canvas3.hoverCursor = 'pointer';

    self.canvas4.selection = false;
    self.canvas4.renderOnAddition = false;
    self.canvas4.renderOnAddRemove = false;
    self.canvas4.stateful = false;

    self.offsetArray = self.makeArrayOffsets();
    //console.log("self.offsetArray: "+ self.offsetArray);
    
    self.canvas1.setWidth($("#"+self.parentDiv+"_arxDrawContainer").width());
    self.canvas1.renderAll();
    
    console.log("Canvas3 HEIGHT & WIDTH before: "+self.canvas3.getWidth() +", "+ self.canvas3.getHeight() +", "+ $("#"+self.parentDiv+'_wrapper1').height() );
    self.canvas3.setWidth( (parseInt(window.innerWidth) * 0.8) - 400);
    self.canvas3.setHeight( (parseInt(window.innerHeight) * 0.9) );
    self.canvas3.renderAll();

    
    //$("#"+self.parentDiv+"_FView").height($( window ).height() * 0.55);
    //$("#"+self.parentDiv+"_FView").css({'height': '540px'});
    console.log("FEATURES VIEW height: "+ $("#"+self.parentDiv+"_FView").height() );
    /** Adding the horizontal scroll bar to the sequence view **/
    $("#"+self.parentDiv+"_sequenceViewCanvas").width( (self.offsetArray[100] + (100))+'px' );
    self.canvas2.setWidth( self.offsetArray[self.wordsInALine] + 100);
    self.canvas2.renderAll();

    

    //Initialise the progressbar
    self.progressBar(0, "Starting..", $('#'+self.parentDiv+'_progressBar'));

    $("#"+self.parentDiv+"_wrapper2").mCustomScrollbar( {
        axis:"xy",
        theme:"3d",
        scrollbarPosition:"inside",
        alwaysShowScrollbar:2,
        scrollInertia: 0,
        advanced: {
            autoExpandHorizontalScroll: true,
            updateOnContentResize: true,
            updateOnSelectorChange: true,
        },
        callbacks:{
            
            whileScrolling: function(){
                //console.log("LINEAR SCROLL: "+ this.mcs.top );
            },
            onScroll: function() {
                $("#"+self.parentDiv+"_wrapper2").mCustomScrollbar("scrollTo", { y: self.linearDraggerTop});
                console.log("LINEAR SCROLL: "+ this.mcs.bottom +", "+ this.mcs.top +", "+ this.mcs.left +", "+ this.mcs.right);
            }
        }
    } );
    
    $("#"+self.parentDiv+"_wrapperXY").mCustomScrollbar({
        axis:"xy",
        theme:"3d",
        scrollbarPosition:"inside",
        alwaysShowScrollbar:2,
        scrollInertia: 0,
        advanced:{
            autoScrollOnFocus: false,
            //autoDraggerLength: true,
            mouseWheel: { enable: true },
            //mouseWheel: { axis: "x" },
            mouseWheel: { axis: "y" },
        },
        callbacks:{
            
            whileScrolling: function(){
                if (this.mcs.direction == "y") {
                    if (self.gotoBasePairScroll != true && self.autoScroll != true) {
                        if ( (($("#"+self.parentDiv+"_canvasPushDiv").height() + $("#"+self.parentDiv+"_c2").height() - (this.mcs.content.parent().height()/3)) < Math.abs(this.mcs.top) ) || ( $("#"+self.parentDiv+"_canvasPushDiv").height() > Math.abs(this.mcs.top) ) ) {
                            console.log("wrapperXY before start spinner");
                            self.startSpinner();
                        }
                        else  {
                            self.stopSpinner();
                        }
                    }
                }
            },
            onScroll: function(){
                if (this.mcs.direction == "y") {
                    if (self.gotoBasePairScroll != true && self.autoScroll != true) {
                        
                        if ( ($("#"+self.parentDiv+"_canvasPushDiv").height() + $("#"+self.parentDiv+"_c2").height() - (this.mcs.content.parent().height()/3)) < Math.abs(this.mcs.top) || ( $("#"+self.parentDiv+"_canvasPushDiv").height() > Math.abs(this.mcs.top) ) ) {
                            var text = self.canvas2.item(2).totalText;
                            var noOfRows = Math.floor( parseInt((this.mcs.content.parent().height() * self.fText.length)/this.mcs.content.height()));
                            
                            self.startId2 = Math.floor( parseInt((Math.abs(this.mcs.top) * self.fText.length)/this.mcs.content.height()) ) - noOfRows ;
                            self.endId2 = self.startId2 + 20;
                            if (self.startId2 < 0) {
                                self.startId2 = 0;
                                self.endId2 = 20;
                            }
                            if (self.fText.length < self.endId2) {
                                self.endId2 = self.fText.length;
                                self.startId2 = self.endId2 - 20;
                            }
                            
                            self.wrapCanvasText(self.startId2, self.endId2, text, 1, false);
                            //Calculate the 'arxD_canvasPushDiv' DIV height
                            var bottomTop = (this.mcs.content.height() * (self.startId2))/self.fText.length;
                            document.getElementById(self.parentDiv+"_canvasPushDiv").style.height = parseInt(bottomTop)+'px' ;
                            console.log("scroll down: "+self.startId2+", "+self.endId2+", "+bottomTop +", "+ document.getElementById(self.parentDiv+'_c2').height);
                        }
                        self.draggerTop = this.mcs.top;
                    }
                    else if (self.gotoBasePairScroll == true) { //moving the scroll bar without updating the canvas
                        self.gotoBasePairScroll = false;
                        self.stopSpinner();
                        return;
                    }
                    else if (self.autoScroll == true) {
                        self.autoScroll = false;
                        self.stopSpinner();
                        return;
                    }
                }

                if (self.autoScroll == true) {
                    self.autoScroll = false;
                    return;
                }
            },
        }
    });

$( "#"+self.parentDiv+"_rotationSlider" ).slider({
        value: 0,
        min: 0,
        max: 360,
        step: 10,
        slide: function( event, ui ) {
            $("#"+self.parentDiv+"_rotationSlider").find(".ui-slider-handle").text( ui.value +  "\xB0" );
            var newVal = $("#"+self.parentDiv+"_rotationSlider").slider("value");
            var zoom = parseInt( $("#"+self.parentDiv+"_zoomSlider").slider("value") );
            var prevRotation = self.canvas3.item(0).rotation;
            var val = newVal - parseInt(prevRotation);
            
            if (self.data.isPlasmid == 1) {
                //var L = ( $(".pageContent").width() - ( self.mappingRadius * $("#"+self.parentDiv+"_zoomSlider").slider("value") ) )/2 ;
                //var L = ($("#"+self.parentDiv+"_arxDrawContainer").width())/2;

                var L = (self.canvas3.getWidth())/2;
                self.canvas3.forEachObject(function(obj){
                    if (obj.id == 1111) { //Circle outside number markings
                        var angle1 = parseInt(obj.objAngle) + parseInt(val);
                        var coords = self.findCoordinates( L, (1.5 * self.mappingRadius), (0.9 * self.mappingRadius), angle1, $("#"+self.parentDiv+"_zoomSlider").slider("value") );
                        
                        var left1 = coords[0]; 
                        var top1 = coords[1]; 
                        
                        obj.setLeft(left1).setCoords();
                        obj.setTop(top1).setCoords();
                        obj.setAngle(angle1).setCoords();
                    }
                    else if (obj.id == 110011 ) { //Base pair info..
                        //Don't do anything
                    }
                    else if (obj.id == 200) { //Restriction enzymes
                        self.canvas3.remove(obj);
                    }
                    else { //Feature bands
                        obj.setAngle(val).setCoords();
                    }
                });
                //Draw the restriction enzymes
                if ( $("#"+self.parentDiv+"_showHideRE").text() == "Hide Enzymes" ) {
                    console.log("findCoordinates: "+ $("#"+self.parentDiv+"_zoomSlider").slider("value") +", "+ self.mappingRadius);
                    if ($("#"+self.parentDiv+"_zoomSlider").slider("value") != 1) {
                        var zoomRadius = Math.floor(self.mappingRadius * $("#"+self.parentDiv+"_zoomSlider").slider("value"));
                    }
                    else {
                        var zoomRadius = self.mappingRadius;
                    }
                    self.drawRECircularMap(zoomRadius, L, (self.canvas3.item(0).item(1).text), newVal, self.REmappingArray);
                }
                self.canvas3.renderAll();
            }
        },
        change: function(event, ui) {
            $("#"+self.parentDiv+"_rotationSlider").find(".ui-slider-handle").text( ui.value +  "\xB0" );
            var newVal = $("#"+self.parentDiv+"_rotationSlider").slider("value");
            var zoom = parseInt( $("#"+self.parentDiv+"_zoomSlider").slider("value") );
            var prevRotation = self.canvas3.item(0).rotation;
            var val = newVal - parseInt(prevRotation);
            
            if (self.data.isPlasmid == 1) {
                //var L = ( $(".pageContent").width() - ( self.mappingRadius * $("#"+self.parentDiv+"_zoomSlider").slider("value") ) )/2 ;
                //var L = ($("#"+self.parentDiv+"_arxDrawContainer").width())/2;

                var L = (self.canvas3.getWidth())/2;
                self.canvas3.forEachObject(function(obj){
                    if (obj.id == 1111) { //Circle outside number markings
                        var angle1 = parseInt(obj.objAngle) + parseInt(val);
                        var coords = self.findCoordinates( L, (1.5 * self.mappingRadius), (0.9 * self.mappingRadius), angle1, $("#"+self.parentDiv+"_zoomSlider").slider("value") );
                        
                        var left1 = coords[0]; 
                        var top1 = coords[1]; 
                        
                        obj.setLeft(left1).setCoords();
                        obj.setTop(top1).setCoords();
                        obj.setAngle(angle1).setCoords();
                    }
                    else if (obj.id == 110011 ) { //Base pair info..
                        //Don't do anything
                    }
                    else if (obj.id == 200) { //Restriction enzymes
                        self.canvas3.remove(obj);
                    }
                    else { //Feature bands
                        obj.setAngle(val).setCoords();
                    }
                });
                //Draw the restriction enzymes
                if ( $("#"+self.parentDiv+"_showHideRE").text() == "Hide Enzymes" ) {
                    console.log("findCoordinates: "+ $("#"+self.parentDiv+"_zoomSlider").slider("value") +", "+ self.mappingRadius);
                    if ($("#"+self.parentDiv+"_zoomSlider").slider("value") != 1) {
                        var zoomRadius = Math.floor(self.mappingRadius * $("#"+self.parentDiv+"_zoomSlider").slider("value"));
                    }
                    else {
                        var zoomRadius = self.mappingRadius;
                    }
                    self.drawRECircularMap(zoomRadius, L, (self.canvas3.item(0).item(1).text), newVal, self.REmappingArray);
                }
                self.canvas3.renderAll();
            }
        }
    });
    $("#"+self.parentDiv+"_rotationSlider").find(".ui-slider-handle").text( $("#"+self.parentDiv+"_rotationSlider").slider("value") +  "\xB0" );
    
    $( "#"+self.parentDiv+"_zoomSlider" ).slider({
        value: 1,
        min: 0.4,
        max: 2.0,
        step: 0.2,
        slide: function( event, ui ) {
            $("#"+self.parentDiv+"_zoomSlider").find(".ui-slider-handle").text( (ui.value * 100) +  "%" );
            var zVal = $("#"+self.parentDiv+"_zoomSlider").slider("value");
            var rVal = $("#"+self.parentDiv+"_rotationSlider").slider("value");
            totalBP = self.canvas3.item(0).item(1).text;
            console.log("ZOOM total BP: "+ totalBP);
            if (self.canvas3.getObjects().length > 0) {
                self.canvas3.clear();
                if (self.data.isPlasmid == 1) {
                    var zoomRadius = Math.floor(self.mappingRadius * $("#"+self.parentDiv+"_zoomSlider").slider("value"));
                    console.log("Zoom Slide: "+$("#"+self.parentDiv+"_rotationSlider").slider("value")+", "+$("#"+self.parentDiv+"_zoomSlider").slider("value")+", "+self.mappingRadius +", -------"+totalBP);
                    self.drawCircularMap(self.data.featuresInMapView, totalBP, zoomRadius, 1, self.data.displayName, self.data.basePairs, self.REmappingArray); //We are sending the zoomed radius so no need to send the zoom again - just send 1
                }
                self.canvas3.renderAll();
            }
        },
        change: function( event, ui ) {
            $("#"+self.parentDiv+"_zoomSlider").find(".ui-slider-handle").text( (ui.value * 100) +  "%" );
            var zVal = $("#"+self.parentDiv+"_zoomSlider").slider("value");
            var rVal = $("#"+self.parentDiv+"_rotationSlider").slider("value");
            totalBP = self.canvas3.item(0).item(1).text;
            if (self.canvas3.getObjects().length > 0) {
                self.canvas3.clear();
                if (self.data.isPlasmid == 1) {
                    var zoomRadius = Math.floor(self.mappingRadius * $("#"+self.parentDiv+"_zoomSlider").slider("value"));
                    console.log("Zoom Slide: "+$("#"+self.parentDiv+"_rotationSlider").slider("value")+", "+$("#"+self.parentDiv+"_zoomSlider").slider("value")+", "+self.mappingRadius +",========== "+totalBP);
                    self.drawCircularMap(self.data.featuresInMapView, totalBP, zoomRadius, 1, self.data.displayName, self.data.basePairs, self.REmappingArray); //We are sending the zoomed radius so no need to send the zoom again - just send 1
                }
                self.canvas3.renderAll();
            }
        }
    });
    $("#"+self.parentDiv+"_zoomSlider").find(".ui-slider-handle").text( ($("#"+self.parentDiv+"_zoomSlider").slider("value") * 100) +  "%" );
    
    
    $( "#"+self.parentDiv+"_linearZoomSlider" ).slider({
        value: 1,
        min: 0.4,
        max: 2.0,
        step: 0.2,
        slide: function( event, ui ) {
            //$( "#linearZoomVal" ).text( ui.value +  "%");
            $("#"+self.parentDiv+"_linearZoomSlider").find(".ui-slider-handle").text( (ui.value * 100) +  "%" );
            var z4Val = $("#"+self.parentDiv+"_linearZoomSlider").slider("value");
            totalBP = self.canvas4.item(0).item(1).text;
            if (self.canvas4.getObjects().length > 0) {
                self.canvas4.clear();
                
                var zoomWidth = Math.floor(self.mapWidth * z4Val);
                self.drawLinearMap(self.data.featuresInMapView, totalBP, zoomWidth, self.data.displayName, self.data.basePairs);
                //self.canvas4.setWidth( zoomWidth + 100 );
                self.canvas4.renderAll();
            }
        },
        change: function( event, ui ) {
            //$( "#linearZoomVal" ).text( ui.value +  "%");
            $("#"+self.parentDiv+"_linearZoomSlider").find(".ui-slider-handle").text( (ui.value * 100) +  "%" );
            var z4Val = $("#"+self.parentDiv+"_linearZoomSlider").slider("value");
            totalBP = self.canvas4.item(0).item(1).text;
            if (self.canvas4.getObjects().length > 0) {
                self.canvas4.clear();
                console.log("LINEAR ZOOM: "+ z4Val + "----------------------");
                var zoomWidth = Math.floor(self.mapWidth * z4Val);
                self.drawLinearMap(self.data.featuresInMapView, totalBP, zoomWidth, self.data.displayName, self.data.basePairs);
                //self.canvas4.setWidth( zoomWidth + 100 );
                self.canvas4.renderAll();
                console.log("LINEAR WIDTH: "+ self.canvas4.getWidth());
            }
        }
    });
    
    $("#"+self.parentDiv+"_linearZoomSlider").find(".ui-slider-handle").text( ($("#"+self.parentDiv+"_linearZoomSlider").slider("value") * 100) +  "%" );

    if((self.data.result).length > 0 && (self.data.displayName).length > 0 ) {
        console.log("RESULT FROM DB: "+ self.data.displayName)
        self.startSpinner();
        dropzone = $('#'+self.parentDiv+'_dragDrop');
        dropzone.remove();
                
        if (self.data.isPlasmid != true || self.data.isPlasmid != 1 || self.data.isPlasmid != "1") {
           /* $("#arxD_displayTabs li:eq(0)").hide();
            $('#arxD_mapView').remove();
            $('#arxD_sequenceView').show(); */
        }
        
        $('#'+self.parentDiv+'_topNavbar').hide();
        $('.arxD_menuButtonRight').show();
        $('#'+self.parentDiv+'_circularMap').show();
       
        self.data.featuresInMapView.sort( self.sort_by('startPos', false, parseInt) ); 
        self.findFMAOverlap_mapView(self.data.featuresInMapView);
        
        self.wrapCanvasText(0, 20, self.data.result, 1, true);
        
        $('#'+self.parentDiv+'_goToBasePair').val("");
        $('#'+self.parentDiv+'_basePairInfo').html( self.data.displayName + "&nbsp; &nbsp; &nbsp; &nbsp;" + self.data.basePairs +" bp" );
        $('#'+self.parentDiv+'_bases').html( self.data.basePairs );
                        
        self.allTranslations = self.getAllAmenoAcidTranslations(self.data.result, self.wordsInALine);
        self.allORFs = self.ORF(self.allTranslations);
        
        var noOfRows = Math.floor($("#"+self.parentDiv+"_middle").height()/20);
        self.displayFeatures(self.data.featuresInMapView, noOfRows);
        self.displayEnzymes(self.REmappingArray, noOfRows);
    }
    
    
};


ArxDraw.prototype.sort_by = function(field, reverse, primer){

    var key = primer ? 
    function(x) {return primer(x[field])} : 
    function(x) {return x[field]};

    reverse = !reverse ? 1 : -1;

    return function (a, b) {
        return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
    } 
}


ArxDraw.prototype.makeArrayOffsets = function(){
    var self = this;
    var ctx = self.canvas2.getContext();

    text1 = ("TTGATGTTCTGCAGACACCTGCAGGGCAGGGAAACTTGCTGGCAGCTCCTCCCAGCAGATCCCATTCGCATCTCCCAATCCTTGATAGATACAAGATCCACATCGTCCTTGTTTACTGTGG");
    text1 = text1.split("");
    var newText = "";
    var offsetArray1= [];
    
    var text = new fabric.Text("", { 
        left: 80, 
        top: 80, 
        fontFamily: 'Courier',
        fontSize: 16
    });
    self.canvas2.add(text);
    var bound = self.canvas2.item(0).getBoundingRect();
    
    offsetArray1.push(self.canvas2.item(0).left + bound.width);
    self.canvas2.item(0).remove();
        
    for (var q = 0; q < text1.length; q++){
        a = 80;
        b = 80;
        newText = newText + text1[q];
        
        var text = new fabric.Text(newText, { 
            left: a , 
            top: b , 
            fontFamily: 'Courier',
            fontSize: 16
        });
        self.canvas2.add(text);
        
        self.canvas2.renderAll();
        
        var bound = self.canvas2.item(0).getBoundingRect();
        
        offsetArray1.push(self.canvas2.item(0).left + bound.width);
        
        self.canvas2.item(0).remove();
    }
    return offsetArray1;
}



ArxDraw.prototype.findFMAOverlap_mapView = function(object) {
    var overLap = 10;
    console.log("OVERLAP function: "+overLap);
    //First row assign the overlap = 1 l< object.length
    if (object.length > 0) {
        object[0]['overLap'] = overLap;
        for (var l = 1; l< object.length; l++){
            var s = object[l]['startPos'];
            var e = object[l]['endPos'];
            var check = 0;
            
            for (var m = l-1; m >= 0; m--) {
                var fStart = object[m]['startPos'];
                var fEnd = object[m]['endPos'];
                if (parseInt(fEnd) > parseInt(s)) {
                    object[l]['overLap'] = object[m]['overLap'] + 1;
                    check = 1;
                }
                else if (parseInt(fEnd) < parseInt(s)) {
                    object[l]['overLap'] = object[m]['overLap'];
                }
                if (object[m]['overLap'] == 1 || check == 1) {
                    break;
                }
            }
        }
    }
}


ArxDraw.prototype.wrapCanvasText = function(startId2, endId2, t, id, drawMapView) {
    console.log("start sequence view: "+((new Date()/1000)-startTime));
    console.log("wrapCanvasText start and end: "+startId2+", "+endId2);
    var self = this;
    /** Clearing and resetting the values before drawing **/
    self.canvas2.clear();
    self.fText = [];
    by = ax = 80;
    var showComplementary = false;
    canvas2MouseClick = false;
    canvas2ClickId = '';
    $('#'+self.parentDiv+'_selectionInfo').html("");
    
    if (document.getElementById(self.parentDiv+'_showComplementary').checked) {
        showComplementary = true;
    }
    
    var words = t.replace(/(\r\n|\n|\\n|\\r)/gm, "");
    
    if ( self.data.basePairs == "" || typeof self.data.basePairs == 'undefined' || !self.data.basePairs ) {
        self.data.basePairs == words.length;
    }
    console.log("BASE PAIRS: "+ self.data.basePairs+", "+self.parentDiv);
    var currentLine = "";
    l = 0;
    k = 0;
    
    self.ribbonCompArray = [];
    self.bLW = [by]; // keep track of the spacing between the rows
    self.itemsBtwRow = [0]; // how many items present between each row
    self.amenoAcidIds = {}; // Ameno acid ids array
    var itemsInARow = [];
    
    while (l < words.length) {
        if (k < self.wordsInALine) { 
            currentLine += words[l].toUpperCase();
            k++;
            l++;
        } 
        else {
            self.fText.push(currentLine);
            currentLine = "";
            k = 0;
        }
    }
    
    if (currentLine != '') {
        self.fText.push(currentLine);
        currentLine = "";
    }
          
    if (self.fText.length < endId2){
        endId2 = self.fText.length;
    }
    
    if (startId2 < 1){
        startId2 = 0;
    }
    
    var howManyTranslations = $( 'input[name=arxD_translations]:checked' ).val() ;

    var translationType = $( 'input[name=arxD_aminoACid]:checked' ).val() ;
        
    self.REmappingArray = self.mapRestrictedEnzymes(words.toUpperCase());
    self.REmappingArray.sort(self.sort_by('startPos', false, parseInt));

    if (drawMapView) {
        if (self.data.isPlasmid == true || self.data.isPlasmid == 1) {
            self.drawCircularMap(self.data.featuresInMapView, words.length, self.mappingRadius, $("#"+self.parentDiv+"zoomSlider").slider("value"), self.data.displayName, self.data.basePairs);
            self.drawCircularMapC1(self.data.featuresInMapView, words.length, self.mappingRadius, $("#"+self.parentDiv+"zoomSlider").slider("value"), self.data.displayName, self.data.basePairs);
            console.log("finished drawCircularMap");
        }
        
        //Draw linear map by default
        self.drawLinearMap(self.data.featuresInMapView, words.length, self.mapWidth, self.data.displayName, self.data.basePairs, self.REmappingArray);
        
        console.log("finished drawLinearMap");
    }
    
    var ax2;
    var counter = 0;
    var itemCountBefore = 0;
    var itemCountAfter = 0;
    
    //Start drawing on sequence view
    for (var q = startId2; q < endId2; q++) {
    //for (var q = startId2; q < 2; q++) {        
        itemCountBefore = self.canvas2.getObjects().length;
        
        if (q < self.fText.length - 1) {
            ax2 = parseInt(self.offsetArray[self.wordsInALine]); //length of the dashed line
            self.fabric_guideLine(self.wordsInALine, q, by);
            counter++;
        } else {
            ax2 = parseInt(self.offsetArray[k]);
            self.fabric_guideLine(k, q, by);
            counter++;
        }
        
        if (id == 1) {
            self.fabric_TextBox(self.fText[q], 1, true, ax, by, t, self.fs);
            self.fabric_TextBox(self.getComplementaryStr(self.fText[q]), 2, showComplementary, ax, by+20, t, self.fs);
            self.ribbonCompArray.push(self.canvas2.getObjects().length);
            self.fabric_hDashedLine(ax, by + 20, ax2, by + 20, showComplementary, q, counter);
            self.ribbonCompArray.push(self.canvas2.getObjects().length);
        }
        else if (id == 2) {
            self.fabric_iText(self.getComplementaryStr(self.fText[q]), 1, true, ax, by, t, self.fs);
            self.fabric_iText(self.fText[q], 2, showComplementary, ax, by+20, t, self.fs);
            self.ribbonCompArray.push(self.canvas2.getObjects().length);
            self.fabric_hDashedLine(ax, by + 20, ax2, by + 20, showComplementary, q, counter);
            self.ribbonCompArray.push(self.canvas2.getObjects().length);
        }
        var fmaCount = 0;
        var fmaStrings = "";
        var fmaStringsArr = [];
        
        fmaStringsArr = self.findFMAObjects(self.data.featureMappingArray, "startRow", q);
        
        if (fmaStringsArr.length > 0 && $("#"+self.parentDiv+"_showHideFeatures").text() == 'Hide Features' ) {
            self.fabric_FMA(0, self.wordsInALine, by, fmaStringsArr.length, fmaStringsArr, startId2, endId2);
            fmaCount = fmaStringsArr[fmaStringsArr.length - 1]['overLap'];
        }
                        
        //var transOffset = by + self.breakLineWidth + fmaCount * 12 + (fmaCount + 1) * 10 ;
        if (fmaCount > 0 ) {
            var transOffset = by + (this.breakLineWidth * 1.5) +  (15 * parseInt(fmaCount - 1)) + (parseInt(fmaCount) * 12) + (this.breakLineWidth * 0.5) ;
        }
        else {
            var transOffset = by + (this.breakLineWidth * 1.5);
        }
                
        if (howManyTranslations != 0) {
            self.fabric_guideLine2(self.wordsInALine, q, transOffset, howManyTranslations); //7 + 3 + 7
            
            //arxD_translations
            var arxD_translations = "";
            var s1 = (q) * self.wordsInALine ;
            var s2 = (q + 1) * self.wordsInALine ;
            var p1 = [], p2 = [], p3 = [], m1 = [], m2 = []; m3 = [];

            if (howManyTranslations == 1 && self.allTranslations.length > 0) {
                plus1 = self.allTranslations[0];
                                        
                for (var t = 0; t < plus1.length; t++) {
                    if (s1 <= plus1[t][0] && s2 > plus1[t][0]){
                        p1.push(plus1[t]);
                    }
                }
            }
            else { 
                if ((howManyTranslations == 3 || howManyTranslations == 6) && self.allTranslations.length > 0) {
                    plus1 = self.allTranslations[0];
                    for (var t = 0; t < plus1.length; t++) {
                        if (s1 <= plus1[t][0] && s2 > plus1[t][0]){
                            p1.push(plus1[t]);
                        }
                    }
                    
                    plus2 = self.allTranslations[1];
                    for (var t = 0; t < plus2.length; t++) {
                        if (s1 <= plus2[t][0] && s2 > plus2[t][0]){
                            p2.push(plus2[t]);
                        }
                    }
                    
                    plus3 = self.allTranslations[2];
                    for (var t = 0; t < plus3.length; t++) {
                        if (s1 <= plus3[t][0] && s2 > plus3[t][0]){
                            p3.push(plus3[t]);
                        }
                    }
                }
                if (howManyTranslations == -3 || howManyTranslations == 6) {
                    minus1 = self.allTranslations[3];
                    for (var t = 0; t < minus1.length; t++) {
                        if (s1 <= minus1[t][0] && s2 > minus1[t][0]){
                            m1.push(minus1[t]);
                        }
                    }
                    
                    minus2 = self.allTranslations[4];
                    for (var t = 0; t < minus2.length; t++) {
                        if (s1 <= minus2[t][0] && s2 > minus2[t][0]){
                            m2.push(minus2[t]);
                        }
                    }
                    
                    minus3 = self.allTranslations[5];
                    for (var t = 0; t < minus3.length; t++) {
                        if (s1 <= minus3[t][0] && s2 > minus3[t][0]){
                            m3.push(minus3[t]);
                        }
                    }
                }
            }
            //console.log("p1: "+ p1);
            self.fabric_amenoAcidTranslations(p1, p2, p3, m1, m2, m3, q, howManyTranslations, transOffset, self.wordsInALine, by, translationType);
        }
        
        if ( Math.abs(howManyTranslations) > 0 ) {
            var transWidth = Math.abs(howManyTranslations) * 12 + (Math.abs(howManyTranslations) - 1 ) * 10 + self.breakLineWidth * 0.5;
        }
        else {
            var transWidth = 0;
        }
        
        by = transOffset + transWidth ;
        self.bLW.push(by);

        itemCountAfter = self.canvas2.getObjects().length;
        self.itemsBtwRow.push(itemCountAfter);
    }
    
    if ( $("#"+self.parentDiv+"_showHideRE").text() == "Hide Enzymes" ) { //Show or hide Restriction Enzymes
        self.displayREMapping(self.REmappingArray, self.wordsInALine, ax, ax, self.fs, self.bLW, self.itemsBtwRow);
    }
    
    if (howManyTranslations != 0) {
        var s1 = (startId2) * self.wordsInALine ;
        var s2 = (endId2) * self.wordsInALine ;
        var o1 = [], o2 = [], o3 = [], o4 = [], o5 = [], o6 = [];
        
        if (howManyTranslations == 1 && typeof self.allORFs[0] != 'undefined') {
            orf1 = self.allORFs[0];
            for (var t = 0; t < orf1.length; t++) {
                if ( (s1 <= orf1[t]['startPos'] && s2 > orf1[t]['endPos']) || (s1 > orf1[t]['startPos'] && s2 > orf1[t]['endPos']) || (s1 <= orf1[t]['startPos'] && s2 < orf1[t]['endPos']) || (s1 > orf1[t]['startPos'] && s2 < orf1[t]['endPos'])){
                    o1.push(orf1[t]);
                }
            }
        }
        else { 
            if (howManyTranslations == 3 || howManyTranslations == 6) {
                orf1 = self.allORFs[0];
                for (var t = 0; t < orf1.length; t++) {
                    if ( (s1 <= orf1[t]['startPos'] && s2 > orf1[t]['endPos']) || (s1 > orf1[t]['startPos'] && s2 > orf1[t]['endPos']) || (s1 <= orf1[t]['startPos'] && s2 < orf1[t]['endPos']) || (s1 > orf1[t]['startPos'] && s2 < orf1[t]['endPos'])){
                        o1.push(orf1[t]);
                    }
                }
                
                orf2 = self.allORFs[1];
                for (var t = 0; t < orf2.length; t++) {
                    if ( (s1 <= orf2[t]['startPos'] && s2 > orf2[t]['endPos']) || (s1 > orf2[t]['startPos'] && s2 > orf2[t]['endPos']) || (s1 <= orf2[t]['startPos'] && s2 < orf2[t]['endPos']) || (s1 > orf2[t]['startPos'] && s2 < orf2[t]['endPos']) ){
                        o2.push(orf2[t]);
                    }
                }
                
                orf3 = self.allORFs[2];
                for (var t = 0; t < orf3.length; t++) {
                    if ( (s1 <= orf3[t]['startPos'] && s2 > orf3[t]['endPos']) || (s1 > orf3[t]['startPos'] && s2 > orf3[t]['endPos']) || (s1 <= orf3[t]['startPos'] && s2 < orf3[t]['endPos']) || (s1 > orf3[t]['startPos'] && s2 < orf3[t]['endPos'])){
                        o3.push(orf3[t]);
                    }
                }
            }
            if (howManyTranslations == -3 || howManyTranslations == 6) {
                orf4 = self.allORFs[3];
                for (var t = 0; t < orf4.length; t++) {
                    if ( (s1 <= orf4[t]['startPos'] && s2 > orf4[t]['endPos']) || (s1 > orf4[t]['startPos'] && s2 > orf4[t]['endPos']) || (s1 <= orf4[t]['startPos'] && s2 < orf4[t]['endPos']) || (s1 > orf4[t]['startPos'] && s2 < orf4[t]['endPos'])){
                        o4.push(orf4[t]);
                    }
                }
                
                orf5 = self.allORFs[4];
                for (var t = 0; t < orf5.length; t++) {
                    if ( (s1 <= orf5[t]['startPos'] && s2 > orf5[t]['endPos']) || (s1 > orf5[t]['startPos'] && s2 > orf5[t]['endPos']) || (s1 <= orf5[t]['startPos'] && s2 < orf5[t]['endPos']) || (s1 > orf5[t]['startPos'] && s2 < orf5[t]['endPos'])){
                        o5.push(orf5[t]);
                    }
                }
                
                orf6 = self.allORFs[5];
                for (var t = 0; t < orf6.length; t++) {
                    if ( (s1 <= orf6[t]['startPos'] && s2 > orf6[t]['endPos']) || (s1 > orf6[t]['startPos'] && s2 > orf6[t]['endPos']) || (s1 <= orf6[t]['startPos'] && s2 < orf6[t]['endPos']) || (s1 > orf6[t]['startPos'] && s2 < orf6[t]['endPos'])){
                        o6.push(orf6[t]);
                    }
                }
            }
        }
        console.log("fabric_ORFs: ["+ o1.length +"], ["+ o2.length +"], ["+ o3.length +"], ["+ o4.length +"], ["+ o5.length +"], ["+ o6.length +"]");
        self.fabric_ORFs(o1, o2, o3, o4, o5, o6, howManyTranslations, self.transOffset, self.wordsInALine, by, self.bLW);
    }
    self.canvas2.setHeight(by);
    
    var totalCanvasHeight = (self.fText.length * by)/(endId2 - startId2);
    
    if ( startId2 == 0 ){
        document.getElementById(self.parentDiv+'_sequenceViewCanvas').style.height = totalCanvasHeight+'px';
        document.getElementById(self.parentDiv+'_canvasPushDiv').style.height = '1px';
    }
    
    self.canvas2.renderAll();
    console.log("Finish sequence view: "+((new Date()/1000)-startTime));
    self.stopSpinner();
}


/** Guide line with markings in between ameno acid translations **/
ArxDraw.prototype.fabric_guideLine2 = function(n, q, offSet, tran) {
    var self = this;
    var check = 0;
    if (tran == 3) {
        var y = offSet + (3 * 15) + (1 * 5);
    }
    else if (tran == 1) {
        var y = offSet + (1 * 15) + (1 * 5);
    }
    else if (tran == -3) {
        var y = offSet + (1 * 5);
    }
    else if (tran == 6) {
        var y = offSet + (3 * 15) + (1 * 5);
    }
    //y = y - 20;
    
    var line1 = new fabric.Line([self.offsetArray[0], y, self.offsetArray[n], y], {
        stroke: 'green',
        strokeWidth: 1,
        selectable: false,
    });
    
    var line2 = new fabric.Line([self.offsetArray[0], y + 3, self.offsetArray[n], y + 3], {
        stroke: 'green',
        strokeWidth: 1,
        selectable: false,
    });
    
    if (tran == 1 || tran == 3 || tran == 6){
        var group = new fabric.Group(); 
        group.add(line1); 
        
        for (var j=0; j < n+1; j++){
            var y1 = y - 3;
            var y2 = y;
            
            if (check == 5) {
                y1 = y - 5;
            }
            else if (check == 10) {
                y1 = y - 7;
                check = 0;
            }
            else if (check == 0) {
                y1 = y - 7;
            }
            check = check + 1;
            
            group.add(new fabric.Line([self.offsetArray[j], y1, self.offsetArray[j], y2], {
                stroke: 'green',
                strokeWidth: 1,
                selectable: false,
            }));
        }
        
        self.canvas2.add(group);
    }
    
    if (tran == -3 || tran == 6){
        var group1 = new fabric.Group(); 
        group1.add(line2); 
        
        check = 0;
        for (var j=0; j < n+1; j++){
            var y1 = y + 3;
            var y2 = y + 6;
            
            if (check == 5) {
                y2 = y + 8;
            }
            else if (check == 10) {
                y2 = y + 10;
                check = 0;
            }
            else if (check == 0) {
                y2 = y + 10;
            }
            check = check + 1;
            group1.add(new fabric.Line([self.offsetArray[j], y1, self.offsetArray[j], y2], {
                stroke: 'green',
                strokeWidth: 1,
                selectable: false,
            }));
        }
        
        self.canvas2.add(group1);
    }
}


ArxDraw.prototype.getComplementaryStr = function(hStr) {
    var s = "";
    for (var x = 0 ; x < hStr.length ; x++) {
        if (hStr[x] == "A") {
            s = s + "T";
        }
        else if (hStr[x] == "C") {
            s = s + "G";
        }
        else if (hStr[x] == "G") {
            s = s + "C";
        }
        else if (hStr[x] == "T") {
            s = s + "A";
        }
        else if (hStr[x] == "\n") {
            s = s + "\n";
        }
        else if (hStr[x] == String.fromCharCode(8201)) {
            s = s + String.fromCharCode(8201);
        }
    }
    return s;
}

ArxDraw.prototype.displayREMapping = function(mappingArray, words, a, b, fontSize, lineBreak, itemsBtwRow){
    var self = this;
    console.log("displayREMapping - inside display mapping: "+self.startId2+", "+ self.endId2+", "+ mappingArray.length);
    //[1816-1822#Test#ATTAAG#1#CCC^GGG#blunt]
    console.log("displayREMapping: "+lineBreak);
    for (var j = 0; j <mappingArray.length ; j++){
        console.log("RE MAPPING: "+ JSON.stringify(mappingArray[j]));
        var startPos = mappingArray[j]['startPos'];
        var endPos = mappingArray[j]['endPos'];
        var getTheStartRow = Math.floor(parseInt(startPos)/parseInt(words));
        var checkEndPosIsLastLetter = parseInt(endPos)/parseInt(words);
        var getTheEndRow = Math.floor(parseInt(endPos)/parseInt(words));
        
        if ( (getTheStartRow == self.startId2 || getTheStartRow >= self.startId2) && getTheStartRow < self.endId2 ){
            
            if (getTheStartRow == getTheEndRow || checkEndPosIsLastLetter == getTheEndRow) {
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow; 
                var enzyme = mappingArray[j]['enzyme'];
                var sequence = mappingArray[j]['sequence'];
                var getTheEndPos = getTheStartPos + sequence.length;
                
                var cutStartPos = mappingArray[j]['cut'].indexOf("^");
                var cutEndPos = mappingArray[j]['cut'].length - cutStartPos - 1;
                var cutType = mappingArray[j]['cutType'];
                
                var x1 = self.offsetArray[getTheStartPos];
                var x2 = self.offsetArray[getTheEndPos];
                var y1 = lineBreak[getTheStartRow - self.startId2];
                var n =  mappingArray[j]['overLap'];
                
                var mappingInfo = getTheStartRow+"#"+getTheStartRow+"#"+getTheStartPos+"#"+getTheEndPos+"#"+getTheStartRow+"-"+cutStartPos+"#"+getTheStartRow+"-"+cutEndPos+"#"+cutType+"#"+lineBreak+"#"+itemsBtwRow;
                console.log("REMapping :"+ y1);
                self.drawMapping(x1, y1, x2, y1, a, b, enzyme, n, mappingInfo);
            }
            else { // The enzyme sequence broken between two lines
            
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow;
                var seqBreak1 = self.wordsInALine;
                var seqBreak2 = 0;
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                var enzyme = mappingArray[j]['enzyme'];
                
                var cutStartPos = mappingArray[j]['cut'].indexOf("^");
                var cutEndPos = mappingArray[j]['cut'].length - cutStartPos - 1;
                var cutEndPos1;
                
                console.log("ENZYMES CUT END POSITION before: " + getTheStartPos +", " + cutStartPos + ", " + getTheEndPos +", "+ cutEndPos);

                if (parseInt(cutStartPos) < (seqBreak1 - getTheStartPos) ) {
                    var cutStartRow = parseInt(getTheStartRow);
                }
                else{
                    var cutStartRow = parseInt(getTheEndRow);
                    cutStartPos = cutStartPos - (self.wordsInALine - getTheStartPos);
                }
                
                if (parseInt(cutEndPos) <= (seqBreak1 - getTheStartPos) ) {
                    var cutEndRow = parseInt(getTheStartRow);
                    cutEndPos1 = cutEndPos;
                }
                else{
                    var cutEndRow = parseInt(getTheEndRow);
                    console.log(self.wordsInALine +", "+ getTheStartPos +", "+ getTheEndPos +", "+ cutEndPos);
                    cutEndPos1 = cutEndPos - (self.wordsInALine - getTheStartPos) ;
                }

                console.log("ENZYMES CUT END POSITION after: " + getTheStartPos +", " + cutStartPos + ", " + getTheEndPos +", "+ cutEndPos1);
                
                var cutType = mappingArray[j]['cutType'];
                
                var x1 = self.offsetArray[getTheStartPos];
                var x2 = self.offsetArray[parseInt(words)];
                var x3 = self.offsetArray[0];
                var x4 = self.offsetArray[getTheEndPos];
                var y1 = lineBreak[getTheStartRow - self.startId2];
                var y2 = lineBreak[getTheEndRow - self.startId2];
                var n  = mappingArray[j]['overLap'];
                var mappingInfo = getTheStartRow+ "#" +getTheEndRow+ "#" +getTheStartPos+ "#" +getTheEndPos+ "#" +cutStartRow+ "-" +cutStartPos+ "#" +cutEndRow+ "-" +cutEndPos1+ "#" +cutType+ "#" +lineBreak+ "#" +itemsBtwRow;
                
                self.drawBreakMapping(x1, x2, x3, x4, y1, y2, a, b, enzyme, n, mappingInfo);
            }
        }
    }
}


ArxDraw.prototype.mapRestrictedEnzymes = function(mList){
    var self = this;
    objRestEnz = JSON.parse(restrictedEnzymes);
    var reArray = [];
    
    for(var i = 0; i < objRestEnz.length; i++) {
        var obj = objRestEnz[i];
        self.mapRE(obj.Sequence, obj.Enzyme, mList, reArray, i, obj.Cut, obj.CutType, obj.CutPosition);
    }
    return reArray;
}

ArxDraw.prototype.mapRE = function(sequence, enzyme, mList, reArray, i, cut, cutType, cutPosition) {
    var startIndex = 0;
    var seqLen = sequence.length;
    var index;
    while ((index = mList.indexOf(sequence, startIndex)) > -1) {
        startIndex = index + seqLen;
        var overLap = 1;
        if (i > 1) {
            for (var j = 0; j <reArray.length ; j++) {
                var overLapPos = reArray[j]['overLap'];
                var startPos = reArray[j]['startPos'];
                var endPos = reArray[j]['endPos'];
                if (index > startPos && index < endPos) {
                    if (overLap < (parseInt(overLapPos) + 1)) {
                       overLap = parseInt(overLapPos) + 1; 
                    }
                }
                if (startIndex > startPos && startIndex < endPos) {
                    if (overLap < (parseInt(overLapPos) + 1)) {
                       overLap = parseInt(overLapPos) + 1; 
                    }
                }
            }
        }
        var reArr = { 'startPos' : index, 'endPos' : startIndex, 'enzyme' : enzyme, 'sequence' : sequence, 'overLap' : overLap, 'cut' : cut,  'cutType' : cutType,  'cutPosition' : cutPosition };
        reArray.push(reArr);
    }
}


ArxDraw.prototype.drawCircularMapC1 = function(fStrJSON, totalBP, r, zoom, displayName, basePairs){
    var self = this;
    //REmappingArray -- {"startPos":2611,"endPos":2617,"enzyme":"BamH1","sequence":"GGATCC","overLap":1,"cut":"G^GATCC","cutType":"sticky","cutPosition":2}
    var rAng = 0;
    self.canvas1.clear();
    //Dividing the outer circle into 9 parts and finding that close to 1000..
    var markOuterCircle = [50, 60, 70, 80, 90, 100, 120, 140, 160, 180, 200, 225, 250, 275, 300, 325, 350, 375, 400, 450, 500, 550, 600, 650, 700, 800, 900, 1000, 1200, 1300, 1500, 1800, 2000, 2200, 2500, 2700, 3000, 3200, 3500, 3700, 3900, 4000, 4200, 4300, 4500, 4700, 5000, 6000, 7500, 10000, 12000, 15000, 16000, 18000, 20000, 22000, 25000, 27500, 30000, 32000, 35000, 37000, 40000];
    target = Math.abs(parseInt(totalBP) / 9);
    zoom = 1;
    
    r = (parseInt(r) * zoom);
    
    if ( !displayName ) {
        displayName = "";
    }
    if ( !basePairs ) {
        basePairs = "";
    }
    
    //var L = ($(self.window).width() - r)/2;
    
    var L = ($("#"+self.parentDiv+"_arxDrawContainer").width())/2;
    
    var iTextName = new fabric.IText(displayName, { 
        fontFamily: 'Courier', 
        left: L,
        top: 1.5 * r,
        originX: 'center', 
        originY: 'center',
        fontSize: 20,
        visible: true,
        fill: 'black'
    });
    var iTextBP = new fabric.IText(basePairs.toString()+ " bp", { 
        fontFamily: 'Courier', 
        left: L,
        top: 1.5 * r + 20,
        originX: 'center', 
        originY: 'center',
        fontSize: 16,
        visible: true,
        fill: 'black'
    });
    
    var name = new fabric.Group([ iTextName, iTextBP], {
        id: 110011,
        selectable: false,
    });
    
    //to add the custom variable to the IText
    fabric.Group.prototype.toObject = (function(toObject) {
        return function() {
            return fabric.util.object.extend(toObject.call(this), {
                rotation: this.rotation,
                zoom: this.zoom
            });
        };
    })(fabric.Group.prototype.toObject);
    
    name.rotation = rAng;
    name.zoom = zoom;
    name.async = true;
    
    self.canvas1.add(name);

    for (var k=1; k<markOuterCircle.length; k++) {
        // As soon as a number bigger than target is found, return the previous or current
        if (parseInt(markOuterCircle[k]) > target) {
            var p = markOuterCircle[k-1];
            var c = markOuterCircle[k];
            var num = Math.abs( p-target ) < Math.abs( c-target ) ? p : c;
            break;
        }
    }

    if (num == ""){
        var num = markOuterCircle[markOuterCircle.length-1];
    }
    
    var markAngle = ((2 * parseInt(num))/ parseInt(totalBP));
    
    var circle = new fabric.Circle({
        id: totalBP,
        radius: r,
        left: L,
        top: 1.5 * r,
        originX: 'center', 
        originY: 'center',
        stroke: '#000',
        strokeWidth: 2,
        fill: '',
        selectable: false,
    });

    var circle1 = new fabric.Circle({
        id: 2,
        radius: r - 6,
        left: L,
        top: 1.5 * r,
        originX: 'center', 
        originY: 'center',
        stroke: '#000',
        strokeWidth: 2,
        fill:'',
        selectable: false,
    });
    
    self.canvas1.add(circle, circle1);

    for (var j = 0; j < 9; j++){
        var startAngle = Math.PI * (1.5 + (parseFloat(markAngle) * j) + (parseInt(rAng)*2/360) );
        var endAngle = Math.PI * ((1.5 + (parseFloat(markAngle) *j))+ (parseInt(rAng)*2/360) + 0.008);
        var c = '#000';
        if (j == 0){ c = 'red';}
        //console.log("J angle: "+ startAngle +", "+endAngle);
        var mark = new fabric.Circle({
            radius: r - 6,
            left: L,
            top: 1.5 * r,
            originX: 'center', 
            originY: 'center',
            startAngle: startAngle,
            endAngle: endAngle,
            stroke: c,
            strokeWidth: 10,
            selectable: false,
        });
        
        self.canvas1.add(mark);
        
        var t = (parseInt(num)*j).toString();
        var angle1 = ((360 * parseInt(num) * j)/parseInt(totalBP)) + (parseInt(rAng)) ; 
        var angle = Math.PI * ((parseFloat(markAngle) * j) + ((2 * (parseInt(rAng)))/360));
        
        var coords = self.findCoordinates(L, (1.5*r), 0.9*r, angle1, 1);
        //console.log("coords: "+coords);
        var left1 = coords[0]; 
        var top1 = coords[1]; 
        
        var text = new fabric.IText(t, { 
            id: 1111, //to differentiate from other elements when rotating 
            left: left1,
            top: top1,
            fontSize: 14,
            fill: 'black',
            originX: 'center', 
            originY: 'center',
            angle: angle1,
            selectable: false,
        });
        
        //to add the custom variable to the IText
        fabric.IText.prototype.toObject = (function(toObject) {
            return function() {
                return fabric.util.object.extend(toObject.call(this), {
                    objAngle: this.objAngle,
                    markAngle: this.markAngle
                });
            };
        })(fabric.IText.prototype.toObject);
        
        text.objAngle = angle1;
        text.markAngle = angle;
        text.async = true;
        
        self.canvas1.add(text);
    }
    
    if (fStrJSON.length > 0 && $("#"+self.parentDiv+"_showHideFeatures").text() == 'Hide Features' ) {
        // Draw red lines to show the selection
        var x1 = cx + r * Math.cos(angle_rad);
        var y1 = cy + r * Math.sin(angle_rad);
        var x2 = cx + r1 * Math.cos(angle_rad);
        var y2 = cy + r1 * Math.sin(angle_rad);
        
        var line = new fabric.Line([x1,y1,x2,y2], {
            stroke: 'black',
            strokeWidth: 1,
            selectable: false,
        });
        
        for (var i = 0; i < fStrJSON.length; i++) {
            var overLap = fStrJSON[i]['overLap'];
            var dir = fStrJSON[i]['direction'];
            
            if ((r - parseInt(overLap) * 20) > 10) {
                var cx = L;
                var cy = 1.5 * r;
                var angle = (parseInt(fStrJSON[i]['startPos'])/ parseInt(totalBP))*360;
                var dangle = ((parseInt(fStrJSON[i]['endPos']) - parseInt(fStrJSON[i]['startPos'])) * 360)/parseInt(totalBP);
                var radius = ((.95 * r) - (parseInt(overLap) * 20));
                var thickness = 14;
                var add_factor = 0.3;
                
                var angle_rad = 1.5 * Math.PI + angle * Math.PI / 180 + ((2 * Math.PI * rAng)/360);    //1.5 * Math.PI - to start drawing arcs from the angle 270
                var dangle_rad = dangle * Math.PI / 180;
                var total_rad = angle_rad + dangle_rad;
                
                var r1 = radius - 0.5*thickness - 0.5*add_factor*thickness;
                var r2 = radius + 0.5*thickness + 0.5*add_factor*thickness;
                var r3 = radius;
                
                var tri_rad = ( thickness + (thickness * add_factor) )/r3;
                
                var angle1, angle2;
                if ( ( 1/3*dangle_rad ) > tri_rad) {  // <) ( thickness + (thickness * add_factor) )/r3
                    var f1 = tri_rad/dangle_rad;
                    var f2 = (dangle_rad - tri_rad)/dangle_rad;
                    
                    if(dir === -1) {
                        angle1 = angle_rad + f2*dangle_rad;
                        angle2 = angle_rad + 3/3*dangle_rad;
                        
                        sAngle = angle_rad + 0/3*dangle_rad;
                        eAngle = angle_rad + f2*dangle_rad;
                    } else {
                        angle1 = angle_rad + f1*dangle_rad;
                        angle2 = angle_rad + 0/3*dangle_rad;
                        
                        sAngle = angle_rad + f1*dangle_rad;
                        eAngle = angle_rad + 3/3*dangle_rad;
                    }
                }
                else {
                    if(dir === -1) {
                        angle1 = angle_rad + 2/3*dangle_rad;
                        angle2 = angle_rad + 3/3*dangle_rad;
                        
                        sAngle = angle_rad + 0/3*dangle_rad;
                        eAngle = angle_rad + 2/3*dangle_rad;
                    } else {
                        angle1 = angle_rad + 1/3*dangle_rad;
                        angle2 = angle_rad + 0/3*dangle_rad;
                        
                        sAngle = angle_rad + 1/3*dangle_rad;
                        eAngle = angle_rad + 3/3*dangle_rad;
                    }
                }

                var x1 = cx + r1 * Math.cos(angle1);
                var y1 = cy + r1 * Math.sin(angle1);
                var x2 = cx + r2 * Math.cos(angle1);
                var y2 = cy + r2 * Math.sin(angle1);
                var x3 = cx + r3 * Math.cos(angle2);
                var y3 = cy + r3 * Math.sin(angle2);
                
                var circle2 = new fabric.Circle({
                    id : 100,
                    radius: ((.95 * r) - (parseInt(overLap) * 20)),
                    left: cx,
                    top: cy,
                    startAngle: sAngle,
                    endAngle: eAngle,
                    originX: 'center', 
                    originY: 'center',
                    stroke: fStrJSON[i]['color'],
                    strokeWidth: thickness,
                    fill: '',
                });
            
                //to add the custom variable to the Circle
                fabric.Circle.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        fName: this.fName,
                        sigment: this.sigment
                       });
                    };
                })(fabric.Circle.prototype.toObject);

                circle2.fName = fStrJSON[i]['featureName'];
                circle2.sigment = fStrJSON[i]['startPos'] + " .. " + fStrJSON[i]['endPos'] + " = " + fStrJSON[i]['lengthOfFeature'];
                circle2.async = true;

                var t2 = new fabric.Polygon(
                    [{x:x1,y:y1},{x:x2,y:y2},{x:x3,y:y3}],
                    {fill:fStrJSON[i]['color']}
                );
                
                var name = new fabric.Group([ circle2, t2], {
                    id: 100,
                    perPixelTargetFind: true,
                    selectable: false
                });
     
                self.canvas1.add(name);
                
            }
            else {
                // console.log("Need check: "+ i);
            }
        }
    }
    
    self.canvas1.renderAll();
}


ArxDraw.prototype.drawCircularMap = function(fStrJSON, totalBP, r, zoom, displayName, basePairs){
    var self = this;
    //REmappingArray -- {"startPos":2611,"endPos":2617,"enzyme":"BamH1","sequence":"GGATCC","overLap":1,"cut":"G^GATCC","cutType":"sticky","cutPosition":2}
    var rAng = $("#"+self.parentDiv+"_rotationSlider").slider("value"); 
    self.canvas3.clear();
   
    //Dividing the outer circle into 9 parts and finding that close to 1000..
    var markOuterCircle = [50, 60, 70, 80, 90, 100, 120, 140, 160, 180, 200, 225, 250, 275, 300, 325, 350, 375, 400, 450, 500, 550, 600, 650, 700, 800, 900, 1000, 1200, 1300, 1500, 1800, 2000, 2200, 2500, 2700, 3000, 3200, 3500, 3700, 3900, 4000, 4200, 4300, 4500, 4700, 5000, 6000, 7500, 10000, 12000, 15000, 16000, 18000, 20000, 22000, 25000, 27500, 30000, 32000, 35000, 37000, 40000];
    target = Math.abs(parseInt(totalBP) / 9);
    zoom = 1;
    
    r = (parseInt(r) * zoom);
    
    if ( !displayName ) {
        displayName = "";
    }
    if ( !basePairs ) {
        basePairs = "";
    }
    
    //var L = ($(self.window).width() - r)/2;
    
    var L = (self.canvas3.getWidth())/2;
    
    var iTextName = new fabric.IText(displayName, { 
        fontFamily: 'Courier', 
        left: L,
        top: 1.5 * r,
        originX: 'center', 
        originY: 'center',
        fontSize: 20,
        visible: true,
        fill: 'black'
    });
    var iTextBP = new fabric.IText(basePairs.toString()+ " bp", { 
        fontFamily: 'Courier', 
        left: L,
        top: 1.5 * r + 20,
        originX: 'center', 
        originY: 'center',
        fontSize: 16,
        visible: true,
        fill: 'black'
    });
    
    var name = new fabric.Group([ iTextName, iTextBP], {
        id: 110011,
        selectable: false,
    });
    
    //to add the custom variable to the IText
    fabric.Group.prototype.toObject = (function(toObject) {
        return function() {
            return fabric.util.object.extend(toObject.call(this), {
                rotation: this.rotation,
                zoom: this.zoom
            });
        };
    })(fabric.Group.prototype.toObject);
    
    name.rotation = rAng;
    name.zoom = zoom;
    name.async = true;
    
    self.canvas3.add(name);
   

    for (var k=1; k<markOuterCircle.length; k++) {
        // As soon as a number bigger than target is found, return the previous or current
        if (parseInt(markOuterCircle[k]) > target) {
            var p = markOuterCircle[k-1];
            var c = markOuterCircle[k];
            var num = Math.abs( p-target ) < Math.abs( c-target ) ? p : c;
            break;
        }
    }

    if (num == ""){
        var num = markOuterCircle[markOuterCircle.length-1];
    }
    
    var markAngle = ((2 * parseInt(num))/ parseInt(totalBP));
    
    var circle = new fabric.Circle({
        id: totalBP,
        radius: r,
        left: L,
        top: 1.5 * r,
        originX: 'center', 
        originY: 'center',
        stroke: '#000',
        strokeWidth: 2,
        fill: '',
        selectable: false,
    });

    var circle1 = new fabric.Circle({
        id: 2,
        radius: r - 6,
        left: L,
        top: 1.5 * r,
        originX: 'center', 
        originY: 'center',
        stroke: '#000',
        strokeWidth: 2,
        fill:'',
        selectable: false,
    });
    self.canvas3.add(circle, circle1);
    

    for (var j = 0; j < 9; j++){
        var startAngle = Math.PI * (1.5 + (parseFloat(markAngle) * j) + (parseInt(rAng)*2/360) );
        var endAngle = Math.PI * ((1.5 + (parseFloat(markAngle) *j))+ (parseInt(rAng)*2/360) + 0.008);
        var c = '#000';
        if (j == 0){ c = 'red';}
        var mark = new fabric.Circle({
            radius: r - 6,
            left: L,
            top: 1.5 * r,
            originX: 'center', 
            originY: 'center',
            startAngle: startAngle,
            endAngle: endAngle,
            stroke: c,
            strokeWidth: 10,
            selectable: false,
        });
        self.canvas3.add(mark);
        
        
        var t = (parseInt(num)*j).toString();
        var angle1 = ((360 * parseInt(num) * j)/parseInt(totalBP)) + (parseInt(rAng)) ; 
        var angle = Math.PI * ((parseFloat(markAngle) * j) + ((2 * (parseInt(rAng)))/360));
        
        var coords = self.findCoordinates(L, (1.5*r), 0.9*r, angle1, 1);
        //console.log("CIRCULAR MAP coords: "+coords[0] + ", " +coords[1]);
        var left1 = coords[0]; 
        var top1 = coords[1]; 
        
        var text = new fabric.IText(t, { 
            id: 1111, //to differentiate from other elements when rotating 
            left: left1,
            top: top1,
            fontSize: 14,
            fill: 'black',
            originX: 'center', 
            originY: 'center',
            angle: angle1,
            selectable: false,
        });
        
        //to add the custom variable to the IText
        fabric.IText.prototype.toObject = (function(toObject) {
            return function() {
                return fabric.util.object.extend(toObject.call(this), {
                    objAngle: this.objAngle,
                    markAngle: this.markAngle
                });
            };
        })(fabric.IText.prototype.toObject);
        
        text.objAngle = angle1;
        text.markAngle = angle;
        text.async = true;
        
        self.canvas3.add(text);
    }
    
    if (fStrJSON.length > 0 && $("#"+self.parentDiv+"_showHideFeatures").text() == 'Hide Features' ) {
        // Draw red lines to show the selection
        var x1 = cx + r * Math.cos(angle_rad);
        var y1 = cy + r * Math.sin(angle_rad);
        var x2 = cx + r1 * Math.cos(angle_rad);
        var y2 = cy + r1 * Math.sin(angle_rad);
        
        var line = new fabric.Line([x1,y1,x2,y2], {
            stroke: 'black',
            strokeWidth: 1,
            selectable: false,
        });
        
        for (var i = 0; i < fStrJSON.length; i++) {
            var overLap = fStrJSON[i]['overLap'];
            var dir = fStrJSON[i]['direction'];
            
            if ((r - parseInt(overLap) * 20) > 10) {
                var cx = L;
                var cy = 1.5 * r;
                var angle = (parseInt(fStrJSON[i]['startPos'])/ parseInt(totalBP))*360;
                var dangle = ((parseInt(fStrJSON[i]['endPos']) - parseInt(fStrJSON[i]['startPos'])) * 360)/parseInt(totalBP);
                var radius = ((.95 * r) - (parseInt(overLap) * 20));
                var thickness = 14;
                var add_factor = 0.3;
                
                var angle_rad = 1.5 * Math.PI + angle * Math.PI / 180 + ((2 * Math.PI * rAng)/360);    //1.5 * Math.PI - to start drawing arcs from the angle 270
                var dangle_rad = dangle * Math.PI / 180;
                var total_rad = angle_rad + dangle_rad;
                
                var r1 = radius - 0.5*thickness - 0.5*add_factor*thickness;
                var r2 = radius + 0.5*thickness + 0.5*add_factor*thickness;
                var r3 = radius;
                
                var tri_rad = ( thickness + (thickness * add_factor) )/r3;
                
                var angle1, angle2;
                if ( ( 1/3*dangle_rad ) > tri_rad) {  // <) ( thickness + (thickness * add_factor) )/r3
                    var f1 = tri_rad/dangle_rad;
                    var f2 = (dangle_rad - tri_rad)/dangle_rad;
                    
                    if(dir === -1) {
                        angle1 = angle_rad + f2*dangle_rad;
                        angle2 = angle_rad + 3/3*dangle_rad;
                        
                        sAngle = angle_rad + 0/3*dangle_rad;
                        eAngle = angle_rad + f2*dangle_rad;
                    } else {
                        angle1 = angle_rad + f1*dangle_rad;
                        angle2 = angle_rad + 0/3*dangle_rad;
                        
                        sAngle = angle_rad + f1*dangle_rad;
                        eAngle = angle_rad + 3/3*dangle_rad;
                    }
                }
                else {
                    if(dir === -1) {
                        angle1 = angle_rad + 2/3*dangle_rad;
                        angle2 = angle_rad + 3/3*dangle_rad;
                        
                        sAngle = angle_rad + 0/3*dangle_rad;
                        eAngle = angle_rad + 2/3*dangle_rad;
                    } else {
                        angle1 = angle_rad + 1/3*dangle_rad;
                        angle2 = angle_rad + 0/3*dangle_rad;
                        
                        sAngle = angle_rad + 1/3*dangle_rad;
                        eAngle = angle_rad + 3/3*dangle_rad;
                    }
                }

                var x1 = cx + r1 * Math.cos(angle1);
                var y1 = cy + r1 * Math.sin(angle1);
                var x2 = cx + r2 * Math.cos(angle1);
                var y2 = cy + r2 * Math.sin(angle1);
                var x3 = cx + r3 * Math.cos(angle2);
                var y3 = cy + r3 * Math.sin(angle2);
                
                var circle2 = new fabric.Circle({
                    id : 100,
                    radius: ((.95 * r) - (parseInt(overLap) * 20)),
                    left: cx,
                    top: cy,
                    startAngle: sAngle,
                    endAngle: eAngle,
                    originX: 'center', 
                    originY: 'center',
                    stroke: fStrJSON[i]['color'],
                    strokeWidth: thickness,
                    fill: '',
                });
            
                //to add the custom variable to the Circle
                fabric.Circle.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        fName: this.fName,
                        sigment: this.sigment
                       });
                    };
                })(fabric.Circle.prototype.toObject);

                circle2.fName = fStrJSON[i]['featureName'];
                circle2.sigment = fStrJSON[i]['startPos'] + " .. " + fStrJSON[i]['endPos'] + " = " + fStrJSON[i]['lengthOfFeature'];
                circle2.async = true;

                var t2 = new fabric.Polygon(
                    [{x:x1,y:y1},{x:x2,y:y2},{x:x3,y:y3}],
                    {fill:fStrJSON[i]['color']}
                );
                
                var name = new fabric.Group([ circle2, t2], {
                    id: 100,
                    perPixelTargetFind: true,
                    selectable: false
                });
     
                self.canvas3.add(name);
               
                var pushStr = {'canvasId':self.canvas3.getObjects().length, 'start':fStrJSON[i]['startPos'], 'end':fStrJSON[i]['endPos'], 'highLightId':(self.canvas2.getObjects().length - 1), 'type':"feature"};
                self.canvas3ItemArray.push(pushStr);
                
            }
            else {
                console.log("Need check: "+ i + ", " + fStrJSON[i]['overLap']);
            }
        }
    }
    
    if ( $("#"+self.parentDiv+"_showHideRE").text() == "Hide Enzymes" ) {
        self.drawRECircularMap(r, L, totalBP, $("#"+self.parentDiv+"_rotationSlider").slider("value"), self.REmappingArray);
    }
    self.canvas3.renderAll();
}

ArxDraw.prototype.drawRECircularMap = function(r, L, totalBP, rotation, REmappingArray) {
    var self = this;
    var prevAngle = 4.71; // 1.5 * PI = 4.71

    console.log("RECIRCULAR MAP: "+ r +", "+ L +", "+ totalBP+", "+ rotation +", "+ REmappingArray.length);
    
    for (var j = 0; j < REmappingArray.length; j++) { //REmappingArray -- {"startPos":2611,"endPos":2617,"enzyme":"BamH1","sequence":"GGATCC","overLap":1,"cut":"G^GATCC","cutType":"sticky"}
        var angle = (parseInt(REmappingArray[j]['startPos'])/ parseInt(totalBP))*360;
        angle = angle + Number(rotation);
        var angle_rad = 1.5 * Math.PI + angle * Math.PI / 180;  
        var cx = L;
        var cy = 1.5 * r;
        
        var x1 = cx + r * Math.cos(angle_rad);
        var y1 = cy + r * Math.sin(angle_rad);
        
        //(9.947073846723887 - 9.909290047053965 = 0.0378) 
        // (1.5 + 1)*PI = 7.855
        if ( (angle_rad > 4.71 && angle_rad < 7.855) || (angle_rad > 10.99 && angle_rad < 14.13 ) )  {
            var dir = 'left';
        }
        else if ( (angle_rad > 7.855 && angle_rad < 10.99 ) || (angle_rad > 14.13 && angle_rad < 17.27 ) ) {
            var dir = 'right';
        }
        
        if ( prevAngle == 4.71 || (angle_rad - prevAngle) > 0.0378 ) {
            var r1 = r + ( (50) * REmappingArray[j]['overLap'] );
            var x2 = cx + r1 * Math.cos(angle_rad);
            var y2 = cy + r1 * Math.sin(angle_rad);
            
            var line = new fabric.Line([x1,y1,x2,y2], {
                stroke: 'black',
                strokeWidth: 1,
                selectable: false,
            });
        }
        else if ( (prevAngle - angle_rad) > 1.573 ) {
            var r1 = r + ( (100) * REmappingArray[j]['overLap'] );
            var x2 = cx + r1 * Math.cos(angle_rad);
            var y2 = cy + r1 * Math.sin(angle_rad);
            
            var line = new fabric.Line([x1,y1,x2,y2], {
                stroke: 'blue',
                strokeWidth: 1,
                selectable: false,
            });
        }
        else if ( ( angle_rad > prevAngle ) &&  (angle_rad - prevAngle) < 0.0378 ) { //the lines are too close by so draw the line with an angle
            var r1 = r + ( (25) * REmappingArray[j]['overLap'] );
            var x3 = cx + r1 * Math.cos(angle_rad);
            var y3 = cy + r1 * Math.sin(angle_rad);
            
            angle_rad = prevAngle  + 0.0378;
            var r2 = r + ( (50) * REmappingArray[j]['overLap'] );
            var x2 = cx + r2 * Math.cos(angle_rad);
            var y2 = cy + r2 * Math.sin(angle_rad);
            
            var line = new fabric.Polyline(
                [{x:x1,y:y1},{x:x3,y:y3},{x:x2,y:y2}], {
                stroke: 'black',
                fill: '',
            });
        }
        else {
            var r1 = r + ( (50/2) * REmappingArray[j]['overLap'] );
            var x2 = cx + r1 * Math.cos(angle_rad);
            var y2 = cy + r1 * Math.sin(angle_rad);
            
            var line = new fabric.Line([x1,y1,x2,y2], {
                stroke: 'black',
                strokeWidth: 1,
                selectable: false,
            });
        }
        
        //itext styles
        var iStyle = "";
        for (k=0; k < REmappingArray[j]['enzyme'].length; k++) {
            iStyle = iStyle + '"'+k+'": {"stroke": "black", "fontWeight": "bold"},';
        }
        
        iStyle = iStyle.substring(0, (iStyle.length - 1) );
        iStyle = JSON.parse('{"0":{' + iStyle + '}}')
        
        var text = new fabric.IText(REmappingArray[j]['enzyme'] + " ("+REmappingArray[j]['startPos']+")", { 
            id: 11011, //to differentiate from other elements when rotating 
            left: x2,
            top: y2,
            fontSize: 12,
            fill: 'black',
            originX: dir, 
           // originY: dir,
            styles: iStyle
        });
        
        //to add the custom variable to the IText
        fabric.IText.prototype.toObject = (function(toObject) {
            return function() {
                return fabric.util.object.extend(toObject.call(this), {
                    sequence: this.sequence ,
                    cutPosition: this.cutPosition,
                    cut: this.cut,
                });
            };
        })(fabric.IText.prototype.toObject);
        
        text.sequence = REmappingArray[j]['sequence'];
        text.cutPosition = REmappingArray[j]['cutPosition'];
        text.cut = REmappingArray[j]['cut'];
        text.async = true;
        
                
        var name = new fabric.Group([ line, text], {
            id: 200,
            perPixelTargetFind: true,
            selectable: false,
        });
        self.canvas3.add(name);
        prevAngle = angle_rad;
        
        var pushStr = {'canvasId':self.canvas3.getObjects().length, 'start':REmappingArray[j]['startPos'], 'end':REmappingArray[j]['endPos'], 'highLightId':(self.canvas2.getObjects().length - 1), 'type':"restictionEnzyme"};
        self.canvas3ItemArray.push(pushStr);
    }
    self.canvas3.renderAll();
}

ArxDraw.prototype.drawLinearMap = function(fStrJSON, totalBP, mapWidth, displayName, basePairs) {
    //console.log("drawLinearMap: "+ JSON.stringify(fStrJSON));
    console.log("LINEAR MAP: "+ mapWidth);
    var self = this;
    var x = 50;
    var y = 500;
    self.canvas4.clear();
    var num = "";
    var markBaseLine = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50, 100, 200, 500, 700, 900, 1000, 1200, 1300, 1500, 1800, 2000, 2200, 2500, 2700, 3000, 3200, 3500, 3700, 3900, 4000, 4200, 4300, 4500, 4700, 5000, 6000, 7500, 10000, 12000, 15000, 16000, 18000, 20000, 22000, 25000, 27500, 30000, 32000, 35000, 37000, 40000];
    target = Math.abs(parseInt(totalBP) / 5);
    var chkOverlap = 0;
    
    if (displayName == "" || typeof displayName == 'undefined' || !displayName) {
        displayName = "Test Sequence";
    }
    var iTextName = new fabric.IText(displayName, { 
        fontFamily: 'Courier', 
        left: (document.getElementById(self.parentDiv+'_c4').width)/2,
        top: 50,
        originX: 'center', 
        originY: 'center',
        fontSize: 20,
        visible: true,
        fill: 'black'
    });
    
    var iTextBP = new fabric.IText(basePairs.toString()+ " bp", { 
        fontFamily: 'Courier', 
        left: (document.getElementById(self.parentDiv+'_c4').width)/2,
        top: 50 + 20,
        originX: 'center', 
        originY: 'center',
        fontSize: 16,
        visible: true,
        fill: 'black'
    });
    
    var name = new fabric.Group([ iTextName, iTextBP ], {
        id: 110011,
        selectable: false,
    });
    self.canvas4.add(name);
    
    for (var k=1; k<markBaseLine.length; k++) {
        // As soon as a number bigger than target is found, return the previous or current
        if (parseInt(markBaseLine[k]) > target) {
            var p = markBaseLine[k-1];
            var c = markBaseLine[k];
            num = Math.abs( p-target ) < Math.abs( c-target ) ? p : c;
            break;
        }
    }
    if (num == ""){
        var num = markBaseLine[markBaseLine.length-1];
    }
    
    var line = new fabric.Line([x, y, x+mapWidth, y], {
        id: totalBP,
        stroke: 'blue',
        strokeWidth: 3,
        selectable: false,
    });
    self.canvas4.add(line);
    
    var line1 = new fabric.Line([x,y+5,x+mapWidth,y+5], {
        stroke: 'blue',
        strokeWidth: 3,
        selectable: false,
    });
    self.canvas4.add(line1);

    for (var j = 0; j < 6; j++){
        
        var t = (parseInt(num)*j).toString();
        var x1 = x + (mapWidth)*num*j/parseInt(totalBP);
        if (j == 5) {
            t = totalBP.toString();
            x1 = x + mapWidth;
        }
        var line2 = new fabric.Line([x1,y+5,x1,y+12], {
            stroke: 'blue',
            strokeWidth: 3,
            selectable: false,
        });
        self.canvas4.add(line2);
        
        var text = new fabric.IText(t, { 
            left: x1,
            top: y + 21,
            fontSize: 14,
            fill: 'black',
            originX: 'center', 
            originY: 'center',
            selectable: false,
        });
        self.canvas4.add(text);
    }
    
    if (fStrJSON.length > 0 && $("#"+self.parentDiv+"_showHideFeatures").text() == 'Hide Features' ) {
        for (var i = 0; i < fStrJSON.length; i++) {
            var s = parseInt(fStrJSON[i]['startPos'])*mapWidth/ parseInt(totalBP);
            var e = parseInt(fStrJSON[i]['endPos'])*mapWidth/ parseInt(totalBP);
            
            var overLap = fStrJSON[i]['overLap'];
            var dir = fStrJSON[i]['direction'];
            
            if (dir === -1) {
                var rectangle = (new fabric.Rect({
                    id: 100,
                    left: x + s,
                    top: y + 20 + (22*overLap),
                    width: (e - s)*(2/3),
                    height: 12,
                    fill: fStrJSON[i]['color'],
                    stroke: '#484848',
                    strokeWidth: 1,
                    perPixelTargetFind: true
                }));
                
                //to add the custom variable to the rectangle
                fabric.Rect.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        fName: this.fName,
                        sigment: this.sigment
                       });
                    };
                })(fabric.Rect.prototype.toObject);
                
                rectangle.fName = fStrJSON[i]['featureName'];
                rectangle.sigment = fStrJSON[i]['startPos'] + " .. " + fStrJSON[i]['endPos'] + " = " + fStrJSON[i]['lengthOfFeature'];
                   
                rectangle.async = true;

                var t1 = new fabric.Triangle({    //originX: 'left',
                    width: 12 + 3 + 3,
                    height: (e - s)*(1/3),
                    selectable: false,
                    fill: fStrJSON[i]['color'],
                    stroke: '#484848',
                    strokeWidth: 1,
                    left: x + s + (e - s),
                    top: y + 20 + (22*overLap) - 3,
                    angle: 90
                });
            }
            else {
                var rectangle = (new fabric.Rect({
                    id: 100,
                    left: x + s + (e - s)*(1/3),
                    top: y + 20 + (22*overLap),
                    width: (e - s)*(2/3),
                    height: 12,
                    fill: fStrJSON[i]['color'],
                    stroke: '#484848',
                    strokeWidth: 1,
                    perPixelTargetFind: true
                }));
                
                //to add the custom variable to the rectangle
                fabric.Rect.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        fName: this.fName,
                        sigment: this.sigment
                       });
                    };
                })(fabric.Rect.prototype.toObject);
                
                rectangle.fName = fStrJSON[i]['featureName'];
                rectangle.sigment = fStrJSON[i]['startPos'] + " .. " + fStrJSON[i]['endPos'] + " = " + fStrJSON[i]['lengthOfFeature'];
                   
                rectangle.async = true;

                var t1 = new fabric.Triangle({    //originX: 'left',
                    width: 12 + 3 + 3,
                    height: (e - s)*(1/3),
                    selectable: false,
                    fill: fStrJSON[i]['color'],
                    stroke: '#484848',
                    strokeWidth: 1,
                    left: x + s ,
                    top: y + 20 + (22*overLap) + 12 + 4,
                    angle: -90
                });
            }
            
            if (parseInt(chkOverlap) < overLap && overLap < 1000 ) {
                chkOverlap = overLap;
            }

            var name = new fabric.Group([ rectangle, t1], {
                id: 100,
                selectable: false,
            });
            self.canvas4.add(name);
        }
    }
    
    if ( $("#"+self.parentDiv+"_showHideRE").text() == "Hide Enzymes" ) {
        self.drawRELinearMap(mapWidth, totalBP);
    }
   
    self.canvas4.setHeight( ( y + 50 + (22*chkOverlap)) );
    self.canvas4.setWidth(mapWidth + 100);
    console.log("CANVAS 4 height: " +self.canvas4.getHeight() + ", " + self.canvas4.getWidth());
    self.canvas4.renderAll();
}

ArxDraw.prototype.drawRELinearMap = function(mapWidth, totalBP) {
    var self = this;
    var x = 50;
    var y = 500;
    var prevLine = 0; 
    var y2 = y - 20;
    
    for (var j = 0; j < self.REmappingArray.length; j++) { //REmappingArray -- {"startPos":2611,"endPos":2617,"enzyme":"BamH1","sequence":"GGATCC","overLap":1,"cut":"G^GATCC","cutType":"sticky"}
        var x1 = x + parseInt(self.REmappingArray[j]['startPos'])*mapWidth/ parseInt(totalBP);
        
        if ( prevLine == 0 || (parseInt(self.REmappingArray[j]['startPos']) - prevLine) > 1000 ) {
            y2 = y - 20;
        }
        else {
            y2 = y2 - 12;
        }
        
        var line2 = new fabric.Line([x1,y,x1,y2], {
            stroke: 'gray',
            strokeWidth: 1,
            selectable: false,
        });
        
        //itext styles
        var iStyle = "";
        for (k=0; k < self.REmappingArray[j]['enzyme'].length; k++) {
            iStyle = iStyle + '"'+k+'": {"stroke": "black", "fontWeight": "bold"},';
        }
        
        iStyle = iStyle.substring(0, (iStyle.length - 1) );
        iStyle = JSON.parse('{"0":{' + iStyle + '}}')
        
        var text = new fabric.IText(self.REmappingArray[j]['enzyme'] + " ("+self.REmappingArray[j]['startPos']+")", { 
            id: 11011, //to differentiate from other elements when rotating 
            left: x1,
            top: y2 - 3,
            fontSize: 12,
            fill: 'black',
            //originX: 'left', 
            //originY: 'left',
            styles: iStyle
        });
        
        //to add the custom variable to the IText
        fabric.IText.prototype.toObject = (function(toObject) {
            return function() {
                return fabric.util.object.extend(toObject.call(this), {
                    sequence: this.sequence ,
                    cutPosition: this.cutPosition,
                    cut: this.cut,
                });
            };
        })(fabric.IText.prototype.toObject);
        
        text.sequence = self.REmappingArray[j]['sequence'];
        text.cutPosition = self.REmappingArray[j]['cutPosition'];
        text.cut = self.REmappingArray[j]['cut'];
        text.async = true;
        
        var name = new fabric.Group([line2, text], {
            id: 200,
            perPixelTargetFind: true,
            selectable: false,
        });
        self.canvas4.add(name);
        prevLine = self.REmappingArray[j]['startPos'];
    }
    self.canvas4.renderAll();
}


ArxDraw.prototype.drawMapping = function(x1,y1,x2,y2,a,b,enzyme,n,info){
    var self = this;
    var line = new fabric.Line([0,0,(x2-x1),0], {
        stroke: 'blue',
        strokeWidth: 1,
    });
    
    var vline1 = new fabric.Line([0,0,0,7], {
        stroke: 'blue',
        strokeWidth: 1,
    });
    
    var vline2 = new fabric.Line([(x2-x1),0,(x2-x1),7], {
        stroke: 'blue',
        strokeWidth: 1,
    });
    
    var text = new fabric.Text(enzyme, {
        fontSize: 11,
        stroke: '#ff1318',
        originX: 'center', 
        originY: 'bottom' ,
        left  : (x2-x1)*6/11,
    });
    
    //to add the custom variable to the Text
    fabric.Text.prototype.toObject = (function(toObject) {
      return function() {
        return fabric.util.object.extend(toObject.call(this), {
          info: this.info,
          highLightIds: this.highLightIds
        });
      };
    })(fabric.Text.prototype.toObject);
    
    text.info = info;
    text.highLightIds = self.startId2+"#"+self.endId2+"#"+self.canvas2.getObjects().length;
    text.async = true;
    
    var highlightRect = (new fabric.Rect({
        id: 10,
        left: (x1),
        top: y1,
        width: (x2-x1),
        height: 45, // 20 + 20 + 5 (itext height + comp itext height + space inbetween)
        fill: '#009900',
        visible: false,
        hasControls: false,
        opacity: 0.2,
        selectable: false,
    })); 
    
    var name = new fabric.Group([ text, line, vline1, vline2], {
        id: 222,
        left: (x1 - 5), //Subtracting 5 because to move the line bracket in match with the highlighting part
        top: y1-22*n,
        visible: true,
        perPixelTargetFind: true,
        selectable: false,
    });
    self.canvas2.add(highlightRect);
    self.canvas2.add(name);
    var pushStr = {'canvasId':self.canvas2.getObjects().length , 'start':x1, 'end':x2, 'highLightId':(self.canvas2.getObjects().length - 1), 'type':"restictionEnzyme"}
    self.canvas2ItemArray.push(pushStr);
}

ArxDraw.prototype.drawBreakMapping = function(x1,x2,x3,x4,y1,y2,a,b,enzyme,n,info){
    console.log("DRAW BREAK MAPPING: "+ enzyme);
    var self = this;
    var line1 = new fabric.Line([0,0,(x2-x1),0], {
        stroke: 'blue',
        strokeWidth: 1,
        left: x1
    });
    
    var vline1 = new fabric.Line([0,0,0,7], {
        stroke: 'blue',
        strokeWidth: 1,
        left: x1
    });
    
    var line2 = new fabric.Line([x3,(y2 - y1),(x4),(y2 - y1)], {
        stroke: 'blue',
        strokeWidth: 1,
        left: x3
    });
    
    var vline2 = new fabric.Line([(x4),(y2 - y1),(x4),(y2 - y1 + 7)], {
        stroke: 'blue',
        strokeWidth: 1,
        left: (x4)
    });
    
    var text = new fabric.Text(enzyme, {
        fontSize: 11,
        stroke: '#ff1318',
        originX: 'center', 
        originY: 'bottom' ,
        left  : x1 + (x2 - x1)*6/11,
        top: 0
    });
    
    //to add the custom variable to the Text
    fabric.Text.prototype.toObject = (function(toObject) {
        return function() {
            return fabric.util.object.extend(toObject.call(this), {
              info: this.info,
              highLightIds: this.highLightIds
            });
        };
    })(fabric.Text.prototype.toObject);
    
    text.info = info;
    text.highLightIds = self.startId2+"#"+self.endId2+"#"+self.canvas2.getObjects().length+"#"+(self.canvas2.getObjects().length+1);
    text.async = true;
    
    var highlightRect1 = (new fabric.Rect({
        id: 10,
        left: (x1),
        top: y1,
        width: (x2-x1),
        height: 45,
        fill: '#009900',
        visible: false,
        hasControls: false,
        opacity: 0.2,
        selectable: false,
    })); 
    
    var highlightRect2 = (new fabric.Rect({
        id: 10,
        left: (x3),
        top: y2,
        width: (x4-x3),
        height: 45,
        fill: '#009900',
        visible: false,
        hasControls: false,
        opacity: 0.2,
        selectable: false,
    })); 
    
    var name = new fabric.Group([ text, line1, vline1, line2, vline2], {
        id : 222,
        left : x3 - 6,
        top : y1-19*n,
        visible : true,
        perPixelTargetFind : true,
        targetFindTolerance : 10,
        hasControls : false,
        hasBorders : false,
        selectable: false,
        
    });
    self.canvas2.add(highlightRect1);
    self.canvas2.add(highlightRect2);
    self.canvas2.add(name);
    var pushStr = {'canvasId':self.canvas2.getObjects().length , 'start':x1, 'end':x2, 'highLightId':(self.canvas2.getObjects().length - 1), 'type':"restictionEnzyme"}
    self.canvas2ItemArray.push(pushStr)
}


ArxDraw.prototype.drawBluntCut = function(x1,y1,x2,y2,left,top) {
    var self = this;
    console.log("DRAW BLUNT CUT: "+ x1+", "+y1+", "+x2+", "+y2+", "+left+", "+top);
    var drawCut = new fabric.Line([x1,y1,x2,y2], {
        stroke: 'red',
        selectable: false,
        left: left,
        top: top,
        strokeWidth: 2
    });
    self.canvas2.add(drawCut);
    drawCut.bringToFront();
    self.drawCutArray.push(self.canvas2.getObjects().length);
}

 
ArxDraw.prototype.drawCut = function(x1,y1,x2,y2,left,top) {
    var self = this;
    console.log("DRAW CUT: "+ x1+", "+y1+", "+x2+", "+y2+", "+left+", "+top);
    var drawCut = new fabric.Line([x1,y1,x2,y2], {
        stroke: 'red',
        selectable: false,
        left: left,
        top: top,
        strokeWidth: 2
    });
    self.canvas2.add(drawCut);
    drawCut.bringToFront();
    self.drawCutArray.push(self.canvas2.getObjects().length);
}


ArxDraw.prototype.findCoordinates = function(a, b, r, angle1, zoom) {
    var t = (1.5 * 3.145)+((angle1 * 2 * 3.145)/360);
    var left1 = a + ((r + 10) * zoom * (Math.cos(t))); // Adding 10 to the radius because to draw the numbers outside the circle
    var top1 = (b * zoom) + ((r + 10) * zoom * (Math.sin(t)));
    return[left1, top1];
}

ArxDraw.prototype.fabric_guideLine = function(n, q, by) {
    var self = this;
    var line = new fabric.Line([self.offsetArray[0], by + self.b, self.offsetArray[n], by + self.b], {
        stroke: 'green',
        strokeWidth: 1,
        selectable: false,
    });
    
    var group = new fabric.Group(); 
    group.add(line); 
    
    var value = ((q+1)*10 + q*(self.wordsInALine - 10));
    
    for (var j=10; j < n; j=j+10){
        var t = value+j-10;
        group.add(new fabric.Text(t.toString(), {
            fontSize: 8,
            fillStyle: 'blue',
            left: self.offsetArray[j-1],
            top: (self.b+3)+by,
            hasBorders: true,
            textAlign: 'right',
            backgroundColor: 'pink',
            selectable: false,
        }));
    }
    // console.log("fabric_guideLine top: "+ ((self.b+3)+by) +", by: "+ by);
    self.canvas2.add(group);
}


ArxDraw.prototype.fabric_TextBox = function(t, id, visible, a, b, tText, fs) {
    var self = this;
    var Textbox = new fabric.Textbox(t, { 
        id: id,
        fontFamily: 'Courier', 
        width: self.offsetArray[self.wordsInALine],
        left: a, 
        top: b,
        fontSize: fs,
        visible: visible,
        selectable: false,
        fill: 'black',
        textAlign: 'left',
    });
   
    //to add the custom variable to the IText
    fabric.Textbox.prototype.toObject = (function(toObject) {
        return function() {
            return fabric.util.object.extend(toObject.call(this), {
                totalText: this.totalText,
            });
        };
    })(fabric.Textbox.prototype.toObject);
    
    Textbox.totalText = tText;
       
    Textbox.async = true;
    
    self.canvas2.add(Textbox);
}


ArxDraw.prototype.fabric_hDashedLine = function(x1, y1, x2, y2, visible, q, w) {
    var self = this;
    var line = new fabric.Line([x1,y1,x2,y2], {
        stroke: 'black',
        strokeDashArray: [6, 6],
        strokeWidth: 1,
        visible: visible,
    });
    
    var t1 = (q+1).toString();
    var t2 = (q+1).toString();
    
    var text1 = new fabric.Text(t1, {
        fontSize: 10,
        fillStyle: 'blue',
        left: x1 - 25,
        top: y1 - 10,
        hasBorders: true,
        textAlign: 'right',
    });
    
    var text2 = new fabric.Text(t1, {
        fontSize: 10,
        fillStyle: 'blue',
        left: x2 + 25,
        top: y1 - 10,
        textAlign: 'left',
    });
     
    var name = new fabric.Group([ text1, line, text2], {
        originX: 'center',
        originY: 'center',
        hasControls: false,
        hasBorders: false,
        visible: visible,
        selectable: false,
    });
    
    self.canvas2.add(name);
}


ArxDraw.prototype.findFMAObjects = function(obj, key, val) {  //(featureMappingArray, "startRow", q)
    var self = this;
    var objects = [];
   
    for (var i = 0; i < obj.length; i++) {
        if (obj[i][key] == val) {
           objects.push(obj[i]);
        }
    }
    
    objects.sort(self.sort_by('lengthOfFeature', true, parseInt));    
    self.findFMAOverlap(objects);
       
    return objects;
}


ArxDraw.prototype.findFMAOverlap = function(object) {
    for (var l = 1; l< object.length; l++){
        var fStart = object[l -1]['startPos'];
        var fEnd = object[l -1]['endPos'];
        var s = object[l]['startPos'];
        var e = object[l]['endPos'];
        
        if ((fStart <= s && fEnd >= e) || (fStart >= s && fEnd <= e) || (fStart >= s && fEnd >= e && fStart <= e)|| (fStart <= s && fEnd >= s && fEnd <= e)){
            object[l]['overLap'] = parseInt(object[l-1]['overLap']) + 1 ;
        }
        else {
            object[l]['overLap'] = parseInt(object[l-1]['overLap']) ;
        }
    }
}

ArxDraw.prototype.findFMAOverlap_mapView = function(object) {
    var overLap = 1;
    //First row assign the overlap = 1 l< object.length
    if (object.length > 0) {
        object[0]['overLap'] = overLap;
        
        for (var l = 1; l< object.length; l++){
            var s = object[l]['startPos'];
            var e = object[l]['endPos'];
            var check = 0;
            
            for (var m = l-1; m >= 0; m--) {
                var fStart = object[m]['startPos'];
                var fEnd = object[m]['endPos'];
                
                if (parseInt(fEnd) > parseInt(s)) {
                    object[l]['overLap'] = object[m]['overLap'] + 1;
                    check = 1;
                }
                else if (parseInt(fEnd) < parseInt(s)) {
                    object[l]['overLap'] = object[m]['overLap'];
                }
                
                if (object[m]['overLap'] == 1 || check == 1) {
                    break;
                }
            }
        }
    }
}

ArxDraw.prototype.fabric_FMA = function(start, wordsInALine, by, fmaCount, fmaStringsArr, startId2, endId2) { //(0, wordsInALine, by, fmaStringsArr.length, fmaStringsArr)
    //Gave an id to the group 100 to differentiate from other groups when highlighting
    var self = this;
    for (var j = 0; j < fmaStringsArr.length; j ++){      //0#1#120#"ChtC2"#1#1##A5F3BE*0#1#120#miscellaneous#2#2##94FB74#"begin"#fSegArr  ROW#STARTID#ENDID#NAME#ARRAYID#OVERLAP#COLOR#"begin"#FSEGARRAY
        //{"startRow":1,"startPos":0,"endPos":120,"featureName":"mphA misc_feature","arrayConn":118,"overLap":1,"color":"#A7730A","typeOfRow":"","featureSegDetails":"","lengthOfFeature":120},
        var fma = fmaStringsArr[j];
        var spacing = 15;
        var drawRect = false;
        var drawLine = false;
        
        var highlightRect = (new fabric.Rect({
            id: 10,
            left: self.offsetArray[parseInt(fma['startPos'])],
            top: by,
            width: self.offsetArray[parseInt(fma['endPos'])] - self.offsetArray[parseInt(fma['startPos'])],
            height: 45,
            fill: '#FFCC00',
            visible: false,
            hasControls: false,
            opacity: 0.2,
            //perPixelTargetFind: true,
            selectable: false,
        })); 
        
        // console.log(" fabric_FMA top:  " + ( by + self.breakLineWidth * 2 +  (parseInt(spacing) * (parseInt(fma['overLap']) - 1)) + (parseInt(fma['overLap'] - 1)*12) + ", overlap: "+ fma['overLap'] ) );
        
        if (fma['featureSegDetails'].length > 0){
            var fSegArr = fma['featureSegDetails'].split(",")[1].split("--"); //18,2~120--0~2
            console.log("fSegArr: "+ fSegArr);
            if (typeof fSegArr[0] != 'undefined' && fSegArr[0].length > 0) {
                var rect = (new fabric.Rect({
                    id: 10,
                    left: self.offsetArray[parseInt(fSegArr[0].split("~")[0])],
                    top: by + (self.breakLineWidth * 1.5) +  (parseInt(spacing) * (parseInt(fma['overLap']) - 1)) + (parseInt(fma['overLap']) - 1)*12 ,
                    width: self.offsetArray[parseInt(fSegArr[0].split("~")[1])] - self.offsetArray[parseInt(fSegArr[0].split("~")[0])],
                    height: 12,
                    fill: fma['color'],
                    stroke: '#000000',
                    strokeWidth: 1,
                    //visible: true,
                    hasControls: false,
                    perPixelTargetFind: true,
                    selectable: false,
                })); 
                
                //to add the custom variable to the rectangle
                fabric.Rect.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        arrId: this.arrId,
                        highLightId: this.highLightId});
                    };
                })(fabric.Rect.prototype.toObject);
                
                rect.arrId = fma['arrayConn'];
                rect.highLightId = startId2+"#"+endId2+"#"+self.canvas2.getObjects().length+"#"+(self.canvas2.getObjects().length+2);
                
                rect.async = true;
                drawRect = true;
            }
            
            if (typeof fSegArr[1] != 'undefined') {
                var x1 = self.offsetArray[parseInt(fSegArr[1].split("~")[0])];
                var y1 = by + (self.breakLineWidth * 1.5) +  (parseInt(spacing) * (parseInt(fma['overLap']) - 1)) + (parseInt(fma['overLap'] - 1)*12) + 6;
                var x2 = self.offsetArray[parseInt(fSegArr[1].split("~")[1])];
                var y2 = by + (self.breakLineWidth * 1.5) +  (parseInt(spacing) * (parseInt(fma['overLap']) - 1)) + (parseInt(fma['overLap'] - 1)*12) + 6;
                
                if (fSegArr[1] != ""){
                    var line = new fabric.Line([x1, y1, x2, y2], {
                        id: canvasObjCount,
                        stroke: 'blue',
                        strokeDashArray: [6, 5],
                        strokeWidth: 2,
                        selection: false
                    });
                }
                
                //to add the custom variable to the line
                fabric.Line.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        arrId: this.arrId,
                        highLightId: this.highLightId});
                    };
                })(fabric.Line.prototype.toObject);
                
                line.arrId = fma['arrayConn'];
                line.highLightId = startId2+"#"+endId2+"#"+self.canvas2.getObjects().length+"#"+(self.canvas2.getObjects().length+2);
                
                line.async = true;
                drawLine = true;
            }
            
            var txt = (new fabric.Text(fma['featureName'], {
                fontSize: 10,
                fillStyle: 'black',
                fontWeight: 'bold',
                left:  self.offsetArray[parseInt(fma['startPos'])] + (self.offsetArray[parseInt(fma['endPos'])] - self.offsetArray[parseInt(fma['startPos'])])/2,
                top:   by + (self.breakLineWidth * 1.5) +  (parseInt(spacing) * (parseInt(fma['overLap']) - 1)) + (parseInt(fma['overLap'] - 1)*12) + 12,
                textAlign: 'center',
            }));
            
            if (drawRect && !drawLine) {
                var name = new fabric.Group([rect, txt], {
                    id: 100,
                    originX: 'center',
                    originY: 'center',
                    hasControls: false,
                    hasBorders: false,
                    perPixelTargetFind: true,
                    selection: false
                });
                self.canvas2.add(highlightRect);
                self.canvas2.add(name);
            }
            else if (drawLine && drawRect) {
                var name = new fabric.Group([rect, line, txt], {
                    id: 100,
                    originX: 'center',
                    originY: 'center',
                    hasControls: false,
                    hasBorders: false,
                    perPixelTargetFind: true,
                    selectable: false,
                });
                self.canvas2.add(highlightRect);
                self.canvas2.add(name);
            }
            else if (drawLine && !drawRect) {
                var name = new fabric.Group([line, txt], {
                    id: 100,
                    originX: 'center',
                    originY: 'center',
                    hasControls: false,
                    hasBorders: false,
                    perPixelTargetFind: true,
                    selectable: false,
                });
                self.canvas2.add(highlightRect);
                self.canvas2.add(name);
            }
            var pushStr = {'canvasId':self.canvas2.getObjects().length, 'start':fma['startPos'], 'end':fma['endPos'], 'highLightId':(self.canvas2.getObjects().length - 1), 'type':"feature"};
            self.canvas2ItemArray.push(pushStr);
        }
        else {
            var rect = (new fabric.Rect({
                id: 10,
                left: self.offsetArray[parseInt(fma['startPos'])],
                top: by + (self.breakLineWidth * 1.5) +  (parseInt(spacing) * (parseInt(fma['overLap']) - 1)) + (parseInt(fma['overLap']) - 1)*12,
                width: self.offsetArray[parseInt(fma['endPos'])] - self.offsetArray[parseInt(fma['startPos'])],
                height: 12,
                fill: fma['color'],
                stroke: '#000000',
                strokeWidth: 1,
                hasControls: false,
                perPixelTargetFind: true,
                borderColor: 'red',
                selectable: false,
            })); 


            //to add the custom variable to the rectangle
            fabric.Rect.prototype.toObject = (function(toObject) {
                return function() {
                    return fabric.util.object.extend(toObject.call(this), {
                    arrId: this.arrId,
                    highLightId: this.highLightId});
                };
            })(fabric.Rect.prototype.toObject);
            
            rect.arrId = fma['arrayConn'];
            rect.highLightId = startId2+"#"+endId2+"#"+self.canvas2.getObjects().length+"#"+(self.canvas2.getObjects().length+2);
            rect.async = true;
            
            var txt = (new fabric.Text(fma['featureName'], {
                fontSize: 10,
                fillStyle: 'black',
                fontWeight: 'bold',
                left:  self.offsetArray[parseInt(fma['startPos'])] + (self.offsetArray[parseInt(fma['endPos'])] - self.offsetArray[parseInt(fma['startPos'])])/2,
                top:   by + (self.breakLineWidth * 1.5) +  (parseInt(spacing) * (parseInt(fma['overLap']) - 1)) + (parseInt(fma['overLap']) - 1)*12,
                textAlign: 'center',
            }));
            
            
            var name = new fabric.Group([rect, txt], {
                id: 100,
                originX: 'center',
                originY: 'center',
                hasControls: false,
                hasBorders: false,
                perPixelTargetFind: true,
                selectable: false,
            });
            
            self.canvas2.add(highlightRect);
            self.canvas2.add(name);
            
            var pushStr = {'canvasId':self.canvas2.getObjects().length, 'start':fma['startPos'], 'end':fma['endPos'], 'highLightId':(self.canvas2.getObjects().length - 1), 'type':"feature"};
            self.canvas2ItemArray.push(pushStr);
        }
        
        //top and bottom lines
        var x1 = self.offsetArray[parseInt(fma['startPos'])];
        var y1 = by + (self.breakLineWidth * 1.5) +  (parseInt(spacing) * (parseInt(fma['overLap']) - 1)) + (parseInt(fma['overLap']) - 1)*12;
        var x2 = self.offsetArray[parseInt(fma['endPos'])];
        
        var line1 = new fabric.Line([x1, (y1 - 2), x2, (y1 - 2)], {
            stroke: 'red',
            strokeWidth: 1,
        });
        
        var line2 = new fabric.Line([x1, (y1 + 12), x2, (y1 + 12)], {
            stroke: 'red',
            strokeWidth: 1,
        });
        
        //check if its the beginning or end of feature rectangle
        var chkType = fma['typeOfRow'];
        
        if (chkType == "begin") {
            var lineV1 = new fabric.Line([x1-2, (y1-2), x1-2, (y1+12)], {
                stroke: 'red',
                strokeWidth: 1,
            }); 

            var lineGroup = new fabric.Group([line1, line2, lineV1], {
                id: 100,
                originX: 'center',
                originY: 'center',
                hasControls: false,
                hasBorders: false,
                visible: false,
                perPixelTargetFind: true,
                selectable: false,
            });
        }
        else if (chkType == "begin&end") {
            var lineV1 = new fabric.Line([x1-2, (y1-2), x1-2, (y1+12)], {
                stroke: 'red',
                strokeWidth: 1,
            });                 
            
            var lineV2 = new fabric.Line([x2, (y1-2), x2, (y1+12)], {
                stroke: 'red',
                strokeWidth: 1,
            }); 

            var lineGroup = new fabric.Group([line1, line2, lineV1, lineV2], {
                id: 100,
                originX: 'center',
                originY: 'center',
                hasControls: false,
                hasBorders: false,
                visible: false,
                perPixelTargetFind: true,
                selectable: false,
            });
        }
        else if(chkType == "end") {
            var lineV2 = new fabric.Line([x2, (y1-2), x2, (y1+12)], {
                stroke: 'red',
                strokeWidth: 1,
            });
            
            var lineGroup = new fabric.Group([line1, line2, lineV2], {
                id: 100,
                originX: 'center',
                originY: 'center',
                hasControls: false,
                hasBorders: false,
                visible: false,
                perPixelTargetFind: true,
                selectable: false,
            });
        }
        else {
            var lineGroup = new fabric.Group([line1, line2], {
                id: 100,
                originX: 'center',
                originY: 'center',
                hasControls: false,
                hasBorders: false,
                visible: false,
                perPixelTargetFind: true,
                selectable: false,
            });
        }
            
        self.canvas2.add(lineGroup);   
        
        /** Updating the high lighting ids with display of every row, we need to highlight all the rows with the feature band  **/
        var count = 0;
        for (var k = 0; k < self.canvas2.getObjects().length; k ++){
            var obj = self.canvas2.item(k);
            
            if (obj.isType('group') && (obj.id == 100) && obj.item(0).arrId == fma['arrayConn']) { 
                if (count == 0) {
                    if (obj.item(0).highLightId.split("#")[2] == (self.canvas2.getObjects().length - 3)) {
                        var hId = obj.item(0).highLightId;
                    }
                    else {
                        var hId = obj.item(0).highLightId +"#"+ (self.canvas2.getObjects().length - 3) +"#"+ (self.canvas2.getObjects().length-1 );
                    }
                }
                obj.item(0).highLightId = hId;
                count = count + 1;
            }
        }
        
    }
}


ArxDraw.prototype.fabric_ORFs = function(o1, o2, o3, o4, o5, o6, howManyTranslations, transOffset, words, by, lineBreak) {
    var self = this;
    console.log("fabric_ORFs lineBreak : "+ lineBreak + ", transOffset: " + transOffset);
    //console.log("ORF1: "+ JSON.stringify(o1) );
    //console.log("ORF2: "+ JSON.stringify(o2) );
    //console.log("ORF3: "+ JSON.stringify(o3) );

    for (var i = 0; i < o1.length; i++) {  //{"startPos":231,"endPos":624,"basePairs":393}
        //Break the lenth of the orfs according to each row and highlight
        var startPos = o1[i]['startPos'];
        var endPos = o1[i]['endPos'];
        //console.log("ORF1s pos: "+ startPos +", "+ endPos+", "+ self.startId2);
        var getTheStartRow = Math.floor(parseInt(startPos)/parseInt(words));
        var checkEndPosIsLastLetter = parseInt(endPos)/parseInt(words);
        var getTheEndRow = Math.floor(parseInt(endPos)/parseInt(words));
        console.log("O1: "+ self.startId2 +", "+ self.endId2 + ", "+ getTheStartRow + ", " + getTheEndRow + ", b:" + b);
        //var transWidth = Math.abs(howManyTranslations) * 12 + (Math.abs(howManyTranslations) - 1 ) * 10 + self.breakLineWidth * 0.5;
        if ((getTheStartRow == self.startId2 || getTheStartRow >= self.startId2) && getTheStartRow < self.endId2) {
            if (getTheStartRow == getTheEndRow || checkEndPosIsLastLetter == getTheEndRow) {
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow; 
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var s = self.offsetArray[getTheStartPos];
                var e = self.offsetArray[getTheEndPos];
                var y1 = lineBreak[getTheStartRow - self.startId2 + 1];
                
                var rectangle = (new fabric.Rect({
                    id: 111,
                    left: s,
                    //top: transOffset + (Math.abs(howManyTranslations) - 2)*15
                    top: y1+ 15 - ( (Math.abs(howManyTranslations) * 12 + (Math.abs(howManyTranslations)) * 10) + self.breakLineWidth * 0.5 ),
                    width: (e - s),
                    height: 12,
                    fill: '#FF3333',
                    stroke: '#484848',
                    strokeWidth: 1,
                    opacity: 0.2,
                    hasControls: false,
                    selectable: false,
                }));
                
                //to add the custom variable to the rectangle
                fabric.Rect.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        orfDetails: this.orfDetails,
                        orfRow: this.orfRow,
                        orfNum: this.orfNum });
                    };
                })(fabric.Rect.prototype.toObject);
                
                rectangle.orfDetails = "ORF1: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                rectangle.orfRow = getTheStartRow;
                rectangle.orfNum = 1;
                rectangle.async = true;
                
                self.canvas2.add(rectangle);
            }
            else {             
                var getTheStartPos = parseInt(startPos) - parseInt(words) * getTheStartRow;
                var seqBreak1 = words;
                var seqBreak2 = 0;
                var getTheEndPos = parseInt(endPos) - parseInt(words) * getTheEndRow;
                
                var x1 = self.offsetArray[getTheStartPos];
                var x2 = self.offsetArray[parseInt(words)];
                var x3 = self.offsetArray[0];
                var x4 = self.offsetArray[getTheEndPos + 3];
                var y1 = lineBreak[getTheStartRow - self.startId2 + 1];
                var y2 = lineBreak[getTheEndRow - self.startId2];
                
                for (var j = getTheStartRow; j < getTheEndRow+1 ; j++) {
                    if (j < self.endId2) {
                        if (j == getTheStartRow) {
                            var s = x1;
                            var e = x2; // +3 nucleotide pairs
                        }
                        else if (j == getTheEndRow) {
                            var s = x3;
                            var e = x4;
                        }
                        else {
                            var s = x3;
                            var e = x2;
                        }
                        var y1 = lineBreak[j - self.startId2 + 1];
                        var rectangle = (new fabric.Rect({
                            id: 111,
                            left: s,
                            //top: b+y1 - (Math.abs(howManyTranslations) * 12 + (Math.abs(howManyTranslations)) * 10),
                            top: y1 + 15 - ( (Math.abs(howManyTranslations) * 12 + (Math.abs(howManyTranslations)) * 10) + self.breakLineWidth * 0.5 ) - 5,
                            width: (e - s),
                            height: 12,
                            fill: '#FF3333',
                            stroke: '#484848',
                            strokeWidth: 1,
                            opacity: 0.2,
                            hasControls: false,
                            selectable: false,
                        }));
                        
                        //to add the custom variable to the rectangle
                        fabric.Rect.prototype.toObject = (function(toObject) {
                            return function() {
                                return fabric.util.object.extend(toObject.call(this), {
                                orfDetails: this.orfDetails,
                                orfRow: this.orfRow,
                                orfNum: this.orfNum });
                            };
                        })(fabric.Rect.prototype.toObject);
                        
                        rectangle.orfDetails = "ORF1: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                        rectangle.orfRow = j;
                        rectangle.orfNum = 1;
                        rectangle.async = true;
                        
                        self.canvas2.add(rectangle);
                        var obj = self.canvas2.item(self.canvas2.size());
                    }
                }
            }
            
        }
    }
    
    for (var i = 0; i < o2.length; i++) {  //{"startPos":231,"endPos":624,"basePairs":393}
        var startPos = o2[i]['startPos'];
        var endPos = o2[i]['endPos'];
        console.log("ORF2s pos: "+ startPos +", "+ endPos);
        var getTheStartRow = Math.floor(parseInt(startPos)/parseInt(words));
        var checkEndPosIsLastLetter = parseInt(endPos)/parseInt(words);
        var getTheEndRow = Math.floor(parseInt(endPos)/parseInt(words));
        console.log("O2: "+ self.startId2 + ", "+ getTheStartRow + ", " + getTheEndRow);

        if ((getTheStartRow == self.startId2 || getTheStartRow >= self.startId2) && getTheStartRow < self.endId2){
            if (getTheStartRow == getTheEndRow || checkEndPosIsLastLetter == getTheEndRow) {
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow; 
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var s = self.offsetArray[getTheStartPos];
                var e = self.offsetArray[getTheEndPos];
                var y1 = lineBreak[getTheStartRow - self.startId2 + 1];
                
                var rectangle = (new fabric.Rect({
                    id: 111,
                    left: s,
                    //top: b+y1 - 65,
                    //top: b+y1 - (Math.abs(howManyTranslations - 1) * 12 + (Math.abs(howManyTranslations)) * 10) + 5,
                    top: y1 + (Math.abs(howManyTranslations)- 2)*15  - ( ((Math.abs(howManyTranslations) ) * 12 + (Math.abs(howManyTranslations)-1) * 10) + self.breakLineWidth * 0.5 ),
                    width: (e - s),
                    height: 12,
                    fill: '#FF3333',
                    stroke: '#484848',
                    strokeWidth: 1,
                    opacity: 0.2,
                    hasControls: false,
                    selectable: false,
                }));
                
                //to add the custom variable to the rectangle
                fabric.Rect.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        orfDetails: this.orfDetails,
                        orfRow: this.orfRow,
                        orfNum: this.orfNum});
                    };
                })(fabric.Rect.prototype.toObject);
                
                rectangle.orfDetails = "ORF2: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                rectangle.orfRow = getTheStartRow;
                rectangle.orfNum = 2;
                rectangle.async = true;
                
                self.canvas2.add(rectangle);
            }
            else {             
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow;
                var seqBreak1 = words;
                var seqBreak2 = 0;
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var x1 = self.offsetArray[getTheStartPos];
                var x2 = self.offsetArray[parseInt(words)];
                var x3 = self.offsetArray[0];
                var x4 = self.offsetArray[getTheEndPos + 3];
                var y1 = lineBreak[getTheStartRow - self.startId2];
                var y2 = lineBreak[getTheEndRow - self.startId2];
                
                for (var j = getTheStartRow; j < getTheEndRow+1 ; j++) {
                    if (j < self.endId2) {
                        if (j == getTheStartRow) {
                            var s = x1;
                            var e = x2; // +3 nucleotide pairs
                        }
                        else if (j == getTheEndRow) {
                            var s = x3;
                            var e = x4;
                        }
                        else {
                            var s = x3;
                            var e = x2;
                        }
                        var y1 = lineBreak[j - self.startId2 + 1];
                        
                        var rectangle = (new fabric.Rect({
                            id: 111,
                            left: s,
                            //top: b+y1 - 50,
                            //top: b+y1 - (Math.abs(howManyTranslations - 1) * 12 + (Math.abs(howManyTranslations)) * 10) + 5,
                            //top: y1 + (Math.abs(howManyTranslations) - 2)*15 - ( ((Math.abs(howManyTranslations)) * 12 + (Math.abs(howManyTranslations)-1) * 10) + self.breakLineWidth * 0.5 ),
                            top: y1 + (3 - 2)*15 - ( ((Math.abs(howManyTranslations)) * 12 + (Math.abs(howManyTranslations)-1) * 10) + self.breakLineWidth * 0.5 ),
                            width: (e - s),
                            height: 12,
                            fill: '#FF3333',
                            stroke: '#484848',
                            strokeWidth: 1,
                            opacity: 0.2,
                            hasControls: false,
                            selectable: false,
                        }));
                        
                        //to add the custom variable to the rectangle
                        fabric.Rect.prototype.toObject = (function(toObject) {
                            return function() {
                                return fabric.util.object.extend(toObject.call(this), {
                                orfDetails: this.orfDetails,
                                orfRow: this.orfRow,
                                orfNum: this.orfNum});
                            };
                        })(fabric.Rect.prototype.toObject);
                        
                        rectangle.orfDetails = "ORF2: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                        rectangle.orfRow = j;
                        rectangle.orfNum = 2;
                        rectangle.async = true;
                        self.canvas2.add(rectangle);
                    }
                    console.log("ORF2 top: "+ (b+y1 - (Math.abs(howManyTranslations - 1) * 12 + (Math.abs(howManyTranslations)) * 10) + 5) + ", " + j);
                }
            }
        }
    }
    
    for (var i = 0; i < o3.length; i++) {  //{"startPos":231,"endPos":624,"basePairs":393}
        //Break the lenth of the orfs according to each row and highlight
        var startPos = o3[i]['startPos'];
        var endPos = o3[i]['endPos'];
        var getTheStartRow = Math.floor(parseInt(startPos)/parseInt(words));
        //console.log("ORF3s pos: "+ startPos +", "+ endPos + ", "+ self.startId2 + ", "+ getTheStartRow);
        var checkEndPosIsLastLetter = parseInt(endPos)/parseInt(words);
        var getTheEndRow = Math.floor(parseInt(endPos)/parseInt(words));
        //console.log("O3: "+ self.startId2 + ", "+ getTheStartRow + ", " + getTheEndRow);

        if ((getTheStartRow == self.startId2 || getTheStartRow >= self.startId2) && getTheStartRow < self.endId2){
            if (getTheStartRow == getTheEndRow || checkEndPosIsLastLetter == getTheEndRow) {
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow; 
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var s = self.offsetArray[getTheStartPos];
                var e = self.offsetArray[getTheEndPos];
                var y1 = lineBreak[getTheStartRow - self.startId2 + 1];
                
                var rectangle = (new fabric.Rect({
                    id: 111,
                    left: s,
                    //top: b+y1 - 65,
                    top: y1 + (Math.abs(howManyTranslations) - 1)*15 - ( ((Math.abs(howManyTranslations)) * 12 + (Math.abs(howManyTranslations)-1) * 10) + self.breakLineWidth * 0.5 ),
                    width: (e - s),
                    height: 12,
                    fill: '#FF3333',
                    stroke: '#484848',
                    strokeWidth: 1,
                    opacity: 0.2,
                    hasControls: false,
                    selectable: false,
                }));
                
                //to add the custom variable to the rectangle
                fabric.Rect.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        orfDetails: this.orfDetails,
                        orfRow: this.orfRow,
                        orfNum: this.orfNum});
                    };
                })(fabric.Rect.prototype.toObject);
                
                rectangle.orfDetails = "ORF3: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                rectangle.orfRow = getTheStartRow;
                rectangle.orfNum = 3;
                rectangle.async = true;
                
                self.canvas2.add(rectangle);
            }
            else {
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow;
                var seqBreak1 = words;
                var seqBreak2 = 0;
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var x1 = self.offsetArray[getTheStartPos];
                var x2 = self.offsetArray[parseInt(words)];
                var x3 = self.offsetArray[0];
                var x4 = self.offsetArray[getTheEndPos + 3];
                var y1 = lineBreak[getTheStartRow - self.startId2];
                var y2 = lineBreak[getTheEndRow - self.startId2];
                
                for (var j = getTheStartRow; j < getTheEndRow+1 ; j++) {
                    if (j < self.endId2) {
                        if (j == getTheStartRow) {
                            var s = x1;
                            var e = x2; // +3 nucleotide pairs
                        }
                        else if (j == getTheEndRow) {
                            var s = x3;
                            var e = x4;
                        }
                        else {
                            var s = x3;
                            var e = x2;
                        }
                        var y1 = lineBreak[j - self.startId2 + 1];
                        
                        var rectangle = (new fabric.Rect({
                            id: 111,
                            left: s,
                            //top: y1 + (Math.abs(howManyTranslations) - 1)*15 - ( ((Math.abs(howManyTranslations)) * 12 + (Math.abs(howManyTranslations)-1) * 10) + self.breakLineWidth * 0.5 ),
                            top: y1 + (3 - 2)*15 - ( ((Math.abs(howManyTranslations)-1) * 12 + (Math.abs(howManyTranslations)-1) * 10) + self.breakLineWidth * 0.5 ) + 5,
                            width: (e - s),
                            height: 12,
                            fill: '#FF3333',
                            stroke: '#484848',
                            strokeWidth: 1,
                            opacity: 0.2,
                            hasControls: false,
                            selectable: false,
                        }));
                        
                        //to add the custom variable to the rectangle
                        fabric.Rect.prototype.toObject = (function(toObject) {
                            return function() {
                                return fabric.util.object.extend(toObject.call(this), {
                                orfDetails: this.orfDetails,
                                orfRow: this.orfRow,
                                orfNum: this.orfNum});
                            };
                        })(fabric.Rect.prototype.toObject);
                        
                        rectangle.orfDetails = "ORF3: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                        rectangle.orfRow = j;
                        rectangle.orfNum = 3;
                        rectangle.async = true;
                        self.canvas2.add(rectangle);
                    }
                }
            }
        }
    }
    
    for (var i = 0; i < o4.length; i++) {  //{"startPos":231,"endPos":624,"basePairs":393}
        //Break the lenth of the orfs according to each row and highlight
        var startPos = o4[i]['startPos'];
        var endPos = o4[i]['endPos'];
        var getTheStartRow = Math.floor(parseInt(startPos)/parseInt(words));
        var checkEndPosIsLastLetter = parseInt(endPos)/parseInt(words);
        var getTheEndRow = Math.floor(parseInt(endPos)/parseInt(words));
        
        //console.log("ORF4s pos: "+ startPos +", "+ endPos +", "+ getTheStartRow +", "+getTheEndRow+", "+self.startId2 +", "+ self.endId2);
                
        if ((getTheStartRow == self.startId2 || getTheStartRow >= self.startId2) && getTheStartRow < self.endId2) {
            if (getTheStartRow == getTheEndRow || checkEndPosIsLastLetter == getTheEndRow) {
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow; 
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var s = self.offsetArray[getTheStartPos];
                var e = self.offsetArray[getTheEndPos];
                var y1 = lineBreak[getTheStartRow - self.startId2 + 1];
                
                var rectangle = (new fabric.Rect({
                    id: 111,
                    left: s,
                    top: y1 + (Math.abs(howManyTranslations) - 1)*15 - ( ((Math.abs(howManyTranslations)) * 12 + (Math.abs(howManyTranslations)-1) * 10) + self.breakLineWidth * 0.5 ),
                    width: (e - s),
                    height: 12,
                    fill: '#FF3333',
                    stroke: '#484848',
                    strokeWidth: 1,
                    opacity: 0.2,
                    hasControls: false,
                    selectable: false,
                }));
                
                //to add the custom variable to the rectangle
                fabric.Rect.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        orfDetails: this.orfDetails,
                        orfRow: this.orfRow,
                        orfNum: this.orfNum});
                    };
                })(fabric.Rect.prototype.toObject);
                
                rectangle.orfDetails = "ORF4: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                rectangle.orfRow = getTheStartRow;
                rectangle.orfNum = 4;
                rectangle.async = true;
                
                self.canvas2.add(rectangle);
            }
            else {             
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow;
                var seqBreak1 = words;
                var seqBreak2 = 0;
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var x1 = self.offsetArray[getTheStartPos - 1];
                var x2 = self.offsetArray[parseInt(words)];
                var x3 = self.offsetArray[0];
                var x4 = self.offsetArray[getTheEndPos + 2];
                var y1 = lineBreak[getTheStartRow - self.startId2];
                var y2 = lineBreak[getTheEndRow - self.startId2];
                
                for (var j = getTheStartRow; j < getTheEndRow+1 ; j++) {
                    if (j < self.endId2) {
                        if (j == getTheStartRow) {
                            var s = x1;
                            var e = x2; // +3 nucleotide pairs
                        }
                        else if (j == getTheEndRow) {
                            var s = x3;
                            var e = x4;
                        }
                        else {
                            var s = x3;
                            var e = x2;
                        }
                        var y1 = lineBreak[j - self.startId2 + 1];
                        
                        var rectangle = (new fabric.Rect({
                            id: 111,
                            left: s,
                            top: y1 + (Math.abs(howManyTranslations) - 2)*15 - ( ((Math.abs(howManyTranslations)) * 12 + (Math.abs(howManyTranslations)-1) * 10) + self.breakLineWidth * 0.5 ),
                            width: (e - s),
                            height: 12,
                            fill: '#009900',
                            stroke: '#484848',
                            strokeWidth: 1,
                            opacity: 0.2,
                            hasControls: false,
                            selectable: false,
                        }));
                        
                        //to add the custom variable to the rectangle
                        fabric.Rect.prototype.toObject = (function(toObject) {
                            return function() {
                                return fabric.util.object.extend(toObject.call(this), {
                                orfDetails: this.orfDetails,
                                orfRow: this.orfRow,
                                orfNum: this.orfNum});
                            };
                        })(fabric.Rect.prototype.toObject);
                        
                        rectangle.orfDetails = "ORF4: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                        rectangle.orfRow = j;
                        rectangle.orfNum = 4;
                        rectangle.async = true;
                        self.canvas2.add(rectangle);
                    }
                }
            }
        }
    }
    
    for (var i = 0; i < o5.length; i++) {  //{"startPos":231,"endPos":624,"basePairs":393}
        //Break the lenth of the orfs according to each row and highlight
        var startPos = o5[i]['startPos'];
        var endPos = o5[i]['endPos'];
        var getTheStartRow = Math.floor(parseInt(startPos)/parseInt(words));
        var checkEndPosIsLastLetter = parseInt(endPos)/parseInt(words);
        var getTheEndRow = Math.floor(parseInt(endPos)/parseInt(words));
        //console.log("ORF5s pos: "+ startPos +", "+ endPos +", "+ getTheStartRow +", "+getTheEndRow+", "+self.startId2 +", "+ self.endId2);
        
        if ((getTheStartRow == self.startId2 || getTheStartRow >= self.startId2) && getTheStartRow < self.endId2){
            if (getTheStartRow == getTheEndRow || checkEndPosIsLastLetter == getTheEndRow) {
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow; 
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var s = self.offsetArray[getTheStartPos];
                var e = self.offsetArray[getTheEndPos];
                var y1 = lineBreak[getTheStartRow - self.startId2 + 1];
                
                var rectangle = (new fabric.Rect({
                    id: 111,
                    left: s,
                    top: y1 - (Math.abs(howManyTranslations - 4) * 12 + (Math.abs(howManyTranslations - 3)) * 10),
                    width: (e - s),
                    height: 12,
                    fill: '#FF3333',
                    stroke: '#484848',
                    strokeWidth: 1,
                    opacity: 0.2,
                    hasControls: false,
                    selectable: false,
                }));
                
                //to add the custom variable to the rectangle
                fabric.Rect.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        orfDetails: this.orfDetails,
                        orfRow: this.orfRow,
                        orfNum: this.orfNum});
                    };
                })(fabric.Rect.prototype.toObject);
                
                rectangle.orfDetails = "ORF5: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                rectangle.orfRow = getTheStartRow;
                rectangle.orfNum = 5;
                rectangle.async = true;
                
                self.canvas2.add(rectangle);
            }
            else {             
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow;
                var seqBreak1 = words;
                var seqBreak2 = 0;
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var x1 = self.offsetArray[getTheStartPos - 1];
                var x2 = self.offsetArray[parseInt(words)];
                var x3 = self.offsetArray[0];
                var x4 = self.offsetArray[getTheEndPos + 2];
                var y1 = lineBreak[getTheStartRow - self.startId2];
                var y2 = lineBreak[getTheEndRow - self.startId2];
                
                for (var j = getTheStartRow; j < getTheEndRow+1 ; j++) {
                    if (j < self.endId2) {
                        if (j == getTheStartRow) {
                            var s = x1;
                            var e = x2; // +3 nucleotide pairs
                        }
                        else if (j == getTheEndRow) {
                            var s = x3;
                            var e = x4;
                        }
                        else {
                            var s = x3;
                            var e = x2;
                        }
                        var y1 = lineBreak[j - self.startId2 + 1];
                        
                        var rectangle = (new fabric.Rect({
                            id: 111,
                            left: s,
                            top: y1 + (Math.abs(howManyTranslations) - 1)*15 - ( ((Math.abs(howManyTranslations)) * 12 + (Math.abs(howManyTranslations)-1) * 10) + self.breakLineWidth * 0.5 ),
                            width: (e - s),
                            height: 12,
                            fill: '#009900',
                            stroke: '#484848',
                            strokeWidth: 1,
                            opacity: 0.2,
                            hasControls: false,
                            selectable: false,
                        }));
                        
                        //to add the custom variable to the rectangle
                        fabric.Rect.prototype.toObject = (function(toObject) {
                            return function() {
                                return fabric.util.object.extend(toObject.call(this), {
                                orfDetails: this.orfDetails,
                                orfRow: this.orfRow,
                                orfNum: this.orfNum});
                            };
                        })(fabric.Rect.prototype.toObject);
                        
                        rectangle.orfDetails = "ORF5: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                        rectangle.orfRow = j;
                        rectangle.orfNum = 5;
                        rectangle.async = true;
                        
                        self.canvas2.add(rectangle);
                    }
                }
            }
        }
    }
    
    for (var i = 0; i < o6.length; i++) {  //{"startPos":231,"endPos":624,"basePairs":393}
        //Break the lenth of the orfs according to each row and highlight
        var startPos = o6[i]['startPos'];
        var endPos = o6[i]['endPos'];
        
        var getTheStartRow = Math.floor(parseInt(startPos)/parseInt(words));
        var checkEndPosIsLastLetter = parseInt(endPos)/parseInt(words);
        var getTheEndRow = Math.floor(parseInt(endPos)/parseInt(words));
        //console.log("ORF6s pos: "+ startPos +", "+ endPos +", "+ getTheStartRow +", "+getTheEndRow+", "+self.startId2 +", "+ self.endId2);
        
        if ((getTheStartRow == self.startId2 || getTheStartRow >= self.startId2) && getTheStartRow < self.endId2){
            if (getTheStartRow == getTheEndRow || checkEndPosIsLastLetter == getTheEndRow) {
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow; 
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var s = self.offsetArray[getTheStartPos];
                var e = self.offsetArray[getTheEndPos];
                var y1 = lineBreak[getTheStartRow - self.startId2 + 1];
                
                var rectangle = (new fabric.Rect({
                    id: 111,
                    left: s,
                    top: b+y1 - (Math.abs(howManyTranslations - 5) * 12 + (Math.abs(howManyTranslations - 4)) * 10),
                    width: (e - s),
                    height: 12,
                    fill: '#FF3333',
                    stroke: '#484848',
                    strokeWidth: 1,
                    opacity: 0.2,
                    hasControls: false,
                    selectable: false,
                }));
                
                //to add the custom variable to the rectangle
                fabric.Rect.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        orfDetails: this.orfDetails,
                        orfRow: this.orfRow,
                        orfNum: this.orfNum});
                    };
                })(fabric.Rect.prototype.toObject);
                
                rectangle.orfDetails = "ORF6: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                rectangle.orfRow = getTheStartRow;
                rectangle.orfNum = 6;
                rectangle.async = true;
                
                self.canvas2.add(rectangle);
            }
            else {             
                var getTheStartPos = parseInt(startPos) - parseInt(words)*getTheStartRow;
                var seqBreak1 = words;
                var seqBreak2 = 0;
                var getTheEndPos = parseInt(endPos) - parseInt(words)*getTheEndRow;
                
                var x1 = self.offsetArray[getTheStartPos - 1];
                var x2 = self.offsetArray[parseInt(words)];
                var x3 = self.offsetArray[0];
                var x4 = self.offsetArray[getTheEndPos + 2];
                var y1 = lineBreak[getTheStartRow - self.startId2];
                var y2 = lineBreak[getTheEndRow - self.startId2];

                for (var j = getTheStartRow; j < getTheEndRow+1 ; j++) {
                    if (j < self.endId2) {
                        if (j == getTheStartRow) {
                            var s = x1;
                            var e = x2; // +3 nucleotide pairs
                        }
                        else if (j == getTheEndRow) {
                            var s = x3;
                            var e = x4;
                        }
                        else {
                            var s = x3;
                            var e = x2;
                        }
                        var y1 = lineBreak[j - self.startId2 + 1];
                        
                        var rectangle = (new fabric.Rect({
                            id: 111,
                            left: s,
                            top: y1 + (Math.abs(howManyTranslations))*15 - ( ((Math.abs(howManyTranslations)) * 12 + (Math.abs(howManyTranslations)-1) * 10) + self.breakLineWidth * 0.5 ),
                            width: (e - s),
                            height: 12,
                            fill: '#009900',
                            stroke: '#484848',
                            strokeWidth: 1,
                            opacity: 0.2,
                            hasControls: false,
                            selectable: false,
                        }));
                        
                        //to add the custom variable to the rectangle
                        fabric.Rect.prototype.toObject = (function(toObject) {
                            return function() {
                                return fabric.util.object.extend(toObject.call(this), {
                                orfDetails: this.orfDetails,
                                orfRow: this.orfRow,
                                orfNum: this.orfNum});
                            };
                        })(fabric.Rect.prototype.toObject);
                        
                        rectangle.orfDetails = "ORF6: "+ startPos +" .. "+ endPos +" = "+ (endPos - startPos) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;" + (endPos - startPos)/3 + " amino acids";
                        rectangle.orfRow = j;
                        rectangle.orfNum = 5;
                        rectangle.async = true;
                        
                        self.canvas2.add(rectangle);
                    }
                }
            }
        }
    }
}


ArxDraw.prototype.fabric_amenoAcidTranslations = function(p1, p2 ,p3 ,m1 ,m2, m3, q, howManyTranslations, transOffset, wordsInALine, by, translationType) {
    //Place a rect with width of 3 base pairs and move it according to the appropriate position
    var self = this;
    var plus1 = p1;
    var minus1 = m1;
    var plus2 = p2;
    var minus2 = m2;
    var plus3 = p3;
    var minus3 = m3;
    
    var startPos = (q) * wordsInALine;
    var aIds1 = [], aIds2 = [], aIds3 = [], aIds4 = [], aIds5 = [], aIds6 = [];
    
    var highlightRect = (new fabric.Rect({
        id: 10,
        left: self.offsetArray[0],
        top: by,
        width: (self.offsetArray[5] - self.offsetArray[2]), // +5 to make the rect little wider
        height: 20,
        fill: '#FFCC00',
        visible: false,
        hasControls: false,
        opacity: 0.4,
        selectable: false,
        stroke: 'black',
        strokeWidth: 1
    })); 
    self.canvas2.add(highlightRect); 
    var highlightTopId = self.canvas2.getObjects().length - 1;
    
    var highlightBottomRect = (new fabric.Rect({
        id: 10,
        left: self.offsetArray[0],
        top: by + 22,
        width: (self.offsetArray[5] - self.offsetArray[2]), // +5 to make the rect little wider
        height: 20,
        fill: '#FFCC00',
        visible: false,
        hasControls: false,
        opacity: 0.4,
        selectable: false,
        stroke: 'black',
        strokeWidth: 1
    })); 
    self.canvas2.add(highlightBottomRect); 
    var highlightBottomId = self.canvas2.getObjects().length - 1;
        
    if (howManyTranslations == 1) {
        
        for (var i = 0; i < plus1.length; i++) {
            if (translationType == "single"){
               var t1 = plus1[i][3];
            }
            else if (translationType == "three"){
                var t1 = plus1[i][2];
            }
            
            var iText = new fabric.IText(t1, { 
                id: 200,
                fontFamily: 'Courier', 
                left: self.offsetArray[(plus1[i][0] - startPos)], 
                top: transOffset,
                fontSize: 12,
                visible: true,
                selectable: false,
                fill: 'black'
            });
           
            //to add the custom variable to the IText
            fabric.IText.prototype.toObject = (function(toObject) {
                return function() {
                    return fabric.util.object.extend(toObject.call(this), {
                        highlightId: this.highlightId,
                        movePos: this.movePos,
                        name: this.name,
                        one: this.one,
                        three: this.three,
                        amenoRow: this.amenoRow,
                        left: this.left,
                        top: this.top,
                        right: this.right,
                        bottom: this.bottom
                    });
                };
            })(fabric.IText.prototype.toObject);
            
            if ((plus1[i][0] - startPos) == 0){
                var p = 0;
            }
            else {
                var p = (plus1[i][0] - startPos);
            }
            iText.movePos = self.offsetArray[p];
            iText.highlightId = highlightTopId;
            iText.name = self.objAmenoAcid[plus1[i][1]]['AminoAcid'];
            iText.three = self.objAmenoAcid[plus1[i][1]]['ThreeLetterCode'];
            iText.one = self.objAmenoAcid[plus1[i][1]]['OneLetterCode'];
            iText.amenoRow = q;
            iText.left = self.offsetArray[(plus1[i][0] - startPos)];
            iText.top = transOffset;
            iText.right = self.offsetArray[(plus1[i][0] - startPos)] + (self.offsetArray[2] - self.offsetArray[0]);
            iText.bottom = transOffset + 12;
            iText.async = true;
            
            self.canvas2.add(iText);
            aIds1.push(self.canvas2.getObjects().length-1);
        }
        self.amenoAcidIds[q+"_1"] = aIds1;   
    }
    else { 
        if (howManyTranslations == 3 || howManyTranslations == 6) {
            
            for (var i = 0; i < plus1.length; i++) {
                if (translationType == "single"){
                   var t1 = plus1[i][3];
                }
                else if (translationType == "three"){
                    var t1 = plus1[i][2];
                }
                //console.log("AMENO ACID LEFT & top: "+self.offsetArray[(plus1[i][0] - startPos)] +", "+ transOffset);
                var iText = new fabric.IText(t1, { 
                    id: 200,
                    fontFamily: 'Courier', 
                    left: self.offsetArray[(plus1[i][0] - startPos)], 
                    top: transOffset,
                    fontSize: 12,
                    visible: true,
                    fill: 'black',
                    selectable: false,
                });
               
                //to add the custom variable to the IText
                fabric.IText.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        highlightId: this.highlightId,
                        movePos: this.movePos,
                        name: this.name,
                        one: this.one,
                        three: this.three,
                        amenoRow: this.amenoRow,
                        left: this.left,
                        top: this.top,
                        right: this.right,
                        bottom: this.bottom
                       });
                    };
                })(fabric.IText.prototype.toObject);
                
                if (plus1[i][0] == startPos) {
                    var p = 0;
                }
                else {
                    var p = (plus1[i][0] - startPos);
                }
                iText.movePos = self.offsetArray[p];
                iText.highlightId = highlightTopId;
                iText.name = self.objAmenoAcid[plus1[i][1]]['AminoAcid'];
                iText.three = self.objAmenoAcid[plus1[i][1]]['ThreeLetterCode'];
                iText.one = self.objAmenoAcid[plus1[i][1]]['OneLetterCode'];
                iText.amenoRow = q;
                iText.left = self.offsetArray[(plus1[i][0] - startPos)];
                iText.top = transOffset;
                iText.right = self.offsetArray[(plus1[i][0] - startPos)] + (self.offsetArray[2] - self.offsetArray[0]) + 5;
                iText.bottom = transOffset + 12;
                iText.async = true;
                
                self.canvas2.add(iText);
                aIds1.push(self.canvas2.getObjects().length-1);
            }
            
            self.amenoAcidIds[q+"_1"] = aIds1; 
            
            for (var i = 0; i < plus2.length; i++) {
                if (translationType == "single"){
                    var t1 = plus2[i][3];
                }
                else if (translationType == "three"){
                    var t1 = plus2[i][2];
                }
                
                var iText = new fabric.IText(t1, { 
                    id: 200,
                    fontFamily: 'Courier', 
                    left: self.offsetArray[(plus2[i][0] - startPos)], 
                    top: transOffset + 15,
                    fontSize: 12,
                    visible: true,
                    fill: 'black',
                    selectable: false,
                });
               
                //to add the custom variable to the IText
                fabric.IText.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                            highlightId: this.highlightId,
                            movePos: this.movePos,
                            name: this.name,
                            one: this.one,
                            three: this.three,
                            amenoRow: this.amenoRow,
                            left: this.left,
                            top: this.top,
                            right: this.right,
                            bottom: this.bottom
                        });
                    };
                })(fabric.IText.prototype.toObject);
                
                if ((plus2[i][0] - startPos) == 1){
                    var p = 1;
                }
                else {
                    var p = (plus2[i][0] - startPos);
                }
                iText.movePos = self.offsetArray[p];
                iText.highlightId = highlightTopId;
                iText.name = self.objAmenoAcid[plus2[i][1]]['AminoAcid'];
                iText.three = self.objAmenoAcid[plus2[i][1]]['ThreeLetterCode'];
                iText.one = self.objAmenoAcid[plus2[i][1]]['OneLetterCode'];
                iText.amenoRow = q;
                iText.left = self.offsetArray[(plus2[i][0] - startPos)];
                iText.top = transOffset + 15;
                iText.right = self.offsetArray[(plus2[i][0] - startPos)] + (self.offsetArray[2] - self.offsetArray[0]) + 5;
                iText.bottom = transOffset + 15 + 12;                   
                iText.async = true;
                
                self.canvas2.add(iText);
                aIds2.push(self.canvas2.getObjects().length-1);
            }
            
            self.amenoAcidIds[q+"_2"] = aIds2; 
            
            for (var i = 0; i < plus3.length; i++) {
                if (translationType == "single"){
                   var t1 = plus3[i][3];
                }
                else if (translationType == "three"){
                    var t1 = plus3[i][2];
                }
                
                var iText = new fabric.IText(t1, { 
                    id: 200,
                    fontFamily: 'Courier', 
                    left: self.offsetArray[(plus3[i][0] - startPos)], 
                    top: transOffset + 2*15,
                    fontSize: 12,
                    visible: true,
                    fill: 'black',
                    selectable: false,
                });
               
                //to add the custom variable to the IText
                fabric.IText.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                            highlightId: this.highlightId,
                            movePos: this.movePos,
                            name: this.name,
                            one: this.one,
                            three: this.three,
                            amenoRow: this.amenoRow,
                            left: this.left,
                            top: this.top,
                            right: this.right,
                            bottom: this.bottom
                        });
                    };
                })(fabric.IText.prototype.toObject);
                
                if ((plus3[i][0] - startPos) == 2){
                    var p = 2;
                }
                else {
                    var p = (plus3[i][0] - startPos);
                }
                iText.movePos = self.offsetArray[p];
                
                iText.highlightId = highlightTopId;
                iText.name = self.objAmenoAcid[plus3[i][1]]['AminoAcid'];
                iText.three = self.objAmenoAcid[plus3[i][1]]['ThreeLetterCode'];
                iText.one = self.objAmenoAcid[plus3[i][1]]['OneLetterCode'];
                iText.amenoRow = q;
                iText.left = self.offsetArray[(plus3[i][0] - startPos)];
                iText.top = transOffset + 2*15;
                iText.right = self.offsetArray[(plus3[i][0] - startPos)] + (self.offsetArray[2] - self.offsetArray[0]) + 5;
                iText.bottom = transOffset + 2*15 + 12;  
                iText.async = true;
                
                self.canvas2.add(iText);
                aIds3.push(self.canvas2.getObjects().length-1);
            }
            
            self.amenoAcidIds[q+"_3"] = aIds3; 
        }
        
        if (howManyTranslations == -3 || howManyTranslations == 6) {
            for (var i = 0; i < minus1.length; i++) {
               if (translationType == "single"){
                   var t1 = minus1[i][3];
                }
                else if (translationType == "three"){
                    var t1 = minus1[i][2];
                }
                
                var iText = new fabric.IText(t1, { 
                    id: 200,
                    fontFamily: 'Courier', 
                    left: self.offsetArray[(minus1[i][0] - startPos)], 
                    top: transOffset + (Math.abs(howManyTranslations) - 2 )*15 + 10,
                    //top: transOffset + 15,
                    fontSize: 12,
                    visible: true,
                    fill: 'black',
                    selectable: false,
                });
               
                //to add the custom variable to the IText
                fabric.IText.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        highlightId: this.highlightId,
                        movePos: this.movePos,
                        name: this.name,
                        one: this.one,
                        three: this.three,
                        amenoRow: this.amenoRow,
                        left: this.left,
                        top: this.top,
                        right: this.right,
                        bottom: this.bottom
                       });
                    };
                })(fabric.IText.prototype.toObject);
                
                if ((minus1[i][0] - startPos) == 0){
                    var p = 0;
                }
                else {
                    var p = (minus1[i][0] - startPos);
                }
                iText.movePos = self.offsetArray[p];
                
                //iText.movePos = offsetArray[(minus1[i][0] - startPos) - 1];
                iText.highlightId = highlightBottomId;
                iText.name = self.objAmenoAcid[minus1[i][1]]['AminoAcid'];
                iText.three = self.objAmenoAcid[minus1[i][1]]['ThreeLetterCode'];
                iText.one = self.objAmenoAcid[minus1[i][1]]['OneLetterCode'];
                iText.amenoRow = q;
                iText.left = self.offsetArray[(minus1[i][0] - startPos)];
                iText.top = transOffset + (Math.abs(howManyTranslations) - 2 )*15;
                iText.right = self.offsetArray[(minus1[i][0] - startPos)] + (self.offsetArray[2] - self.offsetArray[0]) + 5;
                iText.bottom = transOffset + (Math.abs(howManyTranslations) - 2 )*15 + 12;  
                iText.async = true;
                self.canvas2.add(iText);
                aIds4.push(self.canvas2.getObjects().length-1);
            }
            
            self.amenoAcidIds[q+"_4"] = aIds4; 
            
            for (var i = 0; i < minus2.length; i++) {
                if (translationType == "single"){
                   var t1 = minus2[i][3];
                }
                else if (translationType == "three"){
                    var t1 = minus2[i][2];
                }
                
                var iText = new fabric.IText(t1, { 
                    id: 200,
                    fontFamily: 'Courier', 
                    left: self.offsetArray[(minus2[i][0] - startPos)], 
                    top: transOffset + (Math.abs(howManyTranslations) - 1 )*15 + 10,
                    fontSize: 12,
                    visible: true,
                    fill: 'black',
                    selectable: false,
                });
               
                //to add the custom variable to the IText
                fabric.IText.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        highlightId: this.highlightId,
                        movePos: this.movePos,
                        name: this.name,
                        one: this.one,
                        three: this.three,
                        amenoRow: this.amenoRow,
                        left: this.left,
                        top: this.top,
                        right: this.right,
                        bottom: this.bottom
                       });
                    };
                })(fabric.IText.prototype.toObject);
                
                if ((minus2[i][0] - startPos) == 1){
                    var p = 1;
                }
                else {
                    var p = (minus2[i][0] - startPos);
                }
                iText.movePos = self.offsetArray[p];
                iText.highlightId = highlightBottomId;
                iText.name = self.objAmenoAcid[minus2[i][1]]['AminoAcid'];
                iText.three = self.objAmenoAcid[minus2[i][1]]['ThreeLetterCode'];
                iText.one = self.objAmenoAcid[minus2[i][1]]['OneLetterCode'];
                iText.amenoRow = q;
                iText.left = self.offsetArray[(minus2[i][0] - startPos)];
                iText.top = transOffset + (Math.abs(howManyTranslations) - 1 )*15;
                iText.right = self.offsetArray[(minus2[i][0] - startPos)] + (self.offsetArray[2] - self.offsetArray[0]) + 5;
                iText.bottom = transOffset + (Math.abs(howManyTranslations) - 1 )*15 + 12;   
                iText.async = true;
                self.canvas2.add(iText);
                aIds5.push(self.canvas2.getObjects().length-1);
            }
            
            self.amenoAcidIds[q+"_5"] = aIds5; 
            
            for (var i = 0; i < minus3.length; i++) {
                if (translationType == "single"){
                   var t1 = minus3[i][3];
                }
                else if (translationType == "three"){
                    var t1 = minus3[i][2];
                }
                
                var iText = new fabric.IText(t1, { 
                    id: 200,
                    fontFamily: 'Courier', 
                    left: self.offsetArray[(minus3[i][0] - startPos)], 
                    top: transOffset + (Math.abs(howManyTranslations) )*15 + 10,
                    fontSize: 12,
                    visible: true,
                    fill: 'black',
                    selectable: false,
                });
               
                //to add the custom variable to the IText
                fabric.IText.prototype.toObject = (function(toObject) {
                    return function() {
                        return fabric.util.object.extend(toObject.call(this), {
                        highlightId: this.highlightId,
                        movePos: this.movePos,
                        name: this.name,
                        one: this.one,
                        three: this.three,
                        amenoRow: this.amenoRow,
                        left: this.left,
                        top: this.top,
                        right: this.right,
                        bottom: this.bottom
                       });
                    };
                })(fabric.IText.prototype.toObject);
                
                if ((minus3[i][0] - startPos) == 2){
                    var p = 2;
                }
                else {
                    var p = (minus3[i][0] - startPos);
                }
                iText.movePos = self.offsetArray[p];
                
                iText.highlightId = highlightBottomId;
                iText.name = self.objAmenoAcid[minus3[i][1]]['AminoAcid'];
                iText.three = self.objAmenoAcid[minus3[i][1]]['ThreeLetterCode'];
                iText.one = self.objAmenoAcid[minus3[i][1]]['OneLetterCode'];
                iText.amenoRow = q;
                iText.left = self.offsetArray[(minus3[i][0] - startPos)], 
                iText.top = transOffset + (Math.abs(howManyTranslations) )*15;
                iText.right = self.offsetArray[(minus3[i][0] - startPos)] + (self.offsetArray[2] - self.offsetArray[0]) + 5;
                iText.bottom = transOffset + (Math.abs(howManyTranslations) )*15 +  12;   
                iText.async = true;
                self.canvas2.add(iText);
                aIds6.push(self.canvas2.getObjects().length-1);
            }
            self.amenoAcidIds[q+"_6"] = aIds6; 
        }
    }
}


ArxDraw.prototype.startSpinner = function() {
    var self = this;
    console.log("S P I N N E R -- S T A R T E D");
    
    /** Spinner Details spin.js **/
    var opts = {
        lines: 13,  // The number of lines to draw
        length: 18,  // The length of each line
        width: 10,  // The line thickness
        radius: 20, // The radius of the inner circle
        corners: 1, // Corner roundness (0..1)
        rotate: 0,            // The rotation offset
        direction: 1,         // 1: clockwise, -1: counterclockwise
        color: '#C40000',     // #rgb or #rrggbb or array of colors
        speed: 1,             // Rounds per second
        className: 'spinner', // The CSS class to assign to the spinner
    };
    
    $('#'+self.parentDiv+'_uploadSpinner').css({ display: "block" });
    var target = document.getElementById(self.parentDiv+"_uploadSpinner")

    if ($(window).data("blockUI.isBlocked") == 1) { //ui blocked
        var $blockOverlay = jQuery('.blockUI.blockOverlay').not('.has-spinner');
        var $blockMsg = $blockOverlay.next('.blocked');
        $blockOverlay.addClass('has-spinner');
        
        if(self.spinner == null) {
            self.spinner = new Spinner(opts).spin($('#'+self.parentDiv+'_display').get(0));
        } else {
            self.spinner.spin($('#'+self.parentDiv+'_display').get(0));
        } 
    }
    else {  
        console.log("START SPINNER visibility: "+ self.spinner +", "+ $('#'+self.parentDiv+'_uploadSpinner').css('display'));  
        if(self.spinner == null) {
            self.spinner = new Spinner(opts).spin(target);
        } else {
            self.spinner.spin(target);
        } 
    }
}

ArxDraw.prototype.stopSpinner = function() {
    var self = this;
    console.log("S P I N N E R -- S T O P");
    var target = document.getElementById(self.parentDiv+"_uploadSpinner")
    
    if (self.spinner != null) {
        if ($(window).data("blockUI.isBlocked") == 1) { //ui blocked
            self.spinner.stop($('#'+self.parentDiv+'_display').get(0));
        } else {
            self.spinner.stop(target);
            $('#'+self.parentDiv+'_uploadSpinner').css({ display: "none" });
        }
    }
}

ArxDraw.prototype.addRemoveClassActive = function(id) {
    $("#"+id).parent().children("li.active").removeClass("active");
    $("#"+id).addClass("active");
}

ArxDraw.prototype.getAllAmenoAcidTranslations = function(tStringWithoutSpaces, wordsInALine){
    var self = this;
    var objAmenoAcid = JSON.parse(aminoAcidDescription);
    var plus1 = [], plus2 = [], plus3 = [], minus1 = [], minus2 = [], minus3 =[];
    tStringWithoutSpaces = tStringWithoutSpaces.replace(/\\n/g, "");
    var splitStr = tStringWithoutSpaces.split("");
    
    for (var i = 0; i < splitStr.length; i += 3) {
        var checkPlus1 = (splitStr[i]+splitStr[i+1]+splitStr[i+2]).toUpperCase();
        var checkMinus1 = self.reverse(self.getComplementaryStr(checkPlus1));
        var check1 = 0;
        var check2 = 0;
        //console.log("getAllAmenoAcidTranslations: "+ checkPlus1);
        for (var j = 0; j < objAmenoAcid.length; j++) {
            if (objAmenoAcid[j]['Codon'] == checkPlus1){
                plus1.push([i, j, objAmenoAcid[j]['ThreeLetterCode'], objAmenoAcid[j]['OneLetterCode']]);
                check1 = check1+1;
            }
            if (objAmenoAcid[j]['Codon'] == checkMinus1){
                minus1.push([i, j, objAmenoAcid[j]['ThreeLetterCode'], objAmenoAcid[j]['OneLetterCode']]);
                check2 = check2+1;
            }
            if (check1 == 1 && check2 == 1){
                break;
            }
            
        }
        if (check1 == 0) {
            console.log("getAllAmenoAcidTranslations: "+ i + " - " + checkPlus1);
        }

    }
    //console.log("getAllAmenoAcidTranslations: "+ plus1);
    for (var i = 1; i < splitStr.length; i += 3) {
        var checkPlus2 = (splitStr[i]+splitStr[i+1]+splitStr[i+2]).toUpperCase();
        var checkMinus2 = self.reverse(self.getComplementaryStr(checkPlus2));
        var check1 = 0;
        var check2 = 0;
        
        for (var j = 0; j < objAmenoAcid.length; j++) {
            
            if (objAmenoAcid[j]['Codon'] == checkPlus2){
                plus2.push([i, j, objAmenoAcid[j]['ThreeLetterCode'], objAmenoAcid[j]['OneLetterCode']]);
                check1 = check1+1;
            }
            
            if (objAmenoAcid[j]['Codon'] == checkMinus2){
                minus2.push([i, j, objAmenoAcid[j]['ThreeLetterCode'], objAmenoAcid[j]['OneLetterCode']]);
                check2 = check2+1;
            }
            if (check1 == 1 && check2 == 1){
                break;
            }
        }
    }
    
    for (var i = 2; i < splitStr.length; i += 3) {
        var checkPlus3 = (splitStr[i]+splitStr[i+1]+splitStr[i+2]).toUpperCase();
        var checkMinus3 = self.reverse(self.getComplementaryStr(checkPlus3));
        var check1 = 0;
        var check2 = 0;
        
        for (var j = 0; j < objAmenoAcid.length; j++) {
            
            if (objAmenoAcid[j]['Codon'] == checkPlus3){
                plus3.push([i, j, objAmenoAcid[j]['ThreeLetterCode'], objAmenoAcid[j]['OneLetterCode']]);
                check1 = check1+1;
            }
            
            if (objAmenoAcid[j]['Codon'] == checkMinus3){
                minus3.push([i, j, objAmenoAcid[j]['ThreeLetterCode'], objAmenoAcid[j]['OneLetterCode']]);
                check2 = check2+1;
            }
            if (check1 == 1 && check2 == 1){
                break;
            }
        }
    }
    //console.log(plus1.length+", "+minus3.length+", "+minus2.length+", "+plus2.length+", "+plus3.length+", "+minus1.length);
    return [plus1, plus2, plus3, minus1, minus2, minus3];
}

ArxDraw.prototype.reverse = function(s) {
    for (var i = s.length - 1, o = ''; i >= 0; o += s[i--]) { }
    return o;
}

ArxDraw.prototype.ORF = function(allTranslations) {
    var self = this;
    var orf1 = [];
    var orf2 = [];
    var orf3 = [];
    var orf4 = [];
    var orf5 = [];
    var orf6 = [];
    
    orf1 = self.findORF(allTranslations[0], 1);
    orf2 = self.findORF(allTranslations[1], 1);
    orf3 = self.findORF(allTranslations[2], 1);
    orf4 = self.findORF(allTranslations[3], 2);
    orf5 = self.findORF(allTranslations[4], 2);
    orf6 = self.findORF(allTranslations[5], 2);
    
    return [orf1, orf2, orf3, orf4, orf5, orf6];
}

ArxDraw.prototype.findORF = function(transArray, dir) {
    var startCodon = false;
    var orfJSON = [];
    
    if (dir == 1) {
        for (var i = 0; i < transArray.length; i++) {
            if (transArray[i][1] == 29 && !startCodon){
                startCodon = true;
                var orfStartPos = transArray[i][0];
            }
            
            if ((transArray[i][1] == 62 || transArray[i][1] == 63 || transArray[i][1] == 64) && startCodon){
                startCodon = false;
                if ((transArray[i][0] - orfStartPos) > 250) {
                    var orfDetails = { 'startPos' : orfStartPos, 'endPos' : transArray[i][0], 'basePairs' : (transArray[i][0] - orfStartPos) };
                    orfJSON.push(orfDetails);
                    //console.log("orfStartPos: "+orfStartPos +" , "+ transArray[i][0]);
                }
            }
        }
    }
    else {
        for (var i = transArray.length-1; i >= 0 ; i--) {
            if (transArray[i][1] == 29 && !startCodon){
                startCodon = true;
                var orfStartPos = transArray[i][0];
            }
            
            if ((transArray[i][1] == 62 || transArray[i][1] == 63 || transArray[i][1] == 64) && startCodon){
                startCodon = false;
                if ( (orfStartPos - transArray[i][0]) > 250 ) { // minimum length of orf set for 250
                    var orfDetails = { 'startPos' : transArray[i][0], 'endPos' : orfStartPos, 'basePairs' : (orfStartPos - transArray[i][0]) };
                    orfJSON.push(orfDetails);
                    //console.log("orfStartPos: "+orfStartPos +" , "+ transArray[i][0]);
                }
            }
        }
    }
    
    return(orfJSON);
}


ArxDraw.prototype.arxD_addRemoveClassActive = function(tabId, view) {
    console.log("ADD REMOVE CLASS ACTIVE: "+ tabId + ", " + view);
    var self = this;
    $("#"+tabId).parent().children("li.active").removeClass("active");
    $("#"+tabId).addClass("active");
    
    if (view == "mapView") {
        $("#"+self.parentDiv+"_mapView").addClass('active');
        $("#"+self.parentDiv+"_sequenceView").removeClass('active');
        $("#"+self.parentDiv+"_linearView").removeClass('active');
    } 
    else if (view == "sequenceView") {
        $("#"+self.parentDiv+"_sequenceView").addClass('active');
        if ( $("#"+self.parentDiv+"_mapView").length > 0 ) {
            $("#"+self.parentDiv+"_mapView").removeClass('active');
        }
        $("#"+self.parentDiv+"_linearView").removeClass('active');

        self.autoScroll = true;
        $("#"+self.parentDiv+"_wrapperXY").mCustomScrollbar("update");
        $("#"+self.parentDiv+"_wrapperXY").mCustomScrollbar("scrollTo",self.draggerTop);
        //$("#arxD_wrapper").mCustomScrollbar("update");
        //$("#arxD_wrapper").mCustomScrollbar("scrollTo",self.draggerTop, { scrollEasing:"linear" });
    } 
    else if(view == "linearView") {
        $("#"+self.parentDiv+"_linearView").addClass('active');
        $("#"+self.parentDiv+"_sequenceView").removeClass('active');
        if ( $("#"+self.parentDiv+"_mapView").length > 0 ) {
            $("#"+self.parentDiv+"_mapView").removeClass('active');
        }

        console.log("linearDraggerTop: " + self.linearDraggerTop);
        $("#"+self.parentDiv+"_wrapper2").mCustomScrollbar("update");
        $("#"+self.parentDiv+"_wrapper2").mCustomScrollbar("scrollTo", { y: self.linearDraggerTop});
    }
}

ArxDraw.prototype.arxD_checkLeftMenuTabs = function(id) {
    var self = this;
    
    $("#"+self.parentDiv+"_EView").attr("style", "display: none");
    $("#"+self.parentDiv+"_FView").attr("style", "display: none");
    $("#"+self.parentDiv+"_MSLView").attr("style", "display: block");
    //$("#"+self.parentDiv+"_wrapperXY").mCustomScrollbar("stop");
    
    if (id == "mapView" || id == "linearView") {
        if ($("#"+self.parentDiv+"_trans").is(":visible") && $("#"+self.parentDiv+"_amino").is(":visible") ) {
            $("#"+self.parentDiv+"_trans").toggle();
            $("#"+self.parentDiv+"_amino").toggle();
        }
    } 
    else if (id == "sequenceView") {
        if (!$("#"+self.parentDiv+"_trans").is(":visible") && !$("#"+self.parentDiv+"_amino").is(":visible")) {
            $("#"+self.parentDiv+"_trans").toggle();
            $("#"+self.parentDiv+"_amino").toggle();
        }
    }
    console.log("Finished checkLeftMenuTabs");
}


ArxDraw.prototype.displayFeatures = function(fStrJSON, n) {  //3: "{ "feature" : "CDS", "segment" : "complement(11295..12017)", " /label" : "tnpA_5 CD", " /ApEinfo_revcolor" : "#b1ff67", " /ApEinfo_fwdcolor" : "#b1ff67"}"
    var self = this;
    var tableHeader = "";
    var tableRow = "";
    var tableData = "";
    
    var table = document.createElement('table');
    table.setAttribute('id', self.parentDiv+'_features');
    table.setAttribute('class', 'arxD_features table-striped');
    var thead = document.createElement('thead');
    var tr = document.createElement('tr');
    var th = document.createElement('th');
    var spanText = document.createElement('span');
    spanText.appendChild(document.createTextNode("No:"));
    th.appendChild(spanText);
    tr.appendChild(th);
    
    var th = document.createElement('th');
    var spanText = document.createElement('span');
    spanText.appendChild(document.createTextNode("Feature"));
    th.appendChild(spanText);
    tr.appendChild(th);
    
    var th = document.createElement('th');
    var spanText = document.createElement('span');
    spanText.appendChild(document.createTextNode("Location"));
    th.appendChild(spanText);
    tr.appendChild(th);
    
    var th = document.createElement('th');
    var spanText = document.createElement('span');
    spanText.appendChild(document.createTextNode("Size (bp)"));
    th.appendChild(spanText);
    tr.appendChild(th);
    
    var th = document.createElement('th');
    var spanText = document.createElement('span');
    spanText.appendChild(document.createTextNode("Color"));
    th.appendChild(spanText);
    tr.appendChild(th);
    
    var th = document.createElement('th');
    var spanText = document.createElement('span');
    spanText.appendChild(document.createTextNode("Direction"));
    th.appendChild(spanText);
    tr.appendChild(th);
    
    var th = document.createElement('th');
    var spanText = document.createElement('span');
    spanText.appendChild(document.createTextNode("Type"));
    th.appendChild(spanText);
    tr.appendChild(th);
    thead.appendChild(tr);
    table.appendChild(thead);
    var tbody = document.createElement('tbody');

    for (var i = 0; i < fStrJSON.length; i++) { //{"startPos":"217","endPos":"2200","featureName":"misc_feature","arrayConn":1,"overLap":1,"color":"#02E524","lengthOfFeature":1983,"direction":-1}
        var tr = document.createElement('tr');   
        var td = document.createElement('td');
        var text = i + 1;
        var spanText = document.createElement("span");
        spanText.appendChild(document.createTextNode(text));
        td.appendChild(spanText);
        tr.appendChild(td);
        
        var td = document.createElement('td');
        var text = fStrJSON[i]["featureName"];
        var spanText = document.createElement("span");
        spanText.appendChild(document.createTextNode(text));
        td.appendChild(spanText);
        tr.appendChild(td);
        
        var td = document.createElement('td');
        var text = fStrJSON[i]["startPos"]+" .. " +fStrJSON[i]["endPos"];
        var spanText = document.createElement("span");
        spanText.appendChild(document.createTextNode(text));
        td.appendChild(spanText);
        tr.appendChild(td);
        
        var td = document.createElement('td');
        var text = fStrJSON[i]['lengthOfFeature'];
        var spanText = document.createElement("span");
        spanText.appendChild(document.createTextNode(text));
        td.appendChild(spanText);
        tr.appendChild(td);
        
        var td = document.createElement('td');
        td.innerHTML = "<div class='htmlColorBox' id='htmlColorBox' style='background-color:"+fStrJSON[i]['color']+"'></div>"; 
        tr.appendChild(td);
        
        var td = document.createElement('td');
        if (fStrJSON[i]['direction'] === -1){
            td.innerHTML = "<b>&#8594;</b>";
        }
        else {
            td.innerHTML = "<b>&#8592;</b>";
        }
        
        tr.appendChild(td);
        
        var td = document.createElement('td');
        var text = fStrJSON[i]["featureName"];
        var spanText = document.createElement("span");
        spanText.appendChild(document.createTextNode(text));
        td.appendChild(spanText);
        tr.appendChild(td);
        
        tbody.appendChild(tr);
    }
    
    for (var j = i; j < n; j++) {
        var tr = document.createElement('tr');   
        var td = document.createElement('td');
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);
        
        var td = document.createElement('td');
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);
        
        var td = document.createElement('td');
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);
        
        var td = document.createElement('td');
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);
        
        var td = document.createElement('td');
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);
        
        var td = document.createElement('td');
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);
        
        var td = document.createElement('td');
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);
        
        tbody.appendChild(tr);
    }
    
    table.appendChild(tbody);

    $("#"+self.parentDiv+"_FView").append(table);

    //$("#"+self.parentDiv+"_FView").height($( window ).height() * 0.55);
    console.log("FVIEW HEIGHT before append: "+ $( window ).height() +", " + $("#"+self.parentDiv+"_FView").height() );
}

ArxDraw.prototype.restCallAsyncUpload = function(url,verb,data, progressListener, cb,returnType,async){ //Added for progress bar update 3/21/16
    var form
    data["connectionId"] = connectionId;
    if (window.XMLHttpRequest){
        client = new XMLHttpRequest();              
    }else{                                  
        client = new ActiveXObject("Microsoft.XMLHTTP");
    }
    if(async!="async"){
        async = "no";
    }
    form = "async="+async+"&url="+encodeURIComponent(url)+"&verb="+encodeURIComponent(verb)+"&data="+encodeURIComponent(JSON.stringify(data))+"&r="+Math.random();
    client.upload.addEventListener("progress", progressListener);
    client.onreadystatechange=(function(client,cb,returnType){
        return function(){
            restCallACb(client,cb,returnType);
        }
    })(client,cb,returnType);
    client.open("POST", "invp.asp?r="+Math.random(), true);
    client.setRequestHeader("Content-type","application/x-www-form-urlencoded");
    client.send(form);
    return false;
}


ArxDraw.prototype.displayEnzymes = function(REmappingArray, n) {
    var self = this;
    var keyArr = [];
    
    //var UniqueRE= $.unique(REmappingArray.map(function (d) {
    //return d.enzyme;}));

    Array.prototype.unique = function() {
        var n = {},UniqueRE=[];
        for(var i = 0; i < REmappingArray.length; i++) 
        {
            if (!n[REmappingArray[i]['enzyme']]) 
            {
                n[REmappingArray[i]['enzyme']] = true; 
                UniqueRE.push(REmappingArray[i]['enzyme']); 
            }
        }
        return UniqueRE;
    }

    UniqueRE = REmappingArray.unique();
    
    for (var i = 0; i < UniqueRE.length; i ++) {
        var count = 0;
        var numberArr = [];
        for (var j = 0; j < REmappingArray.length; j ++) {
            if (UniqueRE[i] == REmappingArray[j]['enzyme']) {
                count = count + 1;
                numberArr.push(REmappingArray[j]['startPos']);
            }
            if (j == REmappingArray.length - 1) {
                var s = {'enzyme' : UniqueRE[i], 'count' : count, 'startPos' : numberArr};
                keyArr.push(s);
            }
        }
    }
    
    keyArr.sort(function(a, b){
        if(a.enzyme < b.enzyme) return -1;
        if(a.enzyme > b.enzyme) return 1;
        return 0;
    })
    
    var outerTable = document.createElement('table');
    outerTable.setAttribute('id', self.parentDiv+'_outerEnzymes');
    outerTable.setAttribute('class', 'arxD_outerEnzymes');
    var outerTr = document.createElement('tr');
    var outerTd1 = document.createElement('td');
    
        var table = document.createElement('table');
        table.setAttribute('id', self.parentDiv+'_enzymesList');
        table.setAttribute('class', 'arxD_enzymesList');
        table.setAttribute('width', ($("#"+self.parentDiv+"_middle").width())*0.1);
            var tr = document.createElement('tr');
                var thead = document.createElement('thead');
                var th = document.createElement('th');
                    var spanText = document.createElement('span');
                    spanText.appendChild(document.createTextNode("Enzymes"));
                th.appendChild(spanText);
            tr.appendChild(th);
        
                var th = document.createElement('th');
                    var spanText = document.createElement('span');
                    spanText.appendChild(document.createTextNode("Sites"));
                th.appendChild(spanText);
            tr.appendChild(th);
        
        thead.appendChild(tr);
        table.appendChild(thead);
        
        var tbody = document.createElement('tbody');
        
        for (var i = 0; i < keyArr.length; i++) { //3: "{ "enzyme" : "CDS", "count" : 3, "startPos" : "2213, 2345, 7689" }"
            var tr = document.createElement('tr');   
            var td = document.createElement('td');
            var text = keyArr[i]["enzyme"];
            var spanText = document.createElement("span");
            spanText.appendChild(document.createTextNode(text));
            td.appendChild(spanText);
            tr.appendChild(td);
            
            var td = document.createElement('td');
            var text = keyArr[i]["count"];
            var spanText = document.createElement("span");
            spanText.appendChild(document.createTextNode(text));
            td.appendChild(spanText);
            tr.appendChild(td);
            
            tbody.appendChild(tr);
        }    
        
        for (var j = i; j < n; j++) {
            var tr = document.createElement('tr');   
            var td = document.createElement('td');
            td.innerHTML = "&nbsp;";
            tr.appendChild(td);
            
            var td = document.createElement('td');
            tr.appendChild(td);
            
            tbody.appendChild(tr);
        }
        
        table.appendChild(tbody);
    outerTd1.appendChild(table);
    outerTr.appendChild(outerTd1);
    
    var outerTd2 = document.createElement('td');
    outerTd2.setAttribute('width', "100%");
    
    var div = document.createElement('div');
    var ul = document.createElement('ul');
    ul.setAttribute('id', self.parentDiv+'_displayEnzymeTabs');
    ul.setAttribute('class','arxD_displayEnzymeTabs');
    var li = document.createElement('li');
    li.setAttribute('id', self.parentDiv+'_displayEnzymeLocTabs');
    li.setAttribute('class', 'arxD_displayEnzymes active');
    li.innerHTML = "<a href='#'>Location</a>"; 
    ul.appendChild(li);
    var li = document.createElement('li');
    li.setAttribute('id', self.parentDiv+'_displayEnzymeLinesTabs');
    li.setAttribute('class', 'arxD_displayEnzymes');
    li.innerHTML = "<a href='#'>Lines</a>"; 
    ul.appendChild(li);
    div.appendChild(ul);
    
    
    var div1 = document.createElement('div');
    div1.setAttribute('id', self.parentDiv+'_enzymeDetails');
    
    var div2 = document.createElement('div');
    div2.setAttribute('id', self.parentDiv+'_enzymeLoc');
    div2.setAttribute('class', 'arxD_displayEnzymeLoc');
    
    var t1 = document.createElement('table');
    t1.setAttribute('id', self.parentDiv+'_enzymeLocTable');
    t1.setAttribute('class', 'arxD_enzymeLocTable');

    //t1.setAttribute('width', ($("#"+self.parentDiv+"_middle").width())*0.9);
    //t1.setAttribute('border', '1');
    
    var t1body = document.createElement('tbody');
    
    for (var i = 0; i < keyArr.length; i++) { //3: "{ "enzyme" : "CDS", "count" : 3, "startPos" : "2213, 2345, 7689" }"
        var tr = document.createElement('tr');   
        var td = document.createElement('td');
        var text = keyArr[i]["startPos"];
        var spanText = document.createElement("span");
        spanText.appendChild(document.createTextNode(text));
        td.appendChild(spanText);
        tr.appendChild(td);
        
        t1body.appendChild(tr);
    }
    
    for (var j = i; j < n; j++) {
        var tr = document.createElement('tr');   
        var td = document.createElement('td');
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);
        t1body.appendChild(tr);
    }
    t1.appendChild(t1body);
    
    div2.appendChild(t1);
    
    var div3 = document.createElement('div');
    div3.setAttribute('id', self.parentDiv+'_enzymeLines');
    div3.setAttribute('class', 'arxD_displayEnzymeLines');
    div3.style.display = 'none';
    
    var t2 = document.createElement('table');
    t2.setAttribute('id', self.parentDiv+'_enzymeLinesTable');
    t2.setAttribute('class', 'arxD_enzymeLinesTable');
    t2.setAttribute('width', ($("#"+self.parentDiv+"_middle").width())*0.9);
    var t2body = document.createElement('tbody');
    //$('#'+self.parentDiv+'_display')
    
    for (var i = 0; i < keyArr.length; i++) { //3: "{ "enzyme" : "CDS", "count" : 3, "startPos" : "2213, 2345, 7689" }"
        var tr = document.createElement('tr');   
        var td = document.createElement('td');
        //draw lines
        prevX = 0;
        
        for (var j=0; j < keyArr[i]["startPos"].length; j++) {
            x = (keyArr[i]["startPos"][j] - prevX)*($("#"+self.parentDiv+"_display").width())*0.7/self.data.basePairs ;
            prevX = keyArr[i]["startPos"][j];
            x = x +"px;";
            td.innerHTML = td.innerHTML + "<div class='verticalLine' title='Pos: "+prevX+"' style='margin-left:"+x+"'>&nbsp;</div>"; 
        }
        tr.appendChild(td);
        
        t2body.appendChild(tr);
    }
    
    for (var j = i; j < n; j++) {
        var tr = document.createElement('tr');   
        var td = document.createElement('td');
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);
        t2body.appendChild(tr);
    }
    t2.appendChild(t2body);
    
    div3.appendChild(t2);
    
    div1.appendChild(div2);
    div1.appendChild(div3);
    
    div.appendChild(div1);
    
    outerTd2.appendChild(div);
    outerTr.appendChild(outerTd2);
    
    outerTable.appendChild(outerTr);
    
    $("#"+self.parentDiv+"_EView").append(outerTable);
}

