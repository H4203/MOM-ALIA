
from pyswip import *

import pygame
from pygame.locals import *

import time



def printPawns(fenetre, back, blackPawn, whitePawn) :

    fenetre.blit(back, (0,0));

    list(prolog.query("pawn(X,Y,Player)."));

    for sol in prolog.query("pawn(X,Y,Player)."):

        if (sol["Player"] == 'w'):

            fenetre.blit(whitePawn, ((int)(sol["X"]) * 50, (int)(sol["Y"]) * 50));

        elif (sol["Player"] == 'b'):

            fenetre.blit(blackPawn, ((int)(sol["X"]) * 50, (int)(sol["Y"]) * 50)); 

    pygame.display.flip();

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

running = 1;

while running:

    list(prolog.query("play('b')."));

    printPawns(fenetre, back, blackPawn, whitePawn);

    time.sleep(0.5);

    list(prolog.query("play('w')."));

    printPawns(fenetre, back, blackPawn, whitePawn);

    time.sleep(0.5);
    
    for event in pygame.event.get():
        
        if event.type == pygame.QUIT:
            
            running = False

pygame.display.quit()

pygame.quit()

    










