//=============================================================================
// DeusExDecal
//=============================================================================
class AveDecal extends Decal
	abstract;

var bool bAttached, bStartedLife, bImportant;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(1.0, false);
}

function ReattachDecal(optional vector newrot)
{
	DetachDecal();
	if (newrot != vect(0,0,0))
		AttachDecal(32, newrot);
	else
		AttachDecal(32);
}

defaultproperties
{
    bAttached=True
    bImportant=True
}
