class TerminatorHud extends Mutator;

const PlayerHeight = 78;
const PlayerWidth = 34;

var HudPRI RootPRI, CurrPRI;

simulated function Tick(float DeltaTime) {
    if (Level.NetMode != NM_DedicatedServer) {
        if (!bHUDMutator) RegisterHUDMutator();
    }
    if (Level.NetMode != NM_Client) {
        // do something on server
        GetRoot();
    }
}

function Timer() {
    if (CurrPRI == None) {
        Log("TerminatorHud: not doing the thing, CurrPRI is None");
        GetRoot().UpdateAll();
        return;
    }

    GetRoot().UpdateAll();
}


simulated function PostRender(canvas C) {
    local HudPRI curr;
    local Pawn p;
    
    if (NextHUDMutator != None)
        NextHUDMutator.PostRender(C);
        
    curr = GetPlayerHudPRI(C.Viewport.Actor);

    if (curr != None) {
        foreach AllActors(class 'Pawn', p) {
            if (curr.OwnerPRI.PlayerName == p.PlayerReplicationInfo.PlayerName) {
                continue;
            }

            DrawPlayerBox(C, p.Location, p.ViewRotation);
            MaybeDrawPlayerTarget(C, p.Location, p.Velocity);
        }
    }
}

simulated function vector RotateZAndTranslate(vector origin, vector point, float sinYaw, float cosYaw) {
    local float newX, newY, newZ;
    local vector newPoint;

    newX = (point.X * cosYaw) - (point.Y * sinYaw) + (origin.X);
    newY = (point.X * sinYaw) + (point.Y * cosYaw) + (origin.Y);
    newZ = (point.Z) + origin.Z;

    newPoint.X = newX;
    newPoint.Y = newY;
    newPoint.Z = newZ;

    return newPoint;
}


simulated function DrawProjectileTargetReticle(Canvas c, Vector point, texture crosshair, int size, float textureScale) {
    local int XPos, YPos;
    if (getXY(C, point, XPos, YPos) > 0) {
        C.SetPos(XPos - size / 2.0, YPos - size / 2.0);
        C.DrawIcon(crosshair, textureScale);
    }
}

simulated function DrawPlayerBox(Canvas c, vector playerLocation, rotator playerRotation) {
    local vector  up1,   up2,   up3,   up4,
                  down1, down2, down3, down4;
    local float yawRadians;
    local float sinYaw, cosYaw;

    yawRadians = ((playerRotation.Yaw & 65535)/65535.0) * 6.28;

    sinYaw = Sin(yawRadians);
    cosYaw = Cos(yawRadians);

    up1.X = -PlayerWidth/2;
    up1.Y = -PlayerWidth/2;
    up1.Z = -PlayerHeight/2;

    up2.X =  PlayerWidth/2;
    up2.Y = -PlayerWidth/2;
    up2.Z = -PlayerHeight/2;

    up3.X = -PlayerWidth/2;
    up3.Y =  PlayerWidth/2;
    up3.Z = -PlayerHeight/2;

    up4.X =  PlayerWidth/2;
    up4.Y =  PlayerWidth/2;
    up4.Z = -PlayerHeight/2;

    down1.X = -PlayerWidth/2;
    down1.Y = -PlayerWidth/2;
    down1.Z =  PlayerHeight/2;

    down2.X =  PlayerWidth/2;
    down2.Y = -PlayerWidth/2;
    down2.Z =  PlayerHeight/2;

    down3.X = -PlayerWidth/2;
    down3.Y =  PlayerWidth/2;
    down3.Z =  PlayerHeight/2;

    down4.X =  PlayerWidth/2;
    down4.Y =  PlayerWidth/2;
    down4.Z =  PlayerHeight/2;

    up1 = RotateZAndTranslate(playerLocation, up1, sinYaw, cosYaw);
    up2 = RotateZAndTranslate(playerLocation, up2, sinYaw, cosYaw);
    up3 = RotateZAndTranslate(playerLocation, up3, sinYaw, cosYaw);
    up4 = RotateZAndTranslate(playerLocation, up4, sinYaw, cosYaw);

    down1 = RotateZAndTranslate(playerLocation, down1, sinYaw, cosYaw);
    down2 = RotateZAndTranslate(playerLocation, down2, sinYaw, cosYaw);
    down3 = RotateZAndTranslate(playerLocation, down3, sinYaw, cosYaw);
    down4 = RotateZAndTranslate(playerLocation, down4, sinYaw, cosYaw);

    DrawLine3D(c, up1, up2);
    DrawLine3D(c, up2, up4);
    DrawLine3D(c, up4, up3);
    DrawLine3D(c, up3, up1);

    DrawLine3D(c, down1, down2);
    DrawLine3D(c, down2, down4);
    DrawLine3D(c, down4, down3);
    DrawLine3D(c, down3, down1);

    DrawLine3D(c, up1, down1);
    DrawLine3D(c, up2, down2);
    DrawLine3D(c, up3, down3);
    DrawLine3D(c, up4, down4);
}

simulated function MaybeDrawPlayerTarget(Canvas c, vector targetLocation, vector targetVelocity) {
    local vector originLocation, interceptLocation;
    local rotator originRotator; // unused
    local Actor originActor;
    local Pawn origin;

    C.ViewPort.Actor.PlayerCalcView(originActor, originLocation, originRotator);

    origin = Pawn(originActor);

    if (origin == None) {
        return;
    }

    if (origin.Weapon.ProjectileClass != None && tryCalculateIntercept(targetLocation, targetVelocity, originLocation, origin.Weapon.ProjectileSpeed, interceptLocation)) {
        DrawLine3D(c, targetLocation, interceptLocation);
        DrawProjectileTargetReticle(c, interceptLocation, texture'chair4', 64, 1.0);

    }

    if (origin.Weapon.AltProjectileClass != None && tryCalculateIntercept(targetLocation, targetVelocity, originLocation, origin.Weapon.AltProjectileSpeed, interceptLocation)) {
        DrawLine3D(c, targetLocation, interceptLocation);
        DrawProjectileTargetReticle(c, interceptLocation, texture'chair5', 64, 1.0);
    }
}

simulated function bool tryCalculateIntercept(vector a, vector v, vector b, float s, out vector intercept) {
    local float dx, dy, dz,
                h1, h2,
                root, minusPHalf, discriminant,
                tMin, tMax,
                t1, t2,
                t;

    dx = a.X - b.X;
    dy = a.Y - b.Y;
    dz = a.Z - b.Z;

    h1 = (
        - (s * s)
        + (v.X * v.X)
        + (v.Y * v.Y)
        + (v.Z * v.Z)
    );

    h2 = (
         (dx * v.X)
       + (dy * v.Y)
       + (dz * v.Z)
    );

    t = -(
          (dx * dx)
        + (dy * dy)
        + (dz * dz)
    ) / (2 * h2);

    if (h1 != 0) {
        minusPHalf = -h2 / h1;
        discriminant = (minusPHalf * minusPHalf) - (
              (dx * dx)
            + (dy * dy)
            + (dz * dz)
        ) / h1;

        if (discriminant < 0) {
            return false;
        }

        root = sqrt(discriminant);
        t1 = minusPHalf + root;
        t2 = minusPHalf - root;

        if (t1 < t2) {
            tMin = t1;
            tMax = t2;
        } else {
            tMin = t2;
            tMax = t1;
        }

        if (tMin > 0) { 
            t = tMin;
        } else {
            t = tMax;
        }

        if (t < 0) {
            return false;
        }
    }

    intercept.X = a.X + t * v.X;
    intercept.Y = a.Y + t * v.Y;
    intercept.Z = a.Z + t * v.Z;
    return true;
}

simulated function float getXY(Canvas C, vector location, out int screenX, out int screenY) {
    local vector X, Y, Z, CamLoc, TargetDir, Dir, XY;
    local rotator CamRot;
    local Actor Camera;
    local float TanFOVx, TanFOVy;
    local float ret;

    C.ViewPort.Actor.PlayerCalcView(Camera, CamLoc, CamRot);

    TanFOVx = Tan(C.ViewPort.Actor.FOVAngle / 114.591559); // 360/Pi = 114.5915590...
    TanFOVy = (C.ClipY / C.ClipX) * TanFOVx;
    GetAxes(CamRot, X, Y, Z);

    TargetDir = Location - CamLoc;

    ret = X dot TargetDir;

    if (ret > 0) {
        Dir = X * (X dot TargetDir);
        XY = TargetDir - Dir;

        screenX = C.ClipX * 0.5 * (1.0 + (XY dot Y) / (VSize(Dir) * TanFOVx));
        screenY = C.ClipY * 0.5 * (1.0 - (XY dot Z) / (VSize(Dir) * TanFOVy));
    }

    return ret;
}

function HudPRI GetRoot() {
    local HudPRI curr;
    
    if (RootPRI == None) {
        RootPRI = Spawn(class'HudPRI', Self);
    }
    return RootPRI;
}


simulated function DrawLine(Canvas Canvas, int x1, int y1, int x2, int y2) {
    local int i, j, n, dx, dy;
    local float a, b;
    if (x1 == 0 && y1 == 0) return;
    if (x2 == 0 && y2 == 0) return;
    dx = x2 - x1;
    dy = y2 - y1;
    if (Abs(dx) > Abs(dy)) {        
        if (dx == 0) return;
        if (dx > 0) j = 1; else j = -1;
        n = Min(Canvas.ClipX, Max(0, x2));
        a = float(dy)/dx;
        b = float(y1) - a*x1;
        for (i = Min(Canvas.ClipX, Max(0, x1)); i != n; i += j) {
            canvas.SetPos(i, a*i + b);
            canvas.DrawRect(Texture'Botpack.FacePanel0', 2.0, 2.0);
        }
    } else {
        if (dy == 0) return;
        if (dy > 0) j = 1; else j = -1;
        n = Min(Canvas.ClipY, Max(0, y2));
        a = float(dx)/dy;
        b = float(x1) - a*y1;
        for (i = Min(Canvas.ClipY, Max(0, y1)); i != n; i += j) {
            canvas.SetPos(a*i + b, i);
            canvas.DrawRect(Texture'Botpack.FacePanel0', 2.0, 2.0);
        }
    }
}

simulated function DrawLine3D( Canvas C, vector P1, vector P2) {
    local int x1, y1, x2, y2;
    local float a1, a2;

    a1 = getXY(C, P1, x1, y1);  
    a2 = getXY(C, P2, x2, y2);
    if (a1 <= 0 && a2 <= 0) return;
    if (a1 <= 0) {
        P1 -= P2;
        P1 *= a2/(a2 - a1);
        P1 -= Normal(P1);
        P1 += P2;
        getXY(C, P1, x1, y1);
    } else if (a2 <= 0) {
        P2 -= P1;
        P2 *= a1/(a1 - a2);
        P2 -= Normal(P2);
        P2 += P1;
        getXY(C, P2, x2, y2);
    }
    // if (R >= 0)
    //     SetColor(C, R, G, B);
    DrawLine(C, x1, y1, x2, y2);
}

function ModifyPlayer(Pawn Player) {
    if (Level.NetMode != NM_Client && Player != None && Player.isA('PlayerPawn')) {
        GetRoot().Get(PlayerPawn(Player).PlayerReplicationInfo);
    }
}

simulated function HudPRI GetPlayerHudPRI(PlayerPawn Player) {
    local HudPRI curr;

    if (CurrPRI == None) {
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