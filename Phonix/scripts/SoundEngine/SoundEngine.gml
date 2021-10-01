enum PhonixTimeType{
	frames,
	seconds,
	miliseconds
}
#macro BEAT_DEFAULT_LISTENER_ORIENTATION [0, 0, 1000, 0, -1, 0]
#macro PHONIX_DEFAULT_TIME_TYPE PhonixTimeType.miliseconds

function BeatMaster(gain) constructor{
	groups = {};
	sounds = {};
	masterGain = gain;
	activeSounds = [];
	soundPairsArr = [];
	activeQueues = [];
	emitterRefPairs = [];
	
	update = function(){
		for(var i = 0; i < array_length(activeSounds); i++){
			var wr = activeSounds[i][0];
			
			if(weak_ref_alive(wr)){
				wr.ref.update();
				activeSounds[i][1] = wr.ref.sID;
			}else{
				
				var _sID = activeSounds[i][1];
				if(audio_exists(_sID) && (audio_is_playing(_sID) || audio_is_paused(_sID))){
					audio_stop_sound(_sID);
				}
				array_delete(activeSounds, i--, 1);
			}
		}
		
		for(var j = 0; j < array_length(soundPairsArr); j++){
			var pair = soundPairsArr[j];
			if(!pair[0].stopping) pair[0].Stop();
			if(pair[0].IsFinished() && !pair[1].IsPlaying()) {
				pair[1].PlayBeat(pair[2], pair[3]);
				if(pair[1].Is3D()){
					var a = pair[4];
					pair[1].SetPosition(a[0], a[1], a[2]).SetFalloff(a[3], a[4], a[5]);
				}
				array_delete(soundPairsArr, j--, 1);
			}
		}
		
		for(var i = 0; i < array_length(activeQueues); i++){
			var wr = activeQueues[i];
			
			if(weak_ref_alive(wr)){
				wr.ref.update();
			}else{
				array_delete(activeQueues, i--, 1);
			}
		}
		
		for(var i = 0; i < array_length(emitterRefPairs); i++){
			var wr = emitterRefPairs[i][1];
			
			if(!weak_ref_alive(wr)){
				audio_emitter_free(emitter);
				array_delete(emitterRefPairs, i--, 1);
			}
		}
		
	}
	
	CreateSound = function(sIndex, soundName, gain){
		var s = {};
		s.soundIndex = sIndex;
		s.gain = gain;
		s.group = -1;
		sounds[$ soundName] = s;
	}
	
	CreateGroup = function(groupName, gain){
		var s = {};
		s.groupGain = gain;
		s.sounds = {};
		groups[$ groupName] = s;
	}
		
	AddSoundToGroup = function(soundName, groupName){
		sounds[$ soundName].group = groups[$ groupName];	
	}
	
	RemoveSoundFromGroup = function(soundName){
		sounds[$ soundName].group = -1;
	}
	
	SetMasterGain = function(gain){
		masterGain = gain;
	}
	
	SetGroupGain = function(groupName, gain){
		groups[$ groupName] = gain;
	}
		
	SetSoundGain = function(SoundName, gain){
		sounds[$ SoundName].gain = gain;
	}
	
	CreateBeat = function(soundName, _3D){
		var s = new __create3DBeatStruct(sounds[$ soundName], self, _3D);
		array_push(activeSounds, [weak_ref_create(s), s.sID]);
		return s;
	}
	
	CreateNormalBeat = function(soundName){
		var s = new __create3DBeatStruct(sounds[$ soundName], self, false);
		array_push(activeSounds, weak_ref_create(s));
		return s;
	}
	
	CreateBeatQueue = function(loops){
		var s = new __createBeatQueueStruct(self, loops);
		array_push(activeQueues, weak_ref_create(s));
		return s;
	}
	
	CreateDJ = function(_x, _y){
		var s = {};
		s.x = _x;
		s.y = _y;
		s.z = 0;
		s.S = function(_x, _y){
			audio_listener_position(_x, _y, z);
		}
		s.GetPosition = function(){
			return [s.x, s.y, s.z];
		}
		s.SetOrientation = function(arr){
			audio_listener_orientation(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5]);
		}
		s.GetOrientation = function(){
			var ds = audio_listener_get_data(0);
			var arr = [ds[? "lookat_x"], ds[? "lookat_y"], ds[? "lookat_z"], ds[? "up_x"], ds[? "up_y"], ds[? "up_z"]];
			ds_map_destroy(ds);
			return arr;
		}
		
		
		var arr = BEAT_DEFAULT_LISTENER_ORIENTATION;
		audio_listener_orientation(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5]);
		audio_listener_position(s.x, s.y, s.z);
		return s;
	}
	
}

function __create3DBeatStruct(_soundStruct, _soundMaster, _is3D) constructor{
	soundStruct = _soundStruct;
	smStruct = _soundMaster;
	sID = -1;
	overwriteGain = -1;
	fading = false;
	_fadeIn = false;
	_fadeOut = false;
	fadeInTimer = 0;
	fadeOutTimer = 0;
	timer = 0;
	loops = false;
	length = audio_sound_length(soundStruct.soundIndex);
	is3D = _is3D;
	pausing = false;
	paused = false;
	trackPausedTime = 0;
	stopping = false;
	stopped = false;
	finished = false;
	emitter = -1;
	x = 0;
	y = 0;
	z = 0;
	
	
	update = function(){
		if(sID == -1) exit;
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
		
		if(length*1000 <= ((audio_sound_get_track_position(sID)*1000)+fadeOutTimer) && !fading){
			Stop();
		}
		if(finished) {
			audio_stop_sound(sID);
		}else if(paused && IsPlaying(sID)){
			audio_pause_sound(sID);
		}
		
		if(finished && loops){
			PlayBeat(true, 0);
		}else if(finished) show_debug_message("finished");
		show_debug_message(audio_sound_get_gain(sID));
		
	}
	
	
	fadeIn = function(time, timeType = BeatTimeType.miliseconds){
		_fadeIn = true;
		var t = timeType == BeatTimeType.frames ? time * 60 : time;
		t = timeType == BeatTimeType.miliseconds ? t : t*1000;
		fadeInTimer = t;
		return self;
	}
	
	fadeOut = function(time, timeType = BeatTimeType.miliseconds){
		_fadeOut = true;
		var t = timeType == BeatTimeType.frames ? time * 60 : time;
		t = timeType == BeatTimeType.miliseconds ? t : t*1000;
		fadeOutTimer = t;
		return self;
	}
	
	PlayBeat = function(loop, priority, _x = 0, _y = 0, _z = 0, fo_ref = 50, fo_max = 100, fo_factor = 1){
		FreeBeat();
		loops = loop;
		if(!is3D) {
			sID = audio_play_sound(soundStruct.soundIndex, priority, false);
		}
		else{
			if(emitter == -1) emitter = audio_emitter_create();
			array_push(smStruct.emitterRefPairs, [emitter, weak_ref_create(self)]);
			audio_emitter_position(emitter, _x, _y, _z);
			audio_emitter_falloff(emitter, fo_ref, fo_max, fo_factor);
			sID = audio_play_sound_on(emitter, soundStruct.soundIndex, false, priority);
		}
		__SetFadeIn();
		return self;
	}
	
	Stop = function(){
		if(!IsStopping() && !IsFinished()){
			stopping = true;
			__SetFadeOut();
		}
	}
	
	IsFading = function(){
		return fading == 0 ? false : true;
	}
	
	IsStopping = function(){
		return stopping;
	}
	
	Is3D = function(){
		return is3D;
	}
	 
	SetPosition = function(_x, _y, _z){
		if(is3D && emitter != -1){
			x = _x;
			y = _y;
			z = _z;
			audio_emitter_position(emitter, _x, _y, _z);
		}
		return self;
	}
	
	SetFalloff = function(fo_ref, fo_max, fo_factor){
		if(is3D && emitter != -1){
			audio_emitter_falloff(emitter, fo_ref, fo_max, fo_max);
		}
		return self;
	}
	
	GetPosition = function(){
		return [x, y, z];
	}
	
	IsPlaying = function(){
		return sID != -1 ? audio_is_playing(sID) : false;
	}
	
	IsFinished = function(){
		return finished;
	}
	
	DestroyBeat = function(){
		if(!finished) exit;
		if(is3D) audio_emitter_free(emitter);
		return -1;
	}
	
	FreeBeat = function(){
		if(is3D && emitter != -1){
			audio_emitter_free(emitter);
			emitter = -1;
		}
		sID = -1;
		pausing = false;
		paused = false;
		trackPausedTime = 0;
		stopping = false;
		stopped = false;
		finished = false;
		timer = 0;
		fading = 0;
	}
	
	__SetFadeIn = function(){
		if(!IsFading()){
			fading = 1;
			audio_sound_gain(sID, 0, 0);
			var _gain = overwriteGain == -1 ? soundStruct.gain*(soundStruct.group != -1 ? soundStruct.group.gain : 1)*smStruct.masterGain : overwriteGain;
			audio_sound_gain(sID, _gain, fadeInTimer);
		}
	}
	
	__SetFadeOut = function(){
		if(!IsFading()){
			fading = -1;
			audio_sound_gain(sID, 0, fadeOutTimer);
		}
	}
		
	Pause = function(){
		if(!IsFading()){
			pausing = true;
			__SetFadeOut();
		}
	}
	
	Unpause = function(){
		if(!IsFading() && !pausing && paused){
			audio_resume_sound(sID);
			paused = false;
			__SetFadeIn();
			audio_sound_set_track_position(sID, trackPausedTime);
		}
	}
	
	Transition = function(beat, loop, priority, _x = 0, _y = 0, _z = 0, fo_ref = 50, fo_max = 100, fo_factor = 1){
		array_push(smStruct.soundPairsArr, [self, beat, loop, priority, [_x, _y, _z, fo_ref, fo_max, fo_factor]]);
	}
	
	GetLength = function(timeType = BeatTimeType.miliseconds){
		var m = 0;
		switch(timeType){
			case BeatTimeType.frames: m = 60; break;
			case BeatTimeType.miliseconds: m = 1000; break;
			case BeatTimeType.seconds: m = 1; break;
		}
		return length*m;
	}
	
	isPaused = function(){
		return paused;
	}
		
}
	
function __createBeatQueueStruct(_soundMaster, loops) constructor{
	smStruct = _soundMaster;
	hasFade = false;
	fadeTime = 0;
	beatArr = [];
	beatArrLength = 0;
	trackPos = 0;
	trackTarget = 0;
	loop = loops;
	curPlaying = false;
	paused = false;
	pausing = false;
	stopping = false;
	curBeat = -1;
	curBeatLength = 0;
	queueFinished = false;
	destroyCurBeat = false;
	
	update = function(){
		if(queueFinished) exit;
		if(!paused) trackPos += delta_time/1000;
		
		if(stopping && curBeat.IsFinished()) queueFinished = true;
		if(pausing && curBeat.isPaused()){
			pausing = false;
			paused = true;
		}
		
		if(trackPos >= trackTarget || destroyCurBeat){
			var _nextBeat = -1;
			var _pos = __findBeatPos(curBeat);
			if(_pos != -1){
				_pos ++;
				if(_pos < beatArrLength) var _nextBeat = beatArr[_pos];
			}
			if(curBeat.IsFinished()){
				if(_nextBeat != -1){
					curBeat = _nextBeat;
					curBeat.PlayBeat(false, 0);
					curBeatLength = curBeat.GetLength();
					trackTarget  = curBeatLength;
					trackPos = 0;
				}else{
					curPlaying = false;
					queueFinished = true;
				}
				destroyCurBeat = false;
			}
		}
		
	}
	
	AddSoundToTrack = function(){
		var i = 0;
		repeat(argument_count)
		{
		    beatArr[i] = smStruct.CreateBeat(argument[i], false);
		    ++i;
		}
		beatArrLength = array_length(beatArr);
		return self;
	}
	
	RemoveSoundFromTrack = function(index){
		if(__findBeatPos(curBeat) == index){
			curBeat.Stop();
			destroyCurBeat = true;
		}else{
			array_delete(beatArr, index, 1);
			beatArrLength = array_length(beatArr);
		}
	}
	
	PlayQueue = function(){
		if(beatArrLength > 0 && !curPlaying){
			var _beat = beatArr[0];
			_beat.PlayBeat(false, 0);
			curBeat = _beat;
			curBeatLength = curBeat.GetLength();
			trackTarget = curBeatLength;
			curPlaying = true;
		}
		return self;
	}
	
	SetFade = function(time, timeType = BeatTimeType.miliseconds){
		hasFade = true;
		var m = 0;
		switch(timeType){
			case BeatTimeType.frames: m = time/60*1000; break;
			case BeatTimeType.miliseconds: m = time; break;
			case BeatTimeType.seconds: m = time*1000 break;
		}
		fadeTime = m;
		
		for(var i = 0; i < beatArrLength; i++){
			var _b = beatArr[i];
			_b.fadeIn(fadeTime).fadeOut(fadeTime);
		}
		return self;
	}
	
	
	__findBeatPos = function(beat){
		for(var i = 0; i < beatArrLength; i++){
			if(beatArr[i] == beat) return i;
		}
		return -1;
		
	}
	
	
	destroyQueue = function(){
		beatArr = -1;
		return -1;
	}
	
	stopQueue = function(){
		curBeat.Stop();
		stopping = true;
	}
	
	pauseQueue = function(){
		curBeat.Pause();
		pausing = true;
	}
	
	unpauseQueue = function(){
		curBeat.Unpause();
		paused = false;
	}
	
}