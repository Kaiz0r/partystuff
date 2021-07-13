class bed2 extends DeusExDecoration;

var DeusExPlayer Player;
var bool bBusy;
var(Bed2) int WaitTime;
var(Special) string DisString;
var() bool bTeleport;
var() name TeleportTag;
#exec obj load file=..\Textures\CoreTexTextile.utx package=CoreTexTextile
#exec obj load file=..\Textures\CoreTexWood.utx package=CoreTexWood
#exec obj load file=..\Textures\CoreTexPaper.utx package=CoreTexPaper

Function Frob(Actor Frobber, Inventory Frobwith)
{
	if(DisString != "")
	{
		DeusExPlayer(Frobber).ClientMessage(DisString);
		return;
	}
	
		if(DeusExPlayer(Frobber) != None)
		{
			DisString = "The bed is in use!";
			Player = DeusExPlayer(Frobber);
			Player.ClientMessage("You begin to rest...");
			player.ClientFlash(1,Vect(20000,20000,20000));
			player.IncreaseClientFlashLength(5.0);
			SetTimer(WaitTime,False);
			Player.SetPhysics(Phys_None);
		}
}

function Timer()
{
	local Teleporter tp;
	
	if(bTeleport)
		foreach AllActors(class'Teleporter', TP)
			if(TP.Tag == TeleportTag)
				player.SetLocation(TP.Location);
	player.HealPlayer(9999, True);
	DisString = "";
	Player.SetPhysics(Phys_Falling);
}

defaultproperties
{
    WaitTime=2
    bInvincible=True
    bCanBeBase=True
    ItemName="Bed"
    bPushable=False
    Physics=0
    Mesh=LodMesh'bedsmall'
    MultiSkins(0)=Texture'CoreTexTextile.Textile.ClenBlueGrey_A'
    MultiSkins(1)=Texture'CoreTexWood.Wood.ClenMedmWalnt_A'
    MultiSkins(2)=Texture'CoreTexPaper.Paper.ClenWhitPaint_A'
    CollisionRadius=60.00
    CollisionHeight=24.00
}
