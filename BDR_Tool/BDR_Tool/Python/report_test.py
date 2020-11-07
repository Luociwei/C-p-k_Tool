# coding=utf-8

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

r = redis.Redis(host='localhost', port=6379, db=0)

context = zmq.Context()
socket = context.socket(zmq.REP)
socket.bind("tcp://127.0.0.1:3130")

def correlation(message):
    print("this function is generate correlation plot......")
    val = r.get(message)
    # time.sleep(5)  #测试python 执行时间 5s
    if val:
        return val
    else:
        return b'None'
        

def run(n):
    while True:
        try:
            print("wait for correlation client ...")
            message = socket.recv()
            print("message from client:", message.decode('utf-8'))
            ret = correlation(message)
            socket.send(ret.decode('utf-8').encode('ascii'))    # socket.send(b"correlation finished")
        except Exception as e:
            print('error:',e)

if __name__ == '__main__':
    t1 = threading.Thread(target=run, args=("<<correlation>>",))
    t1.start()
    
