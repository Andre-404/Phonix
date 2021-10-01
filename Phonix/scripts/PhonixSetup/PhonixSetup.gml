// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function __phonixCommonVars(coordsArr, foArr){
	pausing = false;
	paused = false;
	trackPausedTime = 0;
	stopping = false;
	finished = false;
	fading = 0;//-1, 0 or 1
	timer = 0;
	overwriteGain = -1;
	//3D stuff
	emitter = -1;
	x = coordsArr[0];
	y = coordsArr[1];
	z = coordsArr[2];
	falloffArr =foArr;
	//for when we use the PhonixTransition()
	hasTransition = false;
	transitionSID = -1;

}

function __phonixConvertTime(time, timeType){
	switch(timeType){
		case PhonixTimeType.frames: m = 1/60*1000; break;
		case PhonixTimeType.miliseconds: m = 1; break;
		case PhonixTimeType.seconds: m = 1000; break;
	}
	return time*m;
}