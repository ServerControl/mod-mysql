#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Module::MySQL;

use strict;
use warnings;

use ServerControl::Module;
use ServerControl::Commons::Process;

use base qw(ServerControl::Module);

our $VERSION = '0.90';

use Data::Dumper;

__PACKAGE__->Parameter(
   help  => { isa => 'bool', call => sub { __PACKAGE__->help; } },
);

__PACKAGE__->Directories(
   "."      => { chmod => 0755, user => 'root', group => 'root' },
   bin      => { chmod => 0755, user => 'root', group => 'root' },
   conf     => { chmod => 0700, user => 'root', group => 'root' },
   run      => { chmod => 0755, user =>  ServerControl::Args->get->{'user'}, group => 'root' },
   data     => { chmod => 0755, user =>  ServerControl::Args->get->{'user'}, group => 'root' },
   logs     => { chmod => 0755, user =>  ServerControl::Args->get->{'user'}, group => 'root' },
   "conf/mysql-conf.d"     => { chmod => 0700, user => 'root', group => 'root' },
);

__PACKAGE__->Files(
   'bin/mysqld-' . __PACKAGE__->get_name  => { link => ServerControl::Schema->get('mysqld_safe') },
   'conf/my.cnf'                          => { call => sub { ServerControl::Template->parse(@_); } },
);

sub help {
   my ($class) = @_;

   print __PACKAGE__ . " " . $ServerControl::Module::MySQL::VERSION . "\n";

   printf "  %-30s%s\n", "--name=", "Instance Name";
   printf "  %-30s%s\n", "--path=", "The path where the instance should be created";
   print "\n";
   printf "  %-30s%s\n", "--user=", "MySQLd User";
   printf "  %-30s%s\n", "--ip=", "Listen IP";
   printf "  %-30s%s\n", "--port=", "Listen Port";
   print "\n";
   printf "  %-30s%s\n", "--create", "Create the instance";
   printf "  %-30s%s\n", "--start", "Start the instance";
   printf "  %-30s%s\n", "--stop", "Stop the instance";

}

sub start {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);
   spawn("$path/bin/mysqld-$name --defaults-file=$path/conf/my.cnf >$path/logs/console.out 2>&1 &");
}

sub create {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);
   system(ServerControl::Schema->get('mysql_install_db') . " --defaults-file=$path/conf/my.cnf --datadir=$path/data --user=" . ServerControl::Args->get->{'user'});

   unless($? == 0) {
      ServerControl->d_print("Error running mysql_install_db.\n");
   }
}

sub stop {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);
   my ($pid_file) = grep { /pid-file=(.*)/ => $_=$1; } eval { local(@ARGV) = ("$path/conf/my.cnf"); <>; };
   unless($pid_file) {
      $pid_file = "$path/run/$name.pid";
   }

   my $pid = eval { local(@ARGV, $/) = ($pid_file); <>; };
   chomp $pid;

   kill 15, $pid;
}

sub status {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);
   my $pid_file = "$path/run/$name.pid";
   if(-f $pid_file) { return 1; }
}



1;
