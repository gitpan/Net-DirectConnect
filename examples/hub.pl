#!/usr/bin/perl -w
#$Id: hub.pl 593 2010-01-30 11:11:27Z pro $ $URL: svn://svn.setun.net/dcppp/trunk/examples/hub.pl $

=r

dev hub test

=cut

use strict;
use Data::Dumper;    #dev only
$Data::Dumper::Sortkeys = $Data::Dumper::Useqq = $Data::Dumper::Indent = 1;
use lib '../lib';
use Net::DirectConnect::hub;
use lib '../lib';
use lib '../TigerHash/lib';
use lib './stat/pslib';
use psmisc;
psmisc::config();
#my $dc = Net::DirectConnect::hub->new( no_print => undef, );
my $dc = Net::DirectConnect->new(
  'protocol' => 'adc',
  hub        => 1,
  no_print   => undef,
  myport     => 413,
  'log'      => sub {
    my $dc = ref $_[0] ? shift : {};
    #psmisc::printlog shift(), $dc->{'number'}, join ' ', psmisc::human('time'), @_, "\n";
    psmisc::printlog shift(), "[$dc->{'number'}]", @_,;
  },
  'auto_work' => sub {
    my $dc = shift;
    psmisc::schedule(
      [ 20, 300 ],
      #our $dump_sub__ ||=
      sub {
        print "Writing dump\n";
        psmisc::file_rewrite( $0 . '.dump', Dumper $dc);
      }
    ) if $config{debug};
  }
);
#$dc->work(100);      #seconds

=without auto_work
while ( $dc->active() ) {
  $dc->work();    #forever
  psmisc::schedule(
    [ 20, 10 ],
    our $dump_sub__ ||= sub {
      print "Writing dump\n";
      psmisc::file_rewrite( 'dump.hub', Dumper $dc);
    }
  );
}
#$dc->wait_finish();
$dc->disconnect();
=cut

#$dc = undef;
