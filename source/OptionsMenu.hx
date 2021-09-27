package;

import lime.math.ColorMatrix;
import openfl.Lib;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import lime.utils.Assets;

class OptionsMenu extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

	var options:Array<OptionCatagory> = [
		new OptionCatagory("Gameplay", [
			new InputOption("it doesn't matter what u put here lol"),
			new DownscrollOption(""),
			new CpuStrums("")
		]),
		new OptionCatagory("Appareance", [
			new Colour(""),
			new BetterIcon(""),
			new SongTimeThing(""),
			new FlashingLightsOption("")
		]),
		new OptionCatagory("Misc", [
			new Health(""),
			new BotPlay(""),
			#if !web
			new Haxeflixel(""),
			#end
			new RemixThing(""),
			new ResetSettings("")
		]),
		new OptionCatagory("Controls", [
			new ControlOption(),
			new Reset("")
		])
	];

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<Alphabet>;

	var currentSelectedCat:OptionCatagory;

	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("main_menu/menuDesat"));

		menuBG.color = 0xFF5EAFA1;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		super.create();
	}

	var isCat:Bool = false;
	
	function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
		}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(!FlxG.sound.music.playing)
		{
			if(FlxG.save.data.remix)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenuRemix'), 0);
				}
				else
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
		}

			if (controls.BACK && !isCat)
			{
				FlxG.switchState(new MainMenuState());
				FlxTween.tween(FlxG.camera, { zoom: -2}, 0.4, { ease: FlxEase.expoIn});
				FlxTween.tween(FlxG.camera, { angle: -90}, 0.4, { ease: FlxEase.expoIn});
			}
			else if (controls.BACK)
			{
				isCat = false;
				grpControls.clear();
				for (i in 0...options.length)
					{
						var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false);
						controlLabel.isMenuItem = true;
						controlLabel.targetY = i;
						grpControls.add(controlLabel);
						// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
					}
				curSelected = 0;
			}
			if (FlxG.keys.justPressed.UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeSelection(-1);
				}
	
				if (FlxG.keys.justPressed.DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeSelection(1);
				}
			
			if (isCat)
			{
				switch(currentSelectedCat.getOptions()[curSelected].getDisplay())
				{
					case 'FPS Cap':
						var fps = (cast (Lib.current.getChildAt(0), Main)).getFPSCap();

						if (FlxG.keys.pressed.RIGHT && fps < 285) // actual cap is 285
						{
							(cast (Lib.current.getChildAt(0), Main)).setFPSCap(fps + 10);
							FlxG.save.data.fpsCap = fps + 10;
						}
		
						if (FlxG.keys.pressed.LEFT && fps > 60)
						{
							(cast (Lib.current.getChildAt(0), Main)).setFPSCap(fps - 10);
							FlxG.save.data.fpsCap = fps - 10;
						}
		
						
					case 'Scroll Speed':
						if (FlxG.keys.justPressed.RIGHT)
							FlxG.save.data.scrollSpeed += 0.1;
		
						if (FlxG.keys.justPressed.LEFT)
							FlxG.save.data.scrollSpeed -= 0.1;

						// caps

						if (FlxG.save.data.scrollSpeed < 1)
							FlxG.save.data.scrollSpeed = 1;

						if (FlxG.save.data.scrollSpeed > 10)
							FlxG.save.data.scrollSpeed = 10;
					default:
						if (FlxG.keys.pressed.RIGHT)
							FlxG.save.data.offset += 0.01;
		
						if (FlxG.keys.pressed.LEFT)
							FlxG.save.data.offset -= 0.01;
						
				}
			}
			else
			{
				if (FlxG.keys.pressed.RIGHT)
					FlxG.save.data.offset+= 0.01;

				if (FlxG.keys.pressed.LEFT)
					FlxG.save.data.offset-= 0.01;
			
			}
		

			if (controls.ACCEPT)
			{
				if (isCat)
				{
					if (currentSelectedCat.getOptions()[curSelected].press()) {
						grpControls.remove(grpControls.members[curSelected]);
						var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, currentSelectedCat.getOptions()[curSelected].getDisplay(), true, false);
						ctrl.isMenuItem = true;
						grpControls.add(ctrl);
					}
				}
				else
				{
					currentSelectedCat = options[curSelected];
					isCat = true;
					grpControls.clear();
					for (i in 0...currentSelectedCat.getOptions().length)
						{
							var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getDisplay(), true, false);
							controlLabel.isMenuItem = true;
							controlLabel.targetY = i;
							grpControls.add(controlLabel);
							// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
						}
					curSelected = 0;
				}
			}
		FlxG.save.flush();
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent("Fresh");
		#end

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}

//Here ends the Option Menu UI Stuff and starts the Options

class OptionCatagory
{
	private var _options:Array<Option> = new Array<Option>();
	public final function getOptions():Array<Option>
	{
		return _options;
	}

	public final function addOption(opt:Option)
	{
		_options.push(opt);
	}

	
	public final function removeOption(opt:Option)
	{
		_options.remove(opt);
	}

	private var _name:String = "New Catagory";
	public final function getName() {
		return _name;
	}

	public function new (catName:String, options:Array<Option>)
	{
		_name = catName;
		_options = options;
	}
}

class Option
{
	public function new()
	{
		display = updateDisplay();
	}
	private var description:String = "";
	private var display:String;
	public final function getDisplay():String
	{
		return display;
	}

	public final function getDescription():String
	{
		return description;
	}

	// Returns whether the label is to be updated.
	public function press():Bool { return throw "stub!"; }
	private function updateDisplay():String { return throw "stub!"; }
	private function songThing() { return throw "stub!"; }
}

class ControlOption extends Option
{
	public function new()
	{
		super();
	}
	
	public override function press():Bool
	{
		trace("switch");
		FlxG.switchState(new KeyBindMenu());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Keybinds";
	}
}

class DownscrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return FlxG.save.data.downscroll ? "Downscroll" : "Upscroll";
	}
}

class InputOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.newInput = !FlxG.save.data.newInput;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return FlxG.save.data.newInput ? "Kade Engine Input" : "Original Input";
	}
}

class CpuStrums extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.cpuStrums = !FlxG.save.data.cpuStrums;
		
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return  FlxG.save.data.cpuStrums ? "Light CPU Strums" : "CPU Strums stay static";
	}

}

class Colour extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.colour = !FlxG.save.data.colour;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return FlxG.save.data.colour ? 'Color bar by Character' : 'Color bar classic';
	}
}

class Health extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.health = !FlxG.save.data.health;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return  !FlxG.save.data.health ? "Full Health Off" : "Full Health On";
	} //FlxG.save.data.betterIcons ? "Better Icons On" : "Better Icons Off"
}

class BotPlay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press():Bool
	{
		FlxG.save.data.botplay = !FlxG.save.data.botplay;
		trace('BotPlay : ' + FlxG.save.data.botplay);
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
		return "BotPlay " + (FlxG.save.data.botplay ? "on" : "off");
}

class Haxeflixel extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.skip = !FlxG.save.data.skip;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return  !FlxG.save.data.skip ? "Haxeflixel Intro On" : "Haxeflixel Intro Off";
	}
}

class BetterIcon extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.betterIcons = !FlxG.save.data.betterIcons;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return  FlxG.save.data.betterIcons ? "Better Icons On" : "Better Icons Off";
	}
}

class FlashingLightsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.flashing = !FlxG.save.data.flashing;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Flashing Lights " + (!FlxG.save.data.flashing ? "off" : "on");
	}
}

class Reset extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.resetButton = !FlxG.save.data.resetButton;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Reset Button " + (!FlxG.save.data.resetButton ? "off" : "on");
	}
}

class ResetSettings extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}
		
		TheData.resetSave();
		TheData.saveLoad();
		confirm = false;
		trace('All settings have been reset');
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return confirm ? "Confirm Settings Reset" : "Reset Settings";
	}
}

class SongTimeThing extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.songPosition = !FlxG.save.data.songPosition;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Song Timer " + (!FlxG.save.data.songPosition ? "off" : "on");
	}
}

class RemixThing extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.remix = !FlxG.save.data.remix;
		display = updateDisplay();
		FlxG.sound.music.stop();
		songThing();	
		return true;
	}

	private override function updateDisplay():String
	{
		return  !FlxG.save.data.remix ? "Gettin Freaky Original" : "Gettin Freaky Remix";
	}

	private override function songThing()
	{
		if(FlxG.save.data.remix)
		{
			if(!FlxG.sound.music.playing)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenuRemix'), 0);
				}
		}
		else
		{
			if(!FlxG.sound.music.playing)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				}
		}
	}
}


/*
class FPSCapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return "FPS Cap";
	}
	
	override function right():Bool {
		if (FlxG.save.data.fpsCap >= 290)
		{
			FlxG.save.data.fpsCap = 290;
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);
		}
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap + 10;
		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		return true;
	}

	override function left():Bool {
		if (FlxG.save.data.fpsCap > 290)
			FlxG.save.data.fpsCap = 290;
		else if (FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = Application.current.window.displayMode.refreshRate;
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap - 10;
		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		return true;
	}

	override function getValue():String
	{
		return "Current FPS Cap: " + FlxG.save.data.fpsCap + 
		(FlxG.save.data.fpsCap == Application.current.window.displayMode.refreshRate ? "Hz (Refresh Rate)" : "");
	}
}
*/