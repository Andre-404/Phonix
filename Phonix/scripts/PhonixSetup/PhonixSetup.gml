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
	applyGroupGain = true;
	
	pitch = 1;
	pitchRate = 0.1;
	pitchTarget = 1;
	
	//3D stuff
	emitter = -1;
	x = coordsArr[0];
	y = coordsArr[1];
	z = coordsArr[2];
	if(x != 0 || y != 0 || z != 0) is3D = true;
	else is3D = false;
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
		
	Pause = function(){
		if(stopping) exit;
		pausing = true;
		__SetFadeOut();
	}
		
	Resume = function(){
		if(stopping) exit;
		if(!pausing && paused){
			audio_resume_sound(sID);
			paused = false;
			__SetFadeIn();
			audio_sound_set_track_position(sID, trackPausedTime);
		}
	}
		
	//handle gain
	gainTick = function(){
		var multiGain = 1;
		//If this sound is part of a group that isn't "master" then take both the group and the master gain into account
		if(group.name != "master" && applyGroupGain){
			multiGain *= group.groupGain*global.__phonixHandler.groups[$ "master"].groupGain;
		}else{
			multiGain *= group.groupGain;
		}
		
		if(fading == 1){
			//startTime is the time at which we started fading in/out and == current_time at that moment
			if(fadeInTimer > 0){
				var p = (current_time-startTime)/fadeInTimer;
				multiGain *= clamp(p, 0, 1);
				if(p >= 1) fading = 0;
			}else fading = 0;
			
		}else if(fading == -1){
			if(fadeOutTimer > 0){
				var p = (current_time-startTime)/fadeInTimer;
				multiGain *= clamp(1-p, 0, 1);
				//bit of a hack to check if were done fading
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
				//this is for when we don't have a fade out setup
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
		
		//gain target and rate can be modified by the SetGain() method
		baseGain += clamp(gainTarget - baseGain, -gainRate, gainRate);
		//pitch tarhet and rate specified can be set in SetPitch() method
		pitch += clamp(pitchTarget - pitch, -pitchRate, pitchRate);
		
		finalGain = baseGain*multiGain;
		
		audio_sound_gain(sID, finalGain*audio_sound_get_gain(sInd), PHONIX_TICK_TIME);
		audio_sound_pitch(sID, pitch);
	}
	
	//getters
	
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
		
	GetFalloff = function(){
		//Only set the falloff if the sound isn't finished and if this is a 3D sound
		if(finished) exit;
		if(!is3D) __phonixTrace("Trying to set a position for a sound that isn't 3D");
		return falloffArr;
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
	
	GetPitch = function(){
		return pitch;
	}
		
	//Setters
	SetTrackPosition = function(time){
		if(finished) exit;
		//time has to be in seconds
		audio_sound_set_track_position(sID, time);
	}
	
	SetPosition = function(_x, _y, _z = 0){
		//Only set the position if the sound isn't finished and if this is a 3D sound
		if(finished) exit;
		if(!is3D) __phonixTrace("Trying to set a position for a sound that isn't 3D");
		x = _x;
		y = _y;
		z = _z;
		audio_emitter_position(emitter, _x, _y, _z);
	}
	
	SetFalloff = function(falloff_ref, falloff_max, falloff_factor){
		//Only set the falloff if the sound isn't finished and if this is a 3D sound
		if(finished) exit;
		if(!is3D) __phonixTrace("Trying to set a position for a sound that isn't 3D");
		falloffArr = [falloff_ref, falloff_max, falloff_factor];
		audio_emitter_falloff(emitter, falloffArr[0], falloffArr[1], falloffArr[2]);
	}
	
	SetGainTarget = function(_gainTarget, rate, _applyGroupGain = true){
		if(finished) exit;
		//rate should be between 0 and 1
		gainTarget = _gainTarget;
		gainRate = rate;
		applyGroupGain = _applyGroupGain;
		
	}
		
	SetGain = function(_gain){
		baseGain = _gain;
	}
		
	SetPitchTarget = function(_pitch, rate){
		pitchTarget = _pitch;
		pitchRate = rate;
	}
		
	SetPitch = function(_pitch){
		pitch = _pitch;
	}
}

function __phonixTrace(s){
	show_error(s, false);
}

