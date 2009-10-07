#$Id: psconn.pm 4323 2009-08-25 05:43:42Z pro $ $URL: svn://svn.setun.net/search/trunk/lib/psconn.pm $
package psconn;
use strict;
#use psmisc;
#sub connection {
sub new {
  my $class = shift;
  my $self  = {};
  bless( $self, $class );
  $self->init(@_);
  #printlog( 'conn', 'new', $self, $class, 'deb:', $self->{'error_sleep'} );
  return $self;
}

sub init {
  my $self = shift;
  local %_ = ( 'connected' => 0, 'connect_auto' => 1, 'connect_tries' => 10, 'error_sleep' => 5, @_ );
  @{$self}{ keys %_ } = values %_;
  #printlog('dev', 'conn init error_sleep', $self->{'error_sleep'});
  $self->connect() if $self->{'auto_connect'};
  return $self;
}
##methods
#connect
#reconnect
#disconnect
#dropconnect
#keep
##child can do
#_connect
#_disconnect
#_dropconnect
#check_error
#parse_error
#_keep
##vars
#tries
#error_sleep
#auto_connect
##vars status
#connected
sub connect {
  my $self = shift;
  #return ($self->{'connect_check'} ? $self->keep() : 0) if $self->{'connected'};
  return 1 if $self->{'in_connect'} or $self->{'in_disconnect'};
  return $self->keep() if $self->{'connected'};
  #printlog( 'dev', "conn::connect[$self->{'connect_tried'} <= $self->{'connect_tries'}]" );
  #if (!$self->_connect()) {   #ok
  while ( !$self->{'die'} and $self->{'connect_tried'}++ <= $self->{'connect_tries'} ) {
    #do {    {    #ok
    $self->{'in_connect'} = 1;
    if ( !$self->_connect() ) {
      #printlog('CONNECTED!?');
      $self->{'in_connect'} = 0;
      ++$self->{'connected'};
      ++$self->{'connects'};
      #printlog( 'dev', 'oncon', $_ ),
      $self->{ 'on_connect' . $_ }->($self) for grep { ref $self->{ 'on_connect' . $_ } eq 'CODE' } ( '', 1 .. 10 );
      return 0;
    }
    $self->{'in_connect'} = 0;
    $self->dropconnect();
    $self->log(
      'dev',
      'psconn::connect run sleep',
      $self->{'error_sleep'},
      $self->{'connect_tried'},
      '/', $self->{'connect_tries'}
    );
    $self->sleep( $self->{'error_sleep'} );
  }
  #} while ( ++$self->{'connect_tried'} <= $self->{'connect_tries'} );
  return 1;
}

sub reconnect {
  my $self = shift;
  $self->disconnect(@_);
  return $self->connect(@_);
  #++$self->{'reconnects'};
}

sub disconnect {
  my $self = shift;
  return 0 unless $self->{'connected'};
  #printlog('trace', 'psconn::disconnect');
  $self->_disconnect(@_);
  $self->dropconnect(@_);
}

sub dropconnect {
  my $self = shift;
  return 0 unless $self->{'connected'};
  $self->_dropconnect(@_);
  $self->{'connected'} = 0;
}

sub keep {
  my $self = shift;
  #print("psconn::keep\n");
  #print("psconn::keep:R1=0\n"),
  return 0 if $self->{'connected'} and !$self->{'connect_check'};
  #local $_ =$self->_check();
  #print("keep:preR2[$_]\n");
  #print("keep:R2=0[$_]\n"),
  #return 0 if !$_;
  return 0 if !$self->_check();
  #print("keep:postR2[$_]\n");
  #print('keep:R3=rc'),
  return $self->reconnect();
}

sub _connect {
  my $self = shift;
  #printlog('NEWER');
  return 0;
}

sub _disconnect {
  my $self = shift;
  return 0;
}

sub _dropconnect {
  my $self = shift;
  return 0;
}

sub _check {
  my $self = shift;
  #printlog('DONT');
  return 0;
}

sub check_error {
  my $self = shift;
  return 0;
}

sub parse_error {
  my $self = shift;
  return 0;
}

sub DESTROY {
  my $self = shift;
  #printlog('trace', 'psconn::DESTROY');
  $self->disconnect();
}

sub sleep {
  my $self = shift;
  #$self->log( 'dev', 'psconn::sleep', @_ );
  #local $_ = $work{'sql_locked'};
  #sql_unlock_tables() if $work{'sql_locked'} and $_[0];
  sleep(@_);
  #return psmisc::sleeper(@_);
  #sql_lock_tables($_) if $_ and $_[0];
}
1;
