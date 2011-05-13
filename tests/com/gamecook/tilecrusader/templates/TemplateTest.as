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
 * Date: 3/3/11
 * Time: 11:10 PM
 * To change this template use File | Settings | File Templates.
 */
package com.gamecook.tilecrusader.templates
{
    import com.gamecook.frogue.templates.Template;
    import com.gamecook.frogue.templates.TemplateProperties;

    import org.flexunit.Assert;

    public class TemplateTest
    {
        public function TemplateTest()
        {
        }

        [Test]
        public function nextPropertyTest():void
        {
            var template:Template = new Template("TestA",[TemplateProperties.LIFE, TemplateProperties.ATTACK, TemplateProperties.DEFENSE])

            Assert.assertEquals(template.nextProperty(), TemplateProperties.LIFE);
            Assert.assertEquals(template.nextProperty(), TemplateProperties.ATTACK);
            Assert.assertEquals(template.nextProperty(), TemplateProperties.DEFENSE);
            Assert.assertEquals(template.nextProperty(), TemplateProperties.LIFE);
        }

        [Test]
        public function nextSinglePropertyTest():void
        {
            var template:Template = new Template("TestB",[TemplateProperties.LIFE])

            Assert.assertEquals(template.nextProperty(), TemplateProperties.LIFE);
            Assert.assertEquals(template.nextProperty(), TemplateProperties.LIFE);
            Assert.assertEquals(template.nextProperty(), TemplateProperties.LIFE);
            Assert.assertEquals(template.nextProperty(), TemplateProperties.LIFE);

        }
    }
}
