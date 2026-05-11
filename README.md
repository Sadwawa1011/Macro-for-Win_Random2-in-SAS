# Macro-for-Win_Random2-in-SAS
  `本宏程序主要基于SAS软件（GBK环境），进行分层区组随机化结果。`
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

# 调用的SAS窗口
  `根据以上宏程序使用语法即可调出下图SAS窗口。`
<img width="1055" height="897" alt="调用窗口图片" src="https://github.com/user-attachments/assets/69cd9904-4430-4691-853a-f2b00d23c7f3" />

# 参数使用语法
## winname
  弹出的窗口名称  
  可任取英文名称，仅为调用赋值。  
  
## outdata1
  输出随机数表的数据集名称。
  
## outdata2
  保留输入的窗口信息数据集名称。
