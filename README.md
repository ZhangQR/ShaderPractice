## 介绍

一些 Shader 的练习，有个哥们把 Unity3D build-in Shader 放到了自己的 Github 里面，并且按照版本打了 Tag，目前只到 2019，不知道断更是因为官方没有更新还是其他原因，不过用来查询内置的函数是真滴方便~ [链接](https://github.com/ZhangQR/Unity-Built-in-Shaders)。项目下载之后，可以将显示改成 16:9，不然 free aspect 有可能会看到显示之外的东西。

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
记录一下这个函数，DecodeFloatRG 用来在 tex2D 之后获取 depth；DecodeViewNormalStereo 用来在 tex2D 后获取 normal。  
```
inline void DecodeDepthNormal( float4 enc, out float depth, out float3 normal )
{
    depth = DecodeFloatRG (enc.zw);
    normal = DecodeViewNormalStereo (enc);
}
```

## 再谈边缘检测

用之前的方法进行边缘检测其实只是在图像上做处理，会出现一些问题，比如说阴影，法线贴图都会被检测到，如图所示：  
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/EdgeDetectionPro01.jpg" width="600px"/>   
所以这次我们使用 Roberts 算子和深度法线纹理来进行边缘检测，依旧是一种后处理技术。我做了一点改动，比如说将乘法改成了加法，效果会更明显一点。因为左上角到右下角算出有一条边界，但右上角到左下角边界不明显，如果乘的话，结果就是边界不明显，但实际上只要有一个方向有很明显的边界应该就算做有边界才对，乘法的效果如下（除了这张其他都是加法的效果）：  
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/EdgeDetectionPro03.jpg" width="600px"/>   
可以选择 **只** 用深度纹理来检测，但是内部的（包括两个紧连着的物体，比如说墙缝）边界是检测不出来的，因为对于内部边界上的某个像素来说，它的相邻的像素的深度值跟它差距都不大。  
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/EdgeDetectionPro02.jpg" width="600px"/>   
还有某些倾斜角度会过多的检测边界：  
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/EdgeDetectionPro04.jpg" width="600px"/>   
而 **只** 使用法线贴图则不会出现这种情况：  
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/EdgeDetectionPro05.jpg" width="600px"/>   
你可以像我一样把两种情况结合起来使用，也就是取了并集，也可以自行尝试，最后的效果图：  
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/EdgeDetectionPro06.jpg" width="600px"/>   

## 卡通渲染

<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/CartoonRender01.gif" width="600px"/>   
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/CartoonRender02.gif" width="600px"/>   