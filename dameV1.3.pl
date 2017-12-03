:- dynamic pawn/3.
:- dynamic action/3.
:- dynamic aiLevel/2.

noWhitePawn :- not(pawn(_,_,'w')).
noWhiteQueen :- not(pawn(_,_,'wq')).
noBlackPawn :- not(pawn(_,_,'b')).
noBlackQueen :- not(pawn(_,_,'bq')).


gameover :- noWhitePawn,noWhiteQueen,
     writeln(''), writeln('Les noirs ont gagne'),displayBoard.
gameover :- noBlackPawn, noBlackQueen,
     writeln(''),writeln('Les blancs ont gagne'),displayBoard.

printVal(Y,X) :- pawn(X,Y,Val), write('\t'), write(Val), write('\t'),!.  %, var(Val)
printVal(_,_) :- write('\t_\t'). %,nonvar(Val)

displayBoard :-
     findall(_, partialDisplayBoard, _), writeln('').

partialDisplayBoard :-
    between(0, 9, I), writeln(''),
    between(0, 9, J),
    printVal(I,J).

% do not delete needed to make applyEat work properly
otherPlayer('b','w').
otherPlayer('w','b').
otherPlayer('bq','w').
otherPlayer('wq','b').
otherPlayer('b','wq').
otherPlayer('w','bq').
otherPlayer('bq','wq').
otherPlayer('wq','bq').


nextPlayer('b','w').
nextPlayer('w','b').
applyEat(Action, Pawn) :-

    Action = action(_, XDest, YDest),
    Pawn = pawn(X, Y, Player),
    XE is (XDest + X) / 2,
    YE is (YDest + Y) / 2,
    otherPlayer(Player, NextPlayer),
    retract(pawn(XE, YE, NextPlayer)).

% turn pawn to a queen if it reach the end of the board
applyMove(Action, Pawn) :-

    Action = action(_, XDest, YDest),
    Pawn = pawn(X, Y, Player), write(Player),

    retract(pawn(X, Y, Player)), write('ici'),
    (
       (
       ( (YDest \== 9, isSameGroup(Player,'bq'));(YDest \== 0, isSameGroup(Player,'wq')) ),
        write('la'),assert(pawn(XDest, YDest, Player))
       );
    ( YDest == 0, isSameGroup(Player,'wq'), assert(pawn(XDest, YDest, 'wq')) );
    ( YDest == 9, isSameGroup(Player,'bq'),assert(pawn(XDest, YDest, 'bq')) )
    ) .

applyAction(Action, Pawn) :-

    Action = action(Type, XDest, YDest),
    Pawn = _,

    Type == 'Move', applyMove(Action, Pawn),

    retract(action(Type, XDest, YDest)).

applyAction(Action, Pawn) :-

    Action = action(Type, XDest, YDest),
    Pawn = _,

    (Type == 'Eat', write(Type), write(XDest), writeln(YDest), writeln('test2'), applyEat(Action, Pawn)),

    applyMove(Action, Pawn),

    retract(action(Type, XDest, YDest)).

applyActions([], _).

applyActions(Actions, Pawn) :-

    Actions = [Head|Tail],

    applyAction(Head, Pawn),
    applyActions(Tail, Pawn).

play(_,_) :- gameover.
play(Player,1) :- write('New turn for:'), writeln(Player),
    displayBoard,
    ai(1,Player,Pawn,ActionList),
    applyActions(ActionList,Pawn),
    nextPlayer(Player,NextPlayer),
    aiLevel(NewL,NextPlayer),
    play(NextPlayer,NewL).
play(Player,L) :- write('New turn for:'), writeln(Player),
    L > 1,
    displayBoard,
    ai(L,Player,_,NewBoard),
    applyNewBoard(NewBoard),
    nextPlayer(Player,NextPlayer),
    aiLevel(NewL,NextPlayer),
    play(NextPlayer,NewL).
init :-
    retractall(pawn(_,_,_)),retractall(action(_,_,_)),
    assert(pawn(1,0,'b')), assert(pawn(3,0,'b')), assert(pawn(5,0,'b')), assert(pawn(7,0,'b')), assert(pawn(9,0,'b')),
    assert(pawn(0,1,'b')), assert(pawn(2,1,'b')), assert(pawn(4,1,'b')), assert(pawn(6,1,'b')), assert(pawn(8,1,'b')),
    assert(pawn(1,2,'b')), assert(pawn(3,2,'b')), assert(pawn(5,2,'b')), assert(pawn(7,2,'b')), assert(pawn(9,2,'b')),
    assert(pawn(0,3,'b')), assert(pawn(2,3,'b')), assert(pawn(4,3,'b')), assert(pawn(6,3,'b')), assert(pawn(8,3,'b')),

    assert(pawn(1,6,'w')), assert(pawn(3,6,'w')), assert(pawn(5,6,'w')), assert(pawn(7,6,'w')), assert(pawn(9,6,'w')),
    assert(pawn(0,7,'w')), assert(pawn(2,7,'w')), assert(pawn(4,7,'w')), assert(pawn(6,7,'w')), assert(pawn(8,7,'w')),
    assert(pawn(1,8,'w')), assert(pawn(3,8,'w')), assert(pawn(5,8,'w')), assert(pawn(7,8,'w')), assert(pawn(9,8,'w')),
    assert(pawn(0,9,'w')), assert(pawn(2,9,'w')), assert(pawn(4,9,'w')), assert(pawn(6,9,'w')), assert(pawn(8,9,'w')),
    aiLevel(L,'w'),
    play('w',L).

%-------------------------------
setAiLevel(L,'w') :- retractall(aiLevel(_,'w')),assert(aiLevel(L,'w')).
setAiLevel(L,'b') :- retractall(aiLevel(_,'b')),assert(aiLevel(L,'b')).
%-------------------------------
isSameGroup('w','w').
isSameGroup('wq','w').
isSameGroup('w','wq').
isSameGroup('wq','wq').

isSameGroup('b','b').
isSameGroup('bq','b').
isSameGroup('b','bq').
isSameGroup('bq','bq').

%-------------------------------

% direction 0:up-left 1:up-right 2:down-left 3:down-right
isGoodDirection(0,'w').
isGoodDirection(1,'w').
isGoodDirection(2,'b').
isGoodDirection(3,'b').
isGoodDirection(_,'wq').
isGoodDirection(_,'bq').


computeNewPosition(0,NumberOfCases,OldX,OldY,NewX,NewY):-NewX is OldX-NumberOfCases, NewY is OldY-NumberOfCases.
computeNewPosition(1,NumberOfCases,OldX,OldY,NewX,NewY):-NewX is OldX+NumberOfCases, NewY is OldY-NumberOfCases.
computeNewPosition(2,NumberOfCases,OldX,OldY,NewX,NewY):-NewX is OldX-NumberOfCases, NewY is OldY+NumberOfCases.
computeNewPosition(3,NumberOfCases,OldX,OldY,NewX,NewY):-NewX is OldX+NumberOfCases, NewY is OldY+NumberOfCases.

numberToType('Eat',0).
numberToType('Move',1).

choosePawn(Player,pawn(X,Y,Role)):-
    repeat,
    X is random(10),
    Y is random(10),
    pawn(X,Y,Role),
    isSameGroup(Role,Player),!.

 isGoodAction('Eat',pawn(X,Y,Role),Direction):-
    computeNewPosition(Direction,1,X,Y,NewX1,NewY1),
    NewX1>=0,NewX1<10,NewY1>=0,NewY1<10,
    pawn(NewX1,NewY1,NewRole1),
    not(isSameGroup(Role,NewRole1)),
    computeNewPosition(Direction,2,X,Y,NewX2,NewY2),
    NewX2>=0,NewX2<10,NewY2>=0,NewY2<10,
    not(pawn(NewX2,NewY2,_)),write(NewX2),write(NewY2).

 isGoodAction('Move',pawn(X,Y,_),Direction):-
    computeNewPosition(Direction,1,X,Y,NewX1,NewY1),
    NewX1>=0,NewX1<10,NewY1>=0,NewY1<10,
    not(pawn(NewX1,NewY1,_)), write(NewX1),write(NewY1).

chooseAction(pawn(X,Y,Role),ActionList):-
%    Direction is random(4), write('Direction'), writeln(Direction),
    isGoodDirection(Direction,Role),
%    Random is random(2),write('Random'),
    between(0,1,Random),
    numberToType(Type,Random),
    isGoodAction(Type,pawn(X,Y,Role),Direction),
    createAction(Type,X,Y,Role,Direction,ActionList), writeln('createAction done')    ,

    !.


createAction('Eat',X,Y,Role,Direction,ActionList):-
    write('eat'),
    computeNewPosition(Direction,1,X,Y,NewX,NewY),
    computeNewPosition(Direction,2,X,Y,XDest,YDest),
    appendAction([action('Eat',XDest,YDest)],[],ActionList),
    assert(action('Eat',XDest,YDest)),
    pawn(NewX,NewY,NewRole),
    cantEatMore([pawn(NewX,NewY,NewRole)], XDest, YDest, Role, ActionList)
    .

createAction('Move',X,Y,_,Direction,ActionList):-
    write('move'),
    computeNewPosition(Direction,1,X,Y,XDest,YDest),
    appendAction([action('Move',XDest,YDest)],[],ActionList), assert(action('Move',XDest,YDest)).

appendAction([],L,L).
appendAction([H|T],L,[H|B]) :- append(T,L,B).

%appendAction([],L,L).
%appendAction([action(Type,X,Y)|T],L,[action(Type,X,Y)|B]) :- appendAction(T,L,B).
canEat(Direction,AlreadyEaten, X, Y, Role) :-
            write(X),write(Y),
            computeNewPosition(Direction,1,X,Y,NewX0,NewY0),
            Direction >= 0, Direction < 4,
            NewX0>=0,NewX0<10,NewY0>=0,NewY0<10,
            pawn(NewX0,NewY0,NewRole0),
            not(isSameGroup(Role,NewRole0)),
            computeNewPosition(0,2,X,Y,NewX02,NewY02),
            NewX02>=0,NewX02<10,NewY02>=0,NewY02<10,
            not(pawn(NewX02,NewY02,_)),
            not(member(pawn(NewX0,NewY0,NewRole0),AlreadyEaten)) .

cantEatMore(AlreadyEaten, X, Y, Role, _) :-
            not(canEat(0,AlreadyEaten, X, Y, Role)),
            not(canEat(1,AlreadyEaten, X, Y, Role)),
            not(canEat(2,AlreadyEaten, X, Y, Role)),
            not(canEat(3,AlreadyEaten, X, Y, Role)),!.
cantEatMore(AlreadyEaten, X, Y, Role, ActionList) :-
    computeNewPosition(Direction,1,X,Y,NewX,NewY),
    NewX>=0,NewX<10,NewY>=0,NewY<10,
    pawn(NewX,NewY,NewRole),
    not(isSameGroup(Role,NewRole)),
    member(pawn(NewX,NewY,NewRole),AlreadyEaten),
    computeNewPosition(Direction,2,X,Y,NewX2,NewY2),
    NewX2>=0,NewX2<10,NewY2>=0,NewY2<10,
    not(pawn(NewX2,NewY2,_)),

    %-----------------------------------------------------------------------------
    %------------------NewActionList is le return of the fonction
    appendAction(action('Eat', NewX2, NewY2),ActionList,NewActionList),
    %-----------------------------------------------------------------------------

    cantEatMore([pawn(NewX,NewY,NewRole)|AlreadyEaten],NewX2, NewY2,Role,NewActionList),
    !.


ai(1,Player,pawn(X,Y,Role),ActionList):-writeln(''),repeat,
    choosePawn(Player,pawn(X,Y,Role)),
    chooseAction(pawn(X,Y,Role),ActionList),
    write('I Choose '),write(X),write(Y),writeln(Role),!.
%do not choose a pawn it just do the best move
ai(2,Player,_,NewBoard) :-
    createBoard(Board),
    minimax([Player,'Playing',Board], [Player,_,NewBoard], _, 0,2)
    .
%do not choose a pawn it just do the best move
ai(3,Player,_,NewBoard) :-
    createBoard(Board),
    minimax([Player,'Playing',Board], [Player,_,NewBoard], _, 0,4)
    .
%do not choose a pawn it just do the best move
ai(4,Player,_,NewBoard) :-
    createBoard(Board),
    minimax([Player,'Playing',Board], [Player,_,NewBoard], _, 0,6)
    .
    %do not choose a pawn it just do the best move
ai(5,Player,_,NewBoard) :-
    createBoard(Board),
    minimax([Player,'Playing',Board], [Player,_,NewBoard], _, 0,8)
    .


% create a list of all pawn on the field
createBoard(Board) :-
    bagof(Element, addElementToBoard(Element), Board)
    .
addElementToBoard(Element) :-
    between(0,9,I),
    between(0,9,J),
    pawn(I,J,Role),
    Element = [I,J,Role].

% move eat
move([CurrentPlayer,State,Board], [CurrentPlayer,State,NewBoard]) :-
    between(0,9,I),
    between(0,9,J),
    between(0,3,Direction),
    nth0(_,Board,[I,J,Role]), isSameGroup(Role,CurrentPlayer),
    isGoodDirection(Direction,Role),canEatMinMax(Direction,Board, I, J, Role),
    eatMinMax(Board,NewBoard,Direction,I,J,Role)
    .

% move move
move([CurrentPlayer,State,Board], [CurrentPlayer,State,NewBoard]) :-
    not(bagof(_,mustEat(CurrentPlayer,Board),_)),
    between(0,9,I),
    between(0,9,J),
    between(0,3,Direction),
    nth0(_,Board,[I,J,Role]), isSameGroup(Role,CurrentPlayer),
    isGoodDirection(Direction,Role),canMoveMinMax(Direction, Board, I, J, Role),
    moveMinMax(Board,NewBoard,Direction,I,J,Role)
    .
%test if a pawn must be eaten or not
mustEat(Player,Board) :-
    between(0,9,I),
    between(0,9,J),
    between(0,3,Direction),
    nth0(_,Board,[I,J,Role]), isSameGroup(Role,Player),
    isGoodDirection(Direction,Role),canEatMinMax(Direction,Board, I, J, Role)
    .
% test
canEatMinMax(Direction,Board, X, Y, Role) :-
    computeNewPosition(Direction,1,X,Y,NewX,NewY),
    NewX>=0,NewX<10,NewY>=0,NewY<10,
    nth0(_,Board,[NewX,NewY,NewRole]),
    not(isSameGroup(Role,NewRole)),
    computeNewPosition(Direction,2,X,Y,NewX2,NewY2),
    NewX2>=0,NewX2<10,NewY2>=0,NewY2<10,
    not(nth0(_,Board,[NewX2,NewY2,_])).

canMoveMinMax(Direction, Board, X, Y, _) :-
    computeNewPosition(Direction,1,X,Y,NewX,NewY),
    NewX>=0,NewX<10,NewY>=0,NewY<10,
    not(nth0(_,Board,[NewX,NewY,_])).

% do
eatMinMax(Board,NewBoard,Direction,X,Y,Role) :-
    computeNewPosition(Direction,1,X,Y,NewX,NewY),
    delete(Board,[NewX,NewY,_],BoardWithoutEatenPawn),
    computeNewPosition(Direction,2,X,Y,NewX2,NewY2), % new postition of pawn
    delete(BoardWithoutEatenPawn,[X,Y,Role],BoardWithoutSelectedPawn),
    isQueen(NewX2,NewY2,Role,NewRole),
    append(BoardWithoutSelectedPawn,[[NewX2,NewY2,NewRole]],ActualBoard),
    eatMoreMinMax(ActualBoard,NewBoard,NewX2,NewY2,NewRole)
    .
isQueen(_,NewY,Role,NewRole) :-
     isSameGroup(Role,'b'),
     NewY == 9,
     NewRole = 'bq'
     .

isQueen(_,NewY,Role,NewRole) :-
     isSameGroup(Role,'w'),
     NewY == 0,
     NewRole = 'wq'
     .
isQueen(_,NewY,Role,Role) :-
     isSameGroup(Role,'b'),
     NewY \== 9
     .
isQueen(_,NewY,Role,Role) :-
     isSameGroup(Role,'w'),
     NewY \== 0
     .

moveMinMax(Board,NewBoard,Direction,X,Y,Role) :-
    computeNewPosition(Direction,1,X,Y,NewX,NewY),
    delete(Board,[X,Y,Role],BoardWithoutSelectedPawn),
    isQueen(NewX,NewY,Role,NewRole),
    append(BoardWithoutSelectedPawn,[[NewX,NewY,NewRole]],NewBoard)
    .
eatMoreMinMax(Board,Board,X,Y,Role) :-
    not(canEatMinMax(0,Board, X, Y, Role)),
    not(canEatMinMax(1,Board, X, Y, Role)),
    not(canEatMinMax(2,Board, X, Y, Role)),
    not(canEatMinMax(3,Board, X, Y, Role)),
    !.
eatMoreMinMax(Board,NewBoard,X,Y,Role) :-
    computeNewPosition(Direction,1,X,Y,NewX,NewY),
    canEatMinMax(Direction,Board, X, Y, Role),
    delete(Board,[NewX,NewY,_],BoardWithoutEatenPawn),
    computeNewPosition(Direction,2,X,Y,NewX2,NewY2), % new postition of pawn
    delete(BoardWithoutEatenPawn,[X,Y,Role],BoardWithoutSelectedPawn),
    isQueen(NewX2,NewY2,Role,NewRole),
    append(BoardWithoutSelectedPawn,[[NewX2,NewY2,NewRole]],ActualBoard),
    eatMoreMinMax(ActualBoard,NewBoard,NewX2,NewY2,NewRole),!
    .


% Pos position of the board : [CurrentPlayer,State,Board]

minimax(Pos, BestNextPos, Val, Deep, EndDeep) :-                     % Pos has successors
    Deep \== EndDeep,
    bagof(NextPos, move(Pos, NextPos), NextPosList),
    best(NextPosList, BestNextPos, Val, Deep, EndDeep),
    !.
minimax(Pos, BestNextPos, Val, Deep, EndDeep) :-                     % Pos has successors
    Deep \== EndDeep,
    not(bagof(NextPos, move(Pos, NextPos), NextPosList)),
    utility(Pos, Val)
    !.

minimax(Pos, _, Val, EndDeep, EndDeep) :-                     % Pos has no successors
    utility(Pos, Val)
    .

best([Pos], Pos, Val, Deep, EndDeep) :-                                % There is no more position to compare
    NewDeep is (Deep +1),
    minimax(Pos, _, Val, NewDeep, EndDeep),
    !.

best([Pos1 | PosList], BestPos, BestVal, Deep, EndDeep) :-             % There are other positions to compare
    NewDeep is (Deep +1),
    minimax(Pos1, _, Val1, NewDeep, EndDeep),
    best(PosList, Pos2, Val2, Deep, EndDeep),
    betterOf(Pos1, Val1, Pos2, Val2, BestPos, BestVal,Deep).

betterOf(Pos0, Val0, _, Val1, Pos0, Val0, Deep) :-   % Pos0 better than Pos1
    min_to_move(Pos0,Deep),                         % MIN to move in Pos0
    Val0 > Val1, !.                            % MAX prefers the greater value

betterOf(Pos0, Val0, _, Val1, Pos0, Val0 , Deep) :-   % Pos0 better than Pos1
    max_to_move(Pos0,Deep),                         % MAX to move in Pos0
    Val0 < Val1, !.                            % MIN prefers the lesser value

betterOf(_, _, Pos1, Val1, Pos1, Val1, _).        % Otherwise Pos1 better than Pos0

min_to_move(_, Deep) :-
    0 is mod(Deep,2).

max_to_move(_, Deep) :-
    1 is mod(Deep,2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% board evaluation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% pawn_value(+player, +pawn, -value)
pawnValue('w', 'w', 1).
pawnValue('w', 'b', -1).
pawnValue('w', 'wq', 5).
pawnValue('w', 'bq', -5).
pawnValue('b', 'w', -1).
pawnValue('b', 'b', 1).
pawnValue('b', 'wq', -5).
pawnValue('b', 'bq', 5).

% board_weight(+pawn,+X,+Y,-value).
boardWeight('w',0,_,5).
boardWeight('w',1,_,4).
boardWeight('w',2,_,3).
boardWeight('w',3,_,2).
boardWeight('w',6,_,2).
boardWeight('w',7,_,3).
boardWeight('w',8,_,4).
boardWeight('w',9,_,5).
boardWeight('w',_,_,1).

boardWeight('b',0,_,5).
boardWeight('b',1,_,4).
boardWeight('b',2,_,3).
boardWeight('b',3,_,2).
boardWeight('b',6,_,2).
boardWeight('b',7,_,3).
boardWeight('b',8,_,4).
boardWeight('b',9,_,5).
boardWeight('b',_,_,1).

boardWeight('bq',_,0,1).
boardWeight('bq',_,1,2).
boardWeight('bq',_,2,3).
boardWeight('bq',_,3,4).
boardWeight('bq',_,6,4).
boardWeight('bq',_,7,3).
boardWeight('bq',_,8,2).
boardWeight('bq',_,9,1).
boardWeight('bq',_,_,5).

boardWeight('wq',_,0,1).
boardWeight('wq',_,1,2).
boardWeight('wq',_,2,3).
boardWeight('wq',_,3,4).
boardWeight('wq',_,6,4).
boardWeight('wq',_,7,3).
boardWeight('wq',_,8,2).
boardWeight('wq',_,9,1).
boardWeight('wq',_,_,5).
boardWeight(_,_,_,1).

% synonym : utility == evaluateBoard

% win situation
utility(Pos,Val):-
    winBoard(Pos,Val).

utility(Pos,Val):-
    evaluateBoard(Pos,Val).

winBoard(['b',_,Board],1000) :-
     noWhitePawn(Board),noWhiteQueen(Board)
     .
winBoard(['b',_,Board],-1000) :-
     noBlackPawn(Board),noBlackQueen(Board)
     .
winBoard(['w',_,Board],-1000) :-
     noWhitePawn(Board),noWhiteQueen(Board)
     .
winBoard(['w',_,Board],1000) :-
     noBlackPawn(Board),noBlackQueen(Board)
     .
noWhitePawn(Board) :-
     not(member([_,_,'w'],Board)).

noWhiteQueen(Board) :-
     not(member([_,_,'wq'],Board)).

noBlackPawn(Board) :-
     not(member([_,_,'b'],Board)).

noBlackQueen(Board) :-
     not(member([_,_,'bq'],Board)).

evaluateBoard([Player,_,[[X,Y,Pawn]]],Val):-
	pawnValue(Player,Pawn, PawnValue),
        boardWeight(Pawn,X,Y,Weight),
	Val is PawnValue * Weight.


evaluateBoard([Player,State,[[X,Y,Pawn]|Tail]], Val) :-
        pawnValue(Player,Pawn, PawnValue),
        boardWeight(Pawn,X,Y,Weight),
	evaluateBoard([Player,State,Tail], Eval),
	Val is Eval + PawnValue * Weight.

applyNewBoard( Board ) :-
    retractall(pawn(_,_,_)),
    bagof(_, assertPawn(Board),_)
	.
assertPawn( Board ) :-
    nth0(_,Board,[X,Y,Role]),
    assert(pawn(X,Y,Role))
	.


% for testing purpose
initfield :-
    retractall(pawn(_,_,_)),retractall(action(_,_,_)),
    assert(pawn(3,4,'b')),

    assert(pawn(2,5,'w')), assert(pawn(4,5,'w')), assert(pawn(5,6,'w')).

initfield2 :-
    retractall(pawn(_,_,_)),retractall(action(_,_,_)),
    assert(pawn(3,4,'b')),

    assert(pawn(2,5,'w')),assert(pawn(2,7,'w')), assert(pawn(1,6,'w')).
