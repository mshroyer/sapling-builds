#!/usr/bin/env perl

use v5.40;

use File::Basename qw(basename dirname);
use File::Copy     qw(move);
use File::Find     qw();

my $scmlib = './eden/scm/lib';

sub source_file_needs_patching {
    my ( $path ) = @_;

    my $needs_patching = 0;
    open my $in, '<', $path or die "Unable to open for input: $path";
    while ( my $line = <$in> ) {
        chomp $line;
        if ( $line =~ /\.get_or_try_init\(/ ) {
            $needs_patching = 1;
            last;
        }
    }
    close $in or die "Unable to close input file $path";

    return $needs_patching;
}

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

# Replace references to OnceCell::get_or_try_init with the stub method in a
# .rs source file.  Also uses the compilerstubs crate, so that the trait
# method can be used.
sub patch_source_file {
    my ( $path ) = @_;

    patch_file(
        $path,
        sub {
            my ( $in, $out ) = @_;

            my $in_use_block = 0;
            while ( my $line = <$in> ) {
                chomp $line;

                $in_use_block = 1 if ( $line =~ /^use / );
                if ( $in_use_block and $line =~ /^(?!(?:pub )?use |\s*$)/ ) {
                    say $out "use crate::compilerstubs;\n";
                    $in_use_block = 0;
                }

                $line =~ s/\.get_or_try_init\(/.get_or_try_init_stub(/;

                say $out "$line";
            }
        }
    );
}

sub source_file_cargo_toml_path {
    my ( $rs_path ) = @_;

    my $src_path = $rs_path;
    while ( basename( $src_path ) ne 'src' ) {
        $src_path = dirname( $src_path );
    }
    my $crate_path = dirname( $src_path );
    return $crate_path . '/Cargo.toml';
}

# Add a relative reference to the compilerstubs library to a Cargo.toml file.
sub patch_cargo_toml {
    my ( $path ) = @_;

    my $compilerstubs_updirs = 0;
    my $compilerstubs_relpath = '';
    my $this_abspath = dirname($path);
    my $compilerstubs_abspath = $scmlib . '/util/compilerstubs';

    while ( $this_abspath ne $compilerstubs_abspath ) {
        if ( length($this_abspath) > length($compilerstubs_abspath) ) {
            my $bn = basename($this_abspath);
            $this_abspath = dirname($this_abspath);
            ++$compilerstubs_updirs;
        } else {
            my $bn = basename($compilerstubs_abspath);
            $compilerstubs_abspath = dirname($compilerstubs_abspath);
            $compilerstubs_relpath = $bn . '/' . $compilerstubs_relpath;
        }
    }
    while ( $compilerstubs_updirs > 0 ) {
        $compilerstubs_relpath = '../' . $compilerstubs_relpath;
        --$compilerstubs_updirs;
    }
    $compilerstubs_relpath =~ s|/$||;

    patch_file(
        $path,
        sub {
            my ( $in, $out ) = @_;

            while ( my $line = <$in> ) {
                chomp $line;

                say $out $line;
                if ( $line eq '[dependencies]' ) {
                    say $out
"sapling-compilerstubs = { version = \"0.1.0\", path = \"$compilerstubs_relpath\" }";
                }
            }
        }
    );
}

my @cargo_tomls = ();

File::Find::find(
    {
        no_chdir => 1,
        wanted   => sub {
            my $path = $_;

            return unless $path =~ /\.rs$/;
            return unless source_file_needs_patching( $path );

            my $cargo_toml = source_file_cargo_toml_path( $path );
            unless ( grep( /^$cargo_toml$/, @cargo_tomls ) ) {
                push @cargo_tomls, $cargo_toml;
            }

            patch_source_file( $path );
        },
    },
    $scmlib,
);

for my $cargo_toml ( @cargo_tomls ) {
    patch_cargo_toml( $cargo_toml );
}
