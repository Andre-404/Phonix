
function PhonixMaster(gain) constructor{
	groups = {};
	groups[$ "master"] = new __phonixCreateGroup("master", 1);
	__masterGroup = groups[$ "master"];
	
	
	__update = function(){
		__masterGroup.update();
	}
	
	__CreateGroup = function(groupName, gain){
		groups[$ "master"].CreateGroup(groupName, gain);
	}
	
	__SetMasterGain = function(gain){
		groups[$ "master"].groupGain = gain;
	}
	
	__GetMasterGain = function(){
		return groups[$ "master"].groupGain;
	}
	
	__SetGroupGain = function(groupName, gain){
		groups[$ groupName].groupGain = gain;
	}
	
	__GetGroupGain = function(groupName){
		return groups[$ groupName].groupGain;
	}
	
	__CreateListener = function(_x, _y){
		return new __phonixCreateListener(_x, _y);
	}
		
	__CreateSinglePattern = function(_asset, _loop, _fadeIn, _fadeOut, _group){
		var s = new __phonixSinglePattern(_asset, _loop, _fadeIn, _fadeOut, groups[$ _group]);
		return s;
	}
	
	__CreateQueuePattern = function(_assetArr, _loop, _fadeIn, _fadeOut, _group){
		var s = new __phonixQueuePattern(_assetArr, _loop, _fadeIn, _fadeOut, groups[$ _group]);
		return s;
	}
		
	__CreateRandomPattern = function(_assetArr,  _fadeIn, _fadeOut, _group){
		var s = new __phonixRandomPattern(_assetArr, _fadeIn, _fadeOut, groups[$ _group]);
		return s;
	}
}

function __phonixCreateGroup(groupName, gain) constructor{
	groupGain = gain;
	childInstances = [];
	type = "group";
	name = groupName;
		
	CreateGroup = function(groupName, gain){
		//create a new group and put it in a array of this groups children, also put it in the global groups lib
		var s = new __phonixCreateGroup(groupName, gain);
		array_push(childInstances, s);
		//global lib of group names
		global.__phonixHandler.groups[$ groupName] = s;
	}
		
	update = function(){
		//Updates all the sounds in the group, and if it finds a subgroup, runs the update code for the group too
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
		//Stops every sound in the group, and if there are subgroups, stops their sounds too
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
		//Pauses every sound in the group, and if there are subgroups, pauses their sounds too
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
		//Unpauses every sound in the group, and if there are subgroups, unpauses their sounds too
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

function __phonixCreateListener(_x, _y) constructor{
	x = _x;
	y = _y;
	z = 0;
	var arr = PHONIX_DEFAULT_LISTENER_ORIENTATION;//can be edited in config file
	audio_listener_orientation(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5]);
	audio_listener_position(x, y, z);
		
	SetPosition = function(_x, _y, _z = 0){
		x = _x;
		y = _y;
		z = _z;
		audio_listener_position(_x, _y, z);
	}
	
	GetPosition = function(){
		return [x, y, z];
	}
		
	SetOrientation = function(arr){
		audio_listener_orientation(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5]);
	}
		
	GetOrientation = function(){
		//right now there exists support for only 1 listener, and thus it's always gonna be at index 0
		var ds = audio_listener_get_data(0);
		var arr = [ds[? "lookat_x"], ds[? "lookat_y"], ds[? "lookat_z"], ds[? "up_x"], ds[? "up_y"], ds[? "up_z"]];
		ds_map_destroy(ds);
		return arr;
	}
}


global.__phonixHandler = new PhonixMaster(1);



