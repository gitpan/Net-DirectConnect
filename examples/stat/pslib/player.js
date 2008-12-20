

var created_plays = [], last_play, destroys = [], autocloses = [], showtimeout = [], oneplayer=0;

function toggle_play(n, full, type, destroy, autoclose, newwin) {
  var obj = my_getbyid('res_play'+n);
//alert(newwin);
//alert(obj +' '+ full + ' ' +type);
  if (!obj || !full ) return; //|| !type
var height = (this["play_height_"+type] || this["play_height"]); 
var width = (this["play_width_"+type] || this["play_width"]); 
//var destroy = parseInt(this["destroy_on_hide_"+type] || this["destroy_on_hide"]); 
destroys[n] = destroy;
autocloses[n] = autoclose;

//alert(height +' '+ width + ' ' +destroy+':'+this["destroy_on_hide_"+type] + ':' + this["destroy_on_hide"]);

  if (!oneplayer && !toggleview('res_play' + n) ) {
//    alert('hide'+oneplayer+n);
    if (n) {
    play_hide(n, destroy)
    }
    if(autoclose) last_play = '';

    return;
  }
 if(!n) ++oneplayer;
    if (autoclose && last_play && autocloses[last_play]) {
//      alert(1);
      toggleview('res_play' + last_play);
      play_hide(last_play); //, destroy
//      if (destroy) my_getbyid('res_play'+last_play).innerHTML = '', created_plays[last_play] = '';
    }
    if (autoclose) last_play = n;
    if (showtimeout[n]) clearTimeout(showtimeout[n]);
//    alert(created_plays[n]);
    if (created_plays[n] != full) {
      created_plays[n] = full;

      var player = "";
      switch (type) {
       case 'image':
	player += '<img '
	if (width)	player += 'width="'+width+'" '
	if (height)	player += 'height="'+height+'" '
	player += 'src="'+full+'">';
       break;         
       case 'audio':
       case 'video':
       case 'playlist':
	player += "<OBJECT ID='Player' height='"+height+"' width='"+width+"' CLASSID='CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6'>"
	player += "<PARAM name='URL' value='" + full + "' id='insert_1'>"
	player += "<PARAM name='uiMode' value='full'>"
	player += "<PARAM name='mute' value='false'>"
	player += "<PARAM name='ShowControls' value='1'>"
	player += "<PARAM name='ShowStatusBar' value='1'>"
//	player += "<PARAM name='ShowDisplay' value='1'>"
        player += "<param name='controller' value='1'>"
	player += "<PARAM NAME='AutoSize' VALUE='1'>"
	player += "<EMBED type='application/x-mplayer2' "
	player += "pluginspage = 'http://www.microsoft.com/Windows/MediaPlayer/' "
	player += "SRC='" + full + "' "
	player += "name='Player' "
	if (width)	player += "width='"+width+"' "
	if (height)	player += "height='"+height+"' "
	player += "AutoStart='true' "
	player += "showcontrols='1' "
	player += "showstatusbar='1' "
//	player += "showdisplay='1' "
	player += "AutoSize='1' "
	player += "controller='1' "
	player += "id='insert_2'>"
	player += "</EMBED>"
/*<noembed>_§ўЁ-Ёв_, ¤<п Ё_ал ў ¬ -г¦_- <a href="http://www.macromedia.com/go/getflashplayer/" target="_blank">Flash Player</a>Curveball</noembed>*/
	player += "</OBJECT>"
//	document.getElementById('radio').innerHTML = player;
//<embed width="320" height="260" src=".....wmv"></embed>
       break;         

       
       case 'flash':
//	var player = "";
///*
       player += '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" '
       player += 'codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0" '
       if (width)	player += 'width="'+width+'" '
       if (height)	player += 'height="'+height+'" '
       player += '>'
//       player += '<param name="menu" value="false" />'
	player += '<param name="movie" value="'+ full +'" />'
	player += '<param name="type" value="application/x-shockwave-flash" />'
	player += '<param name="pluginspage" value="http://www.macromedia.com/go/getflashplayer/" />'
	player += '<param name="bgcolor" value="#000" />'
	player += '<param name="quality" value="high" />'
	if (width)	player += '<param name="width" value="'+width+'"/>'
	if (height)	player += '<param name="height" value="'+height+'"/>'
	player += '<embed src="'+ full +'" '
	if (width)	player += 'width="600" '
	if (height)	player += 'height="600" ' 
	player += 'bgcolor="#000" quality="high" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer/" menu="false"></embed>'
	player += '<noembed>Извините, вам нужен <a href="http://www.macromedia.com/go/getflashplayer/" target="_blank">Flash Player</a></noembed>'
	player += '</object>'
//*/
	default:
	break;
      } 
      if (player) {
        if (this["rhit"])
          this["rhit"](full);
//        rhit(full);
        if (newwin) {
         var win = window.open('', 'psplayer', 'height='+height+',width='+width+',menubar,resizable,scrollbars,status,toolbar', 0)
document.writeln(dmp(win))
         win.innerHTML = player

	} else {
         obj.innerHTML = player
        }
      }

//       + '<br/>dbg: full=' +full +' <br/> type=' + type + ' destroy='+ destroy + ' autoclose=' +autoclose + ' width='+ width+ ' height=' +height+ (width ? ' wt' : ' wf') + (height? ' ht' : ' hf') 
    }

    if(!newwin && n)
     my_getbyid('res_play_link'+n).innerHTML = lang_hide;

//  }
}


function play_hide(n) { //, destroy
    if (!n) return;
    var obj = my_getbyid('res_play'+n);
    my_getbyid('res_play_link'+n).innerHTML = lang_show;
    if (destroys[n]) {
//alert('destrooo='+destroy);
      obj.innerHTML = '';
      created_plays[n] = '';
    }
}

