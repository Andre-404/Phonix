//plays a random sound from the given sound array
function __phonixRandomPattern(assetArr, _gain, _fadeIn, _fadeOut, _group) constructor{
	soundIDs = [];
	array_copy(soundIDs, 0, assetArr, 0, array_length(assetArr));
	gain = _gain;
	fadeInTimer = _fadeIn;
	fadeOutTimer = _fadeOut;
	group = _group;
	
	play = function(priority, _x, _y, _z, fo_ref, fo_max, fo_factor){
		var r = irandom(array_length(soundIDs)-1);
		//utilizes same player as a single pattern
		var s = new __createSinglePatternStruct(gain, group, false, soundIDs[r], fadeInTimer, fadeOutTimer, priority, [_x, _y, _z], [fo_ref, fo_max, fo_factor]);
		array_push(group.childInstances, s);
		return s;
	}
}