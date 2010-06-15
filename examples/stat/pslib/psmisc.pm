#!/usr/bin/perl
#$Id: psmisc.pm 4412 2010-03-15 00:13:51Z pro $ $URL: svn://svn.setun.net/search/trunk/lib/psmisc.pm $

=copyright
PRO-search shared library
Copyright (C) 2003-2007 Oleg Alexeenkov http://pro.setun.net/search/ proler@gmail.com icq#89088275

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
=cut

#print "Content-type: text/html\n\n" if defined($ENV{'SERVER_PORT'}); # for web dev debug
#print "misc execute " , $mi++;
#=pac
package psmisc;
use strict;
our $VERSION = ( split( ' ', '$Revision: 4412 $' ) )[1];
use locale;
use Encode;
use POSIX qw(strftime);
use Data::Dumper;    #dev only
$Data::Dumper::Sortkeys = 1;
#use vars qw( %config %work %stat %static $param %processor %program %out );    #%human,
#our ( @ISA, @EXPORT, @EXPORT_OK );
#our ( @ISA, @EXPORT, @EXPORT_OK );
use vars qw( @ISA @EXPORT @EXPORT_OK );
require Exporter;
#our
#@
@ISA = qw(Exporter);
#our
#@
@EXPORT = qw(
  get_params_one
  get_params
  encode_url
  encode_url_link
  decode_url
  printlog
  printprog
  openproc
  state
  hconfig
  html_chars
  name_to_ip
  normalize_ip
  ip_to_name
  counter
  timer
  join_url
  split_url
  full_host
  cp_trans
  utf_trans
  to_utf_trans
  cp_trans_hash
  cp_detect_trans
  lang
  min
  max
  alarmed
  mkdir_rec
  open_out_file
  close_out_file
  sleeper
  mysleep
  check_int
  shuffle
  config_reload
  conf
  http_get
  http_get_code
  loadlist
  shelldata
  %work %config %stat %static $param
  %processor %program
  );    #%human %out
#flush
our ( %config, %work, %stat, %static, $param, %processor, %program, $root_path, %human );    #%human, %out,
use Socket;
use Time::HiRes qw(time);
no warnings qw(uninitialized);
#my %human;
#sub conf_once {
sub config_init {
  return if $static{'lib_init_psmisc'}{ $ENV{'SCRIPT_FILENAME'} }++;
  my ($param) = @_;
  #print "  config_init;";
  #caller_trace(10);
  conf(
    sub {
#print "  config_init:sub;";
#A                                                              |                                                            YA  E   a                                                              |                                                            ya  e   |-ukr------------------|
      $config{'trans'}{'cp1251'} ||=
"\xC0\xC1\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xCB\xCC\xCD\xCE\xCF\xD0\xD1\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xDB\xDC\xDD\xDE\xDF\xA8\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF0\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFB\xFC\xFD\xFE\xFF\xB8\xB2\xB3\xAF\xBF\xAA\xBA";
      $config{'trans'}{'koi8-r'} ||=
"\xE1\xE2\xF7\xE7\xE4\xE5\xF6\xFA\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF0\xF2\xF3\xF4\xF5\xE6\xE8\xE3\xFE\xFB\xFD\xFF\xF9\xF8\xFC\xE0\xF1\xB3\xC1\xC2\xD7\xC7\xC4\xC5\xD6\xDA\xC9\xCA\xCB\xCC\xCD\xCE\xCF\xD0\xD2\xD3\xD4\xD5\xC6\xC8\xC3\xDE\xDB\xDD\xDF\xD9\xD8\xDC\xC0\xD1\xA3\xB6\xA6\xB7\xA7\xB4\xA4";
      $config{'trans'}{'iso8859-5'} ||=
"\xB0\xB1\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xBB\xBC\xBD\xBE\xBF\xC0\xC1\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xCB\xCC\xCD\xCE\xCF\xA1\xD0\xD1\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xDB\xDC\xDD\xDE\xDF\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF1\xA6\xF6\xA7\xF7\xA4\xF4";
      $config{'trans'}{'cp866'} ||=
"\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8A\x8B\x8C\x8D\x8E\x8F\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9A\x9B\x9C\x9D\x9E\x9F\xF0\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xAB\xAC\xAD\xAE\xAF\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF1\xF6\xF7\xF8\xF9\xF4\xF5";
      $config{'trans'}{'utf-8'} ||= "\xD0\xD1";    #JUST TRICK for autodetect
      #$config{'trans_up'}{$_} = (split//, $config{'trans'}{$_})[0..32] for keys %{$config{'trans'}};
      $config{'trans_up'}{$_}   = substr( $config{'trans'}{$_}, 0,  33 ),
        $config{'trans_lo'}{$_} = substr( $config{'trans'}{$_}, 33, 33 ),
        #print("$config{'trans_up'}{$_}\n$config{'trans_lo'}{$_}\n"),
        for grep { length $config{'trans'}{$_} >= 66 } keys %{ $config{'trans'} };
      #exit;

=with 50% UPPER case
#cp detect with cp_learn_symbols=10; from 28691 bytes text
  $config{'trans_detect'}{'cp1251'}	||= '\xCE\xEE\xC0\xE0\xE5\xC5\xD2\xF2\xE8\xC8';	#  [≠çÓûÖ•‡êïÂ] = [≠çÓûÖ•‡êïÂ];	stat:≠[CE]=658; ç[EE]=658; Ó[C0]=578; û[E0]=578; Ö[E5]=503; •[C5]=503; ‡[D2]=434; ê[F2]=434; ï[E8]=422; Â[C8]=422; 
  $config{'trans_detect'}{'cp866'}	||= '\xAE\x8E\x80\xA0\xA5\x85\x92\xE2\xA8\x88';	#  [R__Õ_:'Åª_] = [ç≠ÓûÖ•‡êïÂ];	stat:ç[AE]=658; ≠[8E]=658; Ó[80]=578; û[A0]=578; Ö[A5]=503; •[85]=503; ‡[92]=434; ê[E2]=434; ï[A8]=422; Â[88]=422; 
  $config{'trans_detect'}{'koi8-r'}	||= '\xCF\xEF\xC1\xE1\xC5\xE5\xD4\xF4\xC9\xE9';	#  [Æé†Ä•Ö‚í®à] = [ç≠ûÓÖ•ê‡ïÂ];	stat:ç[CF]=658; ≠[EF]=658; û[C1]=578; Ó[E1]=578; Ö[C5]=503; •[E5]=503; ê[D4]=434; ‡[F4]=434; ï[C9]=422; Â[E9]=422; 
  $config{'trans_detect'}{'utf-8'}	||= '\xD0\xD1\x9E\xBE\xB0\x90\x95\xB5\xA2\x82';	#  [ØÔ__«_Ç’'] = [ØÔÁ_«Ø„ÇÅ°];	stat:Ø[D0]=10542; Ô[D1]=1934; Á[9E]=658; _[BE]=658; «[B0]=578; Ø[90]=578; „[95]=503; Ç[B5]=503; Å[A2]=434; °[82]=434; 
#$config{'trans_detect'}{'iso8859-5'}	||= '\xDE\xBE\xD0\xB0\xB5\xD5\xC2\xE2\xB8\xD8';	#  [Á_Ø«Ç„°ÅÀÏ] = [ç≠ûÓ•Ö‡êÂï];	stat:ç[DE]=658; ≠[BE]=658; û[D0]=578; Ó[B0]=578; •[B5]=503; Ö[D5]=503; ‡[C2]=434; ê[E2]=434; Â[B8]=422; ï[D8]=422; 
=cut

=was
#cp detect with cp_learn_symbols=20; from 14344 bytes text
      $config{'trans_detect'}{'cp1251'} ||= '\xEE\xE0\xE5\xF2\xE8\xED\xF1\xF0\xE2\xEA\xEB\xEF\xE4\xFC\xEC\xE7\xF3\xE1\xFB\xF7'
        ; #  [çûÖêïåüèÅâäéÑùãÉëÄòÇ] = [çûÖêïåüèÅâäéÑùãÉëÄòÇ];	stat:ç[EE]=649; û[E0]=573; Ö[E5]=489; ê[F2]=425; ï[E8]=416; å[ED]=410; ü[F1]=379; è[F0]=296; Å[E2]=269; â[EA]=256; ä[EB]=221; é[EF]=194; Ñ[E4]=174; ù[FC]=156; ã[EC]=153; É[E7]=152; ë[F3]=141; Ä[E1]=109; ò[FB]=108; Ç[F7]=100;
      $config{'trans_detect'}{'cp866'} ||= '\xAE\xA0\xA5\xE2\xA8\xAD\xE1\xE0\xA2\xAA\xAB\xAF\xA4\xEC\xAC\xA7\xE3\xA1\xEB\xE7'
        ; #  [RÕ_Åª-Äû’”<∆÷ãæ∑ñ∫äÉ] = [çûÖêïåüèÅâäéÑùãÉëÄòÇ];	stat:ç[AE]=649; û[A0]=573; Ö[A5]=489; ê[E2]=425; ï[A8]=416; å[AD]=410; ü[E1]=379; è[E0]=296; Å[A2]=269; â[AA]=256; ä[AB]=221; é[AF]=194; Ñ[A4]=174; ù[EC]=156; ã[AC]=153; É[A7]=152; ë[E3]=141; Ä[A1]=109; ò[EB]=108; Ç[E7]=100;
      $config{'trans_detect'}{'koi8-r'} ||= '\xCF\xC1\xC5\xD4\xC9\xCE\xD3\xD2\xD7\xCB\xCC\xD0\xC4\xD8\xCD\xDA\xD5\xC2\xD9\xDE'
        ; #  [Æ†•‚®≠·‡¢™´Ø§Ï¨ß„°ÎÁ] = [çûÖêïåüèÅâäéÑùãÉëÄòÇ];	stat:ç[CF]=649; û[C1]=573; Ö[C5]=489; ê[D4]=425; ï[C9]=416; å[CE]=410; ü[D3]=379; è[D2]=296; Å[D7]=269; â[CB]=256; ä[CC]=221; é[D0]=194; Ñ[C4]=174; ù[D8]=156; ã[CD]=153; É[DA]=152; ë[D5]=141; Ä[C2]=109; ò[D9]=108; Ç[DE]=100;
      $config{'trans_detect'}{'utf-8'} ||= '\xD0\xD1\xBE\xB0\xB5\x82\xB8\xBD\x81\x80\xB2\xBA\xBB\xBF\xB4\x8C\xBC\xB7\x83\xB1'
        ; #  [ØÔ_«Ç'À____–>¸___“_+] = [ØÔ_«Ç°À_†Ó_–>¸_´_“Ê+];	stat:Ø[D0]=4352; Ô[D1]=1894; _[BE]=649; «[B0]=573; Ç[B5]=489; °[82]=425; À[B8]=416; _[BD]=410; †[81]=379; Ó[80]=296; _[B2]=269; –[BA]=256; >[BB]=221; ¸[BF]=194; _[B4]=174; ´[8C]=156; _[BC]=153; “[B7]=152; Ê[83]=141; +[B1]=109;
=cut

      #cp detect with cp_learn_symbols=20; from 145699 bytes text
      $config{'trans_detect'}{'cp1251'} = '\xEE\xE0\xE5\xE8\xED\xF2\xF1\xF0\xEB\xE2\xEA\xF3\xEF\xEC\xE4\xFF\xFB\xFC\xE7\xE3'
        ; #  [Ó‡ÂËÌÚÒÎ‚ÍÛÔÏ‰ˇ˚¸Á„] = [Ó‡ÂËÌÚÒÎ‚ÍÛÔÏ‰ˇ˚¸Á„];	stat:Ó[EE]=12122; ‡[E0]=10566; Â[E5]=9827; Ë[E8]=8929; Ì[ED]=7504; Ú[F2]=6931; Ò[F1]=6839; [F0]=6744; Î[EB]=6225; ‚[E2]=5384; Í[EA]=4505; Û[F3]=3912; Ô[EF]=3864; Ï[EC]=3811; ‰[E4]=3497; ˇ[FF]=3047; ˚[FB]=2693; ¸[FC]=2628; Á[E7]=2192; „[E3]=1934;
      $config{'trans_detect'}{'utf-8'} = '\xD0\xD1\xBE\xB0\xB5\xB8\xBD\x82\x81\x80\xBB\xB2\xBA\x83\xBF\xBC\xB4\x8F\x8B\x8C'
        ; #  [–—?∞˜∏?'??>I∫?ø???<?] = [–—?∞˜∏?¬¡¿>I∫√ø??œÀÃ];	stat:–[D0]=88304; —[D1]=39900; ?[BE]=12122; ∞[B0]=10566; ˜[B5]=9827; ∏[B8]=8929; ?[BD]=7504; ¬[82]=6931; ¡[81]=6845; ¿[80]=6744; >[BB]=6225; I[B2]=5384; ∫[BA]=4505; √[83]=3912; ø[BF]=3864; ?[BC]=3811; ?[B4]=3497; œ[8F]=3047; À[8B]=2693; Ã[8C]=2628;
      $config{'trans_detect'}{'cp866'} = '\xAE\xA0\xA5\xA8\xAD\xE2\xE1\xE0\xAB\xA2\xAA\xE3\xAF\xAC\xA4\xEF\xEB\xEC\xA7\xA3'
        ; #  [R†?®-‚·‡<¢™„Ø¨§ÔÎÏß?] = [Ó‡ÂËÌÚÒÎ‚ÍÛÔÏ‰ˇ˚¸Á„];	stat:Ó[AE]=12122; ‡[A0]=10566; Â[A5]=9827; Ë[A8]=8929; Ì[AD]=7504; Ú[E2]=6931; Ò[E1]=6839; [E0]=6744; Î[AB]=6225; ‚[A2]=5384; Í[AA]=4505; Û[E3]=3912; Ô[AF]=3864; Ï[AC]=3811; ‰[A4]=3497; ˇ[EF]=3047; ˚[EB]=2693; ¸[EC]=2628; Á[A7]=2192; „[A3]=1934;
      $config{'trans_detect'}{'koi8-r'} = '\xCF\xC1\xC5\xC9\xCE\xD4\xD3\xD2\xCC\xD7\xCB\xD5\xD0\xCD\xC4\xD1\xD9\xD8\xDA\xC7'
        ; #  [œ¡≈…Œ‘”“Ã◊À’–Õƒ—Ÿÿ⁄«] = [Ó‡ÂËÌÚÒÎ‚ÍÛÔÏ‰ˇ˚¸Á„];	stat:Ó[CF]=12122; ‡[C1]=10566; Â[C5]=9827; Ë[C9]=8929; Ì[CE]=7504; Ú[D4]=6931; Ò[D3]=6839; [D2]=6744; Î[CC]=6225; ‚[D7]=5384; Í[CB]=4505; Û[D5]=3912; Ô[D0]=3864; Ï[CD]=3811; ‰[C4]=3497; ˇ[D1]=3047; ˚[D9]=2693; ¸[D8]=2628; Á[DA]=2192; „[C7]=1934;
#$config{'trans_detect'}{'iso8859-5'}	= '\xDE\xD0\xD5\xD8\xDD\xE2\xE1\xE0\xDB\xD2\xDA\xE3\xDF\xDC\xD4\xEF\xEB\xEC\xD7\xD3';	#  [ﬁ–’ÿ›‚·‡€“⁄„ﬂ‹‘ÔÎÏ◊”] = [Ó‡ÂËÌÚÒÎ‚ÍÛÔÏ‰ˇ˚¸Á„];	stat:Ó[DE]=12122; ‡[D0]=10566; Â[D5]=9827; Ë[D8]=8929; Ì[DD]=7504; Ú[E2]=6931; Ò[E1]=6839; [E0]=6744; Î[DB]=6225; ‚[D2]=5384; Í[DA]=4505; Û[E3]=3912; Ô[DF]=3864; Ï[DC]=3811; ‰[D4]=3497; ˇ[EF]=3047; ˚[EB]=2693; ¸[EC]=2628; Á[D7]=2192; „[D3]=1934;
#$config{'trans_detect'}{'iso8859-5'}	||= '\xDE\xD0\xD5\xE2\xD8\xDD\xE1\xE0\xD2\xDA\xDB\xDF\xD4\xEC\xDC\xD7\xE3\xD1\xEB\xE7';	#  [ÁØ„ÅÏÈÄû‡ßËÍ‚ãÌ¢ñÔäÉ] = [çûÖêïåüèÅâäéÑùãÉëÄòÇ];	stat:ç[DE]=649; û[D0]=573; Ö[D5]=489; ê[E2]=425; ï[D8]=416; å[DD]=410; ü[E1]=379; è[E0]=296; Å[D2]=269; â[DA]=256; ä[DB]=221; é[DF]=194; Ñ[D4]=174; ù[EC]=156; ã[DC]=153; É[D7]=152; ë[E3]=141; Ä[D1]=109; ò[EB]=108; Ç[E7]=100;
#$config{'trans_detect'}{'cp1251'}	||= "\xE0\xC0\xEE\xCE"; #ûÓ ç≠
#$config{'trans_detect'}{'cp866'}	||= "\xA0\x80\xAE\x8E";
#$config{'trans_detect'}{'koi8-r'}	||= "\xC1\xE1\xCF\xEF";
## $config{'trans_detect'}{'iso8859-5'}	||= "\xD0\xB0\xDE\xBE";
      #$config{'trans_detect'}{'utf-8'}	||= "\xD0\xD1";
      #$config{'trans_detect'}{'bin'} ||= join '', map{'\\x'.sprintf '%02X', $_}0..0x08,0x0B,0x0C,0x0E,0x0F;
      #$config{'trans_detect'}{'latin'} ||= 'a-zA-Z';
      #print $config{'trans_detect'}{'bin'};exit;
      #$config{'trans_name'}{'cp1251'} ||= 'cp1251';
      $config{'trans_name'}{'win1251'}      ||= 'cp1251';
      $config{'trans_name'}{'windows1251'}  ||= 'cp1251';
      $config{'trans_name'}{'windows-1251'} ||= 'cp1251';
      $config{'trans_name'}{'win'}          ||= 'cp1251';
      $config{'trans_name'}{'1251'}         ||= 'cp1251';
      #$config{'trans_name'}{'koi8-r'} ||= 'koi8-r';
      $config{'trans_name'}{'koi8r'} ||= 'koi8-r';
      $config{'trans_name'}{'koi8'}  ||= 'koi8-r';
      $config{'trans_name'}{'koi'}   ||= 'koi8-r';
      #$config{'trans_name'}{'iso8859-5'} ||='iso8859-5';
      $config{'trans_name'}{'iso88595'} ||= 'iso8859-5';
      $config{'trans_name'}{'iso8859'}  ||= 'iso8859-5';
      $config{'trans_name'}{'iso'}      ||= 'iso8859-5';
      #$config{'trans_name'}{'cp866'} ||='cp866';
      $config{'trans_name'}{'866'} ||= 'cp866';
      $config{'trans_name'}{'dos'} ||= 'cp866';
      #$config{'trans_name'}{'utf-8'} ||= 'utf-8';
      $config{'trans_name'}{'utf8'}  ||= 'utf-8';
      $config{'trans_name'}{'utf'}   ||= 'utf-8';
      $config{'cp_detect_strings'}   ||= 0;
      $config{'cp_detect_letters'}   ||= 2;
      $config{'cp_detect_length'}    ||= 10000;
      $config{'kilo'}                ||= 8;                                                      # 5000k 6000k 7000k >8<m 9m 10m
      $config{'lng'}{'en'}{'months'} ||= [qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)];
      $config{'lng'}{'ru'}{'months'} ||= [qw(ﬂÌ‚ ‘Â‚ Ã‡ ¿Ô Ã‡È »˛Ì »˛Î ¿‚„ —ÂÌ ŒÍÚ ÕÓˇ ƒÂÍ)];
      @{ $config{'lng'}{$_}{'month_table'} }{ @{ $config{'lng'}{$_}{'months'} || [] } } = ( 0 .. 11 )
        for keys %{ $config{'lng'} };
      #@{ $config{'lng'}{''}{'month_table'} }{ @{ $config{'lng'}{''}{'months'} } } = ( 0 .. 11 )  ;
      $config{'lng'}{'en'}{'wdays'} ||= [qw(Sun Mon Tue Wed Thu Fri Sat)];
      $config{'log_screen'}         ||= 1;
      $config{'log_dir'}            ||= $config{'root_path'};
      $config{'log_default'} ||= 'log.log' unless $ENV{'SERVER_PORT'};
      #$config{'log_all'}     ||= '#book.log';
      #$config{'log_all'}     ||= '1';
      $config{'encode_url_file_mask'} ||= '[^a-zA-Z0-9\-.()_]';                                  #url = '[^a-zA-Z0-9\-.()_!,]';
      $config{'human'}{'date'} ||= sub {                                                         #v1
        #my ( $day_of_month, $month, $year ) = ( localtime( ( $_[0] or time() ) ) )[ 3 .. 5 ];
        #return sprintf( '%04d' . ( ( ( $_[1] or '/' ) . '%02d' ) x 2 ), $year + 1900, $month + 1, $day_of_month );
        my $d = $_[1] || '/';
        return strftime "%Y${d}%m${d}%d", localtime( $_[0] || time() );
        #strftime "%Y%m%d%H%M%S", localtime
      };
      $config{'human'}{'time'} ||= sub {
#return          sprintf( join( ( $_[1] or ':' ), ( ("%02d") x 3 ) ), ( reverse( ( localtime( ( $_[0] or time() ) ) )[ 0 .. 2 ] ) ) );
        my $d = $_[1] || ':';
        return strftime "%H${d}%M${d}%S", localtime( $_[0] || time() );
      };
      $config{'human'}{'date_time'} ||=
        sub { return human( 'date', $_[0] || time(), $_[2] ) . ( $_[1] || '-' ) . human( 'time', $_[0] || time(), $_[3] ); };
      $config{'human'}{'float'} ||= sub {    #v1
        return ( $_[0] < 8 and $_[0] - int( $_[0] ) )
          ? sprintf( '%.' . ( $_[0] < 1 ? 3 : ( $_[0] < 3 ? 2 : 1 ) ) . 'f', $_[0] )
          : int( $_[0] );
      };
      $config{'human'}{'micro_time'} ||= sub {
        my $now = time();
        ( $now = human( 'float', abs( int($now) - $now ) ) ) =~ s/^0//;
        return ( $now or '' );
      };
      $config{'human'}{'rfc822_date_time'} ||= sub {
        my ( $day_of_month, $month, $year, $wday ) = ( localtime( ( $_[0] or time() ) ) )[ 3 .. 6 ];
        return sprintf( $config{'lng'}{'en'}{'wdays'}[$wday] . ', %02d ' . $config{'lng'}{'en'}{'months'}[$month] . ' %02d',
          $day_of_month, $year + 1900 )
          . ' '
          . $config{'human'}{'time'}->( ( $_[0] or time() ) )
          . ' +0300';
      };
      $config{'human'}{'size'} ||= sub {
        my ( $size, $sp, $kilo ) = @_;
        $sp ||= ( $ENV{'SERVER_PORT'} ? '&nbsp;' : ' ' );
        $kilo ||= $config{'kilo'} || 8;
        return int( $size / 1099511627776 ) . $sp . 'TB' if ( $size >= $kilo * 1099511627776 );
        return int( $size / 1073741824 ) . $sp . 'GB'    if ( $size >= $kilo * 1073741824 );
        return int( $size / 1048576 ) . $sp . 'MB'       if ( $size >= $kilo * 1048576 );
        return int( $size / 1024 ) . $sp . 'KB'          if ( $size >= $kilo * 1024 );
        return human( 'float', $size ) . $sp . 'B' if ( $size > 0 );
        return $size;
      };
      $config{'human'}{'number_k'} ||= sub {
        local $_ = $_[0];
        $_ *= 1024          if ( $_ =~ s/kb?$//gi );
        $_ *= 1048576       if ( $_ =~ s/mb?$//gi );
        $_ *= 1073741824    if ( $_ =~ s/gb?$//gi );
        $_ *= 1099511627776 if ( $_ =~ s/tb?$//gi );
        return $_;
      };
      $config{'human'}{'procent'} ||= sub {    #v1
        return sprintf( '%' . ( $_[0] < 10 ? '.3f' : 'd' ), $_[0] ) . '%';
      };
      $config{'human'}{'time_period'} ||= sub {    #v0
        my ( $tim, $delim, $sign ) = @_;
        $sign = '-', $tim = -$tim if $tim < 0;
        #print("tpern[", $tim, ']'),
        return '' if $tim == 0 or $tim > 1000000000;
        #print("tperf[", $tim, ']'),
        return ( $sign . human( 'float', $tim ) . $delim . "s" ) if $tim < 60;
        $tim = $tim / 60;
        return ( $sign . int($tim) . $delim . "m" ) if $tim < 60;
        $tim = $tim / 60;
        return ( $sign . int($tim) . $delim . "h" ) if $tim < 24;
        $tim = $tim / 24;
        return ( $sign . int($tim) . $delim . "d" ) if $tim <= 31;
        $tim = $tim / 30.5;
        return ( $sign . int($tim) . $delim . "M" ) if $tim < 12;
        $tim = $tim / 12;
        return ( $sign . int($tim) . $delim . "Y" );
      };
      $config{'human'}{'number'} ||= sub {    #v0 #FIXIT
        #return $_ = reverse( join( ' ', split( /(\d{3})/, reverse $_[0] ) ) );
        #local $_ = reverse( join( ' ', split( /(\d{3})/, reverse $_[0] ) ) );
        #return $_;
        #return reverse( join( ' ', grep {length $_} split( /(\d{3})/, reverse $_[0] ) ) )
        return local $_ = reverse join ' ', grep { length $_ } split /(\d{3})/, reverse $_[0];
      };
      #print 'dh1:',Dumper $config{'human'};
      $config{'human'}{'string_long'} ||= sub {
        my $maxlen = ( $_[1] or 20 );
        html_chars( \$_[0] );
        return $_[0] if length $_[0] <= $maxlen;
        my $print = substr( $_[0], 0, $maxlen );
        $print =~ s/[\xD0\xD1]$//;
        $_[0]  =~ s/\"/&quot;/g;
        return "<span title=\"" . $_[0] . "\">$print...</span>";
      };
      #print 'dh2:',Dumper $config{'human'};
    },
    1010,
  );
}

sub get_params_one(@) {    # p=x,p=y,p=z => p=x,p1=y,p2=z ; p>=z => p=z, p_mode='>'; p => p; -p => -p=1;
  local %_ = %{ ref $_[0] eq 'HASH' ? shift : {} };
  for (@_) {               # PERL RULEZ # SORRY # 8-) #
    tr/+/ /, s/%([a-f\d]{2})/pack 'C', hex $1/gei for my ( $k, $v ) = /^([^=]+=?)=(.+)$/ ? ( $1, $2 ) : ( /^([^=]*)=?$/, /^-/ );
    $_{"${1}_mode$2"} .= $3 if $k =~ s/^(.+?)(\d*)([=!><~@]+)$/$1$2/;
    $k =~ s/(\d*)$/($1 < 100 ? $1 + 1 : last)/e while defined $_{$k};
    $_{$k} = $v;           #lc can be here
  }
  wantarray ? %_ : \%_;
}

sub get_params(;$$) {      #v7
  my ( $string, $delim ) = @_;
  $delim ||= '&';
  read( STDIN, local $_ = '', $ENV{'CONTENT_LENGTH'} ) if !$string and $ENV{'CONTENT_LENGTH'};
  local %_ = $string
    ? get_params_one split $delim, $string
    : (
    get_params_one(@ARGV), map { get_params_one split $delim, $_ } split( /;\s*/, $ENV{'HTTP_COOKIE'} ),
    $ENV{'QUERY_STRING'}, $_
    );
  wantarray ? %_ : \%_;
}

=todo
------------jCZJhSDkEEg0Avf4h2hejC
Content-Disposition: form-data; name="n1"

ertyeryery
------------jCZJhSDkEEg0Avf4h2hejC
Content-Disposition: form-data; name="n2"

ryertytry
------------jCZJhSDkEEg0Avf4h2hejC
Content-Disposition: form-data; name="q"

ertyeryery
------------jCZJhSDkEEg0Avf4h2hejC--    
=cut

sub encode_url($;$) {    #v5
  my ( $str, $mask ) = @_;
  return $str if defined $mask and !$mask;
  $mask ||= '[^a-zA-Z0-9\-.()_!,]';
  #return join( '+', map { s/$mask/'%'.sprintf('%02X', ord($&))/ge; $_ } split( /\x20/, $str ) );
  return join '+', map { s/($mask)/sprintf'%%%02X',ord $1/ge; $_ } split /\x20/, $str;
}

sub encode_url_link($;$) {
  #v5
  my ( $str, $mask ) = @_;
  return $str if defined $mask and !$mask;
  return $str if $str =~ /^(magnet|file):/i;
  #fixed?
  return $str if $config{'client_ie'};
  local %_ = split_url($str);
  $mask ||= '[^a-zA-Z0-9\-.()_\:@\/!,=]';
  $_{$_} =~ s/$mask/'%'.sprintf('%2X', ord($&))/ge for keys %_;
  return join_url( \%_ );
}

sub decode_url($) {    #v1
  my ($str) = @_;
  $str =~ s/%([a-fA-F0-9]{2})/pack('C', hex($1))/eg;
  return $str;
}
{
  my %fh;
  my $savetime;

  sub file_append(;$@) {
    #print( 'append', @_, "\n" );
    local $_ = shift;
    #print "append to [$_]";
    for ( defined $_ ? $_ : keys %fh ) {
      #print("")
      #printlog('dev', 'closing file', $_),
      close( $fh{$_} ), delete( $fh{$_} ) if $fh{$_} and !@_;
    }
    return if !@_;
    unless ( $fh{$_} ) { return unless open( $fh{$_}, '>>', $_ ); }
    print { $fh{$_} } @_;
    if ( time() > $savetime + 5 ) {
      #printlog('dev', 'closing file', $_),
      close( $fh{$_} ), delete( $fh{$_} ) for keys %fh;
      $savetime = time();
    }
    return @_;
  }

  END {
    #printlog('dev', 'closing file', $_),
    close( $fh{$_} ) for keys %fh;
  }
}

sub file_rewrite(;$@) {
  unlink $_[0] if $_[0];    #|| return;
  return &file_append, file_append();
}
#all def fac =
#u   u   u  0
#u   1   u  1
#u   0   u  0
#u   1   0  0
#u   *   1  1
#0   *   *  0
#1   *   *  1
sub printlog (@) {          #v5
  #print "[devlog][fac:$_[0]=".$config{ 'log_' . $_[0]}."][][log_screen=$config{'log_screen'} ]\n",Dumper (\%config );
  return if defined $config{ 'log_' . $_[0] } and !$config{ 'log_' . $_[0] } and !$config{'log_all'};
  #my $file = ( $config{'log_all'} or ( defined $config{ 'log_' . $_[0] } ? $config{ 'log_' . $_[0] } : '' ) );
  my $file = ( (
      defined $config{'log_all'}
      ? $config{'log_all'}
      : ( defined $config{ 'log_' . $_[0] } ? $config{ 'log_' . $_[0] } : $config{'log_default'} )
    )
  );
  my $noscreen;
  for ( 0 .. 1 ) {
    $noscreen = 1 if $file =~ s/^[\-_]// or !$file;
    $noscreen = 0 if $file =~ s/^[+\#]//;
    $file = $config{'log_default'}, next if $file eq '1';
    last;
  }
  $file = undef if $file eq '1';
  my $html = !$file and ( $ENV{'SERVER_PORT'} or $config{'view'} eq 'html' or $config{'view'} =~ /http/i );
  my $xml = $config{'view'} eq 'xml';
  my $delim = $config{'log_delim'} || ' ';
  my @string = (
    ( $xml  ? '<debug><![CDATA['    : () ),
    ( $html ? '<div class="debug">' : () ),
    (
      ( ( $html || $xml ) and !$file ) ? ()
      : (
        $config{'log_datetime'} eq '0' ? () : human( 'date_time', ),
        ( $config{'log_micro'} ? human('micro_time') : () ),
        ( $config{'log_pid'}   ? (" [$$]")           : () ),
      )
    ), (
      $config{'log_caller'}
      ? (
        ' [', join( ',', grep { $_ and !/^ps/ } ( map { ( caller($_) )[ 2 .. 3 ] } ( 0 .. $config{'log_caller'} - 1 ) ) ), ']'
        )
      : ()
    ),
    $delim,
    join( $delim, @_ ),
    (),
    ( $html ? '</div>'      : () ),
    ( $xml  ? ']]></debug>' : () ),
    ("\n")
  );
#print "[devlog][fac:$_[0]=".$config{ 'log_' . $_[0]}."][file=$file][log_screen=$config{'log_screen'} log_default=$config{'log_default'} noscreen=$noscreen html=$html xml=$xml]\n" ;
  file_append( $config{'log_dir'} . $file, @string );
  file_append() if !$config{'log_cache'};
  #if ( @_ and $file and open( LOG, '>>', $config{'log_dir'}.$file ) ) {
  #print LOG@string;
  #close(LOG);
  #}
  print @string if @_ and $config{'log_screen'} and !$noscreen;
  #state(@_);
  flush() if $config{'log_flush'};
  return @_;
}

sub file_read ($) {
  open my $f, '<', $_[0] or return;
  #print "slurp[$_[0]]";
  local $/ = undef;
  my $ret = <$f>;
  close $f;
  #print "=[$ret]";
  return $ret;
}

sub openproc($) {
  my ($proc) = @_;
  printlog( 'dbg', 'run ext:', $proc );
  my $handle;
  return $handle if open( $handle, $proc );
  return 0;
}

sub printprog($;$$) {    #v1
  my ( $proc, $nologbody, $handler ) = @_;
  return unless $proc;
  my $ret;
  my $tim = timer();
  printlog( 'dbg', "Starting [$proc]:" );
  system($proc), return if $nologbody;
  my $h = openproc("$proc $config{'stderr_redirect'}|") or return $ret = 1;
  while (<$h>) {
    s/\s*[\x0A\x0D]*$//;
    next unless $_;
    printlog( 'dbg', $_ );
    $ret = 2, last if $handler and $handler->($_);
  }
  close($h);
  printlog( 'dbg', 'prog done per', human( 'time_period', $tim->() ) );
  return $ret;
}

sub start(;$@) {
  my ($cmd) = shift;
  if ($cmd) {
    #$processor{'out'}{'array'}->();
    if ( $^O =~ /^(?:(ms)?(dos|win(32|nt)?))/i and $^O !~ /^cygwin/i ) {
      $config{'starter'}      ||= 'cmd /c';
      $config{'spawn_prefix'} ||= 'start /min /low';
    } else {
      $config{'spawn_postfix'} ||= '&';
    }
#"$config{'starter'} $config{'spawn_prefix'} $config{'perl'} $config{'root_path'}crawler.pl $force $start $config{'spawn_postfix'}";
    my $com = join ' ', $config{'starter'}, $config{'spawn_prefix'}, $cmd, @_, $config{'spawn_postfix'};
    printlog( 'dbg', "starting with $cmd:", $com );
    #printlog( 'dbg', $com );
    return system($com);
  }
}

sub startme(;$@) {
  my ($start) = shift;
  if ($start) {

=old
  my ($start) = shift;
  if ($start) {
    #$processor{'out'}{'array'}->();
    if ( $^O =~ /^(?:(ms)?(dos|win(32|nt)?))/i and $^O !~ /^cygwin/i ) {
      $config{'starter'}      ||= 'cmd /c';
      $config{'spawn_prefix'} ||= 'start /min /low';
    } else {
      $config{'spawn_postfix'} ||= '&';
    }
    my $com =
#"$config{'starter'} $config{'spawn_prefix'} $config{'perl'} $config{'root_path'}crawler.pl $force $start $config{'spawn_postfix'}";
      join ' ', $config{'starter'}, $config{'spawn_prefix'}, $^X, $work{'$0'} || $0, $start, @_, $config{'spawn_postfix'};
    printlog( 'dbg', "starting with $start:", $com );
    #printlog( 'dbg', $com );
    system($com);
  }
=cut

    return start( $^X, $work{'$0'} || $0, $start, @_ );
  }
}

sub state {
  $work{'$0'} ||= $0;
  $0 = $config{'state_prefix'} . join ' ', @_;
}

sub hconfig($;@) {
  my $par = shift;
  #printlog('hc0', $par,@_);
  #printlog('hc1', $_, $par),
  return $config{'fine'}{$_}{$par} for grep { defined( $config{'fine'}{$_}{$par} ) } @_;
  #printlog('hc2', $par),
  return $config{$par};
}

sub html_chars($) {
  #local $_ = $_[0];
  local $_;    # = $_[0];
  $_ = \$_[0] unless ref $_[0];
  $_ ||= $_[0];
  #print "REf:",ref $_, $$_;
  $$_ =~ s/\&/\&amp\;/g;
  $$_ =~ s/\</\&lt\;/g;
  $$_ =~ s/\>/\&gt\;/g;
  $$_ =~ s/"/\&quot\;/g;
  return $$_;
}

sub human($;@) {
  #print "HUM", @_;
  my $via = shift;
  #print "CO[$config{'human'}{$via}]", Dumper $config{'human'};
  #my $code = $config{'human'}{$via} if ref $config{'human'}{$via} eq 'CODE';
  #$code ||= $config{'human'}{$via} if ref $config{'human'}{$via} eq 'CODE';
  #return $code->(@_) if $code;
  return $config{'human'}{$via}->(@_) if ref $config{'human'}{$via} eq 'CODE';
  return @_;
}

sub func_cache($;@) {
  my ($func) = shift;
  my $save = $func . join( ':', @_ );
  unless ( $static{'func_cache'}{$save} ) { @{ $static{'func_cache'}{$save} } = $func->(@_); }
  else                                    { }
  return wantarray ? @{ $static{'func_cache'}{$save} } : $static{'func_cache'}{$save}[0];
}

sub name_to_ip_noc($) {
  my ($name) = @_;
  unless ( $name =~ /^\d+\.\d+\.\d+\.\d+$/ ) {
    local $_ = ( gethostbyname($name) )[4];
    return ( $name, 1 ) unless length($_) == 4;
    $name = inet_ntoa($_);
  }
  return $name;
}

sub ip_to_name_noc($) {    #v1
  local $_;
  return $_[0] unless $_ = ( gethostbyname( $_[0] ) )[4];
  return inet_ntoa($_);
}
sub normalize_ip($) { return func_cache( \&normalize_ip_noc, @_ ); }
sub ip_to_name($)   { return func_cache( \&ip_to_name_noc,   @_ ); }
sub name_to_ip($)   { return func_cache( \&name_to_ip_noc,   @_ ); }

sub normalize_ip_noc($) {    #v2
  my ($ip) = @_;
  return lc $ip
    if $config{'norm_skip_host'}
      and
      ( ( ref $config{'norm_skip_host'} eq 'Regexp' ? $ip =~ $config{'norm_skip_host'} : $ip =~ /$config{'norm_skip_host'}/i )
      );
  my ($err);
  ( $ip, $err ) = name_to_ip($ip);
  return $ip if $err;
  my ( $tmp, $host );
  return $ip unless $tmp = inet_aton($ip);
  return $ip unless $host = ( gethostbyaddr( $tmp, AF_INET ) )[0];

  for my $repl ( @{ $config{'ip_normalize_pre'} } ) {
    last if $host =~ /^$repl\./;
    my $thost = $host;
    $thost =~ s/^[^.]+/$repl/;
    my $pip = inet_aton($ip);
    for $thost ( ( $host =~ /\..+\./ ? ($thost) : () ), $repl . '.' . $host ) {
      next unless @_ = grep $_, ( ( gethostbyname($thost) )[ 4 .. 14 ] );
      return $thost for ( grep $_ eq $pip, @_ );
    }
  }
  return $ip unless @_ = ( gethostbyname($host) )[4];
  return $host for grep $_ eq $ip, map $_ = inet_ntoa($_), @_;
  return $ip;
}

sub counter($;$) {
  my $start = $_[0];
  return sub {
    $start = $_[1] if $_[1];
    return ( $_[0] - $start ) >= 0 ? ( $_[0] - $start ) : $start;
  };
}

sub timer(;$) {
  my ( $start, $ret ) = ( $_[0] || time() );
  return sub {
    $ret = time() - $start;
    $start = ( $_[0] or time() ) if defined( $_[0] );
    return $ret;
  };
}

sub join_url($) {    #v2
  return
      ( $_[0]->{'prot'} ? $_[0]->{'prot'} . '://' : '' )
    . ( $_[0]->{'user'} ? $_[0]->{'user'} . ( $_[0]->{'pass'} ? ':' . $_[0]->{'pass'} : '' ) . '@' : '' )
    . $_[0]->{'host'}
    . ( (
      $_[0]->{'port'}
        and ( !$static{'port2prot'}{ $_[0]->{'port'} } or ( $static{'port2prot'}{ $_[0]->{'port'} } ne $_[0]->{'prot'} ) )
    )
    ? ':'
      . $_[0]->{'port'}
    : ''
    )
    . ( $_[0]->{'dcuser'} ? '/' . $_[0]->{'dcuser'} : '' )
    . ( ( !$_[0]->{'path'} or $_[0]->{'path'} =~ /^\// ) ? '' : '/' )
    . $_[0]->{'path'}
    . ( ( ( !$_[0]->{'path'} and ( !$_[0]->{'host'} or !( $_[0]->{'name'} or $_[0]->{'ext'} ) ) ) or $_[0]->{'path'} =~ /\/$/ )
    ? ''
    : '/' )
    . $_[0]->{'name'}
    . ( $_[0]->{'ext'}   ? '.' . $_[0]->{'ext'}   : '' )
    . ( $_[0]->{'param'} ? '?' . $_[0]->{'param'} : '' )
    . ( $_[0]->{'pos'}   ? '#' . $_[0]->{'pos'}   : '' );
}
#[[prot://][user[:pass]@]host[:port][/dcuser][/[path]][/[name[.ext]]][?param][#pos]
sub split_url($;$) {    #v3
  my $table = ( $_[1] or $config{'sql_tresource'} );
  local %_ = ();
  ( $_{'prot'}, $_{'host'} ) = $_[0]      =~ m|^\s*(?:(\w+)\://)?(.*)$|;
  ( $_{'host'}, $_{'path'} ) = $_{'host'} =~ m|^([^/]*)(/.*)?$|;
  ( $_{'user'}, $_{'host'} ) = $_{'host'} =~ m|^(?:(.+)@)?(.*)|;
  ( $_{'user'}, $_{'pass'} ) = $_{'user'} =~ m|^([^/:@]+):?(.*)|;
  ( $_{'host'}, $_{'port'} ) = $_{'host'} =~ m|([^/:@]+)\:?(\d*)$|;
  $_{'path'} =~ s|([^/]*)$||;
  ( $_{'name'} ) = $1;
  $_{'path'} =~ s|/*$|| if $_{'path'} ne '/';
  $_{'path'} ||= '/' if $_{'name'} or $_{'ext'};
  #( $_{'pos'} ) = ( $_{'name'} =~ s/#(.+)$// ? ($1) : (undef) );
  ( $_{'pos'} )   = $1 if $_{'name'} =~ s/#(.+)$//;
  ( $_{'param'} ) = $1 if $_{'name'} =~ s/\?(.+)$//;
  ( $_{'ext'} ) = ( $_{'name'} =~ s/\.([^\.]+)$// ? ($1) : ('') );
  delete $_{'port'}
    unless ( $_{'port'} and ( !$static{'port2prot'}{ $_{'port'} } or ( $static{'port2prot'}{ $_{'port'} } ne $_{'prot'} ) ) );
  if ( $_{'prot'} eq 'dchub' ) {
    #printlog   ('split_url', 1, join ':', %_);
    my $dcuser;
    ( $_{'path'} =~ s|^(/[^/]+)|| and $dcuser = $1 )
      or ($_{'path'} =~ s|^/?$||
      and $_{'name'} =~ s|(.+)||
      and $dcuser = $1
      and $_{'ext'} =~ s|(.*)||
      and $dcuser .= ( $1 ? ".$1" : '' ) );
    #printlog   ('split_url', 2, join ':', %_);
    if ( %{ $config{'sql'}{'table'}{$table}{'dcuser'} or {} } ) { $_{'dcuser'} = $dcuser; }
    else {
      ( $_{'host'} = join_url( { 'host' => $_{'host'}, 'port' => $_{'port'}, 'path' => $dcuser, } ) ) =~ s|/$||;
      delete $_{'port'};
      #printlog   ('split_url', 3, join ':', %_);
    }
  }
  delete $_{$_} for grep !length $_{$_}, keys %_;
  #printlog   ('split_url', 'R', join ':', %_);
  return wantarray ? %_ : \%_;
}

sub full_host($;$) {
  my $table = ( $_[1] or $config{'sql_tresource'} );
  return join_url( {
      ( %{ $config{'sql'}{'table'}{$table}{'user'} or {} } ? () : ( 'user' => $_[0]->{'user'} ) ),
      ( %{ $config{'sql'}{'table'}{$table}{'pass'} or {} } ? () : ( 'pass' => $_[0]->{'pass'} ) ),
      'host' => $_[0]->{'host'}, ( ( (
            $_[0]->{'port'}
              and ( !$static{'port2prot'}{ $_[0]->{'port'} } or ( $static{'port2prot'}{ $_[0]->{'port'} } ne $_[0]->{'prot'} ) )
          )
            and ( !%{ $config{'sql'}{'table'}{$table}{'port'} or {} } or ( $_[0]->{'prot'} eq 'dchub' ) )
        ) ? ( 'port' => $_[0]->{'port'} ) : ()
      ),
      ( %{ $config{'sql'}{'table'}{$table}{'dcuser'} or {} } ? () : ( 'dcuser' => $_[0]->{'dcuser'} ) ),
    }
  );
}
sub cp_normalize($) { return $config{'trans_name'}{ lc $_[0] } || lc $_[0]; }

sub cp_trans($$$) {    #v1
  my ( $cfrom, $cto, $string ) = @_;
  $cfrom = cp_normalize($cfrom);
  $cto   = cp_normalize($cto);
  #printlog('dev', 'cp_trans:', $cfrom, $cto, $string);
  return $string if $cto eq $cfrom or !length($string) or !$cfrom or !$cto;
  #print('dev', 'cp_trans:', join ':',$cfrom, $cto, $string);
  #local $_ = "$cfrom -> $cto";
  #caller_trace();
  #return scalar cp_trans_count(@_); # unless $config{'fast_cp_trans'};
  #use Encode;
  #$string = encode($cto, decode($cfrom, $string));
  return Encode::encode( $cto, Encode::decode( $cfrom, $string ) );
}

sub cp_trans_count($$$) {    #v1
  my ( $cfrom, $cto, $string ) = @_;
  $cfrom = cp_normalize($cfrom);
  $cto   = cp_normalize($cto);
  #printlog('dev', 'cp_trans:', $cfrom, $cto, $string);
  return $string if $cto eq $cfrom or !length($string) or !$cfrom or !$cto;
  #print('dev', 'cp_trans:', join ':',$cfrom, $cto, $string);
  #local $_ = "$cfrom -> $cto";
  #caller_trace();
  #use Encode;
  #$string = encode($cto, decode($cfrom, $string));
  #return encode($cto, decode($cfrom, $string));
  return utf_trans( $cto, $string ) if $cfrom eq 'utf-8' and $config{'trans'}{$cto};
  return to_utf_trans( $cfrom, $string ) if $cto eq 'utf-8' and $config{'trans'}{$cfrom};
  my $cnt;
  if ( $config{'trans'}{$cfrom} and $config{'trans'}{$cto} ) {
    ( $cfrom, $cto ) = \( $config{'trans'}{$cfrom}, $config{'trans'}{$cto} );
    eval "\$cnt = \$string =~ tr/$$cfrom/$$cto/";
  }
  #printlog('dev', "cp_trans($_):", $string),     caller_trace()     if $cnt;
  return wantarray ? ( $string, $cnt ) : $string;
}

sub utf_trans($$) {
  my ( $cto, $string ) = @_;
  $cto ||= $config{'cp_db'};
  $cto = cp_normalize($cto);
  return if $cto eq 'utf-8';
  my ( $cnt, $cnt2 );
  $cnt += $string =~ s/\xD0\x81/\xF0/g;     # e
  $cnt += $string =~ s/\xD1\x91/\xF1/g;     # E
  $cnt += $string =~ s/\xD0\x84/\xF4/g;     # ukr beg
  $cnt += $string =~ s/\xD1\x94/\xF5/g;
  $cnt += $string =~ s/\xD0\x86/\xF6/g;
  $cnt += $string =~ s/\xD1\x96/\xF7/g;
  $cnt += $string =~ s/\xD0\x87/\xF8/g;
  $cnt += $string =~ s/\xD1\x97/\xF9/g;     # ukr end
  $cnt += $string =~ s/\xE2\x80\x94/-/g;    # -
  $cnt += $string =~ s/\xC2\xAB/"/g;        # ´
  $cnt += $string =~ s/\xC2\xBB/"/g;        # ª
  $cnt += $string =~ s/\xD1\x98/j/g;        #
  $cnt += $string =~ s/\xD0\xB9/\xA9/g;     # È
  #$cnt += $string =~ s/\xD0\xA9/\xC9/g;                           # Ÿ
  $cnt += $string =~ s/\xD0([\x90-\xBF])/chr(ord($1)-16)/eg;
  $cnt += $string =~ s/\xD1([\x80-\x8F])/chr(ord($1)+96)/eg;
  ( $string, $cnt2 ) = cp_trans_count( 'cp866', $cto, $string );
  $cnt += $cnt2;
  $cnt += $string =~ s/\x21\x16/\xB9/g;     # È
  return wantarray ? ( $string, $cnt ) : $string;
}

sub to_utf_trans($$) {
  my ( $cfrom, $string ) = @_;
  $cfrom ||= $config{'cp_db'};
  $cfrom = cp_normalize($cfrom);
  return if $cfrom eq 'utf-8';
  my $cnt;
  #$cnt += $string =~ s/\xE9/\xD0\xB9/g;                           # È
  $cnt += $string =~ s/\xAB/"/g;            # <
  $cnt += $string =~ s/\xBB/"/g;            # <
  #print "\ndos0[$string]\n";
  ( $string, $cnt ) = cp_trans_count( $cfrom, 'cp866', $string );
  #print "\ndos1[$string]\n";
  $cnt += $string =~ s/([\x80-\x88\x8A-\xA8\xAA-\xAF])/"\xD0".chr(ord($1)+16)/eg;
  $cnt += $string =~ s/([\xE0-\xE8\xEA-\xEF])/"\xD1".chr(ord($1)-96)/eg;
  #print "\ndos2[$string]\n";
  $cnt += $string =~ s/\xF0/\xD0\x81/g;     # e
  $cnt += $string =~ s/\xF1/\xD1\x91/g;     # E
  $cnt += $string =~ s/\xF4/\xD0\x84/g;     # ukr beg
  $cnt += $string =~ s/\xF5/\xD1\x94/g;
  $cnt += $string =~ s/\xF6/\xD0\x86/g;
  $cnt += $string =~ s/\xF7/\xD1\x96/g;
  $cnt += $string =~ s/\xF8/\xD0\x87/g;
  $cnt += $string =~ s/\xF9/\xD1\x97/g;     # ukr end
  #=c
  $cnt += $string =~ s/(?<!\xD0)\xB9/\x21\x16/g;    # π
  $cnt += $string =~ s/(?<!\xD0)\xA9/\xD0\xB9/g;    # È
  $cnt += $string =~ s/(?<!\xD0)\x89/\xD0\x99/g;    # …
  $cnt += $string =~ s/(?<!\xD0)\xE9/\xD1\x89/g;    # ˘
  $cnt += $string =~ s/(?<!\xD0)\x99/\xD0\xA9/g;    # Ÿ
  #=cut
  #$cnt += $string =~ s/\xAB/"/g;                           # <
  #$cnt += $string =~ s/\xBB/"/g;                           # >
  return wantarray ? ( $string, $cnt ) : $string;
}

sub cp_trans_hash($$$) {
  my ( $from, $to, $hash ) = @_;
  #printlog('dev', 'cp_trans_hash:', $from, $to, Dumper $hash);
  return $hash if $from eq $to;
  $hash->{$_} = cp_trans( $from, $to, $hash->{$_} ) for keys %$hash;
  return wantarray ? %$hash : $hash;
}

sub max_hash_el($$;$) {
  my ( $hash, $max, $ret ) = @_;
  $hash->{$_} >= $max ? ( $max = $hash->{$_}, $ret = $_ ) : () for grep $_, keys %$hash;
  return $ret;
}

sub cp_dump($) {
  my ($data) = @_;
  printlog( 'devcp', "$_ = $data->{'stat'}{$_}" ) for keys %{ $data->{'stat'} };
}

sub detectcp($) {
  my ($string) = @_;
  my ( $detectedcp, $t );
  my %cpstat;
  for my $cp ( keys %{ $config{'trans_detect'} } ) {
    ( length($$string) > $config{'cp_detect_length'} ? substr( $$string, 0, $config{'cp_detect_length'} ) : $$string ) =~
      s/([$config{'trans_detect'}{$cp}])/++$cpstat{$cp},$1/eg;
    #$$string
  }
  $detectedcp = max_hash_el( \%cpstat, $config{'cp_detect_letters'} );
  return wantarray ? ( $detectedcp, \%cpstat ) : $detectedcp;
}

sub cp_detect_trans($$$;$$$) {
  my ( $string, $data, $cp_to, $cp_default, $prot, $host ) = @_;
  $cp_default = cp_normalize( $cp_default || hconfig( 'cp_res', $host, $prot ) );
  $cp_to = cp_normalize( $cp_to || hconfig( 'cp_db', $host ) );
  my $cnt;
  if ( !hconfig( 'no_cp_detect', $host ) and ( ++$data->{'tries'} < 20 or !$data->{'cp'} ) ) {
    $data->{'stat'}{ detectcp($string) }++;
    $data->{'cp'} = max_hash_el( $data->{'stat'}, hconfig( 'cp_detect_strings', $host ) );
#printlog( 'dbg', 'charset detected:', $data->{'cp'}, '   dbg: ', %{ $data->{'stat'} }, Dumper($data), Dumper(detectcp($string)),
#' [', $$string, ']'
#)      if $data->{'cp'} and $data->{'cp'} ne $cp_default;
  }
  if ( $data->{'cp'} and $data->{'cp'} ne $cp_to ) {
    ( $$string, $cnt ) = cp_trans_count( $data->{'cp'}, $cp_to, $$string );
    return $cnt ? $data->{'cp'} : undef;
  }
  if ( $cp_default and $cp_default ne $cp_to ) {
    ( $$string, $cnt ) = cp_trans_count( $cp_default, $cp_to, $$string );
    return $cnt ? $cp_default : undef;
  }
  return undef;
}

sub cp_up($;$) {    #v1
  my ( $string, $cp ) = ( shift, cp_normalize( shift || 'cp1251' ) );
  eval "\$string =~ tr/$config{'trans_lo'}{$cp}/$config{'trans_up'}{$cp}/"
    if ( $config{'trans_up'}{$cp} and $config{'trans_lo'}{$cp} );
  return $string;
}

sub cp_lo($;$) {    #v1
  my ( $string, $cp ) = ( shift, cp_normalize( shift || 'cp1251' ) );
  eval "\$string =~ tr/$config{'trans_up'}{$cp}/$config{'trans_lo'}{$cp}/"
    if ( $config{'trans_up'}{$cp} and $config{'trans_lo'}{$cp} );
  return $string;
}

sub lang($;$$$) {
  my ( $key, $lang ) = shift, shift;
  #print "CP[$config{'cp_config'},$work{'codepage'}]" if $key eq 'search';
  return
    #"[".(%config)."]".
    shift() .       # "CP[$config{'cp_config'},$work{'codepage'}]".
    cp_trans(
    ( $config{'cp_config'} || $config{'cp_perl'} ),
    $work{'codepage'}, (
        defined $config{'lng'}{ $lang ||= ( $work{'lang'} || $config{'lang'} ) }{$key} ? $config{'lng'}{$lang}{$key}
      : defined $config{'lng'}{''}{$key} ? $config{'lng'}{''}{$key}
      : $key
    )
    ) . shift;
}

sub min (@) {
  ( sort { $a <=> $b || $a cmp $b } @_ )[0];
}

sub max (@) {
  ( sort { $b <=> $a || $b cmp $a } @_ )[0];
}

sub alarmed {
  my ( $timeout, $proc, @proc_param ) = @_;
  my $ret;
  eval {
    local $SIG{ALRM} = sub { die "alarm\n" }
      if $timeout;    # NB: \n required
    alarm $timeout if $timeout;
    $ret = $proc->(@proc_param) if ref $proc eq 'CODE';
    alarm 0 if $timeout;
  };
  if ( $timeout and $@ ) {
    printlog( 'err', 'Sorry, unknown error (',
      $@, ') runs:', ' [', join( ',', grep $_, map ( ( caller($_) )[2], ( 0 .. 15 ) ) ), ']' ),
      sleeper( 3600, 'alarmed' ), return
      unless $@ eq "alarm\n";    # propagate unexpected errors
    printlog( 'err', 'Sorry, timeout (', $timeout, ')' );
  } else {
    sleeper( undef, 'alarmed' );
  }    #    else { print "no timeout<br/>"; }
  return $ret;
}

sub mkdir_rec($;$) {
  #mkdir $` while m,/,g;
  my ( $name, $mask ) = @_;
  my $ret;
  $name =~ s|/+\s*$||;
  $name =~ s|\\|/|g;
  local @_ = ($name);
  push( @_, $name ) while $name =~ s|^(.+)/([^/]+)$|$1|;
  #$ret += mkdir( $_, $mask ? $mask : () ) for grep { !-d } reverse @_;
  $ret += ( $mask ? mkdir $_, $mask : mkdir $_ ) for grep { !-d } reverse @_;
  return $ret;
}

sub check_int($;$$$) {
  my ( $int, $min, $max, $def ) = @_;
  #printlog('dev', 'int', ( "int=$int,min=$min,max=$max,def=$def" ));
  $def = 0 unless defined $def;
  return $def unless ( defined($int) and length($int) );
  #printlog('dev', "int0[$int]", defined $int, length($int));
  $int =~ s/\s+//g;
  $int = int($int);
  #printlog('dev', 'int1',$int);
  return $def unless $int =~ /^-?\d+$/;
  #printlog('dev', 'int2',$int, $min);
  return $min if defined $min and $int < $min;
  #printlog('dev', 'int3',$int, $max);
  return $max if defined $max and $int > $max;
  #printlog('dev', 'int4',$int);
  return $int;
}
{
  my $current_name;

  sub open_out_file {
    my ($name) = join( '.', grep ( /.+/, @_ ) );
    $name =~ s/\W+/_/g;
    close_out_file();
    $current_name = "$config{'datadir'}$config{'slash_sys'}$name.$config{'output'}";
    $work{'current_name_work'} = "$current_name$config{'work_ext'}";
    rename( $current_name, $work{'current_name_work'} ) if -e $current_name and $work{'current_name_work'} and $current_name;
    open( I, '>>', $work{'current_name_work'} )
      or printlog( 'err', "!!! UNABLE TO OPEN $work{'current_name_work'}" )
      and return;
  }

  sub close_out_file {
    if ( $work{'current_name_work'} ) {
      $processor{'out'}{'array'}->();
      print I";\n";
      close(I);
      rename( $work{'current_name_work'}, $current_name ) if $work{'current_name_work'} and $current_name;
    }
    $work{'current_name_work'} = $current_name = '';
  }
}
sub caller_trace(;$) { printlog( 'caller', $_, caller($_) || last ) for 0 .. $_[0] || 5 }

sub lib_init() {
  $SIG{__WARN__} = sub {
    printlog( 'warn', $!, $@, @_ );
    #printlog( 'die', 'caller', $_, caller($_) ) for ( 0 .. 15 );
    caller_trace(15);
    }, $SIG{__DIE__} = sub {
    printlog( 'die', $!, $@, @_ );
    printlog( 'die', 'caller', $_, caller($_) || last ) for ( 0 .. 15 );
    #caller_trace(15);
    }
    unless $static{'no_sig_log'};    #die $!;
  unless ( $static{'port2prot'} ) {
    @{ $static{'port2prot'} }{ ( $config{'scanner'}{$_}{'port'}, $_ ) } = ( $_, $_ ) for keys %{ $config{'scanner'} };
  }
}

sub mysleep($) {
  if ( $_[0] > 1 and $config{'system'} eq 'win' ) {    #activeperl only?
    sleep(1) for ( 0 .. $_[0] );
  } else {
    sleep( $_[0] );
  }
}

sub sleeper($;$$) {
  my ( $max, $where, $min, ) = @_;
  $where ||= join '', caller;
  ( $work{'sleeper'}{$where} ? printlog( 'dev', "sleeper: clean $where was $work{'sleeper'}{$where}" ) : () ),
    $work{'sleeper'}{$where} = 0, return 0
    if !$max
      or $ENV{'SERVER_PORT'};
  $min ||= 0.5;
  #printlog( 'dbg', "sleepe0: sleep $where $work{'sleeper'}{$where} mi=$min" );
  ( $work{'sleeper'}{$where} ||= $min ) *= ( $work{'sleeper'}{$where} > $max ? 1 : 2 );
  printlog( 'dbg', "sleeper: sleep $where $work{'sleeper'}{$where}" );
  mysleep( $work{'sleeper'}{$where} );
  return $work{'sleeper'}{$where};
}

sub shuffle(@) { #@$deck = map{ splice @$deck, rand(@$deck),  1 }  0..$#$deck;
  my $deck = shift;
  $deck = [ $deck, @_ ] unless ref $deck eq 'ARRAY';
  my $i = @$deck;
  while ( $i-- ) {
    my $j = int rand( $i + 1 );
    @$deck[ $i, $j ] = @$deck[ $j, $i ];
  }
  return wantarray ? @$deck : $deck;
}

sub flush(;$) {
  #printlog('dev', 'FLUSH') ;
  return if $config{'no_flush'};
  select( ( select( $_[0] || *STDOUT ), $| = 1 )[0] );
}

=todo
sub paintdots_onreload {
  my ($ref) = shift;
  sub {
    if ( $_[0] =~ /[Ss]ubroutine (\w+) redefined/ ) {
      my ($subr) = $1;
      ++$$ref;
      local ($|) = 1;
#$CPAN::Frontend->myprint(".($subr)");
#$CPAN::Frontend->myprint(".");
      print(".");
      return;
    }
    warn @_;
  };
}
=cut

sub config_read {
  #print "config_read($ENV{'SCRIPT_FILENAME'}, $_[0]);\n";
  #print ("config_read NOREAD!;\n");
  my $file = $config{'config_file'} || 'config.pl';
  return if $static{'config_read'}{
        $ENV{'SCRIPT_FILENAME'} . $file
          #$ENV{'PROSEARCH_PATH'}
      }++ and !$_[0];
  #print " [$file] config_read($_[0])";
  #do $ENV{'PROSEARCH_PATH'} . './config.pl' or do '../config.pl';
  #print "config_readb(); root_path = $root_path\n";
  ( $ENV{'SCRIPT_FILENAME'} || $work{'$0'} || $0 ) =~ m|^(.+)[/\\].+?$|;
  $root_path ||=    #$ENV{'PROSEARCH_PATH'} ||
    ( $1 ? $1 . '/' : undef );
  #$root_path||=  $1 . '/' if $1;
  $root_path =~ s|\\|/|g;
  #do $ENV{'PROSEARCH_PATH'} . './config.pl' or
  #print "pa=". ( $ENV{'SCRIPT_FILENAME'} ,';', $0),"\n";
  #print "config_read(); root_path = $root_path ; file = $file\n";
  my @errs;
  local $_ = do $root_path . $file;
  #print( ' do1:',$_,',', $!, ' eval=', $@, "\n" ) if !$_ or $! or $@;
  #MAKE ARRAY
  push @errs, grep { $_ } $!, $@, $_ += do $root_path . 'confdef.pl',   push @errs, grep { $_ } $!, $@ unless $_;
  push @errs, grep { $_ } $!, $@, $_ += do $root_path . '../config.pl', push @errs, grep { $_ } $!, $@ unless $_;
  if ( !$_ and !$_[1] ) {
    print "Content-type: text/html\n\n" if defined( $ENV{'SERVER_PORT'} );
    print "config not found in $root_path$file and ../config.pl\nReason:\n", join ";\n", @errs;
  }
  #print"rp set1 to [$root_path]\n";
  conf(
    sub {
      #print"rp set2 to [$root_path]\n";
      $config{'root_path'} = $root_path;
    },
    0.0001
  );
  #print( ' do2:',$_,',', $!, ' eval=', $@, "\n" ) if $! or $@;
  #print( ' do1:', $!, 'eval=', $@ ,"\n" ) if $! or $@;
  #print( 'compile err1:', $!, "\n" ) if $!;
  #print ('compile err2:',$@, "\n");
  #require $ENV{'PROSEARCH_PATH'} . './config.pl' or do '../config.pl';
  #print('config_read',Dumper (\%config ));
  #print('config_read',(scalar keys %config ));
}

sub pre_calc_every {
  $config{'post_init_every'}{$_}->(@_)
    for grep { ref $config{'post_init_every'}{$_} eq 'CODE' } sort keys %{ $config{'post_init_every'} || {} };
}

sub pre_calc_once {
  #$config{'post_init_once'}->(@_) if $config{'post_init_once'};
  #print "pre_calc_once\n";
  $config{'post_init_once'}{$_}->(@_)
    for grep { ref $config{'post_init_once'}{$_} eq 'CODE' } sort keys %{ $config{'post_init_once'} || {} };
}

sub pre_calc {
  pre_calc_once(@_);
  pre_calc_every(@_);
}

sub config_reload {
  #print "config_reload(clear=$_[0];; $config{'root_path'})";
  #print "config_reload(clear!=$_[0])\n";
  %config = () if $_[0];
  config_read( $_[1], $_[3] );
  #print "read end;";
  $_[2]->() if ref $_[2] eq 'CODE';
  conf();
  #print ('compile err2:',$@, "\n");
  if ( !%config ) {
    print "Content-type: text/html\n\n" if defined( $ENV{'SERVER_PORT'} );
    print("Please fix error in config.pl: [$@]"), exit if $@;
    print "Please create config.pl with parametrs (see config.pl.dist) and correct modes [$!]";
    exit;
  }
  #print('config_reload',(scalar keys %config ));
  #print('config_reload',Dumper (\%config ));
}
sub configure { &config_reload; }
sub config    { &configure; }       #to del

sub reload_lib {
  %human = ();
  my $redef = 0;
  for my $file (@_) {
    printlog( 'dbg', "reloading $file: $INC{$file}" );
    open( my $fh, '<', ( $INC{$file} or $file ) ) or printlog( 'err', "reload err $file=$INC{$file}" ), next;
    local ($/);
    local ( $SIG{__WARN__} ) = paintdots_onreload( \$redef );
    local ( $SIG{__DIE__} )  = paintdots_onreload( \$redef );
    eval <$fh>;
    warn $@ if $@;
  }
}

sub conf(;$$) {
  my ( $sub, $order ) = ( shift, shift );
  #if ( !$ENV{'MOD_PERL'} ) {    $sub->(@_) if $sub;    return;  }
  my $id = $ENV{'SCRIPT_FILENAME'} || $work{'$0'} || $0;
  #print join ' ',('dev',"conf($sub, $order, [$root_path] id=$id)", caller,"<br\n/>");
  unless ($sub) {
#print("running", scalar keys %{ $static{'conf_init'}{ $ENV{'PROSEARCH_PATH'} } }, "now=",scalar keys %config, "\n");
#print("RUNCONF[$id]($_/",scalar keys %{ $static{'conf_init'}{$id } },"] from(",join('|',@{$static{'conf_init_from'}{$id}{$_}}), ";", "<br\n/>"),
    $static{'conf_init'}{
      #$ENV{'PROSEARCH_PATH'}
      #$ENV{'SCRIPT_FILENAME'}
      $id
      }{$_}->() for sort { $a <=> $b } keys %{
      $static{'conf_init'}{
        #$ENV{'PROSEARCH_PATH'}
        #$ENV{'SCRIPT_FILENAME'}
        $id
        }
      };
    #print("confrunned",  "now=",scalar keys %config, "\n");
    return;
  }
  local $_;
  $static{'conf_init'}{
    #$ENV{'SCRIPT_FILENAME'}
    #$ENV{'PROSEARCH_PATH'}
    $id
    }{
    $_ = (
      $order or $static{'conf_count'}{
        #$ENV{'PROSEARCH_PATH'}
        #$ENV{'SCRIPT_FILENAME'}
        $id
        }
        += 10
    )
    }
    = $sub;
  $static{'conf_init_from'}{
    #$ENV{'SCRIPT_FILENAME'}
    $id
    }{$_} = [caller];
  #print "conf(@_):", Dumper([caller],$static{'conf_init'}, $static{'conf_init_from'});
}

sub http_get {    # REWRITE easier
  my ( $what, $asfile, $lwpopt, $method, $content, $headers_out, $headers_in ) = @_;
  #return "ZZZZZ";
  #printlog( 'dev', 'http_get', $what, $asfile, "cd=$config{'cachedir'};c=$config{'cache_http'}; " );
  my %url = split_url($what);
  my $c = encode_url( $what, $config{'encode_url_file_mask'} );
  if ( length $c > 200 ) {
    my ( $bef, $mid, $aft ) = $c =~ /^(.{50})(.+)(.{50})$/;
    #local $_ = 0;
    my $midv = 0;
    $midv += ord for split //, $mid;
    $c = join '__', $bef, $midv, $aft;
    #$_ += ord;
    #}
  }
  $c = ( $config{'cachedir'} || '.' ) . '/' . $c if $config{'cachedir'};
  $c = $asfile if $asfile and $asfile != 1;
  #printlog('dev', $what, $asfile, "cache=$config{'cache_http'}, dir=$config{'cachedir'};");
  if ( $config{'cache_http'} and -e $c and -M $c < $config{'cache_http'} ) {
    return $c if $asfile;
    if ( open( CF, '<', $c ) ) {
      local $/;
      local $_ = <CF>;
      close(CF);
      return $_;
    }
  }
  printlog( 'warn', 'http_get disabled' ), return if $config{'no_http_get'};
  #printlog('dev', 'http_get',$what, $asfile);
  return eval
    #do
  {
    #printlog 'dev' ,0 ;
    eval('use LWP::UserAgent; use URI::URL;1;') or printlog( 'err', 'http use libs', @!, $! );    #if not installed
    my $ua = LWP::UserAgent->new(
      'agent' => $config{'useragent'} || $config{'crawler_name'},
      'timeout' => hconfig( 'timeout', $url{'host'}, $url{'prot'} ) || 10,
      %{ $config{'lwp'} || {} }, %{ $lwpopt || {} }
    );
    #$ua->proxy('http', 'http://proxy.ru:3128');
    if ( ref $config{'proxy'} eq 'ARRAY' ) {
      local @_ = @{ shuffle( $config{'proxy'} )->[0] };
      #printlog('proxy', @_, Dumper($config{'proxy'}));
      $ua->proxy(@_);
    } elsif ( $config{'proxy'} ) {
      $ua->proxy( 'http', $config{'proxy'} );
    }
    #printlog 'dev' ,1 , $asfile , $c;
    $ua->mirror( $what, $c ), return $c if $asfile;
    $method ||= 'GET';
    #print "RwM:$method;";
    #my $resp =( $method eq 'HEAD' ? $ua->head($what) :
    my $resp = (
      $ua->request(
        new HTTP::Request(
          $method,
          new URI::URL($what),
          new HTTP::Headers(
            #'User-Agent' => ($config{'useragent'} || $config{'crawler_name'}),
            %{ $headers_in || {} }
          ),
          $content
        )
      )
    );
    #my $ret = $headers ? \$resp->content : \$resp->asfile;
    my $ret = $headers_out ? 'as_string' : 'content';
    #printlog 'resp', Dumper $resp;
    #print "[H:",$resp->header();
    #print "[H:",$resp->code();
    if ( $resp->is_success ) {
      if ( $config{'cachedir'} ) {
        open( CF, '>', $c ) or return;
        binmode(CF);
        print CF$resp->$ret();    #content;
        #print CF $ret->(); #content;
        close(CF);
      }
      #return $asfile ? $c : ($resp->content); #{map {$_ => $resp->header($_)}$resp->header_field_names}
      #printlog('dev', 'http ret', $ret, $asfile,"NOW");
      #return "FUCCCCKKAAA";
      #return $resp->$ret();
      return ( $asfile ? $c : ( $resp->$ret() ) );    #{map {$_ => $resp->header($_)}$resp->header_field_names}
      #return $asfile ? $c : $ret->(); #{map {$_ => $resp->header($_)}$resp->header_field_names}
    } else {
      printlog( 'dev', 'http getfail', $what, $resp->code(), $resp->message() );
      #return $asfile ? undef: $resp->message;
      return undef;
    }
    1;
  } or printlog( 'err', @$, @!, $! );
  return undef;
}

sub http_get_code {
  my ( $what, $lwpopt, $method ) = @_;
  #printlog('dev', 'http_get_code',$what, $method);
  my $ret = eval {
    eval('use LWP::UserAgent; use URI::URL;1;') or printlog( 'err', 'http use libs', @!, $! );    #if not installed
    #my $ua = ;
    #$ua->proxy('http', 'http://proxy.ru:3128');
    my $resp = (
      ( LWP::UserAgent->new( 'timeout' => hconfig('timeout'), %{ $config{'lwp'} or {} }, %{ $lwpopt or {} } ) )->request(
        new HTTP::Request(
          ( $method or 'GET' ),
          new URI::URL($what),
          new HTTP::Headers( 'User-Agent' => $config{'useragent'} || $config{'crawler_name'} )
        )
      )
    );
    #print "[H:",$resp->header();
    #print 'GCR', $resp->code(), "\n";
    return $resp->code();
  } or printlog( 'err', @$, @!, $! );
  return $ret || undef;
}

sub html_strip($) {
  my $s = $_[0];
  $s =~ s{HTTP/.*?\n\n}{}gs;
  $s =~ s/<!--.*?-->//gs;
  $s =~ s{<$_.*?>.*?</$_>}{}gs for qw(script style);
  $s =~ s{</?.+?/?>}{}gs;
  return $s;
}

sub loadlist {
  my %res = ();
  for my $sca (@_) {
    next unless $sca;
    open( SSF, '<', $sca ) or next;
    while (<SSF>) {
      next if /^\s*[#;]/;
      local @_ = split /\s+/, $_;
      my $host = shift or next;
      local %_;
      get_params_one( \%_, @_ );
      $res{$host} = \%_;
    }
    close(SSF);
  }
  return wantarray ? %res : \%res;
}
sub shelldata(@) { s/[\x0d\x0a\"\'\`|><&]//g for @_; }    #`

=c
sub save_list {
 my ($file, $data) = @_;
 use Storable;
 store($data, $file);
=c
 return 1 unless open(SF, '>', $file);
 for my $str (sort keys %$data) {
    print SF join(' ', map{     encode_url($_) . (length($data->{$str}{$_}) ? ( '='. encode_url($data->{$str}{$_})) : ())} sort keys %{$data->{$str}}); 
#for my $k (sort keys %{$data->{$str}}) {
#}
   print SF "\n";
 }
 
 close(SF);
}
=cut

sub schedule($$;@) {    #$Id: psmisc.pm 4412 2010-03-15 00:13:51Z pro $ $URL: svn://svn.setun.net/search/trunk/lib/psmisc.pm $
  our %schedule;
  my ( $every, $func ) = ( shift, shift );
  my $p;
  ( $p->{'wait'}, $p->{'every'}, $p->{'runs'}, $p->{'cond'}, $p->{'id'} ) = @$every if ref $every eq 'ARRAY';
  $p = $every if ref $every eq 'HASH';
  $p->{'every'} ||= $every if !ref $every;
  $p->{'id'} ||= join ';', caller;
  $schedule{ $p->{'id'} }{'func'} = $func if !$schedule{ $p->{'id'} }{'func'} or $p->{'update'};
  $schedule{ $p->{'id'} }{'last'} = time - $p->{'every'} + $p->{'wait'} if $p->{'wait'} and !$schedule{ $p->{'id'} }{'last'};
  $schedule{ $p->{'id'} }{'func'}->(@_), $schedule{ $p->{'id'} }{'last'} = time
    if ( $schedule{ $p->{'id'} }{'last'} + $p->{'every'} < time )
    and ( !$p->{'runs'} or $schedule{ $p->{'id'} }{'runs'}++ < $p->{'runs'} )
    and ( !( ref $p->{'cond'} eq 'CODE' ) or $p->{'cond'}->( $p, $schedule{ $p->{'id'} }, @_ ) )
    and ref $schedule{ $p->{'id'} }{'func'} eq 'CODE';
}
{    #$Id: psmisc.pm 4412 2010-03-15 00:13:51Z pro $ $URL: svn://svn.setun.net/search/trunk/lib/psmisc.pm $
  my (@locks);
  sub lockfile($) {
    return ( $config{'lock_dir'} || './' ) . ( length $_[0] ? $_[0] : 'lock' ) . ( $config{'lock_ext'} || '.lock' );
  }

  sub lock (;$@) {
    my $name = shift;
    my %p = ref $_[0] eq 'HASH' ? %{ $_[0] } : @_;
    $p{'sleep'}   ||= $config{'lock_sleep'}   || 1;
    $p{'timeout'} ||= $config{'lock_timeout'} || 600 unless length $p{'timeout'};
    $p{'old'}     ||= $config{'lock_old'}     || 3600;
    #$p{'readonly'} ||= 0; #dont write lock file, only wait
    my $waitstart = time();
    my $waits;
  LOCKWAIT:
    while ( -e lockfile $name) {
#printlog( 'lockdev', 'locktime', -M lockfile $name, time() - $^T + 86400 * -M lockfile $name,       $^T + 86400 * -M lockfile $name,      86400 * -M lockfile $name,      );
      printlog( 'lock', $name, 'ignore too old', -M lockfile $name, time() - $^T + 86400 * -M lockfile $name), last
        if time() - $^T + 86400 * -M lockfile $name > $p{'old'};
      printlog( 'lock', $name, 'fail, timeout', int( time() - $waitstart ) ), return 0 if time() - $waitstart > $p{'timeout'};
      printlog( 'lock', 'locked, wait', $name ) unless $waits++;
      sleep $p{'sleep'};
    }
    printlog( 'lock', 'unlocked', $name, 'per', int( time() - $waitstart ) ) if $waits;
    return 1 if $p{'readonly'};
    local $_ = "pid=$$ time=" . int( time() );
    file_rewrite lockfile $name, $_;
    file_rewrite;    #flush
    if ( open my $f, '<', lockfile $name) {
      local $/ = undef;
      my $c = <$f>;
      close $f;
      #printlog 'test', $c;
      printlog( 'warn', 'not my lock', $_, $c ), goto LOCKWAIT if $_ ne $c;
    } else {
      printlog( 'err', 'lock open err', $name, lockfile $name);
      return 0;
    }
    push @locks, lockfile $name;
    return 1;
  }

  sub unlock (;$) {
    my $name = shift;
    local $_ = pop @locks;
    push @locks, $_ if length $name and lockfile($name) ne $_;
    #$name ||= $_;
    #printlog 'lock', 'unlocking', $name, lockfile $name;
    #unlink lockfile( $name ||= $_ );
    unlink $name ? lockfile($name) : $_;
  }

  sub unlock_all () {
    #unlink $_ for reverse @locks;
    unlink $_ while $_ = pop @locks;
  }

  END {
    printlog( 'lock', 'END locked unlock', @locks ) if @locks;
    unlock_all();
  }
  $SIG{$_} ||= sub {
    printlog( 'lock', 'SIG locked unlock', @locks ) if @locks;
    unlock_all();
    exit;
    }
    for qw(HUP INT QUIT KILL TERM);
}
{
  my ( $current, $order );

  sub program(;$$) {
    my ( $name, $setorder ) = @_;
    return $current unless $name;
    $program{ $current = $name }{'order'} ||= ( $setorder or $order += ( $config{'order_step'} || 10 ) );
    #print "newprog($current, $program{$current}{'order'});" ;
    return $current;
  }    #v2
}

sub use_try ($;@) {
  ( my $path = ( my $module = shift ) . '.pm' ) =~ s{::}{/}g;
  $INC{$path} or eval 'use ' . $module . ' qw(' . ( join ' ', @_ ) . ');1;' and $INC{$path};
}
program('params');
$program{ program() }{'force'} = 1;
$program{ program() }{'func'} ||= sub { $param = get_params(); };
program('params_pre_config');
$program{ program() }{'mask'}       ||= '^(-*c(onf)?-*)|(--).*';
$program{ program() }{'param_name'} ||= 1;
$program{ program() }{'func'}       ||= sub {
  my ( $v, $w ) = @_;
  $w =~ s/^(-*c(onf?)?-*)|(--)//i;
  $v =~ s/^NUL$//;
  return 0 unless defined($w) and defined($v);
#local @_ = split /__/, eval( '$config' . join( '', map { '{$_[' . $_ . ']}' } ( 0 .. $#_ ) ) . '= $param->{$_};' )  for ( grep { $param->{$_} } keys %$param );
  local @_ = split( /__/, $w ) or return 0;
  #print( 'dev', 'genpre',$w, $v, @_, "\n");
  #printlog( 'dev', 'gen', @_,'$config' . join( '', map { '{$_[' . $_ . ']}' } ( 0 .. $#_ ) ) . ' = $v;' );
  eval( '$config' . join( '', map { '{$_[' . $_ . ']}' } ( 0 .. $#_ ) ) . ' = $v;' );
  #for ( grep { $param->{$_} } keys %$param );
  #$config{$w} = $v if defined($w) and defined($v);
  #printlog('dev', 'res', $config{'zzz'}{'yy'});
  return 0;
};
program('config');
$program{ program() }{'force'} = 1;
$program{ program() }{'func'} ||= sub {
  #print "COOOO";
  config_reload();    #$param
  pre_calc($param);
  #config_init($param);
  return 0;
};
program('params_config');
%{ $program{ program() } } = ( %{ $program{'params_pre_config'} }, 'order' => $program{ program() }{'order'} );
program( 'help', 100000 );
$program{ program() }{'mask'} ||= '^-*he?l?p?$';
$program{ program() }{'func'} ||= sub {
  print "Usage: perl $work{'$0'} [action[=params]] [--config_key[=value]] [...] \n\n Actions:\n";
  for ( sort keys %program ) {
    next if $program{$_}{'force'} or /(_aft)|(_bef)$/;
    print "$_ $program{$_}{'desc'}\n";
  }
  print "\nConfig defaults:\n";
  for ( sort keys %config ) { print "--$_\t[$config{$_}]\n"; }
};

sub program_one($;@) {
  my $current = shift;
  return undef unless exists $program{$current};
  if ( $program{$current}{'func'} and !$program{$current}{'disabled'} ) {
    my @ret;
    printlog( 'trace', 'program run', $current, @_ );
    eval { @ret = $program{$current}{'func'}->(@_); };
    printlog( 'err', 'program', $current, 'run error:', $@ ) if $@;
    return wantarray ? @ret : $ret[0];
  }
  return undef;
}

sub program_run(;$) {
  for my $n ( 0 .. 1 ) {
    my %masks;
    for my $current ( sort keys %program ) { ++$masks{ $program{$current}{'mask'} ||= "^-?$current\\d*\$" }; }
    $program{'default'}{'notmask'} = '^-?(' . join( '|', keys %masks ) . ")\\d*\$";
    for my $current ( grep { !$program{$_}{'checked'} } sort { $program{$a}{'order'} <=> $program{$b}{'order'} } keys %program )
    {
      next if $current eq 'default' and !$n;
      ++$program{$current}{'checked'};
      for my $par ( sort( keys %$param ), grep { $program{$_}{'force'} } keys %program ) {
        if (
          #BUG!!! next line always NOT on one char targets (/ z x ....)
          ( (
              !( $program{$current}{'notmask'} and $par =~ /$program{$current}{'notmask'}/i )
              and $par =~ /$program{$current}{'mask'}/i
            )
            or $program{$current}{'force'}
          )
          and !$program{$current}{'runned'}
          )
        {
          local @_ = (
            ( defined( $param->{$par} ) and $param->{$par} ne '' ? $param->{$par} : () ),
            ( $program{$current}{'param_name'} ? $par : () )
          );
          state( 'program:', $current, @_ );
          program_one( $current . '_bef', @_ );
          my @r = program_one( $current, @_ );
          program_one( $current . '_aft', @_, \@r );
          printlog( 'warn', 'program finished', $current, '=', @r ) if $r[0] and !ref $r[0];
          $program{$current}{'runned'} = 1 if $program{$current}{'once'} or $program{$current}{'force'};
          $program{$current}{'force'} = '';
        }
      }
    }
  }
}
#BEGIN { config_init(); }
config_init();
1;
