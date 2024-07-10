% This file is part of spintach, a tachometer/frequency meter using ATtiny2313A
% Copyright (c) 2024 - Franco Sauvisky
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.

% Script for plotting rotation speed over time using serial comm

pkg load instrument-control

s = serialport('/dev/ttyUSB1',"BaudRate",38400,"Timeout",1);

flush(s);
buffer = [];
i=0;

while true
    data = read(s,2);
    if isempty(data)
        i = i + 1;
        if(i==5)
            break;
        endif
    else
        i = 0;
        buffer = [buffer uint16(data(1))*2^8+uint16(data(2))];
    endif
endwhile

dts = [];
timex = [0];
for i = 1:(length(buffer)-1)
    a = buffer(i);
    b = buffer(i+1);
    if(b > a)
        dt = b - a;
    else
        dt = uint32(b) + 2^16 - uint32(a);
    endif
    dts = [dts dt];
    timex = [timex uint32(timex(end))+uint32(dt)];
endfor

timex(dts<5000) = [];
dts(dts<5000) = [];
timex = double(timex);
dts = double(dts);
dts = (dts(1:(end-1))+dts(2:end))/2;

plot(double(timex(3:end))/512e3,15360000./double(dts),'marker','.');
grid on
grid minor
xlabel "Tempo (s)"
ylabel "Velocidade (RPM)"