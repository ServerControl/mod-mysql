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

our $VERSION = '0.93';

use Data::Dumper;

__PACKAGE__->Parameter(
   help  => { isa => 'bool', call => sub { __PACKAGE__->help; } },
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

   my $exec_file   = ServerControl::FsLayout->get_file("Exec", "mysqld");
   my $config_file = ServerControl::FsLayout->get_file("Configuration", "mycnf");
   my $log_dir     = ServerControl::FsLayout->get_directory("Runtime", "log");

   spawn("$path/$exec_file --defaults-file=$path/$config_file >$path/$log_dir/console.out 2>&1 &");
}

sub create {
   my ($class) = @_;

   my $config_file = ServerControl::FsLayout->get_file("Configuration", "mycnf");
   my $data_dir    = ServerControl::FsLayout->get_directory("Base", "data");

   my ($name, $path) = ($class->get_name, $class->get_path);
   system(ServerControl::Schema->get('mysql_install_db') . " --defaults-file=$path/$config_file --datadir=$path/$data_dir --user=" . ServerControl::Args->get->{'user'});

   unless($? == 0) {
      ServerControl->d_print("Error running mysql_install_db.\n");
   }
}

sub stop {
   my ($class) = @_;

   my $exec_file   = ServerControl::FsLayout->get_file("Exec", "mysqld");
   my $config_file = ServerControl::FsLayout->get_file("Configuration", "mycnf");
   my $log_dir     = ServerControl::FsLayout->get_directory("Runtime", "log");
   my $pid_dir     = ServerControl::FsLayout->get_directory("Runtime", "pid");

   my ($name, $path) = ($class->get_name, $class->get_path);
   my ($pid_file) = grep { /pid-file=(.*)/ => $_=$1; } eval { local(@ARGV) = ("$path/$config_file"); <>; };
   unless($pid_file) {
      $pid_file = "$path/$pid_dir/$name.pid";
   }

   my $pid = eval { local(@ARGV, $/) = ($pid_file); <>; };
   chomp $pid;

   ServerControl->d_print("Killing (15): $pid\n");

   kill 15, $pid;
}

sub status {
   my ($class) = @_;

   my $config_file = ServerControl::FsLayout->get_file("Configuration", "mycnf");
   my $pid_dir     = ServerControl::FsLayout->get_directory("Runtime", "pid");

   my ($name, $path) = ($class->get_name, $class->get_path);
   my $pid_file = "$path/$pid_dir/$name.pid";
   if(-f $pid_file) { return 1; }
}



1;
