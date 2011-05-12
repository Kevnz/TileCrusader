/**
 * Created by IntelliJ IDEA.
 * User: Jesse Freeman
 * Date: 2/19/11
 * Time: 9:59 PM
 * To change this template use File | Settings | File Templates.
 */
package com.gamecook.tilecrusader.activities
{
    import com.bit101.components.Label;
    import com.gamecook.tilecrusader.sounds.TCSoundClasses;
    import com.gamecook.tilecrusader.states.ActiveGameState;
    import com.jessefreeman.factivity.activities.ActivityManager;

    public class GameOverActivity extends AdvancedActivity
    {
        private var activeGameState:ActiveGameState;

        public function GameOverActivity(activityManager:ActivityManager, data:* = null)
        {
            super(activityManager, data);
        }

        override protected function onCreate():void
        {
            soundManager.destroySounds(true);

            activeGameState = new ActiveGameState();
            loadState();

            super.onCreate();

            soundManager.play(TCSoundClasses.DeathTheme);

            var tf:Label = new Label(this, 0, 0, "You were killed!");
            tf.x = (fullSizeWidth - tf.width) * .5;
            tf.y = (fullSizeHeight - tf.height) * .5;
            addChild(tf);

            //TODO show stats before clearing this out.

            //TODO save player name and score

            activeGameState.clear();

            startNextActivityTimer(StartActivity, 5);

        }

        override public function loadState():void
        {
            activeGameState.load();
        }
    }
}
