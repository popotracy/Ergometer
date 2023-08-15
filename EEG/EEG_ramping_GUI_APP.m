clear, close all   clc 
%%
load ('Variables.mat', 'MVC','baseline','lang','Subject_ID');     

%%
d = daq("ni");                                                              % Create DataAcquisition Object
ch=addinput(d,"cDAQ1Mod1","ai23","Voltage");                                % Add channels and set channel properties:'Measurement Type (Voltage)', 
ch.TerminalConfig = "SingleEnded";                                          % 'Terminal  Config (SingleEnded)', if any...

%% Experiment Set-up
PER = 0.7 ;                                                                 % Percentage of the inner screen to be used.
Threshold=0.3;                                                              

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

%[theWindow,screenRect] = Screen('OpenWindow',screenid, black, [],[],2); 
% Uncomment it to Use this smaller screen for debugging.
[theWindow,screenRect] = Screen('OpenWindow',screenid, black,[500 100 1500 1000],[],2);  
oldTextSize=Screen('TextSize', theWindow, 30);                              % Costumize the textsize witht the monitor.  

% 
scrnWidth   = screenRect(3) - screenRect(1);
scrnHeight  = screenRect(4) - screenRect(2);

% Inner screen
frameWidth=(scrnHeight-PER *scrnHeight)/2; 
InScr=floor([screenRect(1:2)+frameWidth screenRect(3:4)-frameWidth]);
inScrnWidth  = InScr(3)-InScr(1);
inScrnHeight = InScr(4)-InScr(2);

% Extra retangular
ExtraTop=floor([InScr(1), InScr(2)-35, InScr(3), InScr(2)]);
ExtraBottom=floor([InScr(1), InScr(4), InScr(3), InScr(4)+35]);

%% EEG experiment variables

max_percentage=0.5;
Cursor_height=Threshold*inScrnHeight/max_percentage;
r=35;

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
Ax3 = (InScr(1)+ InScr(3)*3)/4;
Ay3 = InScr(4)-Cursor_height; % Variable
% #4
Ax4 = InScr(3);
Ay4 = InScr(4)-Cursor_height; % Variable 

%% Tunnel
torque_eeg=[];
Ball_percentage=[];
R=35;

Ramping_duration=Threshold*20; % According to reference: 10% for 2s-ramping.
Threshold_duration=30;

Velocity1=((InScr(3)-InScr(1))/2)/Ramping_duration;  
Velocity2=((InScr(3)-InScr(1))/4)/Threshold_duration;  

start(d,"continuous");
n = ceil(d.Rate/10);

startTime = GetSecs; 
Trial_duration=39;

while GetSecs <= startTime + Trial_duration
     
    Screen('FillRect',theWindow,white,InScr);
    Screen('FillRect',theWindow,white,ExtraTop);
    Screen('FillRect',theWindow,white,ExtraBottom);

    ratio=(Ay2-Ay3)/(Ax3-Ax2);
    for i=1:1:(Ax2-Ax1)
        Screen('FillOval', theWindow, red,[(Ax1-R)+i, Ay1-R, (Ax1+R)+i, Ay1+R]);
    end
    
    for i=1:1:(Ax3-Ax2)
        Screen('FillOval', theWindow, red,[(Ax2-R)+i, (Ay2-R)-i*ratio, (Ax2+R)+i, (Ay2+R)-i*ratio]);
    end
    
    for i=1:1:(Ax4-Ax3)
        Screen('FillOval', theWindow, red,[(Ax3-R)+i, Ay3-R, (Ax3+R)+i, Ay3+R]);
    end

    % data acqusition
    torque_eeg_data = read(d,n);
    torque_eeg_data.cDAQ1Mod1_ai23 = -((torque_eeg_data.cDAQ1Mod1_ai23-baseline)*50);
    torque_eeg = [torque_eeg; torque_eeg_data];
    Ball_percentage=[Ball_percentage; mean(torque_eeg_data.Variables)*100/MVC];
    Ball_RealtimeHeight=mean(torque_eeg_data.Variables)*2*inScrnHeight/MVC;
    
    if GetSecs-startTime <=1.5*Ramping_duration
    Bx1=(Ax1-R)+Velocity1*(GetSecs-startTime);
    Bx2=(Ax1+R)+Velocity1*(GetSecs-startTime); 
    else
    Bx1=(Ax3-R)+Velocity2*(GetSecs-startTime-Ramping_duration);
    Bx2=(Ax3+R)+Velocity2*(GetSecs-startTime-Ramping_duration);
    end 

    By1=(Ay1-R)-abs(Ball_RealtimeHeight);
    By2=(Ay1+R)-abs(Ball_RealtimeHeight); 
    Ball=floor([Bx1, By1, Bx2, By2]);
    cla

    %realtime ball
    Screen('FillOval', theWindow, black,Ball); 
    % timer
    timerdisplay=num2str(round(GetSecs-startTime));
    DrawFormattedText(theWindow,timerdisplay,'center','center', black,255);  
 
    DrawFormattedText(theWindow,'0%',Ax1+20,Ay2-50, black,255);
    Threshold_display=[num2str(Threshold*100) '%'];
    DrawFormattedText(theWindow,Threshold_display,Ax1+20,Ay3+20, black,255); 

    Screen('DrawLine',theWindow,grey,Ax1, Ay1, Ax2, Ay2,5);
    Screen('DrawLine',theWindow,grey,Ax2, Ay2, Ax3, Ay3 ,5);    
    Screen('DrawLine',theWindow,grey,Ax3, Ay3, Ax4, Ay4 ,5);
    Screen(theWindow,'Flip',[],0);
end

stop(d);

%%
Screen('CloseAll');