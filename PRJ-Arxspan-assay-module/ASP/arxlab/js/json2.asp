if(!Object.prototype.get) {
    Object.prototype.get = function(k) {
        return this[k];
    }
}

if(!Object.prototype.set) {
    Object.prototype.set = function(k,v) {
        if(typeof(v) == "unknown") {
            try {
                v = (new VBArray(v)).toArray();
            } catch(e) {
                return;
            }
        }
        this[k] = v;
    }
}

if(!Object.prototype.purge) {
    Object.prototype.purge = function(k) {
        delete this[k];
    }
}

if(!Object.prototype.keys) {
    Object.prototype.keys = function() {
        var d = new ActiveXObject("Scripting.Dictionary");
        for(var key in this) {
            if(this.hasOwnProperty(key)) {
                d.add(key, null);
            }
        }
        return d.keys();
    }
}

if(!Object.prototype.exists) {
	Object.prototype.exists = function(s) {
		for(var key in this) {
			if(this.hasOwnProperty(key)) {
				if(key===s){
					return true;
				}
			}
		}
		return false
	}
}

if(!Object.prototype.enumerate) {
    Object.prototype.enumerate = function() {
        var d = new ActiveXObject("Scripting.Dictionary");
        for(var key in this) {
            if(this.hasOwnProperty(key)) {
                d.add(key, this[key]);
            }
        }
        return d.keys();
    }
}

if(!String.prototype.sanitize) {
    String.prototype.sanitize = function(a, b) {
        var len = a.length,
            s = this;
        if(len !== b.length) throw new TypeError('Invalid procedure call. Both arrays should have the same size.');
        for(var i = 0; i < len; i++) {
            var re = new RegExp(a[i],'g');
            s = s.replace(re, b[i]);
        }
        return s;
    }
}

if(!String.prototype.substitute) {
    String.prototype.substitute = function(object, regexp){
        return this.replace(regexp || (/\\?\{([^{}]+)\}/g), function(match, name){
            if(match.charAt(0) == '\\') return match.slice(1);
            return (object[name] != undefined) ? object[name] : '';
        });
    }
}

var JSON;
if(!JSON) {
    JSON = {};
}

(function () {
    'use strict';

    function f(n) {
        return n < 10 ? '0' + n : n;
    }

    if(typeof Date.prototype.toJSON !== 'function') {

        Date.prototype.toJSON = function (key) {

            return isFinite(this.valueOf())
                ? this.getUTCFullYear()     + '-' +
                    f(this.getUTCMonth() + 1) + '-' +
                    f(this.getUTCDate())      + 'T' +
                    f(this.getUTCHours())     + ':' +
                    f(this.getUTCMinutes())   + ':' +
                    f(this.getUTCSeconds())   + 'Z'
                : null;
        };

        String.prototype.toJSON      =
            Number.prototype.toJSON  =
            Boolean.prototype.toJSON = function (key) {
                return this.valueOf();
            };
    }

    var cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        gap,
        indent,
        meta = {    
            '\b': '\\b',
            '\t': '\\t',
            '\n': '\\n',
            '\f': '\\f',
            '\r': '\\r',
            '"' : '\\"',
            '\\': '\\\\'
        },
        rep;


    function quote(string) {
        escapable.lastIndex = 0;
        return escapable.test(string) ? '"' + string.replace(escapable, function (a) {
            var c = meta[a];
            return typeof c === 'string'
                ? c
                : '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
        }) + '"' : '"' + string + '"';
    }


    function str(key, holder) {


        var i,          
            k,          
            v,          
            length,
            mind = gap,
            partial,
            value = holder[key];



        if(value && typeof value === 'object' &&
                typeof value.toJSON === 'function') {
            value = value.toJSON(key);
        }


        if(typeof rep === 'function') {
            value = rep.call(holder, key, value);
        }


        switch (typeof value) {
        case 'string':
            return quote(value);

        case 'number':


            return isFinite(value) ? String(value) : 'null';

        case 'boolean':
        case 'null':


            return String(value);


        case 'object':

            if(!value) {
                return 'null';
            }

            gap += indent;
            partial = [];

            if(Object.prototype.toString.apply(value) === '[object Array]') {

                length = value.length;
                for (i = 0; i < length; i += 1) {
                    partial[i] = str(i, value) || 'null';
                }


                v = partial.length === 0
                    ? '[]'
                    : gap
                    ? '[\n' + gap + partial.join(',\n' + gap) + '\n' + mind + ']'
                    : '[' + partial.join(',') + ']';
                gap = mind;
                return v;
            }

            if(rep && typeof rep === 'object') {
                length = rep.length;
                for (i = 0; i < length; i += 1) {
                    if(typeof rep[i] === 'string') {
                        k = rep[i];
                        v = str(k, value);
                        if(v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            } else {



                for (k in value) {
                    if(Object.prototype.hasOwnProperty.call(value, k)) {
                        v = str(k, value);
                        if(v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            }




            v = partial.length === 0
                ? '{}'
                : gap
                ? '{\n' + gap + partial.join(',\n' + gap) + '\n' + mind + '}'
                : '{' + partial.join(',') + '}';
            gap = mind;
            return v;
        }
    }



    if(typeof JSON.stringify !== 'function') {
        JSON.stringify = function (value, replacer, space) {







            var i;
            gap = '';
            indent = '';




            if(typeof space === 'number') {
                for (i = 0; i < space; i += 1) {
                    indent += ' ';
                }



            } else if(typeof space === 'string') {
                indent = space;
            }




            rep = replacer;
            if(replacer && typeof replacer !== 'function' &&
                    (typeof replacer !== 'object' ||
                    typeof replacer.length !== 'number')) {
                throw new Error('JSON.stringify');
            }




            return str('', {'': value});
        };
    }




    if(typeof JSON.parse !== 'function') {
        JSON.parse = function (text, reviver) {




            var j;

            function walk(holder, key) {




                var k, v, value = holder[key];
                if(value && typeof value === 'object') {
                    for (k in value) {
                        if(Object.prototype.hasOwnProperty.call(value, k)) {
                            v = walk(value, k);
                            if(v !== undefined) {
                                value[k] = v;
                            } else {
                                delete value[k];
                            }
                        }
                    }
                }
                return reviver.call(holder, key, value);
            }






            text = String(text);
            cx.lastIndex = 0;
            if(cx.test(text)) {
                text = text.replace(cx, function (a) {
                    return '\\u' +
                        ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
                });
            }














            if(/^[\],:{}\s]*$/
                    .test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, '@')
                        .replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']')
                        .replace(/(?:^|:|,)(?:\s*\[)+/g, ''))) {






                j = eval('(' + text + ')');




                return typeof reviver === 'function'
                    ? walk({'': j}, '')
                    : j;
            }



            throw new SyntaxError('JSON.parse');
        };
    }
}());











(function(){

    function __sanitize(value) {
        return value.sanitize(
            ['&',    '<',   '>',    '\'',    '"'],
            ['&amp;','&lt;','&gt;', '&apos;','&quot;']
        );
    };

    function __toXML(o, t) {
        var xml = [];
        switch( typeof o ) {
            case "object":
                if( null === o ) {
                    xml.push("<{tag}/>".substitute({"tag":t}));
                } else if(o.length) {
                    var a = o;
                    if(a.length === 0) {
                        xml.push("<{tag}/>".substitute({"tag":t}));
                    } else {
                        for(var i = 0, len = a.length; i < len; i++) {
                            xml.push(__toXML(a[i], t));
                        }
                    }
                } else {
                    xml.push("<{tag}".substitute({"tag":t}));
                    var childs = [];
                    for(var p in o) {
                        if(o.hasOwnProperty(p)) {
                            if(p.charAt(0) === "@") xml.push(" {param}='{content}'".substitute({"param":p.substr(1), "content":__sanitize(o[p].toString())}));
                            else childs.push(p);
                        }
                    }
                    if(childs.length === 0) {
                        xml.push("/>");
                    } else {
                        xml.push(">");
                        for(var i = 0, len = childs.length; i < len; i++) {
                            if(p === "#text")
                                { xml.push(__sanitize(o[childs[i]])); }
                            else if(p === "#cdata")
                                { xml.push("<![CDATA[{code}]]>".substitute({"code": o[childs[i]].toString()})); }
                            else if(p.charAt(0) !== "@")
                                { xml.push(__toXML(o[childs[i]], childs[i])); }
                        }
                        xml.push("</{tag}>".substitute({"tag":t}));
                    }
                }
                break;
            
            default:
                var s = String(o);
                if(s.length === 0) {
                    xml.push("<{tag}/>".substitute({"tag":t}));
                } else {
                    xml.push("<{tag}>{value}</{tag}>".substitute({"tag":t, "value":s}));
                }
        }
        return xml.join('');
    }

    if(typeof JSON.toXML !== 'function') {
        JSON.toXML = function(json, container){
            
            var xml = [];
            if(container) xml.push("<{tag}>".substitute({"tag":container}));
            for(var p in json) {
                if(json.hasOwnProperty(p)) {
                    xml.push(__toXML(json[p], p));
                }
            }
            if(container) xml.push("</{tag}>".substitute({"tag":container}));
            return xml.join('');
        }
    }

})();











(function(){
    if(typeof JSON.minify !== 'function') {
        JSON.minify = function(json) {
            var tokenizer = /"|(\/\*)|(\*\/)|(\/\/)|\n|\r/g,
                in_string = false,
                in_multiline_comment = false,
                in_singleline_comment = false,
                tmp, tmp2, new_str = [], ns = 0, from = 0, lc, rc;
            
            tokenizer.lastIndex = 0;
            
            while( tmp = tokenizer.exec(json) ) {
                lc = RegExp.leftContext;
                rc = RegExp.rightContext;
                if(!in_multiline_comment && !in_singleline_comment) {
                    tmp2 = lc.substring(from);
                    if(!in_string) {
                        tmp2 = tmp2.replace(/(\n|\r|\s)*/g,"");
                    }
                    new_str[ns++] = tmp2;
                }
                from = tokenizer.lastIndex;
                
                if(tmp[0] == "\"" && !in_multiline_comment && !in_singleline_comment) {
                    tmp2 = lc.match(/(\\)*$/);
                    if(!in_string || !tmp2 || (tmp2[0].length % 2) == 0) { 
                        in_string = !in_string;
                    }
                    from--; 
                    rc = json.substring(from);
                } else if(tmp[0] == "/*" && !in_string && !in_multiline_comment && !in_singleline_comment) {
                    in_multiline_comment = true;
                } else if(tmp[0] == "*/" && !in_string && in_multiline_comment && !in_singleline_comment) {
                    in_multiline_comment = false;
                } else if(tmp[0] == "//" && !in_string && !in_multiline_comment && !in_singleline_comment) {
                    in_singleline_comment = true;
                } else if((tmp[0] == "\n" || tmp[0] == "\r") && !in_string && !in_multiline_comment && in_singleline_comment) {
                    in_singleline_comment = false;
                } else if(!in_multiline_comment && !in_singleline_comment && !(/\n|\r|\s/.test(tmp[0]))) {
                    new_str[ns++] = tmp[0];
                }
            }
            new_str[ns++] = rc;
            return new_str.join("");
        }
    }
})();