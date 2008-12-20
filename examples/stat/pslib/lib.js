var userAgent	= navigator.userAgent.toLowerCase();
var is_saf	= ((userAgent.indexOf('applewebkit') > -1) || (navigator.vendor == 'Apple Computer, Inc.'));
var is_ie	= ((navigator.appName.indexOf('Microsoft') > -1) || (navigator.appName.indexOf('MSIE') > -1)) && userAgent.indexOf('opera') < 0;

function my_getbyid(id) {
	var obj = null;
	if (document.getElementById)	{ obj = document.getElementById(id); }
	else if (document.all)		{ obj = document.all[id]; }
	else if (document.layers)	{ obj = document.layers[id]; }
	return obj;
}
// Show/hide toggle
function toggleview(id) {
	if ( ! id ) return;
	if ( itm = my_getbyid(id) ) {
		if (itm.style.display == 'none')	{ my_show_div(itm); return 1; }
		else					{ my_hide_div(itm); return 0; }
	}
}

function show_id(id) {
	if (!id) return;
	if (obj=my_getbyid(id)) 
		if (obj.style.display == 'none')
			my_show_div(obj); 
}

function hide_id(id) {
	if (!id) return;
	if (obj = my_getbyid(id)) 
		if (obj.style.display != 'none')
			my_hide_div(obj); 
}

function my_hide_div(obj) {
	if (!obj) return;
	obj.style.display = 'none';
	show_under(obj);
}
function my_show_div(obj) {
	if (!obj) return;
	obj.style.display = '';
	hide_under(obj);
}

function absolute_coords(obj) {
	var parent = obj;
	var x = 0;
	var y = 0;
	while (parent != null) {
		x += parent.offsetLeft;
		y += parent.offsetTop;
		parent = parent.offsetParent;
	}
	return [x,y];
}

var select_hidden_objects = [];

function hide_under(obj) {
	if (!is_ie) return;
	var coords = absolute_coords(obj);
	var x = coords[0]; var y = coords[1];
	var selects = document.getElementsByTagName('SELECT');
	if (!select_hidden_objects[obj.id]) select_hidden_objects[obj.id] = [];
//	for (i = 0; i < selects.length; i++) {
	for (i in selects) {
		var select = selects[i];
		if (select.parentNode == obj) continue;
		coords = absolute_coords(select);
		var sx = coords[0]; var sy = coords[1];
		if ((((x < sx) && (x + obj.offsetWidth  > sx)) || ((sx < x) && (sx + select.offsetWidth  > x))) &&
		    (((y < sy) && (y + obj.offsetHeight > sy)) || ((sy < y) && (sy + select.offsetHeight > y))) &&
                    select.style.visibility != 'hidden') {
			select_hidden_objects[obj.id][select_hidden_objects[obj.id].length] = select;
			select.style.visibility = 'hidden';
		}
	}
}

function show_under(obj) {
	if (!is_ie || !select_hidden_objects[obj.id]) return;
//	for (i = 0; i < select_hidden_objects[obj.id].length; i++)
	for (i in select_hidden_objects[obj.id])
		select_hidden_objects[obj.id][i].style.visibility = 'visible';
	select_hidden_objects[obj.id] = [];
}


function repl(where, what, wit) {
	if (! where || ! what) return;
        where = my_getbyid(where);
	if (! where) return;
	where[what] = wit;
//	where.focus();
        where.className = '';
}

var cookie_days = 10000;
function createCookie(name, value, days) {
  
  if (!days) days = cookie_days;
//alert('cook|' + name + '='+value +':'+days);
//  if (days) {
  var expires = '';
  var date = new Date();
  date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
  if (days)      expires = '; expires=' + date.toGMTString();
  document.cookie = name + '=' + value + expires + '; path=/';

}

function cookie_checkbox(obj) {
  createCookie(obj.name, (obj.checked ? 1 : 0), cookie_days);
}

function readCookie (name) {
  var nameEQ = name + '=';
  var ca = document.cookie.split (';');
//  for (var i = 0; i < ca.length; i++)
  for (i in ca)
    {
      var c = ca[i];
      while (c.charAt (0) == ' ')
	c = c.substring (1, c.length);
      if (c.indexOf (nameEQ) == 0)
	return c.substring (nameEQ.length, c.length);
    }
  return null;
}

function eraseCookie(name) { createCookie(name,'',-1); }

function setup_event (obj, on, event) {
  if(!obj || typeof(obj)!='object')return;
//  if(!obj)return;
//  alert('SE'+typeof(obj)+','+ on+','+ event)
//  document.writeln(dmp(obj))
//  alert(10+':'+'obj='+obj+';on='+on+';event='+event+';'+   obj['attachEvent']);
  if (//obj['attachEvent'] && 
  obj.attachEvent && !is_saf) {
//  alert(11+':'+'obj='+obj+';on='+on+';event='+event+';'+   obj.attachEvent);
  obj.attachEvent('on' + on, event);
  }
  else if (obj.addEventListener && !is_saf) {
  //alert(12);
  obj.addEventListener(on, event, false)}
//  else if(obj.hasOwnProperty('on' + on) ) 
//  else if ('on' + on in obj)
  else
  {
//alert(13);
//  alert('set to:'obj + ','+on+',' + obj['on' + on]);
  try {
  obj['on' + on] = event;
    } catch (ex) {}
  
  }
}

function error(desc, page, line) {
   alert('Error description:\t' + desc + '\nPage address:\t' + page + '\nLine number:\t' + line);
   return true;
}
//if(is_ie) window.onerror=error;


var i;
function dmp(obj){var r='';if (obj!='null') { for(i in obj){r+=i+" - "+obj[i]+"<br>\n"; } } return r;} 
//document.writeln(dmp(document.body.all["!!"]));
