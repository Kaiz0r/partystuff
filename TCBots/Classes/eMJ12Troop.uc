//=============================================================================
// MJ12Troop.
//=============================================================================
class eMJ12Troop extends DXEnemy;

defaultproperties
{
		sScanning=sound'DeusExConAudioAIBarks.ConAudioAIBarks_97'
	sTargetAcquired=sound'DeusExConAudioAIBarks.ConAudioAIBarks_104'
	sTargetLost=sound'DeusExConAudioAIBarks.ConAudioAIBarks_105'
	sCriticalDamage=sound'DeusExConAudioAIBarks.ConAudioAIBarks_117'
	sAreaSecure=sound'DeusExConAudioAIBarks.ConAudioAIBarks_115'
	sBossArmourDown=sound'DeusExConAudioAIBarks.ConAudioAIBarks_89'
	sBossArmourBack=sound'DeusExConAudioAIBarks.ConAudioAIBarks_116'
	sMedkitUsed=sound'DeusExConAudioAIBarks.ConAudioAIBarks_117'
	sCallingBackup=sound'DeusExConAudioAIBarks.ConAudioAIBarks_87'
	sRespondBackup=sound'DeusExConAudioAIBarks.ConAudioAIBarks_119'
	sHunting=sound'DeusExConAudioAIBarks.ConAudioAIBarks_92'
     CarcassType=Class'DeusEx.MJ12TroopCarcass'
     WalkingSpeed=0.300000
     InitialAlliances(3)=(AllianceName=eTerrorist,AllianceLevel=-1.000000)
     InitialAlliances(4)=(AllianceName=eJoJoFine,AllianceLevel=-1.000000)
     InitialAlliances(5)=(AllianceName=eJock,AllianceLevel=-1.000000)
     InitialAlliances(6)=(AllianceName=Rogue,AllianceLevel=-1.000000)
     InitialInventory(0)=(Inventory=Class'DeusEx.WeaponAssaultGun')
     InitialInventory(1)=(Inventory=Class'DeusEx.Ammo762mm',Count=12)
     InitialInventory(2)=(Inventory=Class'DeusEx.WeaponCombatKnife')
     walkAnimMult=0.780000
     GroundSpeed=200.000000
     Texture=Texture'DeusExItems.Skins.PinkMaskTex'
     Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.SkinTex1'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.MJ12TroopTex1'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.MJ12TroopTex2'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.SkinTex1'
     MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(5)=Texture'DeusExCharacters.Skins.MJ12TroopTex3'
     MultiSkins(6)=Texture'DeusExCharacters.Skins.MJ12TroopTex4'
     MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     BindName="MJ12Troop"
     FamiliarName="MJ12 Troop"
     UnfamiliarName="MJ12 Troop"
}
