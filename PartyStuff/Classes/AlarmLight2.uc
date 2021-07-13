//=============================================================================
// AlarmLight.
//=============================================================================
class AlarmLight2 extends AlarmLight;

function Trigger(Actor Other, Pawn Instigator)
{
	if (!bIsOn)
	{
		bIsOn = True;
		SetLightColor(SkinColor);
		LightType = LT_Steady;
		bFixedRotationDir = True;
	}
	else
	{
		bIsOn = False;
		MultiSkins[1] = Texture'BlackMaskTex';
		LightType = LT_None;
		bFixedRotationDir = False;
	}
	Super.Trigger(Other, Instigator);
}

// if we are untriggered, turn us off
function UnTrigger(Actor Other, Pawn Instigator)
{
	if (bIsOn)
	{
		bIsOn = False;
		MultiSkins[1] = Texture'BlackMaskTex';
		LightType = LT_None;
		bFixedRotationDir = False;
	}

	Super.UnTrigger(Other, Instigator);
}

defaultproperties
{
}
