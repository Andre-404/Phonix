// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function __phonixCommonVars(coordsArr, foArr){
	type = "sound";
	//pausing and stopping
	pausing = false;
	paused = false;
	trackPausedTime = 0;
	stopping = false;
	finished = false;
	//handle gain
	fading = 0;//-1, 0 or 1
	startTime = 0;
	baseGain = 1;
	gainTarget = 1;
	gainRate = 0.1;
	finalGain = 1;
	
	//3D stuff
	emitter = -1;
	x = coordsArr[0];
	y = coordsArr[1];
	z = coordsArr[2];
	if(x != 0 || y != 0 || z != 0) is3D = true;
	falloffArr = foArr;
	//for when we use the PhonixTransition()
	hasTransition = false;
	transitionSID = -1;
	
	//Functions that are in every single type of  sound
	__SetFadeOut = function(){
		fading = -1;
		startTime = current_time;
		//audio_sound_gain(sID, 0, fadeOutTimer);
	}
	
	__SetFadeIn = function(){
		fading = 1;
		//audio_sound_gain(sID, 0, 0);
		startTime = current_time;
		//var _gain = overwriteGain == -1 ? soundGain*group.groupGain : overwriteGain;
		//audio_sound_gain(sID, _gain, fadeInTimer);
	}
		
	//handle gain
	gainTick = function(){
		var multiGain = 1;
		if(group.name != "master"){
			multiGain *= group.groupGain*global.phonixHandler.groups[$ "master"].groupGain;
		}else{
			multiGain *= group.groupGain;
		}
		
		if(fading == 1){
			if(fadeInTimer > 0){
				var p = (current_time-startTime)/fadeInTimer;
				multiGain *= clamp(p, 0, 1);
				if(p >= 1) fading = 0;
			}
		}else if(fading == -1){
			if(fadeOutTimer > 0){
				var p = (current_time-startTime)/fadeInTimer;
				multiGain *= clamp(1-p, 0, 1);
				if(p >= 1) {
					fading = 0;
					if(stopping) {
						//if were stopping then mark the sound as finished
						finished = true;
						stopping = false;
					}
					else if(pausing) {
						//if were only pausing don't mark the sound as finished
						pausing = false;
						paused = true;
						trackPausedTime = audio_sound_get_track_position(sID);
					}
				}
			}else{
				if(stopping) {
					//if were stopping then mark the sound as finished
					finished = true;
					stopping = false;
				}
				else if(pausing) {
					//if were only pausing don't mark the sound as finished
					pausing = false;
					paused = true;
					trackPausedTime = audio_sound_get_track_position(sID);
				}
			}
		}
		
		baseGain += clamp(gainTarget - baseGain, -gainRate, gainRate);
		
		finalGain = baseGain*multiGain;
		
		audio_sound_gain(sID, finalGain*audio_sound_get_gain(sInd), PHONIX_TICK_TIME);
	}
	
	IsFinished = function(){
		return finished;
	}
	
	IsStopping = function(){
		return stopping;
	}
	
	Is3D = function(){
		return is3D;
	}
	
	IsPaused = function(){
		return paused;
	}
	
	GetLength = function(){
		//in seconds
		return length;
	}
	
	GetTrackPosition = function(){
		if(finished) exit;
		return audio_sound_get_track_position(sID);
	}
	
	GetPosition = function(){
		if(finished) exit;
		return [x, y, z];
	}
	
	SetTrackPosition = function(time){
		if(finished) exit;
		//time has to be in seconds
		audio_sound_set_track_position(sID, time);
	}
	
	SetPosition = function(_x, _y, _z){
		//Only set the position if the sound isn't finished and if this is a 3D sound
		if(finished) exit;
		if(!is3D) PhonixTrace("Trying to set a position for a sound that isn't 3D");
		x = _x;
		y = _y;
		z = _z;
		audio_emitter_position(emitter, _x, _y, _z);
	}
	
	SetFalloff = function(falloff_ref, falloff_max, falloff_factor){
		//Only set the falloff if the sound isn't finished and if this is a 3D sound
		if(finished) exit;
		if(!is3D) PhonixTrace("Trying to set a position for a sound that isn't 3D");
		falloffArr = [falloff_ref, falloff_max, falloff_factor];
		audio_emitter_falloff(emitter, falloffArr[0], falloffArr[1], falloffArr[2]);
	}
		
	SetGain = function(gain, rate, applyGroupGain = true){
		if(finished) exit;
		//rate should be between 0 and 1
		gainTarget = gain;
		gainRate = rate;
		
	}
		
	GetGain = function(){
		if(finished) exit;
		return baseGain;
	}
	
	GetOutputGain = function(){
		if(finished) exit;
		return finalGain;
	}
	
	GetSoundIndex = function(){
		if(sID == -1) return -1;
		return sID;
	}
	
	GetAssetIndex = function(){
		return sInd;
	}
	
}

function __phonixConvertTime(time, timeType){
	switch(timeType){
		case PhonixTimeType.frames: m = 1/60*1000; break;
		case PhonixTimeType.miliseconds: m = 1; break;
		case PhonixTimeType.seconds: m = 1000; break;
	}
	return time*m;
}

function PhonixTrace(s){
	show_error(s, false);
}
