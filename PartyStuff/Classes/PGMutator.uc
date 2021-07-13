//=============================================================================
// PGMutator / Handling everything that needs handling
//=============================================================================
class PGMutator extends Mutator Config (TCMod);

var config bool bSuperGore;
var config bool bSpydroneMod;
var config bool bAllowPlay;
var config bool bAllowPlayAll;
var config bool bGiveAutoMed;
var config bool bAntiCheatKill;
var config bool bCrits;
var config bool bPersistZones;
var config int SaveTimer;
var config string PersistMap;
var config bool bLoadPersistance;
var config bool bGivePSCC;
var config bool bClearSpawnInventory;

replication
{
reliable if (Role == ROLE_Authority)
    ShowMessage;
}

simulated function ShowMessage(DeusExPlayer Player, string Message)
{
local HUDMissionStartTextDisplay    HUD;
if ((Player.RootWindow != None) && (DeusExRootWindow(Player.RootWindow).HUD != None))
{
    HUD = DeusExRootWindow(Player.RootWindow).HUD.startDisplay;
}
if(HUD != None)
{
    HUD.shadowDist = 0;
    //HUD.setFont(Font'FontMenuTitle');
    HUD.fontText = Font'FontMenuExtraLarge';
    HUD.Message = "";
    HUD.charIndex = 0;
    HUD.winText.SetText("");
    HUD.winTextShadow.SetText("");
    HUD.displayTime = 5.50;
    HUD.perCharDelay = 0.01;
    HUD.AddMessage(Message);
    HUD.StartMessage();
}
}

function PostBeginPlay ()
{
local PGMutator R;
local bool bMutatorFound;
local ProjectileGenerator PG;
local ScriptedPawn SP;
local BreakableGlass BG;
local Actor A;
local SecurityCamera SC;
local PSZoneInfo psz;
local Persist p;
    //Super.PostBeginPlay ();
    Level.Game.BaseMutator.AddMutator (Self);
    Level.Game.RegisterDamageMutator (Self);
    
    if(bPersistZones)
    {
        if(InStr(string(Level), PersistMap) != -1)
        {
            log("Enabling Actor Persist");
            p = spawn(class'Persist');
            if(bLoadPersistance)
                p.Load();
            p.SetTimer(SaveTimer,True);
        }
    }
    foreach AllActors(class'SecurityCamera', SC)
    {
        SC.bActive=False; //NO CAM GIRLS
    }
    foreach AllActors(class'Actor', A)
    {		  
        if(string(a.class) ~= "DXMTL152b1.CBPAmmocrate") 
        {
            Spawn(class'acrate',,,A.Location);
            a.Destroy();
        }
    }
    
    if(Left(string(Level), InStr(string(Level), ".")) ~= "DXMP_RPGCity")
    {
        foreach AllActors(class'ScriptedPawn',SP)
        {
            SP.Destroy();
        }
        foreach AllActors(class'BreakableGlass',BG)
        {
            BG.bBreakable = False;
        }
    }
}

function AdminArmour HasAA(PlayerPawn PP)
{
local AdminArmour AA;

    foreach AllActors(class'AdminArmour', AA)
        if(AA.Owner == PP)
            return AA;
}

function PGArmour HasPA(PlayerPawn PP)
{
local PGArmour AA;

    foreach AllActors(class'PGArmour', AA)
        if(AA.Owner == PP)
            return AA;
}

function int GetPADur(PlayerPawn PP)
{
local PGArmour AA;

    foreach AllActors(class'PGArmour', AA)
        if(AA.Owner == PP)
            return AA.Dur;
}

function int GetPADef(PlayerPawn PP)
{
local PGArmour AA;

    foreach AllActors(class'PGArmour', AA)
        if(AA.Owner == PP)
            return AA.Def;
}

function HitPA(PlayerPawn PP, int i)
{
local PGArmour AA;

    foreach AllActors(class'PGArmour', AA)
        if(AA.Owner == PP)
        {
            AA.Dur -= i;
            AA.rDur = AA.Dur;
        }
}

function DrawAdminShield(pawn Victim)
{
    local AdminArmourEffect shield;

    shield = Spawn(class'AdminArmourEffect', Victim,, Victim.Location, Victim.Rotation);
    if (shield != None)
    {
        Shield.DrawScale = Victim.Drawscale;
        shield.SetBase(Victim);
    }
}

function DrawProtShield(pawn Victim)
{
    local ProtEffect shield;

    shield = Spawn(class'ProtEffect', Victim,, Victim.Location, Victim.Rotation);
    if (shield != None)
    {
        Shield.DrawScale = Victim.Drawscale;
        shield.SetBase(Victim);
    }
}

function ReturnArmour HasRA(PlayerPawn PP)
{
local ReturnArmour AA;

    foreach AllActors(class'ReturnArmour', AA)
        if(AA.Owner == PP)
            return AA;
}

function Vialgrow HasVG(PlayerPawn PP)
{
local Vialgrow AA;

    foreach AllActors(class'Vialgrow', AA)
        if(AA.Owner == PP && AA.bOn)
            return AA;
}

function DrawReturnShield(pawn Victim)
{
    local ReturnArmourEffect shield;

    shield = Spawn(class'ReturnArmourEffect', Victim,, Victim.Location, Victim.Rotation);
    if (shield != None)
    {
        Shield.DrawScale = Victim.Drawscale;
        shield.SetBase(Victim);
    }
}

function SpawnExplosion(Pawn victim, Pawn Instigator)
{
local ShockRing s1, s2, s3;
local int r;
local DeusExPlayer player;
    s1 = spawn(class'ShockRing',,,Victim.Location,rot(16384,0,0));
    s1.Lifespan = 2.5;
    s2 = spawn(class'ShockRing',,,Victim.Location,rot(0,16384,0));
    s2.Lifespan = 2.5;
    s3 = spawn(class'ShockRing',,,Victim.Location,rot(0,0,16384));
    S3.Lifespan = 2.5;
    
    r = Rand(100);
    if(r < 10)
    {
        foreach VisibleActors(class'DeusExPlayer', player, 250)
        {
            if (player != None)
            {
                player.TakeDamage(100, Instigator, player.Location, vect(0,0,0), 'Flamed');
                DeusExPlayer(Instigator).HealPlayer(50, True);
                DeusExPlayer(Instigator).StopPoison();
                DeusExPlayer(Instigator).ExtinguishFire();
                DeusExPlayer(Instigator).drugEffectTimer = 0;
                DeusExPlayer(Instigator).Energy += 25;
                if (DeusExPlayer(Instigator).Energy > DeusExPlayer(Instigator).EnergyMax)
                    DeusExPlayer(Instigator).Energy = DeusExPlayer(Instigator).EnergyMax;
            }
        }
    }
}

function MutatorTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, 
                        out Vector Momentum, name DamageType)
{
local int TD,red, hp;
local bool bCrit;
    if(DeusExPlayer(Victim) != None && DeusExPlayer(Victim).ReducedDamageType == 'All')
        DrawProtShield(victim);
    if(ScriptedPawn(Victim) != None && ScriptedPawn(Victim).bInvincible)
        DrawProtShield(victim);	
    if(bCrits)
    {
        if(Rand(100) < 10)
        {
            DeusExPlayer(InstigatedBy).ClientMessage("|P4CRITICAL HIT!");
            ActualDamage = ActualDamage * 2;
            SpawnExplosion(Victim, InstigatedBy);
            hp=Victim.Health;
            bCrit=true;
        }
        
    }
    if(DeusExPlayer(InstigatedBy) != None && DeusExPlayer(Victim) != None && bAntiCheatKill)
    {
        if(DeusExPlayer(InstigatedBy).ReducedDamageType == 'All')
            ActualDamage=0;
            
        if(DamageType == 'Tantalus')
            ActualDamage = 0;
        
        if(DeusExPlayer(InstigatedBy).IsInState('cheatFlying'))
            ActualDamage=0;
            
        if(ActualDamage == 0)
            DrawProtShield(victim);
    }
    
    if(PlayerPawn(InstigatedBy) != None && HasVG(PlayerPawn(InstigatedBy)) != None && HasVG(PlayerPawn(InstigatedBy)).bOn)
        ActualDamage = ActualDamage * 2;
        
    if(PlayerPawn(Victim) != None && HasPA(PlayerPawn(Victim)) != None)
    {
        if(GetPADur(PlayerPawn(Victim)) >= 0)
        {
            if(HasPA(PlayerPawn(Victim)).bResistFire && DamageType == 'Flamed')
            {
                DamageType = 'None';
                ActualDamage=0;
            }
            if(HasPA(PlayerPawn(Victim)).bResistPoison && DamageType == 'Poison')
            {
                DamageType = 'None';
                PlayerPawn(Victim).TakeDamage(ActualDamage, instigatedBy, Victim.Location, vect(0,0,1),'Shot');
                ActualDamage = 0;
            }
            if(HasPA(PlayerPawn(Victim)).bResistEMP && DamageType == 'EMP')
            {
                DamageType = 'None';
                ActualDamage=0;
            }
            HitPA(PlayerPawn(Victim),1);
            red = ActualDamage - GetPADef(PlayerPawn(Victim));
            //Log("Armour debug: "$ActualDamage$" to "$red);
            ActualDamage -= GetPADef(PlayerPawn(Victim));
            DamageType = 'shot';
            DrawProtShield(victim);
            
            if(GetPADur(PlayerPawn(Victim)) <= 0)
            {
                DeusExPlayer(victim).ClientMessage("Your armour broke! ("$HasPA(PlayerPawn(Victim)).ItemName$")");
                Victim.PlaySound(Sound'DeusExSounds.Augmentation.CloakDown', SLOT_None,,, 2048);
                HasPA(PlayerPawn(Victim)).Destroy();
            }
            super.MutatorTakeDamage(ActualDamage, victim, instigatedby, hitLocation, momentum, damagetype);
            return;
        }
    }
        
    if(PlayerPawn(Victim) != None && HasAA(PlayerPawn(Victim)) != None)
    {
        if(DeusExPlayer(Victim).Energy >= 1)
        {
            TD = ActualDamage / 4;
            DeusExPlayer(Victim).Energy -= TD;
            ActualDamage = 0;
            DamageType = 'shot';
            DrawAdminShield(victim);
            if(DeusExPlayer(Victim).Energy < 1)
            {
                Victim.PlaySound(Sound'DeusExSounds.Augmentation.CloakDown', SLOT_None,,, 2048);
            }
            return;
        }
    }
    if(PlayerPawn(Victim) != None && HasRA(PlayerPawn(Victim)) != None && InstigatedBy != None)
    {
        if(DeusExPlayer(Victim).Energy >= 1)
        {
            //Disabling for others using Return Armour due to infinite recursion
            if(DXScriptedPawn(InstigatedBy) != None && DXScriptedPawn(InstigatedBy).bReturnArmour)
                return;
            if(PlayerPawn(InstigatedBy) != None && HasRA(PlayerPawn(InstigatedBy)) != None)
                return;
            DeusExPlayer(Victim).Energy -= ActualDamage / 3;
            InstigatedBy.TakeDamage(ActualDamage / 2, InstigatedBy, hitLocation, Momentum, DamageType);
            ActualDamage = ActualDamage / 4;
            DrawReturnShield(victim);
            if(DeusExPlayer(Victim).Energy < 1)
            {
                Victim.PlaySound(Sound'DeusExSounds.Augmentation.CloakDown', SLOT_None,,, 2048);
            }
            return;
        }
    }
    
    hp -= ActualDamage;
    
    if(bCrit && hp <= 0 && DeusExPlayer(Victim).ReducedDamageType != 'All' && !ScriptedPawn(Victim).bInvincible)
    {
        DeusExPlayer(InstigatedBy).ClientMessage("|P2CRITICAL KILL!");
        DeusExPlayer(InstigatedBy).HealPlayer(50, True);
        DeusExPlayer(InstigatedBy).StopPoison();
        DeusExPlayer(InstigatedBy).ExtinguishFire();
        DeusExPlayer(InstigatedBy).drugEffectTimer = 0;
        DeusExPlayer(InstigatedBy).Energy += 25;
        if (DeusExPlayer(InstigatedBy).Energy > DeusExPlayer(InstigatedBy).EnergyMax)
            DeusExPlayer(InstigatedBy).Energy = DeusExPlayer(InstigatedBy).EnergyMax;
    }
    super.MutatorTakeDamage(ActualDamage, victim, instigatedby, hitLocation, momentum, damagetype);
}

function ModifyPlayer(Pawn Other)
{
    local int x;
    local int k;
    local int i;
    local int m;
    local DeusExPlayer P;
    local PSCreditCard ccc;
    local inventory inv;
        P = DeusExPlayer(Other);

    if(P != None)
        P.MaxRegenPoint = 0;
    
    if(bClearSpawnInventory)
    {
        foreach AllActors(class'Inventory',inv)
        {
            if(Inv.Owner == Other)
            {
                if(Inv.IsA('Medkit'))
                    Inv.Destroy();
                if(Inv.IsA('Lockpick'))
                    Inv.Destroy();
                if(Inv.IsA('Multitool'))
                    Inv.Destroy();
            }
        }
    }

        //p.Credits = 200;

    p.Credits = 50;
    
    if(P!=None && bGiveAutomed)
    {
        inv=Spawn(class'Automed');
        Inv.Frob(P,None);	  
        Inventory.bInObjectBelt = True;
        inv.Destroy();
    }
    
    if(P!=None && bGivePSCC)
    {
        ccc = Spawn(class'PSCreditCard');
        ccc.Frob(p,None);
        ccc.Destroy();
    }
    Super.ModifyPlayer(Other);
}

function Tick(float deltatime)
{
local Spydrone SD;
local FleshFragment F;
local int Random;

if(bSuperGore)
{
    Random = Rand(100);

    ForEach AllActors(class'FleshFragment', F)
    {
            F.Velocity   = vect(10, 10, 1000);
            F.Fatness    = F.Default.Fatness + Random;
            F.elasticity = 1.0;
        }
    }
    
    if(bSpydroneMod)
    {
        foreach AllActors(class'SpyDrone',SD)
        {
            if(SD != None)
            {
                SD.bBlockPlayers = True;
                SD.DamageType = 'None';
                SD.Damage = 0;
                SD.MaxSpeed = 700;
                ConsoleCommand("Set Augdrone ReconstructTime 1");
            }
        }
    }
}

function Mutate (String S, PlayerPawn PP)
{
    local int a, i, j, ID, amount;
    local string IP, AName, Part, noobCommand, bm, Others, _tmpString, Message;
    local DeusExPlayer SP;
local Box PC;
local int JSlot;
    local Pawn APawn;
local string msgs;
local MSGR msobj;
local string formattedmin;
    local sound pgSound;
    local DeusExPlayer DXP;
    local string oldmsgs, msgs2;
    local bool bAutoPackage;
    local float Pitch;
    local Actor hitActor;
    local vector loc, line, HitLocation, hitNormal;
    local Decal Dec;
    local JobScanner JS;
    
    Super.Mutate (S, PP);
    
        if(left(S,5) ~= "MSGR ")
        {
            msgs = Right(S, Len(S) - 5);
            msobj = Spawn(Class'MSGR',,,PP.Location + (PP.CollisionRadius+Default.CollisionRadius+30) * Vector(PP.ViewRotation) + vect(0,0,1) * 30 );
            msobj.MSGSender = PP.PlayerReplicationInfo.PlayerName;
                if(level.minute <= 9)
                {
                    formattedmin = "0"$level.minute;
                }
                else
                {
                    formattedmin = string(level.minute);
                }
            msobj.MSGTimestamp = level.hour$":"$formattedmin;
            msobj.myMSG = msgs;
            msobj.bSentByPlayer=True;
            PP.ClientMessage("Message created.");
        }
        
        if(left(S,7) ~= "setplay" && PP.bAdmin)
        {
            msgs = Right(S, Len(S) - 7);
            if(msgs ~= "allon")
            {
                bAllowPlayAll=True;
            }
            if(msgs ~= "alloff")
            {
                bAllowPlayAll=False;
            }
            if(msgs ~= "on")
            {
                bAllowPlay=True;
            }
            if(msgs ~= "off")
            {
                bAllowPlay=false;
            }
            SaveConfig();
            BroadcastMessage("PLAY SETTINGS: bAllowPlay"@bAllowPlay@": bAllowPlayAll"@bAllowPlayAll);
        }
        
        if(left(S,5) ~= "play " && bAllowPlay)
        {
            msgs = Right(S, Len(S) - 5);
            pitch = 1;
                if(instr(caps(msgs), caps(" ")) != -1) //Assuming theres other words after
                {
                    msgs2 = Right(msgs, Len(msgs)-instr(msgs," ")-Len(" "));
                    msgs = Left(msgs, InStr(msgs," "));

                    if(msgs2 != "")
                    {
                        j = int(msgs2);
                        pitch = (j*0.15)+0.5;
                    }
                    pitch = FClamp(pitch, 0.5, 2.0);
                    //Log("OUT:"$msgs@msgs2@pitch);
                }

            

            oldmsgs = msgs;
            if ( InStr(msgs,".") == -1 )//No package specified, passing through to the auto-namer to see if anything matches.
            {
                bAutoPackage=True;
                msgs="DeusExSounds." $ msgs;
                pgSound = Sound(DynamicLoadObject(msgs, class'Sound', true));
                    if (pgSound == None) //Nothing found in Deus Ex, now checking PartySoundPack, but if it IS found, move along to the sound
                    {
                        msgs = oldmsgs; //Resetting for pass two, assuming PartySoundPack
                            msgs="PartySoundPack." $ msgs;
                            pgSound = Sound(DynamicLoadObject(msgs, class'Sound', true));
                            if (pgSound == None) //Nothing found, erroring
                            {
                            DeusExPlayer(PP).ClientMessage("|P2ERROR: DynamicLoadObject failed or no package specified. (DynamicLoadObject could not find " $ oldmsgs $ ")");
                            return;
                            }
                    }
            }
            
            if(!bAutoPackage)
                pgSound = Sound(DynamicLoadObject(msgs, class'Sound', true));
            //if(j == 0)
            //	j = DefaultPitch;
                
            if (pgSound != None)
                PP.PlaySound(pgSound, SLOT_Talk,2,,1024,pitch);
            else
                DeusExPlayer(PP).ClientMessage("|P2ERROR: Audio file not found.");

        }
        
        if(left(S,8) ~= "playall " && bAllowPlayAll)
        {
            msgs = Right(S, Len(S) - 8);
            pitch=1;
                if(instr(caps(msgs), caps(" ")) != -1) //Assuming theres other words after
                {
                    msgs2 = Right(msgs, Len(msgs)-instr(msgs," ")-Len(" "));
                    msgs = Left(msgs, InStr(msgs," "));

                    if(msgs2 != "")
                    {
                        j = int(msgs2);
                        pitch = (j*0.15)+0.5;
                    }
                    pitch = FClamp(pitch, 0.5, 2.0);
                    //Log("OUT:"$msgs@msgs2@pitch);
                }

                        oldmsgs = msgs;
            if ( InStr(msgs,".") == -1 )//No package specified, passing through to the auto-namer to see if anything matches.
            {
                bAutoPackage=True;
                msgs="DeusExSounds." $ msgs;
                pgSound = Sound(DynamicLoadObject(msgs, class'Sound', true));
                    if (pgSound == None) //Nothing found in Deus Ex, now checking PartySoundPack, but if it IS found, move along to the sound
                    {
                        msgs = oldmsgs; //Resetting for pass two, assuming PartySoundPack
                            msgs="PartySoundPack." $ msgs;
                            pgSound = Sound(DynamicLoadObject(msgs, class'Sound', true));
                            if (pgSound == None) //Nothing found, erroring
                            {
                            DeusExPlayer(PP).ClientMessage("|P2ERROR: DynamicLoadObject failed or no package specified. (DynamicLoadObject could not find "$oldmsgs$")");
                            return;
                            }
                    }
            }
            
            if(!bAutoPackage)
                pgSound = Sound(DynamicLoadObject(msgs, class'Sound', true));
            
                
            if (pgSound != None)
            {
                foreach AllActors(class'DeusExPlayer',DXP)
                {
                DXP.PlaySound(pgSound, SLOT_Talk,2,,1024,pitch);
                }
            }
            else
            {
                DeusExPlayer(PP).ClientMessage("|P2ERROR: Audio file not found.");
            }

        }
        else if(S ~= "DroneRiding" || S ~= "DR")
        {
            if(PP.bAdmin)
            {
                if(bSpydroneMod)
                {//Turning off spydrone riding
                    bSpydroneMod = False;
                    BroadcastMessage("|P3Spydrone riding has been enabled by "$PP.PlayerReplicationInfo.Playername);
                }
                else
                {//Turning on spydrone riding
                    bSpydroneMod = True;
                    BroadcastMessage("|P3Spydrone riding has been disabled by "$PP.PlayerReplicationInfo.Playername);
                }
            }
        }
        else if(S ~= "BoxCleanup" || S ~= "BC")
        {
            if(PP.bAdmin)
            {
                BroadcastMessage("|P3Boxes cleared by "$PP.PlayerReplicationInfo.Playername);	
                foreach allactors(class'Box',PC)
                {
                    if(PC != None)
                    {
                    PC.Lifespan = 1;
                    }
                    else 
                    {
                    BroadcastMessage("Command Failed : No actors to Destroy");
                    }
                }
            }
        }
        else if(S ~= "Resign")
        {
            foreach AllActors(class'JobScanner', JS)
            {
                if(JS.Assist1 == DeusExPlayer(PP))
                {
                    JS.Assist1 = None;
                    PP.ClientMessage("Job resigned.");
                }
                if(JS.Assist2 == DeusExPlayer(PP))
                {
                    JS.Assist2 = None;
                    PP.ClientMessage("Job resigned.");
                }
                if(JS.Assist3 == DeusExPlayer(PP))
                {
                    JS.Assist3 = None;
                    PP.ClientMessage("Job resigned.");
                }
            }
        }
        else if(S ~= "SuperGore" || S ~= "SG")
        {
            if(PP.bAdmin)
            {
                bSuperGore = !bSuperGore;
                BroadcastMessage("|P3Super Gore is "$bSuperGore);	
            }
        }
        else if(S ~= "link")
        {
            loc = PP.Location;
            loc.Z += PP.BaseEyeHeight;
            line = Vector(PP.ViewRotation) * 10000;
            
            if(getLink(pp) != None)
            {
                PP.ClientMessage("Already linked to something.");
                return;
            }
            HitActor = Trace(hitLocation, hitNormal, loc+line, loc, true);
            if(DXScriptedPawn(HitActor) != None && DXScriptedPawn(HitActor).bCanLink)
            {
                PP.ClientMessage("Link created.");
                DXScriptedPawn(HitActor).LinkedPlayer = PP;
                DXScriptedPawn(HitActor).bLinked=True;
            }
        }
        else if(S ~= "link.clear")
        {
            if(GetLink(pp) != None)
            {
                GetLink(pp).bLinked=False;
                GetLink(pp).LinkedPlayer = None;
                PP.ClientMessage("Link cleared.");
            }
            else
            PP.ClientMessage("No link found.");
        }
        else if(S ~= "link.kill")
        {
            if (GetLink(pp) != None)
            {
                PP.ClientMessage(string(GetLink(pp).class)@"destroyed.");
                GetLink(pp).bInvincible    = false;
                GetLink(pp).HealthHead     = 0;
                GetLink(pp).HealthTorso    = 0;
                GetLink(pp).HealthLegLeft  = 0;
                GetLink(pp).HealthLegRight = 0;
                GetLink(pp).HealthArmLeft  = 0;
                GetLink(pp).HealthArmRight = 0;
                GetLink(pp).Health         = 0;
                GetLink(pp).TakeDamage(10000, PP, vect(0,0,0),vect(0,0,1),'Exploded');
            }
            else
            PP.ClientMessage("No link found.");
        }
        else if(S ~= "link.go")
        {
            if (GetLink(pp) != None)
            {
            PP.SetLocation(GetLink(PP).Location);
            }
            else
            PP.ClientMessage("No link found.");
        }
        else if(S ~= "link.bring")
        {
            if (GetLink(pp) != None)
            {
                GetLink(PP).SetCollision(false, false, false);
                GetLink(PP).bCollideWorld = true;
                GetLink(PP).GotoState('PlayerWalking');
                GetLink(PP).SetLocation(PP.Location);
                GetLink(PP).SetCollision(true, true , true);
                GetLink(PP).SetPhysics(PHYS_Walking);
                GetLink(PP).bCollideWorld = true;
                GetLink(PP).GotoState('PlayerWalking');
                GetLink(PP).ClientReStart();
            }
            else
            PP.ClientMessage("No link found.");
        }
        else if(S ~= "link.swap")
        {
            if (GetLink(pp) != None)
            {
            SwapLoc(PP, GetLink(PP));
            }
            else
            PP.ClientMessage("No link found.");
        }
        else if(S ~= "link.view")
        {}		
        else if(Left(S,2) ~= "s ")
        {
            Message = Right(S,Len(S)-2);
            Message = "|p1"$Message;
            ForEach AllActors(class 'DeusExPlayer', SP)
            {
            if(SP != None)
            {
                SetOwner(SP);
                ShowMessage(SP,Message);
            }
            }
        }
}

function SwapLoc(pawn Sender, Pawn Sender2)
{
    local vector Temp1, Temp2;
    
    Temp1 = Sender.Location;
    Temp2 = Sender2.Location;
    
    Sender2.SetCollision(false, false, false);
    Sender2.bCollideWorld = true;
    Sender2.GotoState('PlayerWalking');
    Sender2.SetLocation(Temp1);
    Sender2.SetCollision(true, true , true);
    Sender2.SetPhysics(PHYS_Walking);
    Sender2.bCollideWorld = true;
    Sender2.GotoState('PlayerWalking');
    Sender2.ClientReStart();
        
    Sender.SetCollision(false, false, false);
    Sender.bCollideWorld = true;
    Sender.GotoState('PlayerWalking');
    Sender.SetLocation(Temp2);
    Sender.SetCollision(true, true , true);
    Sender.SetPhysics(PHYS_Walking);
    Sender.bCollideWorld = true;
    Sender.GotoState('PlayerWalking');
    Sender.ClientReStart();	
}

function DXScriptedPawn GetLink(playerpawn check)
{
    local DXScriptedPawn DXS;
    
    foreach AllActors(class'DXScriptedPawn', DXS)
        if(DXS.LinkedPlayer == check)
            return DXS;
}

defaultproperties
{
    bSpydroneMod=True
    bSuperGore=True
    bHidden=True
}
