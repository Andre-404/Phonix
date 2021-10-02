enum PhonixTimeType{
	frames,
	seconds,
	miliseconds
}
#macro BEAT_DEFAULT_LISTENER_ORIENTATION [0, 0, 1000, 0, -1, 0]
#macro PHONIX_DEFAULT_TIME_TYPE PhonixTimeType.miliseconds
#macro PHONIX_TICK_TIME 1/60*1000//in miliseconds


function PhonixMaster(gain) constructor{
	groups = {};
	masterGain = gain;
	activeSounds = [];
	activeQueues = [];
	groups[$ "master"] = new __phonixCreateGroup("master", 1);
	
	
	__update = function(){
		var m = groups[$ "master"];
		m.update();
	}
	
	__CreateGroup = function(groupName, gain){
		groups[$ "master"].CreateGroup(groupName, gain);
	}
	
	__SetMasterGain = function(gain){
		groups[$ "master"].groupGain = gain;
	}
	
	__SetGroupGain = function(groupName, gain){
		groups[$ groupName] = gain;
	}
	
	__CreateListener = function(_x, _y){
		var s = {};
		s.x = _x;
		s.y = _y;
		s.z = 0;
		
		s.SetPosition = function(_x, _y, _z){
			x = _x;
			y = _y;
			z = _z;
			audio_listener_position(_x, _y, z);
		}
		s.GetPosition = function(){
			return [x, y, z];
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
		
	__CreateSinglePattern = function(_asset, _gain, _loop, _fadeIn, _fadeOut, _group){
		var s = new __phonixSinglePattern(_asset, _gain, _loop, _fadeIn, _fadeOut, groups[$ _group]);
		return s;
	}
	
	__CreateQueuePattern = function(_assetArr, _gain, _loop, _fadeIn, _fadeOut, _group){
		var s = new __phonixQueuePattern(_assetArr, _gain, _loop, _fadeIn, _fadeOut, groups[$ _group]);
		return s;
	}
		
	__CreateRandomPattern = function(_assetArr, _gain, _fadeIn, _fadeOut, _group){
		var s = new __phonixRandomPattern(_assetArr, _gain, _fadeIn, _fadeOut, groups[$ _group]);
		return s;
	}
}

function __phonixCreateGroup(groupName, gain) constructor{
	groupGain = gain;
	baseGain = gain;
	childInstances = [];
	type = "group";
	name = groupName;
		
	CreateGroup = function(groupName, gain){
		var s = new __phonixCreateGroup(groupName, gain);
		array_push(childInstances, s);
		global.phonixHandler.groups[$ groupName] = s;
	}
		
	update = function(){
		if(name != "master") groupGain = baseGain*global.phonixHandler.groups[$ "master"];
		var l = array_length(childInstances);
		for(var i = 0; i < l; i++){
			var inst = childInstances[i];
			if(inst.type == "group"){
				inst.update();
			}else if(inst.type == "sound"){
				if(!inst.finished) inst.update();
				else {
					array_delete(childInstances, i--, 1);
					l --;
				}
			}
		}
	}
	
	groupStop = function(stopNow){
		var l = array_length(childInstances);
		for(var i = 0; i < l; i++){
			var inst = childInstances[i];
			if(inst.type == "group"){
				inst.groupStop();
			}else if(inst.type == "sound"){
				inst.Stop(stopNow);
			}
		}
	}
	
	groupPause = function(){
		var l = array_length(childInstances);
		for(var i = 0; i < l; i++){
			var inst = childInstances[i];
			if(inst.type == "group"){
				inst.groupPause();
			}else if(inst.type == "sound"){
				inst.Pause();
			}
		}
	}
	
	groupUnpause = function(){
		var l = array_length(childInstances);
		for(var i = 0; i < l; i++){
			var inst = childInstances[i];
			if(inst.type == "group"){
				inst.groupUnpause();
			}else if(inst.type == "sound"){
				inst.Unpause();
			}
		}
	}
	
}


global.phonixHandler = new PhonixMaster(1);



