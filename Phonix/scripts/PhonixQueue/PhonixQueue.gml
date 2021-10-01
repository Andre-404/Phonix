function __phonixQueuePattern(assetArr, _gain, _loop, _is3D, _fadeIn, _fadeOut, _group) constructor{
	soundIDs = assetArr;
	gain = _gain;
	is3D = _is3D;
	fadeInTimer = _fadeIn;
	fadeOutTimer = _fadeOut;
	group = _group;
	loop = _loop;
	
	play = function(priority, _x = 0, _y = 0, _z = 0, fo_ref = 50, fo_max = 100, fo_factor = 1){
		var s = new __createQueuePatterStruct(soundIDs, gain, group, loop, is3D, fadeInTimer, fadeOutTimer, priority, [_x, _y, _z], [fo_ref, fo_max, fo_factor]);
		array_push(group.sounds, s);
		return s;
		
	}
	
	
	__createQueuePatterStruct = function(soundArr, _gain, _group, _loop, _is3D, _fadeIn, _fadeOut, _priority, coordArr, foArr) constructor{
		soundIDs = soundArr;
		sCurID = -1;
		curIndex = 0;
		gain = _gain;
		loop = _loop;
		is3D = _is3D;
		fadeInTimer = _fadeIn;
		fadeOutTimer = _fadeOut;
		group = _group;
		__phonixCommonVars(coordArr, foArr);
		queuePlayNext = true;
		priority = _priority;
		length = 0;
		
		update = function(){
			//don't play if we know that this sound is part of a transition
			if(sCurID == -1 && !finished && !hasTransition) __play();
		
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
						trackPausedTime = audio_sound_get_track_position(sCurID);
					}
				}
			}
			//automatic stopping
			if(length*1000 <= ((audio_sound_get_track_position(sCurID)*1000)+fadeOutTimer) && fading == 0){
				Stop();
				queuePlayNext = true;
			}
			
			if(finished) {
				if(!queuePlayNext || hasTransition){
					audio_stop_sound(sCurID);
					audio_emitter_free(emitter);
				}else if(!hasTransition){
					audio_stop_sound(sCurID);
					if(curIndex < array_length(soundIDs)){
						curIndex ++;
						finished = false;
						__play();
					}else if(loop){
						curIndex = 0;
						finished = false;
						__play();
					}
				}
				if(hasTransition) transitionSID.__play();
			}else if(paused && IsPlaying(sCurID)){
				audio_pause_sound(sCurID);
			}
			
			if(finished) show_debug_message("finished");
			show_debug_message(audio_sound_get_gain(sCurID));
			
			
		}
		
		__play = function(){
			if(!is3D) {
				sCurID = audio_play_sound(soundIDs[curIndex], priority, false);
			}
			else{
				if(emitter == -1) emitter = audio_emitter_create();
				audio_emitter_position(emitter, x, y, z);
				audio_emitter_falloff(emitter, falloffArr[0], falloffArr[1], falloffArr[2]);
				sCurID = audio_play_sound_on(emitter, soundIDs[curIndex], false, priority);
			}
			length = audio_sound_length(sCurID);
			__SetFadeIn();
			return self;
		}
	
		__SetFadeIn = function(){
			fading = 1;
			audio_sound_gain(sCurID, 0, 0);
			var _gain = overwriteGain == -1 ? gain*group.groupGain*global.phonixHandler.masterGain : overwriteGain;
			audio_sound_gain(sCurID, _gain, fadeInTimer);
		}
	
		__SetFadeOut = function(){
			fading = -1;
			audio_sound_gain(sCurID, 0, fadeOutTimer);
		}
		
		Stop = function(){
			if(!stopping){
				stopping = true;
				__SetFadeOut();
				queuePlayNext = false;
			}
		}
		
		Pause = function(){
			pausing = true;
			__SetFadeOut();
		}
	
		Unpause = function(){
			if(!pausing && paused){
				audio_resume_sound(sCurID);
				paused = false;
				__SetFadeIn();
				audio_sound_set_track_position(sCurID, trackPausedTime);
			}
		
		}
		
		
		
		
	}
}