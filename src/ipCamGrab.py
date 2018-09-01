'''
Created on Jul 31, 2014

@author: BOIRUM
'''

import cv2
import urllib 
import numpy as np
import time
import os

stream_url = "192.168.1.3"
bytes=''
ii=142
dt = 5 #

rawImDir = r'C:\Users\BOIRUM\Desktop\Distorted'
while True:
    stream=urllib.urlopen('http://192.168.1.3/axis-cgi/jpg/image.cgi?resolution=640x480')
    while True:
        #print 'reading stream'
        bytes+=stream.read(1024)
        a = bytes.find('\xff\xd8')
        b = bytes.find('\xff\xd9')
        if a!=-1 and b!=-1:
            jpg = bytes[a:b+2]
            bytes= bytes[b+2:]
            
            i = cv2.imdecode(np.fromstring(jpg, dtype=np.uint8),cv2.CV_LOAD_IMAGE_COLOR)
            #cv2.imshow('i',i)
            if cv2.waitKey(1) ==27:
                exit(0)   
            ii+=1
            cx = 324.6482
            cy = 232.9243
            fx = 265.6509
            fy = 265.7165
            cameraMatrix = np.array([[fx, 0, cx],
                                     [0, fy, cy],
                                     [0, 0, 1]                                     
                                     ])
            distCoeffs = np.array([0.0126, -0.0108, 0.0090, -0.0031])
            distCoeffs = np.array([0.0126, -0.108, 0.090, -0.031])
            #undistorted = cv2.undistort(i, cameraMatrix, distCoeffs)
            cv2.imwrite(os.path.join(rawImDir,'image%d.jpg'%ii), i)
            #cv2.imshow('undistorted',undistorted)
            #cv2.imshow('original',i)
            print"image%s saved"%ii
            time.sleep(dt)
            break