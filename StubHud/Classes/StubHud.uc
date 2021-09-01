class StubHud extends Mutator;

var string TextBuffer[4];
var HudPRI RootPRI, CurrPRI;
var Font FirstFont;

simulated function Tick(float DeltaTime) {
	if (Level.NetMode != NM_DedicatedServer) {
		if (!bHUDMutator) RegisterHUDMutator();
	}
	if (Level.NetMode != NM_Client) {
		// do something on server
		if (RootPRI == None) {
			// init stuff - called only once
			setTimer(1, true);
		};
		
		GetRoot();
	}
}

function Timer() {

	if (CurrPRI != None) {
		AddRow("foo is"$CurrPRI.foo);
	}

	///////////////////////////////////
	// local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	// local actor Other;

	// GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	// StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
	// EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
	// 	+ Accuracy * (FRand() - 0.5 ) * Z * 1000 ;

	// if ( bBotSpecialMove && (Tracked != None)
	// 	&& (((Owner.Acceleration == vect(0,0,0)) && (VSize(Owner.Velocity) < 40)) ||
	// 		(Normal(Owner.Velocity) Dot Normal(Tracked.Velocity) > 0.95)) )
	// 	EndTrace += 10000 * Normal(Tracked.Location - StartTrace);
	// else
	// {
	// 	bSplashDamage = false;
	// 	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);	
	// 	bSplashDamage = true;
	// 	EndTrace += (10000 * vector(AdjustedAim)); 
	// }

	// Tracked = None;
	// bBotSpecialMove = false;

	// Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, StartTrace);
	// ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
	// ///////////////////////////////////
	

	GetRoot().UpdateAll();
}

function AddRow(string newRow) {
	TextBuffer[0] = TextBuffer[1];
	TextBuffer[1] = TextBuffer[2];
	TextBuffer[2] = TextBuffer[3];
	TextBuffer[3] = newRow;
}

simulated function PostRender(canvas C) {
	local int currentLine;
	local HudPRI curr;
	local float baseY;
	
    if (NextHUDMutator != None)
        NextHUDMutator.PostRender(C);
        
	curr = GetPlayerHudPRI(C.Viewport.Actor);

	if (curr != None) {

		currentLine = 0;
		baseY = C.ClipY/2;

		if (FirstFont == None) {
			FirstFont = class'FontInfo'.Static.GetStaticSmallFont(C.ClipX);
		} else if (FirstFont != C.Font) {
			C.Font = FirstFont;
		}
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;

		while (currentLine < 4) 
		{
			C.SetPos(0, baseY + (currentLine * 16));
			C.DrawText(TextBuffer[currentLine]);
			currentLine++;
		}
	}


	C.DrawColor.G = 0;
	C.SetPos(C.ClipX/2+1, C.ClipY/2-6);
	Log(C.ClipX/2$","$C.ClipY/2);
	C.DrawText("x");
}

function HudPRI GetRoot() {
	local HudPRI curr;
	
	if (RootPRI == None) {
		RootPRI = Spawn(class'HudPRI', Self);
	}
	return RootPRI;
}

function ModifyPlayer(Pawn Player) {
	if (Level.NetMode != NM_Client && Player != None && Player.isA('PlayerPawn')) {
		GetRoot().Get(PlayerPawn(Player).PlayerReplicationInfo);
	}
}

simulated function HudPRI GetPlayerHudPRI(PlayerPawn Player) {
	local HudPRI curr;

	if (CurrPRI == None) {
		// test
		TextBuffer[0] = "Line 1";
		TextBuffer[1] = "Line 2";
		TextBuffer[2] = "Line 3";
		TextBuffer[3] = "Line 4";

		foreach AllActors(Class'HudPRI', curr) {
			if (curr.OwnerPRI == Player.PlayerReplicationInfo) {
				CurrPRI = curr;
				break;
			}
		}
	}
	return CurrPRI;
}

defaultproperties {
	bAlwaysRelevant=True
	bNetTemporary=True
	RemoteRole=ROLE_SimulatedProxy
}