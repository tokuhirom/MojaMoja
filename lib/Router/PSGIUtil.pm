package Router::PSGIUtil;
use strict;
use warnings;
use parent 'Exporter';
use Plack::Request;

our @EXPORT = qw/router_to_app psgify/;
our $REQUEST_CLASS = 'Plack::Request';

sub psgify (&) {
    my $code = shift;
    sub {
        my $req = $REQUEST_CLASS->new(@_);
        my $res = $code->($req, $_[0]->{'router-util-psgiutil.args'});
        my $res_t = ref $res;
        if ($res_t eq 'Plack::Response') {
            return $res->finalize;
        } elsif ($res_t eq 'ARRAY') {
            return $res;
        } elsif (not $res_t) {
            return [200, ['Content-Type' => 'text/plain; charset=utf-8'], [$res]];
        } else {
            Carp::croak("unknown response type: $res, $res_t");
        }
    };
}

sub router_to_app {
    my $router = shift;

    sub {
        if ( my $p = $router->match($_[0]) ) {
            $_[0]->{'router-util-psgiutil.args'} = $p->{args};
            return $p->{code}->(@_);
        }
        else {
            return [ 404, [ 'Content-Type' => 'text/plain' ], ['not found'] ];
        }
    };
}

1;

__END__

=head1 SYNOPSIS

    use Router::Simple::Declare;
    use Router::PSGIUtil;

    my $router = router {
        connect '/' => psgify {
            'top page';
        };
    };
    my $app = router_to_app($router);

