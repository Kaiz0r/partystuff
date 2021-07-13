//=============================================================================
// DarkMaiden.
//=============================================================================
class CubeHealer extends CrateUnbreakableMed;

Var DeusExPlayer P;

function Frob(Actor Frobber, Inventory frobWith)
{
	local Actor A;
	local Pawn P;
	local DeusExPlayer Player;
   local Inventory CurInventory;

	Player = DeusExPlayer(Frobber);

	if (player != None)
		HealPlayer2(player, 100);
		player.StopPoison();
		player.ExtinguishFire();
		player.drugEffectTimer = 0;			
		player.Energy += 200;
			if (player.Energy > 200)
				player.Energy = 200;
		
   if (Player != None)
   {
      CurInventory = Player.Inventory;
      while (CurInventory != None)
      {
         if (CurInventory.IsA('DeusExWeapon'))
            RestockWeapon(Player,DeusExWeapon(CurInventory));
         CurInventory = CurInventory.Inventory;
      }
		PlaySound(sound'CreditsEnd', SLOT_None, 0.5+FRand()*0.25, , 256, 0.95+FRand()*0.1);
   }
   
   player.ClientMessage("Fully restocked and healed. Energy raised to 200.");
}

function RestockWeapon(DeusExPlayer Player, DeusExWeapon WeaponToStock)
{
   local Ammo AmmoType;
   if (WeaponToStock.AmmoType != None)
   {
      if (WeaponToStock.AmmoNames[0] == None)
         AmmoType = Ammo(Player.FindInventoryType(WeaponToStock.AmmoName));
      else
         AmmoType = Ammo(Player.FindInventoryType(WeaponToStock.AmmoNames[0]));

      if (WeaponToStock.AmmoNames[1] == None)
         AmmoType = Ammo(Player.FindInventoryType(WeaponToStock.AmmoName));
      else
         AmmoType = Ammo(Player.FindInventoryType(WeaponToStock.AmmoNames[1]));
      
	  if (WeaponToStock.AmmoNames[2] == None)
         AmmoType = Ammo(Player.FindInventoryType(WeaponToStock.AmmoName));
      else
         AmmoType = Ammo(Player.FindInventoryType(WeaponToStock.AmmoNames[2]));
      

      if ((AmmoType != None) && (AmmoType.AmmoAmount < WeaponToStock.PickupAmmoCount))
      {
         AmmoType.AddAmmo(WeaponToStock.PickupAmmoCount - AmmoType.AmmoAmount);
      }
   }   
}

function HealPlayer2(deusexplayer player, int baseHealPoints, optional Bool bUseMedicineSkill)
{
	local float mult;
	local int adjustedHealAmount, aha2, tempaha;
	local int origHealAmount;
	local float dividedHealAmount;

	if (bUseMedicineSkill)
		adjustedHealAmount = player.CalculateSkillHealAmount(baseHealPoints);
	else
		adjustedHealAmount = baseHealPoints;

	origHealAmount = adjustedHealAmount;

	if (adjustedHealAmount > 0)
	{
		if (bUseMedicineSkill)
			player.PlaySound(sound'MedicalHiss', SLOT_None,,, 256);

		// Heal by 3 regions via multiplayer game
		if (( Level.NetMode == NM_DedicatedServer ) || ( Level.NetMode == NM_ListenServer ))
		{
         // DEUS_EX AMSD If legs broken, heal them a little bit first
         if (player.HealthLegLeft == 0)
         {
            aha2 = adjustedHealAmount;
            if (aha2 >= 5)
               aha2 = 5;
            tempaha = aha2;
            adjustedHealAmount = adjustedHealAmount - aha2;
            player.HealPart(player.HealthLegLeft, aha2);
            player.HealPart(player.HealthLegRight,tempaha);
         }
			player.HealPart(player.HealthHead, adjustedHealAmount);

			if ( adjustedHealAmount > 0 )
			{
				aha2 = adjustedHealAmount;
				player.HealPart(player.HealthTorso, aha2);
				aha2 = adjustedHealAmount;
				player.HealPart(player.HealthArmRight,aha2);
				player.HealPart(player.HealthArmLeft, adjustedHealAmount);
			}
			if ( adjustedHealAmount > 0 )
			{
				aha2 = adjustedHealAmount;
				player.HealPart(player.HealthLegRight, aha2);
				player.HealPart(player.HealthLegLeft, adjustedHealAmount);
			}
		}
		else
		{
			player.HealPart(player.HealthHead, adjustedHealAmount);
			player.HealPart(player.HealthTorso, adjustedHealAmount);
			player.HealPart(player.HealthLegRight, adjustedHealAmount);
			player.HealPart(player.HealthLegLeft, adjustedHealAmount);
			player.HealPart(player.HealthArmRight, adjustedHealAmount);
			player.HealPart(player.HealthArmLeft, adjustedHealAmount);
		}
	}
}

defaultproperties
{
    ItemName="Cube of Healing"
    bPushable=False
    Physics=5
    Texture=FireTexture'Effects.Electricity.Nano_SFX_A'
    Skin=FireTexture'Effects.Electricity.Nano_SFX_A'
    DrawScale=1.50
    CollisionRadius=60.00
    CollisionHeight=60.00
    bFixedRotationDir=True
    Mass=500.00
    Physics=PHYS_Rotating
    RotationRate=(Pitch=11192,Yaw=11192,Roll=11192),
}
