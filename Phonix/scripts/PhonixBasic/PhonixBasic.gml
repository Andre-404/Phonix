function __phonixSinglePattern(_asset, _gain, _is3D, _fadeIn, _fadeOut, _group) constructor{
	gain = _gain;
	is3D = _is3D;
	soundIndex = _asset;
	group = _group;
	fadeInTimer = _fadeIn;
	fadeOutTimer = _fadeOut;
	
	
	play = function(priority, _x = 0, _y = 0, _z = 0, fo_ref = 50, fo_max = 100, fo_factor = 1){
		var s = new __createSinglePatternStruct(gain, group, soundIndex, is3D, fadeInTimer, fadeOutTimer, priority, [_x, _y, _z], [fo_ref, fo_max, fo_factor]);
		array_push(group.sounds, s);
		return s;
	}
	
	__createSinglePatternStruct = function(gain, _group, _sIndex, _is3D, _fadeIn, _fadeOut, _priority, coordArr, foArr) constructor{
		sID = -1;
		sInd = _sIndex;
		fadeInTimer = _fadeIn;
		fadeOutTimer = _fadeOut;
		length = audio_sound_length(sInd);
		is3D = _is3D;
		priority = _priority;
		soundGain = gain;
		group = _group;
		__phonixCommonVars(coordArr, foArr);
		
		update = function(){
			//don't play if we know that this sound is part of a transition
			if(sID == -1 && !finished && !hasTransition) __play();
		
			//fading stuff
			if(fading == 1){
				timer += delta_time/1000;
				if(timer >= fadeInTimer){
					fading = 0;
					timer = 0;
				}
			}else if(fading == -1){
				timer += delta_time/1000;
				if(timer >= fadeOutTimer){
					fading = 0;
					timer = 0;
					if(stopping){
						finished = true;
						stopping = false;
					}else if(pausing){
						pausing = false;
						paused = true;
						trackPausedTime = audio_sound_get_track_position(sID);
					}
				}
			}
			//automatic stopping
			if(length*1000 <= ((audio_sound_get_track_position(sID)*1000)+fadeOutTimer) && fading == 0){
				Stop();
			}
			
			if(finished) {
				audio_stop_sound(sID);
				audio_emitter_free(emitter);
				if(hasTransition) transitionSID.__play();
			}else if(paused && IsPlaying(sID)){
				audio_pause_sound(sID);
			}
		
			if(finished) show_debug_message("finished");
			show_debug_message(audio_sound_get_gain(sID));
		}
		
		__play = function(){
			if(!is3D) {
				sID = audio_play_sound(sInd, priority, false);
			}
			else{
				if(emitter == -1) emitter = audio_emitter_create();
				audio_emitter_position(emitter, x, y, z);
				audio_emitter_falloff(emitter, falloffArr[0], falloffArr[1], falloffArr[2]);
				sID = audio_play_sound_on(emitter, sInd, false, priority);
			}
			__SetFadeIn();
			return self;
		}
	
		__SetFadeIn = function(){
			fading = 1;
			audio_sound_gain(sID, 0, 0);
			var _gain = overwriteGain == -1 ? soundGain*group.groupGain*global.phonixHandler.masterGain : overwriteGain;
			audio_sound_gain(sID, _gain, fadeInTimer);
		}
	
		__SetFadeOut = function(){
			fading = -1;
			audio_sound_gain(sID, 0, fadeOutTimer);
		}
		
		Stop = function(){
			if(!stopping){
				stopping = true;
				__SetFadeOut();
			}
		}
		
		Pause = function(){
			pausing = true;
			__SetFadeOut();
		}
	
		Unpause = function(){
			if(!pausing && paused){
				audio_resume_sound(sID);
				paused = false;
				__SetFadeIn();
				audio_sound_set_track_position(sID, trackPausedTime);
			}
		
		}
		
	}
}