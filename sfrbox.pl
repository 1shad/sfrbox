#!/usr/bin/env perl
=encoding utf-8

=head1 NAME

 sfrbox - Un script en perl pour la box de sfr (nb4, interface v3.4)

=head1 VERSION

 Version 0.01

=cut

our $VERSION = '0.01';

use Modern::Perl;
use utf8::all;
use Mojo::UserAgent;
use Mojo::Util qw(trim);
use Digest::SHA qw(sha256_hex hmac_sha256_hex);
use Getopt::Long;
use Pod::Usage qw(pod2usage);

my $ua = Mojo::UserAgent->new( max_redirects => 5 );

#
#
### Notez votre clé wifi ici ###
my $wifikey = '0aaabbbcccdddeeeffff';
###
#
#

my $user = 'admin'; # admin par défault
my $url = 'http://192.168.1.1/'; # Ne pas oublier le '/' à la fin

my %ACTION = (
    connected => \&connected,
    reboot    => \&reboot,
    infos     => \&infos,
    led       => \&led,
    help      => \&pod2usage,
);

my %OPTION;
GetOptions(\%OPTION, 'led=s', 'connected', 'reboot', 'infos', 'help' )
    or pod2usage(1);

pod2usage(1) if keys(%OPTION) < 1;
say "Only one option at a time" and exit() if keys(%OPTION) > 1;

$ACTION{$_}->($OPTION{$_}) for ( keys(%OPTION) );


=head1 SYNOPSIS
 
 sfrbox.pl [options]

 Options:
   -h|-help           bref message d'aide
   -i|-infos          affiche quelques infos
   -r|-reboot         redemarre la box
   -l|-led [on|off]   allume ou éteint les leds
   -c|-connected      affiche les appareils connectés

=head1 INSTALLATION

Copiez le script dans le dossier bin de votre répertoire personnel.
Modifiez le code wifi au début du script.
Renommez le fichier si vous voulez.
chmod 700 le fichier.

Vous pouvez installer les modules requis avec cpanm,
ou avec votre gestionnaire de paquet.

 Modules requis:
  Modern::Perl
  utf8::all
  Mojolicious
  Digest::SHA
  Getopt::Long
  Pod::Usage

=cut

sub led {
    my $state = lc(shift);
    my ( $tx );

    pod2usage(1) unless $state =~ /^(on|off)$/;
    
    login();
    $tx = $ua->post($url.'state' => form => {
        leds_state => $state,
    });
    die "Error action led" unless $tx->success;
}

sub infos {
    my @infos;

    my $tx = $ua->get($url);
    die "Can't connect to $url" unless $tx->success;

    @infos = $tx->res->dom->find('#infos th')
        ->map( sub { $_->text . trim( $_->next->text ) } )
        ->each;

    for ( qw( wan_status modem_uptime ) ) {
        my $node = $tx->res->dom->at('#'.$_);
        my $text = $node->previous->text;
        $text.= ": " . trim( $node->text );
        push @infos, $text;
    }
    
    say s/\n//rg for @infos;
}

sub connected {
    my ( $tx, @array );
    login();

    $tx = $ua->get($url.'network');

    @array = $tx->res->dom->find('#network_clients tbody tr')
        ->map( 'find', 'td' )
        ->map( sub { $_->map ( sub { trim($_->text) } ) } )
        ->map( sub { $_->to_array } )
        ->each;
    
    for ( @array ){
        say "$$_[0]: $$_[2]  $$_[1]  $$_[3]  $$_[4]";
    }
}

sub reboot {
    login();
    my $tx = $ua->post($url.'reboot');
    die "Error action reboot" unless $tx->success;
}

sub login {
    my ( $headers, $tx, $challenge, $hash );

    # get the challenge code by an ajax call
    $headers = { 'X-Requested-With' => 'XMLHttpRequest' };

    $tx = $ua->post($url.'login' => $headers => form => {
        callback => 'getChallenge',
        action => 'challenge',
    });
    die "Error getting challenge code while login" unless $tx->success;
    # ( returns a xml )
    $challenge = $tx->res->dom->at('challenge')->text;

    # simulate javascript actions
    $hash = hmac_sha256_hex(sha256_hex($user), $challenge);
    $hash .= hmac_sha256_hex(sha256_hex($wifikey), $challenge);

    # post the login form
    $tx = $ua->post($url.'login' => form => {
        method => 'passwd',
        page_ref => '',
        zsid => $challenge,
        hash => $hash,
    });
    die "Error action login" unless $tx->success;
}

=head1 LICENSE AND COPYRIGHT                                                       
                                                                                   
Copyright 2017 1shad.                                                               
                                                                                   
This program is free software; you can redistribute it and/or modify it            
under the terms of either: the GNU General Public License as published             
by the Free Software Foundation; or the Artistic License.                          
                                                                                   
See L<http://dev.perl.org/licenses/> for more information.                         
                                                                                   
=cut

