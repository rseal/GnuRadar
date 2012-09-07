#!/usr/bin/env python2

import argparse
import sys

for arg in sys.argv:

   fid = open(arg,'r')
   lines = fid.readlines()
   fid.close()

   brackets=0
   for line in lines:
      for c in line:
         if c=='{': 
            brackets+=1
         elif c=='}':
            brackets-=1

   print('%s bracket balance = %d'%(arg,brackets))

