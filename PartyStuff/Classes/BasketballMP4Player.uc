class BasketballMP4Player extends DeusExDecoration;

event BaseChange()
{
	local BasketballMP AdvB;
	if (bWasCarried)
	{
		AdvB = Spawn(Class'BasketballMP',Owner,,Location,Rotation);
		AdvB.Velocity = Velocity + 0.7 * Owner.Velocity;
		AdvB.SetTimer(0.5,False);
		Destroy();
	}
}

defaultproperties
{
    bInvincible=True
    ItemName="Basketball"
    Mesh=LodMesh'FLBasketball'
    DrawScale=0.71
    CollisionRadius=10.00
    CollisionHeight=10.00
    bBounce=True
    Mass=8.00
    Buoyancy=10.00
}
