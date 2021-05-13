class PlayerFinder extends Object;

var private Actor _context;

function Initialize(Actor context)
{
    _context = context;
}

function Pawn GetPlayer(string playerName)
{
    local Pawn p;

    foreach _context.AllActors(class 'Pawn', p)
        if (p.PlayerReplicationInfo.PlayerName == playerName)
            return p;

    return None;
}