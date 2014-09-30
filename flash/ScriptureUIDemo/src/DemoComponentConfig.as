/**
 * @author risker
 * Oct 19, 2013
 **/
package {
    import com.fl.component.BaseComponent;
    import com.fl.component.Button;
    import com.fl.component.CheckBox;
    import com.fl.component.ComboBox;
    import com.fl.component.DragableComp;
    import com.fl.component.IComponentConfig;
    import com.fl.component.RadioButton;
    import com.fl.component.ResizableComp;
    import com.fl.component.ScrollBar;
    import com.fl.component.ScrollBase;
    import com.fl.component.ScrollTile;
    import com.fl.component.Slider;
    import com.fl.component.StatefulComponent;
    import com.fl.component.Text;
    import com.fl.component.TileItemRenderer;
    import com.fl.component.TitleWindow;
    import com.fl.skin.ImageBorderSkin;
    import com.fl.skin.SkinManager;
    import com.fl.skin.StatefulBorderSkin;
    import com.fl.style.StyleManager;
    import com.fl.textflow.TextFlowArea;
    import com.fl.textflow.TextFlowInput;
    import com.fl.tooltip.HtmlTooltip;
    import com.fl.utils.FLUtil;
    
    import flash.display.Sprite;

    public class DemoComponentConfig extends Sprite implements IComponentConfig {
        //button
        [Embed(source='button_putong_b_1.png', scaleGridLeft=6, scaleGridRight=31, scaleGridTop=6, scaleGridBottom=16, compression="true")]
        private static var button_putong_b_1:Class;
        [Embed(source='button_putong_b_2.png', scaleGridLeft=6, scaleGridRight=31, scaleGridTop=6, scaleGridBottom=16, compression="true")]
        private static var button_putong_b_2:Class;
        [Embed(source='button_putong_b_3.png', scaleGridLeft=6, scaleGridRight=31, scaleGridTop=6, scaleGridBottom=16, compression="true")]
        private static var button_putong_b_3:Class;
        [Embed(source='button_putong_b_4.png', scaleGridLeft=6, scaleGridRight=31, scaleGridTop=6, scaleGridBottom=16, compression="true")]
        private static var button_putong_b_4:Class;
        
        //checkbox
        [Embed(source='button_duoxuan_a_1.png', compression="true")]
        private static var button_duoxuan_a_1:Class;
        [Embed(source='button_duoxuan_a_2.png', compression="true")]
        private static var button_duoxuan_a_2:Class;
        [Embed(source='button_duoxuan_a_3.png', compression="true")]
        private static var button_duoxuan_a_3:Class;
        [Embed(source='button_duoxuan_a_4.png', compression="true")]
        private static var button_duoxuan_a_4:Class;
        
        [Embed(source='button_duoxuan_b_1.png', compression="true")]
        private static var button_duoxuan_b_1:Class;
        [Embed(source='button_duoxuan_b_2.png', compression="true")]
        private static var button_duoxuan_b_2:Class;
        [Embed(source='button_duoxuan_b_3.png', compression="true")]
        private static var button_duoxuan_b_3:Class;
        [Embed(source='button_duoxuan_b_4.png', compression="true")]
        private static var button_duoxuan_b_4:Class;
        
        //radiobox
        [Embed(source='button_danxuan_a_1.png', compression="true")]
        private static var button_danxuan_a_1:Class;
        [Embed(source='button_danxuan_a_2.png', compression="true")]
        private static var button_danxuan_a_2:Class;
        [Embed(source='button_danxuan_a_3.png', compression="true")]
        private static var button_danxuan_a_3:Class;
        [Embed(source='button_danxuan_a_4.png', compression="true")]
        private static var button_danxuan_a_4:Class;
        
        [Embed(source='button_danxuan_b_1.png', compression="true")]
        private static var button_danxuan_b_1:Class;
        [Embed(source='button_danxuan_b_2.png', compression="true")]
        private static var button_danxuan_b_2:Class;
        [Embed(source='button_danxuan_b_3.png', compression="true")]
        private static var button_danxuan_b_3:Class;
        [Embed(source='button_danxuan_b_4.png', compression="true")]
        private static var button_danxuan_b_4:Class;
        
        //scrollbar
        [Embed(source='scroll_bk_a_1.png')]
        private static var scroll_bk_a_1:Class;
        
        [Embed(source='scroll_thu_a_1.png', scaleGridLeft=2, scaleGridRight=7, scaleGridTop=4, scaleGridBottom=18, compression="true")]
        private static var scroll_thu_a_1:Class;
        [Embed(source='scroll_thu_a_2.png', scaleGridLeft=2, scaleGridRight=7, scaleGridTop=4, scaleGridBottom=18, compression="true")]
        private static var scroll_thu_a_2:Class;
        [Embed(source='scroll_thu_a_3.png', scaleGridLeft=2, scaleGridRight=7, scaleGridTop=4, scaleGridBottom=18, compression="true")]
        private static var scroll_thu_a_3:Class;
        
        [Embed(source='scroll_thu_a_4.png', compression="true")]
        private static var scroll_thu_a_4:Class;
        
        [Embed(source='scroll_up_a_1.png', compression="true")]
        private static var scroll_up_a_1:Class;
        [Embed(source='scroll_up_a_2.png', compression="true")]
        private static var scroll_up_a_2:Class;
        [Embed(source='scroll_up_a_3.png', compression="true")]
        private static var scroll_up_a_3:Class;
        
        [Embed(source='scroll_down_a_1.png', compression="true")]
        private static var scroll_down_a_1:Class;
        [Embed(source='scroll_down_a_2.png', compression="true")]
        private static var scroll_down_a_2:Class;
        [Embed(source='scroll_down_a_3.png', compression="true")]
        private static var scroll_down_a_3:Class;
        
        //ComboBox
        [Embed(source="combo_a_1.png", scaleGridLeft=4, scaleGridRight=30, scaleGridTop=4, scaleGridBottom=15, compression="true")]
        private static var combo_a_1:Class;
        [Embed(source="combo_a_2.png", scaleGridLeft=4, scaleGridRight=30, scaleGridTop=4, scaleGridBottom=15, compression="true")]
        private static var combo_a_2:Class;
        [Embed(source="combo_a_3.png", scaleGridLeft=4, scaleGridRight=30, scaleGridTop=4, scaleGridBottom=15, compression="true")]
        private static var combo_a_3:Class;
        [Embed(source="combo_a_4.png", scaleGridLeft=4, scaleGridRight=30, scaleGridTop=4, scaleGridBottom=15, compression="true")]
        private static var combo_a_4:Class;
        
        //TileItemRenderer
        [Embed(source='bk_gaoliang_a_1.png', scaleGridLeft=8, scaleGridRight=177, scaleGridTop=8, scaleGridBottom=20, compression="true")]
        private static var bk_gaoliang_a_1:Class;
        [Embed(source='bk_gaoliang_b_1.png', compression="true")]
        private static var bk_gaoliang_b_1:Class;
        
        //Text
        [Embed(source='bk_b_4.png', scaleGridLeft=8, scaleGridRight=286, scaleGridTop=8, scaleGridBottom=40, compression="true")]
        private static var bk_b_4:Class;
        
        //TitleWindow
        [Embed(source='bk_a_2.png', scaleGridLeft=120, scaleGridRight=136, scaleGridTop=50, scaleGridBottom=140, compression="true")]
        private static var bk_a_2:Class;
        [Embed(source='resize_1.png', compression="true")]
        private static var resize_1:Class;
        
        [Embed(source='button_close_a_1.png', compression="true")]
        private static var button_close_a_1:Class;
        [Embed(source='button_close_a_2.png', compression="true")]
        private static var button_close_a_2:Class;
        [Embed(source='button_close_a_3.png', compression="true")]
        private static var button_close_a_3:Class;
        [Embed(source='button_close_a_4.png', compression="true")]
        private static var button_close_a_4:Class;
        
        public function DemoComponentConfig() {
            load();
        }
        
        private static var loaded:Boolean = false;
        public function load():void {
            if(loaded) return;
            loaded = true;
            
            var name:String;
            var skin:*;
            var style:Object;
            
            name = FLUtil.getClassName(BaseComponent);
            skin = ImageBorderSkin;
            SkinManager.registerSkin(name, skin);
            
            name = FLUtil.getClassName(StatefulComponent);
            skin = StatefulBorderSkin;
            SkinManager.registerSkin(name, skin);
            
            name = FLUtil.getClassName(Slider);
            style = {
                thumbStyle: {upSkin: scroll_thu_a_1, overSkin: scroll_thu_a_2, downSkin: scroll_thu_a_3},
                trackStyle: {upSkin: scroll_bk_a_1}
            };
            StyleManager.registerStyle(name, style);
            
            name = FLUtil.getClassName(ScrollBar);
            style = {
                sliderStyle: style,
                thumbIcon: scroll_thu_a_4,
                topArrowStyle: {upSkin: scroll_up_a_1, overSkin: scroll_up_a_2, downSkin: scroll_up_a_3},
                bottomArrowStyle: {upSkin: scroll_down_a_1, overSkin: scroll_down_a_2, downSkin: scroll_down_a_3}
            };
            StyleManager.registerStyle(name, style);
            
            name = FLUtil.getClassName(ScrollBase);
            style = {
                hStyle: style,
                vStyle: style,
                
                paddingLeft: 4,
                paddingRight: 4,
                paddingTop: 4,
                paddingBottom: 4,
                
                barPaddingLeft: 2,
                barPaddingRight: 2,
                barPaddingTop: 2,
                barPaddingBottom: 2
            };
            StyleManager.registerStyle(name, style);
            
            name = FLUtil.getClassName(Text);
            skin = StatefulBorderSkin;
            SkinManager.registerSkin(name, skin);
            style.focusSkin = bk_gaoliang_a_1;
            style.borderSkin = bk_b_4;
            StyleManager.registerStyle(name, style);
            
            name = FLUtil.getClassName(TextFlowArea);
            StyleManager.registerStyle(name, style);
            
            name = FLUtil.getClassName(TextFlowInput);
            skin = StatefulBorderSkin;
            SkinManager.registerSkin(name, skin);
            StyleManager.registerStyle(name, style);
            
            name = FLUtil.getClassName(HtmlTooltip);
            style.properties = {maxWidth: 300};
            StyleManager.registerStyle(name, style);
            
            name = FLUtil.getClassName(ScrollTile);
            style.properties = {itemWidth: 72, itemHeight: 22}
            StyleManager.registerStyle(name, style);
            
            name = FLUtil.getClassName(ResizableComp);
            StyleManager.registerStyle(name, style);
            
            name = FLUtil.getClassName(Button);
            style = {
                properties: {width: 60, height: 22},
                
                normalStyle: {upSkin: button_putong_b_1, overSkin: button_putong_b_2, downSkin: button_putong_b_3, disabledSkin: button_putong_b_4},
                selectedStyle: {upSkin: button_putong_b_3, overSkin: button_putong_b_3, downSkin: button_putong_b_1, disabledSkin: button_putong_b_4},
                
                normalTextStyle: {borderSkin: null, color: 0xFFC882, upColor: 0xFFC882, overColor: 0xFFFFFF, downColor: 0xCAA074, disabledColor: 0x808080, paddingTop: 0, paddingBottom: 0},
                selectedTextStyle: {borderSkin: null, color: 0xCAA074, upColor: 0xCAA074, overColor: 0xCAA074, downColor: 0xFFC882,  disabledColor: 0x808080, paddingTop: 0, paddingBottom: 0}
            };
            StyleManager.registerStyle(name, style);
            
            name = FLUtil.getClassName(RadioButton);
            style = {
                normalStyle: {upSkin: null, overSkin: null, downSkin: null, disabledSkin: null},
                selectedStyle: {upSkin: null, overSkin: null, downSkin: null, disabledSkin: null},
                
                normalIconStyle: {upSkin: button_danxuan_a_1, overSkin: button_danxuan_a_2, downSkin: button_danxuan_a_3, disabledSkin: button_danxuan_a_4},
                selectedIconStyle: {upSkin: button_danxuan_b_1, overSkin: button_danxuan_b_2, downSkin: button_danxuan_b_3, disabledSkin: button_danxuan_b_4}
            };
            StyleManager.registerStyle(name, style);
            
            name = FLUtil.getClassName(CheckBox);
            style = {
                normalStyle: {upSkin: null, overSkin: null, downSkin: null, disabledSkin: null},
                selectedStyle: {upSkin: null, overSkin: null, downSkin: null, disabledSkin: null},
                
                normalIconStyle: {upSkin: button_duoxuan_a_1, overSkin: button_duoxuan_a_2, downSkin: button_duoxuan_a_3, disabledSkin: button_duoxuan_a_4},
                selectedIconStyle: {upSkin: button_duoxuan_b_1, overSkin: button_duoxuan_b_2, downSkin: button_duoxuan_b_3, disabledSkin: button_duoxuan_b_4}
            };
            StyleManager.registerStyle(name, style);
            
            name = FLUtil.getClassName(ComboBox);
            style = {
                properties: {width: 80, height: 24},
                
                normalStyle: {upSkin: combo_a_1, overSkin: combo_a_2, downSkin: combo_a_3, disabledSkin: combo_a_4},
                normalTextStyle: {borderSkin: null, color: 0xFFFFFF, upColor: 0xFFFFFF, overColor: 0xFFFFFF, downColor: 0xFFFFFF, disabledColor: 0x808080, paddingTop: 0, paddingBottom: 0, paddingRight: 10}
            };
            StyleManager.registerStyle(name, style);
            
            name = FLUtil.getClassName(TileItemRenderer);
            style = {
                normalStyle: {upSkin: null, overSkin: bk_gaoliang_b_1, downSkin: bk_gaoliang_b_1, disabledSkin: null},
                selectedStyle: {upSkin: bk_gaoliang_a_1, overSkin: bk_gaoliang_a_1, downSkin: bk_gaoliang_a_1, disabledSkin: null},
                
                normalTextStyle: {borderSkin: null, color: 0xFFFFFF, upColor: 0xFFFFFF, overColor: 0xFFFFFF, downColor: 0xCAA074, disabledColor: 0x808080, paddingTop: 0, paddingBottom: 0},
                selectedTextStyle: {borderSkin: null, color: 0xFFFFFF, upColor: 0xFFFFFF, overColor: 0xFFFFFF, downColor: 0xCAA074, disabledColor: 0x808080, paddingTop: 0, paddingBottom: 0}
            };
            StyleManager.registerStyle(name, style);
            
            name = FLUtil.getClassName(TitleWindow);
            style = {
                borderSkin: bk_a_2, headerHeight: 36,
                dragBarStyle: {paddingTop: 3, paddingBottom: -3, paddingLeft: 10, paddingRight: 10},
                titleStyle: {normalStyle: {upSkin: null}, normalTextStyle: {borderSkin: null, color: 0xFABE50, upColor: 0xFABE50, size: 20, bold: true, letterSpacing: 1}},
                closeStyle: {normalStyle: {upSkin: button_close_a_1, overSkin: button_close_a_2, downSkin: button_close_a_3, disabledSkin: button_close_a_4}},
                resizeBarStyle: {borderSkin: resize_1, paddingRight: 12, paddingBottom: 12}
            };
            StyleManager.registerStyle(name, style);
        }
        
        public function unload():void {
            if(!loaded) return;
            loaded = false;
        }
    }
}
