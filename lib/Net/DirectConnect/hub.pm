#Copyright (C) 2005-2006 Oleg Alexeenkov http://sourceforge.net/projects/dcppp proler@gmail.com icq#89088275
#my $Id = '$Id: hub.pm 369 2008-12-19 22:52:24Z pro $';
# reserved for future 8)
package Net::DirectConnect::hub;
use Net::DirectConnect;
use Net::DirectConnect::hubcli;
use strict;
no warnings qw(uninitialized);
our $VERSION = ( split( ' ', '$Revision: 369 $' ) )[1];
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
