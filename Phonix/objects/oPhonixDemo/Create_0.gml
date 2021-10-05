singlePattern = PhonixCreateSingle(musicTrack1, false);
queuePattern = PhonixCreateQueue([musicTrack2, musicTrack3, musicTrack1], false, 0, 0);
randomPattern = PhonixCreateRandom([sfx1, sfx2, sfx3]);
loopPattern = PhonixCreateLoop(sndIntro, sndLoop, sndOutro, 50, 50);

testID = -1;
