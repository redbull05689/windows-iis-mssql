multiTextHTMLStr = "<div><input type='text'><img src='/arxlab/images/delete.gif' onclick='$(this).parent().remove();'/></div>";

function makeMultis(){
	$(".multiHolder").each(function(i,el){
		valRaw = $("#"+$(el)[0].id.replace("_holder","")).val();
		vals = valRaw.split("###");
		for(var j=0;j<vals.length;j++){
			htmlStr = "<div><input type='text' value='"+vals[j].replace(/\'/ig,"&apos;")+"'>";
			htmlStr += "<img src='/arxlab/images/delete.gif' onclick='$(this).parent().remove();'/>";
			htmlStr += "</div>"
			$(el).append(htmlStr);
		}
		$(el).append("<img class='add' src='/arxlab/images/add.gif'/ onclick='$(multiTextHTMLStr).insertBefore($(this));'>");
	});
	addEnterEvents();
}

function addEnterEvents(){
	$('.multiHolder input[type=text]').on('keypress', function (event) {
		if(event.which === 13){
			$(multiTextHTMLStr).insertBefore($(this).parent().parent().find(".add")).find("input").focus();
			addEnterEvents();
			return false;
		}
	});
}

function saveMultis(){
	return new Promise(function(resolve, reject) {
		var promiseArray = [];
		$(".multiHolder").each(function(i,el){
			promiseArray.push(new Promise(function(resolve, reject) {
				values = [];
				$(el).find("input[type=text]").each(function(j,el2){
					val = $(el2).val();
					if(val!=""){
						values.push(val);
					}
				});
				$("#"+$(el)[0].id.replace("_holder","")).val(values.join("###"));
                resolve(true);
			}));
		});
		Promise.all(promiseArray).then(function() {
			resolve(true);
		});
	});
}