#! /usr/bin/env python
# coding= utf-8

import time
import os
# current_dir = os.path.dirname(os.path.realpath(__file__))
# print('current_dir--->',current_dir)
# # sys.path.append(current_dir+'/new_env')
# cmd ='export PYTHONPATH='+current_dir+'/new_env/lib/python2.7/site-packages'
# print('cmd--->',cmd)
# os.system(cmd)
#import cpk


if __name__ == '__main__':
#    version = sys.argv[1]
    print('ssssssssssssss')
    test = 'testttttsssssss'
    t0 = time.time()
    python_path =str(os.system('which python3'))
    sys.stdout.write("\rTime: %s" %(t0))
    sys.stdout.flush()

    

    print(test)
    print(t0)




    
   









		
