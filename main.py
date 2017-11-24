
from pyswip import Prolog

import pygame
from pygame.locals import *



def printPawns(fenetre, back, blackPawn, whitePawn) :

    #fenetre.blit(back, (0,0));

    list(prolog.query("pawn(X,Y,Player)."));

    print("Start");

    for sol in prolog.query("pawn(X,Y,Player)."):

        print ("X : " + (str)(sol["X"]) + ", Y : " + (str)(sol["Y"]) + ",  Player : " + str(sol["Player"]));

        #if (sol["Player"] == 'w'):

            #fenetre.blit(whitePawn, ((int)(sol["X"]) * 50, (int)(sol["Y"]) * 50));

        #elif (sol["Player"] == 'b'):

            #fenetre.blit(blackPawn, ((int)(sol["X"]) * 50, (int)(sol["Y"]) * 50)); 

    print("End");

    #pygame.display.flip();

    return;



pygame.init();

fenetre = pygame.display.set_mode((500, 500), RESIZABLE);

back = pygame.image.load("Back.png").convert();
blackPawn = pygame.image.load("BlackPawn.png").convert_alpha();
whitePawn = pygame.image.load("WhitePawn.png").convert_alpha();

fenetre.blit(back, (0,0));

pygame.display.flip();




prolog = Prolog();

prolog.consult("damev1.1.pl");

list(prolog.query("init."));

printPawns(fenetre, back, blackPawn, whitePawn);

#list(prolog.query("applyMove(action('Move', 5, 5), pawn(1, 0, 'b'))."));

a = list(prolog.query("ai(1, 'b', pawn(8, 3, 'b'), A)"));

for sol in a:

    print sol["A"]

printPawns(fenetre, back, blackPawn, whitePawn);

#list(prolog.query("applyMove(action('Move', 5, 6), pawn(5, 5, 'b'))."));

#printPawns(fenetre, back, blackPawn, whitePawn);






