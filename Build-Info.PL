use strict;
use warnings;

use Build::Info::Perl qw(
    $VERSION
    generate_build_info
);
use File::Basename;
use File::Path qw( mkpath );


my @parts;

push @parts, qw( Build Info Perl );
my $module  = join '::', @parts;

push @parts, qw( BuildInfo );
my $package = join '::', @parts;

$parts[-1] .= '.pm';
my $file    = join '/', 'lib', @parts;

my $out;

# NB: use legacy interface from before v2.00
mkpath(dirname($file));
open $out, '>', $file or die "Cannot write file $file: $!";

my %env = (
    VERSION => "$Build::Info::Perl::VERSION",
);

my @vars = keys %env;

generate_build_info(
    env     => \%env,
    module  => $module,
    out     => $out,
    package => $package,
    vars    => \@vars,
);

close $out;

