//=============================================================================
// It's a tarp.
//=============================================================================
class HideyBoxItem extends ChargedPickup;

// ----------------------------------------------------------------------
// ChargedPickupBegin()
// ----------------------------------------------------------------------

function ChargedPickupBegin(DeusExPlayer Player)
{
  // local HideyBox CD;
   local Vector loc,X,Y,Z;
   
   Spawn(Class'HideyBox',,,Player.Location + (Player.CollisionRadius+Default.CollisionRadius+30) * Vector(Player.ViewRotation) + vect(0,0,1) * 30 );

	Super.ChargedPickupBegin(Player);
	
}

simulated function bool TestMPBeltSpot(int BeltSpot)
{
   return ( (BeltSpot >= 1) && (BeltSpot <=9) );
}

function UsedUp()
{
	local DeusExPlayer Player;

	if ( Pawn(Owner) != None )
	{
		bActivatable = false;
		
	}
	Player = DeusExPlayer(Owner);

	if (Player != None)
	{
		if (Player.inHand == Self)
			ChargedPickupEnd(Player);
	}

	Destroy();
}

defaultproperties
{
    ActivateSound=Sound'DeusExSounds.Augmentation.CloakUp'
    DeActivateSound=None
    ChargeRemainingLabel="Box readiness:"
    ItemName="Portable Hideybox"
    PlayerViewOffset=(X=20.00,Y=0.00,Z=-12.00),
    PlayerViewMesh=LodMesh'DeusExDeco.BoxLarge'
    PlayerViewScale=0.20
    PickupViewMesh=LodMesh'DeusExDeco.BoxLarge'
    ThirdPersonMesh=LodMesh'DeusExDeco.BoxLarge'
    ThirdPersonScale=0.25
    Charge=8
    LandSound=Sound'DeusExSounds.Generic.DropLargeWeapon'
    Icon=Texture'DeusExUI.Icons.BeltIconArmorAdaptive'
    largeIcon=Texture'DeusExUI.Icons.LargeIconArmorAdaptive'
    largeIconWidth=35
    largeIconHeight=49
    Description="s"
    beltDescription="BOX"
    Mesh=LodMesh'DeusExDeco.BoxLarge'
    CollisionRadius=45.00
    CollisionHeight=32.00
    Mass=10.00
    Buoyancy=100.00
}
