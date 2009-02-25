# $Id: hubhub.pm 395 2009-01-09 05:34:13Z pro $ $URL: svn://svn.setun.net/dcppp/trunk/lib/Net/DirectConnect/hubhub.pm $
# reserved for future 8)
package Net::DirectConnect::hubhub;
use Net::DirectConnect;
use strict;
no warnings qw(uninitialized);
our $VERSION = ( split( ' ', '$Revision: 395 $' ) )[1];
#our @ISA = ('Net::DirectConnect');
use base 'Net::DirectConnect';

sub init {
  my $self = shift;
  %$self = ( %$self, @_ );
  $self->{'parse'} = {};
  $self->{'cmd'}   = {};
}
1;
