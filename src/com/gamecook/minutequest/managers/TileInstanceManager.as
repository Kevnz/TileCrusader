/**
 * Created by IntelliJ IDEA.
 * User: Jesse Freeman
 * Date: 2/8/11
 * Time: 8:04 PM
 * To change this template use File | Settings | File Templates.
 */
package com.gamecook.minutequest.managers
{
    import com.gamecook.minutequest.factory.ITileFactory;
    import com.gamecook.minutequest.tiles.BaseTile;

    public class TileInstanceManager
    {
        protected var singletons:Array = [];
        private var factory:ITileFactory;

        public function TileInstanceManager(factory:ITileFactory)
        {
            this.factory = factory;
        }

        public function getInstance(uniqueID:String, type:String = "null", values:Object = null):BaseTile
        {
            if(!singletons[uniqueID])
            {
                singletons[uniqueID] = factory.createTile(type);
            }

            if(values)
                BaseTile(singletons[uniqueID]).parseObject(values);

            return singletons[uniqueID];
        }

        public function getInstances():Array
        {
            return singletons;
        }

        public function toString():String
        {
            return "TileInstanceManager[]";
        }


        public function hasInstance(uniqueID:String):Boolean
        {
            return singletons[uniqueID]
        }
    }
}
