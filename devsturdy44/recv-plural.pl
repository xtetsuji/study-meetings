#!/usr/bin/env perl

use strict;
use warnings;

use AnyEvent;

my $cv = AE::cv;

my @event; # レキシカルスカラー変数でなくとも保持できてオブジェクトを壊せればよい

my $count = 0;
#my $timer = AE::timer 0, 1, sub {
push @event, AE::timer 0, 1, sub {
    print "event\n";
    if ( $count++ > 10 ) {
        $cv->send;
    }

    ### こういうのはダメ
    # recv 真っ最中のときは cv が別であっても同じであっても recv を多重に実行することはできない
#     if ( $count == 3 ) {
#         my $cv_in = AE::cv;
#         my $close_timer = AE::timer 0, 0.5, sub { print "close event\n"; };
#         $cv_in->recv();
#     }

    if ( $count > 5 ) {
        # サブイベントが大量に作成される
        my $subcount = $count;
        push @event, AE::timer 0, 1, sub {
            print "subevent at $subcount\n";
        }
    }
};

warn;
$cv->recv;
warn;

my $cv2 = AE::cv; # 新たに作る必要がある
#$cv = AE::cv; # 最初の $cv を壊して入れても OK
my $count2 = 0;

#undef $timer; # これが必要
@event = (); # こうするのもよい

my $tiemer2 = AE::timer 0, 1, sub {
    print "event2\n";
    if ( $count2++ > 5 ) {
        $cv2->send;
    }
};

warn;
#$cv->recv; # うまくいかない
$cv2->recv;
warn;
