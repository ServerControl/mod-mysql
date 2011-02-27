use ExtUtils::MakeMaker;

WriteMakefile(
   NAME => 'ServerControl-Mysql',
   VERSION_FROM => 'lib/ServerControl/Module/MySQL.pm',
   PREREQ_PM => {'ServerControl' => '0.90'},
   LICENSE => 'bsd'
);

