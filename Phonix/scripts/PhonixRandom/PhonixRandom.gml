function __phonixPatternRandom(_soundID, _priority = 1, _group = "master") : __phonixPatternParent() constructor{
	soundIDArray = _soundID;
	var l = array_length(soundIDArray);
	if(l == 0)  __phonixTrace("Sound ID array empty, phonix requires atleast 1 sound to be in the array", true);
	var i = 0;
	repeat(l){
		if(!audio_exists(soundIDArray[i])) __phonixTrace("Audio index \'"+string(soundID)+"\' doesn't exist", true);
	}
	soundID = soundIDArray[irandom(array_length(soundIDArray) - 1)];
	priority = _priority;
	group = _group;
	trackLen = audio_sound_length(soundID)*1000;

	update = function(){
		__parentUpdate();
	}
	
	//timers for functions below are in ms
	play = function(_fadeInTimer = 0){
		var canPlay = (state != __phonixState.playing);
		if(!canPlay) return;
		nextState = __phonixState.playing;
		__changeState(_fadeInTimer);
		return self;
	}
	
	pause = function(_fadeOutTimer = 0){
		var canPause = (state == __phonixState.playing && state != __phonixState.stopping);
		if(!canPause) return;
		nextState = __phonixState.pausing;
		__changeState(_fadeOutTimer);
		return self;
	}
	
	stop = function(_fadeOutTimer = 0){
		var canStop = (state != __phonixState.none);
		if(!canStop) return;
		nextState = __phonixState.stopping;
		__changeState(_fadeOutTimer);
		return self;
	}
	
	//overriding private function to support choosing a random sound
	__reset = function(){
		playingSound = -1;
		gainMultiplier = 0;
		gainIncrement = 0;
		soundID = soundIDArray[irandom(array_length(soundIDArray) - 1)];
		trackLen = audio_sound_length(soundID)*1000;
	}
}
