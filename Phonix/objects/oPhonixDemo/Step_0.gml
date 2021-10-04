if(keyboard_check_released(ord("S"))){
	testID = PhonixPlay(singlePattern, 0);
}

if(keyboard_check_released(ord("Q"))){
	testID = PhonixPlay(queuePattern, 0);
}

if(keyboard_check_released(ord("R"))){
	testID = PhonixPlay(randomPattern, 0);
}

if(keyboard_check_released(vk_space)){
	PhonixStop("master");
}

if(keyboard_check_released(ord("P"))){
	PhonixPause("master");
}

if(keyboard_check_released(ord("U"))){
	PhonixResume("master");
}

if(keyboard_check_released(ord("T"))){
	testID = PhonixTransition(testID, singlePattern, 0);
}

if(mouse_check_button_released(mb_right)){
	PhonixPlay(randomPattern, 0, mouse_x, mouse_y);
}