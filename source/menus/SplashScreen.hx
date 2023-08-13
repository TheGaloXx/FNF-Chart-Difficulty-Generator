package menus;

import Objects;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRect;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;

class SplashScreen extends flixel.FlxState
{
    private var note:FlxSprite;
    private var time:Float = 0;
    private var transitioning:Bool = false;
    private var rect:FlxRect;
    private var notes:FlxTypedGroup<Note>;
    private var credits:Text;

    override function create():Void
    {
        rect = new FlxRect();

        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.active = false;
        add(bg);

        add(notes = new FlxTypedGroup<Note>());

        var grayNote = new FlxSprite();
        grayNote.active = false;
        grayNote.frames = FlxAtlasFrames.fromSparrow('extras/note.png', 'extras/note.xml');
        grayNote.animation.addByIndices('idle', 'note', [0], '', 0, false);
        grayNote.animation.play('idle');
        grayNote.screenCenter();
        grayNote.color = FlxColor.GRAY;
        grayNote.alpha = 0.5;
        grayNote.antialiasing = true;
        add(grayNote);

        // tried using grayNote.clone() but honestly this is simpler
        note = new FlxSprite();
        note.frames = FlxAtlasFrames.fromSparrow('extras/note.png', 'extras/note.xml');
        note.animation.addByIndices('idle', 'note', [0], '', 0, false);
        note.animation.addByIndices('finish', 'note', [for (i in 1...36) i], '', 24, false);
        note.animation.play('idle');
        note.screenCenter();
        note.antialiasing = true;
        add(note);

        final text = "FNF' Chart Difficulty Generator by TheGalo X       v0.0.4";
        var creditsGray = new Text(5, FlxG.height - 20, FlxG.width - 5, text, 18, LEFT, FlxColor.WHITE, OUTLINE, FlxColor.BLACK, 1);
        creditsGray.alpha = 0.5;
        add(creditsGray);

        add(credits = new Text(5, FlxG.height - 20, FlxG.width - 5, text, 18, LEFT, FlxColor.WHITE, OUTLINE, FlxColor.BLACK, 1));
    }

    override function update(elapsed:Float):Void
    {
        FlxG.watch.addQuick('Time:', time);

        #if debug
		if (FlxG.mouse.wheel != 0)
			FlxG.camera.zoom += (FlxG.mouse.wheel / 10);
		#end

        notes.update(elapsed);
        notes.sort(FlxSort.byY);

        if (transitioning) return;

        super.update(elapsed);

        time += elapsed * 100;

        if (Math.floor(time) % 3 == 0) spawnNote();

		note.clipRect = rect.set(0, 0, time, FlxG.height);
        credits.clipRect = rect;

        if (time >= FlxG.width)
        {
            transitioning = true;

            for (i in notes.members) FlxTween.tween(i, {"velocity.y": 0, alpha: 0.1, angularVelocity: 0}, 1.25);

            note.clipRect = null;
            credits.clipRect = null;
            rect = null;
            note.animation.play('finish');
            FlxG.camera.fade(FlxColor.BLACK, 2, false, function() FlxG.switchState(new PlayState()));
        }
    }

    private function spawnNote():Void
    {
        trace('Spawning note! Group members: ${notes.members.length}');
        var daNote = notes.recycle(Note.new);
        daNote.setup();
        notes.add(daNote);
    }

    override function destroy():Void
    {
        super.destroy();

        note = null;
        notes = null;
        credits = null;
    }
}