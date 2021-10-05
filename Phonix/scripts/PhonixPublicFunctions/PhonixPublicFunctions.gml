//These function are for handling sounds
function PhonixPlay(pattern, priority, _x = 0, _y = 0, _z = 0, fo_ref = PHONIX_DEFAULT_FALLOFF_REFERENCE, fo_max = PHONIX_DEFAULT_FALLOFF_MAX, fo_factor = PHONIX_DEFAULT_FALLOFF_FACTOR){
	var _id = pattern.play(priority, _x, _y, _z, fo_ref, fo_max, fo_factor);
	
	return _id;
}

function PhonixStop(index){
	//if the value is a string then find a group of that name and execute the desired function
	if(is_string(index)){
		var g = global.__phonixHandler.groups[$ index];
		if(g != undefined) g.groupStop(false);
	}else{
		if(PhonixValueIsValid(index)) index.Stop(false);
	}
}

function PhonixStopNow(index){
	//if the value is a string then find a group of that name and execute the desired function
	if(is_string(index)){
		var g = global.__phonixHandler.groups[$ index];
		if(g != undefined) g.groupStop(true);
	}else{
		if(PhonixValueIsValid(index)) index.Stop(true);
	}
}

function PhonixPause(index){
	//if the value is a string then find a group of that name and execute the given function
	if(is_string(index)){
		var g = global.__phonixHandler.groups[$ index];
		if(g != undefined) g.groupPause();
	}else{
		if(PhonixValueIsValid(index)) index.Pause();
	}
}

function PhonixResume(index){
	//if the value is a string then find a group of that name and execute the given function
	if(is_string(index)){
		var g = global.__phonixHandler.groups[$ index];
		if(g != undefined) g.groupResume();
	}else{
		if(PhonixValueIsValid(index)) index.Resume();
	}
}
	
function PhonixTransition(soundID, nextSoundPattern, priority, _x = 0, _y = 0, _z = 0, fo_ref = PHONIX_DEFAULT_FALLOFF_REFERENCE, fo_max = PHONIX_DEFAULT_FALLOFF_MAX, fo_factor = PHONIX_DEFAULT_FALLOFF_FACTOR){
	if(!PhonixValueIsValid(soundID)) exit;
	//if the soundID is a valid id, then we stop it and play the desired pattern
	//NOTE: the sound of the next pattern will only start playing after the soundID is marked as finished, meaning not immidiately
	var sFrom = soundID;
	var sNext = nextSoundPattern.play(priority, _x, _y, _z, fo_ref, fo_max, fo_factor);
	sFrom.hasTransition = true;
	sFrom.transitionSID = sNext;
	sFrom.Stop(false);
	sNext.hasTransition = true;
	return sNext;
}


//These functions are for creating patterns and general audio managment
function PhonixTick(){
	global.__phonixHandler.__update();
}

function PhonixCreateGroup(groupName, groupGain){
	global.__phonixHandler.__CreateGroup(groupName, groupGain);
}

function PhonixSetMasterGain(gain){
	global.__phonixHandler.__SetMasterGain(gain);
}
	
function PhonixGetMasterGain(){
	return global.__phonixHandler.__GetMasterGain();
}

function PhonixSetGroupGain(groupName, gain){
	global.__phonixHandler.__SetGroupGain(groupName, gain);
}
	
function PhonixGetGroupGain(groupName){
	return global.__phonixHandler.__GetGroupGain(groupName);
}

function PhonixCreateListener(_x, _y){
	return global.__phonixHandler.__CreateListener(_x, _y);
}

function PhonixCreateSingle(assetIndex, loop, fadeIn = 0, fadeOut = 0, group = "master"){
	return global.__phonixHandler.__CreateSinglePattern(assetIndex, loop, fadeIn, fadeOut, group);
}

function PhonixCreateQueue(assetIndexArr, loop, fadeIn = 0, fadeOut = 0, group = "master"){
	return global.__phonixHandler.__CreateQueuePattern(assetIndexArr, loop, fadeIn, fadeOut, group)
}

function PhonixCreateRandom(assetIndexArr, fadeIn = 0, fadeOut = 0, group = "master"){
	return global.__phonixHandler.__CreateRandomPattern(assetIndexArr, fadeIn, fadeOut, group);
}
	
function PhonixCreateLoop(_intro, _loop, _outro, _fadeIn = 0, _fadeOut = 0, _group = "master"){
	return global.__phonixHandler.__CreateLoopPattern(_intro, _loop, _outro, _fadeIn, _fadeOut, _group);
}

function PhonixSetFade(pattern, fadeInTime, fadeOutTime){
	pattern.fadeInTimer = fadeInTime;
	pattern.fadeOutTimer = fadeOutTime;
}
	
function PhonixValueIsValid(value){
	if(is_struct(value) && (instanceof(value) == "__createSinglePatternStruct"
	|| instanceof(value) == "__createQueuePatternStruct")) return true;
	else return false;
}