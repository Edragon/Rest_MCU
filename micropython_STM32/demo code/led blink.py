# main.py -- put your code here!

import pyb

led = pyb.LED(3)
while True:
   led.toggle()
   pyb.delay(1000)
