//=============================================================================
// AlarmUnit.
//=============================================================================
class AlarmUnit2 extends DeusExDecoration;

#exec OBJ LOAD FILE=Ambient
var bool bActive;
var float alarmTimeout;
var DeusExplayer myIns;
var() name AUGroup;
var() string AlarmPanelIdent;
var bool bTimedOut;

var() bool bUseMannequinSecurity;
var() name MannequinTag; 
function Tick(float deltaTime)
{
	Super.Tick(deltaTime);

	Tag = AUGroup;
	
	if (!bActive)
		return;

		// flash the light and texture
		if ((Level.TimeSeconds % 0.5) > 0.25)
		{
			LightType = LT_Steady;
			MultiSkins[1] = Texture'AlarmUnitTex2';
		}
		else
		{
			LightType = LT_None;
			MultiSkins[1] = Texture'PinkMaskTex';
		}
}

function Frob(Actor Frobber, Inventory frobWith)
{
local AlarmUnit2 AU;

	if(!bTimedOut)
	{
		PGTrigger(DeusExPlayer(Frobber));
		if(bActive)
		{
			BroadcastMessage("|P2"$DeusExPlayer(Frobber).PlayerReplicationinfo.PlayerName$" triggered alarm! ("$AUGroup$")");
		}
		else
		{
			BroadcastMessage("|P2"$DeusExPlayer(Frobber).PlayerReplicationinfo.PlayerName$" deactivated alarm! ("$AUGroup$")");
		}
		
		foreach AllActors(class'AlarmUnit2',AU)
		{
			if(AU.Tag == Tag && AU != Self)
			{
				AU.PGTrigger(DeusExPlayer(Frobber));
			}
		}
	}
}

function DoTriggers(playerpawn triginst, bool bOn)
{
	local Actor A;
	//local Mannequin Man;
	//local LivingMannequin LivMan;
	if(Event != '' && Event != 'None')
		foreach AllActors(class'Actor', a)
			if(A.Tag == Event)
				A.Trigger(Self, triginst);
			
	/*if(bOn && bUseMannequinSecurity)
	{
		foreach Allactors(class'Mannequin', Man)
			if(Man.Tag == MannequinTag)
				Man.GiveLife();
	}
	
	if(!bOn && bUseMannequinSecurity)
	{
		foreach AllActors(class'LivingMannequin', LivMan)
			if(LivMan.Tag == MannequinTag)
				LivMan.goToState('Dying');
	}*/
}

function PGTrigger(deusexplayer Inst)
{
	if (!bActive)
	{
		DoTriggers(inst,True);
		bActive = True;
		AmbientSound = Sound'Klaxon4';
		SoundRadius = 64;
		SoundVolume = 128;
		LightType = LT_Steady;
		MultiSkins[1] = Texture'AlarmUnitTex2';
		SetTimer(AlarmTimeout,False);
		myIns = Inst;
		return;
	}
	
	if (bActive)
	{
		DoTriggers(inst,False);
		bActive = False;
		AmbientSound = Default.AmbientSound;
		SoundRadius = 16;
		SoundVolume = 192;
		LightType = LT_None;
		MultiSkins[1] = Texture'PinkMaskTex';
			bTimedOut=True;
			SetTimer(10,False);
		return;
	}
}

function Timer()
{
	if(bTimedOut)
	{
		bTimedOut=False;
	}
	
	if (bActive)
	{
		bActive = False;
		DoTriggers(None, False);
		AmbientSound = Default.AmbientSound;
		SoundRadius = 16;
		SoundVolume = 192;
		LightType = LT_None;
		MultiSkins[1] = Texture'PinkMaskTex';
		BroadcastMessage("Alarm"@AUGroup@"timed out.");
	}
}

defaultproperties
{
    alarmTimeout=60.00
    AUGroup=Default
    bInvincible=True
    ItemName="Alarm Network Panel [X]"
    bPushable=False
    Physics=0
    Mesh=LodMesh'DeusExDeco.AlarmUnit'
    MultiSkins(1)=Texture'DeusExItems.Skins.PinkMaskTex'
    SoundRadius=56
    SoundVolume=192
    AmbientSound=Sound'DeusExSounds.Generic.AlarmUnitHum'
    CollisionRadius=9.72
    CollisionHeight=9.72
    LightBrightness=255
    LightRadius=1
    Mass=10.00
    Buoyancy=5.00
}
