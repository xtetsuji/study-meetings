#file:MyApache2/FilterSomething.pm
#----------------------------------
use strict;
use warnings;

package MyApache2::FilterSomething;

use Apache2::Filter ();
use Apache2::RequestRec ();
use APR::Table ();

use Apache2::Const -compile => qw(OK);
use constant BUFF_LEN => 1024;

sub handler {
    my $f = shift;
    unless ($f->ctx) {
        $f->r->headers_out->unset('Content-Length');
        $f->ctx(1);
    }
    while ($f->read(my $buffer, BUFF_LEN)) {
        #$buffer =~ s/[\r\n]//g; # 改行を削除

        #$buffer =~ s/\s+/ /g; # 全てのwhitespaceを圧縮

        $buffer =~ s/hello/HELLO/ig;
        $buffer =~ s/world/WORLD/ig; # uppercase

        $f->print($buffer);
    }
    return Apache2::Const::OK;
}
1;
