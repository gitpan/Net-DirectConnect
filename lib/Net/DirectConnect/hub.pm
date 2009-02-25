# $Id: hub.pm 395 2009-01-09 05:34:13Z pro $ $URL: svn://svn.setun.net/dcppp/trunk/lib/Net/DirectConnect/hub.pm $
package Net::DirectConnect::hub;
use Net::DirectConnect;
use Net::DirectConnect::hubcli;
use strict;
no warnings qw(uninitialized);
our $VERSION = ( split( ' ', '$Revision: 395 $' ) )[1];
#our @ISA = ('Net::DirectConnect');
use base 'Net::DirectConnect';

sub init {
  my $self = shift;
  %$self = (
    %$self,
    #
    'incomingclass' => 'Net::DirectConnect::hubcli',
    'auto_connect'  => 0,
    'auto_listen'   => 1,
    'myport'        => 411,
    'myport_base'   => 0,
    'myport_random' => 0,
    'myport_tries'  => 1,
    'HubName'       => 'Net::DirectConnect test hub',
    , @_
  );
  $self->baseinit();
  $self->{'parse'} ||= {};
  $self->{'cmd'}   ||= {};
}
1;
