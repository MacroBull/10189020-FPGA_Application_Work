8 VISUALIZATION ADDED IN THIS BRANCH!
-------------------
Check the video here: http://youtu.be/GCL0K5yfsio
![image](https://raw.githubusercontent.com/MacroBull/10189020-FPGA_application_work/feature-visual/wave.jpg)
![image](https://raw.githubusercontent.com/MacroBull/10189020-FPGA_application_work/feature-visual/peak.jpg)
![image](https://raw.githubusercontent.com/MacroBull/10189020-FPGA_application_work/feature-visual/osc.jpg)


10189020-FPGA应用系统设计 设计作业: 
======================================
基于DE2-70的音频处理与可视化系统
======================================
开发板是DE2-70, 主要功能是音频信号处理和可视化, 音频输入是WM8731的Line in,  音频输出为其Line out, 视频输出是VGA.

主要功能包括:
* 线性音量控制
* 自动增益控制
* 欠采样音效(类似电话音)
* 无限冲击响应IIR滤波器(实例/不可在线设计)
* 有限冲击响应FIR滤波器(实例/不可在线设计)
* 简单的不基于FFT的频谱显示
* 基于分形的音频可视化效果

一些其他辅助功能:
* 音效旁路
* LED音量指示
* LCD1602音量与信息显示
* 7段数码管增益显示
* LED时钟信号调试指示

通过下方开关SW可以切换与开关各项功能.

------------------------------
编写语言是Verilog HDL, 部分涉及System Verilog扩展;

部分驱动参考Altera的demo程序

主要程序框架如图:
![image](https://raw.githubusercontent.com/MacroBull/10189020-FPGA_application_work/master/topo.png)

注意
------------------------------
虽然Quartus提供了大量的IP, 但为了锻炼自己, 算法都是自己构想和编写的,

有几个问题尤其需要注意:

1. 定点数运算

  对于有符号定点数的运算还不是非常熟练, 有些地方实现的并不完善, 诸如取负取反问题, 不同定点格式运算的问题.
  
  另外一方面, 在设计滤波器时是通过对浮点结果参数进行四舍五入得到定点参数的, 而后续仿真表明这样得到的结果会对滤波器的参数性能造成很大的影响甚至改变其稳定性, 这一问题是在结题后才注意到的.
  
  Quartus上似乎必须通过使用IP才能使用浮点数, 用浮点大概能解决很多问题.
  
2. 时钟生成

  Cyclone2的这芯片是有4个PLL的, 不过也要用IP生成.
  
  由于音频并没有录音与回放, 所以采样率也不需要按照标准值, 只要大于40kHz就行了, 这里用50MHz分频得到的48828.125Hz, 滤波器就按fN=24414Hz来设计的.
  
  在VGA方面, 由于分形计算量挺大, 而输出图像色彩精度由迭代次数决定, 因此放慢像素时钟才能得到更好的显示效果,
  经测试在Philips 224E上能显示的最低VGA分辨率大约是640x350@26Hz, 用50MHz时钟8分频得到像素时钟, 此时迭代深度能够达到22, 也就是说能够显示二十多种颜色.
  
  用PLL极大增加设计自由度, 当然PLL也是很贵重的资源, 低端CPLD可能不会具备, 数量也极其有限, 实际设计时要仔细考虑.
  
3. 计算方式

  这分形计算量确实略大, 这一屏内容要用近30Hz的速度刷出来, 奔腾系列CPU是赶不上的, 不过设计中这样在一个像素时钟内就进行上百次计算似乎是不妥的, 一般至少也做成同步的计算方式, 比如一次迭代为一级的流水线; 当然采用同步方式在本设计能够得到很理想的效果, 不过这里只是想体验一下芯片的性能罢了.

  整个设计有很多计算其实用提供的IP也能很轻松的解决的, 特别是有了浮点和FFT都会更方便, 这样的设计以后再做好了.
  
灵感
-------------
写音效器, 均衡器之类的东西, 大抵学过控制和信号处理的人都用这样的想法, 至于分形这个东西, 具体的说是按某一帧的音频波形最大值作为分形的参数进行渲染, 想法是室友提出来的; 本来只是想看看这FPGA性能怎么样,能不能做视频处理之类的运算, 写出来之后,室友说如果连上音频的话一定会造成精神污染;

嗯, 果真.

分形使用的是[Julia集, 尝试过修改C值](http://en.wikipedia.org/wiki/Julia_set), 效果不是很好, 后来改成迭代边界t, t小的时候曲线比较平滑, t大的时候比较曲折, 变化时会出现"快门效果"

注意, **请勿长时间观看**

10189020-FPGA Application System Design Work
======================================
DE2-70 Audio Effector and Visualization
======================================
It's on DE2-70, mainly functioning to process effects on audio signal and visualizations of the signal.
Reads signal from Line-in of WM8931 and outputs to Line-out, video visualization is on VGA interface.

Main functions:
* Linear volume control
* Auto gain control
* Undersampling effects(phone-like)
* IIR filters(offline designed instances)
* FIR filters(offline designed instances)
* Simple spectrum without FFT
* Sound-coefficient fractal visualization

Other auxiliary functions:
* Audio bypass
* LED sound indicator
* LCD1602 information display
* 7seg HEX displaying gain of AGC
* LED indicator for clocks

To toggle and switch between functions, use the SW 0~7.

------------------------------
Written in Verilog HDL, with System Verilog;
The code of controller and driver is partly referred from Altera's demo.
Framework diagram:
![image](https://raw.githubusercontent.com/MacroBull/10189020-FPGA_application_work/master/topo.png)

Defects
------------------------------
Main algorithm is written by myself, though Altera provided many IP in Quartus.

There are things needing attention:

1. Fix point calculation

  The fix point calculation written by myself has some defects in negative number conversion and operation with two different point number.
  
  Another essential problem is that the coefficient of filter is calculated by truncating the real number of design results, from the simulation we get to know that it changes filters' performance and changing zeroes and poles may effects on stabilization , such is aware of later the project finished.
  
  Quartus seems have to use IP for floating calculation, using float may solve many problems.
  
2. Clock generating

  This FPGA has 4 PLL, to use PLL, IP has to be used.
  
  Since no recording and playback is needed, sampling clock is not needed to be precise, here I use a sample rate of 48828.125 Hz, divided from 50 MHz main clock, filters is designed with this sample rate.
  
  Fractal calculation cost lots of time, so to lower the pixel clock of VGA for better performance;
  It is tested that my Philips 224E can display VGA graphics in 640x350@26Hz, which pixel clock is 50 MHz/8, meanwhile 22 iterations can be done.
  
  PLL makes clock accurate, however it does not exist in all devices, such design regards PLL unimportant.
  
3. Method of calculation

  The amount of calculation is over the capability of Pentium, it is not proper to do calculation immediately/asynchronously, it is better to operate with pipeline, each iteration works on a level, the result is stable after 30 ticks.

  IP would really help, especially FFT and float number would give a better effects.
  
Inspiration
-------------
Most people may want to realize filters on audio signals after learning control theory or DSP techniques, so this is my realization. My roommate thinks it will be psychedelic if fractal is connected with music, which I used to thought to test the performance of FPGA, and, it works !

The fractal is a kind of [Julia Set](http://en.wikipedia.org/wiki/Julia_set), it is tested for better visual effects to make the boundary t as variable than C. The shape of the graphic become smooth when t is small and rough when large, when t varies, it present an effect of shutter.

Caution, **DO NOT WATCH FRACTAL VISUALIZATION FOR A LONG TIME, IT MAY HARM**


效果/Result
-------------------------------------------------
![image](https://raw.githubusercontent.com/MacroBull/10189020-FPGA_application_work/master/shot0.jpg)
![image](https://raw.githubusercontent.com/MacroBull/10189020-FPGA_application_work/master/shot1.jpg)
