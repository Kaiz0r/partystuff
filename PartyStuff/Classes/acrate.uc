class ACrate extends Containers;

var localized String AmmoReceived;

// ----------------------------------------------------------------------
// Frob()
//
// If we are frobbed, trigger our event
// ----------------------------------------------------------------------
function Frob(Actor Frobber, Inventory frobWith)
{
	local Actor A;
	local Pawn P;
	local DeusExPlayer Player;
   local Inventory CurInventory;
	local RadarDrone RD;
	local WeaponAirget air;
	local ToolRadarD TD;
	local Estus es;
	
   //Don't call superclass frob.

   P = Pawn(Frobber);
	Player = DeusExPlayer(Frobber);

   if (Player != None)
   {
      CurInventory = Player.Inventory;
      while (CurInventory != None)
      {
         if (CurInventory.IsA('DeusExWeapon'))
            RestockWeapon(Player,DeusExWeapon(CurInventory));
         CurInventory = CurInventory.Inventory;
      }
      Player.ClientMessage(AmmoReceived);
		PlaySound(sound'WeaponPickup', SLOT_None, 0.5+FRand()*0.25, , 256, 0.95+FRand()*0.1);
   }
   
   Foreach AllActors(class'RadarDrone',RD)
   {
	if(RD.myOwner == Player)
	{
		if(RD.RocketsRemain < 30)
		{
			RD.RocketsRemain = 30;
			RD.rRocketsRemain = RD.rocketsRemain;
			Player.ClientMessage("Drone rockets restocked.");
			    Foreach AllActors(class'ToolRadarD',TD)
					if(TD.Owner == Player)
						TD.DroneAmmo = RD.RocketsRemain;
		}
	}
   }

           
   Foreach AllActors(class'Weaponairget',air)
   {
	if(air.Owner == Player)
	{
		if(air.Airammo < 10)
		{
			air.AirAmmo = 10;
			air.rAirAmmo = air.Airammo;
			Player.ClientMessage("Airget rockets restocked.");
		}
	}
   }
    Foreach AllActors(class'Estus',es)
   {
	if(es.Owner == Player)
	{
		if(es.eUses < es.eMaxUses)
		{
			es.eUses = es.eMaxUses;
			Player.ClientMessage("Estus refilled.");
		}
	}
   }
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
      
      if ((AmmoType != None) && (AmmoType.AmmoAmount < WeaponToStock.PickupAmmoCount))
      {
         AmmoType.AddAmmo(WeaponToStock.PickupAmmoCount - AmmoType.AmmoAmount);
      }
   }   
}

defaultproperties
{
    AmmoReceived="Ammo restocked"
    HitPoints=4000
    bFlammable=False
    ItemName="Ammo Crate"
    bPushable=False
    bBlockSight=True
    Mesh=LodMesh'DeusExItems.GEPAmmo'
    bAlwaysRelevant=True
    MultiSkins=Texture'Skins.acrate'
    CollisionRadius=18.00
    CollisionHeight=7.80
    Mass=3000.00
    Buoyancy=40.00
}
