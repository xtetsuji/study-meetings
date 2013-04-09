package MyApache2::Hello;

use strict;
use warnings;

use Apache2::RequestRec;
use Apache2::RequestIO;
use Apache2::Const -compile => qw(OK);

sub handler {
    my $r = shift;
    $r->content_type("text/plain");
    $r->print("Hello, world");
    return Apache2::Const::OK;
}

1;

__END__

<Location />
    PerlResponseHandler MyApache2::Hello
</Location>
