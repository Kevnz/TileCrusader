/*
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 * /
 */

/**
 * Created by IntelliJ IDEA.
 * User: Jesse Freeman
 * Date: 2/25/11
 * Time: 12:15 AM
 * To change this template use File | Settings | File Templates.
 */
package com.gamecook.tilecrusader.activities
{
    import com.bit101.components.Label;
    import com.bit101.components.PushButton;
    import com.jessefreeman.factivity.activities.BaseActivity;
    import com.jessefreeman.factivity.activities.IActivityManager;

    import flash.events.MouseEvent;
    import flash.text.TextFieldAutoSize;

    public class WarningActivity extends BaseActivity
    {
        public function WarningActivity(stateManager:IActivityManager, date:*)
        {
            super(stateManager, date);
        }

        override protected function onCreate():void
        {
            super.onCreate();

            var warning:String = "WARNING!!!\n\nThis game is what we would call Alpha software. You may know Beta as in almost ready, will this is not that. \n\nPlease take that into consideration as you play the game.";

            var tf:Label = new Label(this, 0, 50, warning);
            tf.autoSize = TextFieldAutoSize
            tf.textField.wordWrap = true;
            tf.textField.multiline = true;
            tf.textField.width = 280;
            tf.x = (fullSizeWidth - tf.textField.width) * .5;

            var btn:PushButton = new PushButton(this, 0, tf.textField.y + tf.textField.height + 100, "Ok, I get it!", onAccept);
            btn.x = (fullSizeWidth - btn.width) * .5;

        }

        private function onAccept(event:MouseEvent):void
        {
            nextActivity(StartActivity);
        }
    }
}
