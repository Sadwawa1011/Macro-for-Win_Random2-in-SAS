
/*----------------------------------------------------------------------------
    Author:               liu sheng
  Creation Date:         2021-09-24     
-----------------------------------------------------------------------------*/

/*===========================================================================*
Program Name        :  *WinRand.sas*
Path                :  *程序保存的路径*
Program Language    :  SAS V9.4
______________________________________________________________________________

Purpose             : *创建宏程序，生成随机数表*

Macro Calls         : *%Win_Random2*


Input               : 无
Output              : 无

Program Flow        : *编程步骤*

     *1.  创建宏程序 %win_random2 *

______________________________________________________________________________

Version History     : *版本信息*

Version     Date           Programmer       Description
-------     ----------     ----------       -----------
 1.0        2021-09-24      liu sheng            创建随机宏程序
 2.0        2021-10-13      liu sheng            优化程序
 3.0        2021-12-20      liu sheng            新增-随机总数逻辑判断，每区组长度的逻辑判断 
 4.0        2022-11-07      liu sheng            新增中心/受试者起始编号
 5.0        2024-07-17      liu sheng            新增临时窗口记忆
 6.0        2024-08-06      liu sheng            新增中心编号和流水号的格式（01-001的指定格式）,新增必填项高亮
 7.0        2024-08-23      liu sheng            优化必填项缺失弹出窗口，新增强制关闭窗口参数
==========================================================================*/



%macro win_random2(winname,outdata1,outdata2=randform);
                    /* winname:窗口名称，outdata1:随机数表，outdata2:保留输入的窗口信息数据集 */
%window &winname color=white
                #5 @8 '===================================================================================================================================================='
                #7 @16 '多中心临床试验分层区组随机化设计'
                #9 @16 "V1.0, on &sysday, &sysdate ; Author: liu sheng"
                #11 @16 '随机统计师:'
                #11 @30 NAME  40 ATTR=underline 
                #13 @8 '==================================================================================================================================================='

                #15 @8 "窗口信息是否临时保留本次设定的参数记忆（是-任意值，否-不填此空；默认为否）（注：保留此窗口会一直存在，便于调整参数）："
                #15 @130  memory 20 attr=underline

                #17 @8 '临床试验项目名称:'
                #17 @50 xmname  200 ATTR=underline 
                #19 @8 '拟随机总数:(必填):' color=blue
                #19 @50 n 50 ATTR=underline color=blue
                #21 @8 '初始种子数（必填）:' color=blue
                #21 @50 firseed 50 attr=underline color=blue
                #23 @8 '中心数（必填）:' color=blue
                #23 @50 centern 50 attr=underline color=blue
                #25 @8 "各中心名称（按顺序中英逗顿号区分，必填）:" color=blue
                #25 @50 cename 200 attr=underline color=blue
                #27 @8 '每中心区组数（必填）:' color=blue
                #27 @50 block 50 attr=underline color=blue
                #29 @8 '每区组长度（必填）:' color=blue
                #29 @50 blength 50 attr=underline color=blue
                #31 @8 '组别数（必填）:'  color=blue 
                #31 @50 groupn 50 attr=underline color=blue
                #33 @8 '组别代码(如 试验组：A、对照组：B，必填):' color=blue
                #33 @50 groupa 200 attr=underline color=blue
                #35 @8 '分配比例(英文冒号分割，如1:1，必填):' color=blue
                #35 @50 ratio 50 attr=underline color=blue
                #37 @8 '受试者统一代码（默认无）:'
                #37 @50 subja 50 attr=underline
                #39 @8 '中心起始编号（数值：默认为1,可不填）:'
                #39 @50 beginc 50 attr=underline
                #41 @8 '受试者起始编号（数值：默认为1,可不填）:'
                #41 @50 begins 50 attr=underline
                #43 @8 '中心编号格式（可不填，默认为Z2.，即两位数，不足往前补0）:'
                #43 @70 cenfmt 50 attr=underline
                #45 @8 '受试者编号格式（可不填，默认为Z3.，即三位数，不足往前补0）:'
                #45 @70 subfmt 50 attr=underline


                #50 @8 '=================================================================================================================================================='
                #52 @8 "注：1.按 enter 继续，参数填完后会进行出表" color=red
                #54 @8 "    2.拟随机总数必须等于中心数*每中心区组数*每区组长度，否则报错;每区组长度必须为分配比例和的整倍数，否则报错." color=red
                #56 @8 "    3.窗口信息是否需填写完整(优先度>4)（是-任意值，否-不填；默认否）:"  color=red 
                #56 @80  close  50 attr=underline color=red
                #58 @8 "    4.是否强制关闭窗口（是-填任意值，否-不填此空；默认为否）:"   color=red
                #58 @80  force_close  50 attr=underline color=red
;

%display &winname;


/* --------------------随机序列------------------ */
%MACRO RAND_TEM();

/* 默认编号格式 */
%if &cenfmt=%str() %then %do;
    %let cenfmt = Z2. ;
%end;
%if &subfmt=%str() %then %do;
    %let subfmt = Z3. ;
%end;

%put &=cenfmt &=subfmt ;

proc plan seed=&firseed;
    factors center=&centern ordered block=&block ordered length=&blength;
    output out=a;
quit;

data b(label='随机数表');
    length centname $200.;
        set a;
        group=length/&blength;
        number=_n_;
        sumk=0;
        sumj1=0;
        sumj2=0;

        %DO K=1 %TO &GROUPN;
            sumk=sumk+INPUT(kscan("&ratio",&K,',，、：:'),8.);                  /* 分配比例之和 */
        %end;
        ifmod=mod(&blength,sumk);                                               /* 区组长度除以分配比例和 的余数 */
        call symput('sumk',strip(sumk));
        call symput('ifmod',ifmod);
        
        %do i=1 %to &centern;
            n=number-(&block*&blength)*(center-1);                              /* 各中心编号号码 */
            if center=&i then centname=strip(kscan("&cename",&i,',，、/'));
        %end;



        %do j=1 %to &groupn;                                                    /* 按照分配比例的分布概率，进行分组 */
            
            sumj1=sumj1+INPUT(kscan("&ratio",&j,',，、：:'),8.);                /* 累积概率的分子 */
            
            if &j>1 then do;
                sumj2=sumj2+INPUT(kscan("&ratio",&j-1,',，、：:'),8.);          /* 前一个的累积概率 */
            end;
            

            if group<=sumj1/sumk and group>sumj2/sumk then do;                  /* 0<group<1：为自身随机数除以区组长度 */
                groupnam=strip(kscan(kscan("&groupa",&j,',，、'),1,':：'));     /* 分组名称 */
                groupacs=strip(kscan(kscan("&groupa",&j,',，、'),2,':：'));     /* 分组代码 */
            end;

        %end;

        /* 将中心编号、受试者编号考虑起初号赋值给c1_0,n1_0 */
        if "&beginc"="" or "&beginc"="1"  then do; 
            c1_0=center;
        end;                    
        else do;
            c1_0=center+&beginc-1;
        end;
        if "&begins"="" or "&begins"=1 then do;
            n1_0=n;
        end;
        else do;
            n1_0=n+&begins-1;
        end;
        

        /* 连接受试者统一代码，受试者编号 */
        n1=input(put(n1_0, &subfmt. ),$200.);       /* 限定位数为3位，不足补0 */
        c1=input(put(c1_0, &cenfmt. ),$200.);

        ncenter=cats("&subja",c1);
        id=cats(ncenter,n1);
        
        label id="受试者随机编号"  c1="中心编号" groupacs="分组代码" groupnam="分组名称" 
            block="区组号" length="区组内编号" centname="中心名称" number="序号"; 
        drop  n1 ncenter    GROUP ifmod;
run;



/* 记录窗口的信息 */
data &outdata2(label='填入参数信息');     
    author="&name";
    xmname="&xmname";
    n="&n";
    seed="&firseed";
    siten="&centern";
    cename="&cename";
    block="&block";
    blength="&blength";
    groupn="&groupn";
    groupa="&groupa";
    ratio="&ratio";
    subja="&subja";
    beginc="&beginc";
    begins="&begins";
    cenfmt="&cenfmt";
    subfmt="&subfmt";
    randay="&sysday";
    randate="&sysdate";

    label author='随机人员'     xmname='项目名称'           n='拟随机总数'
          seed='初始种子数'      cename='各中心名称'        block='区组数'
          blength='区组长度'    groupn='组别数'            groupa='组别代码'
          ratio='分配比例'      subja='受试者统一编号'     randay='随机日'
          randate='随机日期'    siten="中心数"             cename="中心名称"
          beginc='中心起始编号' begins='受试者起始编号'    cenfmt="中心编号格式" subfmt="受试者编号格式";
run;


/* 若每区组长度为 分配比例的整倍数，则生成随机数表 */
    %if %eval(&ifmod=0) %then %do;                                          
        data &outdata1(label='随机数表');     /* 最终的随机数表 */
            retain number c1 centname id block length groupacs groupnam;
        set b;
        run;

        proc delete data=a b;
        run;
    %end;
    /* 若逻辑判断错误，则报错   验证2：每区组长度必须为分配比例和的整倍数( mod()函数为取余数 )，若否，则报错 */
    %else %do;                                                              
        proc delete data=a b;
        run;
        %put ERROR: 每区组长度=&blength 应为 分配比例和=&sumk 的整倍数 ;
        %display &winname;
    %end;
%MEND;

/* 出表 */
%RAND_TEM();


/* 判断必填项是否为空 */
%do %while(  %length(&force_close)=0 and  
                ^( %length(&n)>0 and %length(&firseed)>0 and %length(&centern)>0 and %length(&cename)>0 and 
                %length(&block)>0 and %length(&blength)>0 and %length(&groupn)>0 and %length(&groupa)>0 and 
                %length(&ratio)>0 )
      );
        %put ERROR: 高亮必填项缺失或未填，请核查！;
        %display &winname;
        %RAND_TEM();
%end;

/* 是否判断-若宏窗口没有填完，则一直循环输出此窗口，填写完整 */
%do %while( %length(&close)>0 and (%length(&name)=0 or %length(&xmname)=0 or %length(&n)=0 or %length(&firseed)=0 or %length(&centern)=0 or %length(&cename)=0 or 
                %length(&block)=0 or %length(&blength)=0 or %length(&groupn)=0 or %length(&groupa)=0 or %length(&ratio)=0 or %length(&subja)=0
                %length(&beginc)=0 or %length(&begins)=0) );
        %display &winname;
        %RAND_TEM();
        %put NOTE: 窗口信息未填写完整，需核查！;
%end;


/* 验证1: 随机总数是否等于 中心数*区组数*区组长度，若对则继续执行，若否，则报错 */
%do %while( (%length(&centern)>0 and %length(&block)>0 and %length(&blength)>0) and &n^=%eval(&centern*&block*&blength) );  
                %put ERROR: 拟随机总数=&n 与 (中心数=&centern)*(区组数=&block)*(区组长度=&blength)的结果不一致，请核查！;
                %display &winname;
                %RAND_TEM();
%end;                            


/* 是否保留窗口记忆 */
%do %while ( %length(&memory)>0 );
        %display &winname;
        %RAND_TEM();
%end;



%mend;




/* --------------------test-------------------- */
/*
%win_random2(win_test,randtest,outdata2=randform);
*/


/* 2021-10-13 后续可补充：1.目前未考虑各中心比例问题，比如一家中心35例，一家中心10例 */





