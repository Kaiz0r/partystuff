//=============================================================================
// SuperTool.
//=============================================================================
class Estus extends DeusExPickup;

//Add colouring to the HUD, green(P3) - 5, (P4)yellow 4 3 2 1, (P2)red 0
var() int eUses, eMaxUses;
var int ru;
var bool bEstusArmed;

var float explosionDamage;
var float explosionRadius;
	
replication
{
reliable if (bNetOwner && Role==ROLE_Authority)
ru;
}

function DropFrom(vector StartLocation)
{
	bEstusArmed=True;
	super.DropFrom(StartLocation);
}

function BecomePickup()
{
	if(Owner != None)
		bEstusArmed=True;
	super.BecomePickup();
}

function BecomeItem()
{
	bEstusArmed=False;
	super.BecomeItem();
}

function estusExplode()
{
	local SphereEffect sphere;
	local ScorchMark s;
	local ExplosionLight light;
	local int i;

	// alert NPCs that I'm exploding
	AISendEvent('LoudNoise', EAITYPE_Audio, , explosionRadius*16);
	PlaySound(Sound'LargeExplosion1', SLOT_None,,, explosionRadius*16);

	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, Location);
	if (light != None)
		light.size = 4;

	Spawn(class'ExplosionSmall',,, Location + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionMedium',,, Location + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionMedium',,, Location + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionLarge',,, Location + 2*VRand()*CollisionRadius);

	sphere = Spawn(class'SphereEffect',,, Location);
	if (sphere != None)
		sphere.size = explosionRadius / 32.0;

	// spawn a mark
	s = spawn(class'ScorchMark', Base,, Location-vect(0,0,1)*CollisionHeight, Rotation+rot(16384,0,0));
	if (s != None)
	{
		s.DrawScale = FClamp(explosionDamage/30, 0.1, 3.0);
		s.ReattachDecal();
	}

	// spawn some rocks and flesh fragments
	for (i=0; i<explosionDamage/6; i++)
	{
		if (FRand() < 0.3)
			spawn(class'Rockchip',,,Location);
	}

	HurtRadius(explosionDamage*eUses, explosionRadius, 'Exploded', explosionDamage*100, Location);
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
		MaxCopies = 1;
}

simulated event RenderOverlays(canvas Canvas)
{
	local DeusExPlayer P;
	local Actor CrosshairTarget;
	local float Scale, Accuracy, Dist;
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
		local vector loc, line;
			local String KeyName, Alias, curKeyName;
	local int i;
	local string str;
	local Actor hitActor;
	local string mi;
	
	Super.RenderOverlays(Canvas);
	P = DeusExPlayer(Owner);
	if ( P != None ) 
	{	
				loc = P.Location;
				loc.Z += P.BaseEyeHeight;
				line = Vector(P.ViewRotation) * 90000;
			
				hitActor = Trace(hitLocation, hitNormal, loc+line, loc, true);
				Dist = Abs(VSize(HitLocation - P.Location));
				//bOwnsCrossHair = True; 
				Scale = Canvas.ClipX/640;
				Canvas.SetPos(0.5 * Canvas.ClipX - 16 * Scale, 0.5 * Canvas.ClipY - 16 * Scale );
				//Canvas.Style = ERenderStyle.STY_Translucent;
				Canvas.DrawColor.R = 255;
				Canvas.DrawColor.G = 250;
				Canvas.DrawColor.B = 255;
				Canvas.Font = Canvas.SmallFont;
				if(ru == 0)
					mi = "|P2";
				else if(ru > 0 && ru < 5)
					mi = "|P4";
				else mi = "|P3";
					
				if(ScriptedPawn(hitActor) != None && dist < 256)
					str = " - Will use on "$ScriptedPawn(hitActor).FamiliarName;
				
				if(DeusExPlayer(hitActor) != None && dist < 256)
					str = " - Will use on "$DeusExPlayer(hitActor).PlayerReplicationInfo.PlayerName;
					
				Canvas.DrawText("      Uses left: "$ru$str);
	}
			//else
				//bOwnsCrossHair = False; // Only for compatibility with HDX50		
}

state Activated
{
	function Activate()
	{
		// can't turn it off
	}

	function BeginState()
	{
		local DeusExPlayer player, hitplayer;
		local scriptedpawn hitpawn;
		local dxScriptedPawn hitpawn2;
		local Actor       hitActor;
		local Vector      hitLocation, hitNormal;
		local Vector      position, line;
		local float Dist;
		Super.BeginState();
		player = DeusExPlayer(Owner);
		if(eUses > 0)
		{
			position    = player.Location;
			position.Z += player.BaseEyeHeight;
			line        = Vector(player.ViewRotation) * 4000;
			hitActor = Trace(hitLocation, hitNormal, position+line, position, true);
			hitplayer = DeusExPlayer(hitActor);
			hitpawn = ScriptedPawn(hitactor);
			hitpawn2 = dxScriptedPawn(hitactor);
			Dist = Abs(VSize(HitLocation - player.Location));
			if (player != None)
			{
				if (hitplayer != None && dist < 256) //Use on another player
				{
					Spawn(class'EstusCloud',,,Player.Location,player.ViewRotation);
					Hitplayer.ClientMessage("You have been healed by"@player.PlayerReplicationInfo.PlayerName);
					Player.ClientMessage("You have healed "@hitplayer.PlayerReplicationInfo.PlayerName);
					EstusUse(hitplayer);
				}
				else if(hitpawn != None && dist < 256)
				{
					Spawn(class'EstusCloud',,,Player.Location,player.ViewRotation);
					HitPawn.Health = HitPawn.default.Health;
					 HitPawn.HealthHead= HitPawn.default.HealthHead;
					 HitPawn.HealthTorso= HitPawn.default.HealthTorso;
					 HitPawn.HealthLegLeft= HitPawn.default.HealthLegLeft;
					 HitPawn.HealthLegRight= HitPawn.default.HealthLegRight;
					 HitPawn.HealthArmLeft= HitPawn.default.HealtharmLeft;
					 HitPawn.HealthArmRight= HitPawn.default.HealthArmRight;
					 Player.ClientMessage("You have healed "@hitpawn.Familiarname);
				}
				else if(hitpawn2 != None && dist < 256)
				{
					 Hitpawn2.CurrentBossArmour = Hitpawn2.default.CurrentBossArmour;
					 Hitpawn2.CurrentReturnArmour = Hitpawn2.default.CurrentReturnArmour;
				}
				else //Use on self
				{
					EstusUse(player);
				}
			}	
			eUses--;
			ru=eUses;
			player.ClientMessage("The flask has "$eUses$" uses left.");
		}
		else
		{
			player.ClientMessage("The flask is empty.");
		}
		
		GotoState('DeActivated');
	}
Begin:
}

function EstusUse(deusexplayer p)
{
	p.HealPlayer(50, True);
	p.StopPoison();
	p.ExtinguishFire();
	p.drugEffectTimer = 0;
	p.Energy += 50;
			if (p.Energy > p.EnergyMax)
				p.Energy = p.EnergyMax;
}

function bool UpdateInfo(Object winObject)
{
	local PersonaInfoWindow winInfo;
	local string str;

	winInfo = PersonaInfoWindow(winObject);
	if (winInfo == None)
		return False;

	winInfo.SetTitle(itemName @ String(eUses));
	winInfo.SetText(Description $ winInfo.CR() $ winInfo.CR());
//	winInfo.AppendText(Sprintf(RechargesLabel, RechargeAmount));

	// Print the number of copies
	str = CountLabel @ String(eUses);
	winInfo.AppendText(winInfo.CR() $ winInfo.CR() $ str);

	return True;
}

simulated function bool TestMPBeltSpot(int BeltSpot)
{
   return (BeltSpot == 9);
}

function Destroyed() 
{
	local ProjectileGenerator gen;
	
	
	if ( !bEstusArmed || eUses == 0)
		return;
		
	EstusExplode();
	gen = Spawn(class'ProjectileGenerator',,, Location);
	if (gen != None)
	{
     //gen.RemoteRole = ROLE_None;
		//gen.particleDrawScale = 1.0;
		gen.checkTime = 0.05;
		gen.frequency = 1.0;
		gen.ejectSpeed = 200.0;
		//gen.bGravity = True;
		gen.bRandomEject = True;
		gen.ProjectileClass=class'Fireball';
		gen.LifeSpan = 2.0;
	}
	super.Destroyed();
}

defaultproperties
{
	ExplosionRadius=100
	ExplosionDamage=100
	bBreakable=True
	eMaxUses=5
	eUses=5
	ru=5
     maxCopies=1
     bActivatable=True
     ItemName="Estus flask"
     M_Activated=""
     PlayerViewOffset=(X=16.000000,Y=8.000000,Z=-16.000000)
     PlayerViewMesh=LodMesh'DeusExDeco.Flask'
     PickupViewMesh=LodMesh'DeusExDeco.Flask'
     ThirdPersonMesh=LodMesh'DeusExDeco.Flask'
     LandSound=Sound'DeusExSounds.Generic.GlassHit1'
    Icon=Texture'PGAssets.Icons.BeltIconEstus'
    largeIcon=Texture'PGAssets.Icons.LargeIconEstus'
     largeIconWidth=18
     largeIconHeight=44
     Description="Estus magic potion of healing"
     beltDescription="ESTUS"
    Texture=Texture'DeusExDeco.Skins.AlarmLightTex9'
    Mesh=LodMesh'DeusExDeco.Flask'
    AmbientGlow=20
    MultiSkins(0)=Texture'DeusExDeco.Skins.AlarmLightTex9'
    MultiSkins(1)=Texture'DeusExDeco.Skins.AlarmLightTex9'
    MultiSkins(2)=Texture'DeusExDeco.Skins.AlarmLightTex9'
    MultiSkins(3)=Texture'DeusExDeco.Skins.AlarmLightTex9'
    MultiSkins(4)=Texture'DeusExDeco.Skins.AlarmLightTex9'
    MultiSkins(5)=Texture'DeusExDeco.Skins.AlarmLightTex9'
    MultiSkins(6)=Texture'DeusExDeco.Skins.AlarmLightTex9'
    MultiSkins(7)=Texture'DeusExDeco.Skins.AlarmLightTex9'
    SoundVolume=64
    CollisionRadius=4.20
    CollisionHeight=7.45
    LightType=1
    LightBrightness=50
    LightSaturation=20
    LightRadius=5
    Mass=10.00
    Buoyancy=8.00
}
