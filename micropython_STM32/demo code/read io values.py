# main.py -- put your code here!

from pyb import Pin

p_out = Pin('B0',Pin.OUT_PP)
p_out.high()
p_out.low()

p_in = Pin('B3',Pin.PULL_UP)
value = p_in.value()
print(value)
