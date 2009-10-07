#$Id: hubhub.pm 472 2009-08-25 05:52:44Z pro $ $URL: svn://svn.setun.net/dcppp/trunk/lib/Net/DirectConnect/hubhub.pm $
#reserved for future 8)
package Net::DirectConnect::hubhub;
use Net::DirectConnect;
use strict;
no warnings qw(uninitialized);
our $VERSION = ( split( ' ', '$Revision: 472 $' ) )[1];
use base 'Net::DirectConnect';

sub init {
  my $self = shift;
  %$self = ( %$self, @_ );
  $self->{'parse'} = {};
  $self->{'cmd'}   = {};
}
1;
