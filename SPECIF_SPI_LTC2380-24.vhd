-------------------------------------------------------------------------------
O.N le 01/12/2020
Revision 1.00
Projet OSVA
Explication et spécifications pour la lecture des données de l'ADC LTC2380-24
-------------------------------------------------------------------------------
________________________________________________________________________________
Vocabulaire :
Fso  = fréquence d'échantillonnage de sortie effective (aprés moyenne)
nFs = fréquence d'échantillonnage réelle de l'ADC (avant moyenne)
________________________________________________________________________________
Les signaux de contrôle de l'ADC son :
- entrée "CNV" (active high) : déclenche  une conversion
- sortie "Busy" (active high): indique que la la conversion est en cours.
- entrée "SCK" : (active high):  horloge de lecture des données de l'ADC
- sortie "SDO" : (active high):  résultat de la conversion.

Le résultat de la conversion est sur 24 bits (MSB fisrt).
La durée du signal "BUSY" est de 392 ns maxi.

Les modes de conversion, disponibles sont :
################################################################################
1) Mode conventionnel (simple).
*******************************
a) Une impulsion sur cnv initie la conversion,
b) on attend alors que "busy" repasse à 0 ,
c) on génere 23 coups de "clock" pour lire les 24 bits de donnée,
d) on recommence en (a).

>Notes :
les données changent au front montant, on les lis au frond descendant.
il faut seulement 23 coup de "clock" car le MSB des data est lu avant
le 1er coup de "clock").
Inconvénient : Dans ce mode, pour atteindre la vitesse max de l'ADC de
Fs= 1.6 MSPS, il faut que la clock qui lit les données soit de 100 MHz !

2) Mode conventionnel avec moyennage.
*************************************
a) Une impulsion sur cnv initie la conversion,
b) on attend alors que "busy" repasse à 0 ,
c) on génere 23 coups de "clock" pour lire les 24 bits de donnée
mais seulement une fois par nombre de cycle que l'on souhaite moyenner.
Ex:Si on veut moyenner 16 conversions, on génere les 23 coups de "clock"
seulement 1 fois et rien pendant les 15 conversion suivantes.
d) on recommence en (a).

>Notes :Comme pour le mode (1), à Fsmax la clock doit valoir 100 MHz.
 Pour que la moyenne soit juste, la moyenne doit êytre une puissance de 2.
 (toutes valeurs de moyenne possible si on applique un gain correcteur)

3) Mode avec lecture distribué.
*******************************
a) Une impulsion sur cnv initie la conversion,
b) on attend alors que "busy" repasse à 0 ,
c) on génere les 23 coups de "clock" mais en les répartissant sur l'ensemble
des conversions qui doivent être moyennées sauf la dernière (pas de "clock"
pendant la dernière conversion).
d) on recommence en (a).

>Notes :
Le nombre de coups de "clock" pour chaque conversion doit être compris
entre 1 et 19 coups de "clock" maxi. Rien pour le dernier.

Conséquence importante :
Ici, le nombre total de coup de "clock" à fournie à l'ADC pour les data est
réparti sur l'ensemble de cycle de conversion qui sont moyennés.
Il est donc possible d'avoir un signal de "clock" de fréquence BEAUCOUP plus
faible.
Exemple ; Si on moyenne 8 conversions à 1.6 MSPS, cela donne 23 lectures sur
8-1 = 7 périodes.Une période vaut 625ns, à laquelle on retire  392ns de temps de
conversion (busy) soit 625ns -392ns = 233 ns.
On réparti les 23 lectures sur périodes : 23/7 = 3.3 ~ 4.
On choisi 4 coups de clock par conversion, cela donne une période d'horloge
maxi de 233/4 = 58 ns soit une fréquence pour la "clock" de 17 MHz.
C'est bien moin que les 100 MHz nécessaire dans les autres modes !!...
################################################################################


Ce qu'on veut pouvoir faire :
*****************************
choisir entre les modes possible :
(1)  Mode conventionnel (pas de moyennage)
(2)  Mode conventionnel avec moyennage.
(3)  Mode avec lecture distribué.

En mode (1), on souhaite pouvoir choisir Fso entre 1536 kHz et 12 kHz
(12,24,48,96,192,384,768 et 1536 kHz)
>-> Dans ce mode, nFS=Fso car aucun moyennage <-<

En mode (2),on souahite pouvoir choisir Fso entre 768 kHz et 12 kHz.
(12,24,48,96,192,384 et 768 kHz).
La valeur de moyennage est égale à 1536/Fso, et varie donc entre
2 (1536/768) et 128 (1536/12).

En mode (3), idem que le mode (2) sauf que la lecture des data est faite
de manière différente. Les cycles de clock sont distribué sur toutes les
conversions.

Signaux d'entrée du bloc de lecture de l'ADC:
---------------------------------------------
> Clock : horloge maître 98.304 MHz (pour obtenir 1536 kHz ).
> Fso   : choix de Fso entre 12k-1536k (3 bits)
> Mode  : choix du mode de conversion 1,2 ou 3. (2 bits)
Signaux d'entrée du bloc de lecture de l'ADC:

Signaux de sortie du bloc de lecture de l'ADC:
---------------------------------------------
>
>
>
>
