/**
 * Created by jlopez on 9/22/14.
 */
package com.jla.starling.util
{
    import com.jla.as3.shortcut.Shortcuts;
    import com.jla.as3.util.StringUtils;
    import com.jla.as3.util.UncaughtErrorOverlay;
    import com.jla.as3.util.sprintf;
    import com.jla.starling.shortcut.ShortcutPanel;

    import flash.display.LoaderInfo;
    import flash.geom.Rectangle;

    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.display.Stage;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    public class StarlingDebug
    {
        private static var sHelperRect:Rectangle = new Rectangle();

        public static function install(loaderInfo:LoaderInfo = null):void
        {
            if (!loaderInfo)
                loaderInfo = Starling.current.nativeStage.getChildAt(0).loaderInfo;
            UncaughtErrorOverlay.init(Starling.current.nativeStage, loaderInfo.uncaughtErrorEvents);
            Shortcuts.init(Starling.current.nativeStage);
            Shortcuts.add('^d', dumpCommand);
            Shortcuts.add('^p', pinpointCommand);
            new ShortcutPanel(Starling.current.stage);

            function dumpCommand():void
            {
                DisplayListUtils.dumpTree(Starling.current.stage);
            }

            function pinpointCommand():void
            {
                var stage:Stage = Starling.current.stage;
                stage.removeEventListener(TouchEvent.TOUCH, onTouch);
                stage.addEventListener(TouchEvent.TOUCH, onTouch);

                function onTouch(event:TouchEvent):void
                {
                    var touch:Touch = event.getTouch(stage, TouchPhase.BEGAN);
                    if (!touch) return;
                    stage.removeEventListener(TouchEvent.TOUCH, onTouch);
                    trace(sprintf("Touch (%s, %s)", touch.globalX, touch.globalY));
                    DisplayListUtils.visit(stage, visitor);

                    function visitor(obj:DisplayObject, ix:int, depth:int):void {
                        obj.getBounds(null, sHelperRect);
                        var isTarget:Boolean = event.target == obj;
                        if (!isTarget && !sHelperRect.contains(touch.globalX, touch.globalY)) return;
                        trace(sprintf("%s%2d. (%d) %s %s %s", StringUtils.multiply('  ', depth),
                                        ix + 1, depth + 1, obj.touchable ? "T" : "-",
                                DisplayListUtils.describe(obj), isTarget ? "***TARGET***" : ""));
                    }
                }
            }
        }
    }
}
