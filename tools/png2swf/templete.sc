.flash filename="offset.swf" bbox=512x512 version=9 fps=24
    .action:
        import flash.display.MovieClip;
        package ${package_name}
        {
            public dynamic class MainTimeline extends MovieClip {
                public const offsetInfo:Array = [${offset_info}];
                public const frameInfo:Array = [${frame_info}];
                public const actionInfo:Array = [${action_info}];
            }
        }
    .end
.end