if(keyboard_check_released(ord("S"))){
	singlePattern.play(500);
	testID = singlePattern;
}

if(keyboard_check_released(ord("R"))){
	randomPattern.play(500);
	testID = randomPattern;
}

if(keyboard_check_released(ord("L"))){
	loopPattern.play(500)
	testID = loopPattern;
}

if(keyboard_check_released(vk_space)){
	phonixGroupStop("master");
}

if(keyboard_check_released(ord("P"))){
	phonixGroupPause("master");
}

if(keyboard_check_released(ord("U"))){
	phonixGroupResume("master");
}

if(mouse_check_button_released(mb_right)){
	phonixCreateSingle(sfx1).setEmitterInfo(mouse_x, mouse_y, 0).play();
}

	
