use 5.030003;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'Build::Info::Perl',
    VERSION_FROM      => 'lib/Build/Info/Perl.pm',
    ABSTRACT_FROM     => 'lib/Build/Info/Perl.pm',
    AUTHOR            => 'Joshua T. Rowe <jrowe@home.jrowe.org>',
    LICENSE           => 'perl',
	PREREQ_PM         => {
		'Exporter'       => 0,
		'File::Basename' => 0,
		'File::Path'     => 0,
	},
	EXE_FILES         => [
		'bin/build-info-perl',
	],
	PL_FILES          => {
		'Build-Info.PL' => 'lib/Build/Info/Perl/BuildInfo.pm',
	},
);
