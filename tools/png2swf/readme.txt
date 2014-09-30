1. 安装python
2. 安装swftools(http://www.swftools.org/), ImageMagick-6.7.5-Q16(http://www.imagemagick.org)
3. 安装swfmill，解压到某个目录
4. 修改start.bat中set path=%path%;E:\programFiles\Python27这行的python安装目录
5. 修改png2swf.py中的工具路径，如img_mogrify_exe, img_identify_exe, swfmill_exe，swfc_exe, swfcombine_exe
6. 将png2swf.py, start.bat, templete_offset.sc, templete_animation.xml拷贝到需要打包的目录
7. 运行start.bat

结果：
1. 会将所有png图片剪裁至有像素的大小并替换原来的图片，请注意备份原来的图片
2. 保存所有剪裁后图片相对原来图片的偏移,帧数和动作至"offset.txt"
3. 将当前目录中所有的png图片导成"animation.swf"
4. 将offset.txt和animation.swf合并到"当前目录名.swf"中
5. 运行日志在"当前目录名.log"中
6. 可以访问"当前目录名.swf"中的offsetInfo,frameInfo和actionInfo获取偏移和帧数信息