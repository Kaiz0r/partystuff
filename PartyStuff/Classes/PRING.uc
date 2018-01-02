//=============================================================================
// PRing.   Copyright (C) 2002 Hejhujka & Luminous Path.
//=============================================================================
class PRing extends SphereEffect;

var float blastRadius;
var float size;

simulated function Tick(float deltaTime)
{

 Super.Tick(DeltaTime);

 DrawScale = 3.0 * size * (Default.LifeSpan - LifeSpan) / Default.LifeSpan;
 ScaleGlow = 0.75 * (LifeSpan / Default.Lifespan);

    }

defaultproperties
{
     size=5.000000
     LifeSpan=4.750000
     Skin=FireTexture'Effects.liquid.Virus_SFX'
}
