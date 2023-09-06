% Ergometer_GUI_APP_ver2.m
%  
% 13 July, 2023
%
% 
% The Variables recorded from the "Ergometer_Cal_MVC.m" will be firstly imported. 
% Subject should follow the request on the screen to perform the task. 
% 
% Phase 1: Hold the force (bar) to remain on the green line (threshold).
% Phase 2: Resting state.
% Phase 3: Perform the force (bar) to reach the orange line (MVC) .
% Phase 4: Resting state and be ready for next trial again. 
%
% Triggers:
%     "1" : the onset of MVC measurement.
%     "2" : the offset of MVC measurement.
%     "3" : the onset of a trial (threshold).
%     "4" : the offset of a trial (threshold).
%
% Default parameters:
%     BarWidth           : 100     
%     Threshold_duration : 45s 
%     Rest_duration      : 10s 
%     MVC_duration       : 3s 
%     Ready_duration     : 5s 
%     
%     Threshold          : 20% 
%     Error_acceptance   : 2% 
%     trial_n            : Max 20 trials
%
% OUTPUT:
%     No variables will be saved...
%     Only visual feedback will be needed. 

clear, close all,  clc 
%% Load Participant ID

%Subject_ID = input('Please enter the Subject ID number:','s');              % Creat the file for the subject. 
%mkdir(pwd, Subject_ID);

% lang = input('Please choose the language (fr/eng):','s');                   % Select the preferred language, either "fr" or "eng".
% while sum(strcmp(lang,{'fr','eng'}))==0 ;                                   % If the response doesn't match the answer, it will ask you again.
%     lang = input('There is an error, please choose the language (french/english):','s');
% end;

load ('Variables.mat', 'MVC','Baseline','Lang','Subject_ID');                                                        % the setup variables, MVC values and Baseline values are imported. 
DebugMode = 1;

%% Data aqusition with NI 

d = daq("ni")   ;                                                           % Create DataAcquisition Object
ch=addinput(d,"cDAQ1Mod1","ai23","Voltage");                                % Add channels and set channel properties:'Measurement Type (Voltage)', 
ch.TerminalConfig = "SingleEnded" ;                                         % 'Terminal  Config (SingleEnded)', if any...
%% Creat Parallel port 

t = serialport('COM1',9600) ;
ioObj=io64;%create a parallel port handle
status=io64(ioObj);%if this returns '0' the port driver is loaded & ready
address=hex2dec('03F8') ;

%% Experiment Set-up
PER = 0.7 ;                                                                 % Percentage of the inner screen to be used.
Threshold=0.2;                                                              
Error_acceptance = 0.02;

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
Screen('Preference', 'SkipSyncTests', 1);                                   % You can force Psychtoolbox to continue, despite the severe problems, by adding the command.

if DebugMode % Use this smaller screen for debugging
        [theWindow,screenRect] = Screen('OpenWindow',screenid, black,[500 100 1500 1000],[],2);
else
        [theWindow,screenRect] = Screen('OpenWindow',screenid, black,[],[],2);
        %HideCursor;
end

oldTextSize=Screen('TextSize', theWindow, 30);                              % Costumize the textsize witht the monitor.  

% Screen
scrnWidth   = screenRect(3) - screenRect(1);
scrnHeight  = screenRect(4) - screenRect(2);

% Inner screen
frameWidth=(scrnHeight-PER *scrnHeight)/2; 
InScr=floor([screenRect(1:2)+frameWidth screenRect(3:4)-frameWidth]);
inScrnWidth  = InScr(3)-InScr(1);
inScrnHeight = InScr(4)-InScr(2);

% Extra retangular in the screen
ExtraTop=floor([InScr(1), InScr(2)-35, InScr(3), InScr(2)]);
ExtraBottom=floor([InScr(1), InScr(4), InScr(3), InScr(4)+35]);
ErrorShadow=floor([InScr(1), InScr(4)-(Threshold+Error_acceptance)*inScrnHeight, ...
    InScr(3), InScr(4)-(Threshold-Error_acceptance)*inScrnHeight]);         % Error acceptance area of the threshold line. 

%% Fatigue experiment 

BarWidth        = 100; 
trial_n=40;                                                                  
torque_fatique=[];

% 45s at 30% MVC => 10s rest => 3s MVC => 10s rest
Threshold_duration=45;                                                       % 45s as default. The duration to remain on the threshold. 
Rest_duration=10; 
MVC_duration = 3;
Ready_duration = 5;
bar_position=[];
Bar_RealtimeHeight = inScrnHeight;                                                     % Max=inScrnHeight (MVC)

switch Lang
    case 'eng'
        text1 = ['The experiment will start soon...'];
        text2 = ['Hold the bar on the green line for '];
        text3 = ['Ready for MVC in '];
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
WaitSecs(5);

trialTime=Threshold_duration+Rest_duration+MVC_duration+Rest_duration;      % The duration of one trial. 

% *Cursor
%cursorRect = [0, 0, BarWidth, BarHeight];
% *BAR
%
% (Ax1,Ay1) #__
%           |  |
%           |  |
%           |__# (Ax2, Ay2)
%
Ax1 = scrnWidth/2-BarWidth/2;
Ay1 = InScr(4)-abs(Bar_RealtimeHeight);
Ax2 = scrnWidth/2+BarWidth/2;
Ay2 = InScr(4);
    
start(d,"continuous");
n = ceil(d.Rate/10);

%startTime = GetSecs; 

while trial_n >0; 
    KeyPressFcnTest

    % Phase 1: Hold the force (bar) to remain on the green line (threshold).   
    startTime = GetSecs; 
    if ~DebugMode, io64(ioObj,address,1); end % trigger 1: the onset of the trial. 

    start(d,"continuous");
    while GetSecs < startTime + Threshold_duration;

        % inner screen setup
        Screen('FillRect',theWindow,white,ExtraTop);
        Screen('FillRect',theWindow,red,ExtraBottom);
        Screen('FillRect',theWindow,white,InScr);
        % error zone
        Screen('FillRect',theWindow,grey,ErrorShadow);
       
        % data acqusition
        torque_fatique_data = read(d,n);
        torque_fatique_data.cDAQ1Mod1_ai23 = -((torque_fatique_data.cDAQ1Mod1_ai23-Baseline)*50);
        torque_fatique = [torque_fatique; torque_fatique_data];
        bar_position=[bar_position; mean(torque_fatique_data.Variables)*100/MVC];
        Bar_RealtimeHeight=mean(torque_fatique_data.Variables)*inScrnHeight/MVC;
        Ay1 = InScr(4)-abs(Bar_RealtimeHeight);        
        RectAll = floor([Ax1,Ay1,Ax2,Ay2]);
        cla;

        % realtime bar      
        Screen('FillRect',theWindow,red,RectAll);   
        % threshold line
        Screen('DrawLine',theWindow,green,InScr(1), InScr(4)-Threshold*inScrnHeight, InScr(3), InScr(4)-Threshold*inScrnHeight, 5);
        Threshold_percentage_disp=[num2str(Threshold*100),'% of MVC'];
        DrawFormattedText(theWindow,Threshold_percentage_disp,InScr(1)+10, InScr(4)-Threshold*inScrnHeight+30,black, 255);       

        % Baseline
        Screen('DrawLine',theWindow,black,InScr(1), InScr(4), InScr(3), InScr(4), 5);
        DrawFormattedText(theWindow,'0% of MVC (Baseline)',InScr(1)+10, InScr(4)+30,black, 255);
        Screen(theWindow,'Flip',[],0);  
    end
    stop(d);
    
    if ~DebugMode, io64(ioObj,address,2); end % trigger 2: the offset of the trial. 

    % Phase 2: Resting state.

    Screen('FillRect',theWindow,white,ExtraTop);
    Screen('FillRect',theWindow,white,ExtraBottom);
    Screen('FillRect',theWindow,white,InScr);   
    Screen(theWindow,'Flip',[],0);
    WaitSecs(5);

    startTime = GetSecs; 
    while GetSecs < startTime + Ready_duration
        % inner screen setup
        Screen('FillRect',theWindow,white,ExtraTop);
        Screen('FillRect',theWindow,white,ExtraBottom);
        Screen('FillRect',theWindow,white,InScr);
        % timer
        timer_disp=[num2str(Ready_duration-round(GetSecs-startTime)),'s.'];
        DrawFormattedText(theWindow,[text3 timer_disp],'center','center', black,255);    
        Screen(theWindow,'Flip',[],0);                  
    end
   
    % Phase 3: Perform the force (bar) to reach the orange line (MVC) .
    startTime = GetSecs;
    if ~DebugMode, io64(ioObj,address,3); end % trigger 3: the onset of MVC measurement.

    start(d,"continuous");
    while GetSecs < startTime + MVC_duration
        % inner screen setup
        Screen('FillRect',theWindow,white,ExtraTop);
        Screen('FillRect',theWindow,red,ExtraBottom);
        Screen('FillRect',theWindow,white,InScr);
        %MVC_newtowns_disp=['MVC=',num2str(MVC),' Nm'];
        %DrawFormattedText(theWindow,MVC_newtowns_disp,InScr(3)-300, InScr(2)+50, black,255);
       
        % data acqusition
        torque_fatique_data = read(d,n);
        torque_fatique_data.cDAQ1Mod1_ai23 = -((torque_fatique_data.cDAQ1Mod1_ai23-Baseline)*50);
        torque_fatique = [torque_fatique; torque_fatique_data];
        bar_position=[bar_position; mean(torque_fatique_data.Variables)*100/MVC];
        Bar_RealtimeHeight=mean(torque_fatique_data.Variables)*inScrnHeight/MVC;
        Ay1 = InScr(4)-abs(Bar_RealtimeHeight);        
        RectAll = floor([Ax1,Ay1,Ax2,Ay2]);
        cla;                   
       
        % realtime bar 
        Screen('FillRect',theWindow,red,RectAll);
        % timer
        timer_disp=[num2str(MVC_duration-round(GetSecs-startTime)),'s.'];
        DrawFormattedText(theWindow,[text4 timer_disp],'center','center', black,255);
        % MVC line
        Screen('DrawLine',theWindow,orange,InScr(1), InScr(2), InScr(3), InScr(2), 5);
        DrawFormattedText(theWindow,'100% of MVC',InScr(1)+10, InScr(2)+30,black, 255);
        % Baseline
        Screen('DrawLine',theWindow,black,InScr(1), InScr(4), InScr(3), InScr(4), 5);
        DrawFormattedText(theWindow,'0% of MVC (Baseline)',InScr(1)+10, InScr(4)+30,black, 255);
        Screen(theWindow,'Flip',[],0);        
    end
    stop(d);
    if ~DebugMode, io64(ioObj,address,4);  end % trigger 4: the offset of MVC measurement.

    
    % Phase 4: Resting state and be ready for next trial again. 
    Screen('FillRect',theWindow,white,ExtraTop);
    Screen('FillRect',theWindow,white,ExtraBottom);
    Screen('FillRect',theWindow,white,InScr);
    Screen(theWindow,'Flip',[],0);
    WaitSecs(5);
    
    startTime = GetSecs; 
    while GetSecs < startTime + Ready_duration
        % inner screen setup
        Screen('FillRect',theWindow,white,ExtraTop);
        Screen('FillRect',theWindow,white,ExtraBottom);
        Screen('FillRect',theWindow,white,InScr);
        % timer
        timer_disp=[num2str(Ready_duration-round(GetSecs-startTime)),'s.'];
        DrawFormattedText(theWindow,[text5 timer_disp],'center','center', black,255); 
        Screen(theWindow,'Flip',[],0);                  
    end
    
    trial_n=trial_n-1; 
end

%% Ending
switch lang
    case 'eng'
        text1 = ['The experiment has finished.'];
        text2 = ['Thank you for your paticipation.'];
    case 'fr'
        text1 = ['Préparez-vous à serrer votre main ', Hand, ' le plus fort possible pour ',num2str(trialTime),' secondes'];
        text2 = [];
end

DrawFormattedText(theWindow,text1,'center','center', white,255);
Screen(theWindow,'Flip',[],0);
WaitSecs(2);
DrawFormattedText(theWindow,text2,'center','center', white,255);
Screen(theWindow,'Flip',[],0);
WaitSecs(5);

%%
Screen('CloseAll');
