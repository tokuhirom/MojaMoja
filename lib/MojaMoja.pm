package MojaMoja;
use strict;
use warnings;
use parent 'Exporter';
use 5.00800;
our $VERSION = '0.01';
use Plack::Response;
use Router::Simple;
use Text::MicroTemplate ();
use Scalar::Util qw/refaddr/;
use Carp ();
use Data::Dumper qw/Dumper/;
use Data::Section::Simple ();
use Router::PSGIUtil qw/psgify router_to_app/;

our @EXPORT = qw/get put post Delete zigorou res render p Dumper get_data_section/;

my $_ROUTER;
my %CACHE;
our $KEY;

BEGIN {
    no strict 'refs';
    for my $meth (qw/get put post Delete/) {
        my $method = uc $meth;
        *{$meth} = sub ($$) {
            my ( $pattern, $code ) = @_;
            $_ROUTER->connect( $pattern, psgify { goto $code }, { method => $method } );
        };
    }
}


sub import {
    $_ROUTER = Router::Simple->new();
    strict->import;
    warnings->import;
    __PACKAGE__->export_to_level(1);
}

sub p {
    print STDERR Dumper(@_);
}

sub zigorou() {
    my $app = router_to_app($_ROUTER);
    return sub {
        local $KEY = refaddr $app;
        $app->(@_);
    };
}

sub get_data_section {
    my $data = $CACHE{$KEY}->{__data_section} ||= Data::Section::Simple->new('main')->get_data_section();
    return @_ ? $data->{$_[0]} : $data;
}

sub render {
    my ($key, @args) = @_;
    my $code = $CACHE{$KEY}->{$key} ||= do {
        my $tmpl = get_data_section($key);
        Carp::croak("unknown template file:$key") unless $tmpl;
        Text::MicroTemplate->new(template => $tmpl, package_name => 'main')->code();
    };
    package DB;
    local *DB::render = sub {
        my $coderef = (eval $code);
        die "Cannot compile template '$key': $@" if $@;
        $coderef->(@args);
    };
    goto &DB::render;
}

sub res { Plack::Response->new(@_) }

1;
__END__

=encoding utf8

=head1 NAME

MojaMoja -

=head1 SYNOPSIS

  # in myapp.psgi
  use MojaMoja;

  get '/' => sub {
  };

  get '/blog/{year}/{month}' => sub {
     res(200, [], ['display blog content'])
  };

  zigorou;

=head1 DESCRIPTION

MojaMoja is

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF GMAIL COME<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
