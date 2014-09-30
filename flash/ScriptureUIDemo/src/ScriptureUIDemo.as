package {
    import com.demonsters.debugger.MonsterDebugger;
    import com.fl.component.BaseComponent;
    import com.fl.component.BaseSprite;
    import com.fl.component.Box;
    import com.fl.component.Button;
    import com.fl.component.Canvas;
    import com.fl.component.ComboBox;
    import com.fl.component.DragableComp;
    import com.fl.component.Image;
    import com.fl.component.LayoutCanvas;
    import com.fl.component.Menu;
    import com.fl.component.RadioButton;
    import com.fl.component.RadioButtonGroup;
    import com.fl.component.ResizableComp;
    import com.fl.component.ScrollBar;
    import com.fl.component.ScrollBase;
    import com.fl.component.ScrollTile;
    import com.fl.component.Slider;
    import com.fl.component.Text;
    import com.fl.component.TitleWindow;
    import com.fl.component.UIGlobal;
    import com.fl.constants.PositionConstants;
    import com.fl.constants.ScrollPolicyConstants;
    import com.fl.demo.Custom;
    import com.fl.extension.ButtonBar;
    import com.fl.extension.FilterText;
    import com.fl.extension.PageBar;
    import com.fl.extension.PageTile;
    import com.fl.style.StyleManager;
    import com.fl.textflow.TextFlowArea;
    import com.fl.textflow.TextFlowInput;
    import com.fl.utils.FLConfigurator;
    import com.fl.vo.ArrayList;
    import com.senocular.display.Layout;
    
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.ui.Mouse;
    import flash.ui.MouseCursor;
    import flash.utils.getTimer;
    
    import flashx.textLayout.formats.LineBreak;
    
    import org.as3commons.ui.layout.HLayout;
    import org.as3commons.ui.layout.Table;
    import org.as3commons.ui.layout.shortcut.hlayout;
    
    [SWF(width="1000", height="600", frameRate="30")]
    public class ScriptureUIDemo extends Sprite {
        {
            new DemoComponentConfig();
        }
        
        private var cs:Sprite = new Sprite();
        public function ScriptureUIDemo() {
            MonsterDebugger.initialize(this);
            UIGlobal.init(stage);
            
            stage.addEventListener(MouseEvent.CLICK, clickHandler);
            /**
            //normal image
            var img1:Image = new Image();
            img1.autoImgSize = false;
            img1.keepSize = false;
            img1.setSize(200, 200);
            img1.source = StyleManager.getStyleItem("beijing_2", ".common");
            addChild(img1);
            
            //normal text
            var text1:Text = new Text();
            text1.x = 200;
            text1.width = 160;
            text1.height = 90;
            text1.text = "<b>http://s8.app100636252.qqopenapp.com/?seqid=5854c5058da7001918025d1bf71eeaa6&serverid=8&platform=qzone&s=0.6970871203579554&openid=3081DA3C1E78D7DD7C6E0174D3A20766&openkey=9FF7C2BE3389916085095AC66E0ABB35&pf=qzone&pfkey=0a1e2cfe94d41ae2c6bb72c047f8dbaf&app_appbitmap=0&appid=100636252</b>";
            text1.html = true;
            text1.autoContentSize = false;
            text1.editable = true;
            text1.vScrollPosition = PositionConstants.RIGHT;
            text1.setStyle("color", 0xFFFFFF);
            addChild(text1);
            
            //slider
            var slider1:Slider = new Slider();
            slider1.width = 16;
            slider1.height = 200;
            slider1.thumbHeight = 16;
            addChild(slider1);
            
            //scrollbar
            var scroll1:ScrollBar = new ScrollBar();
            scroll1.width = 16;
            scroll1.height = 200;
            scroll1.arrowHeight = 16;
            scroll1.maximum = 80;
            scroll1.direction = PositionConstants.HORIZONTAL;
            addChild(scroll1);
            
            //normal button
            var btn1:Button = new Button();
            btn1.width = 160;
            btn1.height = 29;
            btn1.text.text = "中午aBc";
            btn1.toggle = true;
            //tooltip of button
            btn1.tooltip = "中午aBc";
            btn1.tooltipType = 1;
            //vertical text
            //btn1.text.wordWrap = true;
            //btn1.text.maxWidth = 18;
            addChild(btn1);
            
            //radiobutton and groups, can be used as ButtonBar
            var radioGroup:RadioButtonGroup = new RadioButtonGroup();
            var rb:RadioButton = new RadioButton();
            rb.label = "radio1";
            rb.width = 100;
            rb.height = 26;
            rb.y = 90;
            addChild(rb);
            radioGroup.addItem(rb);
            
            rb = new RadioButton();
            rb.label = "radio2";
            rb.width = 100;
            rb.height = 26;
            rb.y = 120;
            rb.selected = true;
            addChild(rb);
            radioGroup.addItem(rb);
            
            rb = new RadioButton();
            rb.label = "radio3";
            rb.width = 100;
            rb.height = 26;
            rb.y = 150;
            addChild(rb);
            radioGroup.addItem(rb);
            
            //box auto layout
            box1 = new Box();
            box1.y = 90;
            box1.autoContentSize = true;
            box1.width = 200;
            box1.height = 80;
            var tab:Table = new Table();
            tab.numColumns = 3;
            box1.layout = tab;
            addChild(box1);
            
            radioGroup = new RadioButtonGroup();
            var rb:RadioButton = new RadioButton();
            rb.label = "radio1";
            rb.width = 100;
            rb.height = 26;
            radioGroup.addItem(rb);
            box1.addItem(rb);
            
            rb = new RadioButton();
            rb.label = "radio2";
            rb.width = 100;
            rb.height = 26;
            rb.selected = true;
            radioGroup.addItem(rb);
            box1.addItem(rb);
            rbG = rb;
            
            rb = new RadioButton();
            rb.label = "radio3";
            rb.width = 100;
            rb.height = 26;
            radioGroup.addItem(rb);
            box1.addItem(rb);
            
            var st1:ScrollTile = new ScrollTile();
            st1.direction = PositionConstants.VERTICAL;
            st1.height = 0;
            st1.width = 0;
            st1.row = 2;
            st1.column = 2;
            //st1.autoContentSize = true;
            var std1:ArrayList = new ArrayList();
            for(var i:int = 0; i < 10; i++) {
                std1.push("std" + i);
            }
            st1.dataProvider = std1;
            addChild(st1);
            
            var cb1:ComboBox = new ComboBox();
            cb1.height = 24;
            cb1.width = 80;
            var std1:ArrayList = new ArrayList();
            for(var i:int = 0; i < 10; i++) {
                std1.push("std" + i);
            }
            cb1.list.dataProvider = std1;
            UIGlobal.compLayer.addChild(cb1);
            
            //layout demo
            var ly:Layout;
            var lc1:LayoutCanvas = new LayoutCanvas();
            //lc1.autoContentSize = true;
            lc1.width = 100;
            lc1.height = 100;
            var btn1:Button = new Button();
            
            btn1.autoSkinSize = true;
            btn1.label = "1";
            lc1.addItem(new Layout(btn1));
            btn1 = new Button();
            btn1.autoSkinSize = true;
            btn1.label = "2";
            lc1.addItem(new Layout(btn1));
            btn1 = new Button();
            btn1.width = 80;
            btn1.height = 26;
            btn1.label = "3";
            ly = new Layout(btn1);
            ly.horizontalCenter = 0;
            ly.verticalCenter = 0;
            lc1.addItem(ly);
            UIGlobal.compLayer.addChild(lc1);
            
            var dc:DragableComp = new DragableComp();
            dc.setSize(100, 30);
            addChild(dc);
            
            var rc:ResizableComp = new ResizableComp();
            rc.move(100, 40);
            rc.setSize(100, 30);
            addChild(rc);
            
            //title window
            var tw:TitleWindow = new TitleWindow();
            tw.width = 200;
            tw.height = 300;
            tw.title = "title window";
            tw.show();
            
            //canvas
            var c1:Canvas = new Canvas();
            c1.autoContentSize = true;
            var rc:ResizableComp = new ResizableComp();
            rc.move(100, 40);
            rc.setSize(100, 30);
            c1.addChild(rc);
            addChild(c1);
            
            //PageTile
            var pt:PageTile = new PageTile();
            pt.autoContentSize = true;
            var std1:ArrayList = new ArrayList();
            for(var i:int = 0; i < 10; i++) {
                std1.push("std" + i);
            }
            pt.dataProvider = std1;
            addChild(pt);
            
            var st1:ScrollTile = new ScrollTile();
            st1.direction = PositionConstants.VERTICAL;
            st1.height = 0;
            st1.width = 0;
            st1.row = 10;
            st1.autoContentSize = true;
            //st1.autoContentSize = true;
            var std1:ArrayList = new ArrayList();
            for(var i:int = 0; i < 100; i++) {
                std1.push("std" + i);
            }
            st1.dataProvider = std1;
            addChild(st1);
            
            //性能测试
            var t:Number = getTimer();
            var w:Number = 60;
            var h:Number = 24;
            var btn:Button;
            for(var i:int = 0; i < 10; i++) {
                for(var j:int = 0; j < 10; j++) {
                    btn = new Button();
                    btn.label = i + "_" + j;
                    btn.width = w;
                    btn.height = h;
                    btn.x = i * (w + 2);
                    btn.y = j * (h + 2);
                    addChild(btn);
                }
            }
            trace(getTimer() - t);
            
            //TextFlowArea
            var tfa:TextFlowArea = new TextFlowArea();
            tfa.width = 200;
            tfa.height = 100;
            tfa.flowText = "<?xml version='1.0' encoding='utf-8'?><TextFlow whiteSpaceCollapse='preserve' version='3.0.0' xmlns='http://ns.adobe.com/textLayout/2008'><p><span>//性能测试</span></p><p><span>            var t:Number = getTimer();</span></p><p><span>            var w:Number = 60;</span></p><p><span>            var h:Number = 24;</span></p><p><span>            var btn:Button;</span></p><p><span>            for(var i:int = 0; i &lt; 10; i++) {</span></p><p><span>                for(var j:int = 0; j &lt; 10; j++) {</span></p><p><span>                    btn = new Button();</span></p><p><span>                    btn.label = i + '_' + j;</span></p><p><span>                    btn.width = w;</span></p><p><span>                    btn.height = h;</span></p><p><span>                    btn.x = i * (w + 2);</span></p><p><span>                    btn.y = j * (h + 2);</span></p><p><span>                    addChild(btn);</span></p><p><span>                }</span></p><p><span>            }</span></p><p><span>            trace(getTimer() - t);</span></p><p><span></span></p><p><span color='#00cc33'>//-------------------------------------------------</span></p></TextFlow>";
            addChild(tfa);
            
            //TextFlowInput
            var tfi:TextFlowInput = new TextFlowInput();
            tfi.width = 200;
            tfi.height = 60;
            //line autowrapper
            tfi.lineBreak = LineBreak.TO_FIT;
            addChild(tfi);
            
            //buttonbar
            //Button.EVENT_SELECT_CHANGED on ButtonBar.buttonGroup
            //style or properties on ButtonBar.itemRenderer.properties
            var btb:ButtonBar = new ButtonBar();
            var std1:ArrayList = new ArrayList();
            for(var i:int = 0; i < 10; i++) {
                std1.push("std" + i);
            }
            btb.dataProvider = std1;
            addChild(btb);
            
            //Menu
            var menu:Menu = new Menu();
            var std1:ArrayList = new ArrayList();
            for(var i:int = 0; i < 10; i++) {
                std1.push("std" + i);
            }
            menu.dataProvider = std1;
            gi = menu;
            
            //UI configuration
            FLConfigurator.register(Text);
            FLConfigurator.register(Button);
            Box;
            Custom;
            var cc:XML = <comps>
                            <Text id="myLabel" x="10" y="10" autoContentSize="true" text="waiting..."/>
                            <Button x="10" y="40" label="click me" event="click:onClick"/>
                            <com.fl.component.Box x="10" y="70" addFunc="addItem">
                                <Text autoContentSize="true" text="waiting..."/>
                                <Button label="click me" event="click:onClick"/>
                            </com.fl.component.Box>
                            <com.fl.demo.Custom x="10" y="130" parseFunc="parseComp" label="click me" event="click:onClick">
                                some custom data, can be anything
                            </com.fl.demo.Custom>
                        </comps>;
            FLConfigurator.parseXML(cc, this, addChild);
            **/
        }
        public function onClick(env:MouseEvent):void {
            trace(env.target);
        }
        private var gi:*;
        private var sp:Sprite;
        private var radioGroup:RadioButtonGroup;
        private var rbG:RadioButton;
        private var box1:Box;
        private var rbN:int = 0;
        private function clickHandler(env:MouseEvent):void {
            if(gi is Menu) gi.show(new Point(env.stageX, env.stageY));
            
            if(rbN >= 9) return;
            rbN++
            /**
            var rb:RadioButton = new RadioButton();
            rb.label = "radio_" + (rbN++);
            rb.width = 100;
            rb.height = 26;
            radioGroup.addItem(rb);
            box1.addItemAt(rb, 3);
            
            rbG.width = rbN % 2 == 0 ? 160 : 100;
            rbG = rb;
            box1.removeItemAt(0);
            */
        }
    }
}
