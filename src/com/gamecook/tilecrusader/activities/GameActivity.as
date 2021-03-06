/**
 * Created by IntelliJ IDEA.
 * User: Jesse Freeman
 * Date: 2/19/11
 * Time: 9:58 PM
 * To change this template use File | Settings | File Templates.
 */
package com.gamecook.tilecrusader.activities
{
    import com.bit101.components.Label;
    import com.gamecook.frogue.combat.AttackResult;
    import com.gamecook.frogue.combat.DeathMessageFactory;
    import com.gamecook.frogue.combat.ICombatant;
    import com.gamecook.frogue.enum.SlotsEnum;
    import com.gamecook.frogue.equipment.IEquipable;
    import com.gamecook.frogue.helpers.MovementHelper;
    import com.gamecook.frogue.io.Controls;
    import com.gamecook.frogue.io.IControl;
    import com.gamecook.frogue.managers.TileInstanceManager;
    import com.gamecook.frogue.maps.MapAnalytics;
    import com.gamecook.frogue.maps.RandomMap;
    import com.gamecook.frogue.renderer.AbstractMapRenderer;
    import com.gamecook.frogue.sprites.SpriteSheet;
    import com.gamecook.frogue.templates.Template;
    import com.gamecook.frogue.templates.TemplateApplicator;
    import com.gamecook.frogue.templates.TemplateCollection;
    import com.gamecook.frogue.templates.TemplateProperties;
    import com.gamecook.frogue.tiles.EquipmentTile;
    import com.gamecook.frogue.tiles.PlayerTile;
    import com.gamecook.frogue.tiles.TileTypes;
    import com.gamecook.tilecrusader.enum.DarknessOptions;
    import com.gamecook.tilecrusader.enum.GameModeOptions;
    import com.gamecook.tilecrusader.factories.TCTileFactory;
    import com.gamecook.tilecrusader.iterators.TreasureIterator;
    import com.gamecook.tilecrusader.maps.TCMapSelection;
    import com.gamecook.tilecrusader.renderer.MQMapBitmapRenderer;
    import com.gamecook.tilecrusader.renderer.PreviewMapRenderer;
    import com.gamecook.tilecrusader.sounds.TCSoundClasses;
    import com.gamecook.tilecrusader.states.ActiveGameState;
    import com.gamecook.tilecrusader.threads.effects.EaseScrollBehavior;
    import com.gamecook.tilecrusader.views.CharacterSheetView;
    import com.jessefreeman.factivity.activities.ActivityManager;
    import com.jessefreeman.factivity.managers.SingletonManager;
    import com.jessefreeman.factivity.threads.effects.Quake;
    import com.jessefreeman.factivity.threads.effects.TypeTextEffect;
    import com.jessefreeman.factivity.utils.DeviceUtil;
    import com.jessefreeman.factivity.utils.TimeMethodExecutionUtil;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.ui.Keyboard;

    public class GameActivity extends AdvancedActivity implements IControl
    {


        public var map:RandomMap;
        private var renderer:MQMapBitmapRenderer;
        private var renderWidth:int;
        private var renderHeight:int;
        private var darknessWidth:int;
        private var darknessHeight:int;
        private var controls:Controls;
        private var movementHelper:MovementHelper;
        private var invalid:Boolean = true;
        private var player:PlayerTile;
        private var tileInstanceManager:TileInstanceManager;
        private var treasureIterator:TreasureIterator;
        private var gameMode:String;
        private var hasArtifact:Boolean;
        private var spriteSheet:SpriteSheet = SingletonManager.getClassReference(SpriteSheet);
        private var mapBitmap:Bitmap;
        private var mapSelection:TCMapSelection;

        private var display:Sprite;
        private var overlayLayer:Sprite;
        private var statusLabel:Label;
        private var status:String = "";
        private static const TILE_SIZE:int = 32;
        private var scale:int = 1;
        private var tileWidth:int;
        private var tileHeight:int;
        private var viewPortWidth:int = 0;
        private var viewPortHeight:int = 0;
        private const MESSAGE_HEIGHT:int = 40;
        private var cashPool:int = 0;
        private var cashRange:int = 10;
        private var treasurePool:Array;
        private var quakeEffect:Quake;
        private var textEffect:TypeTextEffect;

        private var pollKeyPressCounter:int = 0;
        private var keyPressDelay:int = 0;
        private var _nextMove:Point;
        private var monstersDropTreasure:Boolean;
        private var templateApplicator:TemplateApplicator;
        private var monsterTemplates:TemplateCollection;
        private var exploredTiles:Number;
        private var activeGameState:ActiveGameState;
        private var analytics:MapAnalytics;
        private var monstersLeft:int;

        private var visibility:int;
        private var currentPoint:Point;
        private var currentuID:String;
        private var mouseDown:Boolean;
        private var previewMapShape:Shape;
        private var previewMapRenderer:PreviewMapRenderer;
        private var scrollThread:EaseScrollBehavior;
        private var characterSheet:CharacterSheetView;

        public function GameActivity(activityManager:ActivityManager, data:* = null)
        {
            super(activityManager, data);
        }

        override protected function onCreate():void
        {

            activeGameState = new ActiveGameState();
            loadState();

            super.onCreate();

            display = addChild(new Sprite()) as Sprite;
            overlayLayer = addChild(new Sprite()) as Sprite;

            map = data.mapInstance;
            analytics = new MapAnalytics(map);

            TimeMethodExecutionUtil.execute("updateMapAnalytics", analytics.update);
            var remainingMonsters:int = TimeMethodExecutionUtil.execute("remainingMonsters", analytics.getTotal, "1", "2", "3", "4", "5", "6", "7", "8", "9");
            //trace("Monsters in MapAnalytics", remainingMonsters);


            gameMode = activeGameState.gameType;
            treasurePool = activeGameState.treasurePool;
            cashPool = activeGameState.cashPool;
            cashRange = activeGameState.cashRange;
            monstersDropTreasure = activeGameState.monstersDropTreasure;

            // Configure Tile, Render and Darkness size
            tileWidth = tileHeight = TILE_SIZE * scale;
            viewPortWidth = (fullSizeWidth);// - SIDEBAR_WIDTH);
            viewPortHeight = fullSizeHeight - tileHeight;


            renderWidth = Math.floor(viewPortWidth / tileWidth);
            renderHeight = Math.floor((viewPortHeight - tileHeight) / tileHeight);

            darknessWidth = 5;
            darknessHeight = 4;
            visibility = activeGameState.player.visibility;

            movementHelper = new MovementHelper(map);

            configureMonsterTemplates();


            tileInstanceManager = new TileInstanceManager(new TCTileFactory(monsterTemplates, templateApplicator, activeGameState.player.characterPoints, 0));

            mapSelection = new TCMapSelection(map, renderWidth, renderHeight, visibility, tileInstanceManager);

            if (activeGameState.mapSelection)
            {
                mapSelection.parseObject(activeGameState.mapSelection);
            }

            // Apply darkness setting
            switch (activeGameState.darkness)
            {
                case DarknessOptions.TORCH:
                    mapSelection.tourchMode(true);
                    break;
            }

            mapBitmap = new Bitmap(new BitmapData(viewPortWidth / scale, viewPortHeight / scale, false, 0x000000));
            mapBitmap.scaleX = mapBitmap.scaleY = scale;
            mapBitmap.y = MESSAGE_HEIGHT;
            display.addChild(mapBitmap);


            renderer = new MQMapBitmapRenderer(mapBitmap.bitmapData, spriteSheet, tileInstanceManager);

            //TODO this should be moved into the MapLoadingActivity
            if (activeGameState.tileInstanceManager)
                tileInstanceManager.parseObject(activeGameState.tileInstanceManager);

            player = tileInstanceManager.getInstance("@", "@", activeGameState.player) as PlayerTile;
            player.onDie = onPlayerDie;
            player.onAttack = onPlayerAttack;
            player.onDefend = onPlayerDefend;
            player.onUsePotion = onPlayerUsePotion;


            //TODO need to make this it's own class
            statusLabel = new Label(this, 5, 2, "");
            statusLabel.textField.width = viewPortWidth - 5;
            statusLabel.textField.autoSize = "none";
            statusLabel.textField.height = MESSAGE_HEIGHT;
            statusLabel.textField.multiline = true;
            statusLabel.textField.wordWrap = true;
            statusLabel.x = 5;
            statusLabel.y = 2;
            overlayLayer.addChild(statusLabel);

            addStatusMessage(activeGameState.startMessage);

            configureGame();

            //TODO May need to slow this down for mobile
            keyPressDelay = .25 * MILLISECONDS;

            /*virtualKeys = new VirtualKeysView(this);
             addChild(virtualKeys);
             virtualKeys.x = fullSizeWidth - (virtualKeys.width + 10);
             virtualKeys.y = fullSizeHeight - (virtualKeys.height + 10);*/
            //virtualKeys.scaleX = virtualKeys.scaleY = .5;

            if (DeviceUtil.os != DeviceUtil.IOS)
            {
                quakeEffect = new Quake(display);
                textEffect = new TypeTextEffect(statusLabel.textField, onTextEffectUpdate);
            }

            scrollThread = new EaseScrollBehavior(renderer, onScrollUpdate, onScrollComplete);

            //TODO this isn't working look into it.
            /*if(activeGameState.startMessage)
             PopUpManager.showOverlay(new AlertPopUpWindow(activeGameState.startMessage));*/


            previewMapShape = new Shape();

            previewMapShape.visible;
            addChild(previewMapShape);

            previewMapRenderer = new PreviewMapRenderer(previewMapShape.graphics, new Rectangle(0, 0, 3, 3));

            previewMapRenderer.renderMap(map);
            previewMapShape.x = fullSizeWidth - previewMapShape.width;
            //previewMapShape.y = fullSizeHeight - previewMapShape.height;
            
            characterSheet = addChild(new CharacterSheetView(player)) as CharacterSheetView;
            characterSheet.x = fullSizeWidth - characterSheet.width;
            previewMapShape.x = characterSheet.x + ((characterSheet.width - previewMapShape.width) * .5);
            previewMapShape.y = characterSheet.y + 100;
        }

        private function onScrollComplete():void
        {
            //trace("Scroll Complete");
            renderer.scrollX = 0;
            renderer.scrollY = 0;
        }

        private function onScrollUpdate():void
        {
            //trace("Scroll Update", renderer.scrollX, scrollThread.targetX);
            invalidate();
        }

        private function onPlayerDefend():void
        {

        }

        private function onPlayerAttack(attackResult:AttackResult):void
        {
            var message:String = formatAttackResultMessage(attackResult);
            addStatusMessage(message, false);
        }

        private function onPlayerUsePotion():void
        {
            soundManager.play(TCSoundClasses.PotionSound);
            addStatusMessage("You have taken a potion and restored your health.", true);
        }

        private function onPlayerDie(player:ICombatant):void
        {
            //stateManager(GameOverActivity);
            //TODO build stat Data Object
            startNextActivityTimer(GameOverActivity, 1);
        }

        private function onQuit():void
        {
            //TODO Took this out since it got called twice. May not need this call back.
            //saveState(null);
        }

        private function onKeyDown(event:KeyboardEvent):void
        {
            switch (event.keyCode)
            {
                case Keyboard.L:
                    cycleThroughLighting();
                    break;
                case Keyboard.P:
                    player.setLife(player.getMaxLife());
                    break;
            }

            invalidate();
        }

        private function cycleThroughLighting():void
        {
            var types:Array = [DarknessOptions.REVEAL, DarknessOptions.TORCH, DarknessOptions.NONE];
            var id:int = types.indexOf(activeGameState.darkness);
            id ++;
            if (id >= types.length)
                id = 0;
            var lightingFlags:Array;
            activeGameState.darkness = types[id];
            if (id == 0)
            {
                lightingFlags = [false, true, false];
            }
            else if (id == 1)
            {
                lightingFlags = [true, false, false];
            }
            else
            {
                lightingFlags = [false, false, true];
            }

            mapSelection.tourchMode(lightingFlags[0]);
            //mapSelection.fullLineOfSight(lightingFlags[1]);
            mapSelection.revealAll(lightingFlags[2]);

            statusLabel.text = "Changing lighting mode " + activeGameState.darkness;
        }

        private function configureMonsterTemplates():void
        {
            templateApplicator = new TemplateApplicator();
            monsterTemplates = new TemplateCollection();

            monsterTemplates.addTemplate("1", new Template("Regular", [TemplateProperties.LIFE, TemplateProperties.ATTACK, TemplateProperties.DEFENSE, TemplateProperties.LIFE]), 30);
            monsterTemplates.addTemplate("2", new Template("Tank", [TemplateProperties.LIFE, TemplateProperties.DEFENSE, TemplateProperties.LIFE, TemplateProperties.ATT_DEF]), 4);
            monsterTemplates.addTemplate("3", new Template("Chaos", [TemplateProperties.RANDOM]), 1);
            monsterTemplates.addTemplate("4", new Template("Brute", [TemplateProperties.ATTACK, TemplateProperties.ATTACK, TemplateProperties.DEFENSE, TemplateProperties.LIFE]), 3);
            monsterTemplates.addTemplate("5", new Template("Attack Specialist", [TemplateProperties.ATTACK, TemplateProperties.ATTACK, TemplateProperties.LIFE, TemplateProperties.DEFENSE]), 2);
            monsterTemplates.addTemplate("6", new Template("Defense Specialist", [TemplateProperties.DEFENSE, TemplateProperties.DEFENSE, TemplateProperties.LIFE, TemplateProperties.ATTACK]), 2);
            monsterTemplates.addTemplate("7", new Template("Life Specialist", [TemplateProperties.LIFE, TemplateProperties.LIFE, TemplateProperties.LIFE, TemplateProperties.ATT_DEF]), 3);
            monsterTemplates.addTemplate("8", new Template("Chaos Specialist", [TemplateProperties.RANDOM, TemplateProperties.LIFE, TemplateProperties.RANDOM, TemplateProperties.ATT_DEF]), 1);
        }

        private function onTextEffectUpdate():void
        {
            soundManager.play(TCSoundClasses.TypeSound);
        }

        private function configureGame():void
        {
            //mapSelection.clear();

            //tileInstanceManager.clear();

            treasureIterator = new TreasureIterator(treasurePool);

            movementHelper.startPosition(activeGameState.startPositionPoint);
        }

        //TODO need to clean up movement so it only happens once per second
        public function up():void
        {
            nextMove(MovementHelper.UP);
        }

        public function down():void
        {
            nextMove(MovementHelper.DOWN);
        }

        public function right():void
        {
            nextMove(MovementHelper.RIGHT);
        }

        public function left():void
        {
            nextMove(MovementHelper.LEFT);
        }

        private function nextMove(value:Point):void
        {
            if(!scrollThread.isRunning())
            {
                if (value.y == 1)
                {
                    scrollThread.targetX = 0;
                    scrollThread.targetY = -32;
                }
                else if (value.x == 1)
                {
                    scrollThread.targetX = -32;
                    scrollThread.targetY = 0;
                }
                else if (value.y == -1)
                {
                    scrollThread.targetX = 0;
                    scrollThread.targetY = 32;
                }
                else
                {

                    scrollThread.targetX = 32;
                    scrollThread.targetY = 0;
                }

                _nextMove = value;
            }
        }

        public function move(value:Point):void
        {

            if (player.isDead)
                return;

            var tmpPoint:Point = movementHelper.previewMove(value.x, value.y);

            if (tmpPoint != null)
            {
                var tile:String = map.getTileType(tmpPoint);

                switch (TileTypes.getTileType(tile))
                {
                    case TileTypes.IMPASSABLE:
                        //TODO need to make sure we don't call render here
                        soundManager.play(TCSoundClasses.WallHit);
                        return;
                    case TileTypes.MONSTER: case TileTypes.BOSS:
                    var uID:String = map.getTileID(tmpPoint.y, tmpPoint.x).toString();

                    var tmpTile:ICombatant = tileInstanceManager.getInstance(uID, tile) as ICombatant;

                    if (tmpTile is ICombatant)
                    {
                        currentPoint = tmpPoint;
                        currentuID = uID;
                        fight(tmpTile);
                    }
                    break;
                    case TileTypes.TREASURE:
                        openTreasure(tmpPoint);
                        break;
                    case TileTypes.PICKUP: case TileTypes.ARTIFACT:
                    pickup(tile, tmpPoint, value);
                    break;
                    case TileTypes.EQUIPMENT:

                        var wUID:String = map.getTileID(tmpPoint.y, tmpPoint.x).toString();
                        var tmpWeapon:EquipmentTile = tileInstanceManager.getInstance(wUID, tile) as EquipmentTile;

                        equip(player, tmpWeapon, wUID, tmpPoint, value);
                        break;
                    case TileTypes.EXIT:
                        movePlayer(value);
                        if (canFinishLevel())
                        {
                            //TODO gameover
                            //TODO play heroic theme here?
                            trace("Level Done");

                            onCompleteLevel(true);
                        }
                        else
                        {
                            //TODO let player leave the level, use a pop up to ask

                            //PopUpManager.showOverlay(new LeaveLevelPopUpWindow(onLeaveMap));
                            //addStatusMessage("You can not leave until you "+GameModeOptions.getGameModeDescription(gameMode))+".";
                        }
                        break;
                    default:
                        movePlayer(value);
                        break;
                }
                invalidate();
            }
            if (status.length > 0)
            {
                if (textEffect)
                {
                    textEffect.newMessage(status, 2);
                    addThread(textEffect);
                    status = "";
                }
                else
                {
                    statusLabel.text = status;
                }
            }
            else
            {
                statusLabel.text = status;
            }
        }

        private function equip(player:PlayerTile, tmpTile:EquipmentTile, uID:String, tilePoint:Point, nextMovePoint:Point):void
        {
            //TODO prompt user to equip

            var droppedEquipment:IEquipable = player.equip(tmpTile.getEquipment());

            addStatusMessage(player.getName() + " has equipped " + tmpTile.getEquipment().description + ".\nNew stats: Attack " + player.getAttackRolls() + " | Defense " + player.getDefenceRolls());
            //TODO make sure the player is actually picking up the item.


            var newTile:String = TileTypes.getEmptyTile();

            // Drop weapon
            if (droppedEquipment)
            {
                newTile = droppedEquipment.tileID;

                var equipmentTile:EquipmentTile = new EquipmentTile();
                equipmentTile.parseObject({equipment:droppedEquipment.toObject()});

                tileInstanceManager.registerInstance(mapSelection.getTileID(movementHelper.playerPosition.y, movementHelper.playerPosition.x).toString(), equipmentTile);
            }
            else
            {
                tileInstanceManager.removeInstance(uID);
            }

            swapTileOnMap(tilePoint, newTile);

            movePlayer(nextMovePoint);


        }

        private function onCompleteLevel(success:Boolean):void
        {
            // Level has been finished, remove map sepcific info from state
            activeGameState.clearMapData();
            activeGameState.player = player.toObject();
            // for state to save to update the player.
            activeGameState.save();

            startNextActivityTimer(FinishMapActivity, 1, {success:success});
        }

        private function onLeaveMap():void
        {
            onCompleteLevel(false);
        }

        public function addStatusMessage(value:String, clear:Boolean = true):void
        {
            if (clear)
                status = "";
            status += value;
        }

        private function canFinishLevel():Boolean
        {
            var success:Boolean;

            switch (gameMode)
            {
                case GameModeOptions.FIND_ALL_TREASURE:
                    success = treasureIterator.hasNext();
                    break;
                case GameModeOptions.FIND_ARTIFACT:
                    success = hasArtifact;
                    break;
                case GameModeOptions.KILL_ALL_MONSTERS:
                    TimeMethodExecutionUtil.execute("updateMapAnalytics", analytics.update);
                    // This is super expensive
                    monstersLeft = TimeMethodExecutionUtil.execute("remainingMonsters", analytics.getTotal, false, "1", "2", "3", "4", "5", "6", "7", "8", "9");

                    success = (monstersLeft == 0);
                    break;
                case GameModeOptions.KILL_BOSS:
                    var value:int = analytics.getTotal(false, "9");
                    success = (value == 0);
                    break;
                case GameModeOptions.EXPLORE:
                    success = (exploredTiles == 1);
                    break;
            }

            return success;
        }

        private function fight(monster:ICombatant):void
        {
            setCurrentMonster(monster);
            player.attack(monster, true);

            if (quakeEffect)
            {

                addThread(quakeEffect);

            }
        }

        protected function setCurrentMonster(monster:ICombatant):void
        {
            monster.onDie = onMonsterDie;
            monster.onAttack = onMonsterAttack;
            monster.onDefend = onMonsterDefend;
        }

        protected function formatAttackResultMessage(attackResult:AttackResult):String
        {
            var message:String = "Attack was " + attackResult.success ? "successful" : "not successful" + "!\n";
            message = attackResult.attacker.getName() + " rolled " + attackResult.hitValue + " point" + (( attackResult.hitValue != 1) ? "s" : "") + " of damage against " + attackResult.defender.getName() + "\n";
            return message;
        }

        private function onMonsterDefend():void
        {
        }

        private function onMonsterAttack(attackResult:AttackResult):void
        {
            var monster:ICombatant = attackResult.attacker;
            var monsterName:String = monster.getName();
            var message:String = monsterName;

            if (player.isDead)
            {
                message += " killed " + player.getName();
            }
            else
            {
                message += " did " + attackResult.hitValue + " damage";
            }

            var weaponName:String = monster.getWeaponSlot() ? monster.getWeaponSlot().description : "no weapon";
            message += " with " + weaponName + "\n";
            addStatusMessage(message, false);

            //TODO keep track of this sound, may need a player hit as well.
            soundManager.play(TCSoundClasses.EnemyAttack);
        }

        private function onMonsterDie(monster:ICombatant):void
        {
            soundManager.play(TCSoundClasses.WinBattle);

            swapTileOnMap(currentPoint, "X");

            tileInstanceManager.removeInstance(currentuID);

            var randomDeathMessage:String = DeathMessageFactory.getRandomDeathMessage();

            //Default message
            addStatusMessage(monster.getName() + " " + randomDeathMessage + ".\n", true);

            //Old drop treasure code
            if (monstersDropTreasure)
            {

                // Pick a random number
                var rand:Number = Math.random();

                if (rand < .6)
                {
                    // if value is less the 70%, select from treasure pool
                    var treasure:String = treasureIterator.hasNext() ? treasureIterator.getNext() : "X";
                    if (treasure == "K")
                        treasurePool.push(treasure);
                    else
                        swapTileOnMap(currentPoint, treasure);

                    //TODO need to add a status message here
                }
                else
                {
                    // Randomly pick a slot
                    rand = Math.round(Math.random() * 7)// 5 slots + empty chances
                    //trace("Drop random equipment", rand);
                    var droppedEquipment:IEquipable

                    switch (rand)
                    {
                        case SlotsEnum.ARMOR:
                            droppedEquipment = monster.getArmorSlot();
                            break;
                        case SlotsEnum.WEAPON:
                            droppedEquipment = monster.getWeaponSlot();
                            break;
                        case SlotsEnum.SHIELD:
                            droppedEquipment = monster.getShieldSlot();
                            break;
                        case SlotsEnum.HELMET:
                            droppedEquipment = monster.getHelmetSlot();
                            break;
                        case SlotsEnum.BOOTS:
                            droppedEquipment = monster.getHelmetSlot();
                            break;
                    }

                    if (droppedEquipment)
                    {
                        swapTileOnMap(currentPoint, droppedEquipment.tileID);

                        var weaponTile:EquipmentTile = new EquipmentTile();
                        weaponTile.parseObject({equipment:droppedEquipment.toObject()});

                        tileInstanceManager.registerInstance(currentuID, weaponTile);

                        addStatusMessage(monster.getName() + " " + randomDeathMessage + " and dropped " + monster.getWeaponSlot().description, true);
                    }
                }


            }

        }

        private function openTreasure(tmpPoint:Point):void
        {


            addStatusMessage(player.getName() + " has opened a treasure chest.");

            var treasure:String = treasureIterator.hasNext() ? treasureIterator.getNext() : " ";
            if (treasure == "K")
            {
                addStatusMessage("\nA trap was sprung dealing 1 point of damage.", false);
                player.subtractLife(1);
                if (quakeEffect)
                    addThread(quakeEffect);
                treasure = " ";
            }

            swapTileOnMap(tmpPoint, treasure);
        }

        protected function swapTileOnMap(point:Point, tile:String):void
        {
            map.swapTile(point, tile);
        }


        private function pickup(tile:String, tmpPoint:Point, value:Point):void
        {
            if (tile == "$")
            {
                var foundGold:int = Math.random() * cashRange;

                if (foundGold > cashPool)
                    foundGold = cashPool;

                cashPool -= foundGold;

                player.addGold(foundGold);

                addStatusMessage(player.getName() + " has picked up $" + foundGold + " gold.");
            }
            else if (tile == "P")
            {
                if (player.getPotions() < player.getMaxPotions())
                {
                    player.addPotion(1);
                    addStatusMessage(player.getName() + " has picked up a health potion.");
                }
                else
                {
                    if (player.getLife() < player.getMaxLife())
                    {
                        player.setLife(player.getMaxLife());
                        addStatusMessage(player.getName() + " can not carry any more health potions.\nHe was able to drink it now and restore his health.");
                        soundManager.play(TCSoundClasses.PotionSound);
                    }
                    else
                    {
                        addStatusMessage(player.getName() + " can not carry any more health potions.\nThis one was thrown away.");
                    }
                }
            }
            else if (tile == "A")
            {
                hasArtifact = true;
                addStatusMessage(player.getName() + " has found an Artifact.");
            }

            swapTileOnMap(tmpPoint, " ");
            movePlayer(value);
        }

        private function movePlayer(value:Point):void
        {
            movementHelper.move(value.x, value.y);
            player.addStep();

            //TODO enable to get animation working
            /*if(!scrollThread.isRunning())
                addThread(scrollThread);*/
        }

        protected function invalidate():void
        {
            invalid = true;
        }

        override public function update(elapsed:Number = 0):void
        {
            pollKeyPressCounter += elapsed;

            if (pollKeyPressCounter >= keyPressDelay)
            {
                pollKeyPressCounter = 0;

                if (mouseDown)
                {
                    onUpdateMousePosition();
                }

                if (_nextMove)
                {
                    move(_nextMove);
                    _nextMove = null
                }
            }

            super.update(elapsed);

            exploredTiles = mapSelection.getVisitedTiles() / map.getOpenTiles().length;

        }

        override protected function render():void
        {
            super.render();

            if (invalid)
            {
                characterSheet.update();
                mapSelection.setCenter(movementHelper.playerPosition);
                renderer.renderMap(mapSelection);

                var pos:Point = movementHelper.playerPosition;

                var x:int = pos.x - mapSelection.getOffsetX();
                var y:int = pos.y - mapSelection.getOffsetY();

                var playerSprite:String = TileTypes.getTileSprite("@");

                //Add custom sprite overlay (equipment)
                if (player.getSpriteID() != "")
                    playerSprite = playerSprite.concat("," + player.getSpriteID()); // Removed "," from here since now it's done in the tile instance

                //Add life sprite
                if (player.getLife() < player.getMaxLife())
                    playerSprite = playerSprite.concat(",life" + (Math.round(player.getLife() / player.getMaxLife() * 100).toString()));


                if (Math.round(player.getLife() / player.getMaxLife() * 100) < 30)
                {
                    var matrix:Array = new Array();
                    matrix = matrix.concat([1,0,0,0,0]);// red
                    matrix = matrix.concat([0,0,0,0,0]);// green
                    matrix = matrix.concat([0,0,0,0,0]);// blue
                    matrix = matrix.concat([0,0,0,1,0]);// alpha
                    var my_filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);

                    var rect:Rectangle = new Rectangle(0, 0, mapBitmap.width, mapBitmap.height);

                    mapBitmap.bitmapData.applyFilter(mapBitmap.bitmapData.clone(), rect, new Point(0, 0), my_filter);
                }

                //Draw player
                renderer.renderPlayer(x, y, playerSprite);


                previewMapRenderer.renderPlayer(mapSelection.getOffsetX() + x, mapSelection.getOffsetY() + y, playerSprite);

                invalid = false;

                trace("$Render");
            }


        }

        override public function onStart():void
        {
            super.onStart();
            //This needs to be a compiler argument for debug
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

            controls = new Controls(this);

            soundManager.play(TCSoundClasses.WalkStairsSound);

            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            addEventListener(MouseEvent.CLICK, onMouseClick);
        }


        private function onMouseClick(event:MouseEvent):void
        {
            onUpdateMousePosition();
        }

        private function onMouseDown(event:MouseEvent):void
        {
            mouseDown = true;
        }

        private function onMouseUp(event:MouseEvent):void
        {
            mouseDown = false;
        }

        private function onUpdateMousePosition():void
        {

            var localPoint:Point = new Point(Math.floor((mouseX - mapBitmap.x) / TILE_SIZE), Math.floor((mouseY - mapBitmap.y) / TILE_SIZE));
            var tileID:int = mapSelection.getTileID(localPoint.x, localPoint.y);

            //trace("Update Mouse Position", mouseX, mouseY, localPoint);


            var playerPoint:Point = mapSelection.getCenter().clone();
            playerPoint.x -= mapSelection.getOffsetX();
            playerPoint.y -= mapSelection.getOffsetY();


            var distanceX:Number = localPoint.x - playerPoint.x;
            var distanceY:Number = -1 * (localPoint.y - playerPoint.y);

            var angle:Number = Math.atan2(distanceY, distanceX); // radians
            angle = Math.round(angle / Math.PI * 180); // degrees

            var dir:String;

            var directionX:int = 0;
            var directionY:int = 0;

            if (angle >= -135 && angle <= -45)
            {
                directionY = 1;

            }
            else if (angle >= -45 && angle <= 45)
            {
                directionX = 1;

            }
            else if (angle >= 45 && angle <= 135)
            {
                directionY = -1;

            }
            else
            {
                directionX = -1;

            }

            nextMove(new Point(directionX, directionY));

        }

        override public function loadState():void
        {
            activeGameState.load();
        }

        override public function saveState():void
        {
            if (!player.isDead)
            {
                activeGameState.player = player.toObject();
                activeGameState.tileInstanceManager = tileInstanceManager.toObject();
                activeGameState.mapSelection = mapSelection.toObject();
                activeGameState.startPosition = movementHelper.playerPosition;
                activeGameState.map = map.toObject();
                activeGameState.save();
            }

        }

        override public function onStop():void
        {
            saveState();
            super.onStop();
        }

    }
}
