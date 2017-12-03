
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



def selectActionDirection(pawn) :

    allowedActionDirection = [0, 0, 0, 0];

    for sol in prolog.query("isGoodDirection(Direction, " + pawn[2] + ").") :

        allowedActionDirection[int(sol["Direction"])] = 1;

    print allowedActionDirection

    actionDirectionSelected = 0;

    while (actionDirectionSelected == 0) :

        for event in pygame.event.get() :

            if (event.type == MOUSEMOTION) :

                display();

                mouseX = pygame.mouse.get_pos()[0] / 50;
                mouseY = pygame.mouse.get_pos()[1] / 50;

                if (allowedActionDirection[0] == 1 and mouseX == pawn[0] - 1 and mouseY == pawn[1] - 1):

                    fenetre.blit(direction0Image, ((pawn[0] - 1) * 50, (pawn[1] - 1) * 50));

                elif (allowedActionDirection[1] == 1 and mouseX == pawn[0] + 1 and mouseY == pawn[1] - 1):

                    fenetre.blit(direction1Image, ((pawn[0] + 1) * 50, (pawn[1] - 1) * 50));

                elif (allowedActionDirection[2] == 1 and mouseX == pawn[0] + 1 and mouseY == pawn[1] + 1):

                    fenetre.blit(direction2Image, ((pawn[0] + 1) * 50, (pawn[1] + 1) * 50));

                elif (allowedActionDirection[3] == 1 and mouseX == pawn[0] - 1 and mouseY == pawn[1] + 1):

                    fenetre.blit(direction3Image, ((pawn[0] - 1) * 50, (pawn[1] + 1) * 50));

                pygame.display.flip();

            if (event.type == MOUSEBUTTONDOWN) :

                mouseX = pygame.mouse.get_pos()[0] / 50;
                mouseY = pygame.mouse.get_pos()[1] / 50;

                if (allowedActionDirection[0] == 1 and mouseX == pawn[0] - 1 and mouseY == pawn[1] - 1):

                    actionDirection = 0;
                    actionDirectionSelected = 1;

                elif (allowedActionDirection[1] == 1 and mouseX == pawn[0] + 1 and mouseY == pawn[1] - 1):

                    actionDirection = 1;
                    actionDirectionSelected = 1;

                elif (allowedActionDirection[2] == 1 and mouseX == pawn[0] + 1 and mouseY == pawn[1] + 1):

                    actionDirection = 2;
                    actionDirectionSelected = 1;

                elif (allowedActionDirection[3] == 1 and mouseX == pawn[0] - 1 and mouseY == pawn[1] + 1):

                    actionDirection = 3;
                    actionDirectionSelected = 1;
               
    return actionDirection;



def selectActionType(pawn, actionDirection) :

    allowedActionType = [0, 0];

    for sol in prolog.query("isGoodAction(Type, pawn(" + str(pawn[0]) + ", " + str(pawn[1]) + ", " + pawn[2] + "), " + str(actionDirection) + ").") :

        print sol

        if (sol["Type"] == 'Eat') :

            allowedActionType[1] = 1;

        elif (sol["Type"] == 'Move') :

            allowedActionType[0] = 1;

    print pawn[2]
    print allowedActionType;

    if (allowedActionType[0] == 1 and allowedActionType[1] == 1):

        actionTypeSelected = 0;

        while (actionTypeSelected == 0) :

            for event in pygame.event.get() :

                if (event.type == pygame.KEYDOWN) :

                    if (allowedActionType[0] == 1 and event.key == pygame.K_m) :

                        actionType = "'Move'";
                        actionTypeSelected = 1;

                    if (allowedActionType[1] == 1 and event.key == pygame.K_e) :

                        actionType = "'Eat'";
                        actionTypeSelected = 1;

    elif (allowedActionType[0] == 1) :

        actionType = "'Move'";

    else :

        actionType = "'Eat'";

    return actionType;



def selectActionLength(pawn, actionDirection, actionType) :

    if (pawn[2] == "b" or pawn[2] == "w") :

        if (actionType == "'Move'") :

            actionLength = 1;

        else : 

            actionLength = 2;

    else :

        actionLength = input();

    return actionLength;



def selectAction(pawn) :

    actionDirection = selectActionDirection(pawn);

    actionType = selectActionType(pawn, actionDirection);
    
    actionLength = selectActionLength(pawn, actionDirection, actionType);

    if (actionDirection == 0) :

        action = [actionType, pawn[0] - actionLength, pawn[1] - actionLength];

    elif (actionDirection == 1) :

        action = [actionType, pawn[0] + actionLength, pawn[1] - actionLength];

    elif (actionDirection == 2) :

        action = [actionType, pawn[0] + actionLength, pawn[1] + actionLength];

    elif (actionDirection == 3) :

        action = [actionType, pawn[0] - actionLength, pawn[1] + actionLength];
    
    return action;



pygame.init();

global fenetre;

global backImage;
global blackPawnImage;
global blackQueenImage;
global whitePawnImage;
global whiteQueenImage;
global selectPawnImage;
global direction0Image;
global direction1Image;
global direction2Image;
global direction3Image;
global selectDestImage;

fenetre = pygame.display.set_mode((500, 500));

backImage = pygame.image.load("Back.png").convert();
blackPawnImage = pygame.image.load("BlackPawn.png").convert_alpha();
blackQueenImage = pygame.image.load("BlackQueen.png").convert_alpha();
whitePawnImage = pygame.image.load("WhitePawn.png").convert_alpha();
whiteQueenImage = pygame.image.load("WhiteQueen.png").convert_alpha();
selectPawnImage = pygame.image.load("SelectPawn.png").convert_alpha();
direction0Image = pygame.image.load("Direction0.png").convert_alpha();
direction1Image = pygame.image.load("Direction1.png").convert_alpha();
direction2Image = pygame.image.load("Direction2.png").convert_alpha();
direction3Image = pygame.image.load("Direction3.png").convert_alpha();
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

        action = selectAction(pawn);

        list(prolog.query("applyAction(action(" + action[0] + ", " + (str)(action[1]) + ", " + (str)(action[2]) + "), " +
                                              "pawn(" + (str)(pawn[0]) + ", " + (str)(pawn[1]) + ", " + pawn[2] + "))."));
                
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

    










