enum __phonixState{
	playing,
	pausing,
	paused,
	stopping,
	none,
	len
}


function __phonixMaster(gain) constructor{
	groups = {};
	groups[$ "master"] = new __phonixCreateGroup("master");
	sounds = ds_list_create();
	
	__update = function(){
		var l = ds_list_size(sounds);
		var i = l-1;
		repeat(l){
			var sound = sounds[| i];
			if(sound.state == __phonixState.none) {
				sound.__delete();
				ds_list_delete(sounds, i--);
				continue;
			}
			sound.update();
			i--;
		}
	}
	
	__CreateGroup = function(_groupName, _parentGroup){
		groups[_groupName] = __phonixCreateGroup(_groupName);
		array_push(groups[_parentGroup].childGroups, groups[_groupName]);
	}
	
	__SetMasterGain = function(gain){
		groups[$ "master"].setGain(gain);
	}
	
	__GetMasterGain = function(){
		return groups[$ "master"].getGain();
	}
	
	__SetGroupGain = function(groupName, gain){
		groups[$ groupName].setGain(gain);
	}
	
	__GetGroupGain = function(groupName){
		return groups[$ groupName].getGain();
	}
	
	__CreateListener = function(_x, _y){
		return new __phonixCreateListener(_x, _y);
	}
}

function __phonixCreateGroup(_groupName) constructor{
	baseGain = 1;
	gainMultiplier = 1;
	childGroups = [];
	name = _groupName;
	
	groupStop = function(_fadeOutTimer){
		var handler = global.__phonixHandler;
		var l = ds_list_size(handler.sounds);
		var i = l-1;
		repeat(l){
			var sound = handler.sounds[| i];
			if(sound.group == name) sound.stop(_fadeOutTimer);
			i--;
		}
	}
	
	groupPause = function(_fadeOutTimer){
		var handler = global.__phonixHandler;
		var l = ds_list_size(handler.sounds);
		var i = l-1;
		repeat(l){
			var sound = handler.sounds[| i];
			if(sound.group == name) sound.pause(_fadeOutTimer);
			i--;
		}
	}
	
	groupResume = function(_fadeInTimer){
		var handler = global.__phonixHandler;
		var l = ds_list_size(handler.sounds);
		var i = l-1;
		repeat(l){
			var sound = handler.sounds[| i];
			if(sound.group == name) sound.play(_fadeInTimer);
			i--;
		}
	}
		
	setGain = function(_gain){
		baseGain = _gain;
		__propagateGain();
	}
	
	getGain = function(){
		return baseGain*gainMultiplier;
	}
	
	__propagateGain = function(){
		//this is only done when the gain of this group changes, and that change is propagated only to it's child groups
		var l = array_length(childGroups);
		var i = 0;
		repeat(l){
			childGroups[i].gainMultiplier = gainMultiplier*baseGain;
			childGroups[i].__propagateGain();
			i++;
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
		
	setPosition = function(_x, _y, _z = 0){
		x = _x;
		y = _y;
		z = _z;
		audio_listener_position(_x, _y, z);
	}
	
	getPosition = function(){
		return [x, y, z];
	}
		
	setOrientation = function(arr){
		audio_listener_orientation(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5]);
	}
		
	getOrientation = function(){
		//right now there exists support for only 1 listener, and thus it's always gonna be at index 0
		var ds = audio_listener_get_data(0);
		var arr = [ds[? "lookat_x"], ds[? "lookat_y"], ds[? "lookat_z"], ds[? "up_x"], ds[? "up_y"], ds[? "up_z"]];
		ds_map_destroy(ds);
		return arr;
	}
}


global.__phonixHandler = new __phonixMaster(1);

function __phonixTrace(s, crash = false){
	show_error("Phonix: " + s, crash);
}



