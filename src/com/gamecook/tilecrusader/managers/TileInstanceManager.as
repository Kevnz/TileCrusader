/**
 * Created by IntelliJ IDEA.
 * User: Jesse Freeman
 * Date: 2/8/11
 * Time: 8:04 PM
 * To change this template use File | Settings | File Templates.
 */
package com.gamecook.tilecrusader.managers
{
import com.gamecook.tilecrusader.factory.ITileFactory;
import com.gamecook.tilecrusader.serialize.ISerializeToObject;
import com.gamecook.tilecrusader.tiles.BaseTile;

public class TileInstanceManager implements ISerializeToObject
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
                trace("Create new Tile for", type, uniqueID);

                singletons[uniqueID] = factory.createTile(type);
                singletons[uniqueID].id = uniqueID;
                singletons[uniqueID].type = type;
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

        public function removeInstance(uID:String):void
        {
            delete singletons[uID];
        }

        public function clear():void
        {
            singletons.length = 0;
        }

        public function parseObject(value:Object):void
        {
            if(value.instances)
            {
                var tmpInstances:Array = value.instances;
                var total:int = tmpInstances.length;
                var i:int;
                var instanceTemplate:Object;

                for(i = 0; i < total; i++)
                {
                    instanceTemplate = tmpInstances[i];
                    getInstance(instanceTemplate.id,  instanceTemplate.type, instanceTemplate);
                }
            }
        }

        public function toObject():Object
        {
            var obj:Object = {};
            obj.instances = [];
            var baseTile:BaseTile;
            for each(baseTile in singletons)
            {
                if(baseTile)
                    obj.instances.push(baseTile.toObject());
            }
            return obj;
        }

        public function replaceInstance(uID:String, value:BaseTile):void
        {
            singletons[uID] = value;
        }
    }
}
