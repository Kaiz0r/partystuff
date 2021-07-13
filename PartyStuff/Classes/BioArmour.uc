//=============================================================================
// AdaptiveArmor.
//=============================================================================
class BioArmour extends PGArmour;

simulated function bool TestMPBeltSpot(int BeltSpot)
{
   return ( (BeltSpot >= 1) && (BeltSpot <=9) );
}
defaultproperties
{
    Dur=100
    Def=10
    bResistPoison=True
    ItemName="Bio Armour"
    beltDescription="BIO"
}
