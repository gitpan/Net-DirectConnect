//# $Id: search1.js 4320 2009-08-14 21:37:25Z pro $ $URL: svn://svn.setun.net/search/trunk/lib/search1.js $
// Copyright (C) 2003-2007 Oleg Alexeenkov http://pro.setun.net/search/ proler@gmail.com icq#89088275

var allow_show_adv_auto = 1;
//var adjust_sel;

//alert(is_ie + ':' + userAgent);


// thanks to yandex.ru for following script
var searchInputIsActive = false;
var CtrlUp = false;


function rimg(a) {
  var img = new Image();
  img.src = a;
}

function rhit(a) {
  rimg(root_url + '?view=http-redirect&save=' + a);
}

function rvote(a, obj) {
  rimg(a);
  if(String(obj.innerHTML).search(/\+1$/) < 1)obj.innerHTML+='+1';
}

var dls_cleared = 0;

function r(a) {  // old: var img = new Image();	img.src = a;
  if (dls_cleared || dls_string == 0) {
    dls_string = ''; 
    dls_cleared = 0;
  }
  createCookie('dls', a + dls_string , cookie_days);
  rhit(a);
}

function init() {
	if (document.getElementById) {
		document.onkeydown = register;
		if (document.forms['searchform']['q']) {
			document.forms['searchform']['q'].onfocus = function () {
				searchInputIsActive = true; 
				if (document.forms['searchform']['q'].select && CtrlUp) {document.forms['searchform']['q'].select();}
			};
			document.forms['searchform']['q'].onblur = function () {searchInputIsActive = false; CtrlUp = false;};
		}
	}

/* todo: menu area checking
		if (window.attachEvent && !is_saf)
		{
			document.attachEvent('onclick', menu_hide);
			window.attachEvent('onresize', menu_hide);
		}
		else if (document.addEventListener && !is_saf)
		{
			document.addEventListener('click', menu_hide, false);
			window.addEventListener('resize', menu_hide, false);
		}
		else
		{
			window.onclick = menu_hide;
			window.onresize = menu_hide;
		}
*/
}

function register(e) {
	var code;
	if (!e) var e = window.event;
	if (e.keyCode) code = e.keyCode;
	else if (e.which) code = e.which;
	if ((code == 13) && (e.ctrlKey == true)) document.forms['searchform'].submit();
	if (!searchInputIsActive) {
		if ((code == 37) && (e.ctrlKey == true)) {
			var destination = my_getbyid('prev_page');
			if (destination)	location.href = destination.href;
		}
		if ((code == 39) && (e.ctrlKey == true)) {
			var destination = my_getbyid('next_page');
			if (destination) location.href = destination.href;
		}
	}
	if ((code == 38) && (e.ctrlKey == true) && document.forms['searchform']['q']) {
		CtrlUp = true;
		document.forms['searchform']['q'].focus();
	}
}

/* http://www.alistapart.com/articles/alternate/ */
/* thanks to $FreeBSD: www/en/layout/js/styleswitcher.js,v 1.3 */
function setActiveStyleSheet_one (title, a) {
  if (a.getAttribute('rel').indexOf('style') != -1 && a.getAttribute('title')) {
    a.disabled = true;
    if (a.getAttribute ('title').indexOf(title) != -1) a.disabled = false;
  }
}

function setActiveStyleSheet (title) {
  var i, a, main;
  for (i = 0; (a = document.getElementsByTagName ('link')[i]); i++) 
     setActiveStyleSheet_one(title, a);
  for (i = 0; (a = document.getElementsByTagName ('style')[i]); i++)
     setActiveStyleSheet_one(title, a);
}

function set_position(parent, obj, dx, dy) {
	coords = absolute_coords(parent);
	px = coords[0] + dx; py = coords[1] + dy;
//	obj.style.display = '';
	py = py + (dy >= 0 ? parent.offsetHeight : 0);
	if (document.all) max_width = document.body.clientWidth - 10;
	else              max_width = window.innerWidth - 10;
	if (px + obj.offsetWidth > max_width) {
		px = max_width - obj.offsetWidth;
		if (px < 0) {
			obj.style.width = (max_width - 40) + 'px';
			px = 0;
		}
	}
	obj.style.left = px + 'px';
	obj.style.top  = py + 'px';
}

function toggle_position(parent, id, dx, dy) {
	if (!id) return;
		if (id.style.display == 'none')	{ set_position(parent, id, dx, dy); my_show_div(id); }
		else				{ my_hide_div(id); }
//	}
}


function show_adv() {
  show_id('tr_adv');
  hide_id('form-link-specify');
}

var current_menu, no_hide;

function no_hide_reset() { 
  no_hide = 0;
}


function menu_show() { 
}

function menu_hide() { 
//alert('hide');
	if (no_hide) return;
	my_hide_div(current_menu);
        current_menu = null;
	no_hide = 1;
        setTimeout('no_hide_reset()', 1);
}


function menu_toggle(parent, id, dx, dy) {
//alert('toggle');
	if ( !id ) return;
        if (current_menu == id) {menu_hide(); return;}
	menu_hide();
//	my_hide_div(current_menu);
//	if ( itm = my_getbyid(id) ) {
		if (id.style.display == 'none')	{ set_position(parent, id, dx, dy); my_show_div(id);  }
		else				{ my_hide_div(id); }
	current_menu = id;
}


// http://www.artlebedev.ru/svalka/InputPlaceholder.js
function InputPlaceholder(input, value, cssFilled, cssEmpty) {
	var thisCopy = this
	this.Input = input
	this.Value = value
	this.SaveOriginal = (input.value == value)
	this.CssFilled = cssFilled
	this.CssEmpty = cssEmpty
	this.setupEvent (this.Input, 'focus', function() {return thisCopy.onFocus()})
	this.setupEvent (this.Input, 'blur',  function() {return thisCopy.onBlur()})
	this.setupEvent (this.Input, 'keydown', function() {return thisCopy.onKeyDown()})
//if (this.Value)alert(this.Value+' = '+input.value );
	if (input.value == '' || input.value == this.Value) this.onBlur();
	return this
}
InputPlaceholder.prototype.setupEvent = function (elem, eventType, handler) {
	if (elem.attachEvent)	elem.attachEvent ('on' + eventType, handler);
	if (elem.addEventListener)	elem.addEventListener (eventType, handler, false);
}
InputPlaceholder.prototype.onFocus = function() {
	if (!this.SaveOriginal &&  this.Input.value == this.Value)	this.Input.value = '';
	else	this.Input.className = '';
}
InputPlaceholder.prototype.onKeyDown = function() { this.Input.className = ''; }
InputPlaceholder.prototype.onBlur = function() {
	if (this.Input.value == '' || this.Input.value == this.Value) {
		//this.Input.helpValue = this.Input.defaultValue = 
		this.Input.value = this.Value;
		this.Input.className = this.CssEmpty;
		
	}
	else	this.Input.className = this.CssFilled
}

/*
var saveclass = [];
function selected(id, class) {
	if ( ! id ) return;
	if ( itm = my_getbyid(id) ) {
		saveclass[id] = itm.className;
		itm.className = class;
	}
}

//selected('form-link-hide-advanced', 'selected');
*/

function hide_adv() {  hide_id('tr_adv');hide_id('form-link-hide-specify');show_id('form-link-specify'); }
function show_adv(auto) {  
// alert (auto + "+" + allow_show_adv_auto);
	if (!allow_show_adv_auto && auto) return;
	show_id('tr_adv');show_id('form-link-hide-specify');hide_id('form-link-specify'); 
}

var hilight_obj = [];
var hilight_class = [];
function hilight(num, obj, classname) {
//alert(num+', '+obj+', '+classname);
	if (!num) num = 0;
	if (hilight_obj[num]) hilight_obj[num].className = hilight_class[num];
	if (!obj) return;
	hilight_obj[num] = obj;
	hilight_class[num] = hilight_obj[num].className;
	hilight_obj[num].className = classname;
}




//#print '<td><a ',nameid('res_play_link'.$work{'n'}),' href="#" onclick="toggleview(\'res_play',$work{'n'},'\');this.innerHTML=\'zz\';">SHOW</a></td>' if $row->{'can_show'};

function show_image(n) {}
function hide_image(n) {}

