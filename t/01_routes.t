use strict;
use warnings;
use Test::More;
use Test::WWW::Mechanize::PSGI;

my $app = do {
    use MojaMoja;

    get '/' => sub {
        return [200, [], ['top']];
    };

    get '/blog/{year:[0-9]+}/{month}' => sub {
        my $args = args();
        return  "$args->{year}-$args->{month}'s blog";
    };

    post '/comment' => sub {
        return "posted '@{[ req->param('body') ]}'";
    };

    get '/hoge' => sub {
        my $name = req->param('name');
        render('hoge.mt');
    };

    get '/fuga' => sub {
        render('fuga.mt', req->param('name'));
    };

    zigorou;
};

my $mech = Test::WWW::Mechanize::PSGI->new(app => $app);
$mech->get_ok('/');
$mech->content_contains('top');
$mech->get_ok('/blog/2010/03');
$mech->content_is("2010-03's blog");
$mech->post_ok('/comment', {body => 'hi'});
$mech->content_is("posted 'hi'");
$mech->get_ok('/hoge?name=dan');
$mech->content_is("hogehoge dan\n\n");
$mech->get_ok('/hoge?name=kogai');
$mech->content_is("hogehoge kogai\n\n");

done_testing;

__DATA__

@@ hoge.mt
hogehoge <?= $name ?>

@@ fuga.mt
fugafuga <?= $name ?>

