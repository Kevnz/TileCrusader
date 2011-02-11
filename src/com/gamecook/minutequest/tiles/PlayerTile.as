/**
 * Created by IntelliJ IDEA.
 * User: Jesse Freeman
 * Date: 2/1/11
 * Time: 10:54 AM
 * To change this template use File | Settings | File Templates.
 */
package com.gamecook.minutequest.tiles
{
    public class PlayerTile extends MonsterTile
    {
        protected var weapon:String;
        protected var armor:String;
        private var gold:int = 0;
        private var potions:int = 0;

        public function PlayerTile()
        {
        }

        public function setWeapon(value:String):void
        {
            weapon = value;
        }

        public function getWeapon(value:String):String
        {
            return weapon;
        }

        public function setArmor(value:String):void
        {
            armor = value;
        }

        public function getArmor():String
        {
            return armor;
        }

        public function setGold(value:int):void
        {
            gold = value;
        }

        public function getGold():int
        {
            return gold;
        }

        public function addGold(value:int):void
        {
            gold += value;
        }

        public function subtractGold(value:int):void
        {
            gold -= value;
            if(gold < 0) gold = 0;
        }

        public function getPotions():int
        {
            return potions;
        }

        public function setPotions(value:int):void
        {
            potions = value;
        }

        override public function parseObject(obj:Object):void
        {
            super.parseObject(obj);

            if(obj.hasOwnProperty("weapon"))
                weapon = obj.weapon;
            if(obj.hasOwnProperty("armor"))
                armor = obj.armor;
            if(obj.hasOwnProperty("gold"))
                gold = obj.gold;
            if(obj.hasOwnProperty("potions"))
                potions = obj.potions;
        }

        public function addPotion(value:int):void
        {
            potions += value;
        }
    }
}
