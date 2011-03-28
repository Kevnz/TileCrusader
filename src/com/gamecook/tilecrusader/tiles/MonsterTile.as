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

	public class MonsterTile extends BaseTile implements ICombatant, IMonster
    {
        private var _life:int = 1;
        protected var maxLife:int = 1;
        protected var dice:ICombatDice;
        protected var attackRoll:int = 1;
        protected var defenseRoll:int = 1;
        protected var characterPoints:int = 0;
        private var pointPercent:Number = 0;

        public function MonsterTile()
        {
        }

        public function getDice():ICombatDice
        {
            if(!dice)
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
            if(obj.hasOwnProperty("maxLife"))
                maxLife = life = obj.maxLife;

            if(obj.hasOwnProperty("life"))
                life = obj.life;

            if(obj.hasOwnProperty("attackRoll"))
                attackRoll = obj.attackRoll;

            if(obj.hasOwnProperty("defenseRoll"))
                defenseRoll = obj.defenseRoll;

            if(obj.hasOwnProperty("characterPoints"))
                characterPoints = obj.characterPoints;

            if(obj.hasOwnProperty("pointPercent"))
                pointPercent = Number(obj.pointPercent);

        }

        public function subtractLife(value:int):void
        {
            life -= value;
            if(life < 0) life = 0;
        }

        public function addLife(value:int):void
        {
            life += value;
            if(life > maxLife) life = maxLife;
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

        override public function toObject():Object{
            var tmpObject = super.toObject();
            tmpObject.maxLife = maxLife;
            tmpObject.life = life;
            tmpObject.attackRoll = attackRoll;
            tmpObject.defenseRoll = defenseRoll;
            tmpObject.characterPoints = characterPoints
            tmpObject.pointPercent = pointPercent

            return tmpObject;
        }

	    protected function get life():int
	    {
		    return _life;
	    }

	    protected function set life(value:int):void
	    {
		    if(value == 0)
		    {
			    if(onDie != null)
			    {
				    onDie(this);
				    onDie = null;
			    }
		    }
		    _life = value;
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
		    if(life > 0)
		    {
			    attemptDamageDefender(monster);
			    onDefend();
		    }
	    }

	    public function attack(monster:ICombatant, useChance:Boolean):void
	    {
		    var attackResult:AttackResult;
		    if(useChance)
		    {
			    if(Math.random() >= .5)
			    {
				    attackThenDefend(monster);
			    }
			    else
			    {
				    monster.attack(this, false);
			    }
		    }
		    else
		    {
			    attackThenDefend(monster);
		    }
	    }

		private function attackThenDefend(defender:ICombatant):void
		{
			attemptDamageDefender(defender);
			var defendResult:AttackResult;
			//TODO: Do we need monster defend info?
			if(defender) //TODO: do we null-out the monster when it dies?
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
		    if (hitValue > defenseValue)
		    {
			    success = true;
			    difference = hitValue - defenseValue;
		    }
		    var attackResult:AttackResult = new AttackResult(this, defender, success, hitValue, difference);
		    onAttack(attackResult);

		    defender.subtractLife(difference); //the defender should die after the attack
	    }
    }
}
