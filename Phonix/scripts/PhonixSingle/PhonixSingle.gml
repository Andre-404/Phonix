function __phonixPatternSingle(_soundID, _priority = 1, _group = "master") : __phonixPatternParent() constructor{
	//in the case of a patternSingle the sound ID never changes
	soundID = _soundID;
	if(!audio_exists(soundID)) __phonixTrace("Audio index \'"+string(soundID)+"\' doesn't exist", true);
	else trackLen = audio_sound_length(soundID)*1000;
	priority = _priority;
	group = _group;

	update = function(){
		__parentUpdate();
	}
	
	//timers for functions below are in ms
	play = function(_fadeInTimer = 0){
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
}