% Lab 6: Robot Arm
% Author: Luke Tafur
% Date Created: 4.13.17
% Date Edited: 5.2.17

function h = plotTheoretical(thetad,Kp,Kd,K1,K2,K3,K4,plotNum,j,timeStart,angleStart)
%% set constantst
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

tspan = (0:0.001:3)';

if plotNum == 1
    %% Closed loop system Rigid
    num = n1;
    den = [d2 d1 d0];
    sysTF = tf(num,den);
    
    %% Step response
    % thetad = desired arm angle (scalar)
    [x,t] = step(sysTF,tspan);
    theta= 2*thetad*x;
    if j == 1 || j == 2 || j ==9
        angle = angleStart - theta;
    else
        angle = angleStart + theta;
    end
    h = plot(t,angle,'Color',[1 0 1]);
    % xlabel('Time [Seconds]')
    % xlim([0 0.5])
    % ylabel('Angle [Radians]')
    % title('Theoretical Rigid Arm Angle v Time')
    % within5timesRigid = find(abs(2*thetad*x-2*thetad)<2*thetad*.05);
    % timeReachRigid = t(within5timesRigid(1));
    % fprintf('Time rigid reaches within 5%% is %f \n',timeReachRigid)
    
elseif plotNum == 2
    %voltage
    Vin = Kp.*(thetad - theta(1:end-1))+Kd.*-1*(diff(theta)./diff(t));
    plot(t(1:end-1),Vin)
    xlabel('Time [Seconds]')
    xlim([0 0.5])
    ylabel('Voltage [Volts]')
    title('Theoretical Rigid Arm Voltage v Time')
    fprintf('Max Voltage for rigid is +%f and -%f \n',abs(max(Vin)),abs(min(Vin)))
    
elseif plotNum == 3
    %% Flexible
    %angle
    num = [K1*r1 0 K1*(q1*r2-r1*q2)];
    den = [1 lambda3 lambda2 lambda1 lambda0];
    sysTFflexAngle = tf(num,den);
    
    [x2,t2] = step(sysTFflexAngle,tspan);
    theta2= 2*thetad*x2;
    h = plot(t2,angleStart - theta2,'Color',[1 0 1]);
    % xlabel('Time [Seconds]')
    % ylabel('Angle [Radians]')
    % title('Theoretical Flexible Arm Angle v Time')
    % within5timesFlex = find(abs(2*thetad*x2-2*thetad)<2*thetad*.05);
    % timeReachFlex = t2(within5timesFlex(1));
    % fprintf('Time flexible reaches within 5%% is %f \n',timeReachFlex)
    
elseif plotNum == 4
    %tip deflection
    num = [K1*r2 K1*(p2*r1-r2*p1) 0];
    den = [1 lambda3 lambda2 lambda1 lambda0];
    sysTFflexDisplacement = tf(num,den);
    
    [x3,t3] = step(sysTFflexDisplacement,tspan);
    h = plot(t3,x3,'Color',[1 0 1]);
    % xlabel('Time [Seconds]')
    % ylabel('Displacement [Meters]')
    % title('Theoretical Flexible Arm Tip Displacement v Time')
    % fprintf('Max tip deflection is +%f [cm] and -%f [cm]\n',abs(max(x3)*100),abs(min(x3)*100))
    
elseif plotNum == 5
    %voltage
    Vin2 = K1*(thetad - theta2(1:end-1))-K3*(diff(theta2)./diff(t2))-K2*x3(1:end-1)-K4*(diff(x3)./diff(t3));
    plot(t2(1:end-1),Vin2)
    xlabel('Time [Seconds]')
    ylabel('Voltage [Volts]')
    title('Theoretical Flexible Arm Voltage v Time')
    fprintf('Max Voltage for flexible is +%f and -%f \n\n',abs(max(Vin2)),abs(min(Vin2)))
end
end