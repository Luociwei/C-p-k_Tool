#! /usr/bin/env python3
# --*-- coding: utf-8 ---*---

import sys,os,time,math,re
import time
import threading



BASE_DIR=os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0,BASE_DIR+'/site-packages/')

try:
    import csv
except Exception as e:
    print('e---->',e)

print('python import ---->matplotlib')
try:
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
except Exception as e:
    print('e---->',e)

print('python import ----> matplotlib.colors')
try:
    import matplotlib.colors as colors
except Exception as e:
    print('e---->',e)

print('python import ----> FontProperties')
try:
    from matplotlib.font_manager import FontProperties
except Exception as e:
    print('e---->',e)


print('python import ----> numpy')
try:
    import numpy as np
except Exception as e:
    print('e--->',e)

print('python import ----> pandas')
try:
    import pandas as pd
except Exception as e:
    print('e--->',e)

print('python import ----> openpyxl')
try:
    import openpyxl
except Exception as e:
  print('import openpyxl error:',e)
print('python import ----> xlsxwriter')
try:
    import xlsxwriter
except Exception as e:
  print('import xlsxwriter error:',e)

print('python import ----> diptest')
try:
    import diptest
except Exception as e:
    print('import diptest error:',e)


try:
    import zmq
except Exception as e:
    print('import zmq error:',e)
print('python import ----> zmg')

try:
    import redis
except Exception as e:
    print('import redis error:',e)
print('python import ----> redis')

print(sys.getdefaultencoding())



import zmq
import redis

redisClient = redis.Redis(host='localhost', port=6379, db=0)
context = zmq.Context()
socket = context.socket(zmq.REP)
socket.setsockopt(zmq.LINGER,0)
socket.bind("tcp://127.0.0.1:3110")


filelogname = ''
table_data_correlation_y = []
select_x_flag = 0
xy_reverse_flag = 0

def get_redis_data(zmqMsg):
    tb = redisClient.get(zmqMsg)
    tb_data=[]
    if tb:
        tb=tb.decode('utf-8')
        tb=tb.split("\n")
        tb=(tb[1:-1])   #去掉数据库首尾元素
        for i in tb:
            k=re.sub('\"','',i)  #去掉数据库引号
            h=re.sub(',','',k)   #去掉数据库逗号
            m=h.strip()          #去掉数据库首尾空白
            if is_number(m):
                tb_data.append(eval(m))   #去掉数字的引号
            else:
                tb_data.append(m)
    else:
        tb_data.append('')
    return tb_data

def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        pass
    try:
        import unicodedata
        unicodedata.numeric(s)
        return True
    except (TypeError, ValueError):
        pass
    return False



def correlation_plot(table_data_x,table_data_y):
    try:
        global filelogname

        info = ''

        i_start_x = [i for i,x in enumerate(table_data_x) if x=='Start_Data']
        i_stop_x = [i for i,x in enumerate(table_data_x) if x=='End_Data']
        tbdata_x=[]  #取出数据
        for i, v in enumerate(i_start_x):  #因start_data和End_data成对出现
            tbdata_x.append(table_data_x[i_start_x[i]-36:i_stop_x[i]])

        i_start_y = [i for i,x in enumerate(table_data_y) if x=='Start_Data']
        i_stop_y = [i for i,x in enumerate(table_data_y) if x=='End_Data']
        tbdata_y=[]  #取出数据
        for i, v in enumerate(i_start_y):  #因start_data和End_data成对出现
            tbdata_y.append(table_data_y[i_start_y[i]-36:i_stop_y[i]])

        y_item_name = tbdata_y[0][1]
        x_item_name = tbdata_x[0][1]

        # print('y_item_name==>',y_item_name)
        # print('x_item_name==>',x_item_name)
      
        y_usl = tbdata_y[0][4]
        y_lsl = tbdata_y[0][5]

        x_usl = tbdata_x[0][4]
        x_lsl = tbdata_x[0][5]

        set_bins = tbdata_x[0][19]
        path= tbdata_x[0][30]
        start_time_first = tbdata_x[0][21]
        start_time_last = tbdata_x[0][22]

        new_y_lsl = tbdata_y[0][7]
        new_y_usl = tbdata_y[0][8]
        # new_lsl,new_usl = verify_limit(new_y_lsl,new_y_usl)
        limit_apply_y = tbdata_y[0][9]
        if limit_apply_y == 1:
            y_lsl = new_y_lsl
            y_usl = new_y_usl

        new_x_lsl = tbdata_x[0][7]
        new_x_usl = tbdata_x[0][8]
        # new_lsl,new_usl = verify_limit(new_x_lsl,new_x_usl)
        limit_apply_x = tbdata_x[0][9]
        if limit_apply_x== 1:
            x_lsl = new_x_lsl
            x_usl = new_x_usl


        # image_name = item_name.replace('/','_')+".png"
        filelogname = path + '/temp/.logcor.txt'
        image_name ='correlation.png'
        pic_path = path +'/temp/'
        # if not os.path.exists(pic_path):
        #     os.makedirs(pic_path)
        # os.system('mkdir '+pic_path)
        pic_path = pic_path + image_name
        print('pic_path--->',pic_path)

        select_color_by_left = tbdata_x[0][31]   #判断是否点击了color by
        select_color_by_right = tbdata_x[0][32]   #判断是否点击了color by

        select_btn_x = tbdata_x[0][33]   #select x button
        select_btn_y = tbdata_x[0][34]   #select x button

        print("----select x,y:",select_btn_x,select_btn_y)
        print("--select color by correlation: ",select_color_by_left,select_color_by_right)
        if select_color_by_left == 0 and select_color_by_right == 0:  #没有点击color by
            x_tb_value = tbdata_x[0][37:]
            y_tb_value = tbdata_y[0][37:]

            # print("=====x_tb_value:",x_tb_value)
            # print("=====x_tb_value:",y_tb_value)

            tb_len_x = len(x_tb_value)
            tb_len_y = len(y_tb_value)

            xValue=[]
            yValue=[]
            if tb_len_x>tb_len_y:  #删除空元素 和长度不匹配的，按照做小的长度为基准
                for i,v in enumerate(y_tb_value):
                    if x_tb_value[i]!='' and v!='':
                        xValue.append(x_tb_value[i])
                        yValue.append(v)

            else:
                for i,v in enumerate(x_tb_value):
                    if y_tb_value[i]!='' and v!='':
                        xValue.append(v)
                        yValue.append(y_tb_value[i])

            if len(xValue)<1 and len(yValue)<1 and len(yValue) != len(xValue):  # 判断确认一下长度，理论上经过上面的判断，都应该是一样的长度
                print('xValue and yValue are not same length!Can not calculate pearson/generate correlation_plot')
                # redisClient.set('correlation_png','xValue and yValue are not same')
                with open(filelogname, 'w') as file_object:
                    file_object.write("FAIL,xValue and yValue are not same")
                return 'xValue and yValue are not same length!Can not calculate pearson/generate correlation_plot'

            draw_correlation(xValue,yValue,x_item_name,y_item_name,pic_path,x_lsl,x_usl,y_lsl,y_usl,start_time_first,start_time_last)

        else:
            #[[],[],[]...],only value category lists
            x_tb_val=[]  #取出数据  
            for i, v in enumerate(i_start_x):  #因start_data和End_data成对出现
                x_tb_val.append(table_data_x[i_start_x[i]+1:i_stop_x[i]])

            y_tb_val=[]  #取出数据
            for i, v in enumerate(i_start_y):  #因start_data和End_data成对出现
                y_tb_val.append(table_data_y[i_start_x[i]+1:i_stop_x[i]])

            x_tb_len = len(x_tb_val)  #存的二位数组x
            y_tb_len = len(y_tb_val)  #存的二位数组y

            x_category_value = [] # 二位数组x
            y_category_value = [] #二位数组y
            if x_tb_len>y_tb_len:   
                for i,v in enumerate(y_tb_val):
                    x_tb_value = x_tb_val[i]   # 取出一位数组值x
                    y_tb_value = y_tb_val[i]   # 取出一位数组值y
                    tb_len_x = len(x_tb_value)
                    tb_len_y = len(y_tb_value)

                    x_category_tmp = [] #一维数组值x
                    y_category_tmp = [] #一维数组值y

                    if tb_len_x>tb_len_y:  #删除空元素 和长度不匹配的，按照做小的长度为基准
                        for i,v in enumerate(y_tb_value):
                            if x_tb_value[i]!='' and v!='':
                                x_category_tmp.append(x_tb_value[i])
                                y_category_tmp.append(v)
                    else:
                        for i,v in enumerate(x_tb_value):
                            if y_tb_value[i]!='' and v!='':
                                y_category_tmp.append(v)
                                y_category_tmp.append(y_tb_value[i])

                    x_category_value.append(x_category_tmp)
                    y_category_value.append(x_category_tmp)
            
            else:

                for i,v in enumerate(x_tb_val):
                    x_tb_value = x_tb_val[i]   # 取出一位数组值x
                    y_tb_value = y_tb_val[i]   # 取出一位数组值y
                    tb_len_x = len(x_tb_value)
                    tb_len_y = len(y_tb_value)

                    x_category_tmp = [] #一维数组值x
                    y_category_tmp = [] #一维数组值y

                    if tb_len_x>tb_len_y:  #删除空元素 和长度不匹配的，按照做小的长度为基准
                        for i,v in enumerate(y_tb_value):
                            if x_tb_value[i]!='' and v!='':
                                x_category_tmp.append(x_tb_value[i])
                                y_category_tmp.append(v)
                    else:
                        for i,v in enumerate(x_tb_value):
                            if y_tb_value[i]!='' and v!='':
                                x_category_tmp.append(v)
                                y_category_tmp.append(y_tb_value[i])

                    x_category_value.append(x_category_tmp)
                    y_category_value.append(y_category_tmp)               

            
            if len(x_category_value)<1 and len(y_category_value)<1 and len(x_category_value)!=len(y_category_value):
                print("no data, can not generate plot")
                with open(filelogname, 'w') as file_object:
                    file_object.write("FAIL,x_category_value and y_category_value are not same")
                return 'X table or Y table no data, can not generate plot'
            xValue = ([i for item in x_category_value for i in item]) # 二维列表拼接成一维列表
            yValue = ([i for item in y_category_value for i in item]) # 二维列表拼接成一维列表

            draw_correlation_by_color(xValue,yValue,x_category_value,y_category_value,x_item_name,y_item_name,pic_path,x_lsl,x_usl,y_lsl,y_usl,start_time_first,start_time_last)

        info = 'correlation plot draw finished!'
        print(info)
        with open(filelogname, 'w') as file_object:
            file_object.write("PASS,correlation plot draw finished")
        # redisClient.set('correlation_png','PASS,correlation plot draw finished!')
        return info

    except Exception as e:
        with open(filelogname, 'w') as file_object:
            file_object.write("FAIL,error correlation_plot function")
        print('error correlation_plot function:',e)

def draw_correlation(xValue,yValue,x_item_name,y_item_name,pic_save_path,x_lsl,x_usl,y_lsl,y_usl,start_time_first,start_time_last):

    pearson,spearman = correlation_coefficient_calc(xValue, yValue, x_item_name, y_item_name)
    plt.ion()  # 开启interactive mode
    # font = FontProperties(fname=r"/Library/Fonts/Songti.ttc", size=12)
    fig, axes = plt.subplots(1, 0, figsize=(8, 6), facecolor='#ccddef')
    plt.axes([0.15, 0.15, 0.75, 0.75])  # [左, 下, 宽, 高] 规定的矩形区域 （全部是0~1之间的数，表示比例）    
    plt.title('Correlation pearson coefficient = ' + str(pearson)+'\n'+str(start_time_first)+' -- '+str(start_time_last),size=14)
    if len(x_item_name) > 55:
        x_item_name = x_item_name[0:55] + '\n' + x_item_name[55:]
    if len(y_item_name) > 55:
        y_item_name = y_item_name[0:55] + '\n' + y_item_name[55:]
    plt.xlabel(x_item_name,size=12)
    plt.ylabel(y_item_name,size=12)

    x_min_num, x_max_num = min(xValue), max(xValue)

    print('xvalue min,max:', x_min_num, x_max_num)
    
    x_ticks_l, x_ticks_h = get_ticks(x_min_num, x_max_num, x_lsl, x_usl)
    
    if x_ticks_l == x_ticks_h and x_ticks_l !=0:
        x_ticks_l = x_ticks_l - round((x_ticks_l/5.0),2)
        x_ticks_h = x_ticks_h + round((x_ticks_h/5.0),2)
    elif x_ticks_l == x_ticks_h and x_ticks_l ==0:
        x_ticks_l =  - 3
        x_ticks_h = 3
    
    
    print('x_ticks_l x_ticks_h:', x_ticks_l, x_ticks_h)
    plt.xlim(x_ticks_l, x_ticks_h)

    y_min_num, y_max_num = min(yValue), max(yValue)
    print('yvalue min,max:', y_min_num, y_max_num)
    y_ticks_l, y_ticks_h = get_ticks(y_min_num, y_max_num, y_lsl, y_usl)
    
    if y_ticks_l == y_ticks_h and y_ticks_l !=0:
        y_ticks_l = y_ticks_l - round((y_ticks_l/5.0),2)
        y_ticks_h = y_ticks_h + round((y_ticks_h/5.0),2)
    elif y_ticks_l == y_ticks_h and y_ticks_l ==0:
        y_ticks_l =  - 3
        y_ticks_h = 3
    
    print('y_ticks_l y_ticks_h:', y_ticks_l, y_ticks_h)
    plt.ylim((y_ticks_l, y_ticks_h))  # 设置y轴scopex
    ax=plt.gca()
    ax.spines['bottom'].set_linewidth(1.5)
    ax.spines['left'].set_linewidth(1.5)
    ax.spines['right'].set_linewidth(1.5)
    ax.spines['top'].set_linewidth(1.5)
    if x_lsl != 'NA' and x_usl != 'NA':
        plt.plot([x_lsl, x_lsl, ], [y_ticks_l, 100000000, ], 'k--', linewidth=3.0, color='red')  # x lower limit线，
        plt.plot([x_usl, x_usl, ], [y_ticks_l, 100000000, ], 'k--', linewidth=3.0, color='red')  # x upper limit线，
    if y_lsl != 'NA' and y_usl != 'NA':
        plt.plot([x_ticks_l, 100000000, ], [y_lsl, y_lsl, ], 'k--', linewidth=3.0, color='red')  # y lower limit线，
        plt.plot([x_ticks_l, 100000000, ], [y_usl, y_usl, ], 'k--', linewidth=3.0, color='red')  # y upper limit线，

    # plt.scatter(x, y, s, c, marker)
    # x: x轴坐标
    # y：y轴坐标
    # s：点的大小/粗细 标量或array_like 默认是 rcParams['lines.markersize'] ** 2
    # c: 点的颜色
    # marker: 标记的样式 默认是 'o'
    # plt.legend()
    plt.rcParams['savefig.dpi'] = 250  # 图片像素
    plt.rcParams['figure.dpi'] = 150  # 分辨率
    plt.scatter(xValue, yValue, s=45,linewidth =1, c="blue", marker='+')
    plt.grid(linestyle=':', c='gray', linewidth=1, alpha=0.6)  # 生成网格
    plt.savefig(pic_save_path, dpi=250)
    plt.draw()
    # plt.show()
    plt.close()
    plt.ioff()

def draw_correlation_by_color(xValue,yValue,x_category_value,y_category_value,x_item_name,y_item_name,pic_save_path,x_lsl,x_usl,y_lsl,y_usl,start_time_first,start_time_last):
    
    # print("===xValue",xValue)
    # print("===yValue",yValue)
    # print("===x_category_value",x_category_value)
    # print("===y_category_value",y_category_value)

    pearson, spearman = correlation_coefficient_calc(xValue, yValue, x_item_name, y_item_name)
    plt.ion()  # 开启interactive mode
    # font = FontProperties(fname=r"/Library/Fonts/Songti.ttc", size=12)
    fig, axes = plt.subplots(1, 0, figsize=(8, 6), facecolor='#ccddef')
    plt.axes([0.15, 0.15, 0.75, 0.75])  # [左, 下, 宽, 高] 规定的矩形区域 （全部是0~1之间的数，表示比例）
    plt.title('Correlation pearson coefficient = ' + str(pearson)+'\n'+str(start_time_first)+' -- '+str(start_time_last),size=14)
    if len(x_item_name) > 55:
        x_item_name = x_item_name[0:55] + '\n' + x_item_name[55:]
    if len(y_item_name) > 55:
        y_item_name = y_item_name[0:55] + '\n' + y_item_name[55:]
    plt.xlabel(x_item_name,size=12)
    plt.ylabel(y_item_name,size=12)

    x_min_num, x_max_num = min(xValue), max(xValue)
    print('xvalue min,max:', x_min_num, x_max_num)
    x_ticks_l, x_ticks_h = get_ticks(x_min_num, x_max_num, x_lsl, x_usl)
    
    if x_ticks_l == x_ticks_h and x_ticks_l !=0:
        x_ticks_l = x_ticks_l - round((x_ticks_l/5.0),2)
        x_ticks_h = x_ticks_h + round((x_ticks_h/5.0),2)
    elif x_ticks_l == x_ticks_h and x_ticks_l ==0:
        x_ticks_l =  - 3
        x_ticks_h = 3
    
    print('x_ticks_l x_ticks_h:', x_ticks_l, x_ticks_h)
    plt.xlim(x_ticks_l, x_ticks_h)

    y_min_num, y_max_num = min(yValue), max(yValue)
    print('yvalue min,max:', y_min_num, y_max_num)
    y_ticks_l, y_ticks_h = get_ticks(y_min_num, y_max_num, y_lsl, y_usl)
    
    if y_ticks_l == y_ticks_h and y_ticks_l !=0:
        y_ticks_l = y_ticks_l - round((y_ticks_l/5.0),2)
        y_ticks_h = y_ticks_h + round((y_ticks_h/5.0),2)
    elif y_ticks_l == y_ticks_h and y_ticks_l ==0:
        y_ticks_l =  - 3
        y_ticks_h = 3
    print('y_ticks_l y_ticks_h:', y_ticks_l, y_ticks_h)
    plt.ylim((y_ticks_l, y_ticks_h))  # 设置y轴scopex
    ax=plt.gca()
    ax.spines['bottom'].set_linewidth(1.5)
    ax.spines['left'].set_linewidth(1.5)
    ax.spines['right'].set_linewidth(1.5)
    ax.spines['top'].set_linewidth(1.5)
    if x_lsl != 'NA' and x_usl != 'NA':
        plt.plot([x_lsl, x_lsl, ], [y_ticks_l, 100000000, ], 'k--', linewidth=3.0, color='red')  # x lower limit线，
        plt.plot([x_usl, x_usl, ], [y_ticks_l, 100000000, ], 'k--', linewidth=3.0, color='red')  # x upper limit线，
    if y_lsl != 'NA' and y_usl != 'NA':
        plt.plot([x_ticks_l, 100000000, ], [y_lsl, y_lsl, ], 'k--', linewidth=3.0, color='red')  # y lower limit线，
        plt.plot([x_ticks_l, 100000000, ], [y_usl, y_usl, ], 'k--', linewidth=3.0, color='red')  # y upper limit线，

    # plt.scatter(x, y, s, c, marker)
    # x: x轴坐标
    # y：y轴坐标
    # s：点的大小/粗细 标量或array_like 默认是 rcParams['lines.markersize'] ** 2
    # c: 点的颜色
    # marker: 标记的样式 默认是 'o'
    # plt.legend()
    plt.rcParams['savefig.dpi'] = 250  # 图片像素
    plt.rcParams['figure.dpi'] = 150  # 分辨率
    # print('x_category_value,y_category_value length:---->',len(x_category_value),len(y_category_value),x_category_value[0], y_category_value[0])
    color_l = ['#0000FF','#FF0000','#008000','#00FFFF','#9400D3','#8B008B','#B8860B','#FFA500','#A9A9A9','#FFFF00']
    for i,v in enumerate(x_category_value):  # 因为传过来的参数x_category_value 和y_category_value 经过判断的，长度都是一样的，任意选择一个
        # print('i,v',i,v)
        set_color = color_l[i%10]
        plt.scatter(x_category_value[i], y_category_value[i], s=45,linewidth =1, c=set_color, marker='+')

    # for i in range(0,len(x_category_value),1):
    #     print(x_category_value[i][1],y_category_value[i][1])
    #     set_color = x_category_value[i][1]
    #     plt.scatter(x_category_value[i][5:], y_category_value[i][5:], s=40,linewidth =0.6, c=set_color, marker='+')
    plt.grid(linestyle=':', c='gray', linewidth=1, alpha=0.6)  # 生成网格
    plt.savefig(pic_save_path, dpi=250)
    plt.draw()
    # plt.show()
    plt.close()

    plt.ioff()

def get_ticks(min_num,max_num,lsl,usl):
    #for correlation plot
    print('min_num,max_num,lsl,usl=====>',min_num,max_num,lsl,usl)
    # return
    ticks_l = 0
    ticks_h = 0
    if lsl =='NA' or usl =='NA' or lsl =='' or usl =='':
        ticks_l = min_num
        ticks_h = max_num
    else:
        if min_num < lsl and max_num < lsl:
            ticks_l = min_num
            ticks_h = usl
        elif min_num < lsl and max_num > lsl and max_num <= usl:
            ticks_l = min_num
            ticks_h = usl
        elif min_num < lsl and max_num > usl:
            ticks_l = min_num
            ticks_h = max_num
        elif lsl <= min_num and min_num <= usl and max_num <= usl:
            ticks_l = lsl
            ticks_h = usl
        elif lsl <= min_num and min_num <= usl and max_num > usl:
            ticks_l = lsl
            ticks_h = max_num
        elif min_num > usl:
            ticks_l = lsl
            ticks_h = max_num
    # print('ticks_l,ticks_h:',ticks_l,ticks_h)
    range = get_limit_range(ticks_l,ticks_h)
    # print('ticks_range:',range,round((ticks_l-range/5),2),round((ticks_h+range/5),2))

    ticks_l,ticks_h = round((ticks_l-range/5),2),round((ticks_h+range/5),2)
    return ticks_l,ticks_h

def get_limit_range(lsl,usl):
    # print('lsl,usl----->', lsl, usl)
    range = 0
    if lsl < 0 and usl <= 0:
        range = abs(lsl) - abs(usl)
    elif lsl < 0 and usl >= 0:
        range = abs(lsl) + usl
    elif lsl >= 0 and (usl > 0):
        range = usl - lsl
    else:
        print('get_limit_range 00000')
    range = round(range, 5)
    # print('range in get_limit_range----->', range)
    return range

def correlation_coefficient_calc(data_l1,data_l2,item_name1,item_name2):

    '''
    item_name1 : string
    item_name2 : string
    data_l2 :[]
    data_l1 :[]
    '''
    if item_name1 == item_name2:# can not be the same name.
       item_name2 = item_name2+'_2'
    data = pd.DataFrame({item_name1:data_l1,
                       item_name2:data_l2})
    # print('correlation data:',data)
    pearson = data.corr(method='pearson').values[0].tolist()[1]
    spearman = data.corr(method='spearman').values[0].tolist()[1]
    pearson = round(pearson,5)
    spearman = round(spearman,5)
    # print('pearson:',pearson)
    # print('spearman:',spearman)
    return pearson,spearman

def verify_limit(lsl,usl):
    if lsl != None:
        lsl.replace(' ','')
    if usl != None:
        usl.replace(' ','')
    try:
        lsl = float(eval(lsl))
        usl = float(eval(usl))
    except:
        # print('no valid limit update!')
        return None,None
    if type(lsl) == float and type(usl) == float:
#         print('after verify lsl===>',lsl)
#         print('after verify usl===>',usl)
        return lsl,usl

def calculate_value(message):
    print("this function is calculate_value......")
    val = r.get(message)   # 注意 等到的都是字符串
    if val:
        val = float(val)*200   # 数学运算
        val = str(val).encode('utf-8')
        return val
    else:
        return b'0'

def run(n):
    global table_data_correlation_y
    global select_x_flag
    global xy_reverse_flag
    while True:
        try:
            print("wait for correlation ...")
            zmqMsg = socket.recv()
            socket.send(b'correlation.png')
            if len(zmqMsg)>0:
                key = zmqMsg.decode('utf-8')
                print("-->message from correltion  client:", key)
                table_x = get_redis_data(key)
                msg =key.split("$$")
                if len(msg)>1:
                    if msg[1]=='1':
                        select_x_flag = 0  #select X 设置
                        xy_reverse_flag = 0
                    if msg[1]=='10':
                        select_x_flag = 0  #select Y 设置
                        xy_reverse_flag = 1
                        
                if select_x_flag == 0:
                    table_data_correlation_y = table_x

                # print("===========start====")
                # print(table_data_correlation_y)
                # print(table_x)
                # print("===========end======")
                if len(table_x)>0:
                    if xy_reverse_flag == 0:
                        correlation_plot(table_data_correlation_y,table_x)
                    else:
                        correlation_plot(table_x,table_data_correlation_y)
                    select_x_flag = select_x_flag +1
                else:
                    print("---get data error")
                # socket.send(ret.decode('utf-8').encode('ascii'))
            else:
                time.sleep(0.05)
        except Exception as e:
            print('error:',e)

if __name__ == '__main__':
    run(0)
    # t1 = threading.Thread(target=run, args=("<<calculate>>",))
    # t1.start()
    # table_data = [['xxxxy', 8, 1, 4, 4, 4, 4,4],['yy_y',8, 1, 4.3, 4.2, 4.3,4.5,4.6]]
    # table_category_data = [[['CWNJ_00000_FCT', '#0000FF', 'x_x', 8, 1, 1.1, 1.2, 1.3, 1.4,1.5],['CWNJ_0_FCT', '#0000FF', 'x_x', 8, 1, 2.1, 2.2, 2.3, 2.4,2.5]],[['CWNJ_11111_FCT', '#FF0000', 'y_y', 8, 1, 6.1, 6.2, 6.3, 6.4,6.5],['CWNJ_11111_FCT', '#FF0000', 'y_y', 8, 1, 7.1, 7.2, 7.3, 7.4,7.5]]]
    # table_category_data = []#it's empty when color_by == 'Off'

    # new_y_lsl = ''
    # new_y_usl = ''
    # new_x_lsl = ''
    # new_x_usl = ''
    # start_time_first = '2020/3/11 14:16'
    # start_time_last = '2020/3/26 9:58'
    # pic_path = '/Users/RyanGao/Desktop/CPK_Log/'
    # print(table_category_data[0])
    # print(table_category_data[1])
    # correlation_plot(table_data,table_category_data,pic_path,start_time_first,start_time_last,new_y_lsl,new_y_usl,new_x_lsl,new_x_usl)
    
    # zmqMsg = 'Fixture Channel ID##retest_all&remove_fail_yes'
    # table_x = get_redis_data(zmqMsg)
    # table_y = table_x
    # if len(table_x)>0:
    #     correlation_plot(table_x,table_y)
    # else:
    #     print("---error---")
    
    




