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
use Data::Dumper;

our $VERSION = '0.199.0';

use base qw(ServerControl::Module);

__PACKAGE__->Implements( qw(ServerControl::Module::PidFile) );

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

   my $config_file   = ServerControl::FsLayout->get_file("Configuration", "mycnf");
   my $data_dir      = ServerControl::FsLayout->get_directory("Base", "data");
   my $install_db    = ServerControl::FsLayout->get_file("Exec", "installdb");

   my ($name, $path) = ($class->get_name, $class->get_path);
   system("$path/$install_db --defaults-file=$path/$config_file --datadir=$path/$data_dir --user=" . ServerControl::Args->get->{'user'});

   unless($? == 0) {
      ServerControl->d_print("Error running mysql_install_db.\n");
   }
}

1;
