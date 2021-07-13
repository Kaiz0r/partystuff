class DontMove extends Actor;

function PostBeginPlay(){
  setTimer(1, false);
}

function Timer(){
	local Switch1 sw1;
	local Switch2 sw2;
	local Button1 b1;
	local Seat se;
	
  foreach AllActors(class'Switch1', sw1) sw1.bmovable = False;
  foreach AllActors(class'Switch2', sw2) sw2.bmovable = False;
  foreach AllActors(class'Button1', b1) b1.bmovable = False;
  foreach AllActors(class'Seat', se) { se.bmovable = False; se.bInvincible = True; }
  Destroy();
}

defaultproperties
{
	bHidden=True
}
