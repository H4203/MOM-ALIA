
from pyswip import *

import pygame
from pygame.locals import *

import time



def display() :

    fenetre.blit(backImage, (0,0));

    for sol in prolog.query("pawn(X, Y, Player)."):

        if (sol["Player"] == 'w'):

            fenetre.blit(whitePawnImage, ((int)(sol["X"]) * 50, (int)(sol["Y"]) * 50));

        elif (sol["Player"] == 'b'):

            fenetre.blit(blackPawnImage, ((int)(sol["X"]) * 50, (int)(sol["Y"]) * 50)); 

    return;



def selectPawn(playerColor) :

    pawn = [0, 0, playerColor];

    pawnSelected = 0;

    display();
    pygame.display.flip();

    while (pawnSelected == 0) :

        for event in pygame.event.get() :

            mouseX = pygame.mouse.get_pos()[0] / 50;
            mouseY = pygame.mouse.get_pos()[1] / 50; 

            if (event.type == pygame.MOUSEMOTION) :

                display();

                for sol in prolog.query("pawn(" + (str)(mouseX) + ", " + str(mouseY) + ", " + playerColor + ").") :

                    fenetre.blit(selectPawnImage, (mouseX * 50, mouseY * 50));
                                                       
                pygame.display.flip();

            if (event.type == pygame.MOUSEBUTTONDOWN) :

                for sol in prolog.query("pawn(" + (str)(mouseX) + ", " + str(mouseY) + ", " + playerColor + ").") :

                    pawn[0] = mouseX;
                    pawn[1] = mouseY;

                    pawnSelected = 1;

    return pawn;



def selectAction(pawn, onlyEatAllowed):

    action = ["", -1, -1];

    actionSelected = 0;

    actionType = ["'Move'", "'Eat'"];
    allowedDirectionStep = [0, 0, 0, 0];

    if (onlyEatAllowed == 1):

        iActionType = 1;

    else :

        iActionType = 0;

    while (iActionType < 2) :

        for sol in prolog.query("isGoodAction(" + actionType[iActionType] + ", pawn(" + (str)(pawn[0]) + ", " + (str)(pawn[1]) + ", " + (str)(pawn[2]) + "), Direction).") :

            if ((((int)(sol["Direction"]) == 0 or (int)(sol["Direction"]) == 1) and pawn[2] == "'w'") or
                (((int)(sol["Direction"]) == 2 or (int)(sol["Direction"]) == 3) and pawn[2] == "'b'")): 

                iAllowedDirectionStep = 0;

                while (iAllowedDirectionStep < 4) :

                    if ((int)(sol["Direction"]) == iAllowedDirectionStep):

                        allowedDirectionStep[iAllowedDirectionStep] = iActionType + 1;

                    iAllowedDirectionStep = iAllowedDirectionStep + 1;

        iActionType = iActionType + 1;

    while (actionSelected == 0) :

        for event in pygame.event.get() :

            display();

            fenetre.blit(selectPawnImage, (pawn[0] * 50, pawn[1] * 50));

            if (event.type == pygame.KEYDOWN) :

                if (event.key == pygame.K_RETURN) :

                    action[0] = "done";

                    actionSelected = 1;

                if (event.key == pygame.K_ESCAPE) :

                    if (onlyEatAllowed == 1) :

                        action[0] = "done";

                    else :

                        action[0] = "cancel";

                    actionSelected = 1;

            if (event.type == pygame.MOUSEMOTION) :

                mouseX = pygame.mouse.get_pos()[0] / 50;
                mouseY = pygame.mouse.get_pos()[1] / 50;

                if (allowedDirectionStep[0] != 0 and mouseX == pawn[0] - allowedDirectionStep[0] and mouseY == pawn[1] - allowedDirectionStep[0]) :

                    fenetre.blit(selectDestImage, (mouseX * 50, mouseY * 50));

                elif (allowedDirectionStep[1] != 0 and mouseX == pawn[0] + allowedDirectionStep[1] and mouseY == pawn[1] - allowedDirectionStep[1]) :

                    fenetre.blit(selectDestImage, (mouseX * 50, mouseY * 50));

                elif (allowedDirectionStep[2] != 0 and mouseX == pawn[0] - allowedDirectionStep[2] and mouseY == pawn[1] + allowedDirectionStep[2]) :

                    fenetre.blit(selectDestImage, (mouseX * 50, mouseY * 50));

                elif (allowedDirectionStep[3] != 0 and mouseX == pawn[0] + allowedDirectionStep[3] and mouseY == pawn[1] + allowedDirectionStep[3]) :

                    fenetre.blit(selectDestImage, (mouseX * 50, mouseY * 50));

                pygame.display.flip();

            if (event.type == pygame.MOUSEBUTTONDOWN) :

                if (allowedDirectionStep[0] != 0 and mouseX == pawn[0] - allowedDirectionStep[0] and mouseY == pawn[1] - allowedDirectionStep[0]) :

                    action[0] = allowedDirectionStep[0];
                    action[1] = pawn[0] - allowedDirectionStep[0];
                    action[2] = pawn[1] - allowedDirectionStep[0];

                    actionSelected = 1;
                    
                elif (allowedDirectionStep[1] != 0 and mouseX == pawn[0] + allowedDirectionStep[1] and mouseY == pawn[1] - allowedDirectionStep[1]) :

                    action[0] = allowedDirectionStep[1];
                    action[1] = pawn[0] + allowedDirectionStep[1];
                    action[2] = pawn[1] - allowedDirectionStep[1];

                    actionSelected = 1;
                       
                elif (allowedDirectionStep[2] != 0 and mouseX == pawn[0] - allowedDirectionStep[2] and mouseY == pawn[1] + allowedDirectionStep[2]) :

                    action[0] = allowedDirectionStep[2];
                    action[1] = pawn[0] - allowedDirectionStep[2];
                    action[2] = pawn[1] + allowedDirectionStep[2];

                    actionSelected = 1;
                       
                elif (allowedDirectionStep[3] != 0 and mouseX == pawn[0] + allowedDirectionStep[3] and mouseY == pawn[1] + allowedDirectionStep[3]) :

                    action[0] = allowedDirectionStep[3];
                    action[1] = pawn[0] + allowedDirectionStep[3];
                    action[2] = pawn[1] + allowedDirectionStep[3];

                    actionSelected = 1;

    if (action[0] == 1) :

        action[0] = "'Move'";

    elif (action[0] == 2) :

        action[0] = "'Eat'";

    return action;



pygame.init();

global fenetre;

global backImage;
global blackPawnImage;
global whitePawnImage;
global selectPawnImage;
global selectDestImage;

fenetre = pygame.display.set_mode((500, 500));

backImage = pygame.image.load("Back.png").convert();
blackPawnImage = pygame.image.load("BlackPawn.png").convert_alpha();
whitePawnImage = pygame.image.load("WhitePawn.png").convert_alpha();
selectPawnImage = pygame.image.load("SelectPawn.png").convert_alpha();
selectDestImage = pygame.image.load("SelectDest.png").convert_alpha();



prolog = Prolog();

prolog.consult("damev1.3.Graphique.pl");

list(prolog.query("init."));

display();
pygame.display.flip();

players = [["'w'", "Human"], ["'b'", "2"]];
currentPlayer = 0;

running = 1;

while (running == 1) :

    if (players[currentPlayer][1] == "Human") :

        action = ["cancel", -1, -1];

        while (action[0] == "cancel") :

            pawn = selectPawn(players[currentPlayer][0]);

            action = selectAction(pawn, 0);

            if (action[0] != "cancel") :

                list(prolog.query("applyAction(action(" + action[0] + ", " + (str)(action[1]) + ", " + (str)(action[2]) + "), " +
                                              "pawn(" + (str)(pawn[0]) + ", " + (str)(pawn[1]) + ", " + pawn[2] + "))."));

            if (action[0] == "'Eat'") :

                pawn = [action[1], action[2], pawn[2]];

                while (action[0] != "done") :

                    action = selectAction(pawn, 1);

                    if (action[0] != "done") :

                        list(prolog.query("applyAction(action(" + action[0] + ", " + (str)(action[1]) + ", " + (str)(action[2]) + "), " +
                                                      "pawn(" + (str)(pawn[0]) + ", " + (str)(pawn[1]) + ", " + pawn[2] + "))."));

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

    










