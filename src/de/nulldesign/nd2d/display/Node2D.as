/*
 * ND2D - A Flash Molehill GPU accelerated 2D engine
 *
 * Author: Lars Gerckens
 * Copyright (c) nulldesign 2011
 * Repository URL: http://github.com/nulldesign/nd2d
 * Getting started: https://github.com/nulldesign/nd2d/wiki
 *
 *
 * Licence Agreement
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package de.nulldesign.nd2d.display {

	import de.nulldesign.nd2d.materials.BlendModePresets;
	import de.nulldesign.nd2d.utils.NodeBlendMode;

	import flash.display.Stage;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	/**
	 * Dispatched when the scene is active and added to the stage.
	 * @eventType flash.events.Event.ADDED_TO_STAGE
	 */
	[Event(name="addedToStage", type="flash.events.Event")]

	/**
	 * Dispatched when the scene inactive and removed from stage.
	 * @eventType flash.events.Event.REMOVED_FROM_STAGE
	 */
	[Event(name="removedFromStage", type="flash.events.Event")]

	/**
	 * Dispatched when a user presses and releases the main button of the user's
	 * pointing device over the same Node2D.
	 * @eventType flash.events.MouseEvent.CLICK
	 */
	[Event(name="click", type="flash.events.MouseEvent")]

	/**
	 * Dispatched when a user presses the pointing device button over an Node2D
	 * instance.
	 * @eventType flash.events.MouseEvent.MOUSE_DOWN
	 */
	[Event(name="mouseDown", type="flash.events.MouseEvent")]

	/**
	 * Dispatched when a user moves the pointing device while it is over an Node2D.
	 * @eventType flash.events.MouseEvent.MOUSE_MOVE
	 */
	[Event(name="mouseMove", type="flash.events.MouseEvent")]

	/**
	 * Dispatched when a user releases the pointing device button over an Node2D
	 * instance.
	 * @eventType flash.events.MouseEvent.MOUSE_UP
	 */
	[Event(name="mouseUp", type="flash.events.MouseEvent")]

	/**
	 * Dispatched when the user moves a pointing device over an Node2D instance.
	 * @eventType flash.events.MouseEvent.MOUSE_OVER
	 */
	[Event(name="mouseOver", type="flash.events.MouseEvent")]

	/**
	 * Dispatched when the user moves a pointing device away from an Node2D
	 * instance.
	 * @eventType flash.events.MouseEvent.MOUSE_OUT
	 */
	[Event(name="mouseOut", type="flash.events.MouseEvent")]

	/**
	 * Dispatched when a user presses and releases the main button of the user's
	 * pointing device over the same Node2D.
	 * @eventType flash.events.TouchEvent.TOUCH_TAP
	 */
	[Event(name="touchTap", type="flash.events.TouchEvent")]

	/**
	 * Dispatched when the user moves a pointing device over an Node2D instance.
	 * @eventType flash.events.TouchEvent.TOUCH_OVER
	 */
	[Event(name="touchOver", type="flash.events.TouchEvent")]

	/**
	 * Dispatched when the user moves a pointing device away from an Node2D
	 * instance.
	 * @eventType flash.events.TouchEvent.TOUCH_OUT
	 */
	[Event(name="touchOut", type="flash.events.TouchEvent")]

	/**
	 * Dispatched when a user moves the pointing device while it is over an Node2D.
	 * @eventType flash.events.TouchEvent.TOUCH_MOVE
	 */
	[Event(name="touchMove", type="flash.events.TouchEvent")]

	/**
	 * Dispatched when a user presses the pointing device button over an Node2D
	 * instance.
	 * @eventType flash.events.TouchEvent.TOUCH_BEGIN
	 */
	[Event(name="touchBegin", type="flash.events.TouchEvent")]

	/**
	 * Dispatched when a user releases the pointing device button over an Node2D
	 * instance.
	 * @eventType flash.events.TouchEvent.TOUCH_END
	 */
	[Event(name="touchEnd", type="flash.events.TouchEvent")]

	/**
	 * <p>Base 2D object. All drawable objects must extend Node2D</p>
	 * A Node2D has two methods that are called during rendering:
	 * <ul>
	 * <li>step - Update the node's position here</li>
	 * <li>draw - Your rendering code goes here</li>
	 * </ul>
	 */
	public class Node2D extends EventDispatcher {

		/**
		 * @private
		 */
		public var localModelMatrix:Matrix3D = new Matrix3D();

		/**
		 * @private
		 */
		public var worldModelMatrix:Matrix3D = new Matrix3D();

		/**
		 * @private
		 */
		public var invalidateMatrix:Boolean = true;

		/**
		 * @private
		 */
		public var clipSpaceMatrix:Matrix3D = new Matrix3D();

		/**
		 * @private
		 */
		public var invalidateClipSpace:Boolean = true;

		/**
		 * Currently only used by Sprite2DCloud
		 *
		 * @private
		 */
		public var invalidateUV:Boolean = true;

		/**
		 * Currently only used by Sprite2DCloud
		 * We use it as the lite version of invalidateColors
		 *
		 * @private
		 */
		public var invalidateVisibility:Boolean = true;

		/**
		 * @private
		 */
		public var invalidateColors:Boolean = true;

		public var hasPremultipliedAlphaTexture:Boolean = true;

		public var childCount:uint = 0;
		public var childFirst:Node2D = null;
		public var childLast:Node2D = null;

		public var prev:Node2D = null;
		public var next:Node2D = null;

		public var batchParent:Sprite2DBatch = null;

		public var usesUV:Boolean = false;
		public var usesColor:Boolean = false;
		public var usesColorOffset:Boolean = false;

		public var vx:Number;
		public var vy:Number;

		public var tag:int = 0;

		public var blendMode:NodeBlendMode = BlendModePresets.NORMAL;

		public var mouseEnabled:Boolean = false;

		public var boundingSphereRadius:Number;

		protected var timeSinceStartInSeconds:Number = 0.0;

		protected var camera:Camera2D;

		private var localMouse:Vector3D;
		private var localMouseMatrix:Matrix3D = new Matrix3D();

		internal var mouseInNode:Boolean = false;
		internal var mouseEvents:Vector.<Event> = new Vector.<Event>();

		protected var _stage:Stage;

		public function get stage():Stage {
			return _stage;
		}

		/**
		 * [read-only] Use addChild() instead
		 */
		public var parent:Node2D;

		public var world:World2D;

		public var scene:Scene2D;

		protected var _width:Number;

		public function get width():Number {
			return Math.abs(_width * _scaleX);
		}

		public function set width(value:Number):void {
			scaleX = value / _width;
		}

		protected var _height:Number;

		public function get height():Number {
			return Math.abs(_height * _scaleY);
		}

		public function set height(value:Number):void {
			scaleY = value / _height;
		}

		protected var _visible:Boolean = true;

		public function get visible():Boolean {
			return _visible;
		}

		public function set visible(value:Boolean):void {
			if(_visible != value) {
				_visible = value;
				invalidateVisibility = true;

				if(value) {
					invalidateMatrix = true;
				}
			}
		}

		protected var _alpha:Number = 1.0;

		public function set alpha(value:Number):void {
			if(_alpha != value) {
				_alpha = value;
				invalidateColors = true;
				visible = (_alpha > 0.0);
			}
		}

		public function get alpha():Number {
			return _alpha;
		}

		/**
		 * @private
		 */
		public var combinedColorTransform:ColorTransform = new ColorTransform();

		protected var _colorTransform:ColorTransform = new ColorTransform();

		public function get colorTransform():ColorTransform {
			return _colorTransform;
		}

		public function set colorTransform(value:ColorTransform):void {
			if(_colorTransform != value) {
				_colorTransform = value;
				invalidateColors = true;
			}
		}

		protected var _tint:uint = 0xFFFFFF;

		public function get tint():uint {
			return _tint;
		}

		public function set tint(value:uint):void {
			if(_tint != value && _colorTransform) {
				_tint = value;

				var r:Number = (_tint >> 16 & 255) / 255.0;
				var g:Number = (_tint >> 8 & 255) / 255.0;
				var b:Number = (_tint & 255) / 255.0;

				_colorTransform.redMultiplier = r;
				_colorTransform.greenMultiplier = g;
				_colorTransform.blueMultiplier = b;
				_colorTransform.alphaMultiplier = 1.0;
				_colorTransform.redOffset = 0;
				_colorTransform.greenOffset = 0;
				_colorTransform.blueOffset = 0;
				_colorTransform.alphaOffset = 0;

				invalidateColors = true;
			}
		}

		protected var _uvOffsetX:Number = 0.0;

		/**
		 * Use this property to animate a texture
		 */
		public function set uvOffsetX(value:Number):void {
			if(_uvOffsetX != value) {
				_uvOffsetX = value;
				invalidateUV = true;
			}
		}

		public function get uvOffsetX():Number {
			return _uvOffsetX;
		}

		protected var _uvOffsetY:Number = 0.0;

		/**
		 * Use this property to animate a texture
		 */
		public function set uvOffsetY(value:Number):void {
			if(_uvOffsetY != value) {
				_uvOffsetY = value;
				invalidateUV = true;
			}
		}

		public function get uvOffsetY():Number {
			return _uvOffsetY;
		}

		protected var _uvScaleX:Number = 1.0;

		/**
		 * Use this property to repeat/scale a texture.
		 */
		public function set uvScaleX(value:Number):void {
			if(_uvScaleX != value) {
				_uvScaleX = value;
				invalidateUV = true;
			}
		}

		public function get uvScaleX():Number {
			return _uvScaleX;
		}

		protected var _uvScaleY:Number = 1.0;

		/**
		 * Use this property to repeat/scale a texture.
		 */
		public function set uvScaleY(value:Number):void {
			if(_uvScaleY != value) {
				_uvScaleY = value;
				invalidateUV = true;
			}
		}

		public function get uvScaleY():Number {
			return _uvScaleY;
		}

		protected var _scaleX:Number = 1.0;

		public function set scaleX(value:Number):void {
			if(_scaleX != value) {
				_scaleX = value;
				invalidateMatrix = true;
			}
		}

		public function get scaleX():Number {
			return _scaleX;
		}

		protected var _scaleY:Number = 1.0;

		public function set scaleY(value:Number):void {
			if(_scaleY != value) {
				_scaleY = value;
				invalidateMatrix = true;
			}
		}

		public function get scaleY():Number {
			return _scaleY;
		}

		public function set scale(value:Number):void {
			scaleX = value;
			scaleY = value;
		}

		protected var _x:Number = 0.0;

		public function set x(value:Number):void {
			if(_x != value) {
				_position.x = _x = value;
				invalidateMatrix = true;
			}
		}

		public function get x():Number {
			return _x;
		}

		protected var _y:Number = 0.0;

		public function set y(value:Number):void {
			if(_y != value) {
				_position.y = _y = value;
				invalidateMatrix = true;
			}
		}

		public function get y():Number {
			return _y;
		}

		protected var _z:Number = 0.0;

		public function set z(value:Number):void {
			if(_z != value) {
				_position.z = _z = value;
				invalidateMatrix = true;
			}
		}

		public function get z():Number {
			return _z;
		}

		protected var _position:Vector3D = new Vector3D(0.0, 0.0, 0.0);

		public function get position():Vector3D {
			return _position;
		}

		public function set position(value:Vector3D):void {
			if(_x != value.x || _y != value.y || _z != value.z) {
				_position.x = _x = value.x;
				_position.y = _y = value.y;
				_position.z = _z = value.z;
				invalidateMatrix = true;
			}
		}

		protected var _pivot:Point = new Point(0.0, 0.0);

		public function get pivot():Point {
			return _pivot;
		}

		public function set pivot(value:Point):void {
			if(_pivot.x != value.x || _pivot.y != value.y) {
				_pivot.x = value.x;
				_pivot.y = value.y;
				invalidateMatrix = true;
			}
		}

		/**
		 * @private
		 */
		public var localScrollRect:Rectangle;

		/**
		 * @private
		 */
		public var worldScrollRect:Rectangle;

		public function get scrollRect():Rectangle {
			return localScrollRect;
		}

		public function set scrollRect(value:Rectangle):void {
			if(!localScrollRect || localScrollRect.x != value.x || localScrollRect.y != value.y || localScrollRect.width != value.width || localScrollRect.height != value.height) {
				localScrollRect = value;
				invalidateMatrix = true;
			}
		}

		public function set rotation(value:Number):void {
			if(_rotationZ != value) {
				_rotationZ = value;
				invalidateMatrix = true;
			}
		}

		public function get rotation():Number {
			return _rotationZ;
		}

		protected var _rotationX:Number = 0.0;

		public function set rotationX(value:Number):void {
			if(_rotationX != value) {
				_rotationX = value;
				invalidateMatrix = true;
			}
		}

		public function get rotationX():Number {
			return _rotationX;
		}

		protected var _rotationY:Number = 0.0;

		public function set rotationY(value:Number):void {
			if(_rotationY != value) {
				_rotationY = value;
				invalidateMatrix = true;
			}
		}

		public function get rotationY():Number {
			return _rotationY;
		}

		protected var _rotationZ:Number = 0.0;

		public function set rotationZ(value:Number):void {
			if(_rotationZ != value) {
				_rotationZ = value;
				invalidateMatrix = true;
			}
		}

		public function get rotationZ():Number {
			return _rotationZ;
		}

		protected var _mouseX:Number = 0.0;

		public function get mouseX():Number {
			return _mouseX;
		}

		protected var _mouseY:Number = 0.0;

		public function get mouseY():Number {
			return _mouseY;
		}

		public function get numChildren():uint {
			return childCount;
		}

		public function Node2D() {
		}

		/**
		 * @private
		 */
		public function updateLocalMatrix():void {
			invalidateMatrix = false;

			localModelMatrix.identity();
			localModelMatrix.appendTranslation(-_pivot.x, -_pivot.y, 0);
			localModelMatrix.appendScale(_scaleX, _scaleY, 1.0);
			localModelMatrix.appendRotation(_rotationZ, Vector3D.Z_AXIS);
			localModelMatrix.appendRotation(_rotationY, Vector3D.Y_AXIS);
			localModelMatrix.appendRotation(_rotationX, Vector3D.X_AXIS);
			localModelMatrix.appendTranslation(_x, _y, _z);
		}

		/**
		 * @private
		 */
		public function updateWorldMatrix():void {
			worldModelMatrix.identity();
			worldModelMatrix.append(localModelMatrix);

			if(parent) {
				worldModelMatrix.append(parent.worldModelMatrix);
			}

			updateScrollRect();
			updateClipSpace();

			if(useFrustumCulling) {
				updateCulling();
			}
		}

		/**
		 * @private
		 */
		public function updateScrollRect():void {
			if(localScrollRect) {
				var pos:Point = localToWorld(new Point(-localScrollRect.width >> 1, -localScrollRect.height >> 1));

				worldScrollRect = localScrollRect.clone();
				worldScrollRect.x = pos.x;
				worldScrollRect.y = pos.y;

				if(parent && parent.worldScrollRect) {
					worldScrollRect = worldScrollRect.intersection(parent.worldScrollRect);
				}
			} else if(parent && parent.worldScrollRect) {
				worldScrollRect = parent.worldScrollRect.clone();
			}

			if(localScrollRect) {
				worldModelMatrix.prependTranslation(-localScrollRect.x, -localScrollRect.y, 0);
			}
		}

		/**
		 * @private
		 */
		public function updateClipSpace():void {
			invalidateClipSpace = false;

			clipSpaceMatrix.identity();
			clipSpaceMatrix.append(worldModelMatrix);
		}

		private static const offsetFactor:Number = 1.0 / 255.0;

		/**
		 * @private
		 */
		public function updateColors():void {
			invalidateColors = false;

			combinedColorTransform.redMultiplier = _colorTransform.redMultiplier;
			combinedColorTransform.greenMultiplier = _colorTransform.greenMultiplier;
			combinedColorTransform.blueMultiplier = _colorTransform.blueMultiplier;
			combinedColorTransform.alphaMultiplier = _colorTransform.alphaMultiplier * _alpha;

			// premultiply alpha
			if(hasPremultipliedAlphaTexture) {
				combinedColorTransform.redMultiplier *= combinedColorTransform.alphaMultiplier;
				combinedColorTransform.greenMultiplier *= combinedColorTransform.alphaMultiplier;
				combinedColorTransform.blueMultiplier *= combinedColorTransform.alphaMultiplier;
			}

			combinedColorTransform.redOffset = _colorTransform.redOffset * offsetFactor;
			combinedColorTransform.greenOffset = _colorTransform.greenOffset * offsetFactor;
			combinedColorTransform.blueOffset = _colorTransform.blueOffset * offsetFactor;
			combinedColorTransform.alphaOffset = _colorTransform.alphaOffset * offsetFactor * combinedColorTransform.alphaMultiplier;

			if(parent) {
				combinedColorTransform.concat(parent.combinedColorTransform);
			}

			usesColor = combinedColorTransform.redMultiplier != 1.0
				|| combinedColorTransform.greenMultiplier != 1.0
				|| combinedColorTransform.blueMultiplier != 1.0
				|| combinedColorTransform.alphaMultiplier != 1.0;

			usesColorOffset = combinedColorTransform.redOffset != 0.0
				|| combinedColorTransform.greenOffset != 0.0
				|| combinedColorTransform.blueOffset != 0.0
				|| combinedColorTransform.alphaOffset != 0.0;

			for(var child:Node2D = childFirst; child; child = child.next) {
				child.updateColors();
			}
		}

		/**
		 * @private
		 */
		public function updateUV():void {
			invalidateUV = false;

			usesUV = _uvOffsetX != 0.0
				|| _uvOffsetY != 0.0
				|| _uvScaleX != 1.0
				|| _uvScaleY != 1.0;
		}

		/**
		 * @private
		 */
		public var culled:Boolean = false;

		/**
		 * @private
		 */
		public var invalidateCullingCount:uint;

		/**
		 * If <code>true</code>, wont send it to the GPU at all if it's position
		 * is off screen and not visible anyway.
		 *
		 * <p>Typically makes sense if GPU is slower than CPU or when not using
		 * own culling system.</p>
		 */
		public var useFrustumCulling:Boolean = false;

		/**
		 * @private
		 */
		public function updateCulling():void {
			var radius:int = Math.max(Math.abs(_width * _scaleX), Math.abs(_height * _scaleY)) >> 1;

			invalidateCullingCount = camera.invalidateCount;

			// matrix operations are heavy, fall back to a simple version
			if(!camera.rotation) {
				var pos:Vector3D = worldModelMatrix.position;

				culled = pos.x + radius < camera.x
					|| pos.y + radius < camera.y
					|| pos.x - radius > camera.x + camera.sceneWidth
					|| pos.y - radius > camera.y + camera.sceneHeight;
			} else {
				var point:Point = localToGlobal(new Point());

				culled = point.x + radius < 0
					|| point.y + radius < 0
					|| point.x - radius > camera.sceneWidth
					|| point.y - radius > camera.sceneHeight;
			}
		}

		/**
		 * @private
		 */
		internal function processMouseEvent(mousePosition:Vector3D, mouseEventType:String, cameraViewProjectionMatrix:Matrix3D, isTouchEvent:Boolean, touchPointID:int):Node2D {
			var result:Node2D = null;

			if(mouseEnabled && mouseEventType) {
				mouseEvents.length = 0;

				// transform mousepos to local coordinate system
				localMouseMatrix.identity();
				localMouseMatrix.append(worldModelMatrix);
				localMouseMatrix.append(cameraViewProjectionMatrix);
				localMouseMatrix.invert();

				localMouse = localMouseMatrix.transformVector(mousePosition);

				_mouseX = localMouse.x;
				_mouseY = localMouse.y;

				var oldMouseInNodeState:Boolean = mouseInNode;
				var newMouseInNode:Boolean = hitTest();

				if(newMouseInNode) {
					result = this;

					if(!oldMouseInNodeState) {
						if(isTouchEvent) {
							mouseEvents.push(new TouchEvent(TouchEvent.TOUCH_OVER, false, false, touchPointID, false, localMouse.x, localMouse.y));
						} else {
							mouseEvents.push(new MouseEvent(MouseEvent.MOUSE_OVER, false, false, localMouse.x, localMouse.y, null, false, false, false, (mouseEventType == MouseEvent.MOUSE_DOWN), 0));
						}
					}

					if(isTouchEvent) {
						mouseEvents.push(new TouchEvent(mouseEventType, false, false, touchPointID, false, localMouse.x, localMouse.y));
					} else {
						mouseEvents.push(new MouseEvent(mouseEventType, false, false, localMouse.x, localMouse.y, null, false, false, false, (mouseEventType == MouseEvent.MOUSE_DOWN), 0));
					}
				} else if(oldMouseInNodeState) {
					// dispatch mouse out directly, no hierarchy test
					if(isTouchEvent) {
						dispatchEvent(new TouchEvent(TouchEvent.TOUCH_OUT, false, false, touchPointID, false, localMouse.x, localMouse.y));
					} else {
						dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT, false, false, localMouse.x, localMouse.y, null, false, false, false, (mouseEventType == MouseEvent.MOUSE_DOWN), 0));
					}
				}

				var subChildMouseNode:Node2D;

				for(var child:Node2D = childLast; child; child = child.prev) {
					subChildMouseNode = child.processMouseEvent(mousePosition, mouseEventType, cameraViewProjectionMatrix, isTouchEvent, touchPointID);

					if(subChildMouseNode) {
						result = subChildMouseNode;
						break;
					}
				}

				// set over to false, if one of our childs stole the event
				if(result != this) {
					mouseInNode = false;
				}
			}

			return result;
		}

		/**
		 * Overwrite and do your own hitTest if you like
		 * @return
		 */
		protected function hitTest():Boolean {
			// even faster isNaN()	http://jacksondunstan.com/articles/983
			if(_width != _width || _height != _height) {
				return false;
			}

			var halfWidth:Number = _width >> 1;
			var halfHeight:Number = _height >> 1;

			return _mouseX >= -halfWidth
				&& _mouseX <= halfWidth
				&& _mouseY >= -halfHeight
				&& _mouseY <= halfHeight;
		}

		internal function setReferences(stage:Stage, camera:Camera2D, world:World2D, scene:Scene2D):void {
			var propagate:Boolean = false;

			if(_stage != stage) {
				propagate = true;

				if(stage) {
					_stage = stage;
					dispatchEvent(new Event(Event.ADDED_TO_STAGE));
				} else {
					dispatchEvent(new Event(Event.REMOVED_FROM_STAGE));
					_stage = stage;
				}
			}

			if(this.camera != camera) {
				propagate = true;
				this.camera = camera;
			}

			if(this.world != world) {
				propagate = true;
				this.world = world;
			}

			if(this.scene != scene) {
				propagate = true;
				this.scene = scene;
			}

			if(propagate) {
				for(var child:Node2D = childFirst; child; child = child.next) {
					child.setReferences(stage, camera, world, scene);
				}
			}
		}

		/**
		 * @private
		 */
		internal function stepNode(elapsed:Number, timeSinceStartInSeconds:Number):void {
			this.timeSinceStartInSeconds = timeSinceStartInSeconds;

			step(elapsed);

			for(var child:Node2D = childFirst; child; child = child.next) {
				child.stepNode(elapsed, timeSinceStartInSeconds);
			}
		}

		/**
		 * @private
		 */
		internal function drawNode(context:Context3D, camera:Camera2D):void {
			if(!_visible) {
				return;
			}

			if(invalidateUV) {
				updateUV();
			}

			if(invalidateColors) {
				updateColors();
			}

			if(invalidateMatrix || (parent && parent.invalidateMatrix)) {
				if(invalidateMatrix) {
					updateLocalMatrix();
				}

				updateWorldMatrix();

				invalidateMatrix = true;
			} else if(invalidateClipSpace) {
				updateClipSpace();
			}

			if(useFrustumCulling && invalidateCullingCount != camera.invalidateCount) {
				updateCulling();
			}

			draw(context, camera);

			for(var child:Node2D = childFirst; child; child = child.next) {
				child.drawNode(context, camera);
			}

			invalidateMatrix = false;
		}

		public function draw(context:Context3D, camera:Camera2D):void {
			// override in extended classes
		}

		protected function step(elapsed:Number):void {
			// override in extended classes
		}

		protected function unlinkChild(child:Node2D):void {
			if(child.prev) {
				child.prev.next = child.next;
			} else {
				childFirst = child.next;
			}

			if(child.next) {
				child.next.prev = child.prev;
			} else {
				childLast = child.prev;
			}

			child.prev = null;
			child.next = null;
		}

		public function addChild(child:Node2D):Node2D {
			if(child.parent) {
				child.parent.removeChild(child);
			}

			if(batchParent) {
				batchParent.addBatchParent(child);
			}

			child.parent = this;
			child.setReferences(_stage, camera, world, scene);

			if(childLast) {
				child.prev = childLast;
				childLast.next = child;
				childLast = child;
			} else {
				childFirst = child;
				childLast = child;
			}

			childCount++;

			return child;
		}

		public function removeChild(child:Node2D):void {
			if(child.parent != this) {
				return;
			}

			if(batchParent) {
				batchParent.removeBatchParent(child);
			}

			unlinkChild(child);

			child.parent = null;
			child.invalidateUV = true;
			child.invalidateMatrix = true;
			child.invalidateColors = true;
			child.invalidateVisibility = true;
			child.setReferences(null, null, null, null);

			childCount--;
		}

		/**
		 * Insert or move child1 before child2
		 * @return
		 */
		public function insertChildBefore(child1:Node2D, child2:Node2D):void {
			if(child2.parent != this) {
				return;
			}

			if(child1.parent != this) {
				addChild(child1);
			}

			unlinkChild(child1);

			if(child2.prev) {
				child2.prev.next = child1;
			} else {
				childFirst = child1;
			}

			child1.prev = child2.prev;
			child1.next = child2;
			child2.prev = child1;
		}

		/**
		 * Insert or move child1 after child2
		 * @return
		 */
		public function insertChildAfter(child1:Node2D, child2:Node2D):void {
			if(child2.parent != this) {
				return;
			}

			if(child1.parent != this) {
				addChild(child1);
			}

			unlinkChild(child1);

			if(child2.next) {
				child2.next.prev = child1;
			} else {
				childLast = child1;
			}

			child1.prev = child2;
			child1.next = child2.next;
			child2.next = child1;
		}

		public function swapChildren(child1:Node2D, child2:Node2D):void {
			if(child1.parent != this || child2.parent != this) {
				return;
			}

			if(child1.prev) {
				child1.prev.next = child2;
			} else {
				childFirst = child2;
			}

			if(child2.prev) {
				child2.prev.next = child1;
			} else {
				childFirst = child1;
			}

			if(child1.next) {
				child1.next.prev = child2;
			} else {
				childLast = child2;
			}

			if(child2.next) {
				child2.next.prev = child1;
			} else {
				childLast = child1;
			}

			var swap:Node2D;

			swap = child1.prev;
			child1.prev = child2.prev;
			child2.prev = swap;

			swap = child1.next;
			child1.next = child2.next;
			child2.next = swap;
		}

		/**
		 * Recursive merge sort implementation is faster in AS3
		 */
		internal function merge(sortFunction:Function, sortDirection:int, left:Node2D, count:uint, first:Boolean = false):Node2D {
			if(!left || !left.next) {
				return left;
			}

			var next:Node2D = null;
			var last:Node2D = null;
			var right:Node2D = left;
			var result:Node2D = null;
			var invalidate:Node2D = null;

			// find halfway
			var half:uint = count >> 1;

			for(var i:uint = 0; i < half; i++) {
				right = right.next;
			}

			// separate left from right
			right.prev.next = null;

			// divide
			left = merge(sortFunction, sortDirection, left, half);
			right = merge(sortFunction, sortDirection, right, count - half);

			// merge
			while(left || right) {
				if(!left) {
					next = right;
					right = right.next;
				} else if(!right || sortFunction(left, right) * sortDirection < 0) {
					next = left;
					left = left.next;

					if(right && !invalidate) {
						invalidate = next;
					}
				} else {
					next = right;
					right = right.next;
				}

				if(!result) {
					result = next;
				} else {
					last.next = next;
				}

				next.prev = last;
				last = next;
			}

			if(invalidate && (this is Sprite2DCloud)) {
				Sprite2DCloud(this).invalidateChilds(invalidate);
			}

			if(first) {
				childFirst = result;
				childLast = last;
			}

			return result;
		}

		public function compareY(node1:Node2D, node2:Node2D):int {
			if(node1._y > node2._y) {
				return 1;
			} else if(node1._y < node2._y) {
				return -1;
			}

			return 0;
		}

		public const SORT_ASC:int = -1;
		public const SORT_DESC:int = 1;

		/**
		 * Fast merge sort based on compare function.
		 *
		 * Pass your own compare function or use the build-in
		 * Y-sort which is faster because it avoids getters.
		 *
		 * mergeSort(compareY, SORT_DESC)
		 *
		 * @param sortFunction
		 * @param sortDirection         SORT_ASC or SORT_DESC
		 */
		public function mergeSort(sortFunction:Function, sortDirection:int = SORT_DESC):void {
			merge(sortFunction, sortDirection, childFirst, childCount, true);
		}

		public function removeAllChildren():void {
			// reverse order to speed up Sprite2DCloud
			while(childLast) {
				removeChild(childLast);
			}
		}

		public function getChildByTag(value:int):Node2D {
			for(var child:Node2D = childFirst; child; child = child.next) {
				if(child.tag == value) {
					return child;
				}
			}

			return null;
		}

		/**
		 * transforms a point from the nodes local coordinate system into global
		 * space
		 * @param p
		 * @return
		 */
		public function localToGlobal(p:Point):Point {
			var clipSpaceMat:Matrix3D = new Matrix3D();
			clipSpaceMat.append(worldModelMatrix);
			clipSpaceMat.append(camera.getViewProjectionMatrix());

			var v:Vector3D = clipSpaceMat.transformVector(new Vector3D(p.x, p.y, 0.0));

			return new Point((v.x + 1.0) * 0.5 * camera.sceneWidth, (-v.y + 1.0) * 0.5 * camera.sceneHeight);
		}

		/**
		 * transforms a point into the nodes local coordinate system
		 * @param p
		 * @return
		 */
		public function globalToLocal(p:Point):Point {
			var clipSpaceMat:Matrix3D = new Matrix3D();
			clipSpaceMat.append(worldModelMatrix);
			clipSpaceMat.append(camera.getViewProjectionMatrix());
			clipSpaceMat.invert();

			var from:Vector3D = new Vector3D(p.x / camera.sceneWidth * 2.0 - 1.0,
				-(p.y / camera.sceneHeight * 2.0 - 1.0),
				0.0, 1.0);

			var v:Vector3D = clipSpaceMat.transformVector(from);
			v.w = 1.0 / v.w;
			v.x /= v.w;
			v.y /= v.w;
			//v.z /= v.w;

			return new Point(v.x, v.y);
		}

		/**
		 * transforms a point into world coordinates
		 * @param p
		 * @return the transformed point
		 */
		public function localToWorld(p:Point):Point {
			var clipSpaceMat:Matrix3D = new Matrix3D();
			clipSpaceMat.append(worldModelMatrix);

			var v:Vector3D = clipSpaceMat.transformVector(new Vector3D(p.x, p.y, 0.0));

			return new Point(v.x, v.y);
		}

		public function handleDeviceLoss():void {
			for(var child:Node2D = childFirst; child; child = child.next) {
				child.handleDeviceLoss();
			}

			// extend in extended classes
		}

		public function dispose():void {
			// reverse order to speed up Sprite2DCloud
			while(childLast) {
				childLast.dispose();
			}

			if(parent) {
				parent.removeChild(this);
			}

			_pivot = null;
			_position = null;
			blendMode = null;
			mouseEvents = null;
			_colorTransform = null;
			localScrollRect = null;
			worldScrollRect = null;
			localModelMatrix = null;
			worldModelMatrix = null;
			localMouseMatrix = null;
			combinedColorTransform = null;
		}
	}
}
