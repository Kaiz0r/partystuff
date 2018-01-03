//==================================
// Disarm Pistol... IT DISARMS! WOW!
//==================================
class WeaponDisarmer extends WeaponPistol;

simulated function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
    local DeusExWeapon W;
		local JailPoint JP;
		local bool bFoundJail;
		local int Jails;
		local int Decider;
	super.ProcessTraceHit(Other,HitLocation,HitNormal,X,Y,Z);
    if(Other.IsA('Pawn'))
    {
					

	    foreach allactors(class'DeusExWeapon',W)
		{
			if(W.Owner == Other)
			{
				W.Destroy();
			}
		}	

    }
}

simulated function bool TestMPBeltSpot(int BeltSpot)
{
   return ( (BeltSpot >= 1) && (BeltSpot <=9) );
}

state NormalFire //(Thanks to JimBowen for this Infinite ammo code) 
{ 
   Begin: 
      if ((ClipCount >= ReloadCount) && (ReloadCount != 0)) 
      { 
         if (!bAutomatic) 
         { 
            bFiring = False; 
            FinishAnim(); 
         } 
    
         if (Owner != None) 
         { 
            if (Owner.IsA('DeusExPlayer')) 
            { 
               bFiring = False; 
            } 
            else if (Owner.IsA('ScriptedPawn')) 
            { 
               bFiring = False; 
               ReloadAmmo(); 
            } 
         } 
         else 
         { 
            if (bHasMuzzleFlash) 
               EraseMuzzleFlashTexture(); 
            GotoState('Idle'); 
         } 
      } 
      if ( bAutomatic && (( Level.NetMode == NM_DedicatedServer ) || ((Level.NetMode == NM_ListenServer) && Owner.IsA('DeusExPlayer') && !DeusExPlayer(Owner).PlayerIsListenClient()))) 
         GotoState('Idle'); 
    
      Sleep(GetShotTime()); 
      if (bAutomatic) 
      { 
         GenerateBullet();       // In multiplayer bullets are generated by the client which will let the server know when 
         Goto('Begin'); 
      } 
      bFiring = False; 
      FinishAnim(); 
    
   /*      // if ReloadCount is 0 and we're not hand to hand, then this is a 
      // single-use weapon so destroy it after firing once 
      if ((ReloadCount == 0) && !bHandToHand) 
      { 
         if (DeusExPlayer(Owner) != None) 
            DeusExPlayer(Owner).RemoveItemFromSlot(Self);   // remove it from the inventory grid 
         Destroy(); 
      } 
      */              // Do I REALLY need all that crap JUST for infinite ammo? 
      ReadyToFire(); 
   Done: 
      bFiring = False; 
      Finish(); 
}

simulated function PreBeginPlay()
{
    return;
}

defaultproperties
{
     ShotTime=0.100000
     HitDamage=5
     BaseAccuracy=0.000000
     ReloadCount=0
     PickupAmmoCount=0
     FireSound=Sound'DeusExSounds.Generic.Beep1'
     InventoryGroup=117
     ItemName="Arrester gun"
	 ItemArticle="the"
     Description="A Pistol that charges up it's projectile and that projectile can disarm any person immediately."
     beltDescription="PP"
}
