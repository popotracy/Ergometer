%%
clear, close all,  clc 

%d = daq("ni");
%ch=addinput(d,"cDAQ1Mod1","ai23","Voltage");
%ch.TerminalConfig = "SingleEnded";
%%
Subject_ID = input('Please enter the Subject ID number:','s');
lang='english';
Hand='right';
DebugMode = 1 ;

%lang = input('Please choose the language (fr/eng):','s');
%while sum(strcmp(lang,{'fr','eng'}))==0 ;
    %lang = input('There is an error, please choose the language (fr/eng):','s');
%end;

%hand = input ('Please select the side of the hand (left/right):','s');
%while sum(strcmp(hand,{'left','right'}))==0 ;
    %hand = input('There is an error, please select the side of the hand (left/right):','s');
%end;


%%
sampleTime      = 1/60; % screen refresh rate at 60 Hz (always check!!)
BarWidth        = 100; 
Bar_RealtimeHeight = 0; % Max=inScrnHeight
Threshold=0.4;

PER = 0.7 ; % Percentage of the screen to be used

green   = [0 255 0];
red     = [255 0 0];
orange  = [255 100 0];
grey    = [200 200 200];
%%
Priority(2);% raise priority for stimulus presentation
screens=Screen('Screens');
screenid=max(screens);
white=WhiteIndex(screenid);
black=BlackIndex(screenid);

Screen('Preference', 'SkipSyncTests', 1);
[theWindow,screenRect] = Screen('OpenWindow',screenid, black,[500 100 1500 1000],[],2); % Use this smaller screen for debugging
%[theWindow,screenRect] = Screen('OpenWindow',screenid, black,[200 100 1600 1200],[],2); % Use this smaller screen for debugging

oldTextSize=Screen('TextSize', theWindow, 30);

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

%% Calibration 

Calibration_duration = 10;
torque_cal=[];
%n = ceil(d.Rate/10);
t = tic;

switch lang
        case 'english'
            text1 = ['Please relax your ', Hand,' hand on the ergometer '];
        case 'french'
            text1 = ['Préparez-vous à serrer votre main ', Hand, ' le plus fort possible pour ',num2str(trialTime),' secondes'];
end


startTime = GetSecs; 
        if ~DebugMode, fprintf('on'); pause(0.002); fprintf('off'); end

while GetSecs < startTime + Calibration_duration

    Cal_disp=[num2str(round(GetSecs-startTime)),'s']
    DrawFormattedText(theWindow,'Calibration','center',300,255);
    DrawFormattedText(theWindow,text1,'center',400,255);
    DrawFormattedText(theWindow,Cal_disp,'center','center', white,255);
    Screen(theWindow,'Flip',[],0);

end ;

DrawFormattedText(theWindow,'Calibration is done','center','center', white,255);
Screen(theWindow,'Flip',[],0); 

%% MVC measurement 

% MVC_duration = 3;
% Ready_duration = 5;
% Rest_duration = 10;
% MVC_measurement_n=1;
% 
% switch lang
%     case 'english'
%         text1 = ['Ready for the MVC in '];
%         text2 = ['Go!'];
%         text3 = ['Good job! Rest for...'];
%         text4 = ['MVC measurement is done.'];
%     case 'french'
%         text1 = ['Préparez-vous à serrer votre main ', Hand, ' le plus fort possible pour 3 seconds'];
% end
% 
%   
% while MVC_measurement_n>0;
% startTime = GetSecs; 
%     while GetSecs < startTime + Ready_duration;
%         MVC_disp=[num2str(Ready_duration-round(GetSecs-startTime)),'s']
%         DrawFormattedText(theWindow,[text1 MVC_disp],'center','center',255);
%         Screen(theWindow,'Flip',[],0);  % 0:delete previous, 1:keep
%     end ;
%     
%         startTime = GetSecs; 
%     while GetSecs < startTime + MVC_duration
%         MVC_disp=[num2str(round(GetSecs-startTime)),'s']
%         DrawFormattedText(theWindow,text2,'center',400,255);
%         DrawFormattedText(theWindow,MVC_disp,'center','center', white,255);
%         Screen(theWindow,'Flip',[],0);  % 0:delete previous, 1:keep
%     end ;
%         startTime = GetSecs; 
%     while GetSecs < startTime + Rest_duration
%             MVC_disp=[num2str(Rest_duration-round(GetSecs-startTime)),'s'];
%             DrawFormattedText(theWindow,[text3 MVC_disp],'center','center', white,255);
%             Screen(theWindow,'Flip',[],0);  % 0:delete previous, 1:keep   
%     end ;
%     MVC_measurement_n=MVC_measurement_n-1;
% end 
% 
% DrawFormattedText(theWindow,text4,'center','center', white,255);
% Screen(theWindow,'Flip',[],0);  % 0:delete previous, 1:keep
% WaitSecs(2);
% 
% %% Fatigue experiment 
% 
% Threshold_duration=5;
% Rest_duration=10;
% MVC_duration = 3;
% Ready_duration = 5;
% MVC=208;
% 
% 
% phase1=Threshold_duration;
% phase2=Threshold_duration+Rest_duration;
% phase3=Threshold_duration+Rest_duration+MVC_duration;
% phase4=Threshold_duration+Rest_duration+MVC_duration+Rest_duration;
% 
% 
% switch lang
%         case 'english'
%             text1 = ['The experiment will start soon...'];
%             text2 = ['Hold the bar on the green line for '];
%             text3 = ['Ready for MVC in '];
%             text4 = ['Go! '];
%             text5 = ['Ready for next trial '];
%         case 'french'
%             text1 = ['Préparez-vous à serrer votre main ', Hand, ' le plus fort possible pour ',num2str(trialTime),' secondes'];
% end
% 
% 
% DrawFormattedText(theWindow,text1,'center','center', white,255);
% Screen(theWindow,'Flip',[],0);  % 0:delete previous, 1:keep
% WaitSecs(2);
% 
% trialTime=phase4;
% trial_n=1;
% torque_fatique=[];
% %n = ceil(d.Rate/10);
% %t = tic;
% baseline=0.6428;
% 
% bar_position=[];
% Bar_RealtimeHeight=0;
% 
% 
%     % *Cursor
%     %cursorRect = [0, 0, BarWidth, BarHeight];
%     % *BAR
%     %
%     % (Ax1,Ay1) #__
%     %           |  |
%     %           |  |
%     %           |__# (Ax2, Ay2)
%     %
%     Ax1 = scrnWidth/2-BarWidth/2;
%     Ay1 = InScr(4)-abs(Bar_RealtimeHeight);
%     Ax2 = scrnWidth/2+BarWidth/2;
%     Ay2 = InScr(4);
%     
% % start(d,"continuous");
% 
% startTime = GetSecs; 
% 
% while trial_n >0;   
% while GetSecs < startTime + Threshold_duration;
%         
%     RectAll = floor([Ax1,Ay1,Ax2,Ay2]);
% 
%     Screen('FillRect',theWindow,white,InScr);
%     Screen('DrawLine',theWindow,green,InScr(1), InScr(4)-Threshold*inScrnHeight, InScr(3), InScr(4)-Threshold*inScrnHeight, 5);
%     Threshold_percentage_disp=[num2str(Threshold*100),'% of MVC']
%     DrawFormattedText(theWindow,Threshold_percentage_disp,InScr(1)+10, InScr(4)-Threshold*inScrnHeight+50,black, 255);
% 
%     %torque_fatique_data = read(d,n);
%     %torque_fatique_data.cDAQ1Mod1_ai23 = -((torque_fatique_data.cDAQ1Mod1_ai23-baseline)*50);
% 
%     %torque_fatique = [torque_fatique; torque_fatique_data];
%     %bar_position=[bar_position; mean(torque_fatique_data.Variables)*100/MVC];
%     %Bar_RealtimeHeight=mean(torque_fatique_data.Variables)*inScrnHeight/MVC;
% 
%     %Ay1 = InScr(4)-abs(Bar_RealtimeHeight);
%     %cla;
% 
% 
%     %Plot MVC cursor and threshold. 
% 
%     
%     %round(GetSecs-startTime) <= phase1;
%      
%      Screen('FillRect',theWindow,red,RectAll);     
%      timer_disp=[num2str(phase1-round(GetSecs-startTime)),'s.']
%      DrawFormattedText(theWindow,[text2, timer_disp],'center',InScr(4)-Threshold*inScrnHeight-50, black,255);
%      Screen(theWindow,'Flip',[],0);
% end
% 
% Screen('FillRect',theWindow,white,InScr);
% Screen(theWindow,'Flip',[],0);
% WaitSecs(5);
% 
% 
% startTime = GetSecs; 
% while GetSecs < startTime + Ready_duration;
%         Screen('FillRect',theWindow,white,InScr);
%         timer_disp=[num2str(Ready_duration-round(GetSecs-startTime)),'s.']
%         DrawFormattedText(theWindow,[text3 timer_disp],'center','center', black,255);
%         Screen(theWindow,'Flip',[],0);                  
% end
% 
% startTime = GetSecs;
% while GetSecs < startTime + MVC_duration;
%        Screen('FillRect',theWindow,white,InScr);
%        Screen('DrawLine',theWindow,orange,InScr(1), InScr(2), InScr(3), InScr(2), 5);
%        MVC_percentage_disp=[num2str(100),'%'];
%        DrawFormattedText(theWindow,MVC_percentage_disp,InScr(1)+10, InScr(2)+50,black, 255);
%        %MVC_newtowns_disp=['MVC=',num2str(MVC),' Nm'];
%        %DrawFormattedText(theWindow,MVC_newtowns_disp,InScr(3)-300, InScr(2)+50, black,255);
%        timer_disp=[num2str(MVC_duration-round(GetSecs-startTime)),'s.']
%        DrawFormattedText(theWindow,[text4 timer_disp],'center','center', black,255);
%        Screen(theWindow,'Flip',[],0);                  
% 
% end
% 
% Screen('FillRect',theWindow,white,InScr);
% Screen(theWindow,'Flip',[],0);
% WaitSecs(5);
% 
% startTime = GetSecs; 
% while GetSecs < startTime + Ready_duration;
%         Screen('FillRect',theWindow,white,InScr);
%         timer_disp=[num2str(Ready_duration-round(GetSecs-startTime)),'s.']
%         DrawFormattedText(theWindow,[text5 timer_disp],'center','center', black,255);
%         Screen(theWindow,'Flip',[],0);                  
% 
% end
% trial_n=trial_n-1; startTime = GetSecs; 
% end
% 
% %% Ending
% 
% switch lang
%         case 'english'
%             text1 = ['The experiment has finished.'];
%             text2 = ['Thank you for your patiticipation.']
%         case 'french'
%             text1 = ['Préparez-vous à serrer votre main ', Hand, ' le plus fort possible pour ',num2str(trialTime),' secondes'];
% end
% 
% DrawFormattedText(theWindow,text1,'center','center', white,255);
% Screen(theWindow,'Flip',[],0);
% WaitSecs(2);
% DrawFormattedText(theWindow,text2,'center','center', white,255);
% Screen(theWindow,'Flip',[],0);
% WaitSecs(5);

%%
Screen('CloseAll');

%% EEG experiment variables

%Screen('FillRect',theWindow,white,InScr);
%Screen('FillRect',theWindow,white,ExtraTop);
%Screen('FillRect',theWindow,white,ExtraBottom);

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

%start(d,"continuous");
%n = ceil(d.Rate/100);
MVC=5000;
torque_fatique=[];
ball_position=[];
R=35;
Ball_percentage=0;
%Ball_RealtimePercentage=0.3;
Ramping_duration=Threshold*20; % According to reference: 10% for 2s-ramping.
Threshold_duration=30;

Velocity1=((InScr(3)-InScr(1))/2)/Ramping_duration;  
Velocity2=((InScr(3)-InScr(1))/4)/Threshold_duration;  


startTime = GetSecs; 
Trial_duration=42;

while GetSecs <= startTime + Trial_duration;
    Screen('FillRect',theWindow,white,InScr);
    Screen('FillRect',theWindow,white,ExtraTop);
    Screen('FillRect',theWindow,white,ExtraBottom);

    % Screen('DrawLine',theWindow,orange,(InScr(1)*3+InScr(3))/4, InScr(2), (InScr(1)*3+InScr(3))/4, InScr(4),5);
    % Screen('DrawLine',theWindow,orange,(InScr(1)+InScr(3))/2, InScr(2), (InScr(1)+InScr(3))/2, InScr(4),5);
    % Screen('DrawLine',theWindow,orange,(InScr(1)+InScr(3)*3)/4, InScr(2), (InScr(1)+InScr(3)*3)/4, InScr(4),5);
    ratio=(Ay2-Ay3)/(Ax3-Ax2);
    
    for i=1:1:(Ax2-Ax1);
        Screen('FillOval', theWindow, red,[(Ax1-R)+i, Ay1-R, (Ax1+R)+i, Ay1+R]);
    end;
    
    for i=1:1:(Ax3-Ax2);
    Screen('FillOval', theWindow, red,[(Ax2-R)+i, (Ay2-R)-i*ratio, (Ax2+R)+i, (Ay2+R)-i*ratio]);
    end;
    
    for i=1:1:(Ax4-Ax3);
    Screen('FillOval', theWindow, red,[(Ax3-R)+i, Ay3-R, (Ax3+R)+i, Ay3+R]);
    end;
    
    % timer
    timerdisplay=[num2str(round(GetSecs-startTime))]
    DrawFormattedText(theWindow,timerdisplay,'center','center', black,255);   
    
            By1=(Ay1-R)-Ball_percentage*2*inScrnHeight;
            By2=(Ay1+R)-Ball_percentage*2*inScrnHeight;
    
    if GetSecs-startTime <=1.5*Ramping_duration;
        %Bx1 = (Ball_RealtimePercentage/Threshold)*Ax3+ (1-Ball_RealtimePercentage/Threshold)*Ax2;
        %By1 = (Ball_RealtimePercentage/Threshold)*Ay3+ (1-Ball_RealtimePercentage/Threshold)*Ay2;
        
        Bx1=(Ax1-R)+Velocity1*(GetSecs-startTime);
        Bx2=(Ax1+R)+Velocity1*(GetSecs-startTime);      
  
    else
        Bx1=(Ax3-R)+Velocity2*(GetSecs-startTime-Ramping_duration);
        Bx2=(Ax3+R)+Velocity2*(GetSecs-startTime-Ramping_duration);
                
    end
    
    Screen('DrawLine',theWindow,grey,Ax1, Ay1, Ax2, Ay2,5);
    Screen('DrawLine',theWindow,grey,Ax2, Ay2, Ax3, Ay3 ,5);    
    Screen('DrawLine',theWindow,grey,Ax3, Ay3, Ax4, Ay4 ,5);
    
    Ball=[Bx1, By1, Bx2, By2];
    Screen('FillOval', theWindow, black,Ball);
    DrawFormattedText(theWindow,'0%',Ax1+20,Ay2-50, black,255);
    Threshold_display=[num2str(Threshold*100) '%'];
    DrawFormattedText(theWindow,Threshold_display,Ax1+20,Ay3+20, black,255); 
    Screen(theWindow,'Flip',[],0);
    
end
