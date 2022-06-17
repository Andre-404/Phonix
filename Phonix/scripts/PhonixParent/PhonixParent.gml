function __phonixPatternParent() constructor{
	soundID = -1;//decided per pattern
	playingSound = -1;
	group = "master";
	__isValidPhonixStruct = true;//GML is shit so in order to check if a struct is a phonix struct we check if it contains this variable
	
	//both are in ms
	trackPos = 0;
	trackLen = 0;
	
	
	//since stopping and pausing isn't immediate, we need to track what the sound is currently doing
	state = __phonixState.none;
	nextState = -1;
	stateTransTimer = 0;
	
	pitch = 1;
	baseGain = 1;
	gainMultiplier = 0;//starting sound is completely quiet
	gainIncrement = 0;//for fading in/out, affects gainMultiplier
	priority = 1;//overriden in patterns
	
	//if emitterInfo isn't -1 it's an indication that this is a 3d sound
	emitterInfo = -1;
	emitter = -1;
	
	//public functions
	getSoundIndex = function(){ return soundID; }
	isPlaying = function() { return state == __phonixState.playing }
	isPaused = function() {return state == __phonixState.paused }
	
	getTrackPos = function() { return trackPos; }
	setTrackPos = function(_trackPos) { 
		trackPos = _trackPos;
		if(state != __phonixState.none) audio_sound_set_track_position(playingSound, trackPos/1000);
		return self;
	}
	
	getTrackLen = function() { return trackLen; }
	
	getPitch = function() {return pitch; }
	setPitch = function(_pitch) { 
		pitch = _pitch; 
		return self;
	}
	
	getGain = function() { return baseGain; }
	setGain = function(_gain) { 
		baseGain = _gain; 
		return self;
	}
	
	getWorldPos = function(){
		if(emitterInfo == -1) return undefined;
		var arr = [];
		array_copy(arr, 0, emitterInfo, 0, 3);
		return arr;
	}
	getFalloff = function(){
		if(emitterInfo == -1) return undefined;
		var arr = [];
		array_copy(arr, 0, emitterInfo, 2, 3);
		return arr;
	}
	setEmitterInfo = function(_x, _y, _z = 0, _falloffRefDist = PHONIX_DEFAULT_FALLOFF_REFERENCE, _falloffMaxDist = PHONIX_DEFAULT_FALLOFF_MAX, _falloffFactor = PHONIX_DEFAULT_FALLOFF_FACTOR){
		emitterInfo = array_create(6, 0);
		emitterInfo[0] = _x;
		emitterInfo[1] = _y;
		emitterInfo[2] = _z;
		emitterInfo[3] = _falloffRefDist;
		emitterInfo[4] = _falloffMaxDist;
		emitterInfo[5] = _falloffFactor;
		if(emitter != -1){
			audio_emitter_falloff(emitter, emitterInfo[3], emitterInfo[4], emitterInfo[5]);
			audio_emitter_position(emitter, emitterInfo[0], emitterInfo[1], emitterInfo[2]);
		}
		return self;
	}
	
	//private functions
	__getGroupGain = function(){
		return global.__phonixHandler.__GetGroupGain(group);
	}
		
	__parentUpdate = function(){
		stateTransTimer -= (delta_time/1000);//to avoid lag
		if(nextState != -1 && stateTransTimer <= 0){
			__changeState();
		}
		if(state == __phonixState.none) return;
		if(trackPos >= trackLen && state != __phonixState.none){
			__reset();
			state = __phonixState.none;
			return;
		}
		//the value of gainIncrement is how much should the gain change each *milisecond*
		gainMultiplier = clamp(gainMultiplier + gainIncrement*(delta_time/1000), 0, 1);
		trackPos = audio_is_playing(playingSound) ? audio_sound_get_track_position(playingSound)*1000 : trackPos//in ms
		audio_sound_gain(playingSound, min(baseGain*gainMultiplier*__getGroupGain()*audio_sound_get_gain(soundID), 1), PHONIX_TICK_TIME);
		audio_sound_pitch(playingSound, pitch);
		if(emitter != -1){
			audio_emitter_position(emitter, emitterInfo[0], emitterInfo[1], emitterInfo[2]);
			audio_emitter_falloff(emitter, emitterInfo[3], emitterInfo[4], emitterInfo[5]);
		}
	}
	
	//these function can, but don't have to be overwritten in patterns to achieve some behaviour
	__playAudio = function() {
		//doing this check because .play() doesn't have any restrictions
		if(state == __phonixState.stopping || state == __phonixState.playing) return;
		if(state == __phonixState.paused){
			audio_resume_sound(playingSound);
			return;
		}
		ds_list_add(global.__phonixHandler.sounds, self);
		if(emitterInfo == -1){
			playingSound = audio_play_sound(soundID, priority, false);
		}else{
			if(emitter == -1) emitter = audio_emitter_create();
			playingSound = audio_play_sound_on(emitter, soundID, false, priority);
		}
		//doing this here because there is a 2 frame delay between this and the update method first being called
		//during this time the sound is abnormaly loud, and this is used to prevent that
		audio_sound_gain(playingSound, min(baseGain*gainMultiplier*__getGroupGain()*audio_sound_get_gain(soundID), 1), 0);
		audio_sound_pitch(playingSound, pitch);
	}
	__pauseAudio = function() {
		audio_pause_sound(playingSound);
	}
	__stopAudio = function() {
		audio_stop_sound(playingSound);
		__reset();
	}
	__reset = function(){
		playingSound = -1;
		gainMultiplier = 0;
		gainIncrement = 0;
	}
	__delete = function(){
		if(emitter != -1) {
			audio_emitter_free(emitter);
			emitter = -1;
		}
		//shouldn't be needed, but just in case we got any lingering sounds(not stopping them here would make them unreachable)
		if(playingSound != -1 && (audio_is_playing(playingSound) || audio_is_paused(playingSound))) {
			audio_stop_sound(playingSound);
			playingSound = -1;
		}
	}
		
	
	__changeState = function(timer = 0){
		switch(nextState){
			case __phonixState.playing:{
				//we start playing the sound, when gainMultiplier reaches 1(and fade in timer < 0) we go into the playing state
				//__playAudio is above state = nextState because it relies on the current state to decide whether to unpause/play a song from start
				__playAudio();
				state = nextState;
				nextState = -1;
				gainIncrement = (timer == 0 ? 1 : 1/timer);
				break;
			}
			case __phonixState.none:{
				state = nextState;
				nextState = -1;
				__stopAudio();
				break;
			}
			case __phonixState.stopping:{
				//in this phase we slowly fade out the sound(gainIncrement is negative) and when the timer is over we stop the sound
				//and reset gainMultiplier and gainIncrement
				state = nextState;
				nextState = __phonixState.none;
				stateTransTimer = timer;
				gainIncrement = (stateTransTimer == 0 ? -1 : -1/stateTransTimer);
				break;
			}
			case __phonixState.pausing:{
				//fading out when pausing is still considered "playing" and can be stopped
				state = __phonixState.playing;
				nextState = __phonixState.paused;
				stateTransTimer = timer;
				gainIncrement = (stateTransTimer == 0 ? -1 : -1/stateTransTimer);
				break;
			}
			case __phonixState.paused:{
				state = nextState;
				nextState = -1;
				__pauseAudio();
				break;
			}
		}
		
	}
}