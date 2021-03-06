#!perl -T

BEGIN {
  my $fail = '';
  $fail = "Skipped for perl 5.6.x" if $] < 5.007;
  $fail = "Skipping for Android (tests fail)" if lc($^O) eq 'android';
  if ($fail) {
    print "1..1\nok 1\n";
    warn "$fail\n";
    exit(0);
  }
}

use warnings; use strict;
use FindBin '$Bin';
my $bin;
BEGIN {
    # untaint
    ($bin) = $Bin =~ m/(.*)/;
}
my $t = $bin;
use lib $bin;

use Test::More tests => 10;
use Test::Warn;
use TestInlineSetup;
use Inline Config => DIRECTORY => $TestInlineSetup::DIR;

# deal with running as root - actually simulate running as setuid program. Avoid on Windows.
eval { $< = 1 }; # ignore failure

my $w1 = 'Blindly untainting tainted fields in %ENV';
my $w2 = 'Blindly untainting Inline configuration file information';
my $w3 = 'Blindly untainting tainted fields in Inline object';

warnings_like {require_taint_1()} [qr/$w1/, qr/$w2/, qr/$w1/, qr/$w3/], 'warn_test 1';
warnings_like {require_taint_2()} [qr/$w1/, qr/$w2/, qr/$w1/, qr/$w3/], 'warn_test 2';
warnings_like {require_taint_3()} [qr/$w1/, qr/$w2/, qr/$w1/, qr/$w3/, qr/$w1/, qr/$w2/, qr/$w1/, qr/$w3/], 'warn_test 3';

sub require_taint_1 {
    require "$t/08taint_1.p";
}

sub require_taint_2 {
    require "$t/08taint_2.p";
}

sub require_taint_3 {
    require "$t/08taint_3.p";
}
