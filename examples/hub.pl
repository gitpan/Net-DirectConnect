#!/usr/bin/perl -w
#$Id: hub.pl 473 2009-10-07 20:35:21Z pro $ $URL: svn://svn.setun.net/dcppp/trunk/examples/hub.pl $

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
$dc->work() while $dc->active();    #forever
#$dc->wait_finish();
$dc->disconnect();
#$dc = undef;
