//=============================================================================
// AmmoNuclearBattery.  
//=============================================================================
class AmmoNuclearBattery extends DeusExAmmo;

defaultproperties
{
    bShowInfo=True
    AmmoAmount=25
    MaxAmmo=50
    ItemName="Nuclear Battery"
    ItemArticle="a"
    PickupViewMesh=LodMesh'DeusExItems.AmmoPlasma'
    LandSound=Sound'DeusExSounds.Generic.PlasticHit2'
    Icon=Texture'DeusExUI.Icons.BeltIconAmmoPlasma'
    largeIconWidth=22
    largeIconHeight=46
    Description="A battery straight from 101 labs.It contains enough energy to keep the city of chicago running for 2 hours!"
    beltDescription="|p5NBATT"
    Mesh=LodMesh'DeusExItems.AmmoPlasma'
    CollisionRadius=4.30
    CollisionHeight=8.44
    bCollideActors=True
}
