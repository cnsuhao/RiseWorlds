package com.genome2d.components.renderables.jointanim;

/**
 * ...
 * @author Rise
 */
class JATransform2D extends JAMatrix3
{
	private static var _helpMatrix:JAMatrix3 = new JAMatrix3();
	
	public function Scale(sx:Float, sy:Float):Void
	{
		_helpMatrix.LoadIdentity();
		_helpMatrix.m00 = sx;
		_helpMatrix.m11 = sy;
		JAMatrix3.MulJAMatrix3(_helpMatrix, this, this);
	}

	public function Translate(tx:Float, ty:Float):Void
	{
		_helpMatrix.LoadIdentity();
		_helpMatrix.m02 = tx;
		_helpMatrix.m12 = ty;
		JAMatrix3.MulJAMatrix3(_helpMatrix, this, this);
	}

	public function RotateDeg(rot:Float):Void
	{
		RotateRad((0.0174532925199433 * rot));
	}

	public function RotateRad(rot:Float):Void
	{
		_helpMatrix.LoadIdentity();
		var _local3:Float = Math.sin(rot);
		var _local2:Float = Math.cos(rot);
		_helpMatrix.m00 = _local2;
		_helpMatrix.m01 = _local3;
		_helpMatrix.m10 = -(_local3);
		_helpMatrix.m11 = _local2;
		JAMatrix3.MulJAMatrix3(_helpMatrix, this, this);
	}
	
}