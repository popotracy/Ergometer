clear, close all,  clc 
KeyPressFcnTest
%%
% load ('Variables.mat', 'MVC','baseline','lang','Subject_ID');     
MVC=184;
baseline=0.26
Subject_ID='Tracy'
DebugMode = 1;
lang='eng'; % If 1,(debug) small screen
%% DAQ 
d = daq("ni");                                                              % Create DataAcquisition Object
ch=addinput(d,"cDAQ1Mod1","ai23","Voltage");                                % Add channels and set channel properties:'Measurement Type (Voltage)', 
ch.TerminalConfig = "SingleEnded";                                          % 'Terminal  Config (SingleEnded)', if any...

%% Create parallel port handle
if DebugMode
t = serial('COM1') ;
ioObj=io64;%create a parallel port handle
status=io64(ioObj);%if this returns '0' the port driver is loaded & ready
address=hex2dec('03F8') ;

fopen(t) ;
end
%% Experiment Set-up
PER = 0.7 ;                                                                 % Percentage of the inner screen to be used.
Threshold=0.1;  
error=0.02;

% other color
green   = [0 255 0];
red     = [255 0 0];
orange  = [255 100 0];
grey    = [200 200 200];
%% Screen set-up

sampleTime      = 1/60;                                                     % screen refresh rate at 60 Hz (always check!!)

Priority(2);                                                                % raise priority for stimulus presentation
screens=Screen('Screens');

screenid=max(screens);
white=WhiteIndex(screenid);                                                 % Find the color values which correspond to white and black: Usually
black=BlackIndex(screenid);                                                 % black is always 0 and white 255, but this rule is not true if one of
                                                                            % the high precision framebuffer modes is enabled via the
                                                                            % PsychImaging() commmand, so we query the true values via the
                                                                            % functions WhiteIndex and BlackIndex
Screen('Preference', 'SkipSyncTests', 1);             
                      % You can force Psychtoolbox to continue, despite the severe problems, by adding the command.

if DebugMode % Use this smaller screen for debugging
        [theWindow,screenRect] = Screen('OpenWindow',screenid, black,[500 100 1500 1000],[],2);
else
        [theWindow,screenRect] = Screen('OpenWindow',screenid, black,[],[],2);
        HideCursor;
end
oldTextSize=Screen('TextSize', theWindow, 30);                              % Costumize the textsize witht the monitor.  

% 
scrnWidth   = screenRect(3) - screenRect(1);
scrnHeight  = screenRect(4) - screenRect(2);

% Inner screen
frameWidth=(scrnHeight-PER *scrnHeight)/2; 
InScr=floor([screenRect(1:2)+frameWidth screenRect(3:4)-frameWidth]);
inScrnWidth  = InScr(3)-InScr(1);
inScrnHeight = InScr(4)-InScr(2);
Block_W=inScrnWidth/4;
Block_H=inScrnHeight/4;
R=Block_H/4;

% Extra retangular
ExtraTop=floor([InScr(1), InScr(2)-R, InScr(3), InScr(2)]);
ExtraBottom=floor([InScr(1), InScr(4), InScr(3), InScr(4)+R]);

%% EEG experiment variables

% max_percentage=0.5;
% Cursor_height=Threshold*inScrnHeight/max_percentage;


% tunnel

% (InScr(1), InScr(2))   #o __ __ __
%                        |     #3___|#4
%                        |    /     |
%           (Axn, Ayn) #1|_#2/      | 
%                        |__ __ __ _#e (InScr(3), InScr(4))
%            

% #1
Ax1 = InScr(1);
Ay1 = InScr(4);
% #2
Ax2 = (InScr(1)*3+ InScr(3))/4;
Ay2 = InScr(4);
% #3
Ax3 = InScr(3)-Block_W/2;
Ay3 = InScr(4)-3*Block_H;
% #4
Ax4 = InScr(3);
Ay4 = InScr(4)-3*Block_H; 

%% Tunnel
torque_eeg=[];
Ball_percentage=[];
trial_n=10;       
KeyPressFcnTest;   


ramping_t=Threshold*2/0.1; % According to reference: 10% for 2s-ramping.
pre_ramping_t=ramping_t/2.75;
velocity=Block_W/pre_ramping_t; 

pre_threshold_t=(inScrnWidth-R)/velocity 
post_threshold_t=60; % Default is 60s.
ready_t=60;
Trial_t=pre_threshold_t+post_threshold_t;


switch lang
    case 'eng'
        text1 = ['The experiment will start soon...'];
        text2 = ['Please maintain the ball in the tunnel by adding the force.']
        text3 = ['Ready...']
        text4 = ['Go! '];
        text5 = ['Ready for the next trial '];
        text6 = ['Press the key "esc" to quit the experiment.'];
    case 'fr'
        text1 = ['Préparez-vous à serrer votre main ', Hand, ' le plus fort possible pour ',num2str(trialTime),' secondes'];
        text2 = [];
        text3 = [];
        text4 = [];
end

% Ready to start...
DrawFormattedText(theWindow,text1,'center','center', white,255);
DrawFormattedText(theWindow, text6,'center',750, white,255); 
Screen(theWindow,'Flip',[],0);                                              % 0:delete previous, 1:keep
WaitSecs(3);
DrawFormattedText(theWindow,text2,'center','center', white,255);
DrawFormattedText(theWindow, text6,'center',750, white,255); 
Screen(theWindow,'Flip',[],0);                                              % 0:delete previous, 1:keep
WaitSecs(3);

while trial_n >0
    Onset_ramping=true;
    Offset_ramping=true;
    
    if DebugMode  io64(ioObj,address,1); pause(0.02); io64(ioObj,address,0); end % trigger 1: the onset of MVC measurement.
    
    startTime = GetSecs; 
    start(d,"continuous");
    n = ceil(d.Rate/10);

    
    while GetSecs <= startTime + Trial_t
        
        if DebugMode
              if GetSecs-startTime>=round(pre_ramping_t,2) && Onset_ramping == true
              io64(ioObj,address,2); pause(0.02); io64(ioObj,address,0);
              Onset_ramping = false ;
              end 
              
              if GetSecs-startTime >=round(pre_threshold_t,2) && Offset_ramping == true
              io64(ioObj,address,2); pause(0.02); io64(ioObj,address,0);
              Offset_ramping = false ;
              end 
        end
        
  

        Screen('FillRect',theWindow,white,InScr);
        Screen('FillRect',theWindow,white,ExtraTop);
        Screen('FillRect',theWindow,white,ExtraBottom);
      
        ratio=(Ay2-Ay3)/(Ax3-Ax2);
        for i=1:1:(Ax2-Ax1), Screen('FillOval', theWindow, red,[(Ax1-(1+error)*R)+i, Ay1-(1+error)*R, (Ax1+(1+error)*R)+i, Ay1+(1+error)*R]);end 
        for i=1:1:(Ax3-Ax2), Screen('FillOval', theWindow, red,[(Ax2-(1+error)*R)+i, (Ay2-(1+error)*R)-i*ratio, (Ax2+(1+error)*R)+i, (Ay2+(1+error)*R)-i*ratio]);end 
        for i=1:1:(Ax4-Ax3), Screen('FillOval', theWindow, red,[(Ax3-(1+error)*R)+i, Ay3-(1+error)*R, (Ax3+(1+error)*R)+i, Ay3+(1+error)*R]);end
       

      % data acqusition
      torque_eeg_data = read(d,n);
      torque_eeg_data.cDAQ1Mod1_ai23 = -((torque_eeg_data.cDAQ1Mod1_ai23-baseline)*50);
      torque_eeg = [torque_eeg; torque_eeg_data];
      Ball_percentage=[Ball_percentage; mean(torque_eeg_data.Variables)*100/MVC];
      
      
      if GetSecs-startTime <=  pre_threshold_t
          percentage_scale=3*Block_H/Threshold;
          %Ball_RealtimeHeight=0.1*percentage_scale;
          Ball_RealtimeHeight=mean(torque_eeg_data.Variables)*percentage_scale/MVC;
          Bx1=(Ax1-R)+velocity*(GetSecs-startTime);
          Bx2=(Ax1+R)+velocity*(GetSecs-startTime);
          By1=(Ay2-R)-abs(Ball_RealtimeHeight);
          By2=(Ay2+R)-abs(Ball_RealtimeHeight);        
      else
          Bx1=(Ax3+Ax4)/2-R;
          Bx2=(Ax3+Ax4)/2+R;
          %Ball_RealtimeHeight=(0.1-0.1)*percentage_scale;
          if mean(torque_eeg_data.Variables)/MVC >= Threshold+error;
          percentage_scale=Block_H/(1-Threshold);
          Ball_RealtimeHeight=(mean(torque_eeg_data.Variables)/MVC-Threshold-error)*percentage_scale; 
          percentage_scale=3*Block_H/Threshold;
          Ball_RealtimeHeight=Ball_RealtimeHeight+(Threshold+error)*percentage_scale
          By1=(Ay4-R)-abs(Ball_RealtimeHeight);
          By2=(Ay4+R)-abs(Ball_RealtimeHeight);  
          else
          percentage_scale=3*Block_H/Threshold;
          Ball_RealtimeHeight=mean(torque_eeg_data.Variables)*percentage_scale/MVC;
          By1=(Ay2-R)-abs(Ball_RealtimeHeight);
          By2=(Ay2+R)-abs(Ball_RealtimeHeight); 
          end
      end     
      Ball=floor([Bx1, By1, Bx2, By2]);
      cla
      
      %realtime ball
      Screen('FillOval', theWindow, black,Ball); 
      if DebugMode
      % timer
      timerdisplay=num2str(round(GetSecs-startTime,1));
      DrawFormattedText(theWindow,timerdisplay,'center','center', black,255); 
      %DrawFormattedText(theWindow,'0%',Ax1+20,Ay2-50, black,255);
      Threshold_display=[num2str(Threshold*100) '%'];
      DrawFormattedText(theWindow,Threshold_display,Ax1+20,Ay3+20, black,255); 
      end 
      
      Screen('DrawLine',theWindow,grey,Ax1, Ay1, Ax2, Ay2,5);
      Screen('DrawLine',theWindow,grey,Ax2, Ay2, Ax3, Ay3 ,5);    
      Screen('DrawLine',theWindow,grey,Ax3, Ay3, Ax4, Ay4 ,5);
      Screen(theWindow,'Flip',[],0);
    
    end
    
    stop(d);
    if DebugMode  io64(ioObj,address,4); pause(0.02); io64(ioObj,address,0); end % trigger 1: the onset of MVC measurement.
    
    Screen('FillRect',theWindow,white,ExtraTop);
    Screen('FillRect',theWindow,white,ExtraBottom);
    Screen('FillRect',theWindow,white,InScr);
    Screen(theWindow,'Flip',[],0);
    WaitSecs(5);
    
    startTime = GetSecs; 
    while GetSecs < startTime + ready_t
        % inner screen setup
        Screen('FillRect',theWindow,white,ExtraTop);
        Screen('FillRect',theWindow,white,ExtraBottom);
        Screen('FillRect',theWindow,white,InScr);
        % timer
        timer_disp=[num2str(ready_t-round(GetSecs-startTime)),'s.'];
        DrawFormattedText(theWindow,[text5 timer_disp],'center','center', black,255); 
        Screen(theWindow,'Flip',[],0);                  
    end

    trial_n=trial_n-1;
    startTime = GetSecs; 

end 



%%
DrawFormattedText(theWindow,'Thank you for your participation.','center','center', white,255);
Screen(theWindow,'Flip',[],0);                                              % 0:delete previous, 1:keep
WaitSecs(5);


if DebugMode 
fclose(t) ;
end 
Screen('CloseAll');