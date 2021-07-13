Class Automed extends DeusExPickup;

var() bool bGlowHP, bButCharging;
var int TickDelay;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
		MaxCopies = 1;
}

state Activated
{
	function Activate()
	{
		// can't turn it off
	}

	function BeginState()
	{
		local DeusExPlayer player, hitplayer;
		local scriptedpawn hitpawn;
		local dxScriptedPawn hitpawn2;
		local Actor       hitActor;
		local Vector      hitLocation, hitNormal;
		local Vector      position, line;
		Super.BeginState();
		player = DeusExPlayer(Owner);
		if(bButCharging)
			player.ClientMessage("|P2Charging...");
		else
			player.ClientMessage("|P3Ready!");
		foreach AllActors(class'Inventory', Inv)
		{
			if (Inv.Owner == player)
			{
				if (Inv.IsA('Medkit')) 
				{
					player.ClientMessage("Automed will use Medkits. "$Medkit(inv).NumCopies$" remaining.");
				}
				if (Inv.IsA('Estus')) 
				{
					player.ClientMessage("Automed will use Estus. "$Estus(inv).eUses$" remaining.");
				}
			}
		}
		GotoState('DeActivated');
	}
Begin:
}

function InjectMedkit(string Purpose)
{
      local Inventory Inv;
	  local bool bDoneIt;
	  
		bButCharging=True;
		TickDelay=0;
		SetTimer(20,False);
	if(Purpose != "bio")	
	{
		if(Purpose == "critical")
		{
			DeusExPlayer(Owner).PlaySound(sound'near_death', SLOT_Talk,2,,1024,);
		}
		if(Purpose == "legless")
		{
		DeusExPlayer(Owner).PlaySound(sound'major_fracture', SLOT_Talk,2,,1024,);
		}	
		if(Purpose == "drug")
		{
		DeusExPlayer(Owner).PlaySound(sound'blood_toxins', SLOT_Talk,2,,1024,);
		}		
		if(Purpose == "fire")
		{
		DeusExPlayer(Owner).PlaySound(sound'heat_damage', SLOT_Talk,2,,1024,);
		}
		
		foreach AllActors(class'Inventory', Inv)
		{
			if (Inv.Owner == DeusExPlayer(Owner))
			{
				if (Inv.IsA('Medkit')) 
				{
					bDoneIt=True;
					Inv.GotoState('Activated');
					return;
				}
				if (Inv.IsA('Estus')) 
				{
					if(Estus(inv).eUses > 0)
					{
						bDoneIt=True;
						Inv.GotoState('Activated');
						return;
					}
				}
			}
		}
	}
	else if(Purpose == "bio")
	{
		foreach AllActors(class'Inventory', Inv)
		{
			if (Inv.Owner == DeusExPlayer(Owner))
			{
				if (Inv.IsA('Biocell')) 
				{
					bDoneIt=True;
					Inv.GotoState('Activated');
					return;
				}
				if (Inv.IsA('Estus')) 
				{
					if(Estus(inv).eUses > 0)
					{
						bDoneIt=True;
						Inv.GotoState('Activated');
						return;
					}
				}
			}
		}
	}
		if(!bDoneIt)
		{
			DeusExPlayer(Owner).ClientMessage("No healing available....");
		}

}

function Tick(float deltatime)
{
	TickDelay++;
	if(Owner != None && Owner.IsA('Human'))
	{
		if(DeusExPlayer(Owner).HealthHead <= 15 || DeusExPlayer(Owner).HealthTorso <= 15 || DeusExPlayer(Owner).HealthLegLeft <= 0)
		{
			Owner.LightType=LT_Steady;
			Owner.LightEffect=LE_NonIncidence;
			Owner.LightSaturation=0;
			Owner.LightRadius=8;
			Owner.LightBrightness=64;
			Owner.LightHue = DeusExPlayer(Owner).Health;
		}
		else
		{
			Owner.LightType = LT_None;
		}
	//Hack to prevent flamethrower bypassing the automed completely if hit repeatedly
		if(TickDelay <= 15)
		{
			if(DeusExPlayer(Owner).DrugEffectTimer > 0 || DeusExPlayer(Owner).bOnFire)
			{
			DeusExPlayer(Owner).StopPoison();
			DeusExPlayer(Owner).ExtinguishFire();
			DeusExPlayer(Owner).drugEffectTimer = 0;
			}
		}
		if(!bButCharging)
		{
			if(DeusExPlayer(Owner).HealthHead < 25 || DeusExPlayer(Owner).HealthTorso < 25)
			{
				InjectMedkit("critical");
			}
			if(DeusExPlayer(Owner).HealthLegLeft == 0)
			{
				InjectMedkit("legless");
			}
			if(DeusExPlayer(Owner).DrugEffectTimer > 0)
			{
				InjectMedkit("drug");
			}
			if(DeusExPlayer(Owner).bOnFire)
			{
				InjectMedkit("fire");
			}
			if(DeusExPlayer(Owner).Energy < 10)
			{
				InjectMedkit("bio");
			}
		}	
	}
}

function GiveTo( pawn Other )
{
    super.Giveto(Other);
	Other.PlaySound(sound'automedic_on');
	Other.ClientMessage("Automed activated. Medkits will be used when needed.");
}

function Timer()
{
	bButCharging=False;
	if(DeusExPlayer(Owner) != None)
	{
	DeusExPlayer(Owner).PlaySound(sound'automedic_on');
	DeusExPlayer(Owner).ClientMessage("Automed has recharged and can be used again.");
	}
}

function bool UpdateInfo(Object winObject)
{
	local PersonaInfoWindow winInfo;
	local string str;

	winInfo = PersonaInfoWindow(winObject);
	if (winInfo == None)
		return False;

	winInfo.SetTitle(itemName);
	winInfo.SetText(Description $ winInfo.CR() $ winInfo.CR());
//	winInfo.AppendText(Sprintf(RechargesLabel, RechargeAmount));

	// Print the number of copies
	str = CountLabel @ String(NumCopies);
	winInfo.AppendText(winInfo.CR() $ winInfo.CR() $ str);

	return True;
}

simulated function bool TestMPBeltSpot(int BeltSpot)
{
   return ( (BeltSpot >= 1) && (BeltSpot <=9) || (BeltSpot == 0) );
}

defaultproperties
{
    maxCopies=1
    bCanHaveMultipleCopies=True
    bActivatable=True
    ItemName="Automed"
    PlayerViewOffset=(X=30.00,Y=0.00,Z=-12.00),
    PlayerViewMesh=LodMesh'DeusExItems.Credits'
    PickupViewMesh=LodMesh'DeusExItems.Credits'
    ThirdPersonMesh=LodMesh'DeusExItems.Credits'
    LandSound=Sound'DeusExSounds.Generic.PlasticHit1'
    Icon=Texture'DeusExUI.UserInterface.AugIconHealing'
    M_Activated=""
    largeIconWidth=35
    largeIconHeight=49
    Description="s"
    beltDescription="AUTOMED"
    Mesh=LodMesh'DeusExItems.Credits'
    MultiSkins=Texture'DeusExUI.UserInterface.AugIconHealing_Small'
    CollisionRadius=7.00
    CollisionHeight=0.55
    Mass=10.00
    Buoyancy=100.00
}
