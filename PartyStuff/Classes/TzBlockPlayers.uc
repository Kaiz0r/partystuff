//=============================================================================
// TzBlockPlayers.
//=============================================================================		
class TzBlockPlayers extends Trigger;		

var() vector KickVelocity;
var() name KickedClasses;
var() bool bKillVelocity;
var() bool bRandomize;

simulated function Touch( actor Other )
{
	local Actor A;

	if ( !Other.IsA(KickedClasses) )
		return;
	PendingTouch = Other.PendingTouch;
	Other.PendingTouch = self;
	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Other, Other.Instigator );
}

simulated function PostTouch( actor Other )
{
	local bool bWasFalling;
	local vector Push;
	local float PMag;

	bWasFalling = ( Other.Physics == PHYS_Falling );
	if ( bKillVelocity )
		Push = -1 * Other.Velocity;
	else
		Push.Z = -1 * Other.Velocity.Z;
	if ( bRandomize )
	{
		PMag = VSize(KickVelocity);
		Push += PMag * Normal(KickVelocity + 0.5 * PMag * VRand());
	}
	else
		Push += KickVelocity;
	Other.SetPhysics(PHYS_Falling);
	Other.Velocity += Push;
}

defaultproperties
{
     KickedClasses=DeusExPlayer
     bDirectional=True
}
