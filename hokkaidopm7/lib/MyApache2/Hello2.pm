package MyApache2::Hello2;

use strict;
use warnings;

use Apache2::RequestRec;
use Apache2::RequestIO;
use Apache2::Const -compile => qw(OK);

use MyApache2::Sinatratic;

get '/' => sub {
    my $r = shift;
    $r->content_type("text/plain");
    $r->print("Hello, world2\n");
    return Apache2::Const::OK;
};

get '/num/:num' => sub {
    my $r = shift;
    $r->content_type("text/plain");
    $r->print("Hello, num is " . $r->notes->get("num") . "\n");
    return Apache2::Const::OK;
};

get '/name/:name' => sub {
    my $r = shift;
    $r->content_type("text/plain");
    $r->print("Hello " . $r->notes->get("name") . "\n");
    return Apache2::Const::OK;
};

default {
    my $r = shift;
    $r->content_type("text/plain");
    $r->print("Hello, default\n");
    return Apache2::Const::OK;
};

BEGIN {
    if ( defined &handler ) {
        MyApache2::Sinatratic::tmplog "handler is defined";
    } else {
        MyApache2::Sinatratic::tmplog "handler is not defined";
    }
}

# sub handler {
#     my $r = shift;
#     $r->content_type("text/plain");
#     $r->print("pre-defined handler is called");
#     return Apache2::Const::OK;
# }

1;

__END__

<Location />
    PerlResponseHandler MyApache2::Hello2
</Location>
