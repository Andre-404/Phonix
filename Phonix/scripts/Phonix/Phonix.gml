
function PhonixMaster(gain) constructor{
	groups = {};
	masterGain = gain;
	activeSounds = [];
	activeQueues = [];
	
	
	update = function(){
		var arr = variable_struct_get_names(groups);
		var l = array_length(arr);
		for(var i = 0; i < l; i++){
			var s = groups[$ arr[i]];
			var l2 = array_length(s.sounds);
			for(var j = 0; j < l2; j++){
				var _sound = s.sounds[j];
				if(!_sound.finished)_sound.update();
				else {
					array_delete(s.sounds, j--, 1);
					l2 --;
				}
			}
			
		}
	}
	
	CreateGroup = function(groupName, gain){
		var s = {};
		s.groupGain = gain;
		s.sounds = [];
		groups[$ groupName] = s;
	}
	CreateGroup("master", 1);
	
	SetMasterGain = function(gain){
		masterGain = gain;
	}
	
	SetGroupGain = function(groupName, gain){
		groups[$ groupName] = gain;
	}
	
	CreateListener = function(_x, _y){
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
		
	CreateSinglePattern = function(_asset, _gain, _is3D, _fadeIn, _fadeOut, _group = "master"){
		var s = new __phonixSinglePattern(_asset, _gain, _is3D, _fadeIn, _fadeOut, groups[$ _group]);
		return s;
	}
	
	CreateQueuePattern = function(_assetArr, _gain, _loop, _is3D, _fadeIn, _fadeOut, _group = "master"){
		var s = new __phonixQueuePattern(_assetArr, _gain, _loop, _is3D, _fadeIn, _fadeOut, groups[$ _group]);
		return s;
	}
		
	
}

global.phonixHandler = new PhonixMaster(1);



