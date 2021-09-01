class HudPRI extends ReplicationInfo;

// replicated
var PlayerReplicationInfo OwnerPRI;
var int foo;

// not replicated

// list
var HudPRI next;

replication {
    reliable if (Role == ROLE_Authority)
        OwnerPRI, foo;
}

function UpdateAll() {
	local HudPRI curr;

	Alive();
	
	curr = next;
	while (curr != None) {
		// do something			
	    if (curr.foo != Level.Second) curr.foo = Level.Second;
	    		
		curr = curr.next;
	}
}

function SetFoo(int foo, PlayerPawn Player) {	
	local HudPRI curr;
	
	curr = Get(Player.PlayerReplicationInfo);
	if (curr.foo != foo) curr.foo = foo;
}

function Alive() {
	local HudPRI prev, curr;
	
	prev = Self;
	curr = next;
	while (curr != None) {
		if (Pawn(curr.Owner) == None) {
			prev.next = curr.next;
			curr.Destroy();
			curr = prev.next;
		} else {
			prev = curr;
			curr = curr.next;
		}
	}
}

function HudPRI Get(PlayerReplicationInfo PRI) {
	local HudPRI curr, add;
	
	curr = Self;
	while (curr != None) {
		if (curr.OwnerPRI == PRI) {
			return curr;
		}
		if (curr.next == None) {
			add = Spawn(class'HudPRI', PRI.Owner);
			add.OwnerPRI = PRI;
			curr.next = add;
			return add;
		}
		curr = curr.next;
	}
	Log("Get: Must never happen");
	return None;
}