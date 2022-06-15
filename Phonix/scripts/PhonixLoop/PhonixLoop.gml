function __phonixPatternLoop(_soundID, _introEnd = 0, _outroStart = -1, _priority = 1, _group = "master") : __phonixPatternParent() constructor{
	soundID = _soundID;
	
	if(!audio_exists(soundID)) __phonixTrace("Audio index \'"+string(soundID)+"\' doesn't exist", true);
	else trackLen = audio_sound_length(soundID)*1000;
	//intro only plays when starting from none, outro only plays when stopping
	introEnd = _introEnd;
	outroStart = _outroStart == -1 ? trackLen : _outroStart;
	playingOutro = false;//used because if outroStart isn't set we want to loop as we are fading away
	
	update = function(){
		__parentUpdate();
		if(state != __phonixState.none && state != __phonixState.paused && !playingOutro){
			if(trackPos >= outroStart - PHONIX_TICK_TIME){
				trackPos = introEnd;
				audio_sound_set_track_position(playingSound, trackPos);
			}
		}
	}
	
	play = function(_fadeInTimer = 0){
		var canPlay = (state != __phonixState.playing);
		if(!canPlay) return;
		nextState = __phonixState.playing
		__changeState(_fadeInTimer);
		playingOutro = false;
		return self;
	}
	
	pause = function(_fadeOutTimer = 0){
		var canPause = (state == __phonixState.playing && state != __phonixState.stopping);
		if(!canPause) return;
		nextState = __phonixState.pausing;
		//pausing doesn't play the outro, only stopping does
		__changeState(_fadeOutTimer);
		return self;
	}
	stop = function(_fadeOutTimer = 0, _immediate = false){
		//very dumb, should probably think of a better approach for this
		var canStop = (state != __phonixState.none);
		if(!canStop) return;
		if(outroStart == trackLen){
			nextState = __phonixState.stopping;
			__changeState(_fadeOutTimer);
		}else{
			if(state != __phonixState.stopping) trackPos = outroStart;
			nextState = __phonixState.stopping;
			var delay = _immediate ? 0 : trackLen - outroStart;
			__changeState(delay);
			//overriding gainIncrement because we don't want the end to drop in volume(maybe change later)
			gainIncrement =  _immediate ? -1 : 0;
			playingOutro = true;
		}
		return self;
	}
}
