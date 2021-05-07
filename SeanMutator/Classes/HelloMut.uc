class HelloMut extends Mutator;

function ModifyPlayer(Pawn other)
{
    if (Other.PlayerReplicationInfo != None)
        BroadcastMessage("Hello"@Other.PlayerReplicationInfo.PlayerName@"!");
    
    if (NextMutator != None)
        NextMutator.ModifyPlayer(Other);
}