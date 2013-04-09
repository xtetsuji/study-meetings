package MyApache2::Sinatratic;

use strict;
use warnings;

# $CALLBACK->{$handler_package}->{$http_method} = [ [$url, $handler], ... ];
my $CALLBACK = {};

sub import {
    my $pkg = shift;
    my @args = @_;
    my $callpkg = caller(0);

    # sub handler definition
    require Apache2::RequestRec;
    require Apache2::RequestUtil;
    require APR::Table;
    no strict 'refs';
    *{"$callpkg\::handler"} = \&import_handler;
    for my $method (qw(get post put del any)) {
        $CALLBACK->{$callpkg}->{$method} = [];
        *{"$callpkg\::$method"} = sub {
            my ($url, $handler) = @_;
            push @{$CALLBACK->{$callpkg}->{$method}}, [$url, $handler];
            #tmplog "push method=$method url=$url to CALLBACK at " . localtime;
        };
    }
    *{"$callpkg\::default"} = sub (&) {
        my $handler = shift;
        $CALLBACK->{$callpkg} ||= {};
        $CALLBACK->{$callpkg}->{default} = $handler;
        #tmplog "push method=default to CALLBACK at " . localtime;
    };
}

sub import_handler : method {
    my $class = shift;
    my $r = shift;
    for my $method (qw(any get post put del)) {
        next if $method ne lc $r->method();
        for my $pair (@{$CALLBACK->{$class}->{$method} || []}) {
            my ($url, $handler) = @$pair;
            my $matched_url = $url;
            if ( $matched_url =~ m{/:\w+} ) {
                my @zip_urls = pair([url_split($matched_url)], [url_split($r->uri())]);
                #tmplog __PACKAGE__ . "::import_handler(): zip_urls=" . Dumper(\@zip_urls);
                for my $zip_url (@zip_urls) {
                    last if !defined $zip_url->[0] || !defined $zip_url->[1];
                    my ($key) = $zip_url->[0] =~ m{^:(\w+)}
                        or next;
                    my $value = $zip_url->[1];
                    $r->notes->set( $key => $value );
                    $matched_url =~ s{(?<=/):$key}{$value};
                    #tmplog __PACKAGE__ . "::import_handler(): zip_url set $key=$zip_url->[1]. matched_url is replaced to $matched_url";
                }
            }

            if ( $r->uri() eq $matched_url ) {
                return $handler->($r);
            }
            # elsif () {} # TODO: regex match

        }
        #last if $method eq 'any';
    }

    if ( exists $CALLBACK->{$class}->{default} ) {
        my $default_handler = $CALLBACK->{$class}->{default};
        if ( ref $default_handler ne 'CODE' ) {
            die "given default() argument is not coderef.";
        }
        return $default_handler->($r);
    }
    else {
        die "default handler is not defined.  unknown processing exception.";
    }
}

###
### utility
###
sub url_split {
    return map { defined $_ && length $_ ? $_ : () } split m{/}, shift;
}

sub pair {
    my ($a1, $a2) = @_;
    my $max = scalar @$a1 >= scalar @$a2 ? scalar @$a1 : scalar @$a2;
    my @pair;
    for (1..$max) {
        push @pair, [shift @$a1, shift @$a2];
    }
    return wantarray ? @pair : \@pair;
}

# FOR DEBUG
use Data::Dumper;
sub tmplog {
    open my $fh, '>>', '/tmp/sinatratic.log'
        or die 'can not open /tmp/sinatratic.log';
    print {$fh} @_, "\n";
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

MyApache2::Sinatratic - Sinatratic WAF emulator for mod_perl2

=head1 SYNOPSIS

 # In Aapche config
 <Location />
   YourApache2::ResponseHandler
 </Location>

 # In YourApache2/ResponseHandler.pm
 use MyApache2::Sinatratic;
 # some load modules, Apache2::*, APR::*, and ModPerl::* module if require.
 get '/' => sub {
     my $r = shift; # Apache2::RequestRec object
     # some mod_perl2 code
 };
 get '/foo' => sub {
     my $r = shift;
     # some mod_perl2 code at url is "/foo"
 };
 post '/login' => sub {
     my $r = shift;
     # some mod_perl2 code at url is "/login", HTTP method is POST.
 };
 default {
    my $r = shift;
    # some mod_perl2 code at url that is not matched other rules.
 };

=head1 CAVEATS

This module is *EXPERIMENTAL*, *CONCEPTUAL* and **JOKE** module,
and totally *UNFINISHED* functionally.

Caution if you think to use this module...

=head1 DESCRIPTION

MyApache2::Sinatratic is *CONCEPTUAL* module
that possible to create mod_perl handler on
Sinatra like syntax.

This module offers Sinatra like DSL functions,
"get", "post", "put", "del" and "default".

=head1 AUTHOR

OGATA Tetsuji E<lt>tetsuji.ogata {at} gmail.com E<gt>

=head1 COPYRIGHT AND LICENCE

Copyright 2012 OGATA Tetsuji.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
