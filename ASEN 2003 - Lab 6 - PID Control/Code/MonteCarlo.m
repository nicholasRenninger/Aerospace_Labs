%% set parameters
Kp = 14;
Kd = 0.6;
Kg = 48.4;
Km = 0.0107;

J = .0035;
Rm = 3.29;

n1 = (Kp*Kg*Km)/(J*Rm);
d2 = 1;
d1 = (Kd*Kg*Km+(Kg^2)*(Km^2))/(J*Rm);
d0 = (Kp*Kg*Km)/(J*Rm);

thetad = .2;

%% Closed loop system 
num = n1;
den = [d2 d1 d0];
sysTF = tf(num,den)

%% Step response
% thetad = desired arm angle (scalar)
[x,t] = step(sysTF);
theta= 2*thetad*x;
figure(1);
clf;
plot(t,theta)
xlabel('Time [Seconds]')
ylabel('Angle [Radians]')
title('Rigid Arm Angle v Time')

figure(2);
Vin = Kp.*(thetad - theta(1:end-1))+Kd.*-1*(diff(theta)./diff(t));
plot(t(1:end-1),Vin)
xlabel('Time [Seconds]')
ylabel('Voltage [Volts]')
title('Rigid Arm Voltage v Time')