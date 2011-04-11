/**
 * Created by IntelliJ IDEA.
 * User: Jesse Freeman
 * Date: 2/1/11
 * Time: 11:04 AM
 * To change this template use File | Settings | File Templates.
 */
package com.gamecook.tilecrusader.tiles
{
    import com.gamecook.tilecrusader.combat.AttackResult;
    import com.gamecook.tilecrusader.combat.ICombatant;
    import com.gamecook.tilecrusader.dice.CombatDice;
    import com.gamecook.tilecrusader.dice.ICombatDice;
    import com.gamecook.tilecrusader.enum.SlotsEnum;
    import com.gamecook.tilecrusader.equipment.IEquipable;

    public class MonsterTile extends BaseTile implements IMonster
    {
        private var _life:int = 1;
        protected var maxLife:int = 1;
        protected var dice:ICombatDice;
        protected var attackRoll:int = 1;
        protected var defenseRoll:int = 1;
        protected var characterPoints:int = 0;
        protected var pointPercent:Number = 0;
        protected var equipmentSlots:Array = [];
        protected var spriteID:String = "";

        public function MonsterTile()
        {
            configureSlots()
        }

        private function configureSlots():void
        {
            equipmentSlots[SlotsEnum.WEAPON] = null;
            equipmentSlots[SlotsEnum.SHIELD] = null;
            equipmentSlots[SlotsEnum.ARMOR] = null;
            equipmentSlots[SlotsEnum.HELMET] = null;
            equipmentSlots[SlotsEnum.SHOE] = null;
        }

        /* public function setSpriteID(value:String):void
         {

         spriteID = TileTypes.getTileSprite(equipmentSlot0.tileID);
         }*/

        public function getSpriteID():String
        {
            return spriteID;
        }

        public function getDice():ICombatDice
        {
            if (!dice)
                dice = new CombatDice();
            return dice;
        }

        public function setAttackRolls(value:int):void
        {
            attackRoll = value;
        }

        public function getAttackRolls():int
        {
            return attackRoll;
        }

        public function setDefenseRolls(value:int):void
        {
            defenseRoll = value;
        }

        public function getDefenceRolls():int
        {
            return defenseRoll;
        }

        public function getLife():int
        {
            return life;
        }

        public function setLife(value:int):void
        {
            life = value;
        }

        public function getMaxLife():int
        {
            return maxLife;
        }

        public function setMaxLife(value:int):void
        {
            maxLife = value;
        }

        public function getHitValue():int
        {
            return getDice().attackRoll(attackRoll);
        }

        public function getDefenseValue():int
        {
            return getDice().monsterDefenseRoll(defenseRoll);
        }

        override public function parseObject(obj:Object):void
        {
            super.parseObject(obj);

            // By default life is always set to same value as maxLife
            if (obj.hasOwnProperty("maxLife"))
                maxLife = life = obj.maxLife;

            if (obj.hasOwnProperty("life"))
                life = obj.life;

            if (obj.hasOwnProperty("attackRoll"))
                attackRoll = obj.attackRoll;

            if (obj.hasOwnProperty("defenseRoll"))
                defenseRoll = obj.defenseRoll;

            if (obj.hasOwnProperty("characterPoints"))
                characterPoints = obj.characterPoints;

            if (obj.hasOwnProperty("pointPercent"))
                pointPercent = Number(obj.pointPercent);

        }

        override public function toObject():Object
        {
            var tmpObject:Object = super.toObject();
            tmpObject.maxLife = maxLife;
            tmpObject.life = life;
            tmpObject.attackRoll = attackRoll;
            tmpObject.defenseRoll = defenseRoll;
            tmpObject.characterPoints = characterPoints;
            tmpObject.pointPercent = pointPercent;

            return tmpObject;
        }

        public function subtractLife(value:int):void
        {
            life -= value;
            if (life < 0) life = 0;
        }

        public function addLife(value:int):void
        {
            life += value;
            if (life > maxLife) life = maxLife;
        }

        public function addAttackRoll(i:int):void
        {
            attackRoll ++;
        }

        public function addDefenseRoll(i:int):void
        {
            defenseRoll ++;
        }

        public function getCharacterPoints():int
        {
            return characterPoints;
        }

        public function setCharacterPoints(value:int):void
        {
            characterPoints = value;
        }

        public function getCharacterPointPercent():Number
        {
            return pointPercent;
        }

        public function getDefenseRolls():int
        {
            return defenseRoll;
        }

        public function addMaxLife(value:int):void
        {
            maxLife ++;
            life = maxLife;
        }


        protected function get life():int
        {
            return _life;
        }

        protected function set life(value:int):void
        {
            if (value == 0) {
                if (onDie != null) {
                    onDie(this);
                    onDie = null;
                }
            }
            _life = value;
        }

        public function get isDead():Boolean
        {
            return life == 0;
        }


        protected var _onDie:Function;
        public function set onDie(value:Function):void
        {
            _onDie = value;
        }

        public function get onDie():Function
        {
            return _onDie;
        }

        private var _onAttack:Function;
        public function get onAttack():Function
        {
            return _onAttack;
        }

        public function set onAttack(value:Function):void
        {
            _onAttack = value;
        }


        private var _onDefend:Function;
        public function get onDefend():Function
        {
            return _onDefend;
        }

        public function set onDefend(value:Function):void
        {
            _onDefend = value;
        }

        public function defend(monster:ICombatant):void
        {
            if (life > 0) {
                attemptDamageDefender(monster);
                onDefend();
            }
        }

        public function attack(monster:ICombatant, useChance:Boolean):void
        {
            var attackResult:AttackResult;
            if (useChance) {
                if (Math.random() >= .5) {
                    attackThenDefend(monster);
                }
                else {
                    monster.attack(this, false);
                }
            }
            else {
                attackThenDefend(monster);
            }
        }

        protected function attackThenDefend(defender:ICombatant):void
        {
            attemptDamageDefender(defender);
            var defendResult:AttackResult;
            //TODO: Do we need monster defend info?
            if (defender) //TODO: do we null-out the monster when it dies?
            {
                defender.defend(this);
            }
        }

        private function attemptDamageDefender(defender:ICombatant):void
        {
            //TODO: weapon modifiers, etc
            var success:Boolean;
            var difference:int = 0;
            var hitValue:int = getHitValue();
            var defenseValue:int = getDefenseValue();
            if (hitValue > defenseValue) {
                success = true;
                difference = hitValue - defenseValue;
            }
            var attackResult:AttackResult = new AttackResult(this, defender, success, hitValue, difference);
            onAttack(attackResult);

            defender.subtractLife(difference); //the defender should die after the attack
        }

        private function updateCustomSpriteID():void
        {
            //TODO this should default to the tile's graphic vs having it in the map
            spriteID = "";

            if (getWeaponSlot())
                spriteID = spriteID.concat(TileTypes.getTileSprite(getWeaponSlot().tileID));

            if (getArmorSlot())
                spriteID = spriteID.concat(TileTypes.getTileSprite(getArmorSlot().tileID));

            if (getShieldSlot())
                spriteID = spriteID.concat(TileTypes.getTileSprite(getShieldSlot().tileID));

            if (getHelmetSlot())
                spriteID = spriteID.concat(TileTypes.getTileSprite(getHelmetSlot().tileID));

            if (getShoeSlot())
                spriteID = spriteID.concat(TileTypes.getTileSprite(getShoeSlot().tileID));

            trace("Sprite ID", spriteID);
        }

        public function equip(item:IEquipable):IEquipable
        {
            var droppedItem:IEquipable = null;//equipmentSlots[0] != null? equipmentSlots[0] : null;

            //TODO need to clean all this mess up
            if (item.slotID() == SlotsEnum.WEAPON)
            {
                droppedItem = getWeaponSlot();
                setWeaponSlot(item as IEquipable);
            }

            updateCustomSpriteID();

            return droppedItem;
        }

        public function canEquip(item:IEquipable, slot:String):Boolean
        {
            return (equipmentSlots[slot]);
        }

        public function setWeaponSlot(value:IEquipable):void
        {
            equipmentSlots[SlotsEnum.WEAPON] = value;
        }

        public function getWeaponSlot():IEquipable
        {
            return equipmentSlots[SlotsEnum.WEAPON];
        }

        public function setHelmetSlot(value:IEquipable):void
        {
            equipmentSlots[SlotsEnum.HELMET] = value;
        }

        public function getHelmetSlot():IEquipable
        {
            return equipmentSlots[SlotsEnum.HELMET];
        }

        public function setArmorSlot(value:IEquipable):void
        {
            equipmentSlots[SlotsEnum.ARMOR] = value;
        }

        public function getArmorSlot():IEquipable
        {
            return equipmentSlots[SlotsEnum.ARMOR];
        }

        public function setShieldSlot(value:IEquipable):void
        {
            equipmentSlots[SlotsEnum.SHIELD] = value;
        }

        public function getShieldSlot():IEquipable
        {
            return equipmentSlots[SlotsEnum.SHIELD];
        }

        public function setShoeSlot(value:IEquipable):void
        {
            equipmentSlots[SlotsEnum.SHOE] = value;
        }

        public function getShoeSlot():IEquipable
        {
            return equipmentSlots[SlotsEnum.SHOE];
        }
    }
}
