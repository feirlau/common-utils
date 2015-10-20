.flash filename="offset.swf" bbox=512x512 version=9 fps=12
    .action:
        import flash.display.MovieClip;
        import flash.geom.Point;
        package ${package_name}
        {
            public dynamic class MainTimeline extends MovieClip {
				public const maxInfo:Point = new Point(512, 512);
                public const offsetInfo:Array = [${offset_info}];
                public const frameInfo:Array = [${frame_info}];
                public const actionInfo:Array = [${action_info}];
                public const boxInfo:Point = new Point(${box_info});
            }
        }
    .end
.end