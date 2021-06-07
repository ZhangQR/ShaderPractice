## 介绍

一些 Shader 的练习

## 颜色校正(ColorCorrect)

[step by step](https://www.jianshu.com/p/c92a979f4a9e)
是一种后处理效果，明度校正：  
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/ColorCorrect01.gif" width="600px"/>  
饱和度校正：  
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/ColorCorrect02.gif" width="600px"/>  
对比度校正： 
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/ColorCorrect03.gif" width="600px"/> 

## 边缘检测(EdgeDetection)

带背景的：  
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/EdgeDetection01.jpg" width="600px"/>   
不带背景的：  
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/EdgeDetection02.jpg" width="600px"/>   
渐变的过程：  
<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/EdgeDetection03.gif" 

Prewitt 算子就是把 Sobel 里面的所有 2 都改成 1，效果上区别不是很大。edge 也可以用平方和开根来计算，但这样性能不友好，所有使用绝对值相加也可。  

<img src="https://github.com/ZhangQR/ShaderPractice/raw/master/ReadmeImages/EdgeDetection04.jpg" 


