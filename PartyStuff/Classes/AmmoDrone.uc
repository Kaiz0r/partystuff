//========================================
// Ammo, special for the drone system
//========================================
Class AmmoDrone extends AmmoNapalm;

defaultproperties
{
    AmmoAmount=100000
    MaxAmmo=1000000
    ItemName="Drone Rockets"
    ItemArticle="some"
    PickupViewMesh=LodMesh'DeusExItems.Credits'
    Icon=Texture'DeusExUI.Icons.BeltIconCredits'
    largeIcon=Texture'DeusExUI.Icons.BeltIconCredits'
    beltDescription="Rockets"
    Mesh=LodMesh'DeusExItems.Credits'
    CollisionHeight=4.48
}
