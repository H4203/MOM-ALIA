:- dynamic pawn/3.
:- dynamic action/3.

gameover :- not(pawn(_,_,'w')), writeln('Les noirs ont gagné').
gameover :- not(pawn(_,_,'b')), writeln('Les blancs ont gagné').

printVal(Y,X) :- pawn(Y,X,Val), write(Val),!.  %, var(Val)
printVal(_,_) :- write('\t.\t'). %,nonvar(Val)

displayBoard :-
 	findall(_, partialDisplayBoard, _).   

partialDisplayBoard :-
    between(0, 9, I), writeln(''),
    between(0, 9, J),
    printVal(I,J).

nextPlayer('b','w').
nextPlayer('w','b').

applyEat(Action, Pawn) :-

	Action = action(_, XDest, YDest),
	Pawn = pawn(X, Y, Player),
	XE is (XDest + X) / 2, 
    YE is (YDest + Y) / 2, 
    nextPlayer(Player, NextPlayer),
	retract(pawn(XE, YE, NextPlayer)).

applyMove(Action, Pawn) :-

	Action = action(_, XDest, YDest),
	Pawn = pawn(X, Y, Player),

	retract(pawn(X, Y, Player)),
	assert(pawn(XDest, YDest, Player)).
	
applyAction(Action, Pawn) :-
	
	Action = action(Type, XDest, YDest),
	Pawn = _,
	
	Type == "Move", writeln('test'), applyMove(Action, Pawn),
	
	retract(action(Type, XDest, YDest)).
	
applyAction(Action, Pawn) :-
	
	Action = action(Type, XDest, YDest),
	Pawn = _,
	
	(Type == "Eat",  writeln('test2'), applyEat(Action, Pawn)),
	
	applyMove(Action, Pawn),
	
	retract(action(Type, XDest, YDest)).

applyActions(Actions, Pawn) :-
	
	Pawn = _,
	Actions = [].
	
applyActions(Actions, Pawn) :-
	
	Actions = [Head|Tail],
	
	applyAction(Head, Pawn),
	applyActions(Tail, Pawn).

play(Player) :- gameover.
play(Player) :- write('New turn for:'), writeln(Player),
        displayBoard, aiLevel(Niveau, Player), ai(Niveau,ActionList,Pawn,Player), 
        applyActions(Actions,Pawn), nextPlayer(Player,NextPlayer), play(NextPlayer). 

init :- 

	assert(pawn(1,0,'b')), assert(pawn(3,0,'b')), assert(pawn(5,0,'b')), assert(pawn(7,0,'b')), assert(pawn(9,0,'b')),
    assert(pawn(0,1,'b')), assert(pawn(2,1,'b')), assert(pawn(4,1,'b')), assert(pawn(6,1,'b')), assert(pawn(8,1,'b')),
    assert(pawn(1,2,'b')), assert(pawn(3,2,'b')), assert(pawn(5,2,'b')), assert(pawn(7,2,'b')), assert(pawn(9,2,'b')),
    assert(pawn(0,3,'b')), assert(pawn(2,3,'b')), assert(pawn(4,3,'b')), assert(pawn(6,3,'b')), assert(pawn(8,3,'b')),
        
    assert(pawn(1,6,'w')), assert(pawn(3,6,'w')), assert(pawn(5,6,'w')), assert(pawn(7,6,'w')), assert(pawn(9,6,'w')),
    assert(pawn(0,7,'w')), assert(pawn(2,7,'w')), assert(pawn(4,7,'w')), assert(pawn(6,7,'w')), assert(pawn(8,7,'w')),
    assert(pawn(1,8,'w')), assert(pawn(3,8,'w')), assert(pawn(5,8,'w')), assert(pawn(7,8,'w')), assert(pawn(9,8,'w')),
    assert(pawn(0,9,'w')), assert(pawn(2,9,'w')), assert(pawn(4,9,'w')), assert(pawn(6,9,'w')), assert(pawn(8,9,'w')).
    
	%play('b').
