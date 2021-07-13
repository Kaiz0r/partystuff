//=============================================================================
// AdaptiveArmor.
//=============================================================================
class AdminArmour extends DeusExPickup;
#exec OBJ LOAD FILE="..\Textures\Extras.utx"
var() bool bAAOn;
simulated function bool TestMPBeltSpot(int BeltSpot)
{
   return ( (BeltSpot >= 1) && (BeltSpot <=9) );
}
defaultproperties
{
    bAAOn=True
    ItemName="Admin Armour"
    ItemArticle="some"
    PlayerViewOffset=(X=30.00,Y=0.00,Z=-12.00),
    PlayerViewMesh=LodMesh'DeusExItems.AdaptiveArmor'
    PickupViewMesh=LodMesh'DeusExItems.AdaptiveArmor'
    ThirdPersonMesh=LodMesh'DeusExItems.AdaptiveArmor'
    Charge=500
    LandSound=Sound'DeusExSounds.Generic.PaperHit2'
    Icon=Texture'DeusExUI.Icons.BeltIconArmorAdaptive'
    largeIcon=Texture'DeusExUI.Icons.LargeIconArmorAdaptive'
    largeIconWidth=35
    largeIconHeight=49
    Description="Integrating woven fiber-optics and an advanced computing system, thermoptic camo can render an agent invisible to both humans and bots by dynamically refracting light and radar waves; however, the high power drain makes it impractial for more than short-term use, after which the circuitry is fused and it becomes useless."
    beltDescription="ADMIN"
    Mesh=LodMesh'DeusExItems.AdaptiveArmor'
    MultiSkins(1)=Texture'Extras.Eggs.Matrix_A00'
    CollisionRadius=11.50
    CollisionHeight=13.81
    Mass=30.00
    Buoyancy=20.00
}
