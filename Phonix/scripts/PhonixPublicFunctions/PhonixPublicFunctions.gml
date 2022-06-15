function phonixGroupStop(_groupName, _fadeOutTimer = 0){
	var g = global.__phonixHandler.groups[$ _groupName];
	if(g != undefined) g.groupStop(_fadeOutTimer);
}

function phonixGroupPause(_groupName, _fadeOutTimer = 0){
	var g = global.__phonixHandler.groups[$ _groupName];
	if(g != undefined) g.groupPause(_fadeOutTimer);
}

function phonixGroupResume(_groupName, _fadeInTimer = 0){
	var g = global.__phonixHandler.groups[$ _groupName];
	if(g != undefined) g.groupResume(_fadeInTimer);
}
	
function phonixTransition(_phonixSound1, _phonixSound2, _fadeTimer = 0){
	if(!phonixValueIsValid(_phonixSound1)) exit;
	if(!phonixValueIsValid(_phonixSound2)) exit;
	if(_phonixSound1 == _phonixSound2) __phonixTrace("Can't transition to the same sound", true);
	_phonixSound1.pause(floor(_fadeTimer/4));
	_phonixSound2.play(floor(_fadeTimer));
}


//These functions are for creating patterns and general audio managment
function phonixTick(){
	global.__phonixHandler.__update();
}

function phonixCreateGroup(_groupName, _parentName = "master"){
	global.__phonixHandler.__CreateGroup(_groupName, _parentName);
}

function phonixSetMasterGain(_gain){
	global.__phonixHandler.__SetMasterGain(_gain);
}
	
function phonixGetMasterGain(){
	return global.__phonixHandler.__GetMasterGain();
}

function phonixSetGroupGain(_groupName, _gain){
	global.__phonixHandler.__SetGroupGain(_groupName, _gain);
}
	
function phonixGetGroupGain(_groupName){
	return global.__phonixHandler.__GetGroupGain(_groupName);
}

function phonixCreateListener(_x, _y){
	return global.__phonixHandler.__CreateListener(_x, _y);
}

function phonixCreateSingle(_assetIndex, _priority = 1, _group = "master"){
	return new __phonixPatternSingle(_assetIndex, _priority, _group);
}

function phonixCreateRandom(_assetIndexArr, _priority = 1, _group = "master"){
	return new __phonixPatternRandom(_assetIndexArr, _priority, _group);
}
	
function phonixCreateLoop(_assetIndex, _introEnd = 0, _outroStart = -1, _priority = 1, _group = "master"){
	return new __phonixPatternLoop(_assetIndex, _introEnd, _outroStart, _priority, _group);
}
	
function phonixValueIsValid(value){
	//God i hate GML, every phonix struct contains this variable, so if the user for some arcane reasons decides to create a struct with this variable
	//and then also uses it as a actual phonix struct, we're fucked
	if(is_struct(value) && variable_struct_get(value, "__isValidPhonixStruct") != undefined) return true;
	else return false;
}