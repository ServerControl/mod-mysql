#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Schema::MacPorts::MySQL;

use strict;
use warnings;

use ServerControl::Schema;
use base qw(ServerControl::Schema::Module);

__PACKAGE__->register(
   
      'mysqld_safe'           => '/opt/local/bin/mysqld_safe5',
      'mysql_install_db'      => '/opt/local/bin/mysql_install_db5',

);

1;
