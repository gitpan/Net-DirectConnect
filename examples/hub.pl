#!/usr/bin/perl -w
# $Id: hub.pl 458 2009-01-19 02:03:32Z pro $ $URL: svn://svn.setun.net/dcppp/trunk/examples/hub.pl $

=r

dev hub test

=cut

use strict;
use Data::Dumper;    #dev only
$Data::Dumper::Sortkeys = 1;
use lib '../lib';
use Net::DirectConnect::hub;
my $dc = Net::DirectConnect::hub->new( no_print => undef, );
#$dc->work(100);      #seconds
$dc->work() while $dc->active(); #forever
#$dc->wait_finish();
$dc->disconnect();
#  $dc = undef;
