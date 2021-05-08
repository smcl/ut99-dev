class ProtectSeanMutator extends Mutator;

var private bool MutatorInitialized;
var() string SeanPlayerName;

function PostBeginPlay()
{
    if ( !MutatorInitialized )
    {
        Level.Game.RegisterDamageMutator(self);
        MutatorInitialized = True;
    }
}

function MutatorTakeDamage(
    out int ActualDamage,
    Pawn Victim,
    Pawn InstigatedBy,
    out Vector HitLocation, 
    out Vector Momentum,
    name DamageType)
{
    local Pawn p;

    if (Victim.PlayerReplicationInfo.PlayerName == SeanPlayerName)
    {
        BroadcastMessage("This is what you get for hurting"@SeanPlayerName);

        foreach AllActors(class 'Pawn', p)
        {
            if (p.PlayerReplicationInfo.PlayerName != Victim.PlayerReplicationInfo.PlayerName)
            {
                BroadcastMessage("leave"@SeanPlayerName@"alone");
                p.TakeDamage(ActualDamage, Victim, HitLocation, Momentum, DamageType);
            }
        }
    }

    if ( NextDamageMutator != None )
        NextDamageMutator.MutatorTakeDamage( ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType );
}

    
defaultproperties
{
    SeanPlayerName="sean"
}