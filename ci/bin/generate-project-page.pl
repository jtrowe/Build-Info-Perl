use strict;
use warnings;

my $project  = 'Build::Info::Perl';
my $repo_url = q~https://gitlab.com/jtrowe/build-info-perl~;

print join("\n",
    q~<html>~,
    q~<head>~,
    q~<title>~,
    $project,
    q~</title>~,
    q~</head>~,
    q~<body>~,
    q~<h1>~,
    $project,
    q~</h1>~,
    q~<hr />~,
    q~<div>~,
    q~<div>~,
    q~<h2>Links</h2>~,
    qq~<a href="$repo_url">$project @ GitLab</a>~,
    q~</div>~,
);

my $dh;
opendir $dh, '.';
my @packages = grep { m/\.gz$/ } readdir $dh;
closedir $dh;

if ( @packages ) {
    print q~<div>~;
    print q~<h2>Packages</h2>~;

    foreach my $p ( sort { $b cmp $a  } @packages ) {
        printf qq~<div><a href="%s">%s</a></div>\n~, $p, $p;
    }

    print q~</div>~;
}

print join("\n",
    q~</div>~,
    q~</body>~,
    q~</html>~,
);
