package Build::Info::Perl;

use 5.030003;
use strict;
use warnings;

use Exporter qw( import );

our @EXPORT_OK = qw(
    $VERSION

    collect_env
    generate_build_info
    generate_build_info_exports
    generate_build_info_footer
    generate_build_info_header
    generate_build_info_var
    generate_build_info_vars
);

our $VERSION = '0.4.0';


my %DESC = (
    VERSION => 'The version of the module.',
);

my @RULES = (
    {
        exclude => 1,
        pattern => qr/CI_JOB_TOKEN/,
    },
    {
        exclude => 1,
        pattern => qr/PASSWORD/,
    },
    {
        pattern => qr/_?GITLAB_?/,
        tag     => 'gitlab',
    },
    {
        pattern => qr/_?GIT?/,
        tag     => 'git',
    },
    {
        pattern => qr/_?CI_?/,
        tag     => 'ci',
    },
    {
        pattern => qr/_?LOG_?/,
        tag     => 'log',
    },
    {
        pattern => qr/_?SHELL?/,
        tag     => 'shell',
    },
    {
        pattern => qr/_?VERSION_?/,
        tag     => 'version',
    },
);

sub collect_env {
    my %param  = @_;
    my $env    = $param{env}   // \%ENV,
    my $rules  = $param{rules} // \@RULES,

    my %tags;

    foreach my $var ( sort keys %{ $env } ) {

        RULES:
        foreach my $r ( @{ $rules } ) {
            my $exclude = $r->{exclude} // 0;
            my $pattern = $r->{pattern};
            my $tag     = $r->{tag};
$tag //= '';

            if ( $var =~ $pattern ) {
                if ( $exclude ) {
                    last RULES;
                }

                unless ( $exclude ) {
                    $tags{$tag}->{$var} = 1;
                }
            }
        }
    }

    foreach my $tag ( keys %tags ) {
        my $hash = delete $tags{$tag};
        $tags{$tag} = [ sort keys %{ $hash } ],
    }

    return \%tags;
}


sub generate_build_info {
    my %param   = @_;
    my $desc    = $param{desc}    // \%DESC,
    my $env     = $param{env}     // \%ENV,
    my $module  = $param{module}  // die 'parameter module is undef';
    my $out     = $param{out}     // die 'parameter out is undef';
    my $package = $param{package} // die 'parameter package is undef';
    my $rules   = $param{rules};
    my $tags    = $param{tags};
    my $vars    = $param{vars};

    my $collected = collect_env(
        env   => $env,
        rules => $rules,
    );

    $tags //= $collected;

    unless ( $tags || $vars ) {
        die 'parameters tags and vars cannot both be undef';
    }

    unless ( scalar(keys %{ $tags } ) || scalar(@{ $vars // [] }) ) {
        die 'parameters tags or vars must have a least one entry';
    }

    $tags //= {};

    generate_build_info_header(
        module  => $module,
        out     => $out,
        package => $package,
    );

    my $vars_from_tags = generate_build_info_exports(
        out  => $out,
        tags => $tags,
        vars => $vars,
    );

    unless ( $vars ) {
        $vars = $vars_from_tags;
    }

    generate_build_info_vars(
        desc => $desc,
        env  => $env,
        out  => $out,
        tags => $tags,
        vars => $vars,
    );

    generate_build_info_footer(
        out => $out,
    );


    return;
}


sub generate_build_info_exports {
    my %param = @_;
    my $out   = $param{out}  // die 'parameter out is undef';
    my $tags  = $param{tags} // die 'parameter tags is undef';
    my @vars  = @{ $param{vars} // [] };

    # NB: Param vars will be used for 'all' %EXPORT_TAG if available.
    #     Otherwise, 'all' will be all unique values from all the other
    #     tags.

    my @all;
    my %all;

    my @tags = sort keys %{ $tags };

    print $out join("\n",
        '',
        'our %EXPORT_TAGS = (',
        '',
    );

    foreach my $tag ( @tags, 'all' ) {
        my @items = @{ $tags->{$tag} // [] };

        my $is_all = 'all' eq $tag;
        if ( $is_all ) {
            # NB: Can pass in vars param that will override the all tag
            if ( @vars ) {
                @items = @vars;
            }
            else {
                @items = sort keys %all;
                @all = @items;
            }
        }

        if ( @items ) {
            print $out join("\n",
                sprintf('    %s => [ qw(', $tag),
                '',
            );

            foreach my $item ( @items ) {
                unless ( $is_all ) {
                    $all{$item} = 1;
                }

                print $out join("\n",
                    sprintf('        $%s', $item),
                    '',
                );
            }

            print $out join("\n",
                '    ) ],',
                '',
            );

        }
    }

    print $out join("\n",
        ');',
        '',
    );

    print $out join("\n",
        '',
        'our @EXPORT_OK = qw(',
        '',
    );

    my %ok_all = (
        %all,
        map { $_ => 1 } @vars,
    );
    foreach my $item ( sort keys %ok_all ) {
        print $out join("\n",
            sprintf('    $%s', $item),
            '',
        );
    }

    print $out join("\n",
        ');',
        '',
    );

    return \@all;;
}


sub generate_build_info_footer {
    my %param = @_;
    my $out   = $param{out} // die 'parameter out is undef';

    print $out join("\n",
        '',
        '=head1 GENERATED',
        '',
        'Generated by Build-Info-Perl ' . $VERSION,
        '',
        'Generated on ' . gmtime(time),
        '',
        '=cut',
        '',
        '1;',
        '',
    );

    return;
}


sub generate_build_info_header {
    my %param   = @_;
    my $module  = $param{module}  // die 'parameter module is undef';
    my $out     = $param{out}     // die 'parameter out is undef';
    my $package = $param{package} // die 'parameter package is undef';

    print $out join("\n",
        sprintf('package %s;', $package),
                '',
                'use 5.030003;',
                'use strict;',
                'use warnings;',
                '',
                '',
                'use Exporter qw( import );',
                '',
                '=head1 NAME',
                '',
        sprintf('%s - Build information for package %s', $package, $module),
                '',
                '',
                '=head1 SYNOPSIS',
                '',
                '    use feature qw( say );',
                '    use Build::Info::Perl::BuildInfo qw( :all );',
                '',
                '    say "VERSION => $VERSION";',
                '',
                '=cut',
                '',
    );

    return;
}


sub generate_build_info_var {
    my %param = @_;
    my $desc  = $param{desc} // '';
    my $out   = $param{out}  // die 'parameter out is undef';
    my $val   = $param{val}  || '""';
    my $var   = $param{var}  // die 'parameter var is undef';

    my @desc;
    if ( $desc ) {
        @desc = (
            sprintf('%s', $desc),
                    '',
        );
    }

    print $out join("\n",
                '',
        sprintf('=head2 $%s', $var),
                '',
        sprintf('%s', $val),
                '',
        @desc,
                '=cut',
                '',
        sprintf('our $%s = "%s";', $var, $val),
                '',
    );

    return;
}


sub generate_build_info_vars {
    my %param = @_;
    my $desc  = $param{desc} // {};
    my $env   = $param{env}  // die 'parameter env is undef';
    my $out   = $param{out}  // die 'parameter out is undef';
    my $vars  = $param{vars} // die 'parameter vars is undef';

    print $out join("\n",
        '',
        '=head1 VARIABLES',
        '',
        'All of the variables available for export.',
        '',
        '=cut',
        '',
    );
    foreach my $var ( @{ $vars } ) {
        generate_build_info_var(
            desc => $desc->{$var},
            out  => $out,
            val  => $env->{$var},
            var  => $var,
        );
    }

    return;
}


1;
__END__
=head1 NAME

Build::Info::Perl - Collects build information into a Perl package.

=head1 AUTHOR

Joshua T. Rowe, E<lt>jrowe@home.jrowe.orgE<gt>

=head1 VERSION

0.1.1

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 by Joshua T. Rowe

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.30.3 or,
at your option, any later version of Perl 5 you may have available.


=cut
