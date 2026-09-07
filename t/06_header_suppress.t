# -*- perl -*-
#$Id: 06_header_suppress.t 1103 2006-12-12 01:13:29Z jimk $
# t/06_header_suppress.tt - test what happens when header_suppress element is supplied

use Test::More qw(no_plan); # tests => 2;
use_ok( 'List::RewriteElements' );
use_ok( 'Cwd' );
use_ok( 'File::Temp', qw| tempdir | );
use_ok( 'Tie::File' );
use_ok( 'Carp' );
use lib ( "t/testlib" );
use_ok( 'IO::Capture::Stdout' );

my $lre;
my @lines;
my $cap;

# Case 1:  header present; header rule supplied; header suppression criterion
# supplied; but header does not meet criterion for suppression

$lre  = List::RewriteElements->new ( {
    list        => [ map {"$_\n"} ( q{alpha}, 1..10 ) ],
    body_rule   => sub {
        my $record = shift;
        return (10 * $record);
    },
    header_rule   => sub {
        my $header = shift;
        return uc($header);
    },
    header_suppress  => sub {
        my $header = shift;
        chomp $header;
        return if $header eq 'omega';
    },
} );
isa_ok ($lre, 'List::RewriteElements');

$cap = IO::Capture::Stdout->new();
$cap->start();
$lre->generate_output();
$cap->stop();
chomp( @lines = $cap->read() );
is($lines[0], q{ALPHA}, "Header is correct; no suppression");
is($lines[1], q{10}, "First element of list is correct");
is($lines[-1], q{100}, "Last element of list is correct");

# Case 2:  header present; header rule supplied; header suppression criterion
# supplied; header meets criterion for suppression

$lre  = List::RewriteElements->new ( {
    list        => [ map {"$_\n"} ( q{alpha}, 1..10 ) ],
    body_rule   => sub {
        my $record = shift;
        return (10 * $record);
    },
    header_rule   => sub {
        my $header = shift;
        return uc($header);
    },
    header_suppress  => sub {
        my $header = shift;
        chomp $header;
        return if $header eq 'alpha';
    },
} );
isa_ok ($lre, 'List::RewriteElements');

$cap = IO::Capture::Stdout->new();
$cap->start();
$lre->generate_output();
$cap->stop();
chomp( @lines = $cap->read() );
is($lines[0], q{10},
    "First element of list is correct; suppression was correct");
is($lines[-1], q{100}, "Last element of list is correct");

# Case 3:  (same as #1, only from file)

{
    my $cwd = cwd();
    
    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $output = "./output";
    $lre  = List::RewriteElements->new ( {
        list        => [ map {"$_\n"} ( q{alpha}, 1..10 ) ],
        body_rule   => sub {
            my $record = shift;
            return (10 * $record);
        },
        header_rule   => sub {
            my $header = shift;
            return uc($header);
        },
        header_suppress  => sub {
            my $header = shift;
            chomp $header;
            return if $header eq 'omega';
        },
        output_file => $output,
    } );
    isa_ok ($lre, 'List::RewriteElements');

    $lre->generate_output();
    ok(-f $output, "Output file created");

    my @lines;
    tie @lines, 'Tie::File', $output;
    is($lines[0], q{ALPHA}, "Header is correct; no suppression");
    is($lines[1], q{10}, "First element of list is correct");
    is($lines[-1], q{100}, "Last element of list is correct");
    untie @lines;
    
    ok(chdir $cwd, 'changed back to original directory after testing');
}

