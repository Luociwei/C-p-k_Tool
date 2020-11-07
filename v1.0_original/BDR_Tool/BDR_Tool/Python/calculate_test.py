#! /usr/bin/env python3
# --*-- coding: utf-8 ---*---

import sys,os,time,math,re
import datetime


import time
import threading

start_time = datetime.datetime.now()  #
print('-------------- script update on 20200705 ---------------')
show_log_flag = True

BASE_DIR=os.path.dirname(os.path.abspath(__file__))
print('BASE_DIR--->',BASE_DIR)
sys.path.insert(0,BASE_DIR+'/site-packages/')

print('python import ----> csv')
try:
    import csv
except Exception as e:
    print('e---->',e)

print('python import ---->matplotlib')
try:
    import matplotlib
    matplotlib.use('Agg')
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


# print('python import ----> scipy')
# try:
#     from scipy import stats
# except Exception as e:
#     print('import scipy error:',e)


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



redisClient = redis.Redis(host='localhost', port=6379, db=0)
context = zmq.Context()
socket = context.socket(zmq.REP)
socket.bind("tcp://127.0.0.1:3120")


def calulate_param(header_list,df,csv_path):
    # print('header_list:',type(header_list),header_list,list(df.columns))

    data = [('item_name','BC','P_Val','a_Q','a_irr','3CV'),]
    f = open(csv_path,'w')
    writer = csv.writer(f)

    writer.writerow(('item_name','BC','P_Val','a_Q','a_irr','3CV'))


    column_list = []
    n=0
    for item_name in header_list:
        column_list = df[item_name].tolist()
        # print('column_list--->',column_list)#string list

        # print('item_name:',item_name)
        need_cpk = valid_column(item_name,column_list)
        # print('need_cpk:---->',need_cpk)
        column_num_list = []
        if need_cpk == 'need_cpk':
            column_list = test_value_to_numeric(column_list[2:])
            # print(str(n)+'column_list:',column_list)
            bc,p_val,a_Q,a_irr,three_CV = get_coefficients(column_list)
            value = (item_name,bc,p_val,a_Q,a_irr,three_CV)
            writer.writerow(value)
        n=n+1

    f.close()

def test_value_to_numeric(test_data_list):
    column_list = []
    i = 0
    for x in test_data_list:
        if i ==0 and x == 'NA' or i ==1 and x == 'NA':
            column_list.append(x)
        else:
            try:
              x = float(x)
              column_list.append(x)
            except Exception as e:
                pass
            # print('-------------------- it is not number --------------')
        i = i + 1

    # print('column_list--->',column_list)
    return column_list


def is_number(num):
    pattern = re.compile(r'(.*)\.(.*)\.(.*)')
    if pattern.match(num):
        return False
    return num.replace(".", "").replace('-','').isdigit()


def valid_column(test_item_name,column_list):

    # column_list = df[test_item_name].tolist()
    # print('valid_column item_name-->',test_item_name)
    # print('valid_column--->',len(column_list),column_list)

    # print('column_value_list--->',column_list)
    if test_item_name.lower().find('_cb_count') == -1 and test_item_name.lower().find('fixture channel id') == -1 and test_item_name.lower().find('ss1_num_tri') == -1 and test_item_name.lower().find('fixture vendor_id') == -1:
        pass
    else:
        return 'not_cpk state1'
    if column_list[0] == '0' and column_list[1] == '0' or column_list[0] == '1' and column_list[
        1] == '1' or  column_list[0] == column_list[1] and  column_list[0] !='NA' or len(column_list)< 5:
        # print('====>',column_list[0],column_list[1])
        return "not_cpk state2"
    else:
        # pattern = re.compile(r'^[+-]?[0-9]*\.?[0-9]+$')
        # print('valid_column len----->',test_item_name,len(column_list))
        # print('v====>',column_list[0],column_list[1],column_list,len(column_list))
        j=0
        for i in range(2,len(column_list),1):
            # print(str(i),'valid_column----->',test_item_name,pattern.match(column_list[i]))
            if is_number(column_list[i]):
                j=j+1
                # print(str(j)+',len(set(column_list))-->',j,len(set(column_list)))
                if j>3 and len(set(column_list))>=3:
                    # print('need_cpk')
                    return "need_cpk"
 
        return "not_cpk state3"

def get_coefficients(value_l):
    '''
    param value_l: need float list
    return: bc,p_val,a_Q,a_irr,three_σ_x100_divide_mean
    1σ＝690000／1000000 #fault rate
    2σ＝308000／1000000
    3σ＝66800／1000000
    4σ＝6210／1000000
    5σ＝230／1000000
    6σ＝3.4／1000000 
    7σ＝0／1000000
    '''
    
    column_stdev = np.std(value_l,ddof=1,axis=0)
    three_sigma= 3*column_stdev
    # print('three_sigma:',column_stdev,three_sigma)
    data = np.array(value_l)
    if len(data) <= 3:
        return '','','','',''
    try:
        dip, p_val = diptest.diptest(data)
    except Exception as e:
        print('calculate dip,p_val error:',e)
        return '','','','',''
    # print('dip,p_val:',dip,p_val)
    item_name ='value1'
    data = pd.DataFrame({item_name:value_l})
    # print('data--->',type(data),data)
    u1 = data[item_name].mean() # 计算均值
    # std1 = data[item_name].std() # 计算标准差
    # t,pval=stats.kstest(data[item_name], 'norm', (u1, std1))
    # print('normality test t,pval:',str(t),str(pval))

    # print('------')
    # 正态性检验 → pvalue >0.05

    n= float(len(value_l))
    #Item (xi-ẍ)^2
    item_l_1 =[]
    item_l_2 = []
    item_l_3 = []
    for i in value_l:
        temp1 = (i-u1)**2
        temp2 = (i-u1)**3
        temp3 = (i-u1)**4
        item_l_1.append(temp1)
        item_l_2.append(temp2)
        item_l_3.append(temp3)
    # print('item_l_1--->',item_l_1)
    # print('item_l_2--->',item_l_2)
    # print('item_l_3--->',item_l_3)
    sum_item_l_1 = sum(item_l_1)
    sum_item_l_2 = sum(item_l_2)
    sum_item_l_3 = sum(item_l_3)
    # print('sum_item_l_1',sum_item_l_1)
    # print('sum_item_l_2',sum_item_l_2)
    # print('sum_item_l_3',sum_item_l_3)
    if n<=3 or sum_item_l_1==0 or sum_item_l_2==0 or sum_item_l_3==0:
        # print('len < 3--->')
        if abs(u1) == 0:
            return 'Nan',round(p_val,6),'Nan','Nan','Nan'
        else:
            three_CV = three_sigma*100/abs(u1)
            # print('three_CV:',three_CV)
            return 'Nan',round(p_val,6),'Nan','Nan',round(three_CV,6)
    else:
        try:
            m3 = np.sqrt(n*(n-1))/(n-2)*((1/n*sum_item_l_2)/np.sqrt(1/n*sum_item_l_1)**3)

            # print('m3=',m3)
            # print('d8:',n+1)
            # print('d15:',1/n*sum_item_l_3/(1/n*sum_item_l_1)**2)
            # print('d16:',(n+1)*1/n*sum_item_l_3/(1/n*sum_item_l_1)**2-3*(n-1))
            # print('d6/d7',(n-1)/((n-2)*(n-3)))
            m4 = ((n-1)/((n-2)*(n-3)))*((n+1)*1/n*sum_item_l_3/(1/n*sum_item_l_1)**2-3*(n-1))#(d6/d7)*d16
            # print('m4=',m4)
            #(d14**2+1)/(d17+3*(d10/d7))
            bc =(m3**2+1)/(m4+3*((n-1)**2/((n-2)*(n-3))))
            # print('bc:',bc)
            a_L=0.05
            a_M=0.1
            a_U=0.32
            a_Q = (a_U-a_L)*bc**2+a_L
            # print ('a_Q:',a_Q)
            a_irr = np.sqrt((a_U-a_L)**2*bc)+a_L
            # print('a_irr:',a_irr)
        except Exception as e:
            # print('calculate error',e)
            if abs(u1) == 0:
                return 'Nan',round(p_val,6),'Nan','Nan','Nan'
            else:
                three_CV = three_sigma*100/abs(u1)
                # print('three_CV:',three_CV)
                return 'Nan',round(p_val,6),'Nan','Nan',round(three_CV,6)


    if abs(u1) == 0:
        return round(bc,6),round(p_val,6),round(a_Q,6),round(a_irr,6),'Nan'
    else:
        three_CV = three_sigma*100/abs(u1)
        # print('three_CV:',three_CV)
        return round(bc,6),round(p_val,6),round(a_Q,6),round(a_irr,6),round(three_CV,6)

def open_all_csv(event,all_csv_path,data_select,remove_fail):

    tmp_lst = []
    with open(all_csv_path, 'r') as f:
        reader = csv.reader(f)
        i = 1
        for row in reader:
            # print(row[0].lower())
            if row[0].lower().find('fct') != -1:
                # print("FW version---->")
                pass
            elif row[0].lower().find('display name') != -1:
                pass
            elif row[0].lower().find('pdca priority') != -1:
                pass
            elif row[0].lower().find('upper limit') != -1:
                tmp_lst.append(row)
            elif row[0].lower().find('lower limit') != -1:
                tmp_lst.append(row)
            elif row[0].lower().find('measurement unit') != -1:  # "Measurement Unit ----->" in row:
                pass
            elif row[0].lower().find('site') != -1:
                tmp_lst.append(row)
            else:
                tmp_lst.append(row)
            i = i + 1
    # print("index---->", tmp_lst[0])
    header_list = tmp_lst[0]
  



    df = pd.DataFrame(tmp_lst[1:], columns=tmp_lst[0])
    header_df =df[0:2]
    # print('header_df before--->', header_df)
    data_df = df[2:]
    # print('data_df before--->', data_df)
 

    print('csv data row number before remove SN empty--->', len(data_df.values.tolist()))
    data_df=data_df[~data_df['SerialNumber'].isin([''])]#Remove SN Empty
    print('csv data row number after remove SN empty--->', len(data_df.values.tolist()))
    print('csv data row number before remove fail--->', len(data_df.values.tolist()))
    if remove_fail== 'yes':
        data_df=data_df[data_df['Test Pass/Fail Status'].isin(['PASS'])]
            # data_df=data_df[~data_df['Test Pass/Fail Status'].isin(['FAIL'])]
    print('csv data row number after remove fail--->', len(data_df.values.tolist()))
    print('csv data row number before remove retest--->', len(data_df.values.tolist()))
    if data_select == 'first':
        data_df.drop_duplicates(['SerialNumber'],keep='first',inplace=True)
    elif data_select == 'last':
        data_df.drop_duplicates(['SerialNumber'],keep='last',inplace=True)
    elif data_select == 'no_retest':
        data_df.drop_duplicates(['SerialNumber'],keep=False,inplace=True)
    elif data_select == 'all':
        pass
    print('csv data row number after remove retest--->', len(data_df.values.tolist()))

    if event == 'keynote-report':
        project_code,build_stage,station_name = get_project_info(data_df)
    else:
        project_code,build_stage,station_name = '','',''

    start_time_l  = data_df['StartTime'].values.tolist() #StartTime
    start_time_first = min(start_time_l)
    start_time_last  = max(start_time_l)
    print('<first time -- last time>',start_time_first,start_time_last)

    df = header_df.append(data_df)

 
    # if event != 'one_item_plot':
    #     station_id_l = df['Station ID'].values.tolist()
    #     fixture_channel_id = df['Fixture Channel ID'].values.tolist()
    #     # print('station_id_l:',station_id_l)
    #     # print('fixture_channel_id:',fixture_channel_id)
    #     temp_l = []
    #     for i in range(0,len(station_id_l[2:])):
    #         temp_l.append(station_id_l[i+2]+'_'+fixture_channel_id[i+2])
    #     temp_l.insert(0,'')
    #     temp_l.insert(0,'')
    #     fixture_channel_id = temp_l
    #     # print(fixture_channel_id)
    #     df['Fixture Channel ID'] = pd.DataFrame({'Fixture Channel ID':fixture_channel_id})
    #     # print('fixture channel id:',df['Fixture Channel ID'].values.tolist())

    #     print('*******************************')


    # print('df after--->', df)
    # print('df.values ---->', df.values)#array([[ ]])
    return header_list,df,project_code,build_stage,station_name,start_time_first,start_time_last




def correlation(message):
    print("this function is generate correlation plot......")
    val = redisClient.get(message)
    # time.sleep(5)  #测试python 执行时间 5s
    if val:
        return val
    else:
        return b'None'
        

def run(n):
    while True:
        try:
            print("wait for calculate client ...")
            zmqMsg = socket.recv()
            socket.send(b'calculate_sendback')
            if len(zmqMsg)>0:
                keyMsg = zmqMsg.decode('utf-8')
                print("message from calculate client:", keyMsg)
                msg =keyMsg.split("$$")
                if len(msg)>3:
                    if msg[0] == 'calculate-param':
                        data_select = 'all'
                        remove_fail = 'yes'
                        all_csv_path = msg[1]
                        csv_path = msg[2]
                        header_list,df,project_code,build_stage,station_name,start_time_first,start_time_last = open_all_csv('calculate-param',all_csv_path,data_select,remove_fail)
                        calulate_param(header_list,df,csv_path)
                        filelogname = msg[3]
                        with open(filelogname, 'w') as file_object:
                            file_object.write("PASS,calculate is finished")
            else:
                time.sleep(0.05)
        except Exception as e:
            print('error:',e)

if __name__ == '__main__':
    run(0)
    # t1 = threading.Thread(target=run, args=("<<correlation>>",))
    # t1.start()

    # all_csv_path = '/Users/RyanGao/Desktop/cpk/cpk_data_0611/J5xx-FCT.csv'
    # data_select = 'all'
    # remove_fail = 'yes'
    # header_list,df,project_code,build_stage,station_name,start_time_first,start_time_last =  open_all_csv('calculate-param',all_csv_path,data_select,remove_fail)
    # csv_path = '/Users/RyanGao/Desktop/CPK_Log/temp/calculate_param.csv'
    # calulate_param(header_list,df,csv_path)
    
