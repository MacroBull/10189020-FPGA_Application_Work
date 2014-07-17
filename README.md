WOW FPGA Audio Visualization
================
主要是音频信号处理和可视化, 包括:
    
    * 线性音量控制
    
    * 自动增益控制
    
    * 无限冲击响应滤波器IIR(实例/不可设计)
    
    * 有限冲击响应滤波器FIR(实例/不可设计)
    
    * 简单的不基于FFT的频谱显示
    
    * 基于分形的音频可视化效果
  
-------------------------------------------------
不想用IP, 大部分都是自己写的, 定点运算优化起来神烦.

Verilog写出来寄存器用得很多, 需要深入了解.

某人说把波形作为分形图案参数画出来比较酷炫

用的是Julia集, 改c 移动太大计算精度又不够, 所以改了迭代阈值

有"快门效果"

分形用并行方式迭代延时严重, 危险时还会影响音频产生毛刺, 需要深入研究.

** 请不要长时间观看 **

![image](https://raw.githubusercontent.com/MacroBull/10189020-FPGA_application_work/master/shot0.jpg)
![image](https://raw.githubusercontent.com/MacroBull/10189020-FPGA_application_work/master/shot1.jpg)
