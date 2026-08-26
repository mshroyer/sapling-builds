#!/usr/bin/env perl

use v5.40;

use File::Copy qw(move);

sub patch_file {
    my ( $path, $sub ) = @_;

    open my $in, '<', $path or die "Unable to open for input: $path";
    open my $out, '>', "$path.new"
      or die "Unable to open for output: $path.new";

    $sub->( $in, $out );

    close $in  or die "Unable to close input file $path";
    close $out or die "Unable to close output file $path.new";

    move( "$path.new", $path ) or die "$path: rename from $path.new";
}

sub patch_cargo_toml {
    my ( $path ) = @_;

    patch_file(
        $path,
        sub {
            my ( $in, $out ) = @_;

            while ( my $line = <$in> ) {
                chomp $line;
                if ( $line =~ /^(curl = .*), "static-ssl"(.*)$/ ) {
                    say $out "$1$2";
                }
                else {
                    say $out $line;
                }
            }
        }
    );
}

patch_cargo_toml( "eden/scm/lib/http-client/Cargo.toml" );
