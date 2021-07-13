class HideyBox extends BoxLarge;

var vector OldLocation;
var bool bInBox;
var PlayerPawn StoredPlayer;
var bool bFixWeapons;
var bool bActive;

function SilentAdd(class<inventory> addClass, DeusExPlayer addTarget)
{ 
	local Inventory anItem;
	
	anItem = Spawn(addClass); 
	anItem.Instigator = addTarget; 
	anItem.GotoState('Idle2'); 
	anItem.bHeldItem = true; 
	anItem.bTossedOut = false; 
	
	if(Weapon(anItem) != None) 
		Weapon(anItem).GiveAmmo(addTarget); 
	anItem.GiveTo(addTarget);
}

function Tick(float deltatime)
{
	if(StoredPlayer != None)
	{
		StoredPlayer.SetPhysics(PHYS_None);
		StoredPlayer.SetLocation(Location);
		
		if(StoredPlayer.Health <= 0)
		{
		EjectPlayer(DeusExPlayer(StoredPlayer));
		}
		if(bFixWeapons)
		{
			DeusExPlayer(StoredPlayer).inHand = none;	
		}

		if(StoredPlayer.bIsCrouching)
			{
				EjectPlayer(DeusExPlayer(StoredPlayer));
			}
	}
}

function EjectPlayer(DeusExPlayer Frobber)
{
local rotator Z2F;
Z2F=Frobber.Rotation;
			Frobber.SetLocation(Location + (Frobber.CollisionRadius + CollisionRadius + 30) * vector(Rotation) + vect(0.00,0.00,1.00));
			Frobber.bHidden=False;
			Frobber.SetCollision(true, true , true);
			Frobber.bCollideWorld = true;
			Frobber.SetPhysics(Phys_Falling);
			Frobber.bBehindView=False;
			Frobber.ViewTarget = None;
			Frobber.ClientReStart();
			bInBox = False;
			StoredPlayer.ClientMessage("Left box successfully.");
			StoredPlayer = None;
}

function Frob(Actor Frobber, Inventory frobWith)
{	
local HideyBoxItem h;

	if(!bInBox)
	{
		if(DeusExPlayer(Frobber).bIsCrouching)
		{
			if(bActive)
			{
				bActive=False;
					Destroy();
					SilentAdd(class'HideyboxItem', DeusExPlayer(frobber));
			}
			
		}
		else
		{
			OldLocation = Frobber.Location;
			
			Frobber.SetLocation(Self.Location);
			Frobber.bHidden=True;
			Frobber.SetCollision(false, false, false);
			Frobber.bCollideWorld = true;
			DeusExPlayer(Frobber).SetPhysics(Phys_None);
			DeusExPlayer(Frobber).bBehindView=True;
			PlayerPawn(Frobber).ViewTarget = Self;
			StoredPlayer = PlayerPawn(Frobber);
			StoredPlayer.ClientMessage("Crouch to exit the box.");
			StoredPlayer.ClientMessage("If Crouch doesn't work, enter the command |P2Mutate Box");
			bInBox=True;
		}

	}
	else
	{
		if(PlayerPawn(Frobber) == StoredPlayer)
		{
			EjectPlayer(DeusExPlayer(Frobber));
		}
		else
		{
			DeusExPlayer(Frobber).ClientMessage("Box is full...");
		}

	}

}

defaultproperties
{
    bFixWeapons=True
    bActive=True
    bInvincible=True
    bPushable=False
}
