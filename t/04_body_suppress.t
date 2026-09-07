# -*- perl -*-

# t/04_body_suppress.tt - test what happens when body_suppress element is supplied

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

$lre  = List::RewriteElements->new ( {
    list        => [ map {"$_\n"} (1..10) ],
    body_rule   => sub {
        my $record = shift;
        return (10 * $record);
    },
    body_suppress   => sub {
        my $record = shift;
        chomp $record;
        return if $record eq '10';
    },
} );
isa_ok ($lre, 'List::RewriteElements');

my $cap = IO::Capture::Stdout->new();
$cap->start();
$lre->generate_output();
$cap->stop();
chomp( @lines = $cap->read() );
is($lines[0], q{10}, "First element of list is correct");
is($lines[-1], q{90}, "Last element of list is correct");

{
    my $cwd = cwd();
    
    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $output = "./output";
    $lre  = List::RewriteElements->new ( {
        list        => [ map {"$_\n"} (1..10) ],
        body_rule   => sub {
            my $record = shift;
            return (10 * $record);
        },
        body_suppress   => sub {
            my $record = shift;
            chomp $record;
            return if $record eq '10';
        },
        output_file => $output,
    } );
    isa_ok ($lre, 'List::RewriteElements');

    $lre->generate_output();
    ok(-f $output, "Output file created");

    my @lines;
    tie @lines, 'Tie::File', $output;
    is($lines[0], q{10}, "First element of list is correct");
    is($lines[-1], q{90}, "Last element of list is correct");
    untie @lines;
    
    ok(chdir $cwd, 'changed back to original directory after testing');
}

