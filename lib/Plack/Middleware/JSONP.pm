package Plack::Middleware::JSONP;
use strict;
use parent qw(Plack::Middleware);
use Plack::Util;
use URI::Escape ();

sub call {
    my($self, $env) = @_;
    my $res = $self->app->($env);
    $self->response_cb($res, sub {
        my $res = shift;
        if (defined $res->[2] && ref $res->[2] eq 'ARRAY' && @{$res->[2]} == 1) {
            my $h = Plack::Util::headers($res->[1]);
            if ($h->get('Content-Type') =~ m!/(?:json|javascript)! &&
                $env->{QUERY_STRING} =~ /(?:^|&)callback=([^&]+)/) {
                # TODO: support callback params other than 'callback'
                my $cb = URI::Escape::uri_unescape($1);
                if ($cb =~ /^[\w\.\[\]]+$/) {
                    my $jsonp = "$cb($res->[2][0])";
                    $res->[2] = [ $jsonp ];
                    $h->set('Content-Length', length $jsonp);
                    $h->set('Content-Type', 'text/javascript');
                }
            }
        }
    });
}

1;

__END__

=head1 NAME

Plack::Middleware::JSONP - Wraps JSON response in JSONP if callback parameter is specified

=head1 DESCRIPTION

Plack::Middleware::JSONP wraps JSON response, which has Content-Type
value either C<text/javascript> or C<application/json> as a JSONP
response which is specified with the C<callback> query parameter.

This middleware only works with the application response with content
body set as an array ref and doesn't support IO::Handle-ish body

=head1 AUTHOR

Tatsuhiko Miyagawa

=head1 SEE ALSO

L<Plack>

=cut

