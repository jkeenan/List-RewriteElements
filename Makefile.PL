

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'List::RewriteElements',
    VERSION_FROM => 'lib/List/RewriteElements.pm', # finds \$VERSION
    AUTHOR       => 'James E Keenan (jkeenan@cpan.org)',
    ABSTRACT     => 'Create a new list by rewriting elements of a first list',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                    },
);
