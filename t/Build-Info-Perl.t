use strict;
use warnings;

use Data::Dumper;

use Test::More tests => 12;
use Test::Deep;

BEGIN {
    my @exports = qw(
        collect_env
        generate_build_info
        generate_build_info_exports
        generate_build_info_footer
        generate_build_info_header
        generate_build_info_var
        generate_build_info_vars
    );

    use_ok('Build::Info::Perl' => @exports );
};

$Data::Dumper::Sortkeys = 1;


subtest "collect_env" => sub {
    plan(tests => 1);

    my %env = (
        CI            => 'true',
        CI_COMMIT_SHA => 'fa1d3547c18cf6b42dae80d52c66a3e4eba3d47f',
        GITLAB_CI     => 'true',
    );

    my $rules = [
        {
            pattern => qr/_?CI_?/,
            tag     => 'ci',
        },
        {
            pattern => qr/_?GITLAB_?/,
            tag     => 'gitlab',
        },
    ];

    my $tags = collect_env(
        rules => $rules,
        env   => \%env,
    );

    my $exp = {
        ci => [ qw(
            CI
            CI_COMMIT_SHA
            GITLAB_CI
        ) ],
        gitlab => [ qw(
            GITLAB_CI
        ) ],
    };

    cmp_deeply($tags, $exp, 'Got expected tags');
    note("tags:\n" . Dumper($tags));


};


subtest "collect_env w/ excludes" => sub {
    plan(tests => 1);

    my %env = (
        CI            => 'true',
        CI_COMMIT_SHA => 'fa1d3547c18cf6b42dae80d52c66a3e4eba3d47f',
        CI_JOB_TOKEN  => 'foo',
        CI_PASSWORD   => 'foobaz',
        GITLAB_CI     => 'true',
        PASSWORD      => 'foobar',
    );

    my $rules = [
        {
            exclude => 1,
            pattern => qr/CI_JOB_TOKEN/,
        },
        {
            exclude => 1,
            pattern => qr/PASSWORD/,
        },
        {
            pattern => qr/_?CI_?/,
            tag     => 'ci',
        },
        {
            pattern => qr/_?GITLAB_?/,
            tag     => 'gitlab',
        },
    ];

    my $tags = collect_env(
        rules => $rules,
        env   => \%env,
    );

    my $exp = {
        ci => [ qw(
            CI
            CI_COMMIT_SHA
            GITLAB_CI
        ) ],
        gitlab => [ qw(
            GITLAB_CI
        ) ],
    };

    cmp_deeply($tags, $exp, 'Got expected tags');
    note("tags:\n" . Dumper($tags));


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


subtest "generate_build_info_exports via collect_env" => sub {
    plan(tests => 1);

    my $buffer;
    open(my $out, '>', \$buffer);

    my %env = (
        VERSION => '1.2.3',
    );

    my $tags = collect_env(
        env => \%env,
    );

    generate_build_info_exports(
        out  => $out,
        tags => $tags,
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


subtest "generate_build_info w/ tags" => sub {
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


subtest "generate_build_info w/o tags" => sub {
    plan(tests => 1);

    my $buffer;
    open(my $out, '>', \$buffer);

    my %env = (
        VERSION => '1.2.3',
    );

    generate_build_info(
        env     => \%env,
        module  => 'Bar',
        out     => $out,
        package => 'Bar::BuildInfo',
        vars    => [ keys %env ],
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


