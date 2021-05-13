class GolemBot extends TFemale2Bot; // we inherit a LOT of behaviour from this and the base Bot class

var private GolemMutator _mutator;

function AttachMutator(GolemMutator mutator)
{
    _mutator = mutator;
}

function Pawn GetSean()
{
    local Pawn p;
    foreach AllActors(class 'Pawn', p)
    {
        if (p.PlayerReplicationInfo.PlayerName == _mutator.TargetPlayerName)
        {
            return p;
        }
    }

    return None;
}   

function bool SeekSean()
{
    local Pawn maybeSean;
    maybeSean = GetSean();
    if (maybeSean != None && PathTowardSean(maybeSean) )
    {
        return true;
    }

    return false;
}

function bool PathTowardSean(Actor sean) 
{
    local Actor path;
    local bool success;
    
    path = FindPathTo(sean.Location); 
        
    success = (path != None);    
    
    if (success)
    {
        MoveTarget = path; 
        Destination = path.Location;
    }
    else {
        log("couldn't find path to sean");
    }
    
    return success;
}

function eAttitude AttitudeTo(Pawn other)
{
    if (other.PlayerReplicationInfo.PlayerName == _mutator.TargetPlayerName)
        return ATTITUDE_Friendly;

    return ATTITUDE_Hate;
}

state Hold {
    function PickDestination()
    {
        if (!SeekSean())
            super.PickDestination();
    }
}

state Roaming {
    function PickDestination()
    {
        if (!SeekSean())
            super.PickDestination();
    }
}

state Wandering {
    function PickDestination()
    {
        if (!SeekSean())
            super.PickDestination();
    }
}

state Retreating {
    function PickDestination()
    {
        if (!SeekSean())
            super.PickDestination();
    }
}

state Fallback {
    function PickDestination()
    {
        if (!SeekSean())
            super.PickDestination();
    }
}

state Hunting {
    function PickDestination()
    {
        if (!SeekSean())
            super.PickDestination();
    }
}

state TacticalMove {
    function PickDestination(bool noCharge)
    {
        if (!SeekSean())
            super.PickDestination(noCharge);
    }
}

state FindAir {
    function PickDestination(bool noCharge)
    {
        if (!SeekSean())
            super.PickDestination(noCharge);
    }
}

state Holding {
    /* inherit all */
}

state Acquisition {
    /* inherit all */
}

state Attacking {
    /* inherit all */
}

state Charging {
    /* inherit all */
}

state StakeOut {
    /* inherit all */
}

state TakeHit {
    /* inherit all */
}

state ImpactJumping {
    /* inherit all */
}

state FallingState {
    /* inherit all */
}

state RangedAttack {
    /* inherit all */
}

state VictoryDance {
    /* inherit all */
}

state GameEnded {
    /* inherit all */
}

state Dying {
	function ReStartPlayer()
	{
        BroadcastMessage(PlayerReplicationInfo.PlayerName@"has failed to protect"@_mutator.TargetPlayerName@"and will be liquidated");
        _mutator.GolemActive = False;
        super.Destroy();
    }
}

defaultproperties
{
    GroundSpeed=800.000000
    AirSpeed=800.000000
}