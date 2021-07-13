//=============================================================================
// BinocularsMP.
//=============================================================================
class BinocularsMP extends DeusExPickup;

var bool bZoomed;

replication
{
    reliable if ((Role == ROLE_Authority) && (bNetOwner))
        bZoomed;
        
    reliable if ( Role == ROLE_Authority )
      RefreshScopeDisplay;
}

state Activated
{
	function Activate()
	{
		Super.Activate();

		if (DeusExPlayer(Owner) != None)
			DeusExPlayer(Owner).DesiredFOV = DeusExPlayer(Owner).Default.DesiredFOV;
	}
	function BeginState()
	{
		Super.BeginState();

		if (!bZoomed && (Owner != None) && Owner.IsA('DeusExPlayer'))
		{
			// Show the Binoculars View
			bZoomed = True;
			RefreshScopeDisplay(DeusExPlayer(Owner), False, bZoomed);
		}
	}
Begin:
}

state DeActivated
{
	function BeginState()
	{
		
		Super.BeginState();
		if (bZoomed && (Owner != None) && Owner.IsA('DeusExPlayer'))
		{
			// Hide the Binoculars View
			bZoomed = False;
      			RefreshScopeDisplay(DeusExPlayer(Owner), False, bZoomed);
		}
	}
}

simulated function RefreshScopeDisplay(DeusExPlayer Player, bool bInstant, bool bBinocularOn)
{
	if (bBinocularOn && (Player != None))
	{
		DeusExRootWindow(Player.rootWindow).scopeView.ActivateView(20, True, bInstant);
	}
   	else if (!bBinocularOn)
	{
		DeusExrootWindow(Player.rootWindow).scopeView.DeactivateView();
	}
}

defaultproperties
{
    bActivatable=True
    ItemName="Binoculars"
    ItemArticle="some"
    PlayerViewOffset=(X=18.00,Y=0.00,Z=-6.00),
    PlayerViewMesh=LodMesh'DeusExItems.Binoculars'
    PickupViewMesh=LodMesh'DeusExItems.Binoculars'
    ThirdPersonMesh=LodMesh'DeusExItems.Binoculars'
    LandSound=Sound'DeusExSounds.Generic.PaperHit2'
    Icon=Texture'DeusExUI.Icons.BeltIconBinoculars'
    largeIcon=Texture'DeusExUI.Icons.LargeIconBinoculars'
    largeIconWidth=49
    largeIconHeight=34
    Description="A pair of military binoculars."
    beltDescription="BINOCS"
    Mesh=LodMesh'DeusExItems.Binoculars'
    CollisionRadius=7.00
    CollisionHeight=2.06
    Mass=5.00
    Buoyancy=6.00
}
