use ExtUtils::MakeMaker;

WriteMakefile
  (
   NAME		=> 'Games::Chess::Referee',
   VERSION_FROM	=> 'Referee.pm',
   dist         => { COMPRESS => 'gzip', SUFFIX => 'gz' }
  );

