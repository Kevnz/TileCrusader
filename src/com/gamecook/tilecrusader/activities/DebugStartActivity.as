/**
 * Created by IntelliJ IDEA.
 * User: jfreeman
 * Date: 3/22/11
 * Time: 4:44 PM
 * To change this template use File | Settings | File Templates.
 */
package com.gamecook.tilecrusader.activities
{
    import com.gamecook.frogue.sprites.SpriteSheet;
    import com.gamecook.tilecrusader.enum.BooleanOptions;
    import com.gamecook.tilecrusader.enum.ClassOptions;
    import com.gamecook.tilecrusader.enum.DarknessOptions;
    import com.gamecook.tilecrusader.enum.GameModeOptions;
    import com.gamecook.tilecrusader.factory.NewGameFactory;
    import com.gamecook.tilecrusader.factory.SpriteSheetFactory;
    import com.jessefreeman.factivity.managers.IActivityManager;
    import com.jessefreeman.factivity.managers.SingletonManager;

    public class DebugStartActivity extends AdvancedActivity
    {

        public function DebugStartActivity(activityManager:IActivityManager, data:*)
        {
            super(activityManager, data);
        }


        override public function onStart():void
        {
            super.onStart();

            // this allows you to jump right into a newly generated game,
            // use this area to configure the ActiveGameState
            NewGameFactory.createCofferBreakGame(ClassOptions.getValues(),
                    DarknessOptions.getValues(),
                    GameModeOptions.getValues(),
                /*MapSizeOptions.getValues(),*/[20],
                    BooleanOptions.getTFOptions(),
                /*BooleanOptions.getTFOptions()*/[true]);

            SpriteSheetFactory.parseSpriteSheet(SingletonManager.getClassReference(SpriteSheet) as SpriteSheet);

            nextActivity(MapLoadingActivity);
        }
    }
}
