class AllySpawnPoint extends Actor;

var() string AllyGroup;
var DXScriptedPawn SpawnedAlly;
var() int Cooldown;
var bool bCooling;

function Timer()
{
	bCooling=False;
}

defaultproperties
{
    Cooldown=255
    bHidden=True
}
