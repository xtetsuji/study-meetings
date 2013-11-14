#!/usr/bin/env perl

use strict;
use warnings;

use AnyEvent;
use AnyEvent::IO qw/:DEFAULT :flags/;
use Time::Hires;

my $cv = AE::cv;

my @files = (qw(aaa.txt bbb.txt ccc.txt ddd.txt));
my @years = (2009..2012);

for my $year (@years) {
    $cv->begin;
    my $async; $async = AE::timer 0, 0, sub {
        for my $file (@files){
            render_log($file);
        }
        undef $async;
        $cv->end;
    };
}

print "==========> render start <=========\n";

$cv->recv;

print "==========> render end <=========\n";

sub render_log {
    my $file = shift;
    $cv->begin;
    aio_open $file, O_RDONLY, 0, sub{
    	my ($fh) = @_;
    	my @piece;
    	my $interval;$interval = AE::timer 0, 0.000_000_1, sub{
            aio_read $fh, 128, sub {
                my ($data) = @_;
                if ( !$data ){
                    aio_close $fh, sub{};
                    undef $interval;
                    return $cv->end;
                }
                my @lines = split/\n/, $data;
                push @piece, pop @lines if $lines[-1] !~ /\n$/;
                $lines[0] = (shift @piece || '') . $lines[0];
                for ( @lines ){
                    print $_;
                }
            };
        };
    };
}
