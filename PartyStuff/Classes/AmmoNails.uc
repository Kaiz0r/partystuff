//=============================================================================
// AmmoNails.   (C) 101 Street Killers
//=============================================================================
class AmmoNails extends DeusExAmmo;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
      AmmoAmount = 6;
}

defaultproperties
{
    bShowInfo=True
    AmmoAmount=15
    MaxAmmo=50
    ItemName="Nails"
    ItemArticle="some"
    PickupViewMesh=LodMesh'DeusExItems.AmmoDart'
    LandSound=Sound'DeusExSounds.Generic.PaperHit2'
    Icon=Texture'DeusExUI.Icons.BeltIconAmmoDartsNormal'
    largeIcon=Texture'DeusExUI.Icons.LargeIconAmmoDartsNormal'
    largeIconWidth=20
    largeIconHeight=47
    Description="Specialy designed nails.Designed to pierce flesh more than wood!"
    beltDescription="NAILS"
    Mesh=LodMesh'DeusExItems.AmmoDart'
    CollisionRadius=8.50
    CollisionHeight=2.00
    bCollideActors=True
}
