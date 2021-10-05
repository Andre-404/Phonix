
function __phonixLoopPattern(_intro, _loop, _outro, _fadeIn, _fadeOut, _group) constructor{
	intro = _intro;
	loop = _loop;
	outro = _outro;
	
	group = _group;
	fadeInTimer = _fadeIn;
	fadeOutTimer = _fadeOut;
	
	waitToPlayOutro = true;
	
	play = function(priority, _x, _y, _z, fo_ref, fo_max, fo_factor){
		var s =  new _phonixLoopPatternStruct([intro, loop, outro], priority, fadeInTimer, fadeOutTimer, group, [_x, _y, _z], [fo_ref, fo_max, fo_factor], waitToPlayOutro);
		array_push(group.childInstances, s);
		return s;
	}
}

function _phonixLoopPatternStruct(soundsArr, _priority, fadeIn, fadeOut, _group, coordArr, falloffArr, _wait) constructor{
	//here we store the gms2 audio asset indexes
	soundIndexes = soundsArr;
	intro = soundsArr[0];
	loop = soundsArr[1];
	outro = soundsArr[2];
	index = 0;
	
	//here we'll store the unique sound ID recieved from audio_sound_play() in order to fade them properly
	soundIDs = [];
	sID = -1;
	sInd = soundIndexes[index];
	
	
	priority = _priority;
	fadeInTimer = fadeIn;
	fadeOutTimer = fadeOut;
	group = _group;
	__phonixCommonVars(coordArr, falloffArr);
	
	//Whether to wait until the intro/main loop track position reaches the end to play the outro
	waitToPlayOutro = _wait;
	
	
	update = function(){
		//don't play if we know that this sound is part of a transition
		if(sID == -1 && !finished && !hasTransition) __play();
		
		gainTick();
		//automatic stopping
		var l = (audio_sound_get_track_position(sID)*1000)+ (sInd == outro ? fadeOutTimer : 0);
		if(((length*1000)-l)/pitch <= PHONIX_TICK_TIME*2 && fading == 0){
			
			//the soundChange var is explained below
			var soundChange = false;
			//The PHONIX_TICK_TIME*2 is a handpicked value that I think suits best
			if(sInd == intro){
				//this will play the main loop part
				if(!stopping) index ++;
				else index = 2;
				audio_sound_gain(sID, 0, PHONIX_TICK_TIME*2);
				soundChange = true;
				stopping = false;
			}else if(sInd == loop && stopping){
				//If we're playing the main loop and we're stopping(meaning that waitToPlayOutro is true), play the outro
				stopping = false;
				index ++;
				audio_sound_gain(sID, 0, PHONIX_TICK_TIME*2);
				soundChange = true;
			}else if(sInd == outro){
				//if we're playing the outro, and the outro is finished, we want to fade out of it 
				Stop(false);
			}
			//We have to call __play() AFTER if chain, since it changed the sInd variable which we are checking inside the chain
			if(soundChange) __play();
		}
		
		for(var i = 0; i < array_length(soundIDs); i++){
			s = soundIDs[i];
			//bit of a hack, we know that the only sound that should be playing is the one that was added last
			//so we stop those that have been added before
			if(audio_is_playing(s) && i < array_length(soundIDs)-1) audio_stop_sound(s);
		}
		
		//once finished, stop the sound and if there is a transition, play it
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
			sID = audio_play_sound(soundIndexes[index], priority, index == 1);
		}
		else{
			//Don't have to edit this even if there are multiple calls to __play() since there won't be a memory leak
			if(emitter == -1) emitter = audio_emitter_create();
			audio_emitter_position(emitter, x, y, z);
			audio_emitter_falloff(emitter, falloffArr[0], falloffArr[1], falloffArr[2]);
			sID = audio_play_sound_on(emitter, soundIndexes[index], index == 1, priority);
		}
		length = audio_sound_length(sID);
		//A little hack where we set the beginning gain to something that's not 0
		//this way when transitioning between sounds there isn't a "hole" where there's nothing playing
		audio_sound_gain(sID, baseGain*__applyGroupGain()/2, PHONIX_TICK_TIME);//handpicked value
		//this is for keeping track of the intro, loop and outro unique sound IDs
		array_push(soundIDs, sID);
		sInd = soundIndexes[index];
		//only set a fade in for the intro
		if(index == 0) __SetFadeIn();
	}
	
	Stop = function(stopNow){
		if(!stopping){
			if(stopNow){
				//Stop immediately without playing the outro
				stopping = true;
				fadeOutTimer = 0;
				__SetFadeOut();
			}else{
				//if waitToPlayOutro is true, we will wait until the current sound gets to the end of its track position, and then play the outro
				//we also check if the currently playing audio isn't the outro, since we don't want to be stuck in a loop of playing outros
				if(sInd != outro && waitToPlayOutro) stopping = true;
				else{
					//if we're currently playing either the intro or the main loop, play the outro
					if(sInd != outro){
						index = 2;
						audio_sound_gain(sID, 0, PHONIX_TICK_TIME*2);
						__play();
					}else{
						//if the currently playing audio is the outro, we want to fade out of it
						stopping = true;
						__SetFadeOut();
					}
				}
			}
		}
	}
	
}