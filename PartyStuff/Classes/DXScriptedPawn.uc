class DXScriptedPawn expands ScriptedPawn;
//Boss armour needs tweaking
//Make boss armour a takedamage mutator for players
//Lower freq of scanning barks

#exec obj load File=DeusExConAudioAIBarks.u
var() bool bUseChatList;
var() bool bSpecial;
var() string Saymsg;
var() string ListMSGs[5];
var() bool bRandomList;
var DeusExPlayer p;
var rotator oldViewRotation;
var float rtfTimer;
var float autoTimer;
var int scoreCredits, scoreEXP;
var bool bKD;
var int i;
var() bool bPhatLewt;
var() class<actor> Lewt;
var DeusExPlayer CamLock;
var() sound ConvoSound; 
var() bool bPlaySound;
var() bool bIgnoreAdmins;
var() bool bCanLink;
var() string AllianceGroup;
var() bool bHasCloakX;
var() bool bVoiced;
var() int Medkits;
var() int MedkitMinHealth;
var(Sounds) sound SoundBossArmourBreak, SoundBossArmourRestore;
var(Taunts) string tScanning, tTargetAcquired, tTargetLost, tCriticalDamage, tAreaSecure, tBossArmourDown, tBossArmourBack, tMedkitUsed, tCallingBackup, tRespondBackup, tHunting;
var(Taunts) sound sScanning[5], sTargetAcquired[3], sTargetLost[3], sCriticalDamage[3], sAreaSecure[3], sBossArmourDown, sBossArmourBack, sMedkitUsed, sCallingBackup[3], sRespondBackup[3], sHunting[3];
var(Boss) bool bBossArmour;
var(Boss) int BossArmour;
var int OrigHealth;
var int CurrentBossArmour;
var PlayerPawn LinkedPlayer;
var bool bLinked;
var bool bTempMute;
var() class<DXScriptedPawn> AllyClass;
var bool bCop;
var(Boss) bool bReturnArmour;
var(Boss) int ReturnArmour;
var int CurrentReturnArmour;
var bool bReturnArmourBroken, bBossArmourBroken;
var int TimeSinceBossBreak, TimeSinceReturnBreak;
var int RACharge, BACharge;
var bool bCanChargeRA, bCanChargeBA;
var(Criminal) bool bEnableCrim;
var(Criminal) bool bSteal;
var Pawn HuntedPlayer;
var bool bPHunting;
var() int lOdds;
var bool bLegendary;
var() bool bHasADS;
var BotADS myADS;
var() int AdsEnergy;
var() bool AdsUnlimited;

var DeusExPlayer FallbackTarget;

var(Spawning) bool bLimitSpawning;
var(Spawning) int MinPlayers, PercentageChanceOfSpawn;

function TCBark(string BarkMessage, DeusExPlayer Target,  optional float Delay)
{
    local DeusExPlayer dxp;
    local DeusExRootWindow root;
	local TCBarkActor TCBA;
	
	if(Delay <= 1.0)
		Delay = 8.0;
		
		TCBA = Spawn(class'TCBarkActor');
		TCBA.Flagger = Target;
		TCBA.pSender = self;
		TCBA.sMessage = BarkMessage;
		TCBA.fDelay = Delay;
		TCBA.SetTimer(0.1,false);
}

function RadiusMSG(string BarkMessage, optional float BarkRange, optional float Delay)
{
    local DeusExPlayer dxp;
    local DeusExRootWindow root;
	local bool bRadius;
	local TCBarkActor TCBA;
	
	if(Delay <= 1)
		Delay = 8.0;
	
	if(BarkRange <= 1)
		BarkRange = 512;

	
	foreach RadiusActors(class'DeusExPlayer', DXP, BarkRange)
	{
		TCBA = Spawn(class'TCBarkActor');
		TCBA.Flagger = DXP;
		TCBA.pSender = self;
		TCBA.sMessage = BarkMessage;
		TCBA.fDelay = Delay;
		TCBA.SetTimer(0.1,false);
	}
}

function PlayScanningSound()
{
	local int i;
	
	i = Rand(5);
	if(tScanning != "" && FRand() < 0.3)
		RadiusMSG(tScanning);

	if(sScanning[i] != None && FRand() < 0.3)
		PlaySound(sScanning[i], SLOT_None,,, 2048);
}

function PlayHuntingSound()
{
	local int i;
	
	i = Rand(5);
	if(tHunting != "" && FRand() < 0.4)
		RadiusMSG(tHunting);
	
	if(sHunting[i] != None)
		PlaySound(sHunting[i], SLOT_None,,, 2048);
}

function PlayTargetAcquiredSound()
{
		local int i;
	
	i = Rand(5);
	if(tTargetAcquired != "" && !bTempMute && FRand()<0.5)
		RadiusMSG(tTargetAcquired);
	
	if(sTargetAcquired[i] != None)
		PlaySound(sTargetAcquired[i], SLOT_None,,, 2048);
	bTempMute=false;
}

function PlayTargetLostSound()
{
	local int i;
	
	i = Rand(5);
	if(tTargetLost != "")
		RadiusMSG(tTargetLost);
	
	if(sTargetLost[i] != None)
		PlaySound(sTargetLost[i], SLOT_None,,, 2048);
}

function PlayGoingForAlarmSound()
{
}

function PlayCriticalDamageSound()
{
	local int i;
	
	i = Rand(5);
	if(tCriticalDamage != "")
		RadiusMSG(tCriticalDamage);
	
	if(sCriticalDamage[i] != None)
		PlaySound(sCriticalDamage[i], SLOT_None,,, 2048);
}

function PlayAreaSecureSound()
{
	local int i;
	
	i = Rand(5);
	if(tAreaSecure != "")
		RadiusMSG(tAreaSecure);
	
	if(sAreaSecure[i] != None)
		PlaySound(sAreaSecure[i], SLOT_None,,, 2048);
}

function PostBeginPlay()
{
local int Below, Higher, Players;
	local DeusExPlayer DXP;
	
     Super.PostBeginPlay();
     
    if(bLimitSpawning)
	{
		foreach AllActors(class'DeusExPlayer', DXP)
			Players++;
		
		if(Players < MinPlayers)
			Destroy();
	}
		
	if(bHasADS)
	{
		myAds = Spawn(class'BotADS');
		myAds.P = Self;
		myAds.AdsEnergy = AdsEnergy;
		myAds.AdsUnlimited = AdsUnlimited;
		myAds.SetTimer(0.1,True);
	}
	
	if(AllianceGroup == "")
		AllianceGroup = familiarName;
		
	if(AllyClass == None)
		AllyClass = Self.class;


     if (bIsFemale)
     {
          HitSound1 = Sound'FemalePainMedium';
          HitSound2 = Sound'FemalePainLarge';
          Die = Sound'FemaleDeath';
     }
     
	 Below = scoreCredits -= 100;
		if(Below < 0)
			Below = 0;
	 Higher = scoreCredits += 150;
	 scoreCredits = RandRange(Below, Higher);
	 
	CurrentBossArmour = BossArmour;
	CurrentReturnArmour = returnArmour;
	OrigHealth = Health;
	
	if(lOdds > 0)
	{
		if(Rand(100) <= lOdds)
		{
			bLegendary=True;
			CurrentBossArmour *= 2;
			CurrentReturnArmour *= 2;
			BossArmour *= 2;
			ReturnArmour *= 2;
			Health *= 2;
			HealthHead *= 2;
			HealthTorso *= 2;
			HealthlegLeft *= 2;
			HealthLegRight *= 2;
			HealthArmLeft *= 2;
			HealthArmRight *= 2;
			Drawscale *= 1.3;
			SetCollisionSize(CollisionRadius * 1.2, CollisionHeight * 1.2);
		}
	}
}

function BreakBossArmour()
{
	if(tBossArmourDown != "")
		RadiusMSG(tBossArmourDown);
	if(SoundBossArmourBreak != None)
		PlaySound(SoundBossArmourBreak, SLOT_None,,, 2048);
	if(sBossArmourDown != None)
		PlaySound(sBossArmourDown, SLOT_None,,, 2048);
}

function DrawBossShield()
{
	local BossArmourEffect shield;
	shield = Spawn(class'BossArmourEffect', Self,, Location, Rotation);
	if (shield != None)
	{
		Shield.DrawScale = Drawscale;
		shield.SetBase(Self);
	}
}

function DrawReturnShield()
{
	local ReturnArmourEffect shield;

	shield = Spawn(class'ReturnArmourEffect', Self,, Location, Rotation);
	if (shield != None)
	{
		Shield.DrawScale = Drawscale;
		shield.SetBase(Self);
	}
}

function UseMedkit()
{
local int t;
	if(Medkits > 0)
	{
		if(tMedkitUsed != "")
			RadiusMSG(tMedkitUsed);
		
		if(sMedkitUsed != None)
			PlaySound(sMedkitUsed, SLOT_None,,, 2048);
		Health = OrigHealth;
		Medkits--;
		PlaySound(sound'MedicalHiss', SLOT_None,,, 256);
	}
}

function TakeDamageBase(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType,
                        bool bPlayAnim)
{
	local int          actualDamage;
	local Vector       offset;
	local float        origHealth;
	local EHitLocation hitPos;
	local float        shieldMult;
	local DXScriptedPawn alliez;
	local AllySpawnPoint ASP;
	local int HealthLow, reduc;
	local ReturnArmour AA;
	local DeusExPlayer criminal;
	local CopSpawnPoint CSP;
	local bool bDoCrim, bFound, bDoSpawn;
	local DXScriptedPawn cCop, cCount;
	local CActor CA;
	local int ccc, cCountint;
	local int i;
	
	i = Rand(5);
	if(DamageType == 'Tantalus') //Cos tantalus should still be a kill-all effect.... that and the tantalus command borked it.
	{
		Super.TakeDamageBase(Damage, instigatedBy, hitlocation, momentum, damageType, bPlayAnim);
		return;
	}
	
	if(bSteal && scoreCredits > 0)
	{
		if(DeusExPlayer(instigatedBy) != None)
		{
			criminal = DeusExPlayer(instigatedBy);
			criminal.ClientMessage("You stole"@scoreCredits@"credits from"@FamiliarName);
			criminal.Credits+=scoreCredits;
			scoreCredits=0;
		}
	}
	if(bEnableCrim)
	{
		if(DeusExPlayer(instigatedBy) != None)
		{
			criminal = DeusExPlayer(instigatedBy);
			bDoCrim=true;
		}
		
		if(bDoCrim)
		{
			foreach AllActors(class'CActor',CA)
			{
				if(CA.Crim == DeusExPlayer(InstigatedBy))
				{
					bFound=True;
					CA.CC++;
					if(CA.CC > CA.CLim)
					{
						CA.CC=0;
						CA.CL++;
							if(CA.CL == 2)
								CA.CLim=20;
						//Make client
						criminal.clientmessage("You are now wanted by security forces. (Level "$CA.CL$")");
						bDoSpawn=True;
					}
				}
			}
			if(!bFound)
			{
				CA = Spawn(class'CActor');
				CA.Crim = criminal;
				CA.CC++;
				CA.SetTimer(1,True);
				CA.CN = criminal.PlayerReplicationInfo.PlayerName;
				BroadcastMessage(criminal.PlayerReplicationInfo.PlayerName$" is now being watched by security forces.");
			}
			if(bDoSpawn)
			{
				foreach RadiusActors(Class'CopSpawnPoint', CSP, 756)
				{
					foreach AllActors(class'DXScriptedPawn',cCount)
						if(cCount.bCop)
							cCountint++;
					
					if(cCountint < 15)
					{
						cCop = Spawn(CSP.CopClass,,,CSP.Location);
						cCop.GotoState('Attacking');
						cCop.SetEnemy(instigatedby);
						cCop.InitializePawn();
						cCop.bPHunting=True;
						cCop.PlayHuntingSound();
						cCop.HuntedPlayer = instigatedBy;
						ccc++;
					}
				}
				if(ccc == 0)
					BroadcastMessage("Security forces are now hunting "$criminal.PlayerReplicationInfo.PlayerName$".");
				else if(ccc == 1)
					BroadcastMessage("Security forces are now hunting "$criminal.PlayerReplicationInfo.PlayerName$". "$ccc$" unit appeared.");
				else if(ccc > 1)
					BroadcastMessage("Security forces are now hunting "$criminal.PlayerReplicationInfo.PlayerName$". "$ccc$" units appeared.");
				
			}
		}
	}
	
	foreach RadiusActors(Class'DXScriptedPawn', alliez, 756)
	{
		if((AllianceGroup == Alliez.AllianceGroup) && (alliez != Self))
		{
			if(alliez.Enemy == None)
			{
				if(tCallingBackup != "" && FRand() < 0.8)
					RadiusMSG(tCallingBackup);
				if(sCallingBackup[i] != None)
					PlaySound(sCallingBackup[i], SLOT_None,,, 2048);
					alliez.bTempMute=True;
					alliez.GotoState('Attacking');
					//alliez.TakeDamage(1, Enemy, Location, vect(0,0,0), 'shot');
					alliez.SetEnemy(instigatedby);
					if(alliez.tRespondBackup != "" && FRand()<0.7)
						alliez.RadiusMSG(tRespondBackup);
						
					if(alliez.sRespondBackup[i] != None)
						alliez.PlaySound(sRespondBackup[i], SLOT_None,,, 2048);
						
					alliez.InitializePawn();
			}
		}
	}
			
	if(bBossArmour && CurrentBossArmour >= 1)
	{
		ReactToInjury(instigatedBy, damageType, hitPos);
		DrawBossShield();
		reduc = damage / 2;
		CurrentBossArmour -= Damage;
		bCanChargeBA=True;
		if(CurrentBossArmour < 1)
		{	
			BreakBossArmour();
		}
		return;
	}
	
	if(bReturnArmour && CurrentReturnArmour >= 1)
	{
		if(DXScriptedPawn(InstigatedBy) != None && DXScriptedPawn(InstigatedBy).bReturnArmour)
			return;
		if(HasRA(PlayerPawn(InstigatedBy)) != None)
			return;
		ReactToInjury(instigatedBy, damageType, hitPos);
		DrawReturnShield();
		reduc = damage / 4;
		CurrentReturnArmour -= Damage;
		bCanChargeRA = True;
		InstigatedBy.TakeDamage(reduc, InstigatedBy, hitLocation, Momentum, DamageType); 
		if(CurrentReturnArmour < 1)
		{	
			BreakBossArmour();
		}
		return;
	}
	HealthLow = Health / 2;
	if(Health <= HealthLow && Medkits > 0)
	{
		UseMedkit();
		return;
	}
		
	Super.TakeDamageBase(Damage, instigatedBy, hitlocation, momentum, damageType, bPlayAnim);			
}

function ReturnArmour HasRA(PlayerPawn PP)
{
local ReturnArmour AA;

	foreach AllActors(class'ReturnArmour', AA)
			if(AA.Owner == PP)
				return AA;
}

function Tick(float deltaTime)
{
	local int half;
	local SphereEffect ms;
	
	
	super.Tick(deltatime);
	// Keep turning towards the person we're speaking to
	
	if(bPHunting)
	{
		if((Enemy == None) && (HuntedPlayer == None || HuntedPlayer.Health <= 0))
		{
			PlayAreaSecureSound();
			Destroy();
		}
	}
	
	if (P != None)
	{
		LookAtActor(P, true, true, true, 0, 0.5);
		LipSynch(deltaTime);
	}
	
	half = Health/2;
	if(Medkits > 0 && Health < half)
	{
		if(tMedkitUsed != "")
			RadiusMSG(tMedkitUsed);
		if(sMedkitUsed != None) PlaySound(sMedkitUsed, SLOT_None,,, 2048);
		Health = OrigHealth;
		Medkits--;
		ms = Spawn(class'SphereEffect',,,Location);
		ms.Texture=FireTexture'Effects.liquid.Ambrosia_SFX';
		ms.Skin=FireTexture'Effects.liquid.Ambrosia_SFX';
		PlaySound(sound'MedicalHiss', SLOT_None,,, 256);
	}
	if(Enemy == None && bBossArmour && CurrentBossArmour <= BossArmour && bCanChargeBA)
	{
		BACharge++;
		if(BACharge == 100)
		{
			CurrentBossArmour += Rand(20);
			BACharge=0;
			DrawBossShield();
		}
		if(CurrentBossArmour > BossArmour)
		{
			bCanChargeBA=False;
			if(tBossArmourBack != "")
				RadiusMSG(tBossArmourBack);
			if(SoundBossArmourRestore != None)
				PlaySound(SoundBossArmourRestore, SLOT_None,,, 2048);
			if(sBossArmourBack != None)
				PlaySound(sBossArmourBack, SLOT_None,,, 2048);
		}
	}
	//Make it gradual, like ++ tick instead of set
	if(Enemy == None && bReturnArmour && CurrentReturnArmour <= ReturnArmour && bCanChargeRA)
	{
		RACharge++;
		if(RACharge == 100)
		{
			CurrentReturnArmour += Rand(20);
			RACharge=0;
			DrawReturnShield();
		}
		if(CurrentReturnArmour > ReturnArmour)
		{
			bCanChargeRA=False;
			if(tBossArmourBack != "")
				RadiusMSG(tBossArmourBack);
			if(SoundBossArmourRestore != None)
				PlaySound(SoundBossArmourRestore, SLOT_None,,, 2048);
			if(sBossArmourBack != None)
				PlaySound(sBossArmourBack, SLOT_None,,, 2048);
		}
	}
	
	if (Enemy != None && DeusExPlayer(Enemy).bAdmin && bIgnoreAdmins)
	{
		DeusExPlayer(Enemy).MakePlayerIgnored(True);
	   SetEnemy(None, 0, true);
	}
}

simulated function ConvMessage(DeusExPlayer P, string Message)
{
	local HUDMissionStartTextDisplay _HUD;

	if((P.RootWindow != None) && (DeusExRootWindow(P.RootWindow).HUD != None))
	{
		_HUD = DeusExRootWindow(P.RootWindow).HUD.startDisplay;
	}

	if(_HUD != None) 
	{ 
		_HUD.shadowDist = 0; 
		_HUD.Message = ""; 
		_HUD.charIndex = 0; 
		_HUD.winText.SetText(""); 
		_HUD.winTextShadow.SetText(""); 
		_HUD.displayTime = 5.50; 
		_HUD.perCharDelay = 0.30; 
		_HUD.AddMessage(Message); 
		_HUD.StartMessage(); 
	}
}

state KillSwitchBoss
{
	ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, Timer, TakeDamage;

	function BeginState()
	{	
		StandUp();
		AIClearEventCallback('Futz');
		AIClearEventCallback('MegaFutz');
		AIClearEventCallback('Player');
		AIClearEventCallback('WeaponDrawn');
		AIClearEventCallback('LoudNoise');
		AIClearEventCallback('WeaponFire');
		AIClearEventCallback('Carcass');
		AIClearEventCallback('Distress');
		AmbientGlow=255;
		Acceleration = vect(0,0,0);
		LastPainTime = Level.TimeSeconds;
		LastPainAnim = AnimSequence;
		bInterruptState = false;
		BlockReactions();
		bCanConverse = False;
		bStasis = False;
		SetDistress(true);
		TakeHitTimer = 2.0;
		EnemyReadiness = 1.0;
		ReactionLevel  = 1.0;
		bInTransientState = true;
	}

Begin:
	BossFX();
	FinishAnim();
	PlayAnim('HitTorso', 1.0, 0.1);
	FinishAnim();
	PlayAnim('HitHead', 1.0, 0.1);
	FinishAnim();
	PlayAnim('HitTorsoBack', 1.0, 0.1);
	FinishAnim();
	PlayAnim('HitHeadBack', 1.0, 0.1);
	FinishAnim();
	PlayAnim('HitHead', 2.0, 0.1);
	FinishAnim();
	PlayAnim('HitHeadBack', 2.0, 0.1);
	FinishAnim();
	PlayAnim('HitHead', 3.0, 0.1);
	FinishAnim();
	PlayAnim('HitHeadBack', 1.0, 0.1);
	FinishAnim();
	LockPlayersCam();
	PlayAnim('DeathFront', 0.5, 0.1);
	FinishAnim();
	UnLockPlayersCam();
	Explode2();
	Destroy();
}

function LockPlayersCam()
{
local DeusExPlayer DXP;
foreach AllActors(class'DeusExPlayer', DXP)
{
			DXP.bBehindView=True;
			DXP.ViewTarget = Self;
}
}

function UnLockPlayersCam()
{
local DeusExPlayer DXP;
foreach AllActors(class'DeusExPlayer', DXP)
{
			DXP.bBehindView=False;
			DXP.ViewTarget = None;
}
}

function LockPlayerCam(deusexplayer dxp)
{
			dxp.bBehindView=True;
			dxp.ViewTarget = Self;
}

function UnLockPlayerCam(deusexplayer dxp)
{
			dxp.bBehindView=False;
			dxp.ViewTarget = None;
}

function ReleasePlayerCam()
{
	if(CamLock != None)
	{
			CamLock.bBehindView=False;
			CamLock.ViewTarget = None;
			CamLock=None;
	}
}

function BossFX()
{
		local ProjectileGenerator PG;
		//bCollideActors=False;
		bBlockActors=False;
		PG = spawn(class'ProjectileGenerator',,,Location,rot(16384,0,0));
		PG.bRandomEject=True;
		PG.ProjectileClass = class'Tracer';
		PG.NumPerSpawn = 5;
		PG.CheckTime = 1;
		PG.Lifespan=4;
}

state KillSwitch
{
	ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, Timer, TakeDamage;

	function BeginState()
	{
		StandUp();
		AIClearEventCallback('Futz');
		AIClearEventCallback('MegaFutz');
		AIClearEventCallback('Player');
		AIClearEventCallback('WeaponDrawn');
		AIClearEventCallback('LoudNoise');
		AIClearEventCallback('WeaponFire');
		AIClearEventCallback('Carcass');
		AIClearEventCallback('Distress');

		Acceleration = vect(0,0,0);
		LastPainTime = Level.TimeSeconds;
		LastPainAnim = AnimSequence;
		bInterruptState = false;
		BlockReactions();
		bCanConverse = False;
		bStasis = False;
		SetDistress(true);
		TakeHitTimer = 2.0;
		EnemyReadiness = 1.0;
		ReactionLevel  = 1.0;
		bInTransientState = true;
			//ForgottenRespawn();
	}

Begin:
	FinishAnim();
	PlayAnim('HitTorso', 2.0, 0.1);
	FinishAnim();
	PlayAnim('HitHead', 2.0, 0.1);
	FinishAnim();
	PlayAnim('HitTorsoBack', 2.0, 0.1);
	FinishAnim();
	PlayAnim('HitHeadBack', 2.0, 0.1);
	FinishAnim();
	PlayAnim('HitHead', 3.0, 0.1);
	FinishAnim();
	PlayAnim('HitHeadBack', 3.0, 0.1);
	FinishAnim();
	PlayAnim('HitHead', 5.0, 0.1);
	FinishAnim();
	PlayAnim('HitHeadBack', 5.0, 0.1);
	FinishAnim();
	Explode();
	Destroy();
}

function Explode()
{
	local SphereEffect sphere;
	local ScorchMark s;
	local ExplosionLight light;
	local int i;
	local float explosionDamage;
	local float explosionRadius;

	explosionDamage = 100;
	explosionRadius = 256;

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
		else
			spawn(class'FleshFragment',,,Location);
	}
	PlayDyingSound();
	HurtRadius(explosionDamage, explosionRadius, 'Exploded', explosionDamage*100, Location);
		if(bPhatLewt)
		{
			Spawn(Lewt,,,Location);
		}
}

function ExplodeBot()
{
	local SphereEffect sphere;
	local ScorchMark s;
	local ExplosionLight light;
	local int i;
	local float explosionDamage;
	local float explosionRadius;

	explosionDamage = 100;
	explosionRadius = 256;

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
	
	PlayDyingSound();
	HurtRadius(explosionDamage, explosionRadius, 'Exploded', explosionDamage*100, Location);
		if(bPhatLewt)
		{
			Spawn(Lewt,,,Location);
		}
}

function Explode2()
{
	local SphereEffect sphere;
	local ScorchMark s;
	local ExplosionLight light;
	local int i;
	local float explosionDamage;
	local float explosionRadius;

	explosionDamage = 200;
	explosionRadius = 300;

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
		else
			spawn(class'FleshFragment',,,Location);
	}
	PlayDyingSound();
	HurtRadius(explosionDamage, explosionRadius, 'Exploded', explosionDamage*100, Location);
		
		if(bPhatLewt)
		{
			Spawn(Lewt,,,Location);
		}
}

function Frob(Actor Frobber, Inventory frobWith) 
{
local string resoWut;
local int r;

	if(P == None)
	{
		P=DeusExPlayer(Frobber);
		if(bUseChatList)
		{
			if(bRandomList)
			{
				i = Rand(5);
				LockPlayerCam(P);
				CamLock = P;
				TCBark(ListMSGs[i], P);
							oldViewRotation = ViewRotation;
							LookAtActor(P, false, true, true, 0, 1.0);
							SetTimer(2.2, true);
											if(bPlaySound)
												PlaySound(ConvoSound, SLOT_None,2,,1024,);		
			}
			else
			{
				i++;
					if(i>5)
						i=0;
						LockPlayerCam(P);
							CamLock = P;
							TCBark(ListMSGs[i], P);
							oldViewRotation = ViewRotation;
							LookAtActor(P, false, true, true, 0, 1.0);
							SetTimer(2.2, true);
											if(bPlaySound)
												PlaySound(ConvoSound, SLOT_None,2,,1024,);		
			}
		}
		else
		{
				LockPlayerCam(P);
				CamLock = P;
			TCBark(Saymsg, P);
			oldViewRotation = ViewRotation;
			LookAtActor(P, false, true, true, 0, 1.0);
			SetTimer(2.2, true);
			
				if(bPlaySound)
					PlaySound(ConvoSound, SLOT_None,2,,1024,);			
		}		
	}
	else
	{
		if(P != DeusExPlayer(Frobber))
		{
			DeusExPlayer(Frobber).ClientMessage(familiarName$" is busy talking to someone else...");
		}
	}
}

function ExtSay(string Str)
{
local DeusExPlayer DXP;
	foreach allActors(class'DeusExPlayer',DXP)
	{
		DXP.ClientMessage(familiarName$": "$str, 'Say');
	}
}

function Timer()
{
	ViewRotation = oldViewRotation;
	FollowOrders();
	ReleasePlayerCam();
	p = none;
}

function PreBeginPlay()
{
	if(MenuName == "")
		MenuName = FamiliarName;

	Super.PreBeginPlay();
}

function Carcass SpawnCarcass()
{
	local DeusExCarcass carc;
	local vector loc;
	local Inventory item, nextItem;
	local FleshFragment chunk;
	local int i;
	local float size;

	// if we really got blown up good, gib us and don't display a carcass
	if ((Health < -100) && !IsA('Robot'))
	{
		size = (CollisionRadius + CollisionHeight) / 2;
		if (size > 10.0)
		{
			for (i=0; i<size/4.0; i++)
			{
				loc.X = (1-2*FRand()) * CollisionRadius;
				loc.Y = (1-2*FRand()) * CollisionRadius;
				loc.Z = (1-2*FRand()) * CollisionHeight;
				loc += Location;
				chunk = spawn(class'FleshFragment', None,, loc);
				if (chunk != None)
				{
					chunk.DrawScale = size / 25;
					chunk.SetCollisionSize(chunk.CollisionRadius / chunk.DrawScale, chunk.CollisionHeight / chunk.DrawScale);
					chunk.bFixedRotationDir = True;
					chunk.RotationRate = RotRand(False);
				}
			}
		}

		return None;
	}

	// spawn the carcass
	if(CarcassType == None)
	 carc = Spawn(class'MPCarcass');
	else
		carc = DeusExCarcass(Spawn(CarcassType));
	if(Mesh == LodMesh'DeusExCharacters.GM_DressShirt_B')
	{
		 carc.Mesh2=LodMesh'DeusExCharacters.GM_DressShirt_B_CarcassB';
		 carc.Mesh3=LodMesh'DeusExCharacters.GM_DressShirt_B_CarcassC';
		 carc.Mesh=LodMesh'DeusExCharacters.GM_DressShirt_B_Carcass';
	}
	if(Mesh == LodMesh'DeusExCharacters.GM_Trench')
	{
		 carc.Mesh2=LodMesh'DeusExCharacters.GM_Trench_CarcassB';
		 carc.Mesh3=LodMesh'DeusExCharacters.GM_Trench_CarcassC';
		 carc.Mesh=LodMesh'DeusExCharacters.GM_Trench_Carcass';
	}
	if(Mesh == LodMesh'DeusExCharacters.GFM_Trench')
	{
		 carc.Mesh2=LodMesh'DeusExCharacters.GFM_Trench_CarcassB';
		 carc.Mesh3=LodMesh'DeusExCharacters.GFM_Trench_CarcassC';
		 carc.Mesh=LodMesh'DeusExCharacters.GFM_Trench_Carcass';
	}
	if(Mesh == LodMesh'DeusExCharacters.GM_DressShirt')
	{
		 carc.Mesh2=LodMesh'DeusExCharacters.GM_DressShirt_CarcassB';
		 carc.Mesh3=LodMesh'DeusExCharacters.GM_DressShirt_CarcassC';
		 carc.Mesh=LodMesh'DeusExCharacters.GM_DressShirt_Carcass';
	}
	if(Mesh == LodMesh'DeusExCharacters.GFM_SuitSkirt')
	{
		 carc.Mesh2=LodMesh'DeusExCharacters.GFM_SuitSkirt_CarcassB';
		 carc.Mesh3=LodMesh'DeusExCharacters.GFM_SuitSkirt_CarcassC';
		 carc.Mesh=LodMesh'DeusExCharacters.GFM_SuitSkirt_Carcass';
	}
	if(Mesh == LodMesh'DeusExCharacters.GFM_Dress')
	{
		 carc.Mesh2=LodMesh'DeusExCharacters.GFM_Dress_CarcassB';
		 carc.Mesh3=LodMesh'DeusExCharacters.GFM_Dress_CarcassC';
		 carc.Mesh=LodMesh'DeusExCharacters.GFM_Dress_Carcass';
	}
	if(Mesh == LodMesh'DeusExCharacters.GM_Jumpsuit')
	{
		 carc.Mesh2=LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassB';
		 carc.Mesh3=LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassC';
		 carc.Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit_Carcass';
	}
	if(Mesh == LodMesh'DeusExCharacters.GM_suit')
	{
		 carc.Mesh2=LodMesh'DeusExCharacters.GM_suit_CarcassB';
		 carc.Mesh3=LodMesh'DeusExCharacters.GM_suit_CarcassC';
		 carc.Mesh=LodMesh'DeusExCharacters.GM_suit_Carcass';
	}
	 carc.Texture=Texture;
     carc.MultiSkins[0]=MultiSkins[0];
     carc.MultiSkins[1]=MultiSkins[1];
     carc.MultiSkins[2]=MultiSkins[2];
     carc.MultiSkins[3]=MultiSkins[3];
     carc.MultiSkins[4]=MultiSkins[4];
     carc.MultiSkins[5]=MultiSkins[5];
     carc.MultiSkins[6]=MultiSkins[6];
     carc.MultiSkins[7]=MultiSkins[7];

	if ( carc != None )
	{
		if (bStunned)
			carc.bNotDead = True;

		carc.Initfor(self);

		// move it down to the floor
		loc = Location;
		loc.z -= Default.CollisionHeight;
		loc.z += carc.Default.CollisionHeight;
		carc.SetLocation(loc);
		carc.Velocity = Velocity;
		carc.Acceleration = Acceleration;

			if (Inventory != None)
			{
				do
				{
					item = Inventory;
					nextItem = item.Inventory;
					DeleteInventory(item);
					if ((DeusExWeapon(item) != None) && (DeusExWeapon(item).bNativeAttack))
						item.Destroy();
					else
						carc.AddInventory(item);
					item = nextItem;
				}
				until (item == None);
			}
	}

	return carc;
}

//States
State Attacking
{
	ignores Frob;
     function ReactToInjury(Pawn instigatedBy, Name damageType, EHitLocation hitPos)
     {
          local Pawn oldEnemy;
          local bool bHateThisInjury;
          local bool bFearThisInjury;

          if ((health > 0) && (bLookingForInjury || bLookingForIndirectInjury))
          {
               oldEnemy = Enemy;

               bHateThisInjury = ShouldReactToInjuryType(damageType, bHateInjury, bHateIndirectInjury);
               bFearThisInjury = ShouldReactToInjuryType(damageType, bFearInjury, bFearIndirectInjury);

               if (bHateThisInjury)
                    IncreaseAgitation(instigatedBy, 1.0);
               if (bFearThisInjury)
                    IncreaseFear(instigatedBy, 2.0);

               if (ReadyForNewEnemy())
                    SetEnemy(instigatedBy);

               if (ShouldFlee())
               {
                    SetDistressTimer();
                    PlayCriticalDamageSound();
                    if (RaiseAlarm == RAISEALARM_BeforeFleeing)
                         SetNextState('Alerting');
                    else
                         SetNextState('Fleeing');
               }
               else
               {
                    SetDistressTimer();
                    if (oldEnemy != Enemy)
                         PlayNewTargetSound();
                    SetNextState('Attacking', 'ContinueAttack');
               }
               GotoDisabledState(damageType, hitPos);
          }
     }

     function SetFall()
     {
          StartFalling('Attacking', 'ContinueAttack');
     }

     function HitWall(vector HitNormal, actor Wall)
     {
          if (Physics == PHYS_Falling)
               return;
          Global.HitWall(HitNormal, Wall);
          CheckOpenDoor(HitNormal, Wall);
     }

     function Reloading(DeusExWeapon reloadWeapon, float reloadTime)
     {
          Global.Reloading(reloadWeapon, reloadTime);
          if (bReadyToReload)
               if (IsWeaponReloading())
                    if (!IsHandToHand())
                         TweenToShoot(0);
     }

     function EDestinationType PickDestination()
     {
          local vector               distVect;
          local vector               tempVect;
          local rotator              enemyDir;
          local float                magnitude;
          local float                calcMagnitude;
          local int                  iterations;
          local EDestinationType     destType;
          local NearbyProjectileList projList;

          destPoint = None;
          destLoc   = vect(0, 0, 0);
          destType  = DEST_Failure;

          if (enemy == None)
               return (destType);

          if (bCrouching && (CrouchTimer > 0))
               destType = DEST_SameLocation;

          if (destType == DEST_Failure)
          {
               if (AICanShoot(enemy, true, false, 0.025) || ActorReachable(enemy))
               {
                    destType = ComputeBestFiringPosition(tempVect);
                    if (destType == DEST_NewLocation)
                         destLoc = tempVect;
               }
          }

          if (destType == DEST_Failure)
          {
               MoveTarget = FindPathToward(enemy);
               if (MoveTarget != None)
               {
                    if (!bDefendHome || IsNearHome(MoveTarget.Location))
                    {
                         if (bAvoidHarm)
                              GetProjectileList(projList, MoveTarget.Location);
                         if (!bAvoidHarm || !IsLocationDangerous(projList, MoveTarget.Location))
                         {
                              destPoint = MoveTarget;
                              destType  = DEST_NewLocation;
                         }
                    }
               }
          }

          // Default behavior, so they don't just stand there...
          if (destType == DEST_Failure)
          {
               enemyDir = Rotator(Enemy.Location - Location);
               if (AIPickRandomDestination(60, 150,
                                           enemyDir.Yaw, 0.5, enemyDir.Pitch, 0.5,
                                           2, FRand()*0.4+0.35, tempVect))
               {
                    if (!bDefendHome || IsNearHome(tempVect))
                    {
                         destType = DEST_NewLocation;
                         destLoc  = tempVect;
                    }
               }
          }

          return (destType);
     }

     function bool FireIfClearShot()
     {
          local DeusExWeapon dxWeapon;

          dxWeapon = DeusExWeapon(Weapon);


          //bReadyToFire doesn't seem to work right for Scripted Pawns
          // So I set it and execute ReadyToFire() automatically.

          dxWeapon.bReadyToFire=false;
          dxWeapon.ReadyToFire();

          if (dxWeapon != None)
          {
               if ((dxWeapon.AIFireDelay > 0) && (FireTimer > 0))
                    return false;
               else if (AICanShoot(enemy, true, true, 0.025))
               {

                    //Changed from Fire to ClientFire.
                    Weapon.ClientFire(0);
                    FireTimer = dxWeapon.AIFireDelay;
                    return true;
               }
               else
                   return false;

          }
          else
              return false;
     }

     function CheckAttack(bool bPlaySound)
     {
          local bool bCriticalDamage;
          local bool bOutOfAmmo;
          local Pawn oldEnemy;
          local bool bAllianceSwitch;

          oldEnemy = enemy;

          bAllianceSwitch = false;
          if (!IsValidEnemy(enemy) || (DeusExPlayer(Enemy).bAdmin && bIgnoreAdmins))
          {
               if (IsValidEnemy(enemy, false))
                    bAllianceSwitch = true;
               SetEnemy(None, 0, true);
          }

          if (enemy == None)
          {
               if (Orders == 'Attacking')
               {
                    FindOrderActor();
                    SetEnemy(Pawn(OrderActor), 0, true);
               }
          }
          if (ReadyForNewEnemy())
               FindBestEnemy(false);
          if (enemy == None)
          {
               Enemy = oldEnemy;  // hack
               if (bPlaySound)
               {
                    if (bAllianceSwitch)
                         PlayAllianceFriendlySound();
                    else
                         PlayAreaSecureSound();
               }
               Enemy = None;
               if (Orders != 'Attacking')
                    FollowOrders();
               else
                    GotoState('Wandering');
               return;
          }

          SwitchToBestWeapon();
          if (bCrouching && (CrouchTimer <= 0) && !ShouldCrouch())
          {
               EndCrouch();
               TweenToShoot(0.15);
          }
          bCriticalDamage = False;
          bOutOfAmmo      = False;
          if (ShouldFlee())
               bCriticalDamage = True;
          else if (Weapon == None)
               bOutOfAmmo = True;
          else if (Weapon.ReloadCount > 0)
          {
               if (Weapon.AmmoType == None)
                    bOutOfAmmo = True;
               else if (Weapon.AmmoType.AmmoAmount < 1)
                    bOutOfAmmo = True;
          }
          if (bCriticalDamage || bOutOfAmmo)
          {
               if (bPlaySound)
               {
                    if (bCriticalDamage)
                         PlayCriticalDamageSound();
                    else if (bOutOfAmmo)
                         PlayOutOfAmmoSound();
               }
               if (RaiseAlarm == RAISEALARM_BeforeFleeing)
                    GotoState('Alerting');
               else
                    GotoState('Fleeing');
          }
          else if (bPlaySound && (oldEnemy != Enemy))
               PlayNewTargetSound();
     }

	function Tick (float DeltaSeconds)
	{
		local bool bCanSee;
		local float Yaw;
		local Vector lastLocation;
		local Pawn lastEnemy;
		local float surpriseTime;
		local bool bCanFire2;
		local bool bFacingTarget2;
		local DeusExWeapon dxw;

		if ( Weapon != None )
		{
			dxw = DeusExWeapon(Weapon);
			if ( dxw != None )
				bCanFire2 = rtfTimer >= dxw.ShotTime;
		}
		rtfTimer += DeltaSeconds;
		autoTimer += DeltaSeconds;
		Global.Tick(DeltaSeconds);
		if ( CrouchTimer > 0 )
		{
			CrouchTimer -= DeltaSeconds;
			if ( CrouchTimer < 0 )
				CrouchTimer = 0.0;
		}
		EnemyTimer += DeltaSeconds;
		UpdateActorVisibility(Enemy,DeltaSeconds,1.0,False);
		if ( (Enemy != None) && HasEnemyTimedOut() )
		{
			lastLocation = Enemy.Location;
			lastEnemy = Enemy;
			FindBestEnemy(True);
			if ( Enemy == None )
			{
				SetSeekLocation(lastEnemy,lastLocation,SEEKTYPE_Guess,True);
				GotoState('Seeking');
			}
		} else {
			if ( bCanFire2 && (Enemy != None) )
			{
				ViewRotation = rotator(Enemy.Location - Location);
				bFacingTarget2 = bCheckFace();
				if ( bFacingTarget2 )
				{
					FireIfClearShot();
				} else  if (  !bMustFaceTarget )
				{
					yaw = (ViewRotation.Yaw-Rotation.Yaw) & 0xFFFF;
					if (yaw >= 32768)
						yaw -= 65536;
					yaw = Abs(yaw)*360/32768;  // 0-180 x 2
					if (yaw <= FireAngle)
						FireIfClearShot();
				}
			}
		}
	}

     function bool IsHandToHand()
     {
          if (Weapon != None)
          {
               if (DeusExWeapon(Weapon) != None)
               {
                    if (DeusExWeapon(Weapon).bHandToHand)
                         return true;
                    else
                         return false;
               }
               else
                    return false;
          }
          else
               return false;
     }

     function bool ReadyForWeapon()
     {
          local bool bReady;

          bReady = false;
          if (DeusExWeapon(weapon) != None)
          {
               if (DeusExWeapon(weapon).bReadyToFire)
                    if (!IsWeaponReloading())
                         bReady = true;
          }
          if (!bReady)
               if (enemy == None)
                    bReady = true;
          if (!bReady)
               if (!AICanShoot(enemy, true, false, 0.025))
                    bReady = true;

          return (bReady);
     }

     function bool ShouldCrouch()
     {
          if (bCanCrouch && !Region.Zone.bWaterZone && !IsHandToHand() &&
              ((enemy != None) && (VSize(enemy.Location-Location) > 300)) &&
              ((DeusExWeapon(Weapon) == None) || DeusExWeapon(Weapon).bUseWhileCrouched))
               return true;
          else
               return false;
     }

     function StartCrouch()
     {
          if (!bCrouching)
          {
			//if(bHasCloakX)
			//EnableCloak(True);
				
               bCrouching = true;
               SetBasedPawnSize(CollisionRadius, GetCrouchHeight());
               CrouchTimer = 1.0+FRand()*0.5;
          }
     }

     function EndCrouch()
     {
          if (bCrouching)
          {
		  	//	if(bHasCloakX)
				//	EnableCloak(False);
               bCrouching = false;
               ResetBasedPawnSize();
          }
     }

     function BeginState()
     {
		local DXScriptedPawn alliez;
		local AllySpawnPoint ASP;
		local int i;
	
		i = Rand(5);
          StandUp();
		  	foreach RadiusActors(Class'AllySpawnPoint', ASP, 756)
			{
				if((ASP.AllyGroup == AllianceGroup || ASP.AllyGroup == "") && ASP.SpawnedAlly == None && !ASP.bCooling)
				{
						ASP.bCooling=True;
						ASP.SetTimer(ASP.Cooldown,false);
						if(tCallingBackup != "" && FRand() < 0.8)
							RadiusMSG(tCallingBackup);
						if(sCallingBackup[i] != None)
							PlaySound(sCallingBackup[i], SLOT_None,,, 2048);
							ASP.SpawnedAlly = Spawn(AllyClass,,,ASP.Location);
							//ASP.SpawnedAlly.GotoState('Attacking');
							//alliez.TakeDamage(1, Enemy, Location, vect(0,0,0), 'shot');
							ASP.SpawnedAlly.SetEnemy(Enemy, 0, true);
							ASP.SpawnedAlly.InitializePawn();
								if(ASP.SpawnedAlly.tRespondBackup != "" && FRand()<0.7)
									ASP.SpawnedAlly.RadiusMSG(tRespondBackup);
								
								if(ASP.SpawnedAlly.sRespondBackup[i] != None)
									ASP.SpawnedAlly.PlaySound(sRespondBackup[i], SLOT_None,,, 2048);
				}
			}
			foreach RadiusActors(Class'DXScriptedPawn', alliez, 256)
			{
				if((AllianceGroup == Alliez.AllianceGroup) && (alliez != Self))
				{
					if(alliez.Enemy == None)
					{
						if(tCallingBackup != "")
							RadiusMSG(tCallingBackup);
						
						if(sCallingBackup[i] != None)
							PlaySound(sCallingBackup[i], SLOT_None,,, 2048);
							
							alliez.bTempMute=True;
							alliez.GotoState('Attacking');
							//alliez.TakeDamage(1, Enemy, Location, vect(0,0,0), 'shot');
							alliez.SetEnemy(enemy, 0, true);
						if(alliez.tRespondBackup != "" && FRand()<0.7)
						alliez.RadiusMSG(tRespondBackup);
					
					if(alliez.sRespondBackup[i] != None)
						alliez.PlaySound(sRespondBackup[i], SLOT_None,,, 2048);
					}
				}
			}
          // hack
          if (MaxRange < MinRange+10)
               MaxRange = MinRange+10;
          bCanFire      = false;
          bFacingTarget = false;

          SwitchToBestWeapon();

          //EnemyLastSeen = 0;
          BlockReactions();
          bCanConverse = False;
          bAttacking = True;
          bStasis = False;
          SetDistress(true);

          CrouchTimer = 0;
          EnableCheckDestLoc(false);
     }

     function EndState()
     {
          EnableCheckDestLoc(false);
          bCanFire      = false;
          bFacingTarget = false;

          ResetReactions();
          bCanConverse = True;
          bAttacking = False;
          bStasis = True;
          bReadyToReload = false;

          EndCrouch();
     }

Begin:
     if (Enemy == None)
          GotoState('Seeking');
     //EnemyLastSeen = 0;
     CheckAttack(false);

Surprise:
     if ((1.0-ReactionLevel)*SurprisePeriod < 0.25)
          Goto('BeginAttack');
     Acceleration=vect(0,0,0);
     PlaySurpriseSound();
     PlayWaiting();
     while (ReactionLevel < 1.0)
     {
          TurnToward(Enemy);
          Sleep(0);
     }

BeginAttack:
     EnemyReadiness = 1.0;
     ReactionLevel  = 1.0;
     if (PlayerAgitationTimer > 0)
          PlayAllianceHostileSound();
     else
          PlayTargetAcquiredSound();
     if (PlayBeginAttack())
     {
          Acceleration = vect(0,0,0);
          TurnToward(enemy);
          FinishAnim();
     }

RunToRange:
     bCanFire       = false;
     bFacingTarget  = false;
     bReadyToReload = false;
     EndCrouch();
     if (Physics == PHYS_Falling)
          TweenToRunning(0.05);
     WaitForLanding();
     if (!IsWeaponReloading() || bCrouching)
     {
          if (ShouldPlayTurn(Enemy.Location))
               PlayTurning();
          TurnToward(enemy);
     }
     else
          Sleep(0);
     bCanFire = true;
     while (PickDestination() == DEST_NewLocation)
     {
          if (bCanStrafe && ShouldStrafe())
          {
               PlayRunningAndFiring();
               if (destPoint != None)
                    StrafeFacing(destPoint.Location, enemy);
               else
                    StrafeFacing(destLoc, enemy);
               bFacingTarget = true;
          }
          else
          {
               bFacingTarget = false;
               PlayRunning();
               if (destPoint != None)
                    MoveToward(destPoint, MaxDesiredSpeed);
               else
                    MoveTo(destLoc, MaxDesiredSpeed);
          }
          CheckAttack(true);
     }

Fire:
     bCanFire      = false;
     bFacingTarget = false;
     Acceleration = vect(0, 0, 0);

     SwitchToBestWeapon();
     if (FRand() > 0.5)
          bUseSecondaryAttack = true;
     else
          bUseSecondaryAttack = false;
     if (IsHandToHand())
          TweenToAttack(0.15);
     else if (ShouldCrouch() && (FRand() < CrouchRate))
     {
          TweenToCrouchShoot(0.15);
          FinishAnim();
          StartCrouch();
     }
     else
          TweenToShoot(0.15);
     if (!IsWeaponReloading() || bCrouching)
          TurnToward(enemy);
     FinishAnim();
     bReadyToReload = true;

ContinueFire:
     while (!ReadyForWeapon())
     {
          if (PickDestination() != DEST_SameLocation)
               Goto('RunToRange');
          CheckAttack(true);
          if (!IsWeaponReloading() || bCrouching)
               TurnToward(enemy);
          else
               Sleep(0);
     }
     CheckAttack(true);
     if (!FireIfClearShot())
          Goto('ContinueAttack');
     bReadyToReload = false;
     if (bCrouching)
          PlayCrouchShoot();
     else if (IsHandToHand())
          PlayAttack();
     else
          PlayShoot();
     FinishAnim();
     if (FRand() > 0.5)
          bUseSecondaryAttack = true;
     else
          bUseSecondaryAttack = false;
     bReadyToReload = true;
     if (!IsHandToHand())
     {
          if (bCrouching)
               TweenToCrouchShoot(0);
          else
               TweenToShoot(0);
     }
     CheckAttack(true);
     if (PickDestination() != DEST_NewLocation)
     {
          if (!IsWeaponReloading() || bCrouching)
               TurnToward(enemy);
          else
               Sleep(0);
          Goto('ContinueFire');
     }
     Goto('RunToRange');

ContinueAttack:
ContinueFromDoor:
     CheckAttack(true);
     if (PickDestination() != DEST_NewLocation)
          Goto('Fire');
     else
          Goto('RunToRange');

}

state Burning
{
	ignores Frob;
	
	function ReactToInjury(Pawn instigatedBy, Name damageType, EHitLocation hitPos)
	{
		local name newLabel;

		if (health > 0)
		{
			if (enemy != instigatedBy)
			{
				SetEnemy(instigatedBy);
				newLabel = 'NewEnemy';
			}
			else
				newLabel = 'ContinueBurn';

			if ( Enemy != None )
				LastSeenPos = Enemy.Location;
			SetNextState('Burning', newLabel);
			if ((damageType != 'TearGas') && (damageType != 'HalonGas') && (damageType != 'Stunned'))
				GotoDisabledState(damageType, hitPos);
		}
	}
	
	function bool FireIfClearShot()
    {
		Log("This shouldn't be called by this actor! ("$Self$")");
		return false;
    }
     
	function SetFall()
	{
		StartFalling('Burning', 'ContinueBurn');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Global.HitWall(HitNormal, Wall);
		CheckOpenDoor(HitNormal, Wall);
	}

	function PickDestination()
	{
		local float           magnitude;
		local float           distribution;
		local int             yaw, pitch;
		local Rotator         rotator1;
		local NavigationPoint nav;
		local float           dist;
		local NavigationPoint bestNav;
		local float           bestDist;

		destPoint = None;
		bestNav   = None;
		bestDist  = 2000;   // max distance to water

		// Seek out water
		if (bCanSwim)
		{
			nav = Level.NavigationPointList;
			while (nav != None)
			{
				if (nav.Region.Zone.bWaterZone)
				{
					dist = VSize(Location - nav.Location);
					if (dist < bestDist)
					{
						bestNav  = nav;
						bestDist = dist;
					}
				}
				nav = nav.nextNavigationPoint;
			}
		}

		if (bestNav != None)
		{
			// It'd be nice if we could traverse all pathnodes and figure out their
			// distances...  unfortunately, it's too slow.  :(

			MoveTarget = FindPathToward(bestNav);
			if (MoveTarget != None)
			{
				destPoint = bestNav;
				destLoc   = bestNav.Location;
			}
		}

		// Can't get to water -- run willy-nilly
		if (destPoint == None)
		{
			if (Enemy == None)
			{
				yaw = 0;
				pitch = 0;
				distribution = 0;
			}
			else
			{
				rotator1 = Rotator(Location-Enemy.Location);
				yaw = rotator1.Yaw;
				pitch = rotator1.Pitch;
				distribution = 0.5;
			}

			magnitude = 300*(FRand()*0.4+0.8);  // 400, +/-20%
			if (!AIPickRandomDestination(100, magnitude, yaw, distribution, pitch, distribution, 4,
			                             FRand()*0.4+0.35, destLoc))
				destLoc = Location+(VRand()*200);  // we give up
		}
	}

	function BeginState()
	{
		StandUp();
		BlockReactions();
		bCanConverse = False;
		SetupWeapon(false, true);
		bStasis = False;
		SetDistress(true);
		EnemyLastSeen = 0;
		SeekPawn = None;
		EnableCheckDestLoc(false);
	}

	function EndState()
	{
		EnableCheckDestLoc(false);
		ResetReactions();
		bCanConverse = True;
		bStasis = True;
	}

Begin:
	if (!bOnFire)
		Goto('Done');
	PlayOnFireSound();

NewEnemy:
	Acceleration = vect(0, 0, 0);

Run:
	if (!bOnFire)
		Goto('Done');
	PlayPanicRunning();
	PickDestination();
	if (destPoint != None)
	{
		MoveToward(MoveTarget, MaxDesiredSpeed);
		while ((MoveTarget != None) && (MoveTarget != destPoint))
		{
			MoveTarget = FindPathToward(destPoint);
			if (MoveTarget != None)
				MoveToward(MoveTarget, MaxDesiredSpeed);
		}
	}
	else
		MoveTo(destLoc, MaxDesiredSpeed);
	Goto('Run');

Done:
	if (IsValidEnemy(Enemy))
		HandleEnemy();
	else
		FollowOrders();

ContinueBurn:
ContinueFromDoor:
	Goto('Run');
}

function bool AICanShoot (Pawn Target, bool bLeadTarget, bool bCheckReadiness, optional float throwAccuracy, optional bool bDiscountMinRange)
{
	local DeusExWeapon dxWeapon;

	if ( (Target == None) )
	{
		return False;
	}
	if(DeusExPlayer(Target).bAdmin && bIgnoreAdmins)
	{
		return False;
	}
	if ( Target.bIgnore )
	{
		return False;
	}
	dxWeapon = DeusExWeapon(Weapon);
	if ( (dxWeapon == None) )
	{
		return False;
	}
	if ( (bCheckReadiness && !(dxWeapon.bReadyToFire)) )
	{
		return (rtfTimer > dxWeapon.reloadTime);
	}
	return Super.AICanShoot(Target,bLeadTarget,False,throwAccuracy,bDiscountMinRange);
}

function HandleSighting(Pawn pawnSighted)
{
	if(bIgnoreAdmins && DeusExPlayer(pawnSighted).bAdmin)
	{
		GotoState('Wandering');
	}
	else
	{
		if(!IsInState('Seeking'))
		{
			SetSeekLocation(pawnSighted, pawnSighted.Location, SEEKTYPE_Sight);
				GotoState('Seeking');
		}
	}
}

state HandlingEnemy
{
	ignores bump, frob;
	function BeginState()
	{
		if (Enemy == None)
			GotoState('Seeking');
		else if (RaiseAlarm == RAISEALARM_BeforeAttacking)
			GotoState('Alerting');
		else if(bIgnoreAdmins && DeusExPlayer(Enemy).bAdmin)
			gotoState('Wandering');
		else
			GotoState('Attacking');
	}
	
	function bool FireIfClearShot()
    {
		Log("This shouldn't be called by this actor! ("$Self$")");
		return false;
    }
Begin:

}

function bool bCheckFace ()
{
	local Vector v1;
	local Vector v2;
	local Rotator R;
	local float dist;

	if ( Enemy == None )
		return False;

	R = Rotation;
	v1 = Location;
	v2 = Enemy.Location;
	v1.Z = 0.0;
	v2.Z = 0.0;
	dist = VSize(v1 - v2);
	return VSize(v1 + dist * vector(R) - v2) < 10;
}

state Dying
{
	ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, Timer, TakeDamage, Frob;

	event Landed(vector HitNormal)
	{
		SetPhysics(PHYS_Walking);
	}

	function Tick(float deltaSeconds)
	{
		Global.Tick(deltaSeconds);

		if (DeathTimer > 0)
		{
			DeathTimer -= deltaSeconds;
			if ((DeathTimer <= 0) && (Physics == PHYS_Walking))
				Acceleration = vect(0,0,0);
		}
	}

	function bool FireIfClearShot()
    {
		Log("This shouldn't be called by this actor! ("$Self$")");
		return false;
    }
    
	function MoveFallingBody()
	{
		local Vector moveDir;
		local float  totalTime;
		local float  speed;
		local float  stopTime;
		local int    numFrames;

		if ((AnimRate > 0) && !IsA('Robot'))
		{
			totalTime = 1.0/AnimRate;  // determine how long the anim lasts
			numFrames = int((1.0/(1.0-AnimLast))+0.1);  // count frames (hack)

			// defaults
			moveDir   = vect(0,0,0);
			stopTime  = 0.01;

			ComputeFallDirection(totalTime, numFrames, moveDir, stopTime);

			speed = VSize(moveDir)/stopTime;  // compute speed

			// Set variables necessary for movement when walking
			if (moveDir == vect(0,0,0))
				Acceleration = vect(0,0,0);
			else
				Acceleration = Normal(moveDir)*AccelRate;
			GroundSpeed  = speed;
			DesiredSpeed = 1.0;
			bIsWalking   = false;
			DeathTimer   = stopTime;
		}
		else
			Acceleration = vect(0,0,0);
	}

	function BeginState()
	{
		EnableCheckDestLoc(false);
		StandUp();

		// don't do that stupid timer thing in Pawn.uc
		AIClearEventCallback('Futz');
		AIClearEventCallback('MegaFutz');
		AIClearEventCallback('Player');
		AIClearEventCallback('WeaponDrawn');
		AIClearEventCallback('LoudNoise');
		AIClearEventCallback('WeaponFire');
		AIClearEventCallback('Carcass');
		AIClearEventCallback('Distress');

		bInterruptState = false;
		BlockReactions(true);
		bCanConverse = False;
		bStasis = False;
		SetDistress(true);
		DeathTimer = 0;
	}

Begin:
	WaitForLanding();
	MoveFallingBody();

	DesiredRotation.Pitch = 0;
	DesiredRotation.Roll  = 0;

	// if we don't gib, then wait for the animation to finish
	if ((Health > -100) && !IsA('Robot'))
		FinishAnim();

	SetWeapon(None);

	bHidden = True;

	Acceleration = vect(0,0,0);
	SpawnCarcass();
	Destroy();
}

state FallingState 
{
	ignores Bump, Hitwall, WarnTarget, ReactToInjury, Frob;

	function ZoneChange(ZoneInfo newZone)
	{
		Global.ZoneChange(newZone);
		if (newZone.bWaterZone)
			GotoState('FallingState', 'Splash');
	}

	//choose a jump velocity
	function AdjustJump()
	{
		local float velZ;
		local vector FullVel;

		velZ = Velocity.Z;
		FullVel = Normal(Velocity) * GroundSpeed;

		If (Location.Z > Destination.Z + CollisionHeight + 2 * MaxStepHeight)
		{
			Velocity = FullVel;
			Velocity.Z = velZ;
			Velocity = EAdjustJump();
			Velocity.Z = 0;
			if ( VSize(Velocity) < 0.9 * GroundSpeed )
			{
				Velocity.Z = velZ;
				return;
			}
		}

		Velocity = FullVel;
		Velocity.Z = JumpZ + velZ;
		Velocity = EAdjustJump();
	}

	singular function BaseChange()
	{
		local float minJumpZ;

		Global.BaseChange();

		if (Physics == PHYS_Walking)
		{
			minJumpZ = FMax(JumpZ, 150.0);
			bJustLanded = true;
			if (Health > 0)
			{
				if ((Velocity.Z < -0.8 * minJumpZ) || bUpAndOut)
					GotoState('FallingState', 'Landed');
				else if (Velocity.Z < -0.8 * JumpZ)
					GotoState('FallingState', 'FastLanded');
				else
					GotoState('FallingState', 'Done');
			}
		}
	}

	function bool FireIfClearShot()
    {
		Log("This shouldn't be called by this actor! ("$Self$")");
		return false;
    }
    
	function Landed(vector HitNormal)
	{
		local float landVol, minJumpZ;
		local vector legLocation;

		minJumpZ = FMax(JumpZ, 150.0);

		if ( (Velocity.Z < -0.8 * minJumpZ) || bUpAndOut)
		{
			PlayLanded(Velocity.Z);
			if (Velocity.Z < -700)
			{
				legLocation = Location + vect(-1,0,-1);			// damage left leg
				TakeDamage(-0.14 * (Velocity.Z + 700), Self, legLocation, vect(0,0,0), 'fell');
				legLocation = Location + vect(1,0,-1);			// damage right leg
				TakeDamage(-0.14 * (Velocity.Z + 700), Self, legLocation, vect(0,0,0), 'fell');
				legLocation = Location + vect(0,0,1);			// damage torso
				TakeDamage(-0.04 * (Velocity.Z + 700), Self, legLocation, vect(0,0,0), 'fell');
			}
			landVol = Velocity.Z/JumpZ;
			landVol = 0.005 * Mass * FMin(5, landVol * landVol);
			if ( !FootRegion.Zone.bWaterZone )
				PlaySound(Land, SLOT_Interact, FMin(20, landVol));
		}
		else if ( Velocity.Z < -0.8 * JumpZ )
			PlayLanded(Velocity.Z);
	}

	function SetFall()
	{
		if (!bUpAndOut)
			GotoState('FallingState');
	}

	function BeginState()
	{
		StandUp();
		if (Enemy == None)
			Disable('EnemyNotVisible');
		else
		{
			Disable('HearNoise');
			Disable('SeePlayer');
		}
		bInterruptState = false;
		bCanConverse = False;
		bStasis = False;
		bInTransientState = true;
		EnableCheckDestLoc(false);
	}

	function EndState()
	{
		EnableCheckDestLoc(false);
		bUpAndOut = false;
		bInterruptState = true;
		bCanConverse = True;
		bStasis = True;
		bInTransientState = false;
	}

LongFall:
	if ( bCanFly )
	{
		SetPhysics(PHYS_Flying);
		Goto('Done');
	}
	Sleep(0.7);
	PlayFalling();
	if ( Velocity.Z > -150 ) //stuck
	{
		SetPhysics(PHYS_Falling);
		if ( Enemy != None )
			Velocity = groundspeed * normal(Enemy.Location - Location);
		else
			Velocity = groundspeed * VRand();

		Velocity.Z = FMax(JumpZ, 250);
	}
	Goto('LongFall');

FastLanded:
	FinishAnim();
	TweenToWaiting(0.15);
	Goto('Done');

Landed:
	if ( !bIsPlayer ) //bots act like players
		Acceleration = vect(0,0,0);
	FinishAnim();
	TweenToWaiting(0.2);
	if ( !bIsPlayer )
		Sleep(0.08);

Done:
	bUpAndOut = false;
	if (HasNextState())
		GotoNextState();
	else
		GotoState('Wandering');

Splash:
	bUpAndOut = false;
	FinishAnim();
	if (HasNextState())
		GotoNextState();
	else
		GotoState('Wandering');

Begin:
	if (Enemy == None)
		Disable('EnemyNotVisible');
	else
	{
		Disable('HearNoise');
		Disable('SeePlayer');
	}
	if (bUpAndOut) //water jump
	{
		if ( !bIsPlayer ) 
		{
			DesiredRotation = Rotation;
			DesiredRotation.Pitch = 0;
			Velocity.Z = 440; 
		}
	}
	else
	{	
		if (Region.Zone.bWaterZone)
		{
			SetPhysics(PHYS_Swimming);
			GotoNextState();
		}	
		if ( !bJumpOffPawn )
			AdjustJump();
		else
			bJumpOffPawn = false;

PlayFall:
		PlayFalling();
		FinishAnim();
	}
	
	if (Physics != PHYS_Falling)
		Goto('Done');
	Sleep(2.0);
	Goto('LongFall');

Ducking:
		
}

//------------
//Debug functions added to prevent the Cant Find Function FireIfClearShot crash
//------------
state Paralyzed
{
	ignores bump, frob, reacttoinjury;
	function BeginState()
	{
		StandUp();
		BlockReactions(true);
		bCanConverse = False;
		SeekPawn = None;
		EnableCheckDestLoc(false);
	}
	function bool FireIfClearShot()
    {
		Log("This shouldn't be called by this actor! ("$Self$")");
		return false;
    }
	function EndState()
	{
		ResetReactions();
		bCanConverse = True;
	}

Begin:
	Acceleration=vect(0,0,0);
	PlayAnimPivot('Still');
}

state Standing
{
	ignores EnemyNotVisible;

	function SetFall()
	{
		StartFalling('Standing', 'ContinueStand');
	}

	function AnimEnd()
	{
		PlayWaiting();
	}
	function bool FireIfClearShot()
    {
		Log("This shouldn't be called by this actor! ("$Self$")");
		return false;
    }
	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Global.HitWall(HitNormal, Wall);
		CheckOpenDoor(HitNormal, Wall);
	}

	function Tick(float deltaSeconds)
	{
		animTimer[1] += deltaSeconds;
		Global.Tick(deltaSeconds);
	}

	function BeginState()
	{
		StandUp();
		SetEnemy(None, EnemyLastSeen, true);
		Disable('AnimEnd');
		bCanJump = false;

		bStasis = False;

		SetupWeapon(false);
		SetDistress(false);
		SeekPawn = None;
		EnableCheckDestLoc(false);
	}

	function EndState()
	{
		EnableCheckDestLoc(false);
		bAcceptBump = True;

		if (JumpZ > 0)
			bCanJump = true;
		bStasis = True;

		StopBlendAnims();
	}

Begin:
	WaitForLanding();
	if (!bUseHome)
		Goto('StartStand');

MoveToBase:
	if (!IsPointInCylinder(self, HomeLoc, 16-CollisionRadius))
	{
		EnableCheckDestLoc(true);
		while (true)
		{
			if (PointReachable(HomeLoc))
			{
				if (ShouldPlayWalk(HomeLoc))
					PlayWalking();
				MoveTo(HomeLoc, GetWalkingSpeed());
				CheckDestLoc(HomeLoc);
				break;
			}
			else
			{
				MoveTarget = FindPathTo(HomeLoc);
				if (MoveTarget != None)
				{
					if (ShouldPlayWalk(MoveTarget.Location))
						PlayWalking();
					MoveToward(MoveTarget, GetWalkingSpeed());
					CheckDestLoc(MoveTarget.Location, true);
				}
				else
					break;
			}
		}
		EnableCheckDestLoc(false);
	}
	TurnTo(Location+HomeRot);

StartStand:
	Acceleration=vect(0,0,0);
	Goto('Stand');

ContinueFromDoor:
	Goto('MoveToBase');

Stand:
ContinueStand:
	// nil
	bStasis = True;

	PlayWaiting();
	if (!bPlayIdle)
		Goto('DoNothing');
	Sleep(FRand()*14+8);

Fidget:
	if (FRand() < 0.5)
	{
		PlayIdle();
		FinishAnim();
	}
	else
	{
		if (FRand() > 0.5)
		{
			PlayTurnHead(LOOK_Up, 1.0, 1.0);
			Sleep(2.0);
			PlayTurnHead(LOOK_Forward, 1.0, 1.0);
			Sleep(0.5);
		}
		else if (FRand() > 0.5)
		{
			PlayTurnHead(LOOK_Left, 1.0, 1.0);
			Sleep(1.5);
			PlayTurnHead(LOOK_Forward, 1.0, 1.0);
			Sleep(0.9);
			PlayTurnHead(LOOK_Right, 1.0, 1.0);
			Sleep(1.2);
			PlayTurnHead(LOOK_Forward, 1.0, 1.0);
			Sleep(0.5);
		}
		else
		{
			PlayTurnHead(LOOK_Right, 1.0, 1.0);
			Sleep(1.5);
			PlayTurnHead(LOOK_Forward, 1.0, 1.0);
			Sleep(0.9);
			PlayTurnHead(LOOK_Left, 1.0, 1.0);
			Sleep(1.2);
			PlayTurnHead(LOOK_Forward, 1.0, 1.0);
			Sleep(0.5);
		}
	}
	if (FRand() < 0.3)
		PlayIdleSound();
	Goto('Stand');

DoNothing:
	// nil
}

state Idle
{
	ignores bump, frob, reacttoinjury;
	function BeginState()
	{
		StandUp();
		BlockReactions(true);
		bCanConverse = False;
		SeekPawn = None;
		EnableCheckDestLoc(false);
	}
	function bool FireIfClearShot()
    {
		Log("This shouldn't be called by this actor! ("$Self$")");
		return false;
    }
	function EndState()
	{
		ResetReactions();
		bCanConverse = True;
	}

Begin:
	Acceleration=vect(0,0,0);
	DesiredRotation=Rotation;
	PlayAnimPivot('Still');

Idle:
}

state Dancing
{
	ignores EnemyNotVisible;
	function bool FireIfClearShot()
    {
		Log("This shouldn't be called by this actor! ("$Self$")");
		return false;
    }
    
	function SetFall()
	{
		StartFalling('Dancing', 'ContinueDance');
	}

	function AnimEnd()
	{
		PlayDancing();
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Global.HitWall(HitNormal, Wall);
		CheckOpenDoor(HitNormal, Wall);
	}

	function BeginState()
	{
		if (bSitting && !bDancing)
			StandUp();
		SetEnemy(None, EnemyLastSeen, true);
		Disable('AnimEnd');
		bCanJump = false;

		bStasis = False;

		SetupWeapon(false);
		SetDistress(false);
		SeekPawn = None;
		EnableCheckDestLoc(false);
	}

	function EndState()
	{
		EnableCheckDestLoc(false);
		bAcceptBump = True;

		if (JumpZ > 0)
			bCanJump = true;
		bStasis = True;

		StopBlendAnims();
	}

Begin:
	WaitForLanding();
	if (bDancing)
	{
		if (bUseHome)
			TurnTo(Location+HomeRot);
		Goto('StartDance');
	}
	if (!bUseHome)
		Goto('StartDance');

MoveToBase:
	if (!IsPointInCylinder(self, HomeLoc, 16-CollisionRadius))
	{
		EnableCheckDestLoc(true);
		while (true)
		{
			if (PointReachable(HomeLoc))
			{
				if (ShouldPlayWalk(HomeLoc))
					PlayWalking();
				MoveTo(HomeLoc, GetWalkingSpeed());
				CheckDestLoc(HomeLoc);
				break;
			}
			else
			{
				MoveTarget = FindPathTo(HomeLoc);
				if (MoveTarget != None)
				{
					if (ShouldPlayWalk(MoveTarget.Location))
						PlayWalking();
					MoveToward(MoveTarget, GetWalkingSpeed());
					CheckDestLoc(MoveTarget.Location, true);
				}
				else
					break;
			}
		}
		EnableCheckDestLoc(false);
	}
	TurnTo(Location+HomeRot);

StartDance:
	Acceleration=vect(0,0,0);
	Goto('Dance');

ContinueFromDoor:
	Goto('MoveToBase');

Dance:
ContinueDance:
	// nil
	bDancing = True;
	PlayDancing();
	bStasis = True;
	if (!bHokeyPokey)
		Goto('DoNothing');

Spin:
	Sleep(FRand()*5+5);
	useRot = DesiredRotation;
	if (FRand() > 0.5)
	{
		TurnTo(Location+1000*vector(useRot+rot(0,16384,0)));
		TurnTo(Location+1000*vector(useRot+rot(0,32768,0)));
		TurnTo(Location+1000*vector(useRot+rot(0,49152,0)));
	}
	else
	{
		TurnTo(Location+1000*vector(useRot+rot(0,49152,0)));
		TurnTo(Location+1000*vector(useRot+rot(0,32768,0)));
		TurnTo(Location+1000*vector(useRot+rot(0,16384,0)));
	}
	TurnTo(Location+1000*vector(useRot));
	Goto('Spin');

DoNothing:
	// nil
}

state Sitting
{
	ignores EnemyNotVisible;

	function SetFall()
	{
		StartFalling('Sitting', 'ContinueSit');
	}

	function AnimEnd()
	{
		PlayWaiting();
	}
	function bool FireIfClearShot()
    {
		Log("This shouldn't be called by this actor! ("$Self$")");
		return false;
    }
    
	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if (!bAcceptBump)
			NextDirection = TURNING_None;
		Global.HitWall(HitNormal, Wall);
		CheckOpenDoor(HitNormal, Wall);
	}

	function bool HandleTurn(Actor Other)
	{
		if (Other == SeatActor)
			return true;
		else
			return Global.HandleTurn(Other);
	}

	function Bump(actor bumper)
	{
		// If we hit our chair, move to the right place
		if ((bumper == SeatActor) && bAcceptBump)
		{
			bAcceptBump = false;
			GotoState('Sitting', 'CircleToFront');
		}

		// Handle conversations, if need be
		else
			Global.Bump(bumper);
	}

	function Tick(float deltaSeconds)
	{
		local vector endPos;
		local vector newPos;
		local float  delta;

		Global.Tick(deltaSeconds);

		if (bSitInterpolation && (SeatActor != None))
		{
			endPos = SitPosition(SeatActor, SeatSlot);
			if ((deltaSeconds < remainingSitTime) && (remainingSitTime > 0))
			{
				delta = deltaSeconds/remainingSitTime;
				newPos = (endPos-Location)*delta + Location;
				remainingSitTime -= deltaSeconds;
			}
			else
			{
				remainingSitTime = 0;
				bSitInterpolation = false;
				newPos = endPos;
				Acceleration = vect(0,0,0);
				Velocity = vect(0,0,0);
				SetBase(SeatActor);
				bSitting = true;
			}
			SetLocation(newPos);
			DesiredRotation = SeatActor.Rotation+Rot(0, -16384, 0);
		}
	}

	function Vector SitPosition(Seat seatActor, int slot)
	{
		local float newAssHeight;

		newAssHeight = GetDefaultCollisionHeight() + BaseAssHeight;
		newAssHeight = -(CollisionHeight - newAssHeight);

		return ((seatActor.sitPoint[slot]>>seatActor.Rotation)+seatActor.Location+(vect(0,0,-1)*newAssHeight));
	}

	function vector GetDestinationPosition(Seat seatActor, optional float extraDist)
	{
		local Rotator seatRot;
		local Vector  destPos;

		if (seatActor == None)
			return (Location);

		seatRot = seatActor.Rotation + Rot(0, -16384, 0);
		seatRot.Pitch = 0;
		destPos = seatActor.Location;
		destPos += vect(0,0,1)*(CollisionHeight-seatActor.CollisionHeight);
		destPos += Vector(seatRot)*(seatActor.CollisionRadius+CollisionRadius+extraDist);

		return (destPos);
	}

	function bool IsIntersectingSeat()
	{
		local bool   bIntersect;
		local vector testVector;

		bIntersect = false;
		if (SeatActor != None)
			bIntersect = IsOverlapping(SeatActor);

		return (bIntersect);
	}

	function int FindBestSlot(Seat seatActor, out float slotDist)
	{
		local int   bestSlot;
		local float dist;
		local float bestDist;
		local int   i;

		bestSlot = -1;
		bestDist = 100;
		if (!seatActor.Region.Zone.bWaterZone)
		{
			for (i=0; i<seatActor.numSitPoints; i++)
			{
				if (seatActor.sittingActor[i] == None)
				{
					dist = VSize(SitPosition(seatActor, i) - Location);
					if ((bestSlot < 0) || (bestDist > dist))
					{
						bestDist = dist;
						bestSlot = i;
					}
				}
			}
		}

		slotDist = bestDist;

		return (bestSlot);
	}

	function FindBestSeat()
	{
		local Seat  curSeat;
		local Seat  bestSeat;
		local float curDist;
		local float bestDist;
		local int   curSlot;
		local int   bestSlot;
		local bool  bTry;

		if (bUseFirstSeatOnly && bSeatHackUsed)
		{
			bestSeat = SeatHack;  // use the seat hack
			bestSlot = -1;
			if (!IsSeatValid(bestSeat))
				bestSeat = None;
			else
			{
				if (GetNextWaypoint(bestSeat) == None)
					bestSeat = None;
				else
				{
					bestSlot = FindBestSlot(bestSeat, curDist);
					if (bestSlot < 0)
						bestSeat = None;
				}
			}
		}
		else
		{
			bestSeat = Seat(OrderActor);  // try the ordered seat first
			if (bestSeat != None)
			{
				if (!IsSeatValid(OrderActor))
					bestSeat = None;
				else
				{
					if (GetNextWaypoint(bestSeat) == None)
						bestSeat = None;
					else
					{
						bestSlot = FindBestSlot(bestSeat, curDist);
						if (bestSlot < 0)
							bestSeat = None;
					}
				}
			}
			if (bestSeat == None)
			{
				bestDist = 10001;
				bestSlot = -1;
				foreach RadiusActors(Class'Seat', curSeat, 10000)
				{
					if (IsSeatValid(curSeat))
					{
						curSlot = FindBestSlot(curSeat, curDist);
						if (curSlot >= 0)
						{
							if (bestDist > curDist)
							{
								if (GetNextWaypoint(curSeat) != None)
								{
									bestDist = curDist;
									bestSeat = curSeat;
									bestSlot = curSlot;
								}
							}
						}
					}
				}
			}
		}

		if (bestSeat != None)
		{
			bestSeat.sittingActor[bestSlot] = self;
			SeatLocation       = bestSeat.Location;
			bSeatLocationValid = true;
		}
		else
			bSeatLocationValid = false;

		if (bUseFirstSeatOnly && !bSeatHackUsed)
		{
			SeatHack      = bestSeat;
			bSeatHackUsed = true;
		}

		SeatActor = bestSeat;
		SeatSlot  = bestSlot;
	}

	function FollowSeatFallbackOrders()
	{
		FindBestSeat();
		if (IsSeatValid(SeatActor))
			GotoState('Sitting', 'Begin');
		else
			GotoState('Wandering');
	}

	function BeginState()
	{
		SetEnemy(None, EnemyLastSeen, true);
		Disable('AnimEnd');
		bCanJump = false;

		bAcceptBump = True;

		if (SeatActor == None)
			FindBestSeat();

		bSitInterpolation = false;

		bStasis = False;

		SetupWeapon(false);
		SetDistress(false);
		SeekPawn = None;
		EnableCheckDestLoc(true);
	}

	function EndState()
	{
		EnableCheckDestLoc(false);
		if (!bSitting)
			StandUp();

		bAcceptBump = True;

		if (JumpZ > 0)
			bCanJump = true;

		bSitInterpolation = false;

		bStasis = True;
	}

Begin:
	WaitForLanding();
	if (!IsSeatValid(SeatActor))
		FollowSeatFallbackOrders();
	if (!bSitting)
		WaitForLanding();
	else
	{
		TurnTo(Vector(SeatActor.Rotation+Rot(0, -16384, 0))*100+Location);
		Goto('ContinueSitting');
	}

MoveToSeat:
	if (IsIntersectingSeat())
		Goto('MoveToPosition');
	bAcceptBump = true;
	while (true)
	{
		if (!IsSeatValid(SeatActor))
			FollowSeatFallbackOrders();
		destLoc = GetDestinationPosition(SeatActor);
		if (PointReachable(destLoc))
		{
			if (ShouldPlayWalk(destLoc))
				PlayWalking();
			MoveTo(destLoc, GetWalkingSpeed());
			CheckDestLoc(destLoc);

			if (IsPointInCylinder(self, GetDestinationPosition(SeatActor), 16, 16))
			{
				bAcceptBump = false;
				Goto('MoveToPosition');
				break;
			}
		}
		else
		{
			MoveTarget = GetNextWaypoint(SeatActor);
			if (MoveTarget != None)
			{
				if (ShouldPlayWalk(MoveTarget.Location))
					PlayWalking();
				MoveToward(MoveTarget, GetWalkingSpeed());
				CheckDestLoc(MoveTarget.Location, true);
			}
			else
				break;
		}
	}

CircleToFront:
	bAcceptBump = false;
	if (!IsSeatValid(SeatActor))
		FollowSeatFallbackOrders();
	if (ShouldPlayWalk(GetDestinationPosition(SeatActor, 16)))
		PlayWalking();
	MoveTo(GetDestinationPosition(SeatActor, 16), GetWalkingSpeed());

MoveToPosition:
	if (!IsSeatValid(SeatActor))
		FollowSeatFallbackOrders();
	bSitting = true;
	EnableCollision(false);
	Acceleration=vect(0,0,0);

Sit:
	Acceleration=vect(0,0,0);
	Velocity=vect(0,0,0);
	if (!IsSeatValid(SeatActor))
		FollowSeatFallbackOrders();
	remainingSitTime = 0.8;
	PlaySittingDown();
	SetBasedPawnSize(CollisionRadius, GetSitHeight());
	SetPhysics(PHYS_Flying);
	StopStanding();
	bSitInterpolation = true;
	while (bSitInterpolation)
		Sleep(0);
	FinishAnim();
	Goto('ContinueSitting');

ContinueFromDoor:
	Goto('MoveToSeat');

ContinueSitting:
	if (!IsSeatValid(SeatActor))
		FollowSeatFallbackOrders();
	SetBasedPawnSize(CollisionRadius, GetSitHeight());
	SetCollision(Default.bCollideActors, Default.bBlockActors, Default.bBlockPlayers);
	PlaySitting();
	bStasis  = True;
	// nil

}

state Wandering
{
	ignores EnemyNotVisible;

	function SetFall()
	{
		StartFalling('Wandering', 'ContinueWander');
	}
	function bool FireIfClearShot()
    {
		Log("This shouldn't be called by this actor! ("$Self$")");
		return false;
    }
	function Bump(actor bumper)
	{
		if (bAcceptBump)
		{
			// If we get bumped by another actor while we wait, start wandering again
			bAcceptBump = False;
			Disable('AnimEnd');
			GotoState('Wandering', 'Wander');
		}

		// Handle conversations, if need be
		Global.Bump(bumper);
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Global.HitWall(HitNormal, Wall);
		CheckOpenDoor(HitNormal, Wall);
	}

	function bool GoHome()
	{
		if (bUseHome && !IsNearHome(Location))
		{
			destLoc   = HomeLoc;
			destPoint = None;
			if (PointReachable(destLoc))
				return true;
			else
			{
				MoveTarget = FindPathTo(destLoc);
				if (MoveTarget != None)
					return true;
				else
					return false;
			}
		}
		else
			return false;
	}

	function PickDestination()
	{
		local WanderCandidates candidates[5];
		local int              candidateCount;
		local int              maxCandidates;
		local int              maxLastPoints;

		local WanderPoint curPoint;
		local Actor       wayPoint;
		local int         i;
		local int         openSlot;
		local float       maxDist;
		local float       dist;
		local float       angle;
		local float       magnitude;
		local int         iterations;
		local bool        bSuccess;
		local Rotator     rot;

		maxCandidates = 4;  // must be <= size of candidates[] array
		maxLastPoints = 2;  // must be <= size of lastPoints[] array

		for (i=0; i<maxCandidates; i++)
			candidates[i].dist = 100000;
		candidateCount = 0;

		// A certain percentage of the time, we want to angle off to a random direction...
		if ((RandomWandering < 1) && (FRand() > RandomWandering))
		{
			// Fill the candidate table
			foreach RadiusActors(Class'WanderPoint', curPoint, 3000*wanderlust+1000)  // 1000-4000
			{
				// Make sure we haven't been here recently
				for (i=0; i<maxLastPoints; i++)
				{
					if (lastPoints[i] == curPoint)
						break;
				}

				if (i >= maxLastPoints)
				{
					// Can we get there from here?
					wayPoint = GetNextWaypoint(curPoint);

					if ((wayPoint != None) && !IsNearHome(curPoint.Location))
						wayPoint = None;

					// Yep
					if (wayPoint != None)
					{
						// Find an empty slot for this candidate
						openSlot = -1;
						dist     = VSize(curPoint.location - location);
						maxDist  = dist;

						// This candidate will only replace more distant candidates...
						for (i=0; i<maxCandidates; i++)
						{
							if (maxDist < candidates[i].dist)
							{
								maxDist  = candidates[i].dist;
								openSlot = i;
							}
						}

						// Put the candidate in the (unsorted) list
						if (openSlot >= 0)
						{
							candidates[openSlot].point    = curPoint;
							candidates[openSlot].waypoint = wayPoint;
							candidates[openSlot].dist     = dist;
							if (candidateCount < maxCandidates)
								candidateCount++;
						}
					}
				}
			}
		}

		// Shift our list of recently visited points
		for (i=maxLastPoints-1; i>0; i--)
			lastPoints[i] = lastPoints[i-1];
		lastPoints[0] = None;

		// Do we have a list of candidates?
		if (candidateCount > 0)
		{
			// Pick a candidate at random
			i = Rand(candidateCount);
			curPoint = candidates[i].point;
			wayPoint = candidates[i].waypoint;
			lastPoints[0] = curPoint;
			MoveTarget    = wayPoint;
			destPoint     = curPoint;
		}

		// No candidates -- find a random place to go
		else
		{
			MoveTarget = None;
			destPoint  = None;
			iterations = 6;  // try up to 6 different directions
			while (iterations > 0)
			{
				// How far will we go?
				magnitude = (wanderlust*400+200) * (FRand()*0.2+0.9); // 200-600, +/-10%

				// Choose our destination, based on whether we have a home base
				if (!bUseHome)
					bSuccess = AIPickRandomDestination(100, magnitude, 0, 0, 0, 0, 1,
					                                   FRand()*0.4+0.35, destLoc);
				else
				{
					if (magnitude > HomeExtent)
						magnitude = HomeExtent*(FRand()*0.2+0.9);
					rot = Rotator(HomeLoc-Location);
					bSuccess = AIPickRandomDestination(50, magnitude, rot.Yaw, 0.25, rot.Pitch, 0.25, 1,
					                                   FRand()*0.4+0.35, destLoc);
				}

				// Success?  Break out of the iteration loop
				if (bSuccess)
					if (IsNearHome(destLoc))
						break;

				// We failed -- try again
				iterations--;
			}

			// If we got a destination, go there
			if (iterations <= 0)
				destLoc = Location;
		}
	}

	function AnimEnd()
	{
		PlayWaiting();
	}

	function BeginState()
	{
		StandUp();
		SetEnemy(None, EnemyLastSeen, true);
		Disable('AnimEnd');
		bCanJump = false;
		SetupWeapon(false);
		SetDistress(false);
		SeekPawn = None;
		EnableCheckDestLoc(false);
	}

	function EndState()
	{
		local int i;
		bAcceptBump = True;

		EnableCheckDestLoc(false);

		// Clear out our list of last visited points
		for (i=0; i<ArrayCount(lastPoints); i++)
			lastPoints[i] = None;

		if (JumpZ > 0)
			bCanJump = true;
	}

Begin:
	destPoint = None;

GoHome:
	bAcceptBump = false;
	WaitForLanding();
	if (!GoHome())
		Goto('WanderInternal');

MoveHome:
	EnableCheckDestLoc(true);
	while (true)
	{
		if (PointReachable(destLoc))
		{
			if (ShouldPlayWalk(destLoc))
				PlayWalking();
			MoveTo(destLoc, GetWalkingSpeed());
			CheckDestLoc(destLoc);
			break;
		}
		else
		{
			MoveTarget = FindPathTo(destLoc);
			if (MoveTarget != None)
			{
				if (ShouldPlayWalk(MoveTarget.Location))
					PlayWalking();
				MoveToward(MoveTarget, GetWalkingSpeed());
				CheckDestLoc(MoveTarget.Location, true);
			}
			else
				break;
		}
	}
	EnableCheckDestLoc(false);
	Goto('Pausing');

Wander:
	WaitForLanding();
WanderInternal:
	PickDestination();

Moving:
	// Move from pathnode to pathnode until we get where we're going
	// (ooooold code -- no longer used)
	if (destPoint != None)
	{
		if (ShouldPlayWalk(MoveTarget.Location))
			PlayWalking();
		MoveToward(MoveTarget, GetWalkingSpeed());
		while ((MoveTarget != None) && (MoveTarget != destPoint))
		{
			MoveTarget = FindPathToward(destPoint);
			if (MoveTarget != None)
			{
				if (ShouldPlayWalk(MoveTarget.Location))
					PlayWalking();
				MoveToward(MoveTarget, GetWalkingSpeed());
			}
		}
	}
	else if (destLoc != Location)
	{
		if (ShouldPlayWalk(destLoc))
			PlayWalking();
		MoveTo(destLoc, GetWalkingSpeed());
	}
	else
		Sleep(0.5);

Pausing:
	Acceleration = vect(0, 0, 0);

	// Turn in the direction dictated by the WanderPoint, if there is one
	sleepTime = 6.0;
	if (WanderPoint(destPoint) != None)
	{
		if (WanderPoint(destPoint).gazeItem != None)
		{
			TurnToward(WanderPoint(destPoint).gazeItem);
			sleepTime = WanderPoint(destPoint).gazeDuration;
		}
		else if (WanderPoint(destPoint).gazeDirection != vect(0, 0, 0))
			TurnTo(Location + WanderPoint(destPoint).gazeDirection);
	}
	Enable('AnimEnd');
	TweenToWaiting(0.2);
	bAcceptBump = True;
	PlayScanningSound();
	sleepTime *= (-0.9*restlessness) + 1;
	Sleep(sleepTime);
	Disable('AnimEnd');
	bAcceptBump = False;
	FinishAnim();
	Goto('Wander');

ContinueWander:
ContinueFromDoor:
	FinishAnim();
	PlayWalking();
	Goto('Wander');
}

State Patrolling
{
	function SetFall()
	{
		StartFalling('Patrolling', 'ContinuePatrol');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Global.HitWall(HitNormal, Wall);
		CheckOpenDoor(HitNormal, Wall);
	}
	
	function AnimEnd()
	{
		PlayWaiting();
	}
	function bool FireIfClearShot()
    {
		Log("This shouldn't be called by this actor! ("$Self$")");
		return false;
    }
	function PatrolPoint PickStartPoint()
	{
		local NavigationPoint nav;
		local PatrolPoint     curNav;
		local float           curDist;
		local PatrolPoint     closestNav;
		local float           closestDist;

		nav = Level.NavigationPointList;
		while (nav != None)
		{
			nav.visitedWeight = 0;
			nav = nav.nextNavigationPoint;
		}

		closestNav  = None;
		closestDist = 100000;
		nav = Level.NavigationPointList;
		while (nav != None)
		{
			curNav = PatrolPoint(nav);
			if ((curNav != None) && (curNav.Tag == OrderTag))
			{
				while (curNav != None)
				{
					if (curNav.visitedWeight != 0)  // been here before
						break;
					curDist = VSize(Location - curNav.Location);
					if ((closestNav == None) || (closestDist > curDist))
					{
						closestNav  = curNav;
						closestDist = curDist;
					}
					curNav.visitedWeight = 1;
					curNav = curNav.NextPatrolPoint;
				}
			}
			nav = nav.nextNavigationPoint;
		}

		return (closestNav);
	}

	function PickDestination()
	{
		if (PatrolPoint(destPoint) != None)
			destPoint = PatrolPoint(destPoint).NextPatrolPoint;
		else
			destPoint = PickStartPoint();
		if (destPoint == None)  // can't go anywhere...
			GotoState('Standing');
	}

	function BeginState()
	{
		StandUp();
		SetEnemy(None, EnemyLastSeen, true);
		Disable('AnimEnd');
		SetupWeapon(false);
		SetDistress(false);
		bStasis = false;
		SeekPawn = None;
		EnableCheckDestLoc(false);
	}

	function EndState()
	{
		EnableCheckDestLoc(false);
		Enable('AnimEnd');
		bStasis = true;
	}

Begin:
	destPoint = None;

Patrol:
	//Disable('Bump');
	WaitForLanding();
	PickDestination();

Moving:
	// Move from pathnode to pathnode until we get where we're going
	if (destPoint != None)
	{
		if (!IsPointInCylinder(self, destPoint.Location, 16-CollisionRadius))
		{
			EnableCheckDestLoc(true);
			MoveTarget = FindPathToward(destPoint);
			while (MoveTarget != None)
			{
				if (ShouldPlayWalk(MoveTarget.Location))
					PlayWalking();
				MoveToward(MoveTarget, GetWalkingSpeed());
				CheckDestLoc(MoveTarget.Location, true);
				if (MoveTarget == destPoint)
					break;
				MoveTarget = FindPathToward(destPoint);
			}
			EnableCheckDestLoc(false);
		}
	}
	else
		Goto('Patrol');

Pausing:
	if (!bAlwaysPatrol)
		bStasis = true;
	Acceleration = vect(0, 0, 0);

	// Turn in the direction dictated by the WanderPoint, or a random direction
	if (PatrolPoint(destPoint) != None)
	{
		if ((PatrolPoint(destPoint).pausetime > 0) || (PatrolPoint(destPoint).NextPatrolPoint == None))
		{
			if (ShouldPlayTurn(Location + PatrolPoint(destPoint).lookdir))
				PlayTurning();
			TurnTo(Location + PatrolPoint(destPoint).lookdir);
			Enable('AnimEnd');
			TweenToWaiting(0.2);
			PlayScanningSound();
			//Enable('Bump');
			sleepTime = PatrolPoint(destPoint).pausetime * ((-0.9*restlessness) + 1);
			Sleep(sleepTime);
			Disable('AnimEnd');
			//Disable('Bump');
			FinishAnim();
		}
	}
	Goto('Patrol');

ContinuePatrol:
ContinueFromDoor:
	FinishAnim();
	PlayWalking();
	Goto('Moving');

}

State Seeking
{
		ignores bump, frob;
	function SetFall()
	{
		StartFalling('Seeking', 'ContinueSeek');
	}
	function bool FireIfClearShot()
    {
		Log("This shouldn't be called by this actor! ("$Self$")");
		return false;
    }
	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Global.HitWall(HitNormal, Wall);
		CheckOpenDoor(HitNormal, Wall);
	}

	function bool GetNextLocation(out vector nextLoc)
	{
		local float   dist;
		local rotator rotation;
		local bool    bDone;
		local float   seekDistance;
		local Actor   hitActor;
		local vector  HitLocation, HitNormal;
		local vector  diffVect;
		local bool    bLOS;

		if (bSeekLocation)
		{
			if (SeekType == SEEKTYPE_Guess)
				seekDistance = (200+FClamp(GroundSpeed*EnemyLastSeen*0.5, 0, 1000));
			else
				seekDistance = 300;
		}
		else
			seekDistance = 60;

		dist  = VSize(Location-destLoc);
		bDone = false;
		bLOS  = false;

		if (dist < seekDistance)
		{
			bLOS = true;
			foreach TraceVisibleActors(Class'Actor', hitActor, hitLocation, hitNormal,
			                           destLoc, Location+vect(0,0,1)*BaseEyeHeight)
			{
				if (hitActor != self)
				{
					if (hitActor == Level)
						bLOS = false;
					else if (IsPointInCylinder(hitActor, destLoc, 16, 16))
						break;
					else if (hitActor.bBlockSight && !hitActor.bHidden)
						bLOS = false;
				}
				if (!bLOS)
					break;
			}
		}

		if (!bLOS)
		{
			if (PointReachable(destLoc))
			{
				rotation = Rotator(destLoc - Location);
				if (seekDistance == 0)
					nextLoc = destLoc;
				else if (!AIDirectionReachable(destLoc, rotation.Yaw, rotation.Pitch, 0, seekDistance, nextLoc))
					bDone = true;
				if (!bDone && bDefendHome && !IsNearHome(nextLoc))
					bDone = true;
				if (!bDone)  // hack, because Unreal's movement code SUCKS
				{
					diffVect = nextLoc - Location;
					if (Physics == PHYS_Walking)
						diffVect *= vect(1,1,0);
					if (VSize(diffVect) < 20)
						bDone = true;
					else if (IsPointInCylinder(self, nextLoc, 10, 10))
						bDone = true;
				}
			}
			else
			{
				MoveTarget = FindPathTo(destLoc);
				if (MoveTarget == None)
					bDone = true;
				else if (bDefendHome && !IsNearHome(MoveTarget.Location))
					bDone = true;
				else
					nextLoc = MoveTarget.Location;
			}
		}
		else
			bDone = true;

		return (!bDone);
	}

	function bool PickDestination()
	{
		local bool bValid;

		bValid = false;
		if (/*(EnemyLastSeen <= 25.0) &&*/ (SeekLevel > 0))
		{
			if (bSeekLocation)
			{
				bValid  = true;
				destLoc = LastSeenPos;
			}
			else
			{
				bValid = AIPickRandomDestination(130, 250, 0, 0, 0, 0, 2, 1.0, destLoc);
				if (!bValid)
				{
					bValid  = true;
					destLoc = Location + VRand()*50;
				}
				else
					destLoc += vect(0,0,1)*BaseEyeHeight;
			}
		}

		return (bValid);
	}

	function NavigationPoint GetOvershootDestination(float randomness, optional float focus)
	{
		local NavigationPoint navPoint, bestPoint;
		local float           distance;
		local float           score, bestScore;
		local int             yaw;
		local rotator         rot;
		local float           yawCutoff;

		if (focus <= 0)
			focus = 0.6;

		yawCutoff = int(32768*focus);
		bestPoint = None;
		bestScore = 0;

		foreach ReachablePathnodes(Class'NavigationPoint', navPoint, None, distance)
		{
			if (distance < 1)
				distance = 1;
			rot = Rotator(navPoint.Location-Location);
			yaw = rot.Yaw + (16384*randomness);
			yaw = (yaw-Rotation.Yaw) & 0xFFFF;
			if (yaw > 32767)
				yaw  -= 65536;
			yaw = abs(yaw);
			if (yaw <= yawCutoff)
			{
				score = yaw/distance;
				if ((bestPoint == None) || (score < bestScore))
				{
					bestPoint = navPoint;
					bestScore = score;
				}
			}
		}

		return bestPoint;
	}

	function Tick(float deltaSeconds)
	{
		animTimer[1] += deltaSeconds;
		Global.Tick(deltaSeconds);
		UpdateActorVisibility(Enemy, deltaSeconds, 1.0, true);
	}

	/*function HandleLoudNoise(Name event, EAIEventState state, XAIParams params)
	{
		local Actor bestActor;
		local Pawn  instigator;

		if (state == EAISTATE_Begin || state == EAISTATE_Pulse)
		{
			bestActor = params.bestActor;
			if ((bestActor != None) && (EnemyLastSeen > 2.0))
			{
				instigator = Pawn(bestActor);
				if (instigator == None)
					instigator = bestActor.Instigator;
				if (instigator != None)
				{
					if (IsValidEnemy(instigator))
					{
						SetSeekLocation(instigator, bestActor.Location, SEEKTYPE_Sound);
						destLoc = LastSeenPos;
						if (bInterruptSeek)
							GotoState('Seeking', 'GoToLocation');
					}
				}
			}
		}
	}*/

	function HandleSighting(Pawn pawnSighted)
	{
		if ((EnemyLastSeen > 2.0) && IsValidEnemy(pawnSighted))
		{
			SetSeekLocation(pawnSighted, pawnSighted.Location, SEEKTYPE_Sight);
			destLoc = LastSeenPos;
			if (bInterruptSeek)
				GotoState('Seeking', 'GoToLocation');
		}
	}

	function BeginState()
	{
		StandUp();
		Disable('AnimEnd');
		destLoc = LastSeenPos;
		SetReactions(true, true, false, true, true, true, true, true, true, false, true, true);
		bCanConverse = False;
		bStasis = False;
		SetupWeapon(true);
		SetDistress(false);
		bInterruptSeek = false;
		EnableCheckDestLoc(false);
	}

	function EndState()
	{
		EnableCheckDestLoc(false);
		Enable('AnimEnd');
		ResetReactions();
		bCanConverse = True;
		bStasis = True;
		StopBlendAnims();
		SeekLevel = 0;
	}

Begin:
	WaitForLanding();
	PlayWaiting();
	if ((Weapon != None) && bKeepWeaponDrawn && (Weapon.CockingSound != None) && !bSeekPostCombat)
		PlaySound(Weapon.CockingSound, SLOT_None,,, 1024);
	Acceleration = vect(0,0,0);
	if (!PickDestination())
		Goto('DoneSeek');

GoToLocation:
	bInterruptSeek = true;
	Acceleration = vect(0,0,0);

	if ((DeusExWeapon(Weapon) != None) && DeusExWeapon(Weapon).CanReload() && !Weapon.IsInState('Reload'))
		DeusExWeapon(Weapon).ReloadAmmo();

	if (bSeekPostCombat)
		PlayPostAttackSearchingSound();
	else if (SeekType == SEEKTYPE_Sound)
		PlayPreAttackSearchingSound();
	else if (SeekType == SEEKTYPE_Sight)
	{
		if (ReactionLevel > 0.5)
			PlayPreAttackSightingSound();
	}
	else if ((SeekType == SEEKTYPE_Carcass) && bSeekLocation)
		PlayCarcassSound();

	StopBlendAnims();

	if ((SeekType == SEEKTYPE_Sight) && bSeekLocation)
		Goto('TurnToLocation');

	EnableCheckDestLoc(true);
	while (GetNextLocation(useLoc))
	{
		if (ShouldPlayWalk(useLoc))
			PlayRunning();
		MoveTo(useLoc, MaxDesiredSpeed);
		CheckDestLoc(useLoc);
	}
	EnableCheckDestLoc(false);

	if ((SeekType == SEEKTYPE_Guess) && bSeekLocation)
	{
		MoveTarget = GetOvershootDestination(0.5);
		if (MoveTarget != None)
		{
			if (ShouldPlayWalk(MoveTarget.Location))
				PlayRunning();
			MoveToward(MoveTarget, MaxDesiredSpeed);
		}

		if (AIPickRandomDestination(CollisionRadius*2, 200+FRand()*200, Rotation.Yaw, 0.75, Rotation.Pitch, 0.75, 2,
		                            0.4, useLoc))
		{
			if (ShouldPlayWalk(useLoc))
				PlayRunning();
			MoveTo(useLoc, MaxDesiredSpeed);
		}
	}

TurnToLocation:
	Acceleration = vect(0,0,0);
	PlayTurning();
	if ((SeekType == SEEKTYPE_Guess) && bSeekLocation)
		destLoc = Location + Vector(Rotation+(rot(0,1,0)*(Rand(16384)-8192)))*1000;
	if (bCanTurnHead)
	{
		Sleep(0);  // needed to turn head
		LookAtVector(destLoc, true, false, true);
		TurnTo(Vector(DesiredRotation)*1000+Location);
	}
	else
		TurnTo(destLoc);
	bSeekLocation = false;
	bInterruptSeek = false;

	PlayWaiting();
	Sleep(FRand()*1.5+3.0);

LookAround:
	if (bCanTurnHead)
	{
		if (FRand() < 0.5)
		{
			if (!bSeekLocation)
			{
				PlayTurnHead(LOOK_Left, 1.0, 1.0);
				Sleep(1.0);
			}
			if (!bSeekLocation)
			{
				PlayTurnHead(LOOK_Forward, 1.0, 1.0);
				Sleep(0.5);
			}
			if (!bSeekLocation)
			{
				PlayTurnHead(LOOK_Right, 1.0, 1.0);
				Sleep(1.0);
			}
		}
		else
		{
			if (!bSeekLocation)
			{
				PlayTurnHead(LOOK_Right, 1.0, 1.0);
				Sleep(1.0);
			}
			if (!bSeekLocation)
			{
				PlayTurnHead(LOOK_Forward, 1.0, 1.0);
				Sleep(0.5);
			}
			if (!bSeekLocation)
			{
				PlayTurnHead(LOOK_Left, 1.0, 1.0);
				Sleep(1.0);
			}
		}
		PlayTurnHead(LOOK_Forward, 1.0, 1.0);
		Sleep(0.5);
		StopBlendAnims();
	}
	else
	{
		if (!bSeekLocation)
			Sleep(1.0);
	}

FindAnotherPlace:
	SeekLevel--;
	if (PickDestination())
		Goto('GoToLocation');

DoneSeek:
	if (bSeekPostCombat)
		PlayTargetLostSound();
	else
		PlaySearchGiveUpSound();
	bSeekPostCombat = false;
	SeekPawn = None;
	if (Orders != 'Seeking')
		FollowOrders();
	else
		GotoState('Wandering');

ContinueSeek:
ContinueFromDoor:
	FinishAnim();
	Goto('FindAnotherPlace');

}

State Fleeing
{
			ignores bump, frob;
	function ReactToInjury(Pawn instigatedBy, Name damageType, EHitLocation hitPos)
	{
		local Name currentState;
		local Pawn oldEnemy;
		local name newLabel;
		local bool bHateThisInjury;
		local bool bFearThisInjury;
		local bool bAttack;

		if ((health > 0) && (bLookingForInjury || bLookingForIndirectInjury))
		{
			currentState = GetStateName();

			bHateThisInjury = ShouldReactToInjuryType(damageType, bHateInjury, bHateIndirectInjury);
			bFearThisInjury = ShouldReactToInjuryType(damageType, bFearInjury, bFearIndirectInjury);

			if (bHateThisInjury)
				IncreaseAgitation(instigatedBy);
			if (bFearThisInjury)
				IncreaseFear(instigatedBy, 2.0);

			oldEnemy = Enemy;

			bAttack = false;
			if (SetEnemy(instigatedBy))
			{
				if (!ShouldFlee())
				{
					SwitchToBestWeapon();
					if (Weapon != None)
						bAttack = true;
				}
			}
			else
				SetEnemy(instigatedBy, , true);

			if (bAttack)
			{
				SetDistressTimer();
				SetNextState('HandlingEnemy');
			}
			else
			{
				SetDistressTimer();
				if (oldEnemy != Enemy)
					newLabel = 'Begin';
				else
					newLabel = 'ContinueFlee';
				SetNextState('Fleeing', newLabel);
			}
			GotoDisabledState(damageType, hitPos);
		}
	}

	function SetFall()
	{
		StartFalling('Fleeing', 'ContinueFlee');
	}

	function FinishFleeing()
	{
		if (bLeaveAfterFleeing)
			GotoState('Wandering');
		else
			FollowOrders();
	}

	function bool InSeat(out vector newLoc)  // hack
	{
		local Seat curSeat;
		local bool bSeat;

		bSeat = false;
		foreach RadiusActors(Class'Seat', curSeat, 200)
		{
			if (IsOverlapping(curSeat))
			{
				bSeat = true;
				newLoc = curSeat.Location + vector(curSeat.Rotation+Rot(0, -16384, 0))*(CollisionRadius+curSeat.CollisionRadius+20);
				break;
			}
		}

		return (bSeat);
	}

	function Tick(float deltaSeconds)
	{
		UpdateActorVisibility(Enemy, deltaSeconds, 1.0, false);
		if (IsValidEnemy(Enemy))
		{
			if (EnemyLastSeen > FearSustainTime)
				FinishFleeing();
		}
		else if (!IsValidEnemy(Enemy, false))
			FinishFleeing();
		else if (!IsFearful())
			FinishFleeing();
		Global.Tick(deltaSeconds);
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Global.HitWall(HitNormal, Wall);
		CheckOpenDoor(HitNormal, Wall);
	}
	
	function AnimEnd()
	{
		PlayWaiting();
	}

	function PickDestination()
	{
		local HidePoint      hidePoint;
		local Actor          waypoint;
		local float          dist;
		local float          score;
		local Vector         vector1, vector2;
		local Rotator        rotator1;
		local float          tmpDist;

		local float          bestDist;
		local float          bestScore;

		local FleeCandidates candidates[5];
		local int            candidateCount;
		local int            maxCandidates;

		local float          maxDist;
		local int            openSlot;
		local float          maxScore;
		local int            i;
		local bool           bReplace;

		local float          angle;
		local float          magnitude;
		local int            iterations;

		local NearbyProjectileList projList;
		local bool                 bSuccess;

		maxCandidates  = 3;  // must be <= size of candidates[] arrays
		maxDist        = 10000;

		// Initialize the list of candidates
		for (i=0; i<maxCandidates; i++)
		{
			candidates[i].score = -1;
			candidates[i].dist  = maxDist+1;
		}
		candidateCount = 0;

		MoveTarget = None;
		destPoint  = None;

		if (bAvoidHarm)
		{
			GetProjectileList(projList, Location);
			if (IsLocationDangerous(projList, Location))
			{
				vector1 = ComputeAwayVector(projList);
				rotator1 = Rotator(vector1);
				if (AIDirectionReachable(Location, rotator1.Yaw, rotator1.Pitch, CollisionRadius+24, VSize(vector1), destLoc))
					return;   // eck -- hack!!!
			}
		}

		if (Enemy != None)
		{
			foreach RadiusActors(Class'HidePoint', hidePoint, maxDist)
			{
				// Can the boogeyman see our hiding spot?
				if (!enemy.LineOfSightTo(hidePoint))
				{
					// More importantly, can we REACH our hiding spot?
					waypoint = GetNextWaypoint(hidePoint);
					if (waypoint != None)
					{
						// How far is it to the hiding place?
						dist = VSize(hidePoint.Location - Location);

						// Determine vectors to the waypoint and our enemy
						vector1 = enemy.Location - Location;
						vector2 = waypoint.Location - Location;

						// Strip out magnitudes from the vectors
						tmpDist = VSize(vector1);
						if (tmpDist > 0)
							vector1 /= tmpDist;
						tmpDist = VSize(vector2);
						if (tmpDist > 0)
							vector2 /= tmpDist;

						// Add them
						vector1 += vector2;

						// Compute a score (a function of angle)
						score = VSize(vector1);
						score = 4-(score*score);

						// Find an empty slot for this candidate
						openSlot  = -1;
						bestScore = score;
						bestDist  = dist;

						for (i=0; i<maxCandidates; i++)
						{
							// Can we replace the candidate in this slot?
							if (bestScore > candidates[i].score)
								bReplace = TRUE;
							else if ((bestScore == candidates[i].score) &&
							         (bestDist < candidates[i].dist))
								bReplace = TRUE;
							else
								bReplace = FALSE;
							if (bReplace)
							{
								bestScore = candidates[i].score;
								bestDist  = candidates[i].dist;
								openSlot = i;
							}
						}

						// We found an open slot -- put our candidate here
						if (openSlot >= 0)
						{
							candidates[openSlot].point    = hidePoint;
							candidates[openSlot].waypoint = waypoint;
							candidates[openSlot].location = waypoint.Location;
							candidates[openSlot].score    = score;
							candidates[openSlot].dist     = dist;
							if (candidateCount < maxCandidates)
								candidateCount++;
						}
					}
				}
			}

			// Any candidates?
			if (candidateCount > 0)
			{
				// Find a random candidate
				// (candidates moving AWAY from the enemy have a higher
				// probability of being chosen than candidates moving
				// TOWARDS the enemy)

				maxScore = 0;
				for (i=0; i<candidateCount; i++)
					maxScore += candidates[i].score;
				score = FRand() * maxScore;
				for (i=0; i<candidateCount; i++)
				{
					score -= candidates[i].score;
					if (score <= 0)
						break;
				}
				destPoint  = candidates[i].point;
				MoveTarget = candidates[i].waypoint;
				destLoc    = candidates[i].location;
			}
			else
			{
				iterations = 4;
				magnitude = 400*(FRand()*0.4+0.8);  // 400, +/-20%
				rotator1 = Rotator(Location-Enemy.Location);
				if (!AIPickRandomDestination(100, magnitude, rotator1.Yaw, 0.6, rotator1.Pitch, 0.6, iterations,
				                             FRand()*0.4+0.35, destLoc))
					destLoc = Location+(VRand()*1200);  // we give up
			}
		}
		else
			destLoc = Location+(VRand()*1200);  // we give up
	}
	function bool FireIfClearShot()
    {
		Log("This shouldn't be called by this actor! ("$Self$")");
		return false;
    }
	function BeginState()
	{
		StandUp();
		Disable('AnimEnd');
		//Disable('Bump');
		BlockReactions();
		if (!bCower)
			bCanConverse = False;
		bStasis = False;
		SetupWeapon(false, true);
		SetDistress(true);
		EnemyReadiness = 1.0;
		//ReactionLevel  = 1.0;
		SeekPawn = None;
		EnableCheckDestLoc(false);
	}

	function EndState()
	{
		EnableCheckDestLoc(false);
		Enable('AnimEnd');
		//Enable('Bump');
		ResetReactions();
		if (!bCower)
			bCanConverse = True;
		bStasis = True;
	}

Begin:
	//EnemyLastSeen = 0;
	destPoint = None;

Surprise:
	if ((1.0-ReactionLevel)*SurprisePeriod < 0.25)
		Goto('Flee');
	Acceleration=vect(0,0,0);
	PlaySurpriseSound();
	PlayWaiting();
	Sleep(FRand()*0.5);
	if (Enemy != None)
		TurnToward(Enemy);
	if (bCower)
		Goto('Flee');
	Sleep(FRand()*0.5+0.5);

Flee:
	if (bLeaveAfterFleeing)
	{
		bTransient = true;
		bDisappear = true;
	}
	if (bCower)
		Goto('Cower');
	WaitForLanding();
	PickDestination();

Moving:
	Sleep(0.0);

	if (enemy == None)
	{
		Acceleration = vect(0,0,0);
		PlayWaiting();
		Sleep(2.0);
		FinishFleeing();
	}

	// Move from pathnode to pathnode until we get where we're going
	if (destPoint != None)
	{
		EnableCheckDestLoc(true);
		while (MoveTarget != None)
		{
			if (ShouldPlayWalk(MoveTarget.Location))
				PlayRunning();
			MoveToward(MoveTarget, MaxDesiredSpeed);
			CheckDestLoc(MoveTarget.Location, true);
			if (enemy.bDetectable && enemy.AICanSee(destPoint, 1.0, false, false, false, true) > 0)
			{
				PickDestination();
				EnableCheckDestLoc(false);
				Goto('Moving');
			}
			if (MoveTarget == destPoint)
				break;
			MoveTarget = FindPathToward(destPoint);
		}
		EnableCheckDestLoc(false);
	}
	else if (PointReachable(destLoc))
	{
		if (ShouldPlayWalk(destLoc))
			PlayRunning();
		MoveTo(destLoc, MaxDesiredSpeed);
		if (enemy.bDetectable && enemy.AICanSee(Self, 1.0, false, false, true, true) > 0)
		{
			PickDestination();
			Goto('Moving');
		}
	}
	else
	{
		PickDestination();
		Goto('Moving');
	}

Pausing:
	Acceleration = vect(0,0,0);

	if (enemy != None)
	{
		if (HidePoint(destPoint) != None)
		{
			if (ShouldPlayTurn(Location + HidePoint(destPoint).faceDirection))
				PlayTurning();
			TurnTo(Location + HidePoint(destPoint).faceDirection);
		}
		Enable('AnimEnd');
		TweenToWaiting(0.2);
		while (AICanSee(enemy, 1.0, false, false, true, true) <= 0)
			Sleep(0.25);
		Disable('AnimEnd');
		FinishAnim();
	}

	Goto('Flee');

Cower:
	if (!InSeat(useLoc))
		Goto('CowerContinue');

	PlayRunning();
	MoveTo(useLoc, MaxDesiredSpeed);

CowerContinue:
	Acceleration = vect(0,0,0);
	PlayCowerBegin();
	FinishAnim();
	PlayCowering();

	// behavior 3 - cower and occasionally make short runs
	while (true)
	{
		Sleep(FRand()*3+6);

		PlayCowerEnd();
		FinishAnim();
		if (AIPickRandomDestination(60, 150, 0, 0, 0, 0,
		                            2, FRand()*0.3+0.6, useLoc))
		{
			if (ShouldPlayWalk(useLoc))
				PlayRunning();
			MoveTo(useLoc, MaxDesiredSpeed);
		}
		PlayCowerBegin();
		FinishAnim();
		PlayCowering();
	}

	/* behavior 2 - cower forever
	// don't stop cowering
	while (true)
		Sleep(1.0);
	*/

	/* behavior 1 - cower only when enemy watching
	if (enemy != None)
	{
		while (AICanSee(enemy, 1.0, false, false, true, true) > 0)
			Sleep(0.25);
	}
	PlayCowerEnd();
	FinishAnim();
	Goto('Pausing');
	*/

ContinueFlee:
ContinueFromDoor:
	FinishAnim();
	PlayRunning();
	if (bCower)
		Goto('Cower');
	else
		Goto('Moving');

}

function bool FireIfClearShot()
{
  local DeusExWeapon dxWeapon;

  dxWeapon = DeusExWeapon(Weapon);


  //bReadyToFire doesn't seem to work right for Scripted Pawns
  // So I set it and execute ReadyToFire() automatically.

  dxWeapon.bReadyToFire=false;
  dxWeapon.ReadyToFire();

  if (dxWeapon != None)
  {
	   if ((dxWeapon.AIFireDelay > 0) && (FireTimer > 0))
			return false;
	   else if (AICanShoot(enemy, true, true, 0.025))
	   {

			//Changed from Fire to ClientFire.
			Weapon.ClientFire(0);
			FireTimer = dxWeapon.AIFireDelay;
			return true;
	   }
	   else
		   return false;

  }
  else
	  return false;
}
    
defaultproperties
{
	SoundBossArmourBreak=Sound'DeusExSounds.Augmentation.CloakDown'
	SoundBossArmourRestore=Sound'DeusExSounds.Augmentation.Cloakup'
     Saymsg="I have nothing to say to you."
     scoreCredits=50
     bAimForHead=True
     RaiseAlarm=RAISEALARM_Never
     NameArticle=""
}
