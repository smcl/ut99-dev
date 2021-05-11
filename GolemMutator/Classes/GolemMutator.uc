class GolemMutator extends Mutator;

var() string TargetPlayerName;

var private bool MutatorInitialized;
var private bool GolemActive;
var private ChallengeBotInfo BotConfig;
var private class<ChallengeBotInfo> BotConfigType;
var private string EnteredToProtect;

function PostBeginPlay()
{
    if (!MutatorInitialized)
    {
        // instantiate the BotConfig
        BotConfig = Spawn(BotConfigType);

        // register ourselves as a damage mutator
        Level.Game.RegisterDamageMutator(self);

        // setup the bot
        BotConfig.SetBotName("protekt0r", 0);
        BotConfig.BotSkills[0] = 10;
        BotConfig.BotAccuracy[0] = 1.0;
        BotConfig.Alertness[0] = 1.0;

        // ensure we don't re-enter
        MutatorInitialized = true;
    }
}

function MutatorTakeDamage(
    out int actualDamage,
    Pawn victim,
    Pawn instigatedBy,
    out Vector hitLocation, 
    out Vector momentum,
    name damageType)
{
    if (!GolemActive && victim.PlayerReplicationInfo.PlayerName == TargetPlayerName)
    {
        AddBot(InstigatedBy);
        GolemActive = true;
    }

    if (NextDamageMutator != None)
        NextDamageMutator.MutatorTakeDamage(actualDamage, victim, instigatedBy, hitLocation, momentum, damageType);
}

function ModifyPlayer(Pawn playerToModify) 
{
    local string pawnName;
    pawnName = playerToModify.PlayerReplicationInfo.PlayerName;

    if (pawnName == TargetPlayerName)
    {
        StackPawnInventory(playerToModify);
    }
}

function bool AddBot(Pawn target)
{
    local bot newBot;
    local NavigationPoint startSpot;

    Log("Adding a bot with initial target"@target.PlayerReplicationInfo.PlayerName);

    newBot = SpawnBot(startSpot);
    if (newBot == None)
    {
        Log("Failed to spawn bot.");
        return false;
    }

    startSpot.PlayTeleportEffect(newBot, true);
    newBot.PlayerReplicationInfo.bIsABot = true;

    // Log it.
    if (Level.Game.LocalLog != None)
    {
        Level.Game.LocalLog.LogPlayerConnect(newBot);
        Level.Game.LocalLog.FlushLog();
    }
    if (Level.Game.WorldLog != None)
    {
        Level.Game.WorldLog.LogPlayerConnect(newBot);
        Level.Game.WorldLog.FlushLog();
    }

    return true;
}

function Bot SpawnBot(out NavigationPoint startSpot)
{
    local GolemBot newBot;
    local Pawn p;
    local class<GolemBot> botClass;

    // Find a start spot.
    startSpot = FindPlayerStart(None, 255);
    if (startSpot == None)
    {
        log("Could not find starting spot for Bot");
        return None;
    }

    // select + spawn the bot
    botClass = class<GolemBot>(DynamicLoadObject("GolemMutator.GolemBot", class'Class'));
    
    newBot = Spawn(
        botClass,
        /* actor */,
        /* name  */,
        startSpot.Location,
        startSpot.Rotation);

    if (newBot == None)
    {
        Log("Couldn't spawn player at "$startSpot);
        return None; 
    }

    // customize the player (id, team, skin etc)
    newBot.PlayerReplicationInfo.PlayerID = Level.Game.CurrentID++;
    newBot.PlayerReplicationInfo.Team = BotConfig.GetBotTeam(0);
    BotConfig.CHIndividualize(newBot, 0, 1);
    newBot.ViewRotation = startSpot.Rotation;
    
    // broadcast a welcome message.
    BroadcastMessage(newBot.PlayerReplicationInfo.PlayerName$EnteredToProtect$TargetPlayerName, true);

    // apply some more customizations
    ModifyBehaviour(newBot);
    Level.Game.AddDefaultInventory(newBot);

    // attach the mutator (so we can access the player etc)
    newBot.AttachMutator(self);

    return newBot;
}

function ModifyBehaviour(Bot newBot)
{
    /* nothing here yet */
}

function AddWeapon(Pawn botPawn, Class<Weapon> weaponClass)
{
    local Weapon newWeapon;
    newWeapon = Spawn(
        weaponClass,
        /* actor */,
        /* name  */,
        botPawn.Location);

    if(newWeapon != None)
    {
        newWeapon.Instigator = botPawn;
        newWeapon.BecomeItem();
        botPawn.AddInventory(newWeapon);
        newWeapon.BringUp();
        newWeapon.GiveAmmo(botPawn);
        newWeapon.SetSwitchPriority(botPawn);
        newWeapon.WeaponSet(botPawn);    
        newWeapon.AmmoType.AmmoAmount = 199;
        newWeapon.AmmoType.MaxAmmo = 199;        
        botPawn.Weapon = newWeapon;
    }
    else
    {
        Log("Could not spawn weapon");
    }
}

function StackPawnInventory(Pawn p)
{
    AddWeapon(p, class'Minigun2');
    AddWeapon(p, class'PulseGun');
    AddWeapon(p, class'Ripper');
    AddWeapon(p, class'ShockRifle');
    AddWeapon(p, class'SniperRifle');
    AddWeapon(p, class'UT_BioRifle');
    AddWeapon(p, class'UT_Eightball');
    AddWeapon(p, class'UT_FlakCannon');
}

// TODO: cleanup this piece of shit and make it find the nearest spawn point to me
function NavigationPoint FindPlayerStart(Pawn Player, optional byte InTeam, optional string incomingName)
{
    local PlayerStart Dest, Candidate[4], Best;
    local float Score[4], BestScore, NextDist;
    local pawn OtherPlayer;
    local int i, num;
    local Teleporter Tel;
    local NavigationPoint N;

    if( incomingName!="" )
        foreach AllActors( class 'Teleporter', Tel )
            if(string(Tel.Tag)~=incomingName)
                return Tel;

    num = 0;
    //choose candidates    
    N = Level.NavigationPointList;
    While ( N != None )
    {
        if ( N.IsA('PlayerStart') && !N.Region.Zone.bWaterZone )
        {
            if (num<4)
                Candidate[num] = PlayerStart(N);
            else if (Rand(num) < 4)
                Candidate[Rand(4)] = PlayerStart(N);
            num++;
        }
        N = N.nextNavigationPoint;
    }

    if (num == 0 )
        foreach AllActors( class 'PlayerStart', Dest )
        {
            if (num<4)
                Candidate[num] = Dest;
            else if (Rand(num) < 4)
                Candidate[Rand(4)] = Dest;
            num++;
        }

    if (num>4) num = 4;
    else if (num == 0)
        return None;
        
    //assess candidates
    for (i=0;i<num;i++)
        Score[i] = 4000 * FRand(); //randomize
        
    for ( OtherPlayer=Level.PawnList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextPawn)    
        if ( OtherPlayer.bIsPlayer && (OtherPlayer.Health > 0) )
            for (i=0;i<num;i++)
                if ( OtherPlayer.Region.Zone == Candidate[i].Region.Zone )
                {
                    NextDist = VSize(OtherPlayer.Location - Candidate[i].Location);
                    if (NextDist < OtherPlayer.CollisionRadius + OtherPlayer.CollisionHeight)
                        Score[i] -= 1000000.0;
                    else if ( (NextDist < 2000) && OtherPlayer.LineOfSightTo(Candidate[i]) )
                        Score[i] -= 10000.0;
                }
    
    BestScore = Score[0];
    Best = Candidate[0];
    for (i=1;i<num;i++)
        if (Score[i] > BestScore)
        {
            BestScore = Score[i];
            Best = Candidate[i];
        }

    return Best;
}

defaultproperties
{
    MutatorInitialized=false
    GolemActive=false
    TargetPlayerName="sean"
    BotConfig=None
    BotConfigType=Class'Botpack.ChallengeBotInfo'
    EnteredToProtect=" has entered the game to protect "
}