import funkin.backend.utils.DiscordUtil;
import StringTools;

var accuracyStuff:String = "N/A";
var poop:String = "";

var funnyNames:Array<String> = [
    "NO LEAKS... Indeed!",
    "Coconut Butter",
    "Golden (by HUNTR/X)",
    "Scrap 8",
    "Interference 7",
    "Why you spyin' bruh",
    "Paige's Friend... I see you. Why you stalkin' me Oye?",
    "Keith",
    "Welcome (Old)"
];

function create() {
    poop = funnyNames[FlxG.random.int(0, funnyNames.length - 1)];

    updateDiscordPresence = function() {
        var songName:String = SONG.meta.displayName;
        if (PlayState.instance.curSong.toLowerCase() == "dussy") songName = "[REDACTED]";
        
        DiscordUtil.changePresenceAdvanced({
            state: "Misses: " + misses + " | Accuracy: " + accuracyStuff,
            details: (paused ? "Paused" : "Playing") + " - " + songName + " (" + PlayState.difficulty + ")"
        });
    }

    updateDiscordPresence();
    new FlxTimer().start(2, (tmr:FlxTimer) -> { updateDiscordPresence(); }, 0);
}

function postUpdate(elapsed) {
    if (accuracy >= 0)
        accuracyStuff = FlxMath.roundDecimal(accuracy * 100, 2) + "%";
    else
        accuracyStuff = "N/A";
}