use strict;
use warnings;

use Test::More tests => 8;

BEGIN {
    my @exports = qw(
        generate_build_info
        generate_build_info_exports
        generate_build_info_footer
        generate_build_info_header
        generate_build_info_var
        generate_build_info_vars
    );

    use_ok('Build::Info::Perl' => @exports );
};


subtest "generate_build_info_exports" => sub {
    plan(tests => 1);

    my $buffer;
    open(my $out, '>', \$buffer);

    my %tags = (
        ci => [ qw(
            CI
            CI_COMMMIT_SHA
            GITLAB_CI
        ) ],
        gitlab => [ qw(
            GITLAB_CI
        ) ],
    );

    my $vars = [ qw(
        SHELL
    ) ];

    generate_build_info_exports(
        out  => $out,
        tags => \%tags,
        vars => $vars,
    );

    close $out;

    ok(length($buffer), 'Generated some text')
            or note("out.length => " . length($buffer));
    note("out:\n" . $buffer);

};


subtest "generate_build_info_footer" => sub {
    plan(tests => 1);

    my $buffer;
    open(my $out, '>', \$buffer);

    generate_build_info_footer(
        out => $out,
    );

    close $out;

    ok(length($buffer), 'Generated some text')
            or note("out.length => " . length($buffer));
    note("out:\n" . $buffer);

};


subtest "generate_build_info_header" => sub {
    plan(tests => 1);

    my $buffer;
    open(my $out, '>', \$buffer);

    generate_build_info_header(
        module  => 'Foo',
        out     => $out,
        package => 'Foo::Build::Info',
    );

    close $out;

    ok(length($buffer), 'Generated some text')
            or note("out.length => " . length($buffer));
    note("out:\n" . $buffer);

};


subtest "generate_build_info_var" => sub {
    plan(tests => 1);

    my $buffer;
    open(my $out, '>', \$buffer);

    generate_build_info_var(
        out => $out,
        val => '1',
        var => 'ALFA',
    );

    close $out;

    ok(length($buffer), 'Generated some text')
            or note("out.length => " . length($buffer));
    note("out:\n" . $buffer);

};


subtest "generate_build_info_vars" => sub {
    plan(tests => 1);

    my $buffer;
    open(my $out, '>', \$buffer);

    my %env = (
        VERSION => '1.2.3',
    );

    my @vars = qw(
        VERSION
    );

    generate_build_info_vars(
        env  => \%env,
        out  => $out,
        vars => \@vars,
    );

    close $out;

    ok(length($buffer), 'Generated some text')
            or note("out.length => " . length($buffer));
    note("out:\n" . $buffer);

};


subtest "generate_build_info" => sub {
    plan(tests => 1);

    my $buffer;
    open(my $out, '>', \$buffer);

    my %env = (
        CI      => 'true',
        VERSION => '1.2.3',
    );

    my %tags = (
        ci => [ qw(
            CI
        ) ],
        version => [ qw(
            VERSION
        ) ],
    );

    generate_build_info(
        env     => \%env,
        module  => 'Bar',
        out     => $out,
        package => 'Bar::BuildInfo',
        tags    => \%tags,
    );

    close $out;

    ok(length($buffer), 'Generated some text')
            or note("out.length => " . length($buffer));
    note("out:\n" . $buffer);

};


subtest '$VERSION' => sub {

    my $v = $Build::Info::Perl::VERSION;
    like($v, qr/^\d+\.\d+\.\d+$/, '$VERSION looks ok');

};


