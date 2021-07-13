//=============================================================================
// AmmoSpazmGas.
//=============================================================================
class AmmoSpazmGas expands DeusExAmmo;

defaultproperties
{
    AmmoAmount=100
    MaxAmmo=500
    ItemName="Spazm Gas Ammo"
    ItemArticle="some"
    PickupViewMesh=LodMesh'DeusExItems.AmmoPepper'
    Description="These cartriges contain gas that disturbs he natural brain's electric impulses, effectivly giving the target a seizure."
    Mesh=LodMesh'DeusExItems.AmmoPepper'
    CollisionRadius=3.00
    CollisionHeight=4.00
}
