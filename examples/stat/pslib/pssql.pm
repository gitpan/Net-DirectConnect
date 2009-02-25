#!/usr/bin/perl
# $Id: pssql.pm 4253 2009-01-12 23:01:18Z pro $ $URL: svn://svn.setun.net/search/trunk/lib/pssql.pm $

=copyright
PRO-search sql library
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

=c
todo:

$work

=cut

package pssql;
use strict;
use locale;
use DBI;
use Data::Dumper;    #dev only
$Data::Dumper::Sortkeys = 1;
use psmisc;
#psconn.pm
#use pssql;
use psconn;
#our @ISA = ('connection');
use base 'psconn';
no warnings qw(uninitialized);
our $AUTOLOAD;
our ( %config, %work, %stat, %static, $param, );    #%human, %processor, %program
our $VERSION = ( split( ' ', '$Revision: 4253 $' ) )[1];
my ( $tq, $rq, $vq );
#todoo
#=c
my (
  $roworder, $tableorder,
  #%tableorder
);
our ( %row, %default );

sub row {                                           #print("rowcall($_[0])[", values %{$config{'row'}{$_[0]}} ,"]\n");
  my $row = shift @_;
  #  my $ret = ;  return wantarray ? %$ret : $ret;
  #  return { %{ $config{'row'}{$row} or $row{$row} or {} }, %{ $config{'row_all'} or {} }, 'order' => --$roworder, @_ };
  return {
    %{ ( defined $config{'row'} ? $config{'row'}{$row} : undef ) || $row{$row} || {} }, %{ $config{'row_all'} || {} },
    'order' => --$roworder,
    @_
  };
}

sub table {                                         #print("rowcall($_[0])[", values %{$config{'row'}{$_[0]}} ,"]\n");
  my $table = shift @_;
  #  my $ret = ;  return wantarray ? %$ret : $ret;
  #  return { %{ $config{'row'}{$row} or $row{$row} or {} }, %{ $config{'row_all'} or {} }, 'order' => --$roworder, @_ };
  #    'order' => --$tableorder,
  return @_;
  #{
  #    %{ ( defined $config{'row'} ? $config{'row'}{$row} : undef ) || $row{$row} || {} }, %{ $config{'row_all'} || {} },
  #    'order' => --$tableorder,
  #    @_
  #  };
}
#}
BEGIN {
  %row = (
    'time' => {
      'type'      => 'INT',
      'unsigned'  => 1,
      'default'   => 0,
      'date_time' => 1,       #todo
    },
    'uint'   => { 'type' => 'INTEGER',  'unsigned' => 1, 'default' => 0, },
    'uint16' => { 'type' => 'SMALLINT', 'unsigned' => 1, 'default' => 0, },
    'uint64' => { 'type' => 'BIGINT',   'unsigned' => 1, 'default' => 0, },
    'text'   => {
      'type' => 'VARCHAR',
      #        'length' => $config{'sql_length_text'},
      #    'length' => '333',
      #      'primary' => 1,
      'index' => 10,
      #        'order'		=> --$order,
      #      'array_insert' => 1,
      #    'insert_min'   => 1,
      #        'show' => 1,
      'default' => '',
    },
    'stem' => {
      'type' => 'VARCHAR',
      #!      'length'   => 128,
      'fulltext' => 'stemi',
      #          'array_insert' => 1,
      #          'order'        => --$order,
      #          'row'          => 1,
      'default'    => '',
      'not null'   => 1,
      'stem_index' => 1,
    },
  );
  $row{'id'} ||= row( 'uint', 'auto_increment' => 1, 'primary' => 1 ),
    $row{'added'} ||= row( 'time', 'default_insert' => int( time() ), 'no_insert_update' => 1, );
  $row{'year'} ||= row('uint16');
  $row{'size'} ||= row('uint64');
  #  print "SQLDEFINIT;";
  %default = (
    #    $self->{'default'} ||= {
    'sqlite' => {
      #      'dbi'          => 'SQLite2',
      'dbi'            => 'SQLite',
      'params'         => [qw(dbname)],
      'dbname'         => $config{'root_path'} . 'sqlite.db',
      'table quote'    => '"',
      'row quote'      => '"',
      'value quote'    => "'",
      'IF NOT EXISTS'  => 'IF NOT EXISTS',
      'IF EXISTS'      => 'IF EXISTS',
      'REPLACE'        => 'REPLACE',
      'AUTO_INCREMENT' => 'AUTOINCREMENT',
      'err_ignore'     => [qw( 1 )],
      'error_type'     => sub {                                 #TODO!!!
        my $self = shift;
        my ( $err, $errstr ) = @_;
        #              printlog('dev',"ERRDETECT($err, $errstr)");
        return 'install' if $errstr =~ /no such table:/i;
        return 'syntax'
          if $errstr =~ /syntax|unrecognized token/i
            or $errstr =~ /misuse of aggregate/;
        return 'retry' if $errstr =~ /database is locked/i;
        #      return 'connection' if $errstr =~ /connect/i;
        return undef;
      },
      'on_connect' => sub {
        my $self = shift;
        $self->do("PRAGMA synchronous = OFF;");
        #        $self->log( 'sql', 'on_connect!' );
      },
      'no_dbirows' => 1,
    },
    'pgpp' => {
      'dbi'  => 'PgPP',
      'user' => ( $^O =~ /^(?:(ms)?(dos|win(32|nt)?))/i ? 'postgres' : 'pgsql' ),
      #      'dbname'         => 'psqldef',
      #      'port' => 5432,
      'IF EXISTS' => 'IF EXISTS', 'CREATE TABLE' => 'CREATE TABLE', 'OFFSET' => 'OFFSET',
      #     'unsigned'     => 0,
      'UNSIGNED'        => '',
      'table quote'     => '"',
      'row quote'       => '"',
      'value quote'     => "'",
      'REPLACE'         => 'INSERT',
      'EXPLAIN'         => 'EXPLAIN ANALYZE',
      'CASCADE'         => 'CASCADE',
      'fulltext_config' => 'pg_catalog.simple',
      'params'          => [qw(dbname host port path)],
      'err_ignore'      => [qw( 1 7)],
      'error_type'      => sub {
        my $self = shift, my ( $err, $errstr ) = @_;
        #              printlog('dev',"ERRDETECT($err, [$errstr])");
        #              printlog('dev',"ERRRET1"),
        return 'install_db' if $errstr =~ /FATAL:\s*database ".*?" does not exist/i;
        #              printlog('dev',"ERRRET2"),
        return 'fatal'      if $errstr =~ /fatal/i;
        return 'syntax'     if $errstr =~ /syntax/i;
        return 'connection' if $errstr =~ /connect|Unknown message type: ''/i;
        return 'install'    if $errstr =~ /ERROR:\s*(?:relation \S+ does not exist)/i;
        #return 'retry'    if $errstr =~       /ERROR:\s*cannot drop the currently open database/i;
        return 'retry' if $errstr =~ /ERROR:  database ".*?" is being accessed by other users/i;
        return 'ignore'
          if $errstr =~
/(?:duplicate key violates unique constraint)|(?:duplicate key value violates unique constraint)|(?:ERROR:\s*(?:database ".*?" already exists)|(?:relation ".*?" already exists)|(?:invalid byte sequence for encoding)|(?:function .*? does not exist)|(?:null value in column .*? violates not-null constraint))/i;
        return undef;
      },
      'on_connect' => sub {
        #      printlog('dev',"pgoncon");
        my $self = shift;
        $self->do("select set_curcfg('default');") if $self->{'use_fulltext'} and $self->{'old_fulltext'};
        #        $self->query_log("SET lc_messages='English_English'") ;
        #        $self->query_log("SET lc_messages='de'") ;
        #        $self->query_log("SHOW ALL") ;
      },
      'no_dbirows' => 1,
      #      'err_connection' => [qw( 7)],
      'cp1251'             => 'win1251',
      'fulltext_word_glue' => '&',
    },
    'mysql5' => {
      'dbi'            => 'mysql',
      'user'           => 'root',
      'use_drh'        => 1,
      'varchar_max'    => 65530,
      'unique_max'     => 1000,
      'primary_max'    => 999,
      'fulltext_max'   => 1000,
      'err_connection' => [qw( 1 1040 1053 1129 1213 1226 2002 2003 2006 2013 )],
      'err_fatal'      => [qw( 1016 1046 1251 )],                                   # 1045,
      'err_syntax'  => [qw( 1054 1060 1064 1065 1067 1071 1096 1103 1118 1148 1191 1364 1366 1406 1439)],  #maybe all 1045..1075
      'err_repair'  => [qw( 126  130 144 145 1034 1062 1194 1582 )],
      'err_retry'   => [qw( 1317 )],
      'err_install' => [qw(  1146  )],
      'err_install_db' => [qw( 1049 )],
      'err_ignore '    => [qw( 2 1264 )],
      'error_type'     => sub {
        my $self = shift, my ( $err, $errstr ) = @_;
        #      printlog('dev',"MYERRDETECT($err, $errstr)");
        for my $errtype (qw(connection retry syntax fatal repair install install_db)) {
          #      printlog('dev',"ERRDETECTED($err, $errstr) = $errtype"),
          return $errtype if grep { $err eq $_ } @{ $self->{ 'err_' . $errtype } };
        }
        return undef;
      },
      'table quote' => "`",
      'row quote'   => "`",
      'value quote' => "'",
      #      'index quote'		=> "`",
      #      'unsigned'                => 1,
      'quote_slash'             => 1,
      'index in create table'   => 1,
      'utf-8'                   => 'utf8',
      'koi8-r'                  => 'koi8r',
      'table options'           => 'ENGINE = MYISAM',
      'IF NOT EXISTS'           => 'IF NOT EXISTS',
      'IF EXISTS'               => 'IF EXISTS',
      'IGNORE'                  => 'IGNORE',
      'REPLACE'                 => 'REPLACE',
      'INSERT'                  => 'INSERT',
      'HIGH_PRIORITY'           => 'HIGH_PRIORITY',
      'SET NAMES'               => 'SET NAMES',
      'DEFAULT CHARACTER SET'   => 'DEFAULT CHARACTER SET',
      'USE_FRM'                 => 'USE_FRM',
      'EXTENDED'                => 'EXTENDED',
      'QUICK'                   => 'QUICK',
      'ON DUPLICATE KEY UPDATE' => 'ON DUPLICATE KEY UPDATE',
      'UNSIGNED'                => 'UNSIGNED',
      'UNLOCK TABLES'           => 'UNLOCK TABLES',
      'LOCK TABLES'             => 'LOCK TABLES',
      'OPTIMIZE'                => 'OPTIMIZE TABLE',
      'ANALYZE'                 => 'ANALYZE TABLE',
      'FLUSH'                   => 'FLUSH TABLE',
      'LOW_PRIORITY'            => 'LOW_PRIORITY',
      'on_connect'              => sub {
        my $self = shift;
        #        printlog('dev', "onconect $self->{'SET NAMES'} $self->{'set_names'}");
        #            and !$self->{'set_names_count'}++;
        $self->{'db_id'} = $self->{'dbh'}->{'mysql_thread_id'};
#        $self->log( 'sql', 'on_connect', $self->{'db_id'} );
#        $self->do( $self->{'SET NAMES'} . " $vq$self->{'cp_set_names'}$vq" ) if $self->{'cp_set_names'} and $self->{'SET NAMES'};
        $self->set_names() if !( $ENV{'MOD_PERL'} || $ENV{'FCGI_ROLE'} );
      },
      'on_user' => sub {
        my $self = shift;
        #        printlog('dev', "onuser $self->{'SET NAMES'} $self->{'set_names'}");
        #        $self->do( $self->{'SET NAMES'} . " $vq$self->{'set_names'}$vq" )
        #         if $self->{'set_names'}            and $self->{'SET NAMES'};
        $self->set_names() if $ENV{'MOD_PERL'} || $ENV{'FCGI_ROLE'};
      },
      'params' => [
        qw(host port database mysql_client_found_rows mysql_compression mysql_connect_timeout mysql_read_default_file mysql_read_default_group mysql_socket
          mysql_ssl mysql_ssl_client_key mysql_ssl_client_cert mysql_ssl_ca_file mysql_ssl_ca_path mysql_ssl_cipher
          mysql_local_infile mysql_embedded_options mysql_embedded_groups)
      ],    # perldoc DBD::mysql
      'insert_by' => 1000,
      ( !$ENV{'SERVER_PORT'} ? ( 'auto_check' => 1 ) : () ),
      'unique name' => 1,      # test it
      'match'       => sub {
        #sub query_count {
        my $self = shift;
        my ( $param, $param_num, $table, $search_str, $search_str_stem ) = @_;
        my ( $ask, $glue );
        #          for my $index ( @{ $self->{'fulltext'} } ) {
        local %_;
        map { $_{ $self->{'table'}{$table}{$_}{'fulltext'} } = 1 }
          grep { $self->{'table'}{$table}{$_}{'fulltext'} } keys %{ $self->{'table'}{$table} };
        for my $index ( keys %_ ) {
          if (
            $_ = join( ' , ',
              map    { "$rq$_$rq" }
                sort { $self->{'table'}{$table}{$b}{'order'} <=> $self->{'table'}{$table}{$a}{'order'} }
                grep { $self->{'table'}{$table}{$_}{'fulltext'} eq $index } keys %{ $self->{'table'}{$table} } )
            )
          {
            my $stem =
              grep { $self->{'table'}{$table}{$_}{'fulltext'} eq $index and $self->{'table'}{$table}{$_}{'stem_index'} }
              keys %{ $self->{'table'}{$table} };
            my $double =
              grep { $self->{'table'}{$table}{$_}{'fulltext'} and $self->{'table'}{$table}{$_}{'stem'} }
              keys %{ $self->{'table'}{$table} };
            next if $double and ( $self->{'accurate'} xor !$stem );
            #printlog('acc', $index, $self->{'table'}{$table}{$index}{'fulltext'} ,
            #and
            # $self->{'table'}{$table}{$index}{'stem_index'},
            #and
            #;
            #printlog('I', $index, $_, $stem, $double, $self->{'accurate'});
            my $match = ' MATCH (' . $_ . ') AGAINST (' . $self->squotes( $stem ? $search_str_stem : $search_str ) . (
              ( !$self->{'no_boolean'} and $param->{ 'adv_query' . $param_num } eq 'on' )
              ? 'IN BOOLEAN MODE'
                #              : ( $self->{'allow_query_expansion'} ? 'WITH QUERY EXPANSION' : '' )
              : $self->{'fulltext_extra'}
            ) . ') ';
            $ask .= " $glue " . $match;
            #            $work{'what_relevance'}{$table} ||= ', ' . $match . ' as relev';
            $work{'what_relevance'}{$table} ||= $match . " AS $rq" . "relev$rq"
              if $self->{'select_relevance'}
                or $self->{'table_param'}{$table}{'select_relevance'};
          }
          $glue = $self->{'fulltext_glue'};
        }
        return $ask;
      },
    },
    #  };
  );
  #print "def=", Dumper(\%default);
}
#=cut
sub new {
  my $self = bless( {}, shift );
  #  printlog( 'sql', 'new', $self );
  #  print('sql', 'new', $self, "\n");
  $self->init(@_);
  $self->psconn::init(@_);
  #printlog('dev', ' error_sleep', $self->{'error_sleep'});
  return $self;
}

sub cmd {
  my $self = shift;
  #  local $_ = shift;
  my $cmd = shift;
  #  my $name = shift;
  $self->log( 'trace', "pssql::$cmd [$self->{'dbh'}]", @_ ) if $cmd ne 'log';
  $self->{'handler_bef'}{$cmd}->( $self, \@_ ) if $self->{'handler_bef'}{$cmd};
  #  $self->log( 'dbg', 'cmd nodef:', $cmd ), return unless length $cmd and defined $self->{$cmd};
  #  if ( $self->{$name} ) {
  #$self->log('dev', 'cmdc:', $self->{$name});
  #my @ret = $self->{$cmd} =~ /^CODE\(/ ? $self->{$cmd}->( $self, @_ ) : $self->{$cmd};
  my @ret =
    ref( $self->{$cmd} ) eq 'CODE' ? ( wantarray ? ( $self->{$cmd}->( $self, @_ ) ) : scalar $self->{$cmd}->( $self, @_ ) ) : (
    exists $self->{$cmd} ? ( ( defined( $_[0] ) ? ( $self->{$cmd} = $_[0] ) : ( $self->{$cmd} ) ) ) : (
      undef
        #exists &$self->{'dbh'}->{$cmd} ? $self->{'dbh'}->$cmd() : 0
    )
    );
  $self->{'handler'}{$cmd}->( $self, \@_, \@ret ) if $self->{'handler'}{$cmd};
  return wantarray ? @ret : $ret[0];
  #    return $self->do( $self->{$name}->( $self, @_ ) ) if $self->{'do'}{$name};
  #    return $self->query( $self->{$name}->( $self, @_ ) );
  #  }
}

sub AUTOLOAD {
  my $self = shift;
  my $type = ref($self) or return;
  #                    or croak "$self is not an object";
  my $name = $AUTOLOAD;
  $name =~ s/.*://;    # strip fully-qualified portion
                       #        $self->log('dev', 'autoload', $name, @_);
  return $self->cmd( $name, @_ );
}

sub _disconnect {
  my $self = shift;
  $self->log( 'trace', 'pssql::_diconnect', "dbh=$self->{'dbh'}" );
  $self->flush_insert() unless $self->{'in_disconnect'};
  $self->{'in_disconnect'} = 1;
  #  $self->log( 'sql', 'pssql::_disconnect' );
  #  $self->{'sth'}->finish() if $self->{'sth'};
  #  $self->{'dbh'}->disconnect(), $self->{'dbh'} = 0 if $self->{'dbh'} and keys %{ $self->{'dbh'} };
  #  delete $self->{'in_disconnect'};
  return 0;
}

sub _dropconnect {
  my $self = shift;
  $self->log( 'trace', 'pssql::_dropconnect' );
  $self->{'in_disconnect'} = 1;
  #  $self->log( 'sql', 'pssql::_dropconnect', $self->{'connected'} );
  $self->{'sth'}->finish() if $self->{'sth'};
  $self->{'dbh'}->disconnect(), $self->{'dbh'} = undef if $self->{'dbh'} and keys %{ $self->{'dbh'} };
  delete $self->{'in_disconnect'};
  return 0;
}

sub _check {
  my $self = shift;
  #  $self->log( 'trace', 'pssql::check:', $self->{'dbh'} );
  #   $self->log('checkD:',Dumper($self)),
  #   $self->log('checkR1:'),
  return 1 if !$self->{'dbh'} or !$self->{'connected'};    #or !keys %{$self->{'dbh'}};
                                                           #   $self->log('checkRP:=',$self->{'dbh'}->ping()),
  return !$self->{'dbh'}->ping();
}
#sub query {
#  my $self  = shift;
#  my $query = shift;
#  $self->{$query}->(@_) if $self->{$query};
#  return 0;
#}
#sub err_parse {
#  my $self = shift;
#  return 0;
#}
sub init {
  my $self = shift;
  local %_ = (
    'log' => sub (@_) {    #move to func later
      shift;
      psmisc::printlog(@_);
    },
    'driver'            => 'mysql5',
    'host'              => ( $^O eq 'cygwin' ? '127.0.0.1' : 'localhost' ),
    'database'          => 'pssqldef',
    'connect_tries'     => 100,
    'error_sleep'       => 3600,
    'error_tries'       => 1000,
    'error_chain_tries' => 100,
    #    'reconnect_tries' => 10,            #look old
    'connect_auto'   => 0,
    'connect_params' => {
      'RaiseError'  => 0,
      'AutoCommit'  => 1,
      'PrintError'  => 0,
      'PrintWarn'   => 0,
      'HandleError' => sub {
        $self->log( 'dev', 'HandleError', @_, $DBI::err, $DBI::errstr );
        #psmisc::caller_trace(15)
      },
    },
    #    'connect_check' => 1, #check connection on every keep()
    'auto_repair'          => 10,                                                    # or number 10-30
    'auto_repair_selected' => 0,                                                     # repair all tables
    'auto_install'         => 1, 'auto_install_db' => 1, 'err_retry_unknown' => 0,
    #'reconnect_sleep' => 3600,    #maximum sleep on connect error
    'codepage' => 'utf-8',
    #    'cp_in'             => 'utf-8',
    'index_postfix' => '_i', 'limit_max' => 1000, 'limit_default' => 100,
    #    'limit' => 100,
    'page_min'     => 1,
    'page_default' => 1,
    #    'varchar_max'    => 255,
    'varchar_max'    => 65535,
    'row_max'        => 65535,
    'primary_max'    => 65535,
    'fulltext_max'   => 65535,
    'AUTO_INCREMENT' => 'AUTO_INCREMENT',
    'EXPLAIN'        => 'EXPLAIN',
    'statable'       => { 'queries' => 1, 'connect_tried' => 1, 'connects' => 1, 'inserts' => 1 },
    'statable_time' => { 'queries_time' => 1, 'queries_avg' => 1, },
    'param_trans_int' => { 'on_page' => 'limit', 'show_from' => 'limit_offset', 'page' => 'page', 'accurate' => 'accurate' },
    #    'param_trans'    => { 'codepage'=>'cp_out' ,},
    'connect_cached'     => 1,
    'char_type'          => 'VARCHAR',
    'true'               => 1,
    'fulltext_glue'      => 'OR',
    'retry_vars'         => [qw(auto_repair connect_tries error_sleep error_tries auto_check)],
    'err'                => 0,
    'insert_cached_time' => 60,
    @_
  );
  @{$self}{ keys %_ } = values %_;
  #    $self->log( 'dev', 'initdb',  "$self->{'database'},$self->{'dbname'};");
  $self->{'database'} = $self->{'dbname'} if $self->{'dbname'};
  $self->{'dbname'} ||= $self->{'database'};
  $self->calc();
  $self->functions();
  #    $self->log( 'dev', 'initdb2',  "$self->{'database'},$self->{'dbname'};");
  ( $tq, $rq, $vq ) = $self->quotes();
  DBI->trace( $self->{'trace_level'}, $self->{'trace'} ) if $self->{'trace_level'} and $self->{'trace'};
  #  $self->log( 'sql', 'init', $self );
  return 0;
}

sub calc {
  my $self = shift;
  #  $self->{'dbi'} = 'mysql' if $self->{'driver'} =~ /^mysql/i;
  #  print "CAL";
  $self->{'dbi'} ||= $self->{'driver'}, $self->{'dbi'} =~ s/\d+$//i unless $self->{'dbi'};
  $self->{'default'} ||= \%default;
  #         (
  $self->{'default'}{'pgpp'}{'match'} = sub {
    #sub query_count {
    my $self = shift;
    return undef unless $self->{'use_fulltext'};
    my ( $param, $param_num, $table, $search_str, $search_str_stem ) = @_;
    my ( $ask, $glue );
    #          for my $index ( @{ $self->{'fulltext'} } ) {
    #          $search_str =~ s/(?:^\x20+)|(?:\x20+$)//;
    #          $search_str =~ s/([^|&])\x20+([^|&])/$1$self->{'fulltext_word_glue'}$2/g;
    #$self->log('dev', $search_str, $search_str_stem,);
    #    $$_ =~ s/(?:^\x20+)|(?:\x20+$)//, $$_ =~ s/([^|&])\x20+([^|&])/$1$self->{'fulltext_word_glue'}$2/g #??? why?
    #      for \( $search_str, $search_str_stem );
    s/(?:^\s+)|(?:\s+$)//,
      #s/([^|&])\x20+([^|&])/$1$self->{'fulltext_word_glue'}$2/g
      s/\s+/$self->{'fulltext_word_glue'}/g for ( $search_str, $search_str_stem );
    #$self->log('dev',2, $search_str, $search_str_stem,);
    local %_;
    map { $_{ $self->{'table'}{$table}{$_}{'fulltext'} } = 1 }
      grep { $self->{'table'}{$table}{$_}{'fulltext'} } keys %{ $self->{'table'}{$table} };
    for my $index ( keys %_ ) {
      my $stem =
        grep { $self->{'table'}{$table}{$_}{'fulltext'} eq $index and $self->{'table'}{$table}{$_}{'stem_index'} }
        keys %{ $self->{'table'}{$table} };
      my $double =
        grep { $self->{'table'}{$table}{$_}{'fulltext'} and $self->{'table'}{$table}{$_}{'stem'} }
        keys %{ $self->{'table'}{$table} };
      next if $double and ( $self->{'accurate'} xor !$stem );
      #$self->{'fulltext_config'}#${vq}default${vq},   pg_catalog.simple
      $ask .= " $glue $index @@ to_tsquery( ${vq}$self->{'fulltext_config'}${vq}, "
        . $self->squotes( $stem ? $search_str_stem : $search_str ) . ")";
      $glue ||= $self->{'fulltext_glue'};
    }
    return $ask;
    }
    if $self->{'use_fulltext'};
  #      )
  %{ $self->{'default'}{'mysql6'} } = %{ $self->{'default'}{'mysql5'} };
  %{ $self->{'default'}{'mysql4'} } = %{ $self->{'default'}{'mysql5'} };
  $self->{'default'}{'mysql4'}{'SET NAMES'}                 = $self->{'default'}{'mysql4'}{'DEFAULT CHARACTER SET'} =
    $self->{'default'}{'mysql4'}{'ON DUPLICATE KEY UPDATE'} = '';
  $self->{'default'}{'mysql4'}{'varchar_max'} = 255;
  %{ $self->{'default'}{'mysql3'} } = %{ $self->{'default'}{'mysql4'} };
  $self->{'default'}{'mysql3'}{'table options'} = '';
  $self->{'default'}{'mysql3'}{'USE_FRM'}       = '';
  $self->{'default'}{'mysql3'}{'no_boolean'}    = 1;
  %{ $self->{'default'}{'sqlite2'} } = %{ $self->{'default'}{'sqlite'} };
  $self->{'default'}{'sqlite2'}{'IF NOT EXISTS'} = $self->{'default'}{'sqlite2'}{'IF EXISTS'} = '';
  $self->{'default'}{'pgpp'}{'fulltext_config'} = 'default' if $self->{'old_fulltext'};
  %{ $self->{'default'}{'pg'} } = %{ $self->{'default'}{'pgpp'} };
  $self->{'default'}{'pg'}{'dbi'} = 'Pg';
  %{ $self->{'default'}{'mysqlpp'} } = %{ $self->{'default'}{'mysql5'} };
  $self->{'default'}{'mysqlpp'}{'dbi'} = 'mysqlPP';
  $self->{'driver'} ||= 'mysql5';    # 'pgpp'
  $self->{'driver'} = 'mysql5' if $self->{'driver'} eq 'mysql';
  #  $self->log('devset#', $self->{'driver'});
  #    $self->log('devset',$_, $self->{'default'}{ $self->{'driver'} }{$_},$self->{'driver'}),
  $self->{$_} = $self->{'default'}{ $self->{'driver'} }{$_} for keys %{ $self->{'default'}{ $self->{'driver'} } };
  #    $self->{$_} = $self->{'default'}{ $self->{'driver'} }{'config'}{$_}
  #      for keys %{ $self->{'default'}{ $self->{'driver'} }{'config'} };
  #  if ( $self->{'driver'} =~ /^mysql/i ) {
  #  }
  $self->{'codepage'} = psmisc::cp_normalize( $self->{'codepage'} );
  local $_ = $self->{ $self->{'codepage'} } || $self->{'codepage'};
  #    $self->log('dev', $self->{'codepage'}, $_);
  $self->{'cp'} = $_;
  #  $self->{'default_character_set'} ||= $_;
  $self->{'cp_set_names'} ||= $_;
  $self->{'cp_int'}       ||= 'cp1251';    # internal
  $self->cp_client( $self->{'codepage'} );
  #printlog('dev', "cpint=$self->{'cp_int'}");
  #    $self->log( 'sql', 'calc' );
  #      $self->dump();
  #  printlog('dev', Dumper($self));
  #exit;
}

sub _connect {
  my $self = shift;
  $self->log( 'trace', 'pssql::_connect' );
  #    $self->log("pssql::_connect: try $self->{'in_connect'} or $self->{'in_disconnect'}");
  #  return 1 if $self->{'in_connect'} or $self->{'in_disconnect'}
  #  or  ( $self->{'errors'} >= $self->{'error_tries'} )

=c
  $self->log(
    'dev', 'conn',
    "dbi:$self->{'dbi'}:"
      #          "dbi:$self->{'default'}{ $self->{'driver'} }{'dbi'}:database=$self->{'base'};"
      #map {"$_:$self->{$_}"} qw(dbi database)
      . join(
      ';',
      map( { $_ . '=' . $self->{$_} }
        grep { defined( $self->{$_} ) } @{ $self->{'params'} } )
      ),
    $self->{'user'},
    $self->{'pass'},
    #          \%{ $self->{'connect_params'} }
    $self->{'connect_params'}
  );
=cut

  #  $self->{'dbh'} = DBI->connect_cached(
  #  $self->{'in_connect'} = 1;
  local @_ = (
    "dbi:$self->{'dbi'}:"
      . join( ';', map( { $_ . '=' . $self->{$_} } grep { defined( $self->{$_} ) } @{ $self->{'params'} } ) ),
    $self->{'user'}, $self->{'pass'}, $self->{'connect_params'}
  );
  #        $self->log('dmp', "connect_cached = ",$self->{'connect_cached'}, Dumper(\@_));
  $self->{'dbh'} = ( $self->{'connect_cached'} ? DBI->connect_cached(@_) : DBI->connect(@_) );
  #      )
  #  $self->log('dbh=',$self->{'dbh'}, Dumper($self->{'dbh'}));
  local $_ = $self->err_parse( \'Connection', $DBI::err, $DBI::errstr );    # ' mc color sux
                                                                            #  $self->{'in_connect'} = 0;
                                                                            #  $self->check() if $self->{'auto_check'};
                                                                            #  printlog("connection ret[$_]");
  return $_;

=c
  if ( !$self->err_parse( \'Connection' ) ) {
    #      ++$self->{'connected'};
    $self->log( 'sql', "connected to database" );
    #todo sub
    sql_do( $self->{'SET NAMES'} . " '$self->{'set_names'}'" )
      if $self->{'set_names'}
      and $self->{'SET NAMES'}
      and !$self->{'set_names_count'}++;
    $self->{'connect_try'} = 0;
    return 0;
  }
  #  return 0;
=cut

}

sub sleep {
  my $self = shift;
  #  $self->log( 'dev', 'psconn::sleep', @_ );
  # local $_ = $work{'sql_locked'};
  # sql_unlock_tables() if $work{'sql_locked'} and $_[0];
  #  sleep(@_);
  return psmisc::sleeper(@_);
  # sql_lock_tables($_) if $_ and $_[0];
}

sub functions {
  my $self = shift;
  $self->{'user_params'} ||= sub {
    #    sub user_params {
    my $self = shift;
    #    for $param (@_) {
    ( $tq, $rq, $vq ) = $self->quotes();
    my $param = { map { %$_ } @_ };
    #       printlog('dev', "user_paramsR", %$param);
    for my $from ( keys %{ $self->{'param_trans_int'} } ) {
      my $to = $self->{'param_trans_int'}{$from} || $from;
      $param->{$from} = 1 if $param->{$from} eq 'on';
      $self->{$to} =
        psmisc::check_int( $param->{$from}, ( $self->{ $to . '_min' } ), $self->{ $to . '_max' }, $self->{ $to . '_default' } );
#   printlog('dev', "user_params int $from->$to = $self->{ $to }", ( 'param=',$param->{$from}, ('min=',$self->{ $to.'_min'} ), 'max=',$self->{ $to.'_max'}, 'def=',$self->{ $to.'_default'} ) );
#      }
    }

=c
    for my $from (    grep {defined $param->{$_}} keys %{ $self->{'param_trans'} } )
    {
      my $to = $self->{'param_trans'}{$from} || $from;
      $self->{$to} =$param->{$from};
   printlog('dev', "user_params $from->$to = $self->{ $to }",  'param=',$param->{$from},  'def=',$self->{ $to.'_default'}  );
#      }
    }
=cut

    $self->cp_client( $work{'codepage'} || $param->{'codepage'} || $config{'codepage'} );
  };
  $self->{'dump'} ||= sub {
    #sub dump {
    my $self = shift;
    $self->log( 'dmp', caller, ':=', join( ':', %$self ) );
    return 0;
  };
  $self->{'quotes'} ||= sub {
    #sub quotes {    # my ($tq, $rq, $vq) = $self->quotes();
    my $self = shift;
    $self->{'tq'} ||= $self->{'table quote'};
    $self->{'rq'} ||= $self->{'row quote'};
    $self->{'vq'} ||= $self->{'value quote'};
    return (
      $self->{'table quote'},    #$tq
      $self->{'row quote'},      #$rq
      $self->{'value quote'},    #$vq
    );
  };
  $self->{'sleep'} ||= sub {
    #sub sleep {
    my $self = shift;
    $self->log( 'dev', 'sql_sleeper', @_ );
    # local $_ = $work{'sql_locked'};
    # sql_unlock_tables() if $work{'sql_locked'} and $_[0];
    return psmisc::sleeper(@_);
    # sql_lock_tables($_) if $_ and $_[0];
  };
  $self->{'drh_init'} ||= sub {
    #sub drh {
    my $self = shift;
    $self->{'drh'} ||= DBI->install_driver( $self->{'dbi'} );
    return 0;
  };
  $self->{'repair'} ||= sub {
    #sub repair {
    my $self = shift;
    #    psmisc::program('repair');
    #$program{ psmisc::program() }{'func'} ||= sub {
    my $tim = psmisc::timer();
    @_ = keys %{ $self->{'table'} } unless @_;
    @_ = grep { $_ and $self->{'table'}{$_} } @_;
    $self->log( 'info', 'Repairing table...', @_ );
    $self->flush();
    local $self->{'error_tries'} = 0;    #!
    $self->query_log( "REPAIR TABLE "
        . join( ',', map( $self->tquote("$self->{'table_prefix'}$_"), @_ ) )
        . ( $self->{'rep_quick'} ? ' ' . $self->{'QUICK'}    : '' )
        . ( $self->{'rep_ext'}   ? ' ' . $self->{'EXTENDED'} : '' )
        . ( $self->{'rep_frm'}   ? ' ' . $self->{'USE_FRM'}  : '' ) );
    $self->flush();
    $self->log( 'time', 'Repair per', psmisc::human( 'time_period', $tim->() ) );
    #};
    return 0;
  };
  $self->{'query_time'} ||= sub {
    my $self = shift;
    #          $self->log( 'dev', 'query_time ',  $_[0]);
    ++$self->{'queries'};
    $self->{'queries_time'} += $_[0];
    $self->{'queries_avg'} = $self->{'queries_time'} / $self->{'queries'} || 1;
  };
  $self->{'do'} ||= sub {
    #sub do {
    my $self = shift;
    my $ret;
    #                 $self->log( 'dev', 'do1', @_ ),
    #local $config{'log_trace'}=1;
    return $ret if $self->keep();
    #             $self->log( 'dev', 'do2', @_ );
    for my $cmd (@_) {
      next unless $cmd;
      do {
        {
          #$self->log( 'dev', 'PREdo:[', $_, '] ' );
          #?    return $ret if $self->keep();
          #        last if $self->can_query();
          $self->log( 'dmpbef', 'do:[', $cmd, '] ' );
          my $tim = psmisc::timer();
#        local $_ = $self->{'dbh'}->do($cmd), ( ( $ret and $_ ) ? $ret += $_ : $ret = ( $_ or $ret ) )          if $self->{'dbh'};
#$self->err(0);
          $ret += $self->{'dbh'}->do($cmd) if $self->{'dbh'};
          #        $self->log( 'dmp', 'do:[', $_, '] = ', $lret );
          #        $self->err_parse( \$_, $DBI::err, $DBI::errstr );
          $self->log( 'dmp', 'do:[', $cmd, '] = ', $ret, ' per', psmisc::human( 'time_period', $tim->() ) );
          $self->query_time( $tim->() );
          #        $self->log( 'sql', $cmd);
        }
      } while ( $self->can_query() and $self->err_parse( \$cmd, $DBI::err, $DBI::errstr ) );
    }
    return $ret;
    #  return 0;
  };
  #  $self->{'cant_connect'} ||= sub {    my $self = shift;  }

=test del
  $self->{'errz'} ||= sub {
    my $self = shift;
    $self->log( 'errcall', @_ );
    $self->{'err_save'} = $_[0] if defined $_[0];
    return $self->{'err_save'};
  };
=cut

  $self->{'can_query'} ||= sub {
    my $self = shift;
#        local $_ = ;
#    $self->log( 'dev',      "can_query[$self->{'errors_chain'} < $self->{'error_chain_tries'}  ) or ( $self->{'errors'} < $self->{'error_tries'}] ==[]" );
    return !( $work{'die'} or $self->{'die'} or $self->{'fatal'} )
      && ( $self->{'errors_chain'} < $self->{'error_chain_tries'} )
      && ( $self->{'errors'} < $self->{'error_tries'} );
  };
  $self->{'prepare'} ||= sub {
    #sub prepare {    #v1
    my $self = shift;
    my ($query) = @_;
    #    printlog( 'dev', 'prepare start' ,$self->keep());
    return 1 if $self->keep();
    #  return 0 unless $static{'sqlo'}{ sql_object() }{'dbh'};
    $self->log( 'dmpbef', "prepare query {$query}" );
    return 2 unless $query;
    my $ret;
    my $tim = psmisc::timer();
    do {
      {
        #        last if $self->can_query();
        #        last if $self->{'errors_chain'} > $self->{'error_chain_tries'};
        $self->{'sth'}->finish() if $self->{'sth'};
        #        $self->log( 'dev', "prepare query $query" );
        #$self->err(0);
        $self->{'sth'} = $self->{'dbh'}->prepare($query);
        #$self->log( 'dev', "prepare query = $self->{'sth'}" );
        #    }  } while ( $self->err_parse( \$query, $DBI::err, $DBI::errstr, 1 ) );
        #                   $self->log( 'dev', "PREPARE[$DBI::err,$DBI::errstr]{$query}($self->{'sth'})" );
        redo if $self->can_query() and $self->err_parse( \$query, $DBI::err, $DBI::errstr, 1 );
        #      $self->log( 'err', "SQLerror1[$DBI::err,$DBI::errstr]{$query}" ),
        #  do {    {
        #        if !$self->{'sth'}
        #        or $self->{'dbh'}->err;
        #      dbi_err_parse( \$query, $DBI::err, $DBI::errstr )
        #        if !$static{'sqlo'}{ sql_object() }{'sth'}->execute();#
        last unless $self->{'sth'};
        #$self->log( 'dev', "execute query " );
        $ret = $self->{'sth'}->execute();
        #$self->log( 'dev', "execute query=$ret" );
        #        $ret = 0 if $ret eq '0E0';
        #                $self->log( 'dev', "execute query=", $ret );
      }
    } while ( $self->can_query() and $self->err_parse( \$query, $DBI::err, $DBI::errstr ) );
    $self->query_time( $tim->() );
    #    ++$self->{'queries'};
    return 3 if $DBI::err;
    $self->{'dbirows'} = 0 if ( $self->{'dbirows'} = $DBI::rows ) == 4294967294;
    $self->{'dbirows'} = $self->{'limit'} if $self->{'no_dbirows'};
    #        $self->log('dr', $self->{'dbirows'}, $self->{'no_dbirows'}, $DBI::rows);
    #$self->log( 'dev', "PREPARERET[$DBI::err,$DBI::errstr]{$query}($self->{'sth'})==$ret($self->{'dbirows'});" );
    return !$ret;
  };
  $self->{'line'} ||= sub {
    #sub line {    #v1
    my $self = shift;
    #    print( 'dev', "line [",@_,"]" , join ':',(caller(2))[0]); # if (caller)[0] ne 'pssql';
    #psmisc::caller_trace();
    #print( 'dev', "line r1" ),
    return {} if @_ and $self->prepare(@_);
    return {} if !$self->{'sth'} or $self->{'sth'}->err;
    #$self->log( 'dev', "line r3 ", @_ );
    my $tim = psmisc::timer();
    local $_ =
      scalar( psmisc::cp_trans_hash( $self->{'codepage'}, $self->{'cp_out'}, ( $self->{'sth'}->fetchrow_hashref() || {} ) ) );
    $self->{'queries_time'} += $tim->();
    $self->log(
      'dmp', 'line:[', @_, '] = ', scalar keys %$_,
      ' per', psmisc::human( 'time_period', $tim->() ),
      'err=', $self->err(),
    ) if ( caller(2) )[0] ne 'pssql';
    return $_;
    #  return   ($self->{'sth'}->fetchrow_hashref() or {});
  };
  #printlog('dev', 'line=', $self->{'line'});
  $self->{'query'} ||= sub {
    #sub query {    #v0
    my $self = shift;
    #$self->log( 'dmp', "sql query [",@_,"]" );
    my $tim = psmisc::timer();
    my @hash;
    for my $query (@_) {
      #      $self->log( 'dev', "sql query0 [$query]" );
      next unless $query;
      #      $self->log( 'dev', "sql query1 [$query]" );
      local $self->{'explain'} = 0, $self->query_log( $self->{'EXPLAIN'} . ' ' . $query )
        if $self->{'explain'} and $self->{'EXPLAIN'};
      #      $self->log( 'dev', "sql query2 [$query]" );
      local $_ = $self->line($query);
      next unless keys %{$_};
      push( @hash, $_ );
      next unless $self->{'sth'} and keys %{$_};
      #$self->log( 'dev', "prefetch0" );
      #$self->log( 'dev', "prefetch1" ),
      my $tim = psmisc::timer();
      push( @hash, scalar psmisc::cp_trans_hash( $self->{'codepage'}, $self->{'cp_out'}, $_ ) )
        while ( $_ = $self->{'sth'}->fetchrow_hashref() );
      $self->{'queries_time'} += $tim->();
    }
    $self->log( 'dmp', 'query:[', @_, '] = ', scalar @hash, ' per', psmisc::human( 'time_period', $tim->() ),
      'err=', $self->err() );
    $self->{'dbirows'} = scalar @hash if $self->{'no_dbirows'} or $self->{'dbirows'} <= 0;
    #
    #    $self->log( 'dev', "sql query RET[",@hash,"]" );
    #        $self->query_print( [@hash] );
    return wantarray ? @hash : \@hash;
  };
  $self->{'query_log'} ||= sub {
    #sub query_log {    #v0
    my $self = shift;
    my @ret;
    for (@_) {
      #    my $tim = timer();
      #      my @hash = ( $self->query($_) );
      #      $self->query_print( \@hash );
      #;
      #      push( @ret, @hash );
      push( @ret, $self->query_print( $self->query($_) ) );
    }
    #  query_print(\@ret);
    return \@ret;
  };
  $self->{'query_print'} ||= sub {
    #sub query_print {    #v0
    my $self = shift;
    my @hash = @_;
    #$self->log(Dumper(\@_));
    #  my @ret;
    #  for (@_) {
    #    my $tim = timer();
    #    my @hash = ( $self->query($_) or next );
    #        $self->log( 'dev', "sql query print [", Dumper(\@hash),"]" );
    #        $self->log( 'err', "sql query print something wrong:", $hash[0]),    return if ref $hash[0] eq 'ARRAY';
    #        $self->log( 'dev', "sql query print 1", $hash[0]);
    #        $self->log( 'dev', "sql query print 1", @hash, %{ $hash[0] ||{} });
    return unless @hash and %{ $hash[0] };
    #        $self->log( 'dev', "sql query print 2" );
    $self->log( 'dbg', 'sql query', $_ );
    #        $self->log( 'dev', "sql query print 3" );
    $self->log( 'dbg', '|', join "\t|", keys %{ $hash[0] } ) if keys %{ $hash[0] };
    #        $self->log( 'dev', "sql query print 4" );
    #    for (@hash) {
    #        $self->log( 'dev', "sql query print 5", Dumper($_)     );
    #    $self->log( 'dbg', '|', join( "\t|", values %{$_} ) ) for @{$_};
    #    $self->log( 'dbg', '|', join( "\t|", values %{$_} ) );# for @{$_};
    #    }
    $self->log( 'dbg', '|', join( "\t|", values %{$_} ) ) for @hash;
    #    $self->log( 'time', 'query per', psmisc::human( 'time_period', $tim->() ) );
    #    push( @ret, @hash );
    #  }
    return wantarray ? @_ : \@_;    #\@hash;
  };
  $self->{'quote'} ||= sub {
    #sub quote {    #v0c02
    my $self = shift;
    my ( $s, $q, $qmask ) = @_;
    #$self->log( 'q',
    #print Dumper( $self->{'dbh'}->type_info());
    #    eval { return $self->{'dbh'}->quote(@_) if $self->{'dbh'} and !$q }
    return $s if $self->{'no_quote_null'} and $s =~ /^null$/i;
    return $self->{'dbh'}->quote( defined $s ? $s : '' ) if $self->{'dbh'} and !$q;
    #    return $self->{'dbh'}->quote($s, {NULLABLE=>0}) if $self->{'dbh'} and !$q;
    #    return $self->{'dbh'}->quote($s, $self->{'dbh'}->type_info( 'NULLABLE' => 0 )) if $self->{'dbh'} and !$q;
    #    return $self->{'dbh'}->quote($s, $self->{'dbh'}->type_info( 'NULLABLE' => 0 )) if $self->{'dbh'} and !$q;
    #    );
    #        $self->log( 'q', @_);
    #    $self->log( 'q1',@_);
    $q ||= "'";    # mask "|', q='
    if ( $self->{'quote_slash'} ) {
      $s =~ s/($q|\\)/\\$1/g;
      #    $self->log( 'q2',@_);
    } else {
      $s =~ s/($q)/$1$1/g;
      #    $self->log( 'q2',@_);
    }
    return $q . $s . $q;
  };
  $self->{'squotes'} ||= sub {
    #sub squotes {    #v0c1
    my $self = shift;
    return ' ' . $self->quote(@_) . ' ';
  };
  $self->{'tquote'} ||= sub {
    my $self = shift;
    return $self->{'tq'} . $_[0] . $self->{'tq'};
  };
  $self->{'rquote'} ||= sub {
    my $self = shift;
    return $self->{'rq'} . $_[0] . $self->{'rq'};
  };
  $self->{'vquote'}     ||= $self->{'quote'};
  $self->{'filter_row'} ||= sub {
    #sub filter_row {
    my $self = shift;
    my ( $table, $filter, $values ) = @_;
    local %_;
    map { $_{$_} = $values->{$_} } grep { $self->{'table'}{$table}{$_}{$filter} } keys %{ $self->{'table'}{$table} };
    return wantarray ? %_ : \%_;
  };
  $self->{'err_parse'} ||= sub {
    #sub err_parse {    #v1?
    my $self = shift;
    my ( $cmd, $err, $errstr, $sth ) = @_;
    $err    ||= $DBI::err;
    $errstr ||= $DBI::errstr;
    my $state = $self->{'dbh'}->state if $self->{'dbh'};
#        $self->log('devERRUN', $err,  $self->{'dbh'}->err,$errstr, $self->{'dbh'}->errstr, $self->{'dbh'}->state) if $self->{'dbh'};
    my $errtype = $self->error_type( $err, $errstr );
    $errtype ||= 'connection' unless $self->{'dbh'};
    $self->{'fatal'} = 1 if $errtype eq 'fatal';
#    $self->log('dev','error entry', $errtype, $err, $errstr, 'wdi=', $work{'die'}, 'di=', $self->{'die'}, 'fa=', $self->{'fatal'});

=c

ok
no dbi  ret1
install act ret1
repair  act ret1
syntax  ret0
fatal   ret0
ignore  ret0
other   ret1 n times

tries total
tries 

=cut

    #    {
    #  return 4 if $self->{'fatal'};
    #$config{'log_all'}=1,
    #caller_trace(),
    $self->log(
      'dev', "err_parse st0 ret1 ", 'wdi=', $work{'die'}, 'di=', $self->{'die'}, 'fa=', $self->{'fatal'}, 'er=',
      ( $self->{'errors'} >= $self->{'error_tries'} ), $self->{'errors'}, $self->{'error_tries'}
        #,'caller=', caller(2)
      , $errtype, $state
      ),
      CORE::sleep(1), return $self->err(1)
      if $work{'die'}
        or $self->{'die'}
        or $self->{'fatal'}
        or ( $self->{'errors'} > $self->{'error_tries'} )
        or ( $self->{'errors_chain'} > $self->{'error_chain_tries'} );
    #    or !$self->{'use_dbi'}
    #  $self->log( 'sql', "dbi_err_retry OK1", $work{'errors'}, $DBI::err ),
##  $self->sleep( $self->{'error_sleep'}, 'sql_retry' ),
    #    $self->{'force_retry'} = 0#, $_ (1)
    #    if $self->{'force_retry'};
    $self->log( 'err', 'err_parse: IMPOSIBLE! !$err and !$self->{sth}' ), $self->err(1), return 0
      if $sth and ( !$err and !$self->{'sth'} );
    #        $self->log( 'dev', "err_parse st1 ret0 no err", ),
    $self->{'errors_chain'} = 0, return $self->err(0) if !$err and $self->{'dbh'};    # and keys %{$self->{'dbh'}};
                                                                                      #  if ( !$self->{'dbh'} or $err ) {
                                                                                      #    $work{'sql_error'} ||= $err;
    ++$self->{'errors_chain'};
    ++$self->{'errors'};
    #    $self->log( 'dev', "err_parse st3 ret0 fatal CHk", $errtype, $err, $errstr);
    #                                                             $self->log( 'dev', "err_parse st3 ret0 fatal", ),
    $self->log( 'err',
      "SQL: error[$err,$errstr,$errtype,$state] on executing {$$cmd} [sleep:$self->{'error_sleep'}] dbh=[$self->{'dbh'}]" );
    $self->log( 'dev', "err_parse st3 ret0 fatal=$errtype" ), $self->err(1), return (0) if    #!$self->{'dbh'}
      $errtype and grep { $errtype eq $_ } qw(fatal syntax ignore);
#        ($err and grep( { $err eq $_ } ( @{ $self->{'err_fatal'} }, @{ $self->{'err_syntax'} }, @{ $self->{'err_ignore'} } ) )        );
    $self->log( 'dev', "err_parse sleep($self->{'error_sleep'}), ret1 ", );
    $self->sleep( $self->{'error_sleep'}, 'sql_parse' ) if $self->{'error_sleep'};
    #    $self->log( 'err', 'nodbh' ),
    $self->log( 'dev', "err_parse st3 ret1 fatal=$errtype" ), return $self->err(1) if         #!$self->{'dbh'}
      $errtype and grep { $errtype eq $_ } qw(retry);
    if (                                                                                      #$self->{'auto_install'}and
          #      ( grep { $err eq $_ } @{ $self->{'err_install_db'} } )
      $errtype eq 'install_db' and $self->{'auto_install_db'}-- > 0
      )
    {
      $self->log( 'info', "SQL: trying automatic install db" );
      $self->create_databases(@_);
      return $self->err(1);
    }
    $self->log( 'info', "SQL: trying reconnect[$self->{'connected'}]" ),
      #$self->dropconnect(),
      $self->reconnect(), return $self->err(1) if !$self->{'dbh'};    #!$self->{'in_connect'} and
                                                                      #    $self->sleep( $self->{'error_sleep'}, 'sql_parse' )
                                                                      #      if $self->{'error_sleep'};
                                                                      #install was here
    if (                                                              #$self->{'auto_install'}and
                                                                      #      ( grep { $err eq $_ } @{ $self->{'err_install'} } )
      $errtype eq 'install'
      )
    {
      if ( $self->{'auto_install'}-- > 0 ) {
        $self->log( 'dev', "SQL:install err " );
        #      if ( $self->{'auto_install'}-- > 0 ) {
        $self->log( 'info', "SQL: trying automatic install" );
        $self->install();
        #      $program{'install'}{'func'}->()
        #        if $program{'install'}{'func'};    #not in web! todo
        #todo      ++$self->{'force_retry'};              #?
        #      } else {
        #        $self->log( 'err', "SQL: automatic install failed or denied" );
        #        return 0;
        #      }
      }    # els
      else {
        $self->log( 'dev', "SQL:NOinstall err " );
        $self->err(1);
        return (0);
      }
    }
    #      last if    #(
    $self->log( 'err', "SQL: connection error, trying reconnect and retry last query" ),
      #  $self->{'in_disconnect'} = 1,
      #          $self->reconnect(),
      $self->dropconnect(), $self->reconnect(), return $self->err(1) if
      #      !$self->{'dbh'}       or
      #      grep { $err == $_ } @{ $self->{'err_connection'} }
      $errtype eq 'connection'
        #      )
    ;
    #    {
    #      $self->log( 'info', 'SQL:sleeped', $self->sleep( $self->{'reconnect_sleep'}, 'sql' ), ', trying to reconnect' );
    #TODO
    #     return $self->reconnect();
    #    }# els
    #    if ( grep $err eq $_, @{ $self->{'err_fatal'} } ) {
    #      $self->log( 'err', "SQL:Fatal error, disabling dbi" );
    #TODO
    #      $self->{'use_dbi'} = 0;
    #    return 0;
    #    } #els
    if (
      $self->{'auto_repair'}
      and
      #    ( grep $err eq $_, @{ $self->{'err_repair'} } )
      $errtype eq 'repair' and $self->{'auto_repairs'} < 2
      )
    {
      my $sl = int( rand( $self->{'auto_repair'} + 1 ) );
      $self->log( 'info', 'pre repair sleeping', $sl );
      $self->sleep($sl);
      if ( $sl == 0 or $self->{'force_repair'} ) {
        my ($repair) = $errstr =~ /'(?:.*[\\\/])*(\w+)(?:\.my\w)?'/i;
        $repair = $self->{'current_table'} unless %{ $self->{'table'}{$repair} or {} };
        $self->log( 'info', 'denied repair', $repair ), next
          if $self->{'auto_repair_selected'}
            and ( !$repair or $self->{'auto_repair_selected'} and $self->{'table_param'}{$repair}{'no_auto_repair'} );
        ++$self->{'auto_repairs'};
        $self->log( 'info', "SQL: trying automatic repair", $repair );
        #TODO
        #        $program{'repair'}{'func'}->($repair);
        $self->repair($repair);
        $self->{'rep_ext'} = $self->{'rep_frm'} = 1;
        $self->{'rep_quick'} = 0;
      }
    }
    $self->log( 'dev', "err_parse st2 ret1 no dbh", $err, $errstr ), return $self->err(1) if !$self->{'dbh'};
    #    }
    $self->log( 'dev', "err_parse unknown error ret($self->{'err_retry_unknown'}), end ", $err, $errstr, $errtype );
    #local $_ = 1;
    #todo COUNT check here
    #    ++$self->{'errors_chain'};
    #    ++$self->{'errors'};
    #$self->sleep( undef, 'sql_parse' ),;
    return $self->err( $self->{'err_retry_unknown'} );
    #  } else {
    #    $self->sleep( undef, 'sql_parse' ),;
    #  }
    #  return $err;
  };
  #  $self->{'do'}{'create_tables'} = 1;
  $self->{'install'} ||= sub {
    my $self = shift;
    return $self->create_databases(@_) + $self->create_tables();
  };
  $self->{'create_database'} ||= sub {    #http://dev.mysql.com/doc/refman/5.1/en/create-table.html
    my $self = shift;
    my $ret;
    #    $self->log( 'dev', 'CR database ',@_);
    local $_;
    local @_ = ( $self->{'database'} ) unless @_;
    $self->drh_init() if ( $self->{'use_drh'} );
    for my $db (@_) {
      if ( $self->{'use_drh'} ) {
        $ret += $_ = $self->{'drh'}->func( 'createdb', $db, $self->{'host'}, $self->{'user'}, $self->{'pass'}, 'admin' );
      } elsif ( $self->{'driver'} =~ /pg/i ) {
        {
          #        $self->log( 'dev', 'CR PG database ',@_);
          my $db = $self->{'dbname'};
          local $self->{'dbname'} = 'postgres';
          #undef;
          local $self->{'in_connect'} = undef;
          #$self->connect();
          #        $self->log( 'dev', 'CR PG database DO');
          $self->do("CREATE DATABASE $db WITH ENCODING $vq$self->{'cp'}$vq");
          #        $self->log( 'dev', 'CR PG database OK');
        }
        #$self->dropconnect(),
        $self->reconnect();
        #       $self->log( 'dev', 'CR PG reconnect OK');
      }
      $self->log( 'info', 'install database ', $db, '=', $ret );
    }
    return $ret;
  };
  $self->{'create_databases'} ||= sub {    #http://dev.mysql.com/doc/refman/5.1/en/create-table.html
    my $self = shift;
    return $self->create_database( $self->{'database'} );
  };
  $self->{'create_tables'} ||= sub {       #http://dev.mysql.com/doc/refman/5.1/en/create-table.html
    my $self = shift;
    #  my (%table) = @_;
    #  $self->dump();
    my (%table) = %{ $self->{'table'} or {} };
    my @ret;
    #  my ( $tq, $rq, $vq ) = sql_quotes();
    #    printlog('dev', Dumper(\%table));
    for my $tab ( sort keys %table ) {
      #      printlog('dev','t', $tab);
      push( @ret, $self->{'create_table'}->( $self, $tab, $table{$tab} ) );
      push( @ret, $self->{'create_index'}->( $self, $tab, $table{$tab} ) ) unless $self->{'index in create table'};
    }
    return @ret;
  };
  #  $self->{'do'}{'create_table'} = 1;
  $self->{'create_table'} ||= sub {    #http://dev.mysql.com/doc/refman/5.1/en/create-table.html
    my $self = shift;
    my ( $tab, $table ) = @_;
    my ( @subq, @ret );
    return undef if $tab =~ /^\W/;
    my ( @primary, %unique, %fulltext, @do );
    for my $row ( sort { $table->{$b}{'order'} <=> $table->{$a}{'order'} } keys %$table ) {
      push( @primary, $rq . $row . $rq ) if $table->{$row}{'primary'}
          #!and $self->{'driver'} ne 'sqlite'
      ;
      #      push( @unique, $rq . $row . $rq ) if $table->{$row}{'unique'};
      push( @{ $fulltext{ $table->{$row}{'fulltext'} } }, $rq . $row . $rq ) if $table->{$row}{'fulltext'};
      push( @{ $unique{ $table->{$row}{'unique'} } }, $rq . $row . $rq )
        if $table->{$row}{'unique'} and $table->{$row}{'unique'} =~ /\D/;
    }
    if ( $self->{'driver'} =~ /pg/i and $self->{'use_fulltext'} ) {
      #        $self->log('dev', 'ftdev',$tab,Dumper(\%fulltext),
      1 || $self->{'fulltext_trigger'}
        ? push(
        @do,
        "DROP TRIGGER $self->{'IF EXISTS'} ${tab}_update_$_ ON $tab",
        $self->{'old_fulltext'}
        ? ( "CREATE TRIGGER ${tab}_update_$_ BEFORE UPDATE OR INSERT ON $tab FOR EACH ROW EXECUTE PROCEDURE tsearch2($rq$_$rq, "
            . ( join( ', ', @{ $fulltext{$_} || [] } ) )
            . ")" )
        : (
"CREATE TRIGGER ${tab}_update_$_ BEFORE UPDATE OR INSERT ON $tab FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger($rq$_$rq, ${vq}$self->{'fulltext_config'}${vq}, "
            . ( join( ', ', @{ $fulltext{$_} || [] } ) )
            . ")" )
        )
        : (),
        #),
        $table->{$_} = { 'order' => -9999, 'type' => 'tsvector', } for keys %fulltext;
      #push(@do,"update pg_ts_cfg set locale = 'en_US.UTF-8' where ts_name = 'default'") ,
      #push(@do,"select set_curcfg('default');") if @do;
    }
    for my $row ( grep { keys %{ $table->{$_} } } keys %$table ) {
      $table->{$row}{'varchar'} = 1 if $table->{$row}{'type'} =~ /^varchar$/i;
    }
    for my $row ( sort { $table->{$b}{'order'} <=> $table->{$a}{'order'} } grep { keys %{ $table->{$_} } } keys %$table ) {
      next if $row =~ /^\W/;
$table->{$row}{'length'} = psmisc::min($self->{'varchar_max'}, $table->{$row}{'length'});
      my $length = $table->{$row}{'length'};
      if ( !defined $length ) {
        {
          my ( @types, @maxs, );
          push @types, 'primary'
            if $table->{$row}{'primary'} and $table->{$row}{'type'} =~ /char/i;
          push @types, 'fulltext' if $table->{$row}{'fulltext'};
          push @types, 'unique'   if $table->{$row}{'unique'};
          push( @types, 'varchar' ) if $table->{$row}{'varchar'};    #= 1 if $table->{$row}{'type'} =~ /^varchar$/i;
          last unless @types;
          #$self->log('dev',' ======= ', $row, ' length detect start', @types);
          for my $type (@types) {
            my $max;
            #$type = $types[0];
            $max = $self->{ $type . '_max' }; # if $type ne 'varchar';
            #$self->log('dev',"type $type start ", $row, " max=$max");
            $max /= 3 if $self->{'codepage'} eq 'utf-8' and $self->{'driver'} =~ /mysql/;
            #$max-=2;
            #$self->log('dev','lenmax:',$row,  "type=$type; max=$max, ", Dumper($table));
            my $same;
            my $nowtotal;
            for (
              grep {
                $_
                  #$table->{ $_ }{$type} and $_ ne $row
                  #and $table->{ $_ }{$type} eq $table->{ $row }{$type}
              } keys %{$table}
              )
            {
              $nowtotal += 2 if $type eq 'varchar' and $table->{$_}{'type'} =~ /^smallint$/i;
              $nowtotal += 4 if $type eq 'varchar' and $table->{$_}{'type'} =~ /^int$/i;
              $nowtotal += 8 if $type eq 'varchar' and $table->{$_}{'type'} =~ /^bigint$/i;
#          $self->log('dev', $row, 'look', $_, $type, $table->{ $_ }{$type} , $table->{ $_ }{'length'}, $table->{ $_ }{'type'});
              next unless $table->{$_}{$type} eq $table->{$row}{$type};
              next if !( $table->{$_}{$type} and $_ ne $row );
              #$self->log('dev', $row, 'minus', $_, $table->{ $_ }{'length'}),
              #$max -=  $table->{ $_ }{'length'};
              $nowtotal += $table->{$_}{'length'};
              ++$same,
                #$self->log('dev', $row, 'same', $_, $same),
                if !( $table->{$_}{'length'} );
            }
            $max -= $nowtotal;
            my $want = $max / ( $same + 1 );
    #$self->log('dev', $row, 'same',  $same, 'tot:', $nowtotal,);
#    $self->log('dev','len0:',$row,  "type=$type; max=$max, same=$same totalwo=$nowtotal want=$want  el=", scalar keys %$table);
            $nowtotal = 0;
            for (
              grep {
                      $table->{$_}{$type}
                  and $_ ne $row
                  and $table->{$_}{$type} eq $table->{$row}{$type}
                  and !$table->{$_}{'length'}
              } keys %{$table}
              )
            {
              --$same,
                #$max += $want - $table->{ $_ }{'length_max'} ,
                $max -= $table->{$_}{'length_max'}, $nowtotal += $table->{$_}{'length_max'},
#$self->log('dev','maxlen:',$row,  "look=$_ type=$type; max=$max, same=$same totalwo=$nowtotal want=$want lenmax=$table->{$_}{'length_max'} ret=",$want - $table->{ $_ }{'length_max'}),
                if $table->{$_}{'length_max'} and $table->{$_}{'length_max'} < $want;
            }
           # || $table->{ $_ }{'length_max'}
           #$self->log('dev', $row, 'same',  $same, 'tot:', $nowtotal);
           #$self->log('dev','len1:',$row,  "type=$type; max=$max, ");
           #$self->log('dev','lenpresame',$row,  "type=$type; max=$max, same=$same totalwo=$nowtotal el=", scalar keys %$table);
            $max /= $same + 1 if $same;
            $max = int($max);
            #$self->log('dev','tot:',$row, $nowtotal+(($same+1) * $max));
            #$self->log('dev','len:',$row,  "type=$type; max=$max, same=$same totalwo=$nowtotal el=", scalar keys %$table);
            #        $max /= ( scalar @primary or 1 ) if $table->{$row}{'primary'} and $table->{$row}{'primary'};
            #        $length /= ( scalar keys(%unique) + 1 ) if $table->{$row}{'unique'} and $table->{$row}{'unique'} =~ /\D/;
            push @maxs, $max;
          }
          push @maxs, $table->{$row}{'length_max'} if $table->{$row}{'length_max'};
          #$self->log('dev','maxs:', @maxs);
push @maxs, $self->{'varchar_max'} if $table->{$row}{'type'} =~ /^varchar$/i;
#print "mx:",@maxs;
          $length = psmisc::min(grep{$_>0}@maxs);
#          $table->{$row}{'length'} ||= $length if $table->{$row}{'type'} eq 'varchar';
          $table->{$row}{'length'} ||= $length;

=z
        $length ||= $self->{'primary_max'} if $table->{$row}{'primary'} and $table->{$row}{'type'} =~ /char/i;
        $length ||= $self->{'fulltext_max'} if $table->{$row}{'fulltext'};
        $length ||= $self->{'unique_max'}   if $table->{$row}{'unique'};
        $length ||= $self->{'varchar_max'}  if $table->{$row}{'type'} =~ /^varchar$/i;
        $self->log('dev', 'crelenbef',$row, $length, 'prim=', $table->{$row}{'primary'});
        my $maxl = $self->{'row_max'} / scalar keys %$table;    #todo better counting
#        my $maxl = $length / scalar keys %$table;    #todo better counting
        $self->log('dev', 'maxl',$row, $maxl);
        $length = $maxl if $length > $maxl;
        $length /= 3 if $self->{'codepage'} eq 'utf-8' and $self->{'driver'} =~ /mysql/;
        #$self->log('dev', 'crelen',$row, $length, scalar keys(%unique) +1);
        #        $self->log('dev', 'crelen',$row, $length, scalar @primary );
        $length /= ( scalar @primary or 1 ) if $table->{$row}{'primary'} and $table->{$row}{'primary'};
        $length /= ( scalar keys(%unique) + 1 ) if $table->{$row}{'unique'} and $table->{$row}{'unique'} =~ /\D/;
        #$length=int($length/(4));
        $self->log('dev', 'crelenaft',$row, $length);
=cut
          $length = int($length);
        }
      }
      #      printlog('dev', "$row NN= $table->{$row}{'not null'}");
      push(
        @subq,
        $rq 
          . $row 
          . $rq
          . " $table->{$row}{'type'} "
          #          . ( $table->{$row}{'length'} ? "($table->{$row}{'length'}) " : '' )
          . ( $length ? "($length) " : '' )
          . ( ( $table->{$row}{'unsigned'} and $self->{'UNSIGNED'} ) ? ' ' . $self->{'UNSIGNED'} : '' )
          . ( (
            #!S$self->{'driver'} ne 'sqlite' or
            !$table->{$row}{'auto_increment'}
          )
          #          ? ( ( $table->{$row}{'null'} ) ? ' NULL ' : ' NOT NULL ' )
          #? ( ( $table->{$row}{'null'} ) ? '' : ' NOT NULL ' )
          ? ( ( $table->{$row}{'not null'} ) ? ' NOT NULL ' : '' )
          : ''
          )
          . (
          ( defined( $table->{$row}{'default'} ) and !$table->{$row}{'auto_increment'} )
          ? " DEFAULT " . ( $table->{$row}{'default'} eq 'NULL' ? 'NULL' : "$vq$table->{$row}{'default'}$vq" ) . " "
          : ''
          )
          . ( ( $table->{$row}{'unique'} and $table->{$row}{'unique'} =~ /^\d+$/ ) ? ' UNIQUE ' : '' )
          #.( ( $self->{'driver'} eq '!Ssqlite' and $table->{$row}{'primary'} ) ? ' PRIMARY KEY ' : '' )
          . ( (
            $table->{$row}{'auto_increment'} and (
              #TEST S! $self->{'driver'} ne '!Ssqlite' or
              $table->{$row}{'primary'}
            )
          )
          ? ' '
            . $self->{'AUTO_INCREMENT'} . ' '
          : ''
          )
          . "$table->{$row}{'param'}"
      );
    }
    #iwh
    push( @subq, "PRIMARY KEY (" . join( ',', @primary ) . ")" ) if @primary;
    for my $row ( sort { $table->{$b}{'order'} <=> $table->{$a}{'order'} } keys %$table ) {
      push(
        @subq,
        "INDEX " 
          . $rq 
          . $row 
          . $self->{'index_postfix'} 
          . $rq . " (" 
          . $rq 
          . $row 
          . $rq
          . (
          ( $table->{$row}{'index'} > 1 and $table->{$row}{'index'} < $table->{$row}{'length'} )
          ? '(' . $table->{$row}{'index'} . ')'
          : ''
          )
          . ")"
      ) if $table->{$row}{'index'} and $self->{'index in create table'};

=c
      push(
        @subq,
        "INDEX UNIQUE" 
          . $rq 
          . $row 
          . $self->{'index_postfix'} . 'u'
          . $rq . " (" 
          . $rq 
          . $row 
          . $rq
          . ")"
        )
        if $table->{$row}{'unique'}
        and $self->{'index in create table'};
=cut

      push( @primary, $rq . $row . $rq ) if $table->{$row}{'primary'};
    }
    push( @subq, "UNIQUE " . ( $self->{'unique name'} ? $rq . $_ . $rq : '' ) . "  (" . join( ',', @{ $unique{$_} } ) . ")" )
      for grep @{ $unique{$_} }, keys %unique;
    if ( $self->{'index in create table'} ) {
      push( @subq, "FULLTEXT $rq$_$rq (" . join( ',', @{ $fulltext{$_} } ) . ")" ) for grep @{ $fulltext{$_} }, keys %fulltext;
  #      push( @subq, "UNIQUE $rq$_$rq  (" . join( ',',  @{ $unique{$_} } ) . ")" )   for grep @{ $unique{$_} },   keys %unique;
    }
    #    push(
    #      @ret,
    return map { $self->do($_) }
      grep     { $_ } (
      !@subq
      ? ()
      : 'CREATE TABLE '
        . $self->{'IF NOT EXISTS'}
        . " $tq$self->{'table_prefix'}$tab$tq ("
        . join( ",", @subq )
        . ( join ' ', '', grep { $_ } $self->{'table_constraint'}, $self->{'table_param'}{$tab}{'table_constraint'} ) . ") "
        . $self->{'table options'} . ' '
        . $self->{'table_param'}{$tab}{'table options'}
        . ( $self->{'cp'} and $self->{'DEFAULT CHARACTER SET'} ? " $self->{'DEFAULT CHARACTER SET'} $vq$self->{'cp'}$vq " : '' )
        . ';'
      ), @do;
    #    return undef;
  };
  #  $self->{'do'}{'create_index'} = 1;
  $self->{'create_index'} ||= sub {
    #sub create_index {
    my $self = shift;
    my @ret;
    my ( $tab, $table ) = @_;
    #  for my $table( @_){
    #  for my $tab ( keys %$table ) {
    my (@subq);
    #    next if $tab =~ /^\W/;
    for my $row ( sort { $table->{$b}{'order'} <=> $table->{$a}{'order'} } keys %$table ) {
      next if $row =~ /^\W/;
      push( @ret,
            'CREATE INDEX '
          . $self->{'IF NOT EXISTS'} . ' '
          . $rq
          . $row . '_'
          . $tab
          . $self->{'index_postfix'}
          . $rq . ' ON '
          . " $tq$self->{'table_prefix'}$tab$tq ( $rq$row$rq )" )
        if $table->{$row}{'index'};
    }
    #  }
    return $self->do(@ret);
  };
  #  $self->{'do'}{'drop_table'} = 1;
  $self->{'drop_table'} ||= sub {
    #sub drop_table {
    my $self = shift;
    my @ret;
    for my $tab (@_) {
      my ($sql);
      next if $tab =~ /^\W/ or $tab !~ /\w/;
      $sql .= "DROP TABLE " . $self->{'IF EXISTS'} . " $tq$self->{'table_prefix'}$tab$tq $self->{'CASCADE'}";
      push( @ret, $sql );
    }
    return $self->do(@ret);
  };
  $self->{'drop_database'} ||= sub {
    #sub drop_table {
    my $self = shift;
    my @ret;
    @_ = $self->{'database'} if !@_;
    my $rec = 1 if $self->{'driver'} =~ /pg/i and grep { $self->{'database'} eq $_ } @_;
    if ($rec) {
      #$self->log('dev','tryreconnect', $self->{'connected'});
      local $self->{'dbname'}   = undef;
      local $self->{'database'} = undef;
      $self->{'dbname'} = $self->{'database'} = 'postgres' if $self->{'driver'} =~ /pg/i;    #TODO MYSQL
                                                                                             # $self->dropconnect();
      $self->reconnect();
    }
    for my $tab (@_) {
      my ($sql);
      next if $tab =~ /^\W/ or $tab !~ /\w/;
      $sql .= "DROP DATABASE " . $self->{'IF EXISTS'} . " $tq$self->{'table_prefix'}$tab$tq";
      push( @ret, $sql );
    }
    @ret = $self->do(@ret);
    if ($rec) { $self->reconnect(); }
    return @ret;
  };
  $self->{'drop_tables'} ||= sub {
    my $self = shift;
    @_ = keys %{ $self->{'table'} or {} } if !@_;
    return $self->drop_table(@_);
  };
  #  {
  #    my (%buffer);
  #  $processor{'out'}{'array'} ||= sub {
  $self->{'insert_fields'} ||= sub {
    my $self = shift;
    my $table = shift || $self->{'current_table'};
    return grep {
      $self->{'table'}{$table}{$_}{'array_insert'}
        #or !defined $self->{'table'}{$table}{$_}{'default'}
    } keys %{ $self->{'table'}{$table} };
  };
  $self->{'insert_order'} ||= sub {
    my $self = shift;
    my $table = shift || $self->{'current_table'};
    return sort { $self->{'table'}{$table}{$b}{'order'} <=> $self->{'table'}{$table}{$a}{'order'} } $self->insert_fields($table)
      #                 grep { $self->{'table'}{$table}{$_}{'array_insert'} or !defined $self->{'table'}{$table}{$_}{'default'}
      #} keys %{ $self->{'table'}{$table} }
  };
  $self->{'insert_cached'} ||= sub {
    my $self = shift;
    #        $self->log('dev','insert_cached', Dumper(\@_));
    my $table = shift || $self->{'current_table'};
    my @dummy;
    #    my ( $tq, $rq, $vq ) = sql_quotes();
    ++$self->{'table_updated'}{$table};
    ++$self->{'inserts'};
    push( @{ $self->{'insert_buffer'}{$table} }, \@_ ) if $table and scalar @_;
    for my $table ( $table ? ($table) : ( keys %{ $self->{'insert_buffer'} } ) ) {
      $self->{'insert_block'}{$table} = ( $self->{'table_param'}{$table}{'insert_by'} or $self->{'insert_by'} )
        unless defined $self->{'insert_block'}{$table};
      #printlog('ict', $table,int(time() - $self->{'insert_buffer_time'}{$table}));
      #$self->{'insert_buffer_time'}{$table}||=time();
      if (
        $self->{'insert_block'}{$table}-- <= 1
        or !scalar(@_)
        #or time() - $self->{'insert_buffer_time'}{$table} > $self->{'insert_cached_time'}
        or time() - ( $self->{'insert_buffer_time'}{$table} ||= time() ) > $self->{'insert_cached_time'}
        )
      {
        $self->{'insert_buffer_time'}{$table} = time();
        $self->{'current_table'} = $table;
        #printlog('iciii', $table);
        $self->do(
          join(
            '',
            ( $self->{'ON DUPLICATE KEY UPDATE'} ? $self->{'INSERT'} : $self->{'REPLACE'} )
              . " $self->{$self->{'insert_options'}} INTO $tq$self->{'table_prefix'}$table$tq (",
            join( ',', map { $rq . $_ . $rq } $self->insert_order($table) ),
            ") VALUES\n",
            join(
              ",\n",
              map {
                join(
                  '', '(',
                  join(
                    ',',
#                    map { $self->quote( scalar cp_trans( $self->{'cp_in'}, $self->{'codepage'}, $$_ ), $self->{'value quote'} ) }
                    map { $self->quote( scalar cp_trans( $self->{'cp_in'}, $self->{'codepage'}, $$_ ) ) }
                      @{$_}[ 0 .. scalar( $self->insert_fields($table) ) - 1 ],
                    @dummy =
                      ( map { \$self->{'table'}{$table}{$_}{'default'} } $self->insert_order($table) )
                      [ scalar( @{$_} ) .. scalar( $self->insert_fields($table) ) - 1 ]
                  ),
                  ')'
                  )
                } @{ $self->{'insert_buffer'}{$table} }
            ), (
              !$self->{'ON DUPLICATE KEY UPDATE'} ? '' : " \n" . $self->{'ON DUPLICATE KEY UPDATE'} . ' ' . join(
                ',',
                map {
                  $rq . $_ . $rq . '=VALUES(' . $rq . $_ . $rq . ')'
                  } sort {
                  $self->{'table'}{$table}{$b}{'order'} <=> $self->{'table'}{$table}{$a}{'order'}
                  } grep {
                  $self->{'table'}{$table}{$_}{'array_insert'}
                    and !$self->{'table'}{$table}{$_}{'no_insert_update'}
                    and !$self->{'table'}{$table}{$_}{'added'}
                  } keys %{ $self->{'table'}{$table} }
              )
            ),
            ';'
          )
          ),
          delete $self->{'insert_buffer'}{$table}
          if $self->{'insert_buffer'}{$table} and scalar @{ $self->{'insert_buffer'}{$table} };
        $self->{'insert_block'}{$table} = $self->{'table_param'}{$table}{'insert_by'} || $self->{'insert_by'};
      }
    }
    #$self->log('dev', 'insert:',@{ $buffer{$table} });
    return undef;
  };
  #  }
  #  $self->{'flush'} ||= $self->{'insert'};
  $self->{'flush_insert'} ||= sub {
    my $self = shift;
    $self->insert_cached(@_);
    #pg tsearch
    #      push( @{ $fulltext{ $table->{$row}{'fulltext'} } }, $rq . $row . $rq ) if $table->{$row}{'fulltext'};
    if ( 0 and $self->{'driver'} =~ /pg/i and $self->{'use_fulltext'} ) {
      for my $tablen ( grep { $_ and $self->{'table_updated'}{$_} } keys %{ $self->{'table_updated'} || {} } ) {
        my $table = $self->{'table'}{$tablen};
        my (%fulltext);
        for my $row ( sort { $table->{$b}{'order'} <=> $table->{$a}{'order'} } keys %$table ) {
          push( @{ $fulltext{ $table->{$row}{'fulltext'} } }, $rq . $row . $rq ) if $table->{$row}{'fulltext'};
        }
        my @do;
        #local @_ = map {$self->rquote($_)}grep {$table->{$_}{'fulltext'}} keys %{%$table || {}} or next;
        push @do,
          "SELECT tsvector_update_trigger($rq$_$rq, ${vq}$self->{'fulltext_config'}${vq}, "
          . ( join( ', ', @{ $fulltext{$_} || [] } ) )
          . ") FROM $tq$tablen$tq"
          for keys %fulltext;
        #              $self->log('dev', 'ftup',$self->{'table_updated'}{$table},$table, $do);
        $self->do(@do);
        $self->{'table_updated'}{$tablen} = 0;
      }
    }
  };
  $self->{'insert'} ||= sub {
    my $self = shift;
    my @ret  = $self->insert_cached(@_);
    $self->flush_insert( $_[0] ) if scalar @_ > 1;
    return @ret;
  };
  $self->{'update'} ||= sub {
    my $self = shift;
    my $table = ( shift or $self->{'current_table'} );
    #sub update {    #v5
    #  my $self = shift;
    my ( $by, $values, $where, $set, $setignore, $whereignore ) = @_;
    #        $self->log('dev','sql_update:', join ':',@_, "PREUPVAL=",%{$values} );
    #        $self->log('dev','sql_update:', "[$set],[$setignore]" );
    return unless %{ $self->{'table'}{$table} or {} };
    $self->{'current_table'} = $table;
    #  my ( $tq, $rq, $vq ) = sql_quotes();
    #    printlog('dev','HIRUN', $table, $self->{'handler_insert'} ,
    $self->{'handler_insert'}->( $table, $values ) if ref $self->{'handler_insert'} eq 'CODE';
    $self->stem_insert( $table, $values );
    #    $self->{'handler_insert'}->( $table, \%{$values} ) if $self->{'handler_insert'};
    local $self->{'handler_insert'} = undef;
    local $self->{'stem_insert'} = sub { };
    local @_;
    $by ||= [
      grep { $self->{'table'}{$table}{$_}{'primary'} or $self->{'table'}{$table}{$_}{'unique'} }
        keys %{ $self->{'table'}{$table} || {} }
    ];
    my $bymask = '^(' . join( ')|(', @$by ) . ')$';
    my $bywhere = join(
      ' AND ',
      map ( "$rq$_$rq=" . $self->quote( $values->{$_} ),
        grep {
          %{ $self->{'table'}{$table}{$_} || {} }
            and ( $self->{'table'}{$table}{$_}{'primary'}
            or $self->{'table'}{$table}{$_}{'unique'} )
            and $self->{'table'}{$table}{$_}{'type'} ne 'serial'    #todo mysql
          } @$by )
    );
    $set ||= join(
      ', ', (
        map {
          #$self->log('dev','sql_update:', "[$_:$values->{$_}]" );
          $rq . $_ . $rq . "=" . $self->quote(
            $self->cut( $values->{$_}, $self->{'table'}{$table}{$_}{'length'} )
              #              $values->{$_}
            )
          } (
          @_ = grep( ( ( $_ !~ $bymask ) and $_ and %{ $self->{'table'}{$table}{$_} || {} } and defined( $values->{$_} ) ),
            keys %$values ), (
            @_ ? () : grep {
              $_ and %{ $self->{'table'}{$table}{$_} or {} } and defined( $values->{$_} )
              } keys %$values
          )
          )
      )
    );
    $set = 'SET ' . $set if $set;
    my $lwhere = $where;
    $where = '' if $where eq 1;
    $where = ' AND ' . $where if $where and $bywhere;
    $whereignore = ' AND ' . $whereignore if $whereignore and ( $where or $bywhere );
    local $_;
    #    $processor{'out'}{'sql'}
    $_ =
      $self->do(
      "UPDATE $self->{'IGNORE'} $tq$self->{'table_prefix'}$table$tq $set $setignore WHERE $bywhere $where $whereignore")
      if ( $set or $lwhere or !$self->{'ON DUPLICATE KEY UPDATE'} )
      and ( $bywhere or $where or $whereignore );
#    $self->log( 'dev', "WHERE[" . $where . "] BYwhere[" . $bywhere . "] whereignore[$whereignore] ",      " UPVAL=", %{$values}, "UPSET=", $set, "RES[$_]" );
#  $processor{'out'}{'hash'}->
#    $self->hash($table, { '' => $values } ),    #$processor{'out'}{'array'}->($table)
#    $self->log( 'dev',"insert_hash run? ", "( !$set or !int($_) ) and !$where");
#    $self->log( 'dev',"insert_hash run "),
    $self->insert_data( $table, $values ),    #$processor{'out'}{'array'}->($table)
      $self->flush_insert($table) if ( !$set or !int($_) ) and !$lwhere;
    return undef;
  };
  $self->{'insert_hash'} ||= sub {
    my $self = shift;
    return $self->insert_data(@_) unless $self->{'driver'} =~ /pg/i;
    my $table = shift || $self->{'current_table'};
    my $ret;
    for (@_) {
      #    $self->log( 'dev',"insert_hash run "),
      $ret += $self->update( $table, undef, $_ );
    }
    return $ret;
  };
  #=z
  $self->{'cut'} ||= sub {
    my $self = shift;
    return $_[0] unless $_[1];
    return $_[0] = substr( $_[0], 0, $_[1] - ( ( $self->{'codepage'} eq 'utf-8' and $self->{'driver'} =~ /mysql/ ) ? 2 : 0 ) ),
      ( $self->{'codepage'} eq 'utf-8' ? $_[0] =~ s/[\xD0\xD1]+$// : () );
  };
  #=cut
  $self->{'insert_data'} ||= sub {
    my $self = shift;
    #                  $self->log('dmp','insertdata=',Dumper(\@_));
    my $table = ( shift or $self->{'current_table'} );    #or $self->{'tfile'}
                                                          #$self->log('dev','hash!', $table);
                                                          #$processor{'out'}{'hash'} ||= sub {
                                                          #  my $self = shift;
                                                          #  my $table = ( shift or $self->{'tfile'} );
    for my $hash (@_) {
      #                 $self->log('dev','hash1=',Dumper($hash));
      #      for my $col ( keys %$hash ) {
      #$self->log('dev','hash col',$col );
      #$self->log('dev','hash col2',$col , $hash->{$col}{'path'});
      #$self->log('dev','hash col2',$col , $hash->{$col}{'path'});
      next if !$hash;
      #                 $self->log('dev',"def for $_", $self->{'table'}{$table}{$_}{'array_insert'}),
      #                       $self->log('dev',"hash[$hash]",Dumper($hash) ) if ref $hash eq 'REF';
      $hash->{$_} = (
        $self->{'table'}{$table}{$_}{'default_insert'}
          or ( $self->{'table'}{$table}{$_}{'array_insert'} ? $self->{'table'}{$table}{$_}{'default'} : undef )
        ),
        #$self->log('dev','hash def',$_, $hash->{$_}),
        for grep { !defined $hash->{$_} }    #$self->{'table'}{ $table }{$_}{'array_insert'} and
        keys %{ $self->{'table'}{$table} };
#$self->log('dev','hash next insert_min', $hash->{$col}, grep { $self->{'table'}{$table}{$_}{'insert_min'} and $hash->{$_} }          keys %{ $self->{'table'}{$table} }),
#      $self->log('dev','hash2=',Dumper($hash),
#      grep { $self->{'table'}{$table}{$_}{'insert_min'} and !$hash->{$_} } keys %{ $self->{'table'}{$table} }
#      ),
#$self->log('dev','SKIP'),
      next if                                #!$hash->{$col}
            #          and !(grep { $self->{'table'}{$table}{$_}{'insert_min'} } keys %{ $self->{'table'}{$table} })
            #          or
        grep { $self->{'table'}{$table}{$_}{'insert_min'} and !$hash->{$_} } keys %{ $self->{'table'}{$table} };
      #$self->log('dev','hash1');
#########not here
      $self->handler_insert0( $table, $hash );
      #        if $self->{'handler_insert0'};
#########not here
#      $self->log('dev','hash3=',Dumper($hash));
#      ( $self->{'filter_handler'} ? $self->{'filter_handler'}->($hash) : () ), next
#        if grep { $self->{'table'}{$table}{$_}{'skip_mask'} and $hash->{$_} =~ /$self->{'table'}{ $table }{$_}{'skip_mask'}/i }
#          keys %{ $self->{'table'}{$table} };
      next
        if ref $self->{'table_param'}{$table}{'filter'} eq 'CODE'
          and $self->{'table_param'}{$table}{'filter'}->( $self, $hash );
      #      $self->handler_insert( $table, $hash );
      $self->handler_insert( $table, $hash );    # if $self->{'handler_insert'};
      $self->stem_insert( $table, $hash );
      #      $self->log('dev',"lenCUT[$hash->{$_}]"),
      $self->cut( $hash->{$_}, $self->{'table'}{$table}{$_}{'length'} )
#      $hash->{$_} = substr( $hash->{$_}, 0, $self->{'table'}{$table}{$_}{'length'} - ( $self->{'codepage'} eq 'utf-8' ? 2 : 0 ) ),($self->{'codepage'} eq 'utf-8' ? $hash->{$_} =~ s/[\xD0\xD1]+$// : ()),
#      $self->log('dev',"lenCUT[$self->{'codepage'}][$hash->{$_}]"),
        for grep {
              ( $self->{'table'}{$table}{$_}{'type'} eq $self->{'char_type'} )
          and $self->{'table'}{$table}{$_}{'length'}
          and length( $hash->{$_} ) >
          ( $self->{'table'}{$table}{$_}{'length'} )
        } keys %{ $self->{'table'}{$table} };
      #      $processor{'out'}{'array'}->
      #      $self->log('dev','ic from here=');
      local $self->{'table'}{$table} = $self->{'table'}{$table};
      #printlog('dev', $self->{'table'}{$table});
      my $chanded;
      #      printlog('dev', 'set array_insert', $table, $_, ),
      (
        ++$chanded == 1
        ? (
          #printlog('dev', 'flush on change', $table, $_),
          $self->flush_insert($table)
          )
        : ()
        ),
        $self->{'table'}{$table}{$_}{'array_insert'} = 1
        for grep {
        defined $hash->{$_}
          and length $hash->{$_}
          #and ($hash->{$_} ne $self->{'table'}{$table}{$_}{'default'} )
          and keys %{ $self->{'table'}{$table}{$_} } and !$self->{'table'}{$table}{$_}{'array_insert'}
        } keys %{ $self->{'table'}{$table} };
      #                  $self->log('dmp','insertdata2=',Dumper(\@_));
      $self->insert_cached(
        $table,
        \@{$hash}{
          $self->insert_order($table)
            #          sort   { $self->{'table'}{$table}{$b}{'order'} <=> $self->{'table'}{$table}{$a}{'order'} }
            #            grep { $self->{'table'}{$table}{$_}{'array_insert'} } keys %{ $self->{'table'}{$table} }
          }
      );
#########not here
      $self->handler_insert2( $table, $hash );
#########not here
    }
    #    }
    return undef;
  };
  $self->{'insert_hash_hash'} ||= sub {
    my $self  = shift;
    my $table = ( shift or $self->{'current_table'} );    #or $self->{'tfile'}
                                                          #$self->log('dev','hash!', $table);
                                                          #$processor{'out'}{'hash'} ||= sub {
                                                          #  my $self = shift;
                                                          #  my $table = ( shift or $self->{'tfile'} );
    for my $hash (@_) {
      $self->insert_hash( $table, values %$hash );
      #$self->log('dev','hash=',$hash);
      #      for my $col ( keys %$hash ) {
      #$self->log('dev','hash col',$col );
      #$self->log('dev','hash col2',$col , $hash->{$col}{'path'});
      #$self->log('dev','hash col2',$col , $hash->{$col}{'path'});
      #      $self->hash($table, $hash->{$col});
      #    }
    }

=c
        $hash->{$col}{$_} = $self->{'table'}{$table}{$_}{'default'},
#$self->log('dev','hash def',$_, $hash->{$col}{$_}),
          for grep { !$hash->{$col}{$_} }    #$self->{'table'}{ $table }{$_}{'array_insert'} and
           keys %{ $self->{'table'}{$table} };
#$self->log('dev','hash next insert_min', $hash->{$col}, grep { $self->{'table'}{$table}{$_}{'insert_min'} and $hash->{$col}{$_} }          keys %{ $self->{'table'}{$table} }),
        next
          if !$hash->{$col}
#          and !(grep { $self->{'table'}{$table}{$_}{'insert_min'} } keys %{ $self->{'table'}{$table} })
          or grep { $self->{'table'}{$table}{$_}{'insert_min'} and !$hash->{$col}{$_} }
          keys %{ $self->{'table'}{$table} };
#$self->log('dev','hash1');
#########not here
        if ( $table eq $self->{'tfile'} ) {    #TODO CONFIGURABLE

=old
        if (  !$self->{'use_dbi'}
          and $work{'current_output_file'} ne $hash->{$_}{'host'}
          and $hash->{$col}{'host'} )
        {
          $work{'current_output_file'} = $hash->{$col}{'host'};
          open_out_file( $work{'current_output_file'} );
        }
#=cut
          if ( $hash->{$col}{'size'} ) {
            ++$stat{'files'};
            $stat{'size'} += $hash->{$col}{'size'}
              if $hash->{$col}{'size'} < $self->{'max_stat_file_size'};
          } else {
            ++$stat{'dirs'};
          }
        }
#########not here
        (
            $self->{'filter_handler'}
          ? $self->{'filter_handler'}->( $hash->{$col} )
          : ()
          ),
          next
          if grep {
                $self->{'table'}{$table}{$_}{'skip_mask'}
            and $hash->{$col}{$_} =~ /$self->{'table'}{ $table }{$_}{'skip_mask'}/i
          }
          keys %{ $self->{'table'}{$table} };
        $self->{'handler_insert'}->( $table, \%{ $hash->{$col} } )
          if $self->{'handler_insert'};
        $hash->{$col}{$_} =
          substr( $hash->{$col}{$_}, 0, $self->{'table'}{$table}{$_}{'length'} - ( $self->{'codepage'} eq 'utf-8' ? 2 : 0 ) )
          for grep {
                ( $self->{'table'}{$table}{$_}{'type'} eq $self->{'char_type'} )
            and $self->{'table'}{$table}{$_}{'length'}
            and length( $hash->{$col}{$_} ) >
            ( $self->{'table'}{$table}{$_}{'length'} )
          }
          keys %{ $self->{'table'}{$table} };
        #      $processor{'out'}{'array'}->
        $self->cmd(
          'insert', $table,
          \@{ $hash->{$col} }{
            sort   { $self->{'table'}{$table}{$b}{'order'} <=> $self->{'table'}{$table}{$a}{'order'} }
              grep { $self->{'table'}{$table}{$_}{'array_insert'} }
              keys %{ $self->{'table'}{$table} }
            }
        );
#########not here
        $work{'upscanned'} = counter( $stat{'files'} ) unless $work{'upscanned'};
        if (  $work{'filec'}
          and $work{'filec'}->( $stat{'files'} )
          and $work{'upscanned'}->( $stat{'files'} ) > $self->{'update_scan_every'} )
        {
          $work{'upscanned'} = counter( $stat{'files'} );
          my ($values) = values(%$hash);
          #        sql_update(
          $self->cmd(
            'update',
            $self->{'tresource'},
            undef, {
              $self->filter_row( $self->{'tresource'}, 'primary', $values ),
              'path' => '',
              'scan' => int( time() ),
              'time' => int( time() )
            }
          );
          #!!! TODO < BUG !!!
          $self->cmd(
            'update',
            #        sql_update(
            $self->{'tresource'},
            undef, {
              $self->filter_row( $self->{'tresource'}, 'primary', $values ),
              'path'  => '',
              'files' => $work{'filec'}->( $stat{'files'} ),
              'dirs'  => $work{'dirc'}->( $stat{'dirs'} ),
              'size'  => $work{'sizec'}->( $stat{'size'} )
            },
            '`files` < \'' . $work{'filec'}->( $stat{'files'} ) . "'"
          );
          my $h = split_url( $values->{'host'} )->{'host'};
          $self->cmd(
            'update',
            #        sql_update(
            $self->{'thost'},
            undef, {
              $self->filter_row( $self->{'thost'}, 'primary', $values ),
              'host' => $h,
              'ip'   => ip_to_name($h),
              'scan' => int( time() ),
              'time' => int( time() )
            }
          );
        }
#########not here
      }
    }
=cut

    return undef;
  };
  $self->{'where_body'} ||= sub {
    #      my $self  = shift;
    #      my $table = (shift or $self->{'tfile'} or $self->{'current_table'});
    #sub where_body {
    my $self = shift;
    my ( $param_orig, $param_num, $table, $after ) = @_;
    my $param = { %{ $param_orig || {} } };
    #    my $param = $param_orig;
    $table ||= $self->{'current_table'};
    my ( $search_str_add, $ask, $close );
    #        $self->log('dev', 'where_body', 1, $table, %$param, $self->{'current_table'});
    my $questions = 0;
    map ++$questions, grep defined( $param->{ $_ . $param_num } ),
      @{ $config{'user_param_founded'} || [ 'q', keys %{ $self->{'table'}{$table} } ] };
    #        $self->log('dev', 'recstop' , $param_num),
    return if ( $param_num and !$questions ) or ++$self->{'rec_stop'} > 20;
    my $first      = 1;
    my $local_cond = 0;
    #  my ( $tq, $rq, $vq ) = sql_quotes();
    #    $self->log('dev', 'where_body', 1.1, $param->{ 'q' . $param_num });
    while ( defined( $param->{ 'q' . $param_num } ) and $param->{ 'q' . $param_num } =~ s/(\w+\S?[=:](?:".+?"|\S+))// ) {
      #    $self->log('dev', 'where_body', 1.2, $param->{ 'q' . $param_num }, $1);
      #    $self->log('dev', 'where_body selected', $1);
      #$self->log('dev', 'where_body selected',
      #      get_params_one( $param, $1 );
      local $_ = $1;
      s/^(\S+):/$1=/;
      my $lparam = get_params_one( undef, $_ );
      $lparam->{$_} =~ s/^"|"$//g, $param->{$_} = $lparam->{$_} for keys %$lparam;
      #      $self->log('dev', 'where_body selected', $1,  %$param); #%$lparam,
    }
    #    $self->log('dev', 'where_body', 2);
    for my $preset ( $param->{ 'q' . $param_num } =~ /:(\S+)/g ) {
      for my $sets ( keys %{ $config{'preset'} } ) {
        if ( $config{'preset'}{$sets}{$preset} ) {
          $param->{ 'q' . $param_num } =~ s/:$preset//;
          for ( keys %{ $config{'preset'}{$sets}{$preset}{'set'} } ) {
            $param->{ $_ . $param_num } .=
              ( $param->{ $_ . $param_num } ? ' ' : '' ) . $config{'preset'}{$sets}{$preset}{'set'}{$_};
          }
        }
      }
    }
    my $search_str = $param->{ 'q' . $param_num };
    #        $self->log( 'dev', 'where_body', 3, $search_str, $param_num );
    my $glueg = $param->{ 'glueg' . $param_num } eq 'or' ? ' OR ' : ' AND ';
    my $gluel = $param->{ 'gluel' . $param_num } eq 'or' ? ' OR ' : ' AND ';
    $glueg = ' XOR ' if $self->{'enable_xor_query'} and $param->{ 'glueg' . $param_num } eq 'xor';
    $gluel = ' XOR ' if $self->{'enable_xor_query'} and $param->{ 'gluel' . $param_num } eq 'xor';
    if ( my ($days) = $param->{ 'search_days' . $param_num } =~ /(\d+)/ and $1 and %{ $self->{'table'}{$table}{'time'} or {} } )
    {
      $ask .= " $tq$self->{'table_prefix'}$table$tq.$rq" . "time$rq ";
      if   ( $param->{ 'search_days_mode' . $param_num } eq 'l' ) { $ask .= '<'; }
      else                                                        { $ask .= '>'; }
      $days = int( time() ) - $days * 24 * 60 * 60;
      $ask .= '=' . $self->squotes($days);
    }
    #printlog('dev', 'online1', Dumper($param));
    if ( !$self->{'no_online'} and defined( $param->{ 'online' . $param_num } ) ) {
      if ( $param->{ 'online' . $param_num } eq 'on' ) { $param->{ 'online' . $param_num } = $config{'online_minutes'}; }
      #printlog('dev', 'online2', Dumper($param));
      if ( $param->{ 'online' . $param_num } > 0 ) {
        $param->{ 'live' . $param_num } = int( time() ) + $self->{'timediff'} - int( $param->{ 'online' . $param_num } ) * 60;
        $param->{ 'live_mode' . $param_num } = 'g';
        #printlog('dev', $param->{ 'live' . $param_num });
      }
    }
    if (
          $self->{'path_complete'}
      and $param->{ 'path' . $param_num }
      and !( $param->{ 'path' . $param_num } =~ /^[ !\/\*]/ )
      and ( $param->{ 'path' . $param_num } ne 'EMPTY' )
      and !( (
          !$self->{'no_regex'}
          and
          ( $param->{ 'path' . $param_num } =~ /^\s*reg?e?x?p?:\s*/i or $param->{ 'path' . '_mode' . $param_num } =~ /[r~]/i )
        )
      )
      )
    {    # bad idea ?
      $search_str_add .= ' /' . $param->{ 'path' . $param_num } . '/ ';
      delete $param->{ 'path' . $param_num };
    }
    for my $item (
      grep( {
               $self->{'nav_all'}
            or $self->{'table'}{$table}{$_}{'nav_num_field'}
            or $self->{'table'}{$table}{$_}{'nav_field'}
            or $self->{'table'}{$table}{$_}{'nav_hide'}
        } keys %{ $self->{'table'}{$table} } ),
      @{ $self->{'table_param'}{$table}{'join_fields'} }
      )
    {
      #      $self->log('dev', 'where_body', 4, $item);
      next
        if $self->{'no_index'}
          or $self->{'ignore_index'}
          or $self->{'table_param'}{$table}{'no_index'}
          or $self->{'table_param'}{$table}{'ignore_index'}
          or $param->{ $item . $param_num } !~ /\S/;
      #      $self->log('dev', 'where_body', 4, $item);
      my $lask;
      ++$local_cond, $lask .= $gluel if $ask;
      my $pib = $param->{ $item . $param_num };
      $pib =~ s/^\s*|\s*$//g;
      my ( $group_not, $group_not_close );    #,
                                              #$self->log('dev', 'where_body', 5, $item, $self->{$item}, $_),
      $pib =~ s/\:$_(\W|$)/$config{$item}{$_}{'to'}$1/g and ++$group_not
        for grep { defined $config{$item}{$_}{'to'} } keys %{ $config{$item} or {} };
      #        for grep {defined $self->{$item}{$_}{'to'}} keys %{ $self->{$item} or {}};
      next if $pib eq '';
      my ( $brstr, $space );
      if ( $self->{'table'}{$table}{$item}{'no_split_space'}
        or ( !$self->{'no_regex'} and ( $pib =~ /\s*reg?e?x?p?:\s*/ or $param->{ $item . '_mode' . $param_num } =~ /[r~]/i ) ) )
      {
        #$self->log('dev', 'SPA')    ;
        $space = '\s+';
      } else {
        $brstr = '|\s+';
      }
      #    $brstr = $space . '\&+' . $space . '|' . '\|+' . '|(\s+AND\s+)|\s+OR\s+' . $brstr;
      $brstr = $space . '\&+' . $space . '|' . $space . '\|+' . $space . '|(\s+AND\s+)|\s+OR\s+' . $brstr;
      my $num_cond = 0;
      my $next_cond;
      my $llask;
      do {
        my ( $pi, $cond );
        $cond = $next_cond;
        #        $self->log('dev', "split[$pib] with  [($brstr)]");
        if ( $pib =~ /($brstr)/ ) { ( $pib, $pi, $next_cond ) = ( $', $`, $1 ); }
        else                      { $pi = $pib, $pib = ''; }
        if ( $num_cond++ ) {
          #        $self->log('dev', "andf1, $llask");
          if ( $cond =~ /(and)|\&+/i ) { $llask .= ' AND '; }
          elsif ( $self->{'enable_xor_query'} and $cond =~ /(xor)/i ) { $llask .= ' XOR '; }    #too slow
          elsif ( $cond =~ /(or)|\|+|\s+|^$/i ) { $llask .= ' OR '; }
          #        $self->log('dev', "andf2, $llask");
        }
        #        $self->log('dev', "$pib, $pi, $next_cond, $llask");
        my $not = 1 if ( !$self->{'no_slow'} or $self->{'table'}{$table}{$item}{'fast_not'} ) and ( $pi =~ s/^\s*[\!\-]\s*//g );
        $llask .= ' NOT ' . ( $group_not ? ( ++$group_not_close, ' ( ' ) : '' ) if $not;
        #        $self->log('dev', "not1 $llask");
        if ( $self->{'table_param'}{$table}{'name_to_base'}{$item} ) {
   #          printlog('dev', "here", $self->{'table_param'}{$table}{'name_to_base'}{$item});
   #          $llask .= ' ' . $tq . $self->{'table_prefix'} . $self->{'table_param'}{$table}{'name_to_base'}{$item} . $tq . ' ';
          $llask .= ' ' . $self->{'table_param'}{$table}{'name_to_base'}{$item} . ' ';
        } else {
          $llask .= " $tq$self->{'table_prefix'}$table$tq.$rq$item" . "$rq ";
        }
        my ($dequote_);    #, $dequotesl
                           #printlog('dev', !$self->{'no_regex'});
        if ( !$self->{'no_regex'}
          and ( $pi =~ s/^\s*reg?e?x?p?:\s*//ig or $param->{ $item . '_mode' . $param_num } =~ /[r~]/i ) )
        {
          $llask .= ' REGEXP ';
          #          ++$dequotesl;
        } elsif ( !$self->{'no_soundex'}
          and ( $pi =~ s/^\s*sou?n?d?e?x?:\s*//ig or $param->{ $item . '_mode' . $param_num } =~ /[s@]/i ) )
        {
          $llask .= ' SOUNDS LIKE ';
        } elsif ( $pi =~ /[*?]/ ) {
          $pi =~ s/%/\\%/g;
          $pi =~ s/_/\\_/g and ++$dequote_;
          $pi =~ tr/*?/%_/;
          next if $self->{'no_empty'} and ( $pi !~ /\S/ or $pi =~ /^\s*[%_]+\s*$/ );
          #printlog('dev', 'pi_:', $pi);
          $llask .= ' LIKE ';
        } else {
          if    ( $param->{ $item . '_mode' . $param_num } =~ /[g>]/i ) { $llask .= ( $not ? '<' : '>' ) . '= '; }
          elsif ( $param->{ $item . '_mode' . $param_num } =~ /[l<]/i ) { $llask .= ( $not ? '>' : '<' ) . '= '; }
          else                                                          { $llask .= '= '; }
        }
        $pi =~ s/(^\s*)|(\s*$)//g;
        $pi = psmisc::human( 'number_k', $pi ) if $item eq 'size';
        $work{ 'bold_' . $item } .= ' ' . $pi;
        $pi = ( $pi ne 'EMPTY' ? $self->squotes($pi) : $self->squotes('') );
        $pi =~ s|\\_|\_|g if $dequote_;
        #        printlog('dev', '$pi:', $pi, $dequotesl);
        #        $pi =~ s|\\{2}|\\|g if $dequotesl;
        #        printlog('dev', '$pi a:', $pi);
        $llask .= $pi;
        #        printlog('dev', '$llask:', $llask);
      } while ( $pib and $num_cond < 50 );
      #printlog('dev', '1 $llask:', $llask);
      $llask .= " ) " x $group_not_close;
      $group_not_close = 0;
      $lask .= ( $num_cond > 1 ? ' ( ' : '' ) . $llask . ( $num_cond > 1 ? ' ) ' : '' );
      #printlog('dev', '1 $lask:', $lask);
      $ask .=
        ( ( !$self->{'no_slow'} or $self->{'table'}{$table}{$item}{'fast_not'} )
          and $param->{ $item . '_mode' . $param_num } =~ /[n!]/i ? ' NOT ' : ' ' )
        . $lask;
      #printlog('dev', '1 $ask:', $ask);
    }
    $work{'search_str'} .= ' ' . $search_str . ' ' . $search_str_add;
    if ( $search_str =~ /\S/ or $search_str_add ) {
      unless ( $param->{'page'} > 1 or $param->{'order'} ) {
        #      printlog('dev', '2 $ask:', $search_str);
        #$self->dump_cp();
        ++$work{'query'}{$search_str};
        map { ++$work{'word'}{$_} } grep $_, split /\W+/, $search_str if $self->{'codepage'} ne 'utf-8';
      }
      #printlog('dev', '2 $ask:', $ask);
      ++$local_cond, $ask .= $gluel if $ask;
      #printlog('dev', '3 $ask:', $ask, $search_str, $search_str_add);
      $param->{ 'adv_query' . $param_num } = 'on'
        if $search_str =~ /\S+\*+\s*/
          or $search_str =~ /(^|\s+)(([+\-><~]+\()|\")[^"()]*\S+\s+\S+[^"()]*[\"\)]($|\s+)/
          or $search_str =~ /(^|\s+)[\~\+\-\<\>]\S+/;
      $search_str =~ s/(\S+)/\+$1/g
        if $param->{ 'adv_query' . $param_num } eq 'on'
          and !( $search_str =~ /((^|\s)\W+\S)|\S\W+(\s|$)/ )
          and $search_str =~ /\s/;
      $ask .= ( $search_str =~ s/^\s*\!\s*// ? ' NOT ' : '' );
      if ( $search_str =~ /^\s*(\S+)\.+(\S+)\s*$/ and $self->{'table'}{$table}{'name'} and $self->{'table'}{$table}{'ext'} ) {
        my %tparam = ( 'name' => $1, 'ext' => $2 );
        $ask .= ' ( ' . $self->where_body( \%tparam, undef, $table ) . ' ) ';
      } elsif ( !$self->{'no_slow'}
        and $search_str =~ /^\s*\*+\S+/
        and $self->{'table'}{$table}{'path'}
        and $self->{'table'}{$table}{'name'}
        and $self->{'table'}{$table}{'ext'} )
      {
        my %tparam = ( 'path' => '/' . $search_str, 'name' => $search_str, 'ext' => $search_str, 'gluel' => 'or' );
        $ask .= ' ( ' . $self->where_body( \%tparam, undef, $table ) . ' ) ';
      } else {
        #my $search_str = $search_str . $search_str_add;
        #printlog('ss', $search_str);
        $search_str .= $search_str_add;
        $self->{'handler_search_str'}->( $table, \$search_str ) if ref $self->{'handler_search_str'} eq 'CODE';
        my $search_str_stem = $self->stem($search_str)
          if grep { $self->{'table'}{$table}{$_}{'stem'} } keys %{ $self->{'table'}{$table} };
        #printlog('ss1',$param_num, $search_str);
        local $param->{ 'adv_query' . $param_num } = 'on'
          if $self->{'ignore_index'}
            or $self->{'table_param'}{$table}{'ignore_index'};
#        $self->log( 'dev', 'where_body', 6, $search_str, $table, $ask, grep { $self->{'table'}{$table}{$_}{'fulltext'} } keys %{ $self->{'table'}{$table} } );
        if ( (
            !$param->{ 'adv_query' . $param_num } and ( $self->{'ignore_index_fulltext'}
              or !grep { $self->{'table'}{$table}{$_}{'fulltext'} } keys %{ $self->{'table'}{$table} } )
          )
          or !$self->{'match'}
          )
        {
          #          my $sl = $self->squotes( '%' . $search_str . '%' );
          #          $self->log( 'dev', 'where_body', 7, $search_str,  $table , $ask);
          $_ = join(
            ' OR ',
#            map{ "$rq$_$rq LIKE $sl"} grep{ defined $self->{'table'}{$table}{$_}{'fulltext'}} keys %{ $self->{'table'}{$table} }
            map {
              "$rq$_$rq LIKE "
                . $self->squotes( ( (
                    !$self->{'no_slow'}
                      and $self->{'table'}{$table}{$_}{'like_bef'}
                      || $self->{'table_param'}{$table}{'like_bef'}
                      || $self->{'like_bef'}
                  ) ? '%' : ''
                )
                . $search_str . '%'
                )
              } grep {
              $self->{'table'}{$table}{$_}{'q'} || $self->{'table'}{$table}{$_}{'nav_field'}
                and !$self->{'table'}{$table}{$_}{'q_skip'}
              } keys %{ $self->{'table'}{$table} }
          );
          #          $self->log( 'dev', 'where_body', 8, $_ , $ask);
          $ask .= ' ( ' . $_ . ' ) ' if $_;
          #          $self->log( 'dev', 'where_body', 9, $search_str,  $ask );
        } else {
          #          $self->log( 'dev', 'where_body', 10, $search_str );
          $ask .= $self->match( $param, $param_num, $table, $search_str, $search_str_stem );
        }
      }
    }
    #        $self->log( 'dev', 'ask1:', $ask);
    $ask = ( $local_cond ? ' ( ' : '' ) . $ask . ( $local_cond ? ' ) ' : '' );
    #        $self->log( 'dev', 'ask2:', $ask);
    $ask = $glueg . $ask if $after and $ask;
#        $self->log( 'dev', 'ask3:', $ask);
#    $self->log(      'dbg', $local_cond, ' lret: ', $ask . ( $ask and $close ? ' ) ' x $close : '' ),      'after=', $after, '$glueg', $glueg, $param->{'search_prev'},    );
#"RET=[$ask]"
#
#      . ( $ask and $close ? ' ) ' x $close : '' )
#      . $self->where_body(
#       $param, $param_num + ( defined($param_num) ? 1 : ( $param->{'search_prev'} ? 0 : 1 ) ),
#      $table, ( $ask ? 1 : 0 )
#      )
#
#);
    return $ask 
      . ( $ask and $close ? ' ) ' x $close : '' )
      . $self->where_body( $param, $param_num + ( defined($param_num) ? 1 : ( $param->{'search_prev'} ? 0 : 1 ) ),
      $table, ( $ask ? 1 : 0 ) );
  };
  $self->{'where'} ||= sub {
    #sub where {
    my $self = shift;
    my ( $param, undef, $table ) = @_;
    #  my $where = sql_where_body(@_);
    $self->{'rec_stop'} = 0;
    my $where = $self->where_body(@_);
#            $self->log( 'dbg', "WHERE($table):[$where]", Dumper(\@_) , "$self->{'cp_in'} -> $self->{'codepage'} [extra=$self->{'table_param'}{$table}{'where_extra'}]");
#    return ' WHERE ' . scalar psmisc::cp_trans( $self->{'cp_in'}, $self->{'codepage'}, $where ) if $where;
    if ( $self->{'table_param'}{$table}{'where_extra'} ) {
      #$self->log( 'dbg','where_extra', $self->{'table_param'}{$table}{'where_extra'});
      $where .= (' AND ') if length $where;
      $where .= $self->{'table_param'}{$table}{'where_extra'};
    }
    return ' WHERE ' . $where if $where;
    return undef;
  };
  $self->{'count'} ||= sub {
    #sub query_count {
    my $self = shift;
    my ( $param, $table ) = @_;
    #  my ( $tq, $rq, $vq ) = sql_quotes();
    $self->limit_calc( $self, $param, $table );
    return undef
      if $self->{'query_count'}{$table}++
        or $self->{'ignore_index'}
        or $self->{'table_param'}{$table}{'ignore_index'};
    my @ask;
    $param->{'count_f'} = 'on' if $self->{'page'} eq 'rnd';
    push( @ask, ' COUNT(*) ' ) if $param->{'count_f'} eq 'on';
    push( @ask, " SUM($tq$table$tq.$rq$_$rq) " )
      for grep( ( $self->{'table'}{$table}{$_}{'allow_count'} and $param->{ 'count_' . $_ } eq 'on' ),
      sort keys %{ $self->{'table'}{$table} } );
    if (@ask) {
      my %tmp_para = %$param;
      local $self->{'dbirows'};
      delete $tmp_para{'online'};
      my $where = $self->where( \%tmp_para, undef, $table );
      return unless $self->{'allow_null_count'} or $where;
      my $from = join ' ', $tq . $self->{'table_prefix'} . $table . $tq, $self->join_what( undef, $param, $table );
      my $req = ' SELECT ' . join( ' , ', @ask ) . " FROM $from $where ";
      psmisc::flush();
#    $self->log( 'dmp', 'query:[', @_, '] = ', scalar @hash, ' per', psmisc::human( 'time_period', $tim->() ), 'err=',$self->err() );
      @ask = values %{ $self->query($req)->[0] };
      #      @ask = values %{ $self->line($req) };
      $stat{'found'}{'files'} = pop(@ask) if $param->{'count_f'} eq 'on';
      for (
        grep( ( $self->{'table'}{$table}{$_}{'allow_count'} and $param->{ 'count_' . $_ } eq 'on' ),
          sort keys %{ $self->{'table'}{$table} } )
        )
      {
        my $t = pop(@ask);
        $stat{'found'}{$_} = $t if $t;
      }
    }
    $self->{'calc_count'}->( $self, $param, $table );
    return undef;
  };
  $self->{'select'} ||= sub {
    my $self = shift;
    my ( $table, $param, ) = @_;
    $self->{'current_table'} = $table;
#        $self->log( 'dbg',  "$self->{'cp_in'} -> $self->{'codepage'}");
#    return ' WHERE ' . scalar psmisc::cp_trans( $self->{'cp_in'}, $self->{'codepage'}, $where ) if $where;
#$self->log( 'dbg',  'q1', scalar psmisc::cp_trans( $self->{'cp_in'}, $self->{'codepage'}, $self->select_body( $self->where($param), $param, $table ) ));
#$self->log( 'dbg',  'q2', $self->select_body( $self->where($param, undef, $table), $param, $table ) );
#$self->log( 'dbg',  'q3',  $self->where($param));
    return $self->query(
      scalar psmisc::cp_trans(
        $self->{'cp_in'}, $self->{'codepage'}, $self->select_body( $self->where( $param, undef, $table ), $param )
      )
    );
  };
  $self->{'select_log'} ||= sub {
    my $self = shift;
    my ( $table, $param, ) = @_;
    return $self->query_log( $self->select_body( $self->where( $param, undef, $table ), $param, $table ) );
  };
  $self->{'join_what'} ||= sub {
    #sub select {
    my $self = shift;
    my ( $where, $param, $table ) = @_;
    $table ||= $self->{'current_table'};
    my @join;
    #=dev
    for my $jt ( keys %{ $self->{'table_join'}{$table} } ) {
      local @_ = (    #(
                      #        map    { $_ }
        grep { $_ and $self->{'table'}{$jt}{$_} } keys %{ $self->{'table_join'}{$table}{$jt}{'on'} }
          #      )
      );
      #   printlog('dev','join', %{$self->{'table_join'}});
      #        $self->log('dev', "JOd $table -> $jt,",@_,"::", keys %{ $self->{'table_join'}{$table}{$jt}{'on'} });
      #    push @join,  " $tq$self->{'table_prefix'}$table$tq LEFT JOIN " .$tq. $self->{'table_prefix'} . $jt . $tq.
      push @join, "  LEFT JOIN " . $tq . $self->{'table_prefix'} . $jt . $tq . ' ON ' . '(' . join(
        ', ',
        map {
              $tq
            . $self->{'table_prefix'}
            . $table
            . $tq . '.'
            . $rq
            . $self->{'table_join'}{$table}{$jt}{'on'}{$_}
            . $rq . ' = '
            . $tq
            . $self->{'table_prefix'}
            . $jt
            . $tq . '.'
            . $rq
            . $_
            . $rq
          } @_
        )
        . ')'
        if @_;
      unless (@_) {
        @_ = (
          #      (
          #        map    { $_ }
          grep { $_ and $self->{'table'}{$jt}{$_} } keys %{ $self->{'table_join'}{$table}{$jt}{'using'} }
            #      )
            #        or (grep { $self->{'table'}{$jt}{$_}{'primary'} }
            #        keys %{ $self->{'table'}{$jt} })
        );
#$self->log('dev',"joprim{$jt}{$_}",
#keys (%{ $self->{'table'}{$jt} }),"oooooo",
#grep( { $self->{'table'}{$jt}{$_}{'primary'} }
#            keys (%{ $self->{'table'}{$jt} })),
#            "j[".join(':',@_)."]", scalar @_),
#$self->log('dev',"joprim{$jt} keys:", map( {'[', keys %{ $self->{'table'}{$jt}{$_}} , ']'} ,keys %{ $self->{'table'}{$jt} }),'prim:',grep { $self->{'table'}{$jt}{$_}{'primary'} }
#            keys %{ $self->{'table'}{$jt} }
#);
#        $self->log('dev',"joprim{$jt:",%{$self->{'table'}{$jt}{'host'}});
#$self->log('dev','jop1',@_, "::", Dumper($self->{'table'}{$jt} ));
        @_ = ( grep { $self->{'table'}{$jt}{$_}{'primary'} } keys %{ $self->{'table'}{$jt} } ) unless @_;
#$self->log('dev','jop2',@_);
#$self->log('dev','jop', "j[$jt][$_][".join(':',@_)."]", scalar @_);
#$self->log('dev', 'jo:',@_, ',,,:',grep { $self->{'table'}{$jt}{$_} }
#          grep { $_ }keys %{ $self->{'table_join'}{$table}{$jt}{'using'} });
#    push @join, "$tq$self->{'table_prefix'}$table$tq LEFT JOIN " .$tq. $self->{'table_prefix'} . $jt . $tq.' USING ' . '(' . join( ', ', map { $rq . $_ . $rq } @_ ) . ')'
#        $self->log('dev', "JO1 $table -> $jt,@_ [".join(':',@_)."]::", keys %{ $self->{'table_join'}{$table}{$jt}{'on'} });
        push @join,
          " LEFT JOIN " 
          . $tq
          . $self->{'table_prefix'}
          . $jt
          . $tq
          . ' USING ' . '('
          . join( ', ', map { $rq . $_ . $rq } @_ ) . ')'
          if @_;
      }
      #=cut
    }
    #=cut
    return join( ' ', @join );
  };
  $self->{'join_where'} ||= sub {
    #sub select {
    my $self = shift;
    my ( $where, $param, $table ) = @_;
    my @what;
    $table ||= $self->{'current_table'};
    for my $jt ( keys %{ $self->{'table_join'}{$table} } ) {
      #$self->log('dev', "here $jt");
      local $_ = join ', ', map {
            $tq
          . $self->{'table_prefix'}
          . $jt
          . $tq . '.'
          . $rq
          . $self->{'table_join'}{$table}{$jt}{'fields'}{$_}
          . $rq . ' AS '
          . $rq
          . $_
          . $rq
        } grep {
        $self->{'table'}{$jt}{ $self->{'table_join'}{$table}{$jt}{'fields'}{$_} }
        } keys %{ $self->{'table_join'}{$table}{$jt}{'fields'} };
      $_ ||= "$tq$self->{'table_prefix'}$jt" . "$tq.*";
      #             $join .= $_
      push( @what, $_ );
    }
#    $join = ', ' . $join if $join;
#    $sql = " $tq$self->{'table_prefix'}$table" . "$tq.* $work{'what_relevance'}{$table}".($join ? ', ' : ''). $join . " " . $sql;
#$self->log('dev', join(':',@what));
#@what = ('*');
    return join( ', ', grep { $_ } @what );
  };
  $self->{'orderby'} ||= sub {
    #sub select {
    my $self = shift;
    my ( $param, $table ) = @_;
    $table ||= $self->{'current_table'};
    my $sql;
    my %order;
    for my $ordern ( '', 0 .. 10 ) {
      my $order = ( $param->{ 'order' . $ordern } or next );
      last if ( $self->{'ignore_index'} or $self->{'table_param'}{$table}{'ignore_index'} );
      #$self->log('dev',1, $ordern, $order);
      my $min_data;
      ++$min_data
        for grep { $self->{'table'}{$table}{$_}{'sort_min'} and defined( $param->{$_} ) } keys %{ $self->{'table'}{$table} };
      last if $self->{'no_slow'} and !$min_data;
      #$self->log('dev',2, $ordern, $order);
      for my $join (
        grep { $order eq $_ } (
          grep { $self->{'table'}{$table}{$_}{'sort'} or !$self->{'table'}{$table}{$_}{'no_order'} }
            keys %{ $self->{'table'}{$table} }
          ),
        @{ $self->{'table_param'}{$table}{'join_fields'} }
        )
      {
        my ($intable) = grep { keys %{ $self->{'table'}{$_}{$join} } } $table, keys %{ $config{'sql'}{'table_join'}{$table} };
        #print "INTABLE[$intable]";
        #        $order{ $tq . $table . $tq . '.' . $rq . $_ . $rq
        $order{ $tq . $intable . $tq . '.' . $rq . $join . $rq
            . ( ( $param->{ 'order_mode' . $ordern } ) ? ' DESC ' : '' ) } =    #$param->{ 'order_rev' . $ordern } eq 'on' or
          $ordern;
      }
    }
    if ( keys %order ) {
      $sql .= ' ORDER BY ' . join ', ', sort { $order{$a} <=> $order{$b} } keys %order;
    }
    #print 'ORDERBY', Dumper($param,$table,$sql,  $self->{'table_param'}{$table}{'join_fields'} );
    return $sql;
  };
  $self->{'select_body'} ||= sub {
    #sub select {
    my $self = shift;
    my ( $where, $param, $table ) = @_;
    $table ||= $self->{'current_table'};
    #    $self->log( 'dev', 'select_body', $where );
    #  my ( $tq,    $rq,    $vq )    = sql_quotes();
    $self->limit_calc( $param, $table );
    #  limit_calc( $param, $table );
    if ( ( $self->{'ignore_index'} or $self->{'table_param'}{$table}{'ignore_index'} )
      and !( $self->{'no_index'} or $self->{'table_param'}{$table}{'no_index'} ) )
    {
      local @_ = ();
      local %_ = ();
      for ( keys %{ $self->{'table'}{$table} } ) {
        ++$_{ $self->{'table'}{$table}{$_}{'fulltext'} } if $self->{'table'}{$table}{$_}{'fulltext'};
        push( @_, $_ ) if $self->{'table'}{$table}{$_}{'index'};
      }
      push( @_, keys %_ ) unless $self->{'ignore_index_fulltext'} and $self->{'table_param'}{$table}{'ignore_index_fulltext'};
      $work{'sql_select_index'} = 'IGNORE INDEX (' . join( ',', @_ ) . ')';
    }
    #my $join = ;
    #!!!
    my $sql = "FROM $tq$self->{'table_prefix'}$table$tq " if $table;
    $sql .= $work{'sql_select_index'} . ' ' .
      #$join
      $self->join_what( $where, $param, $table ) . ' ' . $where;
    #  my $sql = "FROM  $work{'sql_select_index'} ". join(', ', @join). ' ' . $where;
    my @what = (
      ( $table ? $tq . $self->{'table_prefix'} . $table . $tq . '.' : ('') ) . '*', $work{'what_relevance'}{$table},
      #$param->{'what_extra'}
      $self->{'table_param'}{$table}{'what_extra'}
    );
    if ( defined( $self->{'table'}{$table}{ $param->{'distinct'} } ) ) {
      $sql = " DISTINCT $rq$param->{'distinct'}$rq " . $sql . " ";
    } else {
      #    my $join ;
      #@join = ()
      #!!
      $sql = join( ', ', grep { $_ } @what, $self->join_where( $where, $param, $table ) ) . " " . $sql;
    }
    $sql = " SELECT $self->{'HIGH_PRIORITY'} " . $sql;    #SQL_CALC_FOUND_ROWS
    $sql .= $self->orderby( $param, $table );
 #    $work{'on_page'} = 10 unless defined $work{'on_page'};
 #    my $limit = psmisc::check_int( ( $param->{'limit'} or $work{'on_page'} ), 0, $self->{'limit_max'}, $self->{'on_page'} );
 #    $sql .= ' LIMIT ' . ( $param->{'show_from'} ? $param->{'show_from'} . ',' : '' ) . " $limit"
 #      if $param->{'show_from'}
 #      or $limit;
 #    $self->{'limit'} = 10 unless defined $self->{'limit'};
 #    my $limit = psmisc::check_int( ( $param->{'limit'} or $self->{'limit'} ), 0, $self->{'results_max'}, $self->{'on_page'} );
 #    $sql .= ' LIMIT ' . ( $param->{'show_from'} ? $param->{'show_from'} . ',' : '' ) . " $limit"      if $param->{'show_from'}
    $sql .= $self->limit_body();
    return $sql;
  };
  $self->{'limit_body'} ||= sub {
    #sub calc_count {
    my $self = shift;
    return unless $self->{'limit_offset'} or $self->{'limit'};
    return ' LIMIT '
      . ( $self->{'limit_offset'} && !$self->{'OFFSET'} ? $self->{'limit_offset'} . ',' : '' )
      . $self->{'limit'}
      . ( $self->{'OFFSET'} && $self->{'limit_offset'} ? ' ' . $self->{'OFFSET'} . ' ' . $self->{'limit_offset'} : '' ) . ' ';
    return '';
  };
  $self->{'calc_count'} ||= sub {
    #sub calc_count {
    my $self = shift;
    my ( $param, $table, $count ) = @_;
    return if $work{'calc_count'}{$table}++;
    $self->{'founded'} = $count
      || (
      ( $self->{'dbirows'} > $stat{'found'}{'files'} and $self->{'dbirows'} < $self->{'limit'} )
      ? $self->{'dbirows'} + $self->{'limit_offset'}
      : $stat{'found'}{'files'}
      );
    $self->{'founded'} = 0 if $self->{'founded'} < 0 or !$self->{'founded'};    #or !$self->{'dbirows'} !!!experemental!
    $self->{'page_last'} =
      $self->{'limit'} > 0
      ? ( int( $self->{'founded'} / ( $self->{'limit'} or 1 ) ) + ( $self->{'founded'} % ( $self->{'limit'} or 1 ) ? 1 : 0 ) )
      : 0;                                                                      #3
    $self->{'page'} = int( rand( $self->{'page_last'} ) ) if $self->{'page'} eq 'rnd' and $param->{'count_f'} eq 'on';    #4
#    printlog(      'dev', "calc_count : founded=$self->{'founded'}; page=$self->{'page'} page_last=$self->{'page_last'}  dbirows=$self->{'dbirows'}   stat{'found'}{'files'}=$stat{'found'}{'files'} limit=$self->{'limit'}  ",          );
  };
  $self->{'limit_calc'} ||= sub {
    #sub pre_query {
    my $self = shift;
    my ($param) = @_;
    #    return if $work{'pre_query'}{$table}++;
    #    $self->{'page'} = int( $param->{'page'} > 0 ? $param->{'page'} : 1 );
    #    $self->{'page'}  = psmisc::check_int( $param->{'page'}, 1, $self->{'page_max'},    1 );
    #    $self->{'limit'} = psmisc::check_int( $param->{'on_page'},   0, $self->{'limit_max'}, $self->{'on_page'} );
    #    $self->{'limit'} ||= psmisc::check_int( $param->{'on_page'},   0, $self->{'results_max'}, $self->{'on_page'} );
    $self->{'limit_offset'} =
      int( $self->{'page'} > 0 ? $self->{'limit'} * ( $self->{'page'} - 1 ) : ( ( $param->{'show_from'} ) or 0 ) );
   #        printlog( 'dev', "limit_calc : limit_offset=$self->{'limit_offset'}; page=$self->{'page'} limit= $self->{'limit'}");
   #    ;    #caller(), caller(1),  caller(2)
    return undef;
  };
  $self->{'lock_tables'} ||= sub {
    #sub lock_tables {
    my $self = shift;
    #  local $_ = $self->do( $self->{'LOCK TABLES'}.' ' . join ' ', @_ );
    #  $work{'sql_locked'} = join ' ', @_ if $_;
    return $self->do( $self->{'LOCK TABLES'} . ' ' . join ' ', @_ ) if $self->{'LOCK TABLES'};
  };
  $self->{'unlock_tables'} ||= sub {
    #sub unlock_tables {
    my $self = shift;
    #  $work{'sql_locked'} = '';
    #  return $self->do( 'UNLOCK TABLES ' . join ' ', @_ );
    return $self->do( $self->{'UNLOCK TABLES'} . ' ' . join ' ', @_ ) if $self->{'UNLOCK TABLES'};
  };
  $self->{'stat_string'} ||= sub {
    my $self = shift;
    #print "\nSTRAAAA\n";
    return 'sqlstat: '
      . join(
      ' ',
      ( map { "$_=$self->{$_};" } grep { $self->{$_} } ( @_ or sort keys %{ $self->{'statable'} } ) ),
      (
        map { "$_=" . psmisc::human( 'time_period', $self->{$_} ) . ';' }
          grep { $self->{$_} } ( @_ or sort keys %{ $self->{'statable_time'} } )
      )
      );
  };
  $self->{'log_stat'} ||= sub {
    my $self = shift;
    $self->log( 'stat', $self->stat_string(@_) );
  };
  $self->{'check'} ||= sub {
    my $self = shift;
    local @_ = sort grep { $_ } keys %{ $self->{'table'} };
    return 0 unless @_;
    #printlog('dev',@_);
    #return 0;
    return $self->query( 'SELECT * FROM ' . ( join ',', map { "$tq$_$tq" } @_ ) . ' WHERE 1 LIMIT 1' );
  };
  $self->{'on_connect1'} ||= sub {
    my $self = shift;
    #  $self->log( 'dev', 'ONCON1');
    $self->check() if $self->{'auto_check'};
    #        use Data::Dumper;
    #    $self->log( 'dev', Dumper($config{'sql'}));
  };
  $self->{'table_stat'} ||= sub {
    my $self = shift;
    $self->log( 'info', 'totals:', @_,
      map { ( $_, '=', values %{ $self->line("SELECT COUNT(*) FROM $rq$self->{'table_prefix'}$_$rq ") } ) }
        grep { $_ } ( @_ or keys %{ $self->{'table'} } ) );
  };
  $self->{'next_user_prepare'} ||= sub {
    my $self = shift;
    $self->{'queries'} = $self->{'queries_time'} = $self->{'errors_chain'} = $self->{'errors'} = $self->{'connect_tried'} = 0;
    $self->{ 'on_user' . $_ }->($self) for grep { ref $self->{ 'on_user' . $_ } eq 'CODE' } ( '', 1 .. 5 );
    #        $self->{ 'on_user' }->($self) for grep { ref $self->{ 'on_user' } eq 'CODE'}('');
    #  printlog('dev', 'nup');
  };
  $self->{'next_user'} ||= sub {
    my $self = shift;
    $self->user_params(@_);
    $self->next_user_prepare(@_);
  };

=stem links
http://en.wikipedia.org/wiki/New_York_State_Identification_and_Intelligence_System
http://translit.ru/
http://koi8.pp.ru/koi8-r_iso9945-2.txt
http://en.wikipedia.org/wiki/Stemming
http://linguist.nm.ru/stemka/stemka.html
=cut

  $self->{'stem'} ||= sub {
    my $self = shift;
    #    $self->log('dev', "stem in[$_[0]]( $self->{'codepage'}, $self->{'cp_in'} -> $self->{'cp_int'})");
    #return $_[0];
    local $_ = lc( scalar psmisc::cp_trans( $self->{'cp_in'}, $self->{'cp_int'}, $_[0] ) );
    #    local $_ = lc( scalar psmisc::cp_trans( $self->{'codepage'}, $self->{'cp_int'}, $_[0] ) );
    #    local $_ = lc($_[0]  );
    #$self->log('dev', "stem bef[$_]");
    $self->{'stem_version'} = 4 if $self->{'stem_version'} <= 1;
    if ( $self->{'stem_version'} == 2 ) {    #first
      s/(\d)(\D)/$1 $2/g;
      s/(\D)(\d)/$1 $2/g;
      tr/À-‗/א-ÿ/;
      s/[תü]//g;
      s/kn/n/g;
      tr/אבגדהו¸זחטיךכלםמןנסעףפץצקרשû‎‏ÿ/abvgdeejsiiklmnoprstufhccssieua/;
      tr/ekouw/acaav/;
      s/'//g;
      s/\W/ /g if $_[1];
      s/_/ /g;
      s/(?:rd|nd)\b/d/g;
      s/ay\b/y/g;
      s/\B[aeisuo]\b//g;
      s/av/af/g;
      s/sch/s/g;
      s/ph/f/g;
      s/\s+/ /g;
      s/(\w)\1+/$1/g;
    } elsif ( $self->{'stem_version'} == 3 ) {    #temporary
      s/(\d)(\D)/$1 $2/g;
      s/(\D)(\d)/$1 $2/g;
      tr/À-‗/א-ÿ/;
      s/[תü]//g;
      s/kn/n/g;
      tr/אבגדהו¸זחטיךכלםמןנסעףפץצקרשû‎‏ÿ/abvgdeejsiiklmnoprstufhccssieua/;
      s/ks/x/g;                                   #2
      tr/kw/cv/;                                  #3
      s/'//g;
      s/\W/ /g if $_[1];
      s/_/ /g;
      s/(?:rd|nd)\b/d/g;
      s/ay\b/y/g;
      s/\B[aeisuo]\b//g;
      s/av/af/g;
      s/sch/s/g;
      s/ph/f/g;
      s/\s+/ /g;
      s/(?:(?!xxx)|(?=xxxx))(\w)\1+(?:(?<!xxx)|(?<=xxxx))/$1/g;    #3
    } elsif ( $self->{'stem_version'} == 4 ) {                     #release candidate
      s/(\d)(\D)/$1 $2/g;
      s/(\D)(\d)/$1 $2/g;
      tr/À-‗/א-ÿ/;
      s/[תü]//g;
      s/kn/n/g;
      tr/אבגדהו¸זחטיךכלםמןנסעףפץצקרשû‎‏ÿ/abvgdeejziiklmnoprstufhccssieua/;    #4 z
      s/ks/x/g;                                                               #2
      tr/kw/cv/;                                                              #3
      s/'//g;
      s/\W/ /g if $_[1];
      s/_/ /g;
      s/(?:rd|nd)\b/d/g;
      s/ay\b/y/g;
      s/\B[aeisuo]\b//g;
      s/av/af/g;
      s/sch/s/g;
      s/ph/f/g;
      s/\s+/ /g;
      s/(?:(?!xxx)|(?=xxxx))(\w)\1+(?:(?<!xxx)|(?<=xxxx))/$1/g;               #3
    }
    #$self->log('dev', "stem aft[$_]");
    #$_ = scalar psmisc::cp_trans( $self->{'cp_int'}, $self->{'cp_in'},$_);
    #    $_ = scalar psmisc::cp_trans( $self->{'cp_int'}, $self->{'codepage'}, $_ );
    #    $self->log('dev', "stem out[$_]");
    #    return scalar psmisc::cp_trans( $self->{'cp_int'}, $self->{'codepage'}, $_ );
    return scalar psmisc::cp_trans( $self->{'cp_int'}, $self->{'cp_in'}, $_ );
  };
  $self->{'stem_insert'} ||= sub {
    my $self = shift;
    #        $config{'sql'}{'handler_insert'} = sub {
    my ( $table, $col ) = @_;
    return 1 unless ref $self->{'stem'} eq 'CODE';
    #          $config{'stem'} and
    #          $config{'stem_func'};
    $col->{'stem'} = join ' ',
      map { $self->stem( $col->{$_}, 1 ) } grep { $self->{'table'}{$table}{$_}{'stem'} and $col->{$_} } keys %$col;
    return undef;
  };
  $self->{'last_insert_id'} ||= sub {
    my $self = shift;
    my $table = shift || $self->{'current_table'};
    if ( $^O eq 'MSWin32' and $self->{'driver'} eq 'pgpp' ) {
      my ($field) =
        grep { $self->{'table'}{$table}{$_}{'type'} eq 'serial' or $self->{'table'}{$table}{$_}{'auto_increment'} }
        keys %{ $self->{'table'}{$table} };
      #	        $self->log('dev', 'use lid1', "${table}_${field}");
      return $self->line("SELECT currval('${table}_${field}_seq') as lastid")->{'lastid'};
    } else {
      #	        $self->log('use lid2');
      return $self->{dbh}->last_insert_id( undef, undef, $table, undef );
    }
  };
  $self->{'dump_cp'} ||= sub {
    $self->log( 'dev', map { "$_ = $self->{$_}; " } qw(codepage cp cp_in cp_out cp_int cp_set_names) );
  };
  $self->{'cp_client'} ||= sub {
    shift;
    $self->{'cp_in'} = $_[0] if $_[0];
    $self->{'cp_out'} = $_[1] || $self->{'cp_in'} if $_[1] or $_[0];
    return ( $self->{'cp_in'}, $self->{'cp_out'} );
  };
  $self->{'index_disable'} ||= sub {
    my $self = shift;
    my $tim  = psmisc::timer();
    $self->log( 'info', 'Disabling indexes on', @_ );
    $self->log( 'err', 'ALTER TABLE ... DISABLE KEYS available in mysql >= 4' ), return
      if $self->{'driver'} eq 'mysql3'
        or $self->{'driver'} !~ /mysql/;
    $self->    #query_log
      do("ALTER TABLE $tq$config{'table_prefix'}$_$tq DISABLE KEYS") for @_;
    $self->log( 'time', "Disable index per", psmisc::human( 'time_period', $tim->() ), "sec" );
  };
  $self->{'index_enable'} ||= sub {
    my $self = shift;
    my $tim  = psmisc::timer();
    $self->log( 'info', 'Enabling indexes on', @_ );
    $self->log( 'err', 'ALTER TABLE ... DISABLE KEYS available in mysql >= 4' ), return
      if $self->{'driver'} eq 'mysql3'
        or $self->{'driver'} !~ /mysql/;
    $self->    #query_log
      do("ALTER TABLE $tq$config{'table_prefix'}$_$tq ENABLE KEYS") for @_;
    $self->log( 'time', 'Enable index per ', psmisc::human( 'time_period', $tim->() ) );
  };
  for my $action (qw(optimize analyze)) {
    $self->{$action} ||= sub {
      my $self = shift;
      @_ = keys %{ $self->{'table'} } unless @_;
      @_ = grep { $_ and $self->{'table'}{$_} } @_;
      $self->log( 'err', 'not defined action', $action, ), return unless $self->{ uc $action };
      $self->log( 'info', $action, @_ );
      my $tim = psmisc::timer();
      $self->query_log( $self->{ uc $action } . ' ' . join( ',', map( $self->tquote("$self->{'table_prefix'}$_"), @_ ) ) );
      $self->log( 'time', $action, 'per ', psmisc::human( 'time_period', $tim->() ) );
    };
  }
  for my $action (qw(flush)) {
    $self->{$action} ||= sub {
      my $self = shift;
      @_ = keys %{ $self->{'table'} } unless @_;
      @_ = grep { $_ and $self->{'table'}{$_} } @_;
      $self->log( 'err', 'not defined action', $action, ), return unless $self->{ uc $action };
      $self->log( 'info', $action, @_ );
      my $tim = psmisc::timer();
      $self->do( $self->{ uc $action } . ' ' . join( ',', map( $self->tquote( $self->{'table_prefix'} . $_ ), @_ ) ) );
      $self->log( 'time', $action, 'per ', psmisc::human( 'time_period', $tim->() ) );
    };
  }
  $self->{'retry_off'} ||= sub {
    my $self = shift;
    return if %{ $self->{'retry_save'} || {} };
    $self->{'retry_save'}{$_} = $self->{$_}, $self->{$_} = 0 for @{ $self->{'retry_vars'} };
  };
  $self->{'retry_on'} ||= sub {
    my $self = shift;
    return unless %{ $self->{'retry_save'} || {} };
    $self->{$_} = $self->{'retry_save'}{$_} for @{ $self->{'retry_vars'} };
    $self->{'retry_save'} = {};
  };
  $self->{'set_names'} ||= sub {
    my $self = shift;
    local $_ = $_[0] || $self->{'cp_set_names'};
    $self->do( $self->{'SET NAMES'} . " $vq$_$vq" ) if $_ and $self->{'SET NAMES'};
  };
}
1;
