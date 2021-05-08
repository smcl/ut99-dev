class HelloMut extends Mutator;

function ModifyPlayer(Pawn other)
{
    if (other.PlayerReplicationInfo != None)
        BroadcastMessage("Hello,"@other.PlayerReplicationInfo.PlayerName@"");
    
    if (NextMutator != None)
        NextMutator.ModifyPlayer(other);
}