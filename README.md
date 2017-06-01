## NAME

    sfrbox - Un script en perl pour la box de sfr (nb4, interface v3.4)

## VERSION

    Version 0.01

## SYNOPSIS

    sfrbox.pl [options]

    Options:
      -h|-help           bref message d'aide
      -i|-infos          affiche quelques infos
      -r|-reboot         redemarre la box
      -l|-led [on|off]   allume ou éteint les leds
      -c|-connected      affiche les appareils connectés

## INSTALLATION

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

## LICENSE AND COPYRIGHT                                                       

Copyright 2017 1shad.                                                               

This program is free software; you can redistribute it and/or modify it            
under the terms of either: the GNU General Public License as published             
by the Free Software Foundation; or the Artistic License.                          

See [http://dev.perl.org/licenses/](http://dev.perl.org/licenses/) for more information.                         
