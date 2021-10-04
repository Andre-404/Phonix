var s = "No sound is currently playing";
var mG = 0, gG = s, oG = s, tP = s, tL = s;

mG = PhonixGetMasterGain();
draw_text(20, 20, string(mG));
if(PhonixValueIsValid(testID)){
	if(testID.group.name != "master") gG = PhonixGetGroupGain(testID.group);
	else gG = "This sound isn't part of a group";
	oG = testID.GetOutputGain();
	tP = testID.GetTrackPosition();
	tL = testID.GetLength();
}

draw_text(20, 20, "Master Gain: " + string(mG));
draw_text(20, 40, "Group Gain: " + string(gG));
draw_text(20, 60, "Output Gain: " + string(oG));
draw_text(20, 80, "Press mb_right to create a 3D sound at mouse coords");

draw_text(20, 120, "Press S to play a single pattern");
draw_text(20, 140, "Press Q to play a queue pattern");
draw_text(20, 160, "Press R to play a random pattern");
draw_text(20, 180, "Press SPACE to stop all sound");
draw_text(20, 200, "Press P to pause all sounds");
draw_text(20, 220, "Press U to resume all sounds");


//the below code is just for showcase and shouldn't really be used in practice
var arr = global.__phonixHandler.groups[$ "master"].childInstances;
for(var i = 0; i < array_length(arr); i++){
	var s = arr[i];
	if(s.Is3D() && !s.IsFinished()){
		var c = s.GetPosition();
		var f = s.GetFalloff();
		draw_set_color(c_green);
		draw_set_alpha(0.5);
		draw_circle(c[0], c[1], f[1], false);
		draw_set_alpha(1);
		draw_circle(c[0], c[1], f[0], false);
		draw_set_color(c_yellow);
		draw_rectangle(c[0]-5, c[1]-5, c[0]+5, c[1]+5, false);
		draw_set_color(c_white);
	}
}

