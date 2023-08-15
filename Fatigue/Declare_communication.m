% Declare_communication

% d  = daq.getDevices ;
% s = daq.createSession('dt') ;
% s.Rate = 1000 ;
% % s.ScansAcquired = 10 ;
% s.DurationInSeconds = 5 ;
% %s.IsContinuous = true ;
% 
% addAnalogInputChannel(s,'DT3034(01)','0','Voltage') ;
% addAnalogInputChannel(s,'DT3034(01)','1','Voltage') ;
% addAnalogInputChannel(s,'DT3034(01)','2','Voltage') ;
% addAnalogInputChannel(s,'DT3034(01)','3','Voltage') ;
% addAnalogInputChannel(s,'DT3034(01)','4','Voltage') ;
% addAnalogInputChannel(s,'DT3034(01)','5','Voltage') ;

t = serial('COM1') ;
ioObj=io64;%create a parallel port handle
status=io64(ioObj);%if this returns '0' the port driver is loaded & ready
address=hex2dec('D000') ;

fopen(t) ;
% fclose(t) ; clear ; clc
