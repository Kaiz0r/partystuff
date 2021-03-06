//=============================================================================
// GuntherHermann.
//=============================================================================
class eGuntherHermann extends DXEnemy;

//
// Damage type table for Gunther Hermann:
//
// Shot			- 100%
// Sabot		- 100%
// Exploded		- 100%
// TearGas		- 10%
// PoisonGas	- 10%
// Poison		- 10%
// HalonGas		- 10%
// Radiation	- 10%
// Shocked		- 10%
// Stunned		- 0%
// KnockedOut   - 0%
// Flamed		- 0%
// Burned		- 0%
// NanoVirus	- 0%
// EMP			- 0%
//

function float ShieldDamage(name damageType)
{
	// handle special damage types
	if ((damageType == 'Flamed') || (damageType == 'Burned') || (damageType == 'Stunned') ||
	    (damageType == 'KnockedOut'))
		return 0.0;
	else if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'HalonGas') ||
			(damageType == 'Radiation') || (damageType == 'Shocked') || (damageType == 'Poison') ||
	        (damageType == 'PoisonEffect'))
		return 0.1;
	else
		return Super.ShieldDamage(damageType);
}
function PlayDying(name damageType, vector hitLoc)
{
}

// ----------------------------------------------------------------------
// SpawnCarcass()
//
// Blow up instead of spawning a carcass
// ----------------------------------------------------------------------

function Carcass SpawnCarcass()
{
	if (bStunned)
		return Super.SpawnCarcass();

	Explode();

	return None;
}

function GotoDisabledState(name damageType, EHitLocation hitPos)
{
	if (!bCollideActors && !bBlockActors && !bBlockPlayers)
		return;
	if (CanShowPain())
		TakeHit(hitPos);
	else
		GotoNextState();
}

//
// special Gunther killswitch animation state
//
state KillswitchActivated
{
	function BeginState()
	{
		StandUp();
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

defaultproperties
{
	AllyClass=class'eMIB'
	tScanning="I sense you there."
	tTargetAcquired="Found you."
	tTargetLost="Target lost."
	tCriticalDamage="Argh!"
	tAreaSecure="Nothing there."
	tBossArmourDown="That wont save you."
	tBossArmourBack="Boss Armour augmentation has been repaired."
	tMedkitUsed="I vanted o-range, all I have is zis medkit!"
	tCallingBackup="Converge on his position!"
		bVoiced=True
		bPlaySound=True
		bHasCloakX=True
     scoreCredits=300
     CarcassType=Class'DeusEx.GuntherHermannCarcass'
     WalkingSpeed=0.350000
     bImportant=True
     CloseCombatMult=0.500000
     InitialAlliances(3)=(AllianceName=eTerrorist,AllianceLevel=-1.000000)
     InitialAlliances(4)=(AllianceName=eJoJoFine,AllianceLevel=-1.000000)
     InitialAlliances(5)=(AllianceName=eTerroristCommander,AllianceLevel=-1.000000)
     InitialAlliances(6)=(AllianceName=ePaulDenton,AllianceLevel=-1.000000)
     InitialInventory(0)=(Inventory=Class'WeaponSawedOffShotgun')
     InitialInventory(1)=(Inventory=Class'AmmoShell',Count=120)
     BurnPeriod=0.000000
     walkAnimMult=0.750000
     GroundSpeed=210.000000
     BaseEyeHeight=44.000000
     Health=400
     HealthHead=600
     HealthTorso=400
     HealthLegLeft=400
     HealthLegRight=400
     HealthArmLeft=400
     HealthArmRight=400
     Texture=Texture'DeusExItems.Skins.BlackMaskTex'
     Mesh=LodMesh'DeusExCharacters.GM_DressShirt_B'
     DrawScale=1.100000
     MultiSkins(0)=Texture'DeusExCharacters.Skins.GuntherHermannTex1'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.PantsTex9'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.GuntherHermannTex0'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.GuntherHermannTex0'
     MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(6)=Texture'DeusExItems.Skins.BlackMaskTex'
     MultiSkins(7)=Texture'DeusExItems.Skins.BlackMaskTex'
     CollisionRadius=24.200001
     CollisionHeight=55.660000
     BindName="GuntherHermann"
     FamiliarName="Gunther Hermann"
     UnfamiliarName="Gunther Hermann"
}
