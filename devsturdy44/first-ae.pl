#!/usr/bin/env perl

use strict;
use warnings;

use AnyEvent;

my $cv = AnyEvent->condvar;

my $count = 0;
my $timer1 = AnyEvent->timer(
    after => 0,
    interval => 1,
    cb => sub {
        $count++;
        print "event $count\n";
        if ( $count > 10 ) {
            $cv->send;
        }
    },
);

my $timer2 = AnyEvent->timer(
    after => 5,
    cb => sub {
        print "sub-event\n";
    },
);

$cv->recv;

