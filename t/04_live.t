use strict;
use warnings;
use Test::More;
use Test::TCP;
use Time::Piece;
use t::Util qw/ run_fluentd /;

my ($server, $dir) = run_fluentd();
my $port = $server->port;

use_ok "Fluent::Logger";

subtest tcp => sub {
    my $logger = Fluent::Logger->new( port => $port );

    isa_ok $logger, "Fluent::Logger";
    my $tag = "test.tcp";
    ok $logger->post( $tag, { "foo" => "bar" });

    my $time     = time - int rand(3600);
    my $time_str = localtime($time)->strftime("%Y-%m-%dT%H:%M:%S%z");
    $time_str =~ s/(\d\d)$/:$1/; # TZ offset +0000 => +00:00

    ok $logger->post_with_time( $tag, { "FOO" => "BAR" }, $time );
    sleep 1;
    my $log = `cat $dir/tcp.log*`;
    note $log;
    like $log => qr{$tag\t\{"foo":"bar"\}}, "match post log";
    like $log => qr{\Q$time_str\E\t$tag\t\{"FOO":"BAR"\}}, "match post_with_time log";
};

done_testing;