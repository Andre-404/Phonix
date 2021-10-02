//plays a random sound from the given sound array
function __phonixRandomPattern(assetArr, _gain, _fadeIn, _fadeOut, _group) constructor{
	soundIDs = [];
	array_copy(soundIDs, 0, assetArr, 0, array_length(assetArr));
	gain = _gain;
	fadeInTimer = _fadeIn;
	fadeOutTimer = _fadeOut;
	group = _group;
	
	play = function(priority, _x, _y, _z, fo_ref, fo_max, fo_factor){
		var r = irandom(array_length(soundIDs)-1);
		var s = new __createSinglePatternStruct(gain, group, soundIDs[r], fadeInTimer, fadeOutTimer, priority, [_x, _y, _z], [fo_ref, fo_max, fo_factor]);
		array_push(group.childInstances, s);
		return s;
	}
	
	__createSinglePatternStruct = function(gain, _group, _sIndex, _fadeIn, _fadeOut, _priority, coordArr, foArr) constructor{
		sID = -1;
		sInd = _sIndex;
		fadeInTimer = _fadeIn;
		fadeOutTimer = _fadeOut;
		length = audio_sound_length(sInd);
		is3D = false;
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
					//if were stopping then mark the sound as finished
					if(stopping){
						finished = true;
						stopping = false;
					}else if(pausing){
						//if were only pausing don't mark the sound as finished
						pausing = false;
						paused = true;
						trackPausedTime = audio_sound_get_track_position(sID);
					}
				}
			}
			//automatic stopping
			if(length*1000 <= ((audio_sound_get_track_position(sID)*1000)+fadeOutTimer) && !stopping){
				Stop(false);
			}
			
			if(finished) {
				audio_stop_sound(sID);
				audio_emitter_free(emitter);
				if(hasTransition) transitionSID.__play();
			}else if(paused && audio_is_playing(sID)){
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
		
		Stop = function(stopNow){
			if(!stopping){
				stopping = true;
				if(stopNow) fadeOutTimer = 0;
				__SetFadeOut();
			}
		}
		
		Pause = function(){
			if(stopping) exit;
			pausing = true;
			__SetFadeOut();
		}
	
		Unpause = function(){
			if(stopping) exit;
			if(!pausing && paused){
				audio_resume_sound(sID);
				paused = false;
				__SetFadeIn();
				audio_sound_set_track_position(sID, trackPausedTime);
			}
		
		}
		
	}
}