# Macro-for-Win_Random2-in-SAS
  `本宏程序主要基于SAS软件，进行分层区组随机化结果。`
# 必填参数目录Content
- [winname](#winname)
- [outdata1](#outdata1)  
# 可选参数目录Content
- [outdata2](#outdata2)  
# 宏程序使用语法
```sas  
%Win_Random2(winname = test1, outdata1 = test2);  
%Win_Random2(winname = test1, outdata1 = test2,outdata2 = randform);  
```  
  宏程序内置了参数注释窗口，调用如下：  
  ```sas  
  %Win_Random2;  
  %Win_Random2();  
  %Win_Random2(help);  
  ```
# 参数使用语法
## indata
  弹出的窗口名称  
  可任取英文名称，仅为调用赋值。  
  
## outdata1
  输出随机数表的数据集名称。
  
## outdata2
  保留输入的窗口信息数据集名称。  
