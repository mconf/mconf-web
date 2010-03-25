/*
 *This file is part of SparkWeb.
 *
 *SparkWeb is free software: you can redistribute it and/or modify
 *it under the terms of the GNU Lesser General Public License as published by
 *the Free Software Foundation, either version 3 of the License, or
 *(at your option) any later version.
 *
 *SparkWeb is distributed in the hope that it will be useful,
 *but WITHOUT ANY WARRANTY; without even the implied warranty of
 *MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *GNU Lesser General Public License for more details.
 *
 *You should have received a copy of the GNU Lesser General Public License
 *along with SparkWeb.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.kebinger.flexlayout
{
    import flash.display.DisplayObjectContainer;
    import flash.display.Graphics;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import mx.containers.Canvas;
    import mx.core.Application;
    import mx.core.FlexShape;
    import mx.core.FlexSprite;

    
    public class ShowBorders
    {
        private var _object:DisplayObjectContainer;
        private var _overlay:Canvas;
        
        public function ShowBorders()
        {
            Application.application.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
            _object = Application.application as Application;
            insertOverlay(Application.application as Application);
        }
        
        protected function insertOverlay(app:Application) :void
        {
            /*
            * this only works for absolute contaiiners- the only way to get flex to 
             * overlap controls is with absolute layout
             */
            _overlay = new Canvas();
            _overlay.x = 0;
            _overlay.y = 0;
            _overlay.width = app.width;
            _overlay.height = app.height;
            if (app.layout == "absolute")
            {
                // add a canvas at the top level to draw the outlines on
                app.addChild(_overlay);
            }
            else
            {
                /*
                * attempt to insert an absolute root container with a Box container
                * move the application's contents to the box, then overlay a canvas
                *
                * this doesn't work currently - some complaint about casting to IUIObject
                var fakeRoot:Canvas = new Canvas();
                fakeRoot.percentWidth=100;
                fakeRoot.percentHeight=100;
                var surrogateApp:Box = new Box();
                surrogateApp.id = "surrogateApp";
                surrogateApp.direction = app.layout;
                for each(var child:DisplayObject in app.getChildren() )
                {    
                    surrogateApp.addChild(child);
                }
                app.validateNow();
                fakeRoot.addChild(_overlay);
                // add fake root as 
                app.addChild(fakeRoot);
                */ 
            
            }
            
            
        }
        
        protected function onMouseMove(e:MouseEvent) :void 
        {
            var objs:Array = _object.getObjectsUnderPoint(new Point(e.stageX,e.stageY));
            var obj:Object = objs[objs.length-1];
            
            if (obj != null && obj.hasOwnProperty("parent")){
                var currObj:Object = obj;
                _overlay.graphics.clear();
                while (currObj != _object)
                {
                    borderIfy(currObj.getRect(_object));
                    currObj = currObj.parent;
                }
            }
        }
        
        protected function borderIfy(rect:Rectangle) :void 
        {
            var s:FlexSprite = _object as FlexSprite;
            if (s)
            {
                var g:Graphics = _overlay.graphics;
                g.lineStyle(2,0xff0000,0.5);
                g.drawRect(rect.x,rect.y,rect.width,rect.height);
            }
        }
    }
}