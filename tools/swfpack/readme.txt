1. 将swfpack.py, start.bat, templete_animation.xml复制到打包目录，打包目录不能有中文
2. 修改swfpack中对应的相关路径
3. 根据需求修改swfpack中的：
出图fps，默认为0（图片数量）
输出swf的fps，默认60
swf宽、高，默认0（图片最大宽、高）
是否设置swf左上为中心点
4. 运行start.bat，输出为"目录名.swf"，有问题查看“目录名.log”