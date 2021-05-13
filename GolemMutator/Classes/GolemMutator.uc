class GolemMutator extends Mutator;

var() string TargetPlayerName;
var bool GolemActive;

var private bool MutatorInitialized;
var private string EnteredToProtect;

function PostBeginPlay()
{
    if (!MutatorInitialized)
    {
        // register ourselves as a damage mutator
        Level.Game.RegisterDamageMutator(self);

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
    startSpot = FindPlayerStart();
    if (startSpot == None)
    {
        Log("Could not find starting spot for Bot");
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
    newBot.PlayerReplicationInfo.Team = 0;
    IndividualizeBot(newBot);

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

function float DistanceBetween(Vector fromVector, Vector toVector) {
    local Vector difference;

    difference.X = fromVector.X - toVector.X;
    difference.Y = fromVector.Y - toVector.Y;
    difference.Z = fromVector.Z - toVector.Z;

    return VSize(difference);
}

// TODO: put this into a separate class, it's used by both the Mutator and the Bot
function Pawn GetSean()
{
    local Pawn p;
    foreach AllActors(class 'Pawn', p)
    {
        if (p.PlayerReplicationInfo.PlayerName == TargetPlayerName)
        {
            return p;
        }
    }

    return None;
}   

function NavigationPoint FindPlayerStart()
{
    local PlayerStart current, closest;
    local float currentDistance, closestDistance;
    local Pawn sean;

    closest = None;
    closestDistance = -1;
    sean = GetSean();

    foreach AllActors(class 'PlayerStart', current)
    {
        currentDistance = DistanceBetween(sean.Location, current.Location);

        if (closestDistance < 0 || currentDistance < closestDistance) {
            closest = current;
            closestDistance = currentDistance;
        }
    }

    return closest;
}

function IndividualizeBot(Bot newBot)
{
    local string BotName;
    local string BotClass;
    local string BotSkin;
    local string BotFace;
    local string FavoriteWeapon;
    local float CombatStyle;
    local float Alertness;
    local float StrafingAbility;
    local float Camping;
    local float Skill;
    local int Accuracy;
    local int Team;
    local byte Difficulty;

    BotName         = "pr0tekt0rka";
    BotClass        = "BotPack.TFemale2Bot";
    BotSkin         = "SGirlSkins.Garf";
    BotFace         = "SGirlSkins.Isis";
    FavoriteWeapon  = "Botpack.Minigun2";
    CombatStyle     = 1.000000;
    Alertness       = 1.0;
    StrafingAbility = 1.0; // ???
    Camping         = 0.0;
    Skill           = 10.0;
    Accuracy        = 1.0;
    Team            = 255;
    Difficulty      = 4.0;

    // Set bot's skin
    newBot.Static.SetMultiSkin(newBot, BotSkin, BotFace, Team);
    Level.Game.ChangeName(newBot, BotName, false);
    newBot.InitializeSkill(Difficulty + Skill);

    if ((FavoriteWeapon != "") && (FavoriteWeapon != "None"))
        newBot.FavoriteWeapon = class<Weapon>(DynamicLoadObject(FavoriteWeapon, class'Class'));

    newBot.Accuracy = Accuracy;
    newBot.CombatStyle = newBot.Default.CombatStyle + 0.7 * CombatStyle;
    newBot.BaseAggressiveness = 0.5 * (newBot.Default.Aggressiveness + newBot.CombatStyle);
    newBot.BaseAlertness = Alertness;
    newBot.CampingRate = Camping;
    newBot.bJumpy = false; // nah you don't get to be jumpy
    newBot.StrafingAbility = StrafingAbility;

    // if ( VoiceType[n] != "" && VoiceType[n] != "None" )
    //     NewBot.PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject(VoiceType[n], class'Class'));
    
    // if(NewBot.PlayerReplicationInfo.VoiceType == None)
    //     NewBot.PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject(NewBot.VoiceType, class'Class'));
}

defaultproperties
{
    MutatorInitialized=false
    GolemActive=false
    TargetPlayerName="sean"
    EnteredToProtect=" has entered the game to protect "
}