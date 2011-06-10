#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Schema::Fedora::MySQL;

use strict;
use warnings;

use ServerControl::Schema;
use base qw(ServerControl::Schema::Module);

__PACKAGE__->register(
   
      'mysqld_safe'           => '/usr/bin/mysqld_safe',
      'mysql_install_db'      => '/usr/bin/mysql_install_db',

);

1;
