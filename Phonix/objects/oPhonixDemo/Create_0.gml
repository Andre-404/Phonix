singlePattern = phonixCreateSingle(musicTrack1, false);
randomPattern = phonixCreateRandom([sfx1, sfx2, sfx3]);
loopPattern = phonixCreateLoop(sndLoop);

testID = -1;
audio_falloff_set_model(audio_falloff_linear_distance);

