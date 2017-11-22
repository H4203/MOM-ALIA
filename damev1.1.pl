:- dynamic pawn/3.
:- dynamic action/3.

noWhitePawn :- not(pawn(_,_,'w')).
noWhiteQueen :- not(pawn(_,_,'wq')).
noBlackPawn :- not(pawn(_,_,'b')).
noBlackQueen :- not(pawn(_,_,'bq')).


gameover :- noWhitePawn,noWhiteQueen,
     writeln(''), writeln('Les noirs ont gagné'),displayBoard.
gameover :- noBlackPawn, noBlackQueen,
     writeln(''),writeln('Les blancs ont gagné'),displayBoard.

printVal(Y,X) :- pawn(X,Y,Val), write('\t'), write(Val), write('\t'),!.  %, var(Val)
printVal(_,_) :- write('\t_\t'). %,nonvar(Val)

displayBoard :-
     findall(_, partialDisplayBoard, _).

partialDisplayBoard :-
    between(0, 9, I), writeln(''),
    between(0, 9, J),
    printVal(I,J).

% do not delete needed to make applyEat work properly
nextPlayer('b','w').
nextPlayer('w','b').
nextPlayer('bq','w').
nextPlayer('wq','b').
nextPlayer('b','wq').
nextPlayer('w','bq').
nextPlayer('bq','wq').
nextPlayer('wq','bq').

applyEat(Action, Pawn) :-

    Action = action(_, XDest, YDest),
    Pawn = pawn(X, Y, Player),
    XE is (XDest + X) / 2,
    YE is (YDest + Y) / 2,
    nextPlayer(Player, NextPlayer),
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

play(_) :- gameover.
play(Player) :- write('New turn for:'), writeln(Player),
    displayBoard,
    aiLevel(Niveau, Player),
    ai(Niveau,Player,Pawn,ActionList),
    applyActions(ActionList,Pawn),
    nextPlayer(Player,NextPlayer),
    play(NextPlayer).

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
   play('b').

%-------------------------------
aiLevel(1,'w').
aiLevel(1,'b').
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
    repeat,
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

% for testing purpose
initfield :-
    retractall(pawn(_,_,_)),retractall(action(_,_,_)),
    assert(pawn(1,0,'b')), assert(pawn(3,0,'b')), assert(pawn(5,0,'b')), assert(pawn(7,0,'b')), assert(pawn(9,0,'b')),
    assert(pawn(0,1,'b')), assert(pawn(2,1,'b')), assert(pawn(4,1,'b')), assert(pawn(6,1,'b')), assert(pawn(8,1,'b')),
    assert(pawn(1,2,'b')), assert(pawn(3,2,'b')), assert(pawn(5,2,'b')), assert(pawn(7,2,'b')), assert(pawn(9,2,'b')),
    assert(pawn(0,3,'b')), assert(pawn(2,3,'b')), assert(pawn(4,3,'b')), assert(pawn(6,3,'b')), assert(pawn(8,3,'b')),

    assert(pawn(1,6,'w')), assert(pawn(3,6,'w')), assert(pawn(5,6,'w')), assert(pawn(7,6,'w')), assert(pawn(9,6,'w')),
    assert(pawn(0,7,'w')), assert(pawn(2,7,'w')), assert(pawn(4,7,'w')), assert(pawn(6,7,'w')), assert(pawn(8,7,'w')),
    assert(pawn(1,8,'w')), assert(pawn(3,8,'w')), assert(pawn(5,8,'w')), assert(pawn(7,8,'w')), assert(pawn(9,8,'w')),
    assert(pawn(0,9,'w')), assert(pawn(2,9,'w')), assert(pawn(4,9,'w')), assert(pawn(6,9,'w')), assert(pawn(8,9,'w')).

