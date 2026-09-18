import funkin.backend.utils.DiscordUtil;
import flixel.text.FlxTextBorderStyle;
import funkin.menus.MainMenuState;
import haxe.crypto.Base64;
import haxe.Json;
import openfl.net.URLRequest;
import openfl.net.URLLoader;
import openfl.net.URLRequestMethod;

public var trophyGroup:FlxTypedGroup<FunkinSprite>;
var trophy:FunkinSprite;
var rainbowShader:CustomShader = new CustomShader("rgbpalette");
public var versionText:FunkinText;

var clicks:Int = FlxG.save.data.totalCreditsClicks != null ? FlxG.save.data.totalCreditsClicks : 0;
var milestones:Array<Int> = [500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 6000, 7000, 8000, 9000, 10000, 12500, 15000, 17500, 20000, 25000, 30000, 35000, 40000, 45000, 50000]; // i am so sorry for you

public function createMainMenu() {
    trophyGroup = new FlxTypedGroup<FunkinSprite>();
    add(trophyGroup);
	versionText = new FunkinText(5, FlxG.height - 2, 0);
    versionText.text = "VS. Mouse Ultimate (Cancelled Build)\n" + "[TAB] Open Mods menu";
    versionText.setFormat(Paths.font("CreatoDisplay-ExtraBold.otf"), 16, 0xFFFFFFFF, "right");
    versionText.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF000000, 1.5);
    versionText.y = 5;
    versionText.x = FlxG.width - versionText.width - 5;
    add(versionText);
    
    var tierColors:Array<Int> = [ //brightness, hue, contrast, saturation
        [-100,-30,35,-75],
        [-75,-30,45,-100],
        [0,0,0,0],
        [35,-180,0,-30],
        [0,45,0,0]
    ];

    var highestIdx:Int = -1;
    for (i in 0...milestones.length) {
        if (clicks >= milestones[i]) highestIdx = i;
    }

    for (i in 0...milestones.length) {
        if (clicks >= milestones[i]) {
            var trophy:FunkinSprite = new FunkinSprite(62.5 + (i * 45), 520);
            trophy.loadSprite(Paths.image('menus/credits/trophy'));
            trophy.scale.set(0.3, 0.3);
            trophy.updateHitbox();
            trophy.scrollFactor.set();
            trophy.antialiasing = Options.antialiasing;

            if (i >= 20) {
                trophy.shader = rainbowShader;
                rainbowShader.uMult = 1.0; 
            } else {
                var colorIndex:Int = Std.int((i / 20) * (tierColors.length - 1));
                var colorShader:CustomShader = new CustomShader("adjustColor");
                trophy.shader = colorShader;
                colorShader.brightness = tierColors[colorIndex][0];
                colorShader.hue = tierColors[colorIndex][1];
                colorShader.contrast = tierColors[colorIndex][2];
                colorShader.saturation = tierColors[colorIndex][3];
            }

            trophyGroup.add(trophy);
            
            trophy.alpha = 0;
            FlxTween.tween(trophy, {alpha: 1, y: trophy.y + 10}, 0.5, {
                ease: FlxEase.bounceOut, 
                startDelay: 0.5 + (i * 0.05),
                onStart: function(twn:FlxTween) {
                    var shineSnd = FlxG.sound.play(Paths.sound("credits/trophyShine"), 0.4);
                    if (shineSnd != null) shineSnd.pitch = 0.8 + (i * 0.02);

                    if (i == highestIdx) {
                        new FlxTimer().start(0.05, function(tmr:FlxTimer) {
                            FlxG.sound.play(Paths.sound("credits/trophyWow"), 1);
                        });
                    }
                }
            });
        }
    }

    var unlockedCount:Int = 0;
    for (m in milestones) if (clicks >= m) unlockedCount++;

    if (unlockedCount >= 25) {
        sendWebhookNotification();
    }

    DiscordUtil.changePresence("Main Menu", "(Trophies: " + unlockedCount + "/" + milestones.length + ")");
}

var shaderTimer:Float = 0;

function update(elapsed:Float) {
    shaderTimer += elapsed * 2.5;

    var r = (Math.sin(shaderTimer) * 0.5 + 0.5) * 0.7;
    var g = (Math.sin(shaderTimer + (Math.PI * 2 / 3)) * 0.5 + 0.5) * 0.7;
    var b = (Math.sin(shaderTimer + (Math.PI * 4 / 3)) * 0.5 + 0.5) * 0.7;

    rainbowShader.uR = [r, g, b];
    rainbowShader.uG = [b, r, g];
    rainbowShader.uB = [g, b, r];
}

function sendWebhookNotification() {
    var lastClicks:Int = FlxG.save.data.lastWebhookClicks != null ? FlxG.save.data.lastWebhookClicks : 0;
    if (clicks == lastClicks) return; 

    var encodedUrl:String = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTQ5MDA4NTE3NTk3MzkwNDUxNi84N1FKNlhwZnlpVk5NZVdoMXo5MGN2dEtEeHhrLS00c21DcDZYTzhEOHU3eXduQmo3T0RCOURjMVZvYmMwTzVTTDM4MA=="; 
    var webhookUrl:String = Base64.decode(encodedUrl).toString();
    
    var request:URLRequest = new URLRequest(webhookUrl);
    request.method = URLRequestMethod.POST;
    request.contentType = "application/json";

    var postData = {
        content: "**TROPHY MILESTONE UPDATE !!!**",
        embeds: [{
            title: "25/25 Trophies - from Somebody .",
            description: "somebody Has spent their precious time to unlock all 25 trophies! Why ? I don't know! But congratulations. ya r worthy.",
            color: 0x00FFFF,
            fields: [
                {name: "Total Clicks", value: "**" + Std.string(clicks) + "**", inline: true},
                {name: "Date Reached", value: Date.now().toString(), inline: true}
            ],
            footer: {text: "VS. Mouse Ultimate (Cancelled Build)"}
        }]
    };
    
    request.data = Json.stringify(postData);

    var loader:URLLoader = new URLLoader();
    
    loader.addEventListener("complete", function(e) {
        trace("Webhook sent successfully!");
        FlxG.save.data.lastWebhookClicks = clicks;
        FlxG.save.flush();
    });

    try {
        loader.load(request);
    } catch (e:Dynamic) {
        trace("Webhook error: " + e);
    }
}