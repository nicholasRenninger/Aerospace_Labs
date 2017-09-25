% Lab 6: Robot Arm
% Author: Luke Tafur
% Date Created: 4.25.17
% Date Edited: 5.2.17

clear all; close all;

%declare directory and extract for flexible
gainzFlex = dir('../../Data/Real Data/flex*');
for i = 1:10
    dataFlex{i} = load(sprintf('%s/%s', gainzFlex(i).folder, gainzFlex(i).name));
end

%declare directory and extract for rigid
gainzRigid = dir('../../Data/Real Data/rigid*');
for i = 1:10
    dataRigid{i} = load(sprintf('%s/%s', gainzRigid(i).folder, gainzRigid(i).name));
end

%declare names
name = {'Flexible' 'Rigid'};

%% Flexible
for j = 1:10
    l = 1;
    Kp = [15];
    Kd = [4];
    
    %split up data
    time = dataFlex{j}(:,1);
    hubAngle = dataFlex{j}(:,2);
    tipDeflection = dataFlex{j}(:,3);
    hubAngularVelocity = dataFlex{j}(:,4);
    tipVelocity = dataFlex{j}(:,5);
    positionReference = dataFlex{j}(:,6);
    outputVoltage = dataFlex{j}(:,7);
    K1 = dataFlex{j}(:,8);
    K2 = dataFlex{j}(:,9);
    K3 = dataFlex{j}(:,10);
    K4 = dataFlex{j}(:,11);
    
    a=0;
    
    for k = 1:length(hubAngle)-1000
        if (abs(hubAngle(k+1000) - hubAngle(k+999)) > 0.002) && a==0
            timeStart = k+1000;
            a = 1;
        end
    end
    %% plot time versus theta
    figure(j)
    actual = plot((time(timeStart:end)-time(timeStart))/1000,hubAngle(timeStart:end),'Color',[0 0 0]);
    hold on
    
    %define thetad
    if j == 2
        thetad = 0.6;
    else
        thetad = 0.3;
    end
    temp = hubAngle(timeStart+500:end);
    reach5per = find(abs(temp) > thetad*0.95)+timeStart+500;
    if ~isempty(reach5per)
        reach5per = reach5per(1);
        timeTaken = time(reach5per(1)) - time(timeStart);
        fprintf('Time to get within 5%% for flexible test %i is %1.3f seconds with K1 = %1.2f K2 = %1.2f K3 = %1.2f K4 = %1.2f \n',j,(time(reach5per)-time(timeStart))/1000,K1(1),K2(1),K3(1),K4(1))
        
        %plots data lines
        start = plot([(time(reach5per)-time(timeStart))/1000 (time(reach5per)-time(timeStart))/1000],[thetad*1.5 -thetad*1.5],'Color',[1 0 0]);
        sec1 = plot([1 1],[thetad*1.5 -thetad*1.5],'Color',[0 0 1]);
        td = plot(linspace(0,time(end)/1000,1000),linspace(thetad,thetad,1000),'Color',[0 1 0]);
        plot(linspace(0,time(end)/1000,1000),linspace(-thetad,-thetad,1000),'Color',[0 1 0])
        
        %label and define limits
        xlabel('Time [s]')
        ylabel('Angle [rads]')
        
        if (timeStart + 2000) < length(time)
            xend = 2;
        else
            xend = 1;
        end
        xlim([0 xend])
        ylim([thetad*-1.5 thetad*1.5])        
        title(sprintf('Time vs Angle of Test %i for %s',j,name{l}))
        %% plot time versus tip delfection
        figure(j+10)
        actualtip = plot((time(timeStart:end)-time(timeStart))/1000,tipDeflection(timeStart:end)-tipDeflection(timeStart),'Color',[0 0 0]);
        hold on
        
        boundsTip = plot(linspace(0,xend,1000),linspace(.05,.05,1000),'Color',[0 1 0]);
        plot(linspace(0,xend,1000),linspace(-.05,-.05,1000),'Color',[0 1 0])
        sec12 = plot([1 1],[-.06 .06],'Color',[0 0 1]);
        
        xlabel('Time [ms]')
        ylabel('Tip Deflection [m]')
        xlim([0 xend])
        ylim([-.06 .06])
        title(sprintf('Time vs Tip Deflection of Test %i for %s',j,name{l}))
        %% kill plots that don't make the cut
        if time(reach5per) > time(timeStart+1000)
            close(j)
            close(j+10)
        else
            figure(j)
            hold on
            theo = plotTheoretical(thetad,Kp(1),Kd(1),K1(1),K2(1),K3(1),K4(1),3,j,time(timeStart),hubAngle(timeStart));
            legend([actual theo td start sec1],'Actual','Theoretical','Desired Theta','Within 5%','1 second')
            %% label gainz on graph
            annotation('textbox',...
                [0.675 0.46 .18 0.22],...
                'String',{['K1 = ' num2str(K1(1))] ['K2 = ' num2str(K2(1))] ['K3 = ' num2str(K3(1))] ['K4 = ' num2str(K4(1))] ['Thetad = ' num2str(thetad)]},...
                'FontSize',10,...
                'EdgeColor',[0 0 0],...
                'LineWidth',.01,...
                'BackgroundColor',[1 1 1],...
                'Color',[0 0 0]);
            figure(j+10)
            hold on
            theo2 = plotTheoretical(thetad,Kp(1),Kd(1),K1(1),K2(1),K3(1),K4(1),4,j,time(timeStart),hubAngle(timeStart));
            legend([actualtip theo2 boundsTip sec12],'Actual','Theoretical','Maximum Tip Deflection','1 second')
            fprintf('Sick Werking Gainz to get Swole for trial %i are K1 = %1.1f K2 = %1.1f K3 = %1.1f K4 = %1.1f\n',j,K1(1),K2(1),K3(1),K4(1));
        end
    else
        fprintf('Redefine upper limits somehow plz for plots for trial %i\n',j)
        close(j)
    end
end

%% Rigid
for j = 1:10
    l = 2;
    
    %split up data
    time = dataRigid{j}(:,1);
    hubAngle = dataRigid{j}(:,2);
    tipDeflection = dataRigid{j}(:,3);
    hubAngularVelocity = dataRigid{j}(:,4);
    tipVelocity = dataRigid{j}(:,5);
    positionReference = dataRigid{j}(:,6);
    outputVoltage = dataRigid{j}(:,7);
    K1 = dataRigid{j}(:,8);
    K2 = dataRigid{j}(:,9);
    K3 = dataRigid{j}(:,10);
    K4 = dataRigid{j}(:,11);
    Kp = K1;
    Kd = K3;
    
    a=0;
    if j ~= 9
        for k = 1:length(hubAngle)-1
            if (abs(hubAngle(k+1) - hubAngle(k)) > 0.002) && a==0
                timeStart = k;
                a = 1;
            end
        end
    else
        for k = 1:length(hubAngle)-101
            if (abs(hubAngle(k+101) - hubAngle(k+100)) > 0.002) && a==0
                timeStart = k+100;
                a = 1;
            end
        end
    end
    %% plot time versus theta
    figure(j+20)
    actual = plot((time(timeStart:timeStart+1000)-time(timeStart))/1000,hubAngle(timeStart:timeStart+1000),'Color',[0 0 0]);
    hold on
    
    %define thetad    
    thetad = 0.3;
    
    %find when within 5%
    temp = hubAngle(timeStart+100:end);
    reach5per = find(abs(temp) > thetad*0.95)+timeStart+100;
    xend = 0.6;
    if ~isempty(reach5per)
        reach5per = reach5per(1);
        timeTaken = time(reach5per(1)) - time(timeStart);
        
        fprintf('Time to get within 5%% for rigid test %i is %1.3f seconds with Kp = %1.2f and Kd = %1.2f \n',j,(time(reach5per)-time(timeStart))/1000,Kp(1),Kd(1))
        
        %plot lines with info
        start = plot([(time(reach5per)-time(timeStart))/1000 (time(reach5per)-time(timeStart))/1000],[thetad*1.5 -thetad*1.5],'Color',[1 0 0]);
        sec5 = plot([.5 .5],[thetad*1.5 -thetad*1.5],'Color',[0 0 1]);
        td = plot(linspace(0,xend,1000),linspace(thetad,thetad,1000),'Color',[0 1 0]);
        plot(linspace(0,xend,1000),linspace(-thetad,-thetad,1000),'Color',[0 1 0])
        
        %label and set limits
        xlabel('Time [s]')
        ylabel('Angle [rads]')        
        xlim([0 xend])
        ylim([thetad*-1.5 thetad*1.5])        
        title(sprintf('Time vs Angle of Test %i for %s',j,name{l}))
        %% kill plots that don't make the cut
        if time(reach5per) > time(timeStart+500)
            close(j+20)
        else
            figure(j+20)
            hold on
            theo = plotTheoretical(thetad,Kp(1),Kd(1),K1(1),K2(1),K3(1),K4(1),1,j,time(timeStart),hubAngle(timeStart));
            legend([actual theo td start sec5],'Actual','Theoretical','Desired Theta','Within 5%','0.5 Seconds')
            %% label gainz on graph
            annotation('textbox',...
                [0.675 0.55 .18 0.13],...
                'String',{['Kp = ' num2str(Kp(1))] ['Kd = ' num2str(K3(1))] ['Thetad = ' num2str(thetad)]},...
                'FontSize',10,...
                'EdgeColor',[0 0 0],...
                'LineWidth',.01,...
                'BackgroundColor',[1 1 1],...
                'Color',[0 0 0]);
        end
    else
        fprintf('Redefine upper limits somehow plz for plots for trial %i\n',j)
        close(j+20)
    end
end