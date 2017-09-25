% Lab 6: Robot Arm
% Author: Luke Tafur
% Date Created: 4.13.17
% Date Edited: 5.2.17

clear all; close all;
gainzFlex = dir('../Data/Real Data/flex*');
for i = 1:10
    dataFlex{i} = load(sprintf('%s/%s', gainzFlex(i).folder, gainzFlex(i).name));
end

gainzRigid = dir('../Data/Real Data/rigid*');
for i = 1:10
    dataRigid{i} = load(sprintf('%s/%s', gainzRigid(i).folder, gainzRigid(i).name));
end

name = {'Flexible' 'Rigid'};
Kp = [15];
Kd = [4];

%% Flexible
for j = 1:10
    l = 1;
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
    actual = plot(time(timeStart:end),hubAngle(timeStart:end),'Color',[0 0 0]);
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
        
        start = plot([time(reach5per) time(reach5per)],[thetad*1.5 -thetad*1.5],'Color',[1 0 0]);
        sec1 = plot([time(timeStart+1000) time(timeStart+1000)],[thetad*1.5 -thetad*1.5],'Color',[0 0 1]);
        td = plot(linspace(time(timeStart),time(end),1000),linspace(thetad,thetad,1000),'Color',[0 1 0]);
        plot(linspace(time(timeStart),time(end),1000),linspace(-thetad,-thetad,1000),'Color',[0 1 0])
        
        xlabel('Time [ms]')
        ylabel('Angle [rads]')
        
        if (timeStart + 2000) < length(time)
            xend = time(timeStart + 2000);
        else
            xend = time(end);
        end
        xlim([time(timeStart) xend])
        ylim([thetad*-1.5 thetad*1.5])
        
        title(sprintf('Time vs Angle of Test %i for %s',j,name{l}))
        %% plot time versus tip delfection
        figure(j+10)
        actualtip = plot(time(timeStart:end),tipDeflection(timeStart:end),'Color',[0 0 0]);
        hold on
        
        boundsTip = plot(linspace(time(timeStart),time(end),1000),linspace(.05,.05,1000),'Color',[0 1 0]);
        plot(linspace(time(timeStart),time(end),1000),linspace(-.05,-.05,1000),'Color',[0 1 0])
        sec12 = plot([time(timeStart+1000) time(timeStart+1000)],[-.06 .06],'Color',[0 0 1]);
        
        xlabel('Time [ms]')
        ylabel('Tip Deflection [m]')
        xlim([time(timeStart) xend])
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
    
    for k = 1:length(hubAngle)-1
        if (abs(hubAngle(k+1) - hubAngle(k)) > 0.002) && a==0
            timeStart = k;
            a = 1;
        end
    end
    %% plot time versus theta
    figure(j+20)
    actual = plot(time(timeStart:timeStart+500),hubAngle(timeStart:timeStart+500),'Color',[0 0 0]);
    hold on
    
    %define thetad
    if j == 2
        thetad = 0.6;
    else
        thetad = 0.3;
    end
    temp = hubAngle(timeStart:end);
    reach5per = find(abs(temp) > thetad*0.95)+timeStart;
    if ~isempty(reach5per)
        reach5per = reach5per(1);
        timeTaken = time(reach5per(1)) - time(timeStart);
        
        start = plot([time(reach5per) time(reach5per)],[thetad*1.5 -thetad*1.5],'Color',[1 0 0]);
        sec5 = plot([time(timeStart+500) time(timeStart+500)],[thetad*1.5 -thetad*1.5],'Color',[0 0 1]);
        td = plot(linspace(time(timeStart),time(end),1000),linspace(thetad,thetad,1000),'Color',[0 1 0]);
        plot(linspace(time(timeStart),time(end),1000),linspace(-thetad,-thetad,1000),'Color',[0 1 0])
        
        xlabel('Time [ms]')
        ylabel('Angle [rads]')
        
        if (timeStart + 600) < length(time)
            xend = time(timeStart + 600);
        else
            xend = time(end);
        end
        xlim([time(timeStart) xend])
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
        close(j)
    end
end