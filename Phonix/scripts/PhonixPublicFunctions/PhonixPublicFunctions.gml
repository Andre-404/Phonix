//These function are for handling sounds
function PhonixPlay(pattern, priority, _x = 0, _y = 0, _z = 0, fo_ref = 50, fo_max = 100, fo_factor = 1){
	var _id = pattern.play(priority, _x, _y, _z, fo_ref, fo_max, fo_factor);
	
	return _id;
}

function PhonixStop(index){
	if(is_string(index)){
		var g = global.phonixHandler.groups[$ index];
		g.groupStop(false);
	}else{
		index.Stop(false);
	}
}

function PhonixStopNow(index){
	if(is_string(index)){
		var g = global.phonixHandler.groups[$ index];
		g.groupStop(true);
	}else{
		index.Stop(true);
	}
}

function PhonixPause(index){
	if(is_string(index)){
		var g = global.phonixHandler.groups[$ index];
		g.groupPause();
	}else{
		index.Pause();
	}
}

function PhonixUnpause(index){
	if(is_string(index)){
		var g = global.phonixHandler.groups[$ index];
		g.groupUnpause();
	}else{
		index.Unpause();
	}
}
	
function PhonixTransition(soundID, nextSoundPattern, priority, _x = 0, _y = 0, _z = 0, fo_ref = 50, fo_max = 100, fo_factor = 1){
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
	global.phonixHandler.__update();
}

function PhonixCreateGroup(groupName, groupGain){
	global.phonixHandler.__CreateGroup(groupName, groupGain);
}

function PhonixSetMasterGain(gain){
	global.phonixHandler.__SetMasterGain(gain);
}

function PhonixSetGroupGain(groupName, gain){
	global.phonixHandler.__SetGroupGain(groupName, gain);
}

function PhonixCreateListener(_x, _y){
	global.phonixHandler.__CreateListener(_x, _y);
}

function PhonixCreateSingle(_asset, _gain, _loop, _fadeIn = 0, _fadeOut = 0, _group = "master"){
	return global.phonixHandler.__CreateSinglePattern(_asset, _gain, _loop, _fadeIn, _fadeOut, _group);
}

function PhonixCreateQueue(_assetArr, _gain, _loop, _fadeIn = 0, _fadeOut = 0, _group = "master"){
	return global.phonixHandler.__CreateQueuePattern(_assetArr, _gain, _loop, _fadeIn, _fadeOut, _group)
}

function PhonixCreateRandom(_assetArr, _gain, _fadeIn = 0, _fadeOut = 0, _group = "master"){
	return global.phonixHandler.__CreateRandomPattern(_assetArr, _gain, _fadeIn, _fadeOut, _group);
}

