//=============================================================================
// UNATCOTroop.
//=============================================================================
class eUNATCOTroop extends DXEnemy;

defaultproperties
{
	sScanning(0)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_97'
	sScanning(1)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_98'
	sScanning(2)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_99'
	sScanning(3)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_100'
	sScanning(4)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_93'
	sTargetAcquired(0)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_104'
	sTargetAcquired(1)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_92'
	sTargetAcquired(2)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_91'
	sTargetLost(0)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_105'
	sTargetLost(1)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_105'
	sTargetLost(2)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_105'
	sCriticalDamage(0)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_116'
	sCriticalDamage(1)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_117'
	sCriticalDamage(2)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_118'
	sAreaSecure(0)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_113'
	sAreaSecure(1)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_114'
	sAreaSecure(2)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_115'
	sBossArmourDown=sound'DeusExConAudioAIBarks.ConAudioAIBarks_89'
	sBossArmourBack=sound'DeusExConAudioAIBarks.ConAudioAIBarks_116'
	sMedkitUsed=sound'DeusExConAudioAIBarks.ConAudioAIBarks_117'
	sCallingBackup(0)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_86'
	sCallingBackup(1)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_85'
	sCallingBackup(2)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_87'
	sRespondBackup(0)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_119'
	sRespondBackup(1)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_120'
	sRespondBackup(2)=sound'DeusExConAudioAIBarks.ConAudioAIBarks_121'
	sHunting=sound'DeusExConAudioAIBarks.ConAudioAIBarks_92'
     CarcassType=Class'DeusEx.UNATCOTroopCarcass'
     WalkingSpeed=0.300000
     InitialInventory(0)=(Inventory=Class'DeusEx.WeaponAssaultGun')
     InitialInventory(1)=(Inventory=Class'DeusEx.Ammo762mm',Count=12)
     InitialInventory(2)=(Inventory=Class'DeusEx.WeaponCombatKnife')
     walkAnimMult=0.780000
     GroundSpeed=200.000000
     Texture=Texture'DeusExItems.Skins.PinkMaskTex'
     Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.MiscTex1'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.UNATCOTroopTex1'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.UNATCOTroopTex2'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.MiscTex1'
     MultiSkins(4)=Texture'DeusExCharacters.Skins.MiscTex1'
     MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(6)=Texture'DeusExCharacters.Skins.UNATCOTroopTex3'
     MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     BindName="UNATCOTroop"
     FamiliarName="UNATCO Troop"
     UnfamiliarName="UNATCO Troop"
}