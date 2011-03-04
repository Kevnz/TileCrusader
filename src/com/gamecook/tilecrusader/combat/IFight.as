/**
 * Created by IntelliJ IDEA.
 * User: Jesse Freeman
 * Date: 2/1/11
 * Time: 10:54 AM
 * To change this template use File | Settings | File Templates.
 */
package com.gamecook.tilecrusader.combat
{

    import com.gamecook.tilecrusader.tiles.ITile;

    public interface IFight extends ITile
    {

        function getLife():int;

        function subtractLife(value:int):void;

        function addLife(value:int):void;

        function getHitValue():int;

        function getDefenseValue():int;

        function getMaxLife():int;

        function addAttackRoll(i:int):void;

        function addDefenseRoll(i:int):void;

        function getCharacterPoints():int;

        function setCharacterPoints(value:int):void;

        function getAttackRolls():int;

        function getDefenseRolls():int;
    }
}
