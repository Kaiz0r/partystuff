//=============================================================================
// BFG
//=============================================================================
class BFG extends Rocket;

var() float shakeTime;
var() float shakeRollMagnitude;
var() float shakeVertMagnitude;

var SizableEffectSpawner efs;

simulated function SpawnRocketEffects()
{
	efs = Spawn(class'SizableEffectSpawner',,,Location);
	if (efs != None)
	{
		efs.RemoteRole = ROLE_None;
		efs.SetBase(Self);
		efs.EffectClass=class'MagicRing';
		efs.EffectSkin = Texture'SkyBlueRay';
		efs.SizeofEffect = 3;
		efs.Interval = 0.01;
		efs.EffectLSpan = 1.0;
   	}
}

simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
        local ExplosionLarge expeffect;
	local DeusExPlayer player, pls;
	local pring sphere;
	//stop the other effect
	efs.Destroy();

	player = DeusExPlayer(Owner);
	
	foreach AllActors(class'DeusExPlayer', pls)
	{
		if (pls != None)
		{
			pls.ShakeView(shakeTime, shakeRollMagnitude, shakeVertMagnitude);
		}
	}

	// draw a pretty explosion
	efs = Spawn(class'SizableEffectSpawner',,, HitLocation);
	if (efs != None)
	{
		efs.RemoteRole = ROLE_None;
		efs.EffectClass=class'MagicRing';      		
		efs.EffectSkin = Texture'SkyBlueRay';
		efs.SizeofEffect = 10;
		efs.Interval = 0.1;
		efs.TimeLimit=12;
		efs.EffectLSpan = 3.0;
   	}
	sphere = Spawn(class'pring',,, HitLocation);
	if (sphere != None)
	{
	sphere.RemoteRole = ROLE_None;
	sphere.size = blastradius;
	Sphere.MultiSkins[0]=Texture'DeusExDeco.Skins.AlarmLightTex7';
	}
   	expeffect = Spawn(class'ExplosionLarge',,, HitLocation);
   	if (expeffect != None)
   	   expeffect.RemoteRole = ROLE_None;	
}

defaultproperties
{
    shaketime=3.00
    shakeRollMagnitude=512.00
    shakeVertMagnitude=48.00
    blastRadius=1024.00
    bTracking=False
    ItemName="Big Fucking Blast"
    speed=500.00
    MaxSpeed=1000.00
    SpawnSound=None
    ImpactSound=None
    DrawType=1
    Style=3
    Texture=Texture'PGAssets.Skins.SkyBlueRay'
    Mesh=None
    DrawScale=5.00
    SoundRadius=0
    SoundVolume=0
    AmbientSound=None
}
