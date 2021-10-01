function PhonixStop(sound){
	if(is_string(sound)){
		var arr = global.phonixHandler.sounds[$ sound].activeSounds;
		var l = array_length(arr);
		for(var i = 0; i < l; i++){
			arr[i].Stop();
		}
	}else{
		if(weak_ref_alive(sound)){
			sound.ref.Stop();
		}else PhonixTrace(string(sound) + " doesn't exist!");
	}
}

function PhonixStopNow(sound){
	if(is_string(sound)){
		var arr = global.phonixHandler.sounds[$ sound].activeSounds;
		var l = array_length(arr);
		for(var i = 0; i < l; i++){
			arr[i].finished = true;
		}
	}else{
		if(weak_ref_alive(sound)){
			sound.ref.finished = true;
		}else PhonixTrace(string(sound) + " doesn't exist!");
	}
}

function PhonixIsFinished(sound){
	if(weak_ref_alive(sound)) return sound.ref.finished;
	PhonixTrace(string(sound) + " doesn't exist!");
}

function PhonixIsStopping(sound){
	if(weak_ref_alive(sound)) return sound.ref.stopping;
	PhonixTrace(string(sound) + " doesn't exist!");
}

function PhonixIs3D(sound){
	if(is_string(sound)){
		return global.phonixHandler.sounds[$ sound].is3D;
		PhonixTrace(sound + " doesn't exist!");
	}else{
		if(weak_ref_alive(sound)) return sound.ref.is3D;
		PhonixTrace(string(sound) + " doesn't exist!");
	}
}

function PhonixIsPaused(sound){
	if(is_string(sound)){
		return global.phonixHandler.sounds[$ sound].pause;
		PhonixTrace(sound + " doesn't exist!");
	}else{
		if(weak_ref_alive(sound)) return sound.ref.paused;
		PhonixTrace(string(sound) + " doesn't exist!");
	}
}

function PhonixGetLength(sound){
	if(is_string(sound)){
		return global.phonixHandler.sounds[$ sound].length;
		PhonixTrace(sound + " doesn't exist!");
	}else{
		if(weak_ref_alive(sound)) return sound.ref.length;
		PhonixTrace(string(sound) + " doesn't exist!");
	}
}

function PhonixSet3D(sound, _is3D){
	if(is_string(sound)){
		global.phonixHandler.sounds[$ sound].is3D = _is3D;
		PhonixTrace(sound + " doesn't exist!");
	}else{
		if(weak_ref_alive(sound)) sound.ref.is3D = _is3D;
		else PhonixTrace(string(sound) + " doesn't exist!");
	}
}

function PhonixSetTrackPosition(sound, _pos, _timeType = PHONIX_DEFAULT_TIME_TYPE){
	if(weak_ref_alive(sound)){
		if(PhonixIsPlaying(sound)){
			var p = __phonixConvertTime(_pos, _timeType);
			audio_sound_set_track_position(sound.ref.sID, p)
		}
	}else PhonixTrace(string(sound) + " doesn't exist!");
}

function PhonixSetPosition(sound, _x, _y, _z){
	if(weak_ref_alive(sound)){
		with(sound.ref){
			if(is3D && emitter != -1){
				x = _x;
				y = _y;
				z = _z;
				audio_emitter_position(emitter, _x, _y, _z);
			}
		}
	}else PhonixTrace(string(sound) + " doesn't exist!");
}

function PhonixGetPosition(sound){
	if(weak_ref_alive(sound)){
		with(sound.ref){
			if(is3D && emitter != -1){
				x = _x;
				y = _y;
				z = _z;
				audio_emitter_position(emitter, _x, _y, _z);
			}
		}
	}else PhonixTrace(string(sound) + " doesn't exist!");
	
}

function PhonixSetFalloff(sound, falloff_ref, falloff_max, falloff_factor){
		if(weak_ref_alive(sound)){
		with(sound.ref){
			if(is3D && emitter != -1) audio_emitter_falloff(emitter, falloff_ref, falloff_max, falloff_factor);
		}
	}else PhonixTrace(string(sound) + " doesn't exist!");
}

function PhonixPause(sound){
	if(is_string(sound)){
		var arr = global.phonixHandler.sounds[$ sound].activeSounds;
		var l = array_length(arr);
		for(var i = 0; i < l; i++){
			arr[i].Pause();
		}
	}else{
		if(weak_ref_alive(sound)){
			sound.ref.Pause();
		}else PhonixTrace(string(sound) + " doesn't exist!");
	}
}

function PhonixUnpause(sound){
	if(is_string(sound)){
		var arr = global.phonixHandler.sounds[$ sound].activeSounds;
		var l = array_length(arr);
		for(var i = 0; i < l; i++){
			arr[i].Unpause();
		}
	}else{
		if(weak_ref_alive(sound)){
			sound.ref.Unpause();
		}else PhonixTrace(string(sound) + " doesn't exist!");
	}
}

