class BasketballMP extends ThrownProjectile;

var bool bDoomedToDestroy;
var bool bAlreadyScored;
var bool bAllowBumping;

simulated function Timer()
{
	if(!bAllowBumping)
	{
		bAllowBumping=True;
	}
	if (bDoomedToDestroy)
	{
		Destroy();
	}
	return;
}

simulated function Tick(float deltaTime)
{
	return;
}

simulated function TakeDamage(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name damageType)
{
	return;
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	return;
}

function Frob(Actor Frobber, Inventory frobWith)
{
	local BasketballMP4Player FLB4P;
	if (!bDoomedToDestroy)
	{
		FLB4P = Spawn(Class'BasketballMP4Player',Frobber,,Location,Rotation);
		DeusExPlayer(Frobber).FrobTarget = FLB4P;
		DeusExPlayer(Frobber).GrabDecoration();
		Super.Frob(Frobber, frobWith);
		Destroy();
	}
	else 
	{
		return;
	}
}

auto simulated state Flying
{
	simulated function HitWall(vector HitNormal, actor HitWall)
	{
		local float speed;
		
		Velocity = 0.8*((Velocity dot HitNormal) * HitNormal * (-2.0) + Velocity);
		speed = VSize(Velocity);
		bFixedRotationDir = True;
		RotationRate = RotRand(False);
		if ((speed > 0) && (speed < 30) && (HitNormal.Z > 0.7))
		{
			SetPhysics(PHYS_None, HitWall);
			if (Physics == PHYS_None)
				bFixedRotationDir = False;
		}
	
		if (HitWall.IsA('Mover'))
		{
			HitWall.TakeDamage(speed/58, Pawn(Owner), HitWall.Location, MomentumTransfer*Normal(Velocity), 'Shot');
		}
		
		else if (speed > 30)
		{	
			if ((FRand() >= 0.75) && (FRand() < 1.0))
			{
				PlaySound(sound'Bounce1', SLOT_None, 3);
			}
			else if ((FRand() >= 0.5) && (FRand() < 0.75))
			{
				PlaySound(sound'Bounce2', SLOT_None, 3);	
			}
			else
			{
				PlaySound(sound'Bounce3', SLOT_None, 3);	
			}
		}
	}
}

function bump(actor other)
{
local DeusExPlayer Player;
Player = DeusExPlayer(other);

	if((other.IsA('DeusExPlayer')))
	{
		if(bAllowBumping && Player.Inhand == None)
		{
			frob(Other,None);
		}
	}
}

simulated function BeginPlay()
{
	Super.BeginPlay();
}

defaultproperties
{
    bDisabled=True
    bExplodes=False
    bBlood=False
    bEmitDanger=False
    bIgnoresNanoDefense=True
    ItemName="Basketball"
    LifeSpan=0.00
    bDirectional=False
    Mesh=LodMesh'FLBasketball'
    DrawScale=0.71
    CollisionRadius=10.00
    CollisionHeight=10.00
    bBlockActors=True
    bBlockPlayers=True
    Mass=8.00
    Buoyancy=10.00
}
