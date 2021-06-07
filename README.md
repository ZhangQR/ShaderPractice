## 介绍

一些 Shader 的练习，有个哥们把 Unity3D build-in Shader 放到了自己的 Github 里面，并且按照版本打了 Tag，目前只到 2019，不知道断更是因为官方没有更新还是其他原因，不过用来查询内置的函数是真滴方便~ [连接](https://github.com/ZhangQR/Unity-Built-in-Shaders)

## 颜色校正(ColorCorrect)

[step by step](https://www.jianshu.com/p/c92a979f4a9e)  
是一种后处理效果，明度校正：  
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/ColorCorrect01.gif" width="600px"/>  
饱和度校正：  
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/ColorCorrect02.gif" width="600px"/>    
对比度校正：   
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/ColorCorrect03.gif" width="600px"/> 

## 边缘检测(EdgeDetection)
也是通过后处理，先看美女原图（我承认有一部分私心在里面）：  
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/EdgeDetection05.jpg" width="600px"/>   
带背景的：  
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/EdgeDetection01.jpg" width="600px"/>   
不带背景的：  
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/EdgeDetection02.jpg" width="600px"/>   

Prewitt 算子就是把 Sobel 里面的所有 2 都改成 1，效果上区别不是很大。edge 也可以用平方和开根来计算，但这样性能不友好，所以使用绝对值相加也可。  

<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/EdgeDetection04.jpg" width="600px"/>   

## 获取深度和法线纹理

还是后处理，先简单搭一个场景：  
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/GetDepthAndNormal01.jpg" width="600px"/>   
使用 Frame Debugger 来查看深度和法线，不过首先你需要把相机的 `depthTextureMode` 给设置好，如果深度图示全黑或者全白，那么有两种方法：1、Frame Debugger 的 Levels 右边往左调整。2、将相机的 Near Plane 和 Far Plane 调整到正好包住场景。  
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/GetDepthAndNormal02.jpg" width="600px"/>   
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/GetDepthAndNormal03.jpg" width="600px"/>   
也可以使用代码来查看：  
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/GetDepthAndNormal04.jpg" width="600px"/>   
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/GetDepthAndNormal05.jpg" width="600px"/>   