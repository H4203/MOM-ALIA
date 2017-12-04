
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



def selectAction(pawn, onlyEatAllowed):

    display();
    fenetre.blit(selectPawnImage, (pawn[0] * 50, pawn[1] * 50));
    pygame.display.flip();

    action = ["", -1, -1];
    actionSelected = 0;

    actionType = ["'Move'", "'Eat'"];
    allowedDirectionStep = [0, 0, 0, 0];

    eatPossible = 0;

    if (onlyEatAllowed == 1):

        iActionType = 1;

    else :

        iActionType = 0;

    while (iActionType < 2) :

        for sol in prolog.query("isGoodAction(" + actionType[iActionType] + ", pawn(" + (str)(pawn[0]) + ", " + (str)(pawn[1]) + ", " + (str)(pawn[2]) + "), Direction).") :

            if (iActionType == 1 or pawn[2] == "wq" or pawn[2] == "bq" or
                (((int)(sol["Direction"]) == 0 or (int)(sol["Direction"]) == 1) and pawn[2] == "w") or
                (((int)(sol["Direction"]) == 2 or (int)(sol["Direction"]) == 3) and pawn[2] == "b")) : 

                iAllowedDirectionStep = 0;

                while (iAllowedDirectionStep < 4) :

                    if ((int)(sol["Direction"]) == iAllowedDirectionStep):

                        allowedDirectionStep[iAllowedDirectionStep] = iActionType + 1;

                        if (onlyEatAllowed == 1 and iActionType == 1) :

                            eatPossible = 1;    

                    iAllowedDirectionStep = iAllowedDirectionStep + 1;

        iActionType = iActionType + 1;

    print(allowedDirectionStep);

    if (onlyEatAllowed == 1 and eatPossible == 0):

        action[0] = "done";
        actionSelected = 1;

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

prolog.consult("damev1.3.G.pl");

list(prolog.query("init."));

display();
pygame.display.flip();

players = [["w", "1"], ["b", "2"]];
currentPlayer = 0;

i = 0;

while (i < 2) :
    
    if (players[i][1] != "Human") :

        list(prolog.query("assert(aiLevel(" + players[i][1] + ", " + players[i][0] + "))."));

    i = i + 1;

running = 1;

while (running == 1) :

    if (players[currentPlayer][0] == "w") :

        print("White Turn");

    else :

        print("Black Turn");
        
    if (players[currentPlayer][1] == "Human") :

        print("Human Player");

        action = ["cancel", -1, -1];

        while (action[0] == "cancel") :

            print("   Choosing Pawn ...");

            pawn = selectPawn(players[currentPlayer][0]);

            print("   Choosing Action ...");

            action = selectAction(pawn, 0);

            if (action[0] != "cancel") :

                list(prolog.query("applyAction(action(" + action[0] + ", " + (str)(action[1]) + ", " + (str)(action[2]) + "), " +
                                              "pawn(" + (str)(pawn[0]) + ", " + (str)(pawn[1]) + ", " + pawn[2] + "))."));

                display();
                pygame.display.flip();

            if (action[0] == "'Eat'") :

                pawn = [action[1], action[2], pawn[2]];

                while (action[0] != "done") :

                    print("   Choosing Action ...");

                    action = selectAction(pawn, 1);

                    if (action[0] != "done") :

                        list(prolog.query("applyAction(action(" + action[0] + ", " + (str)(action[1]) + ", " + (str)(action[2]) + "), " +
                                                      "pawn(" + (str)(pawn[0]) + ", " + (str)(pawn[1]) + ", " + pawn[2] + "))."));

                        display();
                        pygame.display.flip();

                        pawn = [action[1], action[2], pawn[2]];
                
    else :

        print("AI Level " + players[currentPlayer][1] + " Player");

        print("   Playing ...");

        list(prolog.query("play(" + players[currentPlayer][0] + ", " + players[currentPlayer][1] + ")."));

        time.sleep(0.2);

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

    










