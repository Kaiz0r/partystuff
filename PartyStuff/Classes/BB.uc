class BB extends DeusExProjectile;

var ParticleGenerator pGen1;
var ParticleGenerator pGen2;

var float mpDamage;
var float mpBlastRadius;

#exec OBJ LOAD FILE=Effects

simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
	local ParticleGenerator gen;

	// create a particle generator shooting out plasma spheres
	gen = Spawn(class'ParticleGenerator',,, HitLocation, Rotator(HitNormal));
	if (gen != None)
	{
      gen.RemoteRole = ROLE_None;
		gen.particleDrawScale = 2.0;
		gen.checkTime = 0.10;
		gen.frequency = 2.0;
		gen.ejectSpeed = 100.0;
		gen.bGravity = True;
		gen.bRandomEject = True;
		gen.particleLifeSpan = 14.00;
		gen.particleTexture = FireTexture'Effects.Laser.LaserSpot2';
		gen.LifeSpan = 18.5;
	}
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

   if ((Level.NetMode == NM_Standalone) || (Level.NetMode == NM_ListenServer))
      SpawnPlasmaEffects();
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	Damage = mpDamage;
	blastRadius = mpBlastRadius;
}

simulated function PostNetBeginPlay()
{
      SpawnPlasmaEffects();
}

// DEUS_EX AMSD Should not be called as server propagating to clients.
simulated function SpawnPlasmaEffects()
{
	local Rotator rot;
   rot = Rotation;
	rot.Yaw -= 32768;

   pGen2 = Spawn(class'ParticleGenerator', Self,, Location, rot);
	if (pGen2 != None)
	{
      pGen2.RemoteRole = ROLE_None;
		pGen2.particleTexture = FireTexture'Effects.Laser.LaserSpot2';
		pGen2.particleDrawScale = 2.0;
		pGen2.checkTime = 0.04;
		pGen2.riseRate = 0.0;
		pGen2.ejectSpeed = 100.0;
		pGen2.particleLifeSpan = 4.0;
		pGen2.bRandomEject = True;
		pGen2.SetBase(Self);
	}
   
}

simulated function Destroyed()
{
	if (pGen1 != None)
		pGen1.DelayedDestroy();
	if (pGen2 != None)
		pGen2.DelayedDestroy();

	Super.Destroyed();
}

defaultproperties
{
    mpDamage=5.00
    mpBlastRadius=100.00
    bExplodes=True
    blastRadius=128.00
    DamageType=Sabot
    AccurateRange=14400
    maxRange=24000
    bIgnoresNanoDefense=True
    ItemName="Energy Bolt"
    ItemArticle="an"
    speed=1500.00
    MaxSpeed=1500.00
    Damage=5.00
    MomentumTransfer=5000
    ImpactSound=Sound'DeusExSounds.Weapons.PlasmaRifleHit'
    ExplosionDecal=Class'DeusEx.ScorchMark'
    Texture=FireTexture'Effects.Laser.LaserBeam2'
    Mesh=LodMesh'DeusExItems.Tracer'
    DrawScale=3.00
    bUnlit=True
    LightBrightness=200
    LightHue=80
    LightSaturation=128
    LightRadius=3
    bFixedRotationDir=True
}
