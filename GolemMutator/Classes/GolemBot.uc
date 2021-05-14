class GolemBot extends TFemale2Bot; // we inherit a LOT of behaviour from this and the base Bot class

var() bool LeaveOnDeath;
var private GolemMutator _mutator;

function Initialize(GolemMutator mutator)
{
    _mutator = mutator;
}

function bool SeekSean()
{
    local Pawn maybeSean;

    maybeSean = _mutator.PlayerFinder.GetPlayer(_mutator.TargetPlayerName);
    if (maybeSean != None)
        return PathTowardSean(maybeSean);

    return false;
}

function bool PathTowardSean(Actor sean) 
{
    local Actor path;
    local bool success;
    
    path = FindPathTo(sean.Location); 
        
    if (path == None)
    {
        Log("couldn't find path to sean");
        return false;
    }

    MoveTarget = path; 
    Destination = path.Location;
    return true;
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
        if (LeaveOnDeath)
        {
            BroadcastMessage(PlayerReplicationInfo.PlayerName@"has failed to protect"@_mutator.TargetPlayerName@"and will be liquidated");
            _mutator.GolemActive = False;
            super.Destroy();
        }
        else {
            super.ReStartPlayer();
        }
    }
}

defaultproperties
{
    LeaveOnDeath=false
    GroundSpeed=800.000000
    AirSpeed=800.000000
    DrawScale=1.5
}