/**
 * Created by IntelliJ IDEA.
 * User: Jesse Freeman
 * Date: 2/6/11
 * Time: 11:40 AM
 * To change this template use File | Settings | File Templates.
 */
package com.gamecook.minutequest.factory
{
    import com.gamecook.minutequest.tiles.TileTypes;
    import com.gamecook.minutequest.tiles.BaseTile;

    import flash.utils.getDefinitionByName;

    public class TileFactory
    {

        protected var singletons:Array = [];
        private var tileTypes:TileTypes;

        public function TileFactory(tileTypes:TileTypes)
        {
            this.tileTypes = tileTypes;
        }

        public function createTile(value:String, uniqueID:String = null):BaseTile
        {
            var instance:BaseTile;

            instance = uniqueID ? returnInstance(value, uniqueID) : createInstance(value);

            return instance;
        }

        private function returnInstance(value:String, uniqueID:String):BaseTile
        {
            if(!singletons[uniqueID])
            {
                singletons[uniqueID] = createInstance(value)
            }

            return singletons[uniqueID];
        }

        private function createInstance(value:String):BaseTile
        {
            var template:Object = tileTypes.getTileTemplate(value);
            if(!template)
                return null;

            var classReference:Class;
            try
            {
                classReference = getDefinitionByName(template.classPath) as Class;
            }
            catch(error:Error)
            {
                classReference = BaseTile;
            }

            var instance:BaseTile = new classReference;

            if(instance.hasOwnProperty("parseObject"))
                instance["parseObject"](template);

            return instance;
        }

    }
}
