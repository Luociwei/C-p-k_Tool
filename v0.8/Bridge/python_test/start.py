#! /usr/bin/env python3
# coding= utf-8
#update on 20200716 for V0.5
import datetime
import os,sys,re

print('['+str(datetime.datetime.now())+']','run start.py ---->')

# current_dir = os.path.dirname(os.path.realpath(__file__))
# print('current_dir--->',current_dir)
# sys.path.insert(0,current_dir)
# cmd ='export PYTHONPATH='+current_dir+'/'
# print('cmd--->',cmd)
# os.system(cmd)
# print('python import ----> csv')
try:
    import cpk
except Exception as e:
    print('e---->',e)



def parse_color_by(color_by):
    temp1,temp2='',''
    temp1_l=[]
    temp2_l = []
    if color_by =='Off':
        select_category_l= []
    else:
        it = re.finditer(r"\[(.*?)\]",color_by) 
        i=0
        for match in it:
            # print(match.group())
            if i == 0:
                temp1 = match.group()
                temp1 = temp1.replace('[','')
                temp1 = temp1.replace(']','')
            else:
                temp2 = match.group()
                temp2 = temp2.replace('[','')
                temp2 = temp2.replace(']','')
                temp1_l = [temp2]
                temp2_l = temp2_l + temp1_l
            i=i+1

        color_by = temp1
        select_category_l = temp2_l
        print ('-----color_by is-----'+str(color_by)+ '----\n')
        print('-----select_category_l is-----'+str(select_category_l)+ '----\n',len(select_category_l))
    return color_by,select_category_l

if __name__ == '__main__':
    all_csv_path = sys.argv[1]
    cpk_path = sys.argv[2]+'/'
    cpk_lsl = float(sys.argv[3])
    cpk_usl = float(sys.argv[4])
    color_by1 = sys.argv[5]
    set_bins = int(sys.argv[6])
    remove_fail = str.lower(sys.argv[7])#'no'
    one_item_name = sys.argv[8]
    data_select = str.lower(sys.argv[9])
    event = str.lower(sys.argv[10])
    new_y_usl =sys.argv[11]
    new_y_lsl =sys.argv[12]
    new_x_usl =sys.argv[13]
    new_x_lsl =sys.argv[14]
    color_by2 = sys.argv[15]
    excel_report_item =str.lower(sys.argv[16])
    fail_plot_to_excel =str.lower(sys.argv[17])
    excel_report_user =sys.argv[18]
    excel_report_stage = sys.argv[19]
    zoom_type = sys.argv[20]
    project_name = sys.argv[21]
    # select_category_l = sys.argv[8]

    # event = 'cpk-report'/'one_item_plot'/...
    #item_name =''
    # all_csv_path = '/Users/rex/Desktop/P1_Retest/cpk/222.csv'
    # cpk_path = "/Users/rex/PycharmProjects/my/"
    # cpk_lsl=1.33
    # cpk_usl=9999999999999999
    # color_by='off'#'off'/'SerialNumber'/'Version'/'Station ID'/'Special Build Name'/'Product'/'StartTime'/'Special Build Description'
    # select_category_l = [] #[]
    # data_select = 'first'#first/last/no_retest/all --empty sn reminder only for
    # remove_fail = 'No'
    # set_bins = 250

    print ('-----all_csv_path is-----'+all_csv_path + '----\n')
    print ('-----cpk_path is-----'+cpk_path + '----\n')
    print ('-----cpk_lsl is-----'+str(cpk_lsl) + '----\n')
    print ('-----cpk_usl is-----'+str(cpk_usl) + '----\n')
    print ('-----color_by1 is-----'+color_by1 + '----\n')
    print ('-----set_bins is-----'+str(set_bins) + '----\n')
    print ('-----remove_fail is-----'+remove_fail + '----\n')
    print ('-----one_item_name is-----'+one_item_name + '----\n')
    print ('-----data_select is-----'+data_select + '----\n')
    print ('-----event is-----'+event + '----\n')
    print ('-----select_new_y_usl is-----'+str(new_y_usl) + '----\n')
    print ('-----select_new_y_lsl is-----'+str(new_y_lsl) + '----\n')
    print ('-----select_new_x_usl is-----'+str(new_x_usl) + '----\n')
    print ('-----select_new_x_lsl is-----'+str(new_x_lsl) + '----\n')
    print ('-----color_by2 is-----'+color_by2 + '----\n')
    
    print ('-----excel_report_item is-----'+str(excel_report_item) + '----\n')
    print ('-----fail_plot_to_excel is-----'+str(fail_plot_to_excel) + '----\n')
    print ('-----excel_report_user is-----'+str(excel_report_user) + '----\n')
    print ('-----excel_report_stage is-----'+str(excel_report_stage) + '----\n')
    print ('-----zoom_type is-----'+str(zoom_type) + '----\n')
    print ('-----project_name is-----'+str(project_name) + '----\n')

     
    # color_by1 = '[Version],[20200310_v1__oscar_fct],[20200312_v1__oscar_fct],[20200319_v1__oscar_fct]'
    # color_by2 = '[Station ID],[CWNJ_C02-2FAP-23_2_FCT],[CWNJ_C02-2FAP-24_1_FCT],[CWNJ_C02-2FAP-23_1_FCT],[CWNJ_C02-2FAP-24_2_FCT],[CWNJ_C02-2F-REL01_1_FCT]'
    # # color_by2 = 'Off'
    color_by1,select_category_l1  = parse_color_by(color_by1)
    color_by2,select_category_l2  = parse_color_by(color_by2)

    if set_bins <=0:
        print('set_bins must be greater than 0!')
        set_bins = 250

    cpk.run(event,one_item_name,all_csv_path,cpk_path,cpk_lsl,cpk_usl,color_by1,select_category_l1,color_by2,select_category_l2,data_select,remove_fail,set_bins,new_x_lsl,new_x_usl,new_y_lsl,new_y_usl,excel_report_item,fail_plot_to_excel,excel_report_user,excel_report_stage,zoom_type,str(project_name))








		
