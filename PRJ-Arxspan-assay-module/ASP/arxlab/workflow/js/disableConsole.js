console.error("Overrriding console.log for production!")
var console = {};
console.log = function(){};
console.error = function(){};
console.warn = function(){};
console.info = function(){};