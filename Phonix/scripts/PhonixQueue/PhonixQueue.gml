//Plays every sound in the assetArr in order that they are in the array,
//has optional fade in/out that applies to every sound in the queue

function __phonixQueuePattern(assetArr, _gain, _loop, _fadeIn, _fadeOut, _group) constructor{
	soundIDs = [];
	array_copy(soundIDs, 0, assetArr, 0, array_length(assetArr));
	gain = _gain;
	fadeInTimer = _fadeIn;
	fadeOutTimer = _fadeOut;
	group = _group;
	//if this is set to true when the queue finishes the last sound in the array, it will loop back to the first sound in the array
	loop = _loop;
	
	play = function(priority, _x, _y, _z, fo_ref, fo_max, fo_factor){
		var s = new __createQueuePatterStruct(soundIDs, gain, group, loop, fadeInTimer, fadeOutTimer, priority, [_x, _y, _z], [fo_ref, fo_max, fo_factor]);
		array_push(group.childInstances, s);
		return s;
		
	}
	
	
	__createQueuePatterStruct = function(soundArr, _gain, _group, _loop, _fadeIn, _fadeOut, _priority, coordArr, foArr) constructor{
		soundIDs = soundArr;
		sID = -1;
		curIndex = 0;
		sInd = soundIDs[curIndex];
		gain = _gain;
		loop = _loop;
		fadeInTimer = _fadeIn;
		fadeOutTimer = _fadeOut;
		group = _group;
		__phonixCommonVars(coordArr, foArr);
		queuePlayNext = true;
		priority = _priority;
		length = 0;
		
		update = function(){
			//don't play if we know that this sound is part of a transition,
			//but if there is not ID and were not finished and this sound isn't part of a transition, play the sound
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
					//when we stop completely the sound will be marked as finished
					if(stopping){
						finished = true;
						stopping = false;
					}else if(pausing){
						//if we aren't stopping, but rather pausing, don't mark the sound as finished
						pausing = false;
						paused = true;
						trackPausedTime = audio_sound_get_track_position(sCurID);
					}
				}
			}
			//automatic stopping
			if(length*1000 <= ((audio_sound_get_track_position(sCurID)*1000)+fadeOutTimer) && fading == 0){
				Stop(false);
				queuePlayNext = true;
			}
			
			if(finished) {
				//if were stopping intentonally, or we are stopping because of a transition, kill the struct
				if(!queuePlayNext || hasTransition){
					audio_stop_sound(sID);
					audio_emitter_free(emitter);
				}else if(!hasTransition){
					//if we don't have a transition, and we stopped naturally, then try to play the next sound in the queue
					audio_stop_sound(sID);
					if(curIndex < array_length(soundIDs)){
						//if there are sounds left in the array that haven't been played, play them, and remove the finished mark
						curIndex ++;
						finished = false;
						__play();
					}else if(loop){
						//if were looping and we have reached the end of the queue, loop back to the start
						curIndex = 0;
						finished = false;
						__play();
					}
				}
				//if we have satisfied neither condition, that we stopped intentionally, because of a transition,
				//or we have reached the end of the queue and we aren't looping, mark the struct as finished
				if(hasTransition) transitionSID.__play();
			}else if(paused && audio_is_playing(sID)){
				audio_pause_sound(sID);
			}
			
			if(finished) show_debug_message("finished");
			show_debug_message(audio_sound_get_gain(sID));
			
			
		}
		
		__play = function(){
			if(!is3D) {
				sCurID = audio_play_sound(soundIDs[curIndex], priority, false);
			}
			else{
				//Don't have to edit this even if there are multiple calls to __play() since there won't be a memory leak
				if(emitter == -1) emitter = audio_emitter_create();
				audio_emitter_position(emitter, x, y, z);
				audio_emitter_falloff(emitter, falloffArr[0], falloffArr[1], falloffArr[2]);
				sID = audio_play_sound_on(emitter, soundIDs[curIndex], false, priority);
			}
			length = audio_sound_length(sID);
			sInd = soundIDs[curIndex];
			__SetFadeIn();
			return self;
		}
		
		Stop = function(stopNow){
			if(!stopping){
				stopping = true;
				if(stopNow) fadeOutTimer = 0;
				__SetFadeOut();
				queuePlayNext = false;
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