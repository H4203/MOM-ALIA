
from pyswip import *

import pygame
from pygame.locals import *

import time



def display() :

    fenetre.blit(backImage, (0,0));

    for sol in prolog.query("pawn(X, Y, Player)."):

        if (sol["Player"] == 'w'):

            fenetre.blit(whitePawnImage, ((int)(sol["X"]) * 50, (int)(sol["Y"]) * 50));

        if (sol["Player"] == 'wq'):

            fenetre.blit(whiteQueenImage, ((int)(sol["X"]) * 50, (int)(sol["Y"]) * 50));

        elif (sol["Player"] == 'b'):

            fenetre.blit(blackPawnImage, ((int)(sol["X"]) * 50, (int)(sol["Y"]) * 50));

        elif (sol["Player"] == 'bq'):

            fenetre.blit(blackQueenImage, ((int)(sol["X"]) * 50, (int)(sol["Y"]) * 50)); 

    return;



def selectPawn(playerColor) :

    display();

    pygame.display.flip();

    pawn = [0, 0, playerColor];
    pawnSelected = 0;

    while (pawnSelected == 0) :

        for event in pygame.event.get() :

            mouseX = pygame.mouse.get_pos()[0] / 50;
            mouseY = pygame.mouse.get_pos()[1] / 50; 

            if (event.type == pygame.MOUSEMOTION) :

                display();

                for sol in prolog.query("pawn(" + (str)(mouseX) + ", " + str(mouseY) + ", Role).") :

                    if (sol["Role"] == playerColor or sol["Role"] == playerColor + "q"):

                        fenetre.blit(selectPawnImage, (mouseX * 50, mouseY * 50));
                                                       
                        pygame.display.flip();

            if (event.type == pygame.MOUSEBUTTONDOWN) :

                for sol in prolog.query("pawn(" + (str)(mouseX) + ", " + str(mouseY) + ", Role).") :

                    if (sol["Role"] == playerColor or sol["Role"] == playerColor + "q"):

                        pawn[0] = mouseX;
                        pawn[1] = mouseY;
                        pawn[2] = sol["Role"];

                        pawnSelected = 1;

    return pawn;



def selectAction(pawn):

    display();

    fenetre.blit(selectPawnImage, (pawn[0] * 50, pawn[1] * 50));

    pygame.display.flip();

    action = [0, 0, 0];
    actionSelected = 0;

    while (actionSelected == 0) :

        for event in pygame.event.get() :

            if (event.type == KEYDOWN) :

                if (event.key == K_RETURN) :

                    action[0] = "done";
                    actionSelected = 1;

            if (event.type == MOUSEMOTION) :

                mouseX = pygame.mouse.get_pos()[0] / 50;
                mouseY = pygame.mouse.get_pos()[1] / 50;

                display();

                fenetre.blit(selectPawnImage, (pawn[0] * 50, pawn[1] * 50));

                fenetre.blit(selectDestImage, (mouseX * 50, mouseY * 50));

                pygame.display.flip();

            elif (event.type == MOUSEBUTTONDOWN) :

                action[0] = "'Move'";
                action[1] = mouseX;
                action[2] = mouseY;

                for sol in prolog.query("pawn(X, Y, Role).") :

                    if (int(sol["X"]) == mouseX and int(sol["Y"]) == mouseY) :

                        action[0] = "'Eat'";
                        action[1] = 2*mouseX - pawn[0];
                        action[2] = 2*mouseY - pawn[1];

                actionSelected = 1;

    return action;

    

pygame.init();

global fenetre;

global backImage;
global blackPawnImage;
global blackQueenImage;
global whitePawnImage;
global whiteQueenImage;
global selectPawnImage;
global selectDestImage;

fenetre = pygame.display.set_mode((500, 500));

backImage = pygame.image.load("Back.png").convert();
blackPawnImage = pygame.image.load("BlackPawn.png").convert_alpha();
blackQueenImage = pygame.image.load("BlackQueen.png").convert_alpha();
whitePawnImage = pygame.image.load("WhitePawn.png").convert_alpha();
whiteQueenImage = pygame.image.load("WhiteQueen.png").convert_alpha();
selectPawnImage = pygame.image.load("SelectPawn.png").convert_alpha();
selectDestImage = pygame.image.load("SelectDest.png").convert_alpha();



prolog = Prolog();

prolog.consult("damev1.3.Graphique.pl");

list(prolog.query("init."));

display();
pygame.display.flip();

players = [["w", "Human"], ["b", "Human"]];
currentPlayer = 0;

running = 1;

while (running == 1) :

    if (players[currentPlayer][1] == "Human") :

        pawn = selectPawn(players[currentPlayer][0]);

        action = ["", 0, 0];

        while (action[0] != "done") :

            action = selectAction(pawn);

            if (action != "done"):

                list(prolog.query("applyAction(action(" + action[0] + ", " + str(action[1]) + ", " + str(action[2]) + "), " +
                                               "pawn(" + str(pawn[0]) + ", " + str(pawn[1]) + ", " + pawn[2] + "))."));

                pawn = [action[1], action[2], pawn[2]];

    else :

        list(prolog.query("play(" + players[currentPlayer][0] + ", " + players[currentPlayer][1] + ")."));

    display();
    pygame.display.flip();

    if (currentPlayer == 0) :
        
        currentPlayer = 1;
        
    else :
        
        currentPlayer = 0;
    
    for event in pygame.event.get() :

        if (event.type == pygame.QUIT) :

            running = 0;
        
        if (event.type == pygame.KEYDOWN) :

            if (event.key == pygame.K_ESCAPE) :

                running = 0;

pygame.display.quit()

pygame.quit()

    










