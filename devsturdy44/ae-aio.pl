#!/usr/bin/env perl

use strict;
use warnings;

use AnyEvent;
use AnyEvent::IO;

aio_open "aaa.txt", sub {
    my ($data) = @_
        or return AE::log error => "$!";
    print $data;
};

aio_open "bbb.txt", sub {
    my ($data) = @_
        or return AE::log error => "$!";
    print $data;
};


