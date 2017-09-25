%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Luke Tafur                                     %
%    Robot Control Arm                              %
%    Date Created: 4.18.2017                        %
%    Date Modified: 4.20.2017                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;tic
clear all; close all;
%% set parameters
%set rules
maxDeflect = 5;
maxTimeRigid = 0.5;
maxTimeFlex = 1;
maxVoltRigid = 5;
maxVoltFlex = 5;

%desired angle
thetad = .3;

%rigid arm
Kp = 14;
Kd = 0.6;

%flexible arm
%working-ish values 
%[6 -6.4 1.3 1.5] too much tip deflect tho
%
%6.8 -6.4 1.4 1.1
%
%[4.2 -15 1.2 0.1] 0.999 [s] 5.06 [cm]
%[3.9 -15 1.1 0.1] 0.993 [s] 4.89 [cm]
%[3.6 -15 0.9 0.1] 0.860 [s] 4.88 [cm]
%[3.0 -15 0.6 0.1] 0.761 [s] 4.67 [cm]
%[2.5 -15 0.4 0.1] 0.750 [s] 4.36 [cm]
%[2.0 -15 0.2 0.1] 0.752 [s] 4.01 [cm]
%[1.8 -15 0.0 0.0] 0.678 [s] 4.09 [cm] NOT SURE WHY 0 DER CONTROL IS 
%[1.2 -15 0.0 0.0] 0.919 [s] 2.79 [cm] DOING WELL. DID THEY LIE TO US??
K1 = 6.8; %Kptheta *0 - 10*
K2 = -6.4; %Kpd *-15 - 0*
K3 = 1.4; %KDtheta *0 - 1.5*
K4 = 1.1; %KDd *0 -1.5*

Kg = 48.4; %total gear ratio []
Km = 0.0107; %motor constant [V/(rad/sec) or Nm/amp]
Rm = 3.29; %armature resistance [ohms]

Jh = 0.002; %base inertia [Kg*m^2]
Jl = 0.0015; %load inertia of bar [Kg*m^2]
J = Jh+Jl; %total intertia [Kg*m^2]
L = 0.45; %link length [m]

%closed loop transfer function for rigid
n1 = (Kp*Kg*Km)/(J*Rm); %numerator constant term
d2 = 1; %denominator s^2 term
d1 = (Kd*Kg*Km+(Kg^2)*(Km^2))/(J*Rm); %denominator s term
d0 = (Kp*Kg*Km)/(J*Rm);%denominator constant term

Marm = 0.06; %link mass of the ruler [Kg]
Ja = (Marm*L^2)/3; %link rigid body inertia [Kg*m^2]
Mtip = 0.05; %tip mass [Kg]
Jm = Mtip*L^2; %tip mass inertia [Kg*m^2]
Jl = Ja + Jm; %total inertia [Kg*m^2]
Fc = 1.8; %natural frequency [Hz]
Karm = ((2*pi*Fc)^2)*(Jl); %flexible link stiffness

%constants from lab doc pg. 6
r1 = (Kg*Km)/(Jh*Rm);
r2 = (-1*Kg*Km*L)/(Jh*Rm);
p1 = (-1*(Kg^2)*(Km^2))/(Jh*Rm);
p2 = ((Kg^2)*(Km^2)*L)/(Jh*Rm);
q1 = Karm/(L*Jh);
q2 = (-1*Karm*(Jh+Jl))/(Jl*Jh);

%constants from lab doc pg. 7
lambda3 = -1*p1+K3*r1+K4*r2;
lambda2 = -1*q2+K1*r1+K2*r2+K4*(p2*r1-r2*p1);
lambda1 = p1*q2-q1*p2+K3*(q1*r2-r1*q2)+K2*(p2*r1-r2*p1);
lambda0 = K1*(q1*r2-r1*q2);

tspan = (0:0.001:1.5)';

%% Closed loop system Rigid
num = n1;
den = [d2 d1 d0];
sysTF = tf(num,den)

%% Step response
% thetad = desired arm angle (scalar)
[x,t] = step(sysTF,tspan);
theta= 2*thetad*x;
figure(1);
clf;
plot(t,theta)
xlabel('Time [Seconds]')
xlim([0 0.5])
ylabel('Angle [Radians]')
title('Theoretical Rigid Arm Angle v Time')
within5timesRigid = find(abs(2*thetad*x-2*thetad)<2*thetad*.05);
timeReachRigid = t(within5timesRigid(1));
fprintf('Time rigid reaches within 5%% is %f \n',timeReachRigid)

%voltage
figure(2);
Vin = Kp.*(thetad - theta(1:end-1))+Kd.*-1*(diff(theta)./diff(t));
plot(t(1:end-1),Vin)
xlabel('Time [Seconds]')
xlim([0 0.5])
ylabel('Voltage [Volts]')
title('Theoretical Rigid Arm Voltage v Time')
fprintf('Max Voltage for rigid is +%f and -%f \n',abs(max(Vin)),abs(min(Vin)))

%% Flexible
%angle
num = [K1*r1 0 K1*(q1*r2-r1*q2)];
den = [1 lambda3 lambda2 lambda1 lambda0];
sysTFflexAngle = tf(num,den)

[x2,t2] = step(sysTFflexAngle,tspan);
theta2= 2*thetad*x2;
figure(3);
clf;
plot(t2,theta2)
xlabel('Time [Seconds]')
ylabel('Angle [Radians]')
title('Theoretical Flexible Arm Angle v Time')
within5timesFlex = find(abs(2*thetad*x2-2*thetad)<2*thetad*.05);
timeReachFlex = t2(within5timesFlex(1));
fprintf('Time flexible reaches within 5%% is %f \n',timeReachFlex)

%tip deflection
num = [K1*r2 K1*(p2*r1-r2*p1) 0];
den = [1 lambda3 lambda2 lambda1 lambda0];
sysTFflexDisplacement = tf(num,den)

[x3,t3] = step(sysTFflexDisplacement,tspan);
figure(4);
clf;
plot(t3,x3)
xlabel('Time [Seconds]')
ylabel('Displacement [Meters]')
title('Theoretical Flexible Arm Tip Displacement v Time')
fprintf('Max tip deflection is +%f [cm] and -%f [cm]\n',abs(max(x3)*100),abs(min(x3)*100))

%voltage
figure(5);
Vin2 = K1*(thetad - theta2(1:end-1))-K3*(diff(theta2)./diff(t2))-K2*x3(1:end-1)-K4*(diff(x3)./diff(t3));
plot(t2(1:end-1),Vin2)
xlabel('Time [Seconds]')
ylabel('Voltage [Volts]')
title('Theoretical Flexible Arm Voltage v Time')
fprintf('Max Voltage for flexible is +%f and -%f \n\n',abs(max(Vin2)),abs(min(Vin2)))

%%check criteria
if timeReachRigid < maxTimeRigid
    cprintf('green','Passes rigid time test!\n')
    check1 = 1;
else
    cprintf('red','Fails rigid time test!\n')
    check1 = 0;
end

if abs(max(Vin)) > maxVoltRigid || abs(min(Vin)) > maxVoltRigid
    cprintf('red','Fails rigid voltage test!\n')
    check2 = 0;
else
    cprintf('green','Passes rigid voltage test!\n')
    check2 = 1;
end

if timeReachFlex < maxTimeFlex
    cprintf('green','Passes flex time test!\n')
    check3 = 1;
else
    cprintf('red','Fails flex time test!\n')
    check3 = 0;
end

if abs(max(x3(1000:1500))*100) > maxDeflect || abs(min(x3(1000:1500))*100) > maxDeflect
    cprintf('red','Fails tip deflection test!\n')
    check4 = 0;
else
    cprintf('green','Passes tip deflection test!\n')
    check4 = 1;
end

if abs(max(Vin2)) > maxVoltFlex || abs(min(Vin2)) > maxVoltFlex
    cprintf('red','Fails flex voltage test!\n')
    check5 = 0;
else
    cprintf('green','Passes flex voltage test!\n')
    check5 = 1;
end

if check1 && check2
    fprintf('\nWorking model for rigid with values Kp:%f and Kd:%f\n',Kp,Kd)
else
    fprintf('\nBad rigid model\n')
end

if check3 && check4 && check5
    fprintf('Working model for flexible with values K1:%f, K2:%f, K3:%f, and K4:%f\n\n',K1,K2,K3,K4)
else
    fprintf('Bad flexible model\n\n')
end

toc