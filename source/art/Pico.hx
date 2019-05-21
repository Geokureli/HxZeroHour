package art;

import flixel.effects.FlxFlicker;
import flixel.math.FlxPoint;
import data.BulletGroup as Gun;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.math.FlxVector;
import flixel.input.gamepad.FlxGamepadInputID;

class Pico extends GroupEntity {
    
    inline static var WALK_SPEED     = 200;
    inline static var DASH_SPEED     = 350;
    inline static var SPEED_UP_TIME  = 1 / 8;//seconds
    inline static var DASH_TIME      = 2.0;//seconds
    

    inline static var MAX_APEX_TIME  = .45;//seconds
    inline static var JUMP_MAX       = 100;//pixels
    inline static var JUMP_MIN       = 20;//pixels
    inline static var MIN_APEX_TIME  = 2 * MAX_APEX_TIME * JUMP_MIN / (JUMP_MIN + JUMP_MAX);//seconds
    inline static var GRAVITY        = 2 * JUMP_MIN / MIN_APEX_TIME / MIN_APEX_TIME; // px/s^2
    inline static var JUMP_VEL       = -2 * JUMP_MIN / MIN_APEX_TIME; //px/s
    inline static var JUMP_MAX_TIME  = (JUMP_MAX - JUMP_MIN) / -JUMP_VEL; //seconds
    
    inline static var CAMERA_LERP    = 0.1; // % of total distance
    inline static var CAMERA_LEAD    = 100; // pixels
    
    inline static var SHOOT_SPEED       = 800; // px/s
    inline static var SHOOT_OFFSET_PAR  = 22; // pixels
    inline static var SHOOT_OFFSET_PERP = -6; // pixels
    inline static var SHOOT_FREQ        = 1 / 15; // seconds
    inline static var AFTER_FIRE        = 0.5; // seconds
    
    public var dashPercentLeft(get, never):Float;
    public var bullets(default, null):Gun;
    
    var _torso:FlxSprite;
    var _scarf:FlxSprite;
    var _feet :FlxSprite;
    
    var _cameraTarget:FlxObject;
    
    var _jumpTimer = 0.0;
    var _dashLeft = DASH_TIME;
    var _dashing = false;
    var _dashAntiPress = true;
    var _wasDashing = false;
    
    var _gunPivotX(get, never):Float;
    var _gunPivotY(get, never):Float;
    var _lastClickTime = AFTER_FIRE;
    var _lastShootTime = SHOOT_FREQ;
    var _lastShootDir = FlxVector.get();
    var _lastMoveDir = FlxVector.get();
    var _wasShooting = false;
    var _lastGroundPos = FlxPoint.get();
    
    var _aimToShoot = true;
    
    public function new (x = 0.0, y = 0.0) {
        super(x, y);
        
        add(_feet = new FlxSprite(13, 24, "assets/images/global/pico/Feet.png"));
        add(_scarf = new FlxSprite(0 , 14, "assets/images/global/pico/Scarf.png"));
        _scarf.origin.set(_scarf.width + 3, _scarf.height / 2);
        add(_torso = new FlxSprite(17, 0 , "assets/images/global/pico/Torso.png"));
        _torso.origin.set(13, 23);
        
        acceleration.y = GRAVITY;
        maxVelocity.x = WALK_SPEED;
        maxVelocity.y = -JUMP_VEL;
        drag.x = maxVelocity.x / SPEED_UP_TIME;
        FlxG.gamepads.globalDeadZone = 0.1;
        
        _cameraTarget = new FlxObject(x, y, 1, 1);
        FlxG.camera.follow(_cameraTarget, FlxCameraFollowStyle.PLATFORMER, CAMERA_LERP);
        FlxG.camera.focusOn(_cameraTarget.getPosition(FlxPoint.weak()));
        
        width = 18;
        height = groupHeight;
        offset.x = 20;
        
        bullets = new Gun();
    }
    
    public function addDebugDrawObjects(group):Void {
        
        group.add(_cameraTarget);
    }
    
    override function update(elapsed:Float) {
        
        var shootDir = FlxVector.get();
        var moveDir = FlxVector.get();
        var dashing = getIsDashing(elapsed);
        if (!FlxFlicker.isFlickering(this))
            getInput(shootDir, moveDir, dashing);
        
        // _scarf.visible = dashing;
        var shooting = false;
        if (dashing) {
            
            shootDir.zero();
            _lastClickTime = AFTER_FIRE;
            _lastShootTime = SHOOT_FREQ;
            
        } else {
            
            var isGamePad = FlxG.gamepads.numActiveGamepads > 0;
            
            var firingPressed = isGamePad
                ? _aimToShoot || FlxG.gamepads.firstActive.pressed.RIGHT_TRIGGER
                : FlxG.mouse.pressed;
            
            if (!shootDir.isZero() && firingPressed) {
                
                shooting = true;
                
            } else if (_lastClickTime < AFTER_FIRE && _wasShooting) {
                
                if (shootDir.isZero())
                    shootDir.copyFrom(_lastShootDir);
                shooting = true;
                
            } else if (!isGamePad)
                shootDir.zero();
            
            _lastClickTime += elapsed;
            _lastShootTime += elapsed;
            if (!_wasShooting) {
                
                _lastClickTime = 0;
                _lastShootTime = 0;
            }
            
            _wasShooting = shooting;
        }
        _lastShootDir.copyFrom(shootDir);
        
        var aimDir = shootDir.clone();
        if (!aimDir.isZero() && !dashing) {
            
            if (shootDir.x < 0) {
                
                scale.x = -1;
                aimDir.x = -aimDir.x;
                aimDir.y = -aimDir.y;
                
            } else
                scale.x = 1;
            
        } else if (moveDir.x != 0)
            scale.x = moveDir.x;
        
        _cameraTarget.x = _torso.x + _torso.width / 2 + scale.x * CAMERA_LEAD;
        _cameraTarget.y = _torso.y;
        
        _torso.angle = aimDir.degrees;
        aimDir.put();
        
        if (dashing) {
            
            if (!_wasDashing) {
                
                acceleration.set(0, 0);
                maxVelocity.set(DASH_SPEED, DASH_SPEED);
            }
            
            if (moveDir.isZero()) {
                
                if (_wasDashing)
                    moveDir.copyFrom(_lastMoveDir);
                else
                    moveDir.set(scale.x, 0);
            }
            
            _lastMoveDir.copyFrom(moveDir);
            
            velocity.copyFrom(moveDir.scale(DASH_SPEED));
            
        } else {
            
            if (_wasDashing) {
                
                velocity.set(0, 0);
                maxVelocity.set(WALK_SPEED, -JUMP_VEL);
                acceleration.y = GRAVITY;
            }
            
            acceleration.x = moveDir.x * drag.x;
            
            var onGround = isTouching(FlxObject.FLOOR);
            var jumpPress = moveDir.y < 0;
            
            if (onGround)
                _lastGroundPos.set(x, y);
            
            if (!onGround && !jumpPress)
                _jumpTimer = JUMP_MAX_TIME;
            else if (jumpPress) {
                
                if (onGround)
                    _jumpTimer = 0;
                
                if (_jumpTimer < JUMP_MAX_TIME) {
                    
                    velocity.y = JUMP_VEL;
                    _jumpTimer += elapsed;
                }
            }
            
            if (shooting && _lastShootTime > SHOOT_FREQ) {
                
                _lastShootTime -= SHOOT_FREQ;
                
                bullets.shootWithOffsets
                    ( _gunPivotX
                    , _gunPivotY
                    , shootDir.x * SHOOT_SPEED
                    , shootDir.y * SHOOT_SPEED
                    , SHOOT_OFFSET_PAR
                    , SHOOT_OFFSET_PERP * scale.x
                    );
            }
        }
        
        super.update(elapsed);
        
        if (y > FlxG.worldBounds.bottom)
        {
            x = _lastGroundPos.x;
            y = _lastGroundPos.y - 10;
            last.set(x, y);
            velocity.set();
            FlxFlicker.flicker(this, 0.5);
            dashing = false;
        }
        
        _scarf.scale.x = scale.x * dashPercentLeft;
        _wasDashing = dashing;
        
        moveDir.put();
        shootDir.put();
    }
    
    inline function getInput(shootDir:FlxVector, moveDir:FlxVector, dashing:Bool):Void {
        
        if (FlxG.keys.justPressed.ONE)
            _aimToShoot = !_aimToShoot;
        
        if (FlxG.gamepads.numActiveGamepads == 0) {
            
            getKeyMovement(moveDir);
            getMouseDirection(shootDir);
            
        } else {
            
            getPadMovement(moveDir, dashing);
            getPadDirection(shootDir);
        }
    }
    
    inline function getKeyMovement(dir:FlxVector):Void {
        
        var keys = FlxG.keys.pressed;
        
        dir.x = (keys.D ? 1 : 0) - (keys.A ? 1 : 0);
        dir.y = (keys.S ? 1 : 0) - (keys.W ? 1 : 0);
    }
    
    inline function getPadMovement(dir:FlxVector, isDashing:Bool):Void {
        
        var pressed = FlxG.gamepads.firstActive.pressed;
        
        dir.x
            = (pressed.DPAD_RIGHT || pressed.LEFT_STICK_DIGITAL_RIGHT ? 1 : 0)
            - (pressed.DPAD_LEFT  || pressed.LEFT_STICK_DIGITAL_LEFT  ? 1 : 0);
        
        if (isDashing)
            dir.y
                = (pressed.DPAD_DOWN || pressed.LEFT_STICK_DIGITAL_DOWN ? 1 : 0)
                - (pressed.DPAD_UP   || pressed.LEFT_STICK_DIGITAL_UP   ? 1 : 0);
        else
            dir.y = pressed.A ? -1 : 0;
    }
    
    inline function getMouseDirection(dir:FlxVector):Void {
        
        dir.x = FlxG.mouse.x - _gunPivotX;
        dir.y = FlxG.mouse.y - _gunPivotY;
        dir.normalize();
    }
    
    inline function getPadDirection(dir:FlxVector):Void {
        
        var analog = FlxG.gamepads.firstActive.analog.value;
        
        dir.set(analog.RIGHT_STICK_X, analog.RIGHT_STICK_Y).normalize();
    }
    
    inline function getIsDashing(elapsed:Float):Bool {
        
        var dashPressed = 
            if (FlxG.gamepads.numActiveGamepads == 0)
                FlxG.keys.pressed.SPACE;
            else
                FlxG.gamepads.firstActive.anyPressed
                    (   [ FlxGamepadInputID.RIGHT_SHOULDER
                        , FlxGamepadInputID.LEFT_SHOULDER
                        , FlxGamepadInputID.X
                        ]
                    );
        
        if(dashPressed) {
            
            if (_dashLeft > 0 && _dashAntiPress)
                _dashLeft -= elapsed;
            else {
                
                dashPressed = false;
                _dashAntiPress = false;
            }
            
        } else {
            _dashAntiPress = true;
        }
        
        if (!dashPressed) {
            
            _dashLeft += elapsed;
            
            if (_dashLeft > DASH_TIME)
                _dashLeft = DASH_TIME;
        }
        
        return dashPressed;
    }
    
    inline function get_dashPercentLeft():Float {
        
        return _dashLeft / DASH_TIME;
    }
    
    inline function get__gunPivotX():Float { return _torso.x + _torso.origin.x - _torso.offset.x; }
    inline function get__gunPivotY():Float { return _torso.y + _torso.origin.y - _torso.offset.y; }
}