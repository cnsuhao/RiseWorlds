package com.genome2d.components.renderables.jointanim;

import com.genome2d.context.GContextCamera;
import com.genome2d.context.IContext;
import com.genome2d.context.stage3d.renderers.GRenderersCommon;
import com.genome2d.error.GError;
import com.genome2d.geom.GRectangle;
import com.genome2d.node.GNode;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.Vector;

/**
 * ...
 * @author Rise
 */
class JAnim extends GComponent implements IRenderable
{
	private static var NORMALIZED_VERTICES_3D:Array<Float> = [-0.5, 0.5, 0, -0.5, -0.5, 0, 0.5, -0.5, 0, 0.5, 0.5, 0];

	private static var _helpTransform:JATransform = new JATransform();
	private static var _helpCallTransform:Vector<JATransform> = new Vector<JATransform>(1000);
	private static var _helpCallColor:Vector<JAColor> = new Vector<JAColor>(1000);
	private static var _helpCallDepth:Int = 0;
	private static var _helpDrawSpriteASrcRect:Rectangle = new Rectangle();
	private static var _helpCalcTransform:JATransform;
	private static var _helpCalcColor:JAColor;
	private static var _helpANextObjectPos:Vector<JAObjectPos> = new Vector<JAObjectPos>(3);
	public static var UpdateCnt:Int = 0;
	private static var _helpGetTransformedVertices3DTransformMatrix:Matrix3D = new Matrix3D();
	private static var _helpMatrix3DVector1:Array<Float> = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];
	private static var _helpMatrix3DArg1:Matrix3D = new Matrix3D();
	private static var _helpJAnimRender:JATransform2D = new JATransform2D();
	private static var _helpJAnimRenderVector:Vector<Float> = new Vector<Float>(16);
	private static var bInit:Bool = false;
	private static var _helpDrawSprite:Matrix = new Matrix();
	
	private var _JointAnimate:JointAnimate;
	private var _id:Int;
	private var _listener:JAnimListener;
	private var _animRunning:Bool;
	private var _paused:Bool;
	private var _interpolate:Bool;
	private var _color:JAColor;
	private var _transform:JATransform2D;
	private var _drawTransform:JATransform2D;
	private var _mirror:Bool;
	private var _additive:Bool;
	private var _inNode:Bool;
	private var _mainSpriteInst:JASpriteInst;
	private var _transDirty:Bool;
	private var _blendTicksTotal:Float;
	private var _blendTicksCur:Float;
	private var _blendDelay:Float;
	private var _lastPlayedFrameLabel:String;
	private var _helpGetTransformedVertices3DVector:Vector<Float>;

	public function new(p_node:GNode, jointAnimate:JointAnimate, id:Int, listener:JAnimListener=null) 
	{
		_helpGetTransformedVertices3DVector = new Vector<Float>();
		//super(p_node);
		super();
		if (jointAnimate == null)
		{
			throw (new GError("Joint Animate is null!"));
		};
		_inNode = !((p_node == null));
		_JointAnimate = jointAnimate;
		_id = id;
		_listener = listener;
		_mirror = false;
		_animRunning = false;
		_paused = false;
		_transform = new JATransform2D();
		_interpolate = true;
		_color = new JAColor();
		_color.clone(JAColor.White);
		_additive = false;
		_transDirty = true;
		_mainSpriteInst = new JASpriteInst();
		_mainSpriteInst.spriteDef = null;
		_mainSpriteInst.parent = null;
		_blendDelay = 0;
		_blendTicksCur = 0;
		_blendTicksTotal = 0;
	}
	
	public static function HelpCallInitialize():Void
	{
		var _local1:Int;
		if (!bInit)
		{
			_helpCallTransform.fixed = true;
			_helpCallColor.fixed = true;
			_local1 = 0;
			while (_local1 < 1000)
			{
				_helpCallTransform[_local1] = new JATransform();
				_helpCallColor[_local1] = new JAColor();
				_local1++;
			};
			bInit = true;
		};
	}


	override public function dispose():Void
	{
		super.dispose();
		_color = null;
		_transform = null;
		_mainSpriteInst.Dispose();
		_JointAnimate = null;
	}

	/*override public function processMouseEvent(p_captured:Bool, p_event:MouseEvent, p_position:Vector3D):Bool
	{
		return (false);
	}*/

	///*override*/ public function getWorldBounds(p_target:Rectangle=null):Rectangle
	public function getBounds(p_target:GRectangle = null):GRectangle
	{
		var _local4:Int;
		var _local2:Vector<Float> = getTransformedVertices3D();
		if (p_target != null)
		{
			p_target.setTo(_local2[0], _local2[1], 0, 0);
		}
		else
		{
			p_target = new Rectangle(_local2[0], _local2[1], 0, 0);
		};
		var _local3:Int = _local2.length;
		_local4 = 3;
		while (_local4 < _local3)
		{
			if (p_target.left > _local2[_local4])
			{
				p_target.left = _local2[_local4];
			};
			if (p_target.right < _local2[_local4])
			{
				p_target.right = _local2[_local4];
			};
			if (p_target.top > _local2[(_local4 + 1)])
			{
				p_target.top = _local2[(_local4 + 1)];
			};
			if (p_target.bottom < _local2[(_local4 + 1)])
			{
				p_target.bottom = _local2[(_local4 + 1)];
			};
			_local4 = (_local4 + 3);
		};
		return (p_target);
	}

	private function getTransformedVertices3D():Vector<Float>
	{
		//_helpGetTransformedVertices3DTransformMatrix.copyfFrom(node.transform.matrix);
		//_helpMatrix3DVector1[0] = _transform.m00;
		//_helpMatrix3DVector1[1] = _transform.m10;
		//_helpMatrix3DVector1[4] = _transform.m01;
		//_helpMatrix3DVector1[5] = _transform.m11;
		//_helpMatrix3DVector1[12] = _transform.m02;
		//_helpMatrix3DVector1[13] = _transform.m12;
		//_helpMatrix3DArg1.copyRawDataFrom(_helpMatrix3DVector1);
		//_helpGetTransformedVertices3DTransformMatrix.prepend(_helpMatrix3DArg1);
		//NORMALIZED_VERTICES_3D[0] = _JointAnimate.animRect.x;
		//NORMALIZED_VERTICES_3D[1] = _JointAnimate.animRect.y;
		//NORMALIZED_VERTICES_3D[2] = 0;
		//NORMALIZED_VERTICES_3D[3] = _JointAnimate.animRect.x;
		//NORMALIZED_VERTICES_3D[4] = (_JointAnimate.animRect.y + _JointAnimate.animRect.height);
		//NORMALIZED_VERTICES_3D[5] = 0;
		//NORMALIZED_VERTICES_3D[6] = (_JointAnimate.animRect.x + _JointAnimate.animRect.width);
		//NORMALIZED_VERTICES_3D[7] = (_JointAnimate.animRect.y + _JointAnimate.animRect.height);
		//NORMALIZED_VERTICES_3D[8] = 0;
		//NORMALIZED_VERTICES_3D[9] = (_JointAnimate.animRect.x + _JointAnimate.animRect.width);
		//NORMALIZED_VERTICES_3D[10] = _JointAnimate.animRect.y;
		//NORMALIZED_VERTICES_3D[11] = 0;
		//_helpGetTransformedVertices3DTransformMatrix.transformVectors(NORMALIZED_VERTICES_3D, _helpGetTransformedVertices3DVector);
		return (_helpGetTransformedVertices3DVector);
	}

	///*override*/ public function render(p_context:IContext, p_camera:GContextCamera, p_maskRect:Rectangle):Void
	public function render(p_camera:GContextCamera, p_useMatrix:Bool):Void
	{
		//if (_inNode)
		//{
		//	_drawTransform = JAMatrix3.MulJAMatrix3_M3D(node.transform.worldTransformMatrix, _transform, _helpJAnimRender);
		//}
		//else
		{
			_drawTransform = _transform;
		};
		//Draw(p_context);
	}

	/*override*/ public function update(p_deltaTime:Float, p_parentTransformUpdate:Bool, p_parentColorUpdate:Bool):Void
	{
		//if (_inNode)
		//{
		//	_drawTransform = JAMatrix3.MulJAMatrix3_M3D(node.transform.worldTransformMatrix, _transform, _helpJAnimRender);
		//}
		//else
		{
			_drawTransform = _transform;
		};
		Update((p_deltaTime * 0.1));
	}

	//public function get transform():JATransform2D
	//{
	//	return (_transform);
	//}
	public var transform(get, never):JATransform2D;
    inline private function get_transform():JATransform2D {
        return _transform;
    }

	//public function get lastPlayedLabel():String
	//{
	//	return (_lastPlayedFrameLabel);
	//}
	public var lastPlayedLabel(get, never):String;
    inline private function get_lastPlayedLabel():String {
        return _lastPlayedFrameLabel;
    }

	//public function get interpolate():Bool
	//{
	//	return (_interpolate);
	//}
    //
	//public function set interpolate(val:Bool):Void
	//{
	//	_interpolate = val;
	//}
	public var interpolate(get, set):Bool;
    inline private function get_interpolate():Bool {
        return _interpolate;
    }
	inline private function set_interpolate(val:Bool):Bool {
        _interpolate = val;
		return _interpolate;
    }

	//public function set mirror(val:Bool):Void
	//{
	//	_mirror = val;
	//}
    //
	//public function get mirror():Bool
	//{
	//	return (_mirror);
	//}
	public var mirror(get, never):Bool;
    inline private function get_mirror():Bool {
        return _mirror;
    }
	inline private function set_mirror(val:Bool):Bool {
        _mirror = val;
		return _mirror;
    }

	//public function set additive(val:Bool):Void
	//{
	//	_additive = val;
	//}
    //
	//public function get additive():Bool
	//{
	//	return (_additive);
	//}
	#if swc @:extern #end
	public var additive(get, set):Bool;
	#if swc @:getter(mask) #end
    inline private function get_additive():Bool {
        return _additive;
    }
	#if swc @:setter(mask) #end
	inline private function set_additive(val:Bool):Bool	{
		_additive = val;
		return _additive;
	}

	//public function set color(c:UInt):Void
	//{
	//	_color.alpha = ((c >> 24) & 0xFF);
	//	_color.red = ((c >> 16) & 0xFF);
	//	_color.green = ((c >> 8) & 0xFF);
	//	_color.blue = (c & 0xFF);
	//}
    //
	//public function get color():UInt
	//{
	//	return (_color.toInt());
	//}
	public var color(get, set):UInt;
    inline private function get_color():UInt {
        return _color.toInt();
    }
	inline private function set_color(val:UInt):UInt {
		_color.alpha = ((val >> 24) & 0xFF);
		_color.red = ((val >> 16) & 0xFF);
		_color.green = ((val >> 8) & 0xFF);
		_color.blue = (val & 0xFF);
		return _color.toInt();
	}
    //
	//public function get mainSpriteInst():JASpriteInst
	//{
	//	return (_mainSpriteInst);
	//}
	public var mainSpriteInst(get, never):JASpriteInst;
    inline private function get_mainSpriteInst():JASpriteInst {
        return _mainSpriteInst;
    }

	public function IsActive():Bool
	{
		if (_animRunning)
		{
			return (true);
		};
		return (false);
	}

	public function GetToFirstFrame():Void
	{
		var _local1:Bool;
		var _local2:Bool;
		while (((!((_mainSpriteInst.spriteDef == null))) && ((_mainSpriteInst.frameNum < _mainSpriteInst.spriteDef.workAreaStart))))
		{
			_local1 = _animRunning;
			_local2 = _paused;
			_animRunning = true;
			_paused = false;
			Update(0);
			_animRunning = _local1;
			_paused = _local2;
		};
	}

	public function ResetAnim():Void
	{
		ResetAnimHelper(_mainSpriteInst);
		_animRunning = false;
		GetToFirstFrame();
		_blendTicksTotal = 0;
		_blendTicksCur = 0;
		_blendDelay = 0;
	}

	public function SetupSpriteInst(theName:String=""):Bool
	{
		var _local4:Int;
		if (_mainSpriteInst == null)
		{
			return (false);
		};
		if (((!((_mainSpriteInst.spriteDef == null))) && ((theName == ""))))
		{
			return (true);
		};
		if (_JointAnimate.mainAnimDef.mainSpriteDef != null)
		{
			InitSpriteInst(_mainSpriteInst, _JointAnimate.mainAnimDef.mainSpriteDef);
			return (true);
		};
		if (_JointAnimate.mainAnimDef.spriteDefVector.length == 0)
		{
			return (false);
		};
		var _local3 = theName;
		if (_local3.length == 0)
		{
			_local3 = "main";
		};
		var _local2:JASpriteDef = null;
		_local4 = 0;
		while (_local4 < _JointAnimate.mainAnimDef.spriteDefVector.length)
		{
			if (((!((_JointAnimate.mainAnimDef.spriteDefVector[_local4].name == null))) && ((_JointAnimate.mainAnimDef.spriteDefVector[_local4].name == _local3))))
			{
				_local2 = _JointAnimate.mainAnimDef.spriteDefVector[_local4];
				_lastPlayedFrameLabel = _local3;
				break;
			};
			_local4++;
		};
		if (_local2 == null)
		{
			_local2 = _JointAnimate.mainAnimDef.spriteDefVector[0];
		};
		if (_local2 != _mainSpriteInst.spriteDef)
		{
			if (_mainSpriteInst.spriteDef != null)
			{
				_mainSpriteInst.Reset();
				_mainSpriteInst.parent = null;
			};
			InitSpriteInst(_mainSpriteInst, _local2);
			_transDirty = true;
		};
		return (true);
	}

	public function Play(theFrameLabel:String, resetAnim:Bool=true):Bool
	{
		var _local3:Int;
		_animRunning = false;
		if (_JointAnimate.mainAnimDef.mainSpriteDef != null)
		{
			if (!SetupSpriteInst())
			{
				return (false);
			};
			_local3 = _JointAnimate.mainAnimDef.mainSpriteDef.GetLabelFrame(theFrameLabel);
			if (_local3 == -1)
			{
				return (false);
			};
			_lastPlayedFrameLabel = theFrameLabel;
			return (PlayIndex(_local3, resetAnim));
		};
		_lastPlayedFrameLabel = theFrameLabel;
		SetupSpriteInst(theFrameLabel);
		return (PlayIndex(_mainSpriteInst.spriteDef.workAreaStart, resetAnim));
	}

	public function PlayIndex(theFrameNum:Int=0, resetAnim:Bool=true):Bool
	{
		if (!SetupSpriteInst())
		{
			return (false);
		};
		if (theFrameNum >= _mainSpriteInst.spriteDef.frames.length)
		{
			_animRunning = false;
			return (false);
		};
		if (((!((_mainSpriteInst.frameNum == theFrameNum))) && (resetAnim)))
		{
			ResetAnim();
		};
		_paused = false;
		_animRunning = true;
		_mainSpriteInst.delayFrames = 0;
		_mainSpriteInst.frameNum = theFrameNum;
		_mainSpriteInst.lastFrameNum = theFrameNum;
		_mainSpriteInst.frameRepeats = 0;
		if (_blendDelay == 0)
		{
			DoFramesHit(_mainSpriteInst, null);
		};
		return (true);
	}

	public function Update(val:Float):Void
	{
		if (!SetupSpriteInst())
		{
			return;
		};
		UpdateF(val);
	}

	private function UpdateF(val:Float):Void
	{
		if (_paused)
		{
			return;
		};
		AnimUpdate(val);
	}

	public function Draw(p_context:IContext):Void
	{
		if (!SetupSpriteInst())
		{
			return;
		};
		_helpCallDepth = 0;
		if (!_inNode)
		{
			_drawTransform = _transform;
		};
		if (_transDirty)
		{
			UpdateTransforms(_mainSpriteInst, null, _color, false);
			_transDirty = false;
		};
		DrawSprite(p_context, _mainSpriteInst, null, _color, _additive, false);
	}

	private function DrawSprite(p_context:IContext, theSpriteInst:JASpriteInst, theTransform:JATransform, theColor:JAColor, additive:Bool, parentFrozen:Bool):Void
	{
		var _local7 = null;
		var _local16:Int;
		var _local20 = null;
		var _local9 = null;
		var _local24 = null;
		var _local8 = null;
		var _local19:Int;
		var _local11 = null;
		var _local13 = null;
		var _local21 = null;
		var _local23 = null;
		var _local12:Float;
		var _local14:Float;
		var _local18:Int;
		var _local17:JAFrame = theSpriteInst.spriteDef.frames[cast theSpriteInst.frameNum];
		var _local22:JATransform = _helpCallTransform[_helpCallDepth];
		var _local10:JAColor = _helpCallColor[_helpCallDepth];
		_helpCallDepth++;
		var _local15:Bool = ((((parentFrozen) || ((theSpriteInst.delayFrames > 0)))) || (_local17.hasStop));
		_local16 = 0;
		while (_local16 < _local17.frameObjectPosVector.length)
		{
			_local20 = _local17.frameObjectPosVector[_local16];
			_local9 = theSpriteInst.children[_local20.objectNum];
			if (((!((_listener == null))) && (_local9.predrawCallback)))
			{
				_local9.predrawCallback = _listener.JAnimObjectPredraw(_id, this, p_context, theSpriteInst, _local9, theTransform, theColor);
			};
			if (_local20.isSprite)
			{
				_local7 = theSpriteInst.children[_local20.objectNum].spriteInst;
				_local10.clone(_local7.curColor);
				_local22.clone(_local7.curTransform);
			}
			else
			{
				CalcObjectPos(theSpriteInst, _local16, _local15);
				_local22 = _helpCalcTransform;
				_local10 = _helpCalcColor;
				_helpCalcTransform = null;
				_helpCalcColor = null;
			};
			if ((((theTransform == null)) && (!((_JointAnimate.drawScale == 1)))))
			{
				_helpTransform.matrix.LoadIdentity();
				_helpTransform.matrix.m00 = _JointAnimate.drawScale;
				_helpTransform.matrix.m11 = _JointAnimate.drawScale;
				_helpTransform.matrix = JAMatrix3.MulJAMatrix3(_drawTransform, _helpTransform.matrix, _helpTransform.matrix);
				_local24 = _helpTransform.TransformSrc(_local22, _local22);
			}
			else
			{
				if ((((theTransform == null)) || (_local20.isSprite)))
				{
					_local24 = _local22;
					if (_JointAnimate.drawScale != 1)
					{
						_helpTransform.matrix.LoadIdentity();
						_helpTransform.matrix.m00 = _JointAnimate.drawScale;
						_helpTransform.matrix.m11 = _JointAnimate.drawScale;
						_local24.matrix = JAMatrix3.MulJAMatrix3(_helpTransform.matrix, _local24.matrix, _local24.matrix);
					};
					_local24.matrix = JAMatrix3.MulJAMatrix3(_drawTransform, _local24.matrix, _local24.matrix);
				}
				else
				{
					_local24 = theTransform.TransformSrc(_local22, _local22);
				};
			};
			_local8 = _helpCallColor[_helpCallDepth];
			_helpCallDepth++;
			_local8.Set(cast (((_local10.red * theColor.red) * _local9.colorMult.red) / 65025), 
				cast (((_local10.green * theColor.green) * _local9.colorMult.green) / 65025), 
				cast (((_local10.blue * theColor.blue) * _local9.colorMult.blue) / 65025), 
				cast (((_local10.alpha * theColor.alpha) * _local9.colorMult.alpha) / 65025));
			if (_local8.alpha != 0)
			{
				if (_local20.isSprite)
				{
					_local7 = theSpriteInst.children[_local20.objectNum].spriteInst;
					DrawSprite(p_context, _local7, _local24, _local8, ((_local20.isAdditive) || (additive)), _local15);
				}
				else
				{
					_local19 = 0;
					while (true)
					{
						_local11 = _JointAnimate.imageVector[_local20.resNum];
						_local13 = _local24.TransformSrc(_local11.transform, _local24);
						_local23 = _helpDrawSpriteASrcRect;
						if ((((_local20.animFrameNum == 0)) || ((_local11.images.length == 1))))
						{
							_local21 = _local11.images[0];
							_local21.GetCelRect(_local20.animFrameNum, _local23);
						}
						else
						{
							_local21 = _local11.images[_local20.animFrameNum];
							_local21.GetCelRect(0, _local23);
						};
						if (_local20.hasSrcRect)
						{
							_local23 = _local20.srcRect;
						};
						if (_JointAnimate.imgScale != 1)
						{
							_local12 = _local13.matrix.m02;
							_local14 = _local13.matrix.m12;
							_helpTransform.matrix.LoadIdentity();
							_helpTransform.matrix.m00 = (1 / _JointAnimate.imgScale);
							_helpTransform.matrix.m11 = (1 / _JointAnimate.imgScale);
							_local13 = _helpTransform.TransformSrc(_local13, _local13);
							_local13.matrix.m02 = _local12;
							_local13.matrix.m12 = _local14;
						};
						_local18 = 0;
						if (((!((_listener == null))) && (_local9.imagePredrawCallback)))
						{
							_local18 = _listener.JAnimImagePredraw(theSpriteInst, _local9, _local13, _local21, p_context, _local19);
							if (_local18 == 0)
							{
								_local9.imagePredrawCallback = false;
							};
							if (_local18 == 2) break;
						};
						_helpTransform.matrix.LoadIdentity();
						_helpTransform.matrix.m02 = (_local23.width / 2);
						_helpTransform.matrix.m12 = (_local23.height / 2);
						if (_mirror)
						{
							_helpTransform.matrix.m00 = -1;
						};
						_local13.matrix = JAMatrix3.MulJAMatrix3(_local13.matrix, _helpTransform.matrix, _local13.matrix);
						if (_mirror)
						{
							_local13.matrix.m02 = ((_JointAnimate.animRect.width - _local13.matrix.m02) + (2 * _drawTransform.m02));
							_local13.matrix.m01 = -(_local13.matrix.m01);
							_local13.matrix.m10 = -(_local13.matrix.m10);
						};
						_helpDrawSprite.a = _local13.matrix.m00;
						_helpDrawSprite.b = _local13.matrix.m10;
						_helpDrawSprite.c = _local13.matrix.m01;
						_helpDrawSprite.d = _local13.matrix.m11;
						_helpDrawSprite.tx = _local13.matrix.m02;
						_helpDrawSprite.ty = _local13.matrix.m12;
						if (_local21.imageExist)
						{
							p_context.drawMatrix(_local21.texture, 
								_helpDrawSprite.a, 
								_helpDrawSprite.b, 
								_helpDrawSprite.c, 
								_helpDrawSprite.d, 
								_helpDrawSprite.tx, 
								_helpDrawSprite.ty, 
								(_local8.red * 0.003921568627451), 
								(_local8.green * 0.003921568627451), 
								(_local8.blue * 0.003921568627451), 
								(_local8.alpha * 0.003921568627451), 
								((((additive) || (_local20.isAdditive))) ? 2 : 1));
						}
						else
						{
							if (_listener != null)
							{
								_listener.JAnimImageNotExistDraw(_local21.name, p_context, _helpDrawSprite, (_local8.red * 0.003921568627451), (_local8.green * 0.003921568627451), (_local8.blue * 0.003921568627451), (_local8.alpha * 0.003921568627451), ((((additive) || (_local20.isAdditive))) ? 2 : 1));
							};
						};
						if (_local18 != 3) break;
						_local19++;
					};
					if (((!((_listener == null))) && (_local9.postdrawCallback)))
					{
						_local9.postdrawCallback = _listener.JAnimObjectPostdraw(_id, this, p_context, theSpriteInst, _local9, theTransform, theColor);
					};
				};
			};
			_local16++;
		};
	}

	private function AnimUpdate(val:Float):Void
	{
		if (!_animRunning)
		{
			return;
		};
		if (_blendTicksTotal > 0)
		{
			_blendTicksCur = (_blendTicksCur + val);
			if (_blendTicksCur >= _blendTicksTotal)
			{
				_blendTicksTotal = 0;
			};
		};
		_transDirty = true;
		if (_blendDelay > 0)
		{
			_blendDelay = (_blendDelay - val);
			if (_blendDelay <= 0)
			{
				_blendDelay = 0;
				DoFramesHit(_mainSpriteInst, null);
			};
			return;
		};
		IncSpriteInstFrame(_mainSpriteInst, null, val);
		PrepSpriteInstFrame(_mainSpriteInst, null);
	}

	private function PrepSpriteInstFrame(theSpriteInst:JASpriteInst, theObjectPos:JAObjectPos):Void
	{
		var _local6:Int;
		var _local10:Int;
		var _local7 = null;
		var _local11:Int;
		var _local5 = null;
		var _local8 = null;
		var _local4:Int;
		var _local3:Int;
		var _local9:JAFrame = theSpriteInst.spriteDef.frames[cast theSpriteInst.frameNum];
		if (theSpriteInst.onNewFrame)
		{
			if (theSpriteInst.lastFrameNum < theSpriteInst.frameNum)
			{
				_local6 = cast theSpriteInst.frameNum;
				_local10 = cast (theSpriteInst.lastFrameNum + 1);
				while (_local10 < _local6)
				{
					_local7 = theSpriteInst.spriteDef.frames[_local10];
					FrameHit(theSpriteInst, _local7, theObjectPos);
					_local10++;
				};
			};
			FrameHit(theSpriteInst, _local9, theObjectPos);
		};
		if (_local9.hasStop)
		{
			if (theSpriteInst == _mainSpriteInst)
			{
				_animRunning = false;
				if (_listener != null)
				{
					_listener.JAnimStopped(_id, this);
				};
			};
			return;
		};
		_local11 = 0;
		while (_local11 < _local9.frameObjectPosVector.length)
		{
			_local5 = _local9.frameObjectPosVector[_local11];
			if (_local5.isSprite)
			{
				_local8 = theSpriteInst.children[_local5.objectNum].spriteInst;
				if (_local8 != null)
				{
					_local4 = cast (theSpriteInst.frameNum + (theSpriteInst.frameRepeats * theSpriteInst.spriteDef.frames.length));
					_local3 = cast (theSpriteInst.lastFrameNum + (theSpriteInst.frameRepeats * theSpriteInst.spriteDef.frames.length));
					if (((!((_local8.lastUpdated == _local3))) && (!((_local8.lastUpdated == _local4)))))
					{
						_local8.frameNum = 0;
						_local8.lastFrameNum = 0;
						_local8.frameRepeats = 0;
						_local8.delayFrames = 0;
						_local8.onNewFrame = true;
					};
					PrepSpriteInstFrame(_local8, _local5);
					_local8.lastUpdated = _local4;
				};
			};
			_local11++;
		};
	}

	private function IncSpriteInstFrame(theSpriteInst:JASpriteInst, theObjectPos:JAObjectPos, theFrac:Float):Void
	{
		var _local9:Int;
		var _local4 = null;
		var _local8 = null;
		var _local5:Int = cast theSpriteInst.frameNum;
		var _local7:JAFrame = theSpriteInst.spriteDef.frames[_local5];
		if (_local7.hasStop)
		{
			return;
		};
		theSpriteInst.lastFrameNum = theSpriteInst.frameNum;
		var _local6:Float = (((theObjectPos)!=null) ? theObjectPos.timeScale : 1);
		theSpriteInst.frameNum = (theSpriteInst.frameNum + ((theFrac * (theSpriteInst.spriteDef.animRate / 100)) / _local6));
		if (theSpriteInst == _mainSpriteInst)
		{
			if (!theSpriteInst.spriteDef.frames[(theSpriteInst.spriteDef.frames.length - 1)].hasStop)
			{
				if (theSpriteInst.frameNum >= ((theSpriteInst.spriteDef.workAreaStart + theSpriteInst.spriteDef.workAreaDuration) + 1))
				{
					theSpriteInst.frameRepeats++;
					theSpriteInst.frameNum = (theSpriteInst.frameNum - (theSpriteInst.spriteDef.workAreaDuration + 1));
					theSpriteInst.lastFrameNum = theSpriteInst.frameNum;
				};
			}
			else
			{
				if (theSpriteInst.frameNum >= (theSpriteInst.spriteDef.workAreaStart + theSpriteInst.spriteDef.workAreaDuration))
				{
					theSpriteInst.onNewFrame = true;
					theSpriteInst.frameNum = (theSpriteInst.spriteDef.workAreaStart + theSpriteInst.spriteDef.workAreaDuration);
					theSpriteInst.lastFrameNum = theSpriteInst.frameNum;
					if (theSpriteInst.spriteDef.workAreaDuration != 0)
					{
						_animRunning = false;
						if (_listener != null)
						{
							_listener.JAnimStopped(_id, this);
						};
						return;
					};
					theSpriteInst.frameRepeats++;
				};
			};
		}
		else
		{
			if (theSpriteInst.frameNum >= theSpriteInst.spriteDef.frames.length)
			{
				theSpriteInst.frameRepeats++;
				theSpriteInst.frameNum = (theSpriteInst.frameNum - theSpriteInst.spriteDef.frames.length);
			};
		};
		theSpriteInst.onNewFrame = !((theSpriteInst.frameNum == _local5));
		if (((theSpriteInst.onNewFrame) && ((theSpriteInst.delayFrames > 0))))
		{
			theSpriteInst.onNewFrame = false;
			theSpriteInst.frameNum = _local5;
			theSpriteInst.lastFrameNum = theSpriteInst.frameNum;
			theSpriteInst.delayFrames--;
			return;
		};
		_local9 = 0;
		while (_local9 < _local7.frameObjectPosVector.length)
		{
			_local4 = _local7.frameObjectPosVector[_local9];
			if (_local4.isSprite)
			{
				_local8 = theSpriteInst.children[_local4.objectNum].spriteInst;
				IncSpriteInstFrame(_local8, _local4, (theFrac / _local6));
			};
			_local9++;
		};
	}

	private function DoFramesHit(theSpriteInst:JASpriteInst, theObjectPos:JAObjectPos):Void
	{
		var _local6:Int;
		var _local3 = null;
		var _local4 = null;
		var _local5:JAFrame = theSpriteInst.spriteDef.frames[cast theSpriteInst.frameNum];
		FrameHit(theSpriteInst, _local5, theObjectPos);
		_local6 = 0;
		while (_local6 < _local5.frameObjectPosVector.length)
		{
			_local3 = _local5.frameObjectPosVector[_local6];
			if (_local3.isSprite)
			{
				_local4 = theSpriteInst.children[_local3.objectNum].spriteInst;
				if (_local4 != null)
				{
					DoFramesHit(_local4, _local3);
				};
			};
			_local6++;
		};
	}

	private function FrameHit(theSpriteInst:JASpriteInst, theFrame:JAFrame, theObjectPos:JAObjectPos):Void
	{
		var _local13:Int;
		var _local14 = null;
		var _local8 = null;
		var _local18:Int;
		var _local16:Int;
		var _local6:Int;
		var _local4 = null;
		var _local7:Bool;
		var _local17:Int;
		var _local11:Int;
		var _local10:JACommand = null;
		var _local20:Int;
		var _local19:String = null;
		var _local5:Int;
		var _local12:Float;
		var _local15:Float;
		var _local9 = null;
		theSpriteInst.onNewFrame = false;
		_local13 = 0;
		while (_local13 < theFrame.frameObjectPosVector.length)
		{
			_local14 = theFrame.frameObjectPosVector[_local13];
			if (_local14.isSprite)
			{
				_local8 = theSpriteInst.children[_local14.objectNum].spriteInst;
				if (_local8 != null)
				{
					_local18 = 0;
					while (_local18 < _local14.preloadFrames)
					{
						IncSpriteInstFrame(_local8, _local14, (100 / theSpriteInst.spriteDef.animRate));
						_local18++;
					};
				};
			};
			_local13++;
		};
		_local11 = 0;
		while (_local11 < theFrame.commandVector.length)
		{
			_local10 = theFrame.commandVector[_local11];
			if ((((_listener == null)) || (!(_listener.JAnimCommand(_id, this, theSpriteInst, _local10.command, _local10.param)))))
			{
				if (_local10.command == "delay")
				{
					_local6 = _local10.param.indexOf(",");
					if (_local6 != -1)
					{
						_local16 = cast _local10.param.substr(0, _local6);
						_local20 = cast _local10.param.substr((_local6 + 1));
						if (_local20 <= _local16)
						{
							_local20 = (_local16 + 1);
						};
						theSpriteInst.delayFrames = (_local16 + ((cast Math.random() * 100000) % (_local20 - _local16)));
					}
					else
					{
						_local16 = cast _local10.param;
						theSpriteInst.delayFrames = _local16;
					};
				}
				else
				{
					if (_local10.command == "playsample")
					{
						_local19 = _local10.param;
						_local5 = 0;
						_local12 = 1;
						_local15 = 0;
						_local7 = true;
						while (_local19.length > 0)
						{
							_local6 = _local19.indexOf(",");
							if (_local6 == -1)
							{
								_local4 = _local19;
							}
							else
							{
								_local4 = _local19.substr(0, _local6);
							};
							if (_local7)
							{
								_local9 = _local4;
								_local7 = false;
							}
							else
							{
								while ((_local17 = _local4.indexOf(" ")) != -1)
								{
									_local4 = (_local4.substr(0, _local17) + _local4.substr((_local17 + 1)));
								};
								if (_local4.substr(0, 7) == "volume=")
								{
									_local12 = cast _local4.substr(7);
								}
								else
								{
									if (_local4.substr(0, 4) == "pan=")
									{
										_local5 = cast _local4.substr(4);
									}
									else
									{
										if (_local4.substr(0, 6) == "steps=")
										{
											_local15 = cast _local4.substr(6);
										};
									};
								};
							};
							if (_local6 == -1) break;
							_local19 = _local19.substr((_local6 + 1));
						};
						if (_listener != null)
						{
							_listener.JAnimPLaySample(_local9, _local5, _local12, _local15);
						};
					};
				};
			};
			_local11++;
		};
	}

	private function UpdateTransforms(theSpriteInst:JASpriteInst, theTransform:JATransform, theColor:JAColor, parentFrozen:Bool):Void
	{
		var _local9:Int;
		var _local6 = null;
		if (theTransform != null)
		{
			theSpriteInst.curTransform.clone(theTransform);
		}
		else
		{
			theSpriteInst.curTransform.matrix.clone(_drawTransform);
		};
		if (theSpriteInst.curColor == null)
		{
			theSpriteInst.curColor = new JAColor();
		};
		theSpriteInst.curColor.clone(theColor);
		var _local5:JAFrame = theSpriteInst.spriteDef.frames[cast theSpriteInst.frameNum];
		var _local7:JATransform = _helpCallTransform[_helpCallDepth];
		var _local8:JAColor = _helpCallColor[_helpCallDepth];
		_helpCallDepth++;
		var _local10:Bool = ((((parentFrozen) || ((theSpriteInst.delayFrames > 0)))) || (_local5.hasStop));
		_local9 = 0;
		while (_local9 < _local5.frameObjectPosVector.length)
		{
			_local6 = _local5.frameObjectPosVector[_local9];
			if (_local6.isSprite)
			{
				CalcObjectPos(theSpriteInst, _local9, _local10);
				_local7 = _helpCalcTransform;
				_local8 = _helpCalcColor;
				_helpCalcTransform = null;
				_helpCalcColor = null;
				if (theTransform != null)
				{
					_local7 = theTransform.TransformSrc(_local7, _local7);
				};
				UpdateTransforms(theSpriteInst.children[_local6.objectNum].spriteInst, _local7, _local8, _local10);
			};
			_local9++;
		};
	}

	private function CalcObjectPos(theSpriteInst:JASpriteInst, theObjectPosIdx:Int, frozen:Bool):Void
	{
		var _local17 = null;
		var _local6 = null;
		var _local7 = null;
		var _local10:Int;
		var _local19 = null;
		var _local8:Int;
		var _local9:Float;
		var _local18:Bool;
		var _local11:JAFrame = theSpriteInst.spriteDef.frames[cast theSpriteInst.frameNum];
		var _local12:JAObjectPos = _local11.frameObjectPosVector[theObjectPosIdx];
		var _local5:JAObjectInst = theSpriteInst.children[_local12.objectNum];
		_helpANextObjectPos[0] = null;
		_helpANextObjectPos[1] = null;
		_helpANextObjectPos[2] = null;
		var _local14:Int = (theSpriteInst.spriteDef.frames.length - 1);
		var _local16:Int = 1;
		var _local13:Int = 2;
		if ((((theSpriteInst == _mainSpriteInst)) && ((theSpriteInst.frameNum >= theSpriteInst.spriteDef.workAreaStart))))
		{
			_local14 = (theSpriteInst.spriteDef.workAreaDuration - 1);
		};
		var _local15:JATransform = _helpCallTransform[_helpCallDepth];
		var _local4:JAColor = _helpCallColor[_helpCallDepth];
		_helpCallDepth++;
		if (((_interpolate) && (!(frozen))))
		{
			_local10 = 0;
			while (_local10 < 3)
			{
				_local19 = theSpriteInst.spriteDef.frames[cast ((theSpriteInst.frameNum + (((_local10)==0) ? _local14 : (((_local10)==1) ? _local16 : _local13))) % theSpriteInst.spriteDef.frames.length)];
				if ((((theSpriteInst == _mainSpriteInst)) && ((theSpriteInst.frameNum >= theSpriteInst.spriteDef.workAreaStart))))
				{
					_local19 = theSpriteInst.spriteDef.frames[cast ((((theSpriteInst.frameNum + (((_local10)==0) ? _local14 : (((_local10)==1) ? _local16 : _local13))) - theSpriteInst.spriteDef.workAreaStart) % (theSpriteInst.spriteDef.workAreaDuration + 1)) + theSpriteInst.spriteDef.workAreaStart)];
				}
				else
				{
					_local19 = theSpriteInst.spriteDef.frames[cast ((theSpriteInst.frameNum + (((_local10)==0) ? _local14 : (((_local10)==1) ? _local16 : _local13))) % theSpriteInst.spriteDef.frames.length)];
				};
				if (_local11.hasStop)
				{
					_local19 = _local11;
				};
				if (_local19.frameObjectPosVector.length > theObjectPosIdx)
				{
					_helpANextObjectPos[_local10] = _local19.frameObjectPosVector[theObjectPosIdx];
					if (_helpANextObjectPos[_local10].objectNum != _local12.objectNum)
					{
						_helpANextObjectPos[_local10] = null;
					};
				};
				if (_helpANextObjectPos[_local10] == null)
				{
					_local8 = 0;
					while (_local8 < _local19.frameObjectPosVector.length)
					{
						if (_local19.frameObjectPosVector[_local8].objectNum == _local12.objectNum)
						{
							_helpANextObjectPos[_local10] = _local19.frameObjectPosVector[_local8];
							break;
						};
						_local8++;
					};
				};
				_local10++;
			};
			if (_helpANextObjectPos[1] != null)
			{
				_local9 = (theSpriteInst.frameNum - Math.floor(theSpriteInst.frameNum));
				_local18 = false;
				_local15 = _local12.transform.InterpolateTo(_helpANextObjectPos[1].transform, _local9, _local15);
				_local4.Set(cast (((_local12.color.red * (1 - _local9)) + (_helpANextObjectPos[1].color.red * _local9)) + 0.5), cast (((_local12.color.green * (1 - _local9)) + (_helpANextObjectPos[1].color.green * _local9)) + 0.5), cast (((_local12.color.blue * (1 - _local9)) + (_helpANextObjectPos[1].color.blue * _local9)) + 0.5), cast (((_local12.color.alpha * (1 - _local9)) + (_helpANextObjectPos[1].color.alpha * _local9)) + 0.5));
			}
			else
			{
				_local15.clone(_local12.transform);
				_local4.clone(_local12.color);
			};
		}
		else
		{
			_local15.clone(_local12.transform);
			_local4.clone(_local12.color);
		};
		_local15.matrix = JAMatrix3.MulJAMatrix3(_local5.transform, _local15.matrix, _local15.matrix);
		if (((((_local5.isBlending) && (!((_blendTicksTotal == 0))))) && ((theSpriteInst == _mainSpriteInst))))
		{
			_local9 = (_blendTicksCur / _blendTicksTotal);
			_local15 = _local5.blendSrcTransform.InterpolateTo(_local15, _local9, _local15);
			_local4.Set(cast (((_local5.blendSrcColor.red * (1 - _local9)) + (_local4.red * _local9)) + 0.5), 
				cast (((_local5.blendSrcColor.green * (1 - _local9)) + (_local4.green * _local9)) + 0.5), 
				cast (((_local5.blendSrcColor.blue * (1 - _local9)) + (_local4.blue * _local9)) + 0.5), 
				cast (((_local5.blendSrcColor.alpha * (1 - _local9)) + (_local4.alpha * _local9)) + 0.5));
		};
		_helpCalcTransform = _local15;
		_helpCalcColor = _local4;
		_helpANextObjectPos[0] = null;
		_helpANextObjectPos[1] = null;
		_helpANextObjectPos[2] = null;
	}

	private function InitSpriteInst(theSpriteInst:JASpriteInst, theSpriteDef:JASpriteDef):Void
	{
		var _local7:Int;
		var _local6 = null;
		var _local5 = null;
		var _local4 = null;
		var _local3 = null;
		theSpriteInst.frameRepeats = 0;
		theSpriteInst.delayFrames = 0;
		theSpriteInst.spriteDef = theSpriteDef;
		theSpriteInst.lastUpdated = -1;
		theSpriteInst.onNewFrame = true;
		theSpriteInst.frameNum = 0;
		theSpriteInst.lastFrameNum = 0;
		theSpriteInst.children.splice(0, theSpriteInst.children.length);
		theSpriteInst.children.length = theSpriteDef.objectDefVector.length;
		_local7 = 0;
		while (_local7 < theSpriteDef.objectDefVector.length)
		{
			theSpriteInst.children[_local7] = new JAObjectInst();
			_local7++;
		};
		_local7 = 0;
		while (_local7 < theSpriteDef.objectDefVector.length)
		{
			_local6 = theSpriteDef.objectDefVector[_local7];
			_local5 = theSpriteInst.children[_local7];
			_local5.colorMult = new JAColor();
			_local5.colorMult.clone(JAColor.White);
			_local5.name = _local6.name;
			_local5.isBlending = false;
			_local4 = _local6.spriteDef;
			if (_local4 != null)
			{
				_local3 = new JASpriteInst();
				_local3.parent = theSpriteInst;
				InitSpriteInst(_local3, _local4);
				_local5.spriteInst = _local3;
			};
			_local7++;
		};
		if (theSpriteInst == _mainSpriteInst)
		{
			GetToFirstFrame();
		};
	}

	private function ResetAnimHelper(theSpriteInst:JASpriteInst):Void
	{
		var _local3:Int;
		var _local2 = null;
		theSpriteInst.frameNum = 0;
		theSpriteInst.lastFrameNum = 0;
		theSpriteInst.frameRepeats = 0;
		theSpriteInst.delayFrames = 0;
		theSpriteInst.lastUpdated = -1;
		theSpriteInst.onNewFrame = true;
		_local3 = 0;
		while (_local3 < theSpriteInst.children.length)
		{
			_local2 = theSpriteInst.children[_local3].spriteInst;
			if (_local2 != null)
			{
				ResetAnimHelper(_local2);
			};
			_local3++;
		};
		_transDirty = true;
	}
}