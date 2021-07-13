//=============================================================================
// Shuriken.
//=============================================================================
class Boner extends DeusExProjectile;

var float	mpDamage;
var int		mpAccurateRange;
var int		mpMaxRange;

// set it's rotation correctly
simulated function Tick(float deltaTime)
{
	local Rotator rot;

	if (bStuck)
		return;

	Super.Tick(deltaTime);

	if (Level.Netmode != NM_DedicatedServer)
	{
		rot = Rotation;
		rot.Roll += 16384;
		rot.Pitch -= 13384;
		SetRotation(rot);
	}
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
	{
		Damage = mpDamage;
		AccurateRange = mpAccurateRange;
		MaxRange = mpMaxRange;
	}
}

auto simulated state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if (bStuck)
			return;

		if ((Other != instigator) && (DeusExProjectile(Other) == None) &&
			(Other != Owner))
		{
			damagee = Other;
			Explode(HitLocation, Normal(HitLocation-damagee.Location));

         // DEUS_EX AMSD Spawn blood server side only
         if (Role == ROLE_Authority)
			{
            if (damagee.IsA('Pawn') && !damagee.IsA('Robot') && bBlood)
               SpawnBlood(HitLocation, Normal(HitLocation-damagee.Location));
			   		if(StickyPayload())
					{
						AttachPayload();
					}
			}
		}
	}
	simulated function HitWall(vector HitNormal, actor Wall)
	{
		if (bStickToWall)
		{
			Velocity = vect(0,0,0);
			Acceleration = vect(0,0,0);
			SetPhysics(PHYS_None);
			bStuck = True;

			// MBCODE: Do this only on server side
			if ( Role == ROLE_Authority )
			{
            if (Level.NetMode != NM_Standalone)
               SetTimer(5.0,False);

				if (Wall.IsA('Mover'))
				{
					SetBase(Wall);
					Wall.TakeDamage(Damage, Pawn(Owner), Wall.Location, MomentumTransfer*Normal(Velocity), damageType);
				}
			}
		}

		if (Wall.IsA('BreakableGlass'))
			bDebris = False;

		SpawnEffects(Location, HitNormal, Wall);
		if(StickyPayload())
		{
			AttachPayload();
		}
		Super.HitWall(HitNormal, Wall);
	}
	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local bool bDestroy;
		local float rad;

      // Reduce damage on nano exploded projectiles
      if ((bAggressiveExploded) && (Level.NetMode != NM_Standalone))
         Damage = Damage/6;

		bDestroy = false;

		if (bExplodes)
		{
         //DEUS_EX AMSD Don't draw effects on dedicated server
         if ((Level.NetMode != NM_DedicatedServer) || (Role < ROLE_Authority))			
            DrawExplosionEffects(HitLocation, HitNormal);

			GotoState('Exploding');
		}
		else
		{
			// Server side only
			if ( Role == ROLE_Authority )
			{
				if ((damagee != None)) // Don't even attempt damage with a tracer
				{
					if ( Level.NetMode != NM_Standalone )
					{
						if ( damagee.IsA('DeusExPlayer') )
							DeusExPlayer(damagee).myProjKiller = Self;
					}
					damagee.TakeDamage(Damage, Pawn(Owner), HitLocation, MomentumTransfer*Normal(Velocity), damageType);
				}
			}
			if (!bStuck)
				bDestroy = true;
		}

		rad = Max(blastRadius*24, 1024);

		// This needs to be outside the simulated call chain
		PlayImpactSound();

      //DEUS_EX AMSD Only do these server side
      if (Role == ROLE_Authority)
      {
         if (ImpactSound != None)
         {
            AISendEvent('LoudNoise', EAITYPE_Audio, 2.0, blastRadius*24);
            if (bExplodes)
               AISendEvent('WeaponFire', EAITYPE_Audio, 2.0, blastRadius*5);
         }
      }
		if (bDestroy)
			Destroy();
	}
	simulated function BeginState()
	{
		local DeusExWeapon W;

		initLoc = Location;
		initDir = vector(Rotation);	
		Velocity = speed*initDir;
		PlaySound(SpawnSound, SLOT_None);
	}
}

function bool StickyPayload()
{
local WeaponBoner WBoner;
	foreach AllActors(class'WeaponBoner',WBoner)
	{
		if(WBoner.Owner == Owner)
		{
			if(WBoner.bStickyPayload)
			{
				return True;
			}
		}
	}
}

function AttachPayload()
{
local BonerPayload BP;
local int Payloads;

	foreach AllActors(class'BonerPayload', BP)
	{
		if(BP.Payloader == DeusExPlayer(Owner))
		{
			Payloads++;
		}
	}
	
	if(Payloads > 10)
	{
		return;
	}
	
BP = Spawn(class'BonerPayload',,,Location);
BP.Payloader = DeusExPlayer(Owner);
}

defaultproperties
{
    mpDamage=65.00
    mpAccurateRange=640
    mpMaxRange=640
    bExplodes=True
    bBlood=True
    blastRadius=64.00
    DamageType=shot
    AccurateRange=640
    maxRange=1280
    bIgnoresNanoDefense=True
    ItemName="Boner"
    ItemArticle="the"
    speed=1000.00
    MaxSpeed=1000.00
    Damage=100.00
    MomentumTransfer=128
    ImpactSound=Sound'DeusExSounds.Generic.BulletHitFlesh'
    Mesh=LodMesh'DeusExDeco.BoneFemur'
    CollisionRadius=12.65
    CollisionHeight=0.80
}
