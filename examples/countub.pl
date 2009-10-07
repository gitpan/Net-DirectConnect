#!/usr/bin/perl
#my $Id = '$Id: countub.pl 473 2009-10-07 20:35:21Z pro $';

=copyright
counting users-bytes from dchub for mrtg or cacti (snmpd)
=cut

use strict;
use lib '../lib';
use Net::DirectConnect::clihub;
print("usage: countub.pl [dchub://]host[:port] [bot_nick] [share_delim]\n"), exit if !$ARGV[0];
$ARGV[0] =~ m|^(?:dchub\://)?(.+?)(?:\:(\d+))?$|;
my $dc = Net::DirectConnect::clihub->new(
  'host' => $1,
  ( $2 ? ( 'port' => $2 ) : () ),
  'Nick' => ( $ARGV[1] or 'dcpppCnt' ),
  'log' => sub { },    # no logging
);
$dc->connect();
#$dc->cmd('GetNickList');
my ($share) = (0);
$dc->wait_connect();    #for 1 .. 3;
$dc->cmd('GetINFO');
$dc->wait(3);
$share += $dc->{'NickList'}{$_}{'sharesize'} for keys %{ $dc->{'NickList'} };
$share /= $ARGV[2] if $ARGV[2];
print( ( scalar keys %{ $dc->{'NickList'} } or 0 ), "\n$share\n$ARGV[0]\nz\n" );
