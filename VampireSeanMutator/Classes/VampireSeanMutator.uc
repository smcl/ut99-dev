class VampireSeanMutator extends Mutator;

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
    local string damageStr;
    if (Victim.PlayerReplicationInfo.PlayerName == SeanPlayerName)
    {
        if (InstigatedBy.PlayerReplicationInfo.PlayerName != SeanPlayerName)
        {
            damageStr = string(ActualDamage);
            BroadcastMessage(SeanPlayerName@"leeches"@damageStr@"health from"@InstigatedBy.PlayerReplicationInfo.PlayerName);
            InstigatedBy.TakeDamage(ActualDamage, Victim, HitLocation, Momentum, DamageType);
            ActualDamage = -ActualDamage;
        }
    }

    if ( NextDamageMutator != None )
        NextDamageMutator.MutatorTakeDamage( ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType );
}
    
defaultproperties
{
    SeanPlayerName="sean"
}