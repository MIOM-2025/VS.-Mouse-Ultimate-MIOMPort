function postCreate() {
		var i = 0;
		for (s in strumLines.members[1]) {
			s.x = -278 + (160 * 0.7) * i + 50 + (FlxG.width / 2);
			i += 1;
		}
		i = 0;
		try{
        for (s in strumLines.members[2]) {
			if (i < 2) {
				s.x = 82 + i * 112;
			} else {
				s.x = FlxG.width - 309 + (i - 2) * 112;
			}
			i += 1;
		}	
		i = 0;
		} catch (e:Dynamic) {}
		for (s in strumLines.members[0]) {
			if (i < 2) {
				s.x = 82 + i * 112;
			} else {
				s.x = FlxG.width - 309 + (i - 2) * 112;
			}
			i += 1;
		}
}
