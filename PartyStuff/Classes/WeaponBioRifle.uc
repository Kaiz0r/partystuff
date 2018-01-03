class WeaponBioRifle extends WeaponAssaultGun;

simulated function bool TestMPBeltSpot(int BeltSpot)
{
   return ( (BeltSpot >= 1) && (BeltSpot <=9) );
}

defaultproperties
{
     HitDamage=8
     bInstantHit=False
     ProjectileClass=Class'GrayShoot'
     InventoryGroup=111
     ItemName="|P2Bio Assault Gun"
     beltDescription="BIO"
     Mass=1.000000
}
