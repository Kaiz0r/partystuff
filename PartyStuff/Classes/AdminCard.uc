//=============================================================================
// AdminCard.
//=============================================================================
class AdminCard expands DeusExPickup;

// ----------------------------------------------------------------------
// TestMPBeltSpot()
// Returns true if the suggested belt location is ok for the object in mp.
// ----------------------------------------------------------------------

simulated function bool TestMPBeltSpot(int BeltSpot)
{
   return ( (BeltSpot >= 1) && (BeltSpot <=9) );
}

defaultproperties
{
    bCanHaveMultipleCopies=True
    ItemName="Admin Pass"
    PlayerViewOffset=(X=30.00,Y=0.00,Z=-12.00),
    PlayerViewMesh=LodMesh'DeusExItems.Credits'
    PickupViewMesh=LodMesh'DeusExItems.Credits'
    ThirdPersonMesh=LodMesh'DeusExItems.Credits'
    LandSound=Sound'DeusExSounds.Generic.PlasticHit1'
    Icon=Texture'DeusExUI.Icons.BeltIconCredits'
    beltDescription="Admin Pass"
    Mesh=LodMesh'DeusExItems.Credits'
    MultiSkins=Texture'DeusExUI.UserInterface.ComputerLogonLogoIlluminati'
    CollisionRadius=7.00
    CollisionHeight=0.55
    Mass=2.00
    Buoyancy=3.00
}
