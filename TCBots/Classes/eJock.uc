//=============================================================================
// Jock.
//=============================================================================
class eJock extends DXEnemy;

defaultproperties
{
     scoreCredits=300
     CarcassType=Class'DeusEx.JockCarcass'
     WalkingSpeed=0.300000
     bImportant=True
     BaseAssHeight=-23.000000
     InitialInventory(0)=(Inventory=Class'DeusEx.WeaponSawedOffShotgun')
     InitialInventory(1)=(Inventory=Class'DeusEx.AmmoShell',Count=12)
     InitialInventory(2)=(Inventory=Class'DeusEx.WeaponCrowbar')
     walkAnimMult=1.050000
     GroundSpeed=200.000000
     Health=400
     HealthHead=400
     HealthTorso=400
     HealthLegLeft=400
     HealthLegRight=400
     HealthArmLeft=400
     HealthArmRight=400
     Mesh=LodMesh'DeusExCharacters.GM_Trench'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.JockTex0'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.JockTex2'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.JockTex3'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.JockTex0'
     MultiSkins(4)=Texture'DeusExCharacters.Skins.JockTex1'
     MultiSkins(5)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(6)=Texture'DeusExCharacters.Skins.FramesTex2'
     MultiSkins(7)=Texture'DeusExCharacters.Skins.LensesTex3'
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     BindName="Jock"
     FamiliarName="Jock"
     UnfamiliarName="Jock"
}