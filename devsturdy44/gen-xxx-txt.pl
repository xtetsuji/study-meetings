#!/usr/bin/env perl

use strict;
use warnings;

my @files = (qw(aaa.txt bbb.txt ccc.txt ddd.txt));

for my $file (@files) {
    open my $fh, '>', $file
        or die;
    my $char = ($file =~ /^(.)/)[0];
    for (1..100000) {
        print {$fh} $char x 60 . "\n";
    }
}
