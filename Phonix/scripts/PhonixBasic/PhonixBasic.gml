//Plays a single sound with a optional fade in/out

function __phonixSinglePattern(_asset, _loop, _fadeIn, _fadeOut, _group) constructor{
	soundIndex = _asset;
	group = _group;
	fadeInTimer = _fadeIn;
	fadeOutTimer = _fadeOut;
	loop = _loop;
	
	
	play = function(priority, _x, _y, _z, fo_ref, fo_max, fo_factor){
		var s = new __createSinglePatternStruct(group, loop, soundIndex, fadeInTimer, fadeOutTimer, priority, [_x, _y, _z], [fo_ref, fo_max, fo_factor]);
		array_push(group.childInstances, s);
		return s;
	}
}

function __createSinglePatternStruct(_group, _loop, _sIndex, _fadeIn, _fadeOut, _priority, coordArr, foArr) constructor{
	sID = -1;
	sInd = _sIndex;
	fadeInTimer = _fadeIn;
	fadeOutTimer = _fadeOut;
	length = audio_sound_length(sInd);
	priority = _priority;
	group = _group;
	__phonixCommonVars(coordArr, foArr);
	loops = _loop;
		
	update = function(){
		//don't play if we know that this sound is part of a transition
		if(sID == -1 && !finished && !hasTransition) __play();
		gainTick();
		//automatic stopping
		var l = (audio_sound_get_track_position(sID)*1000)+fadeOutTimer;
		if((length*1000)-l <= PHONIX_TICK_TIME*2 && fading == 0 && !loops){
			Stop(false);
		}
			
		if(finished) {
			audio_stop_sound(sID);
			audio_emitter_free(emitter);
			if(hasTransition && transitionSID != -1) transitionSID.__play();
		}else if(paused && audio_is_playing(sID)){
			audio_pause_sound(sID);
		}
	}
		
	__play = function(){
		if(!is3D) {
			sID = audio_play_sound(sInd, priority, loops);
		}
		else{
			if(emitter == -1) emitter = audio_emitter_create();
			audio_emitter_position(emitter, x, y, z);
			audio_emitter_falloff(emitter, falloffArr[0], falloffArr[1], falloffArr[2]);
			sID = audio_play_sound_on(emitter, sInd, loops, priority);
		}
		__SetFadeIn();
		return self;
	}
		
	Stop = function(stopNow){
		if(!stopping){
			stopping = true;
			if(stopNow) fadeOutTimer = 0;
			__SetFadeOut();
		}
	}
}