%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%PLZ IGNORE ALL OF THIS GARBAGE%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

c=[];
a = 1;
thetad = .2;
len = size(goodKs,1);
for k = 1:len
                K1 = goodKs(k,1);
                K2 = goodKs(k,2);
                K3 = goodKs(k,3);
                K4 = goodKs(k,4);
                Kg = 48.4; %total gear ratio []
                Km = 0.0107; %motor constant [V/(rad/sec) or Nm/amp]
                Rm = 3.29; %armature resistance [ohms]
                
                Jh = 0.002; %base inertia [Kg*m^2]
                Jl = 0.0015; %load inertia of bar [Kg*m^2]
                J = Jh+Jl; %total intertia [Kg*m^2]
                L = 0.45; %link length [m]
                
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
                
                %% Flexible
                %angle
                num = [K1*r1 0 K1*(q1*r2-r1*q2)];
                den = [1 lambda3 lambda2 lambda1 lambda0];
                sysTFflexAngle = tf(num,den);
                
                [x2,t2] = step(sysTFflexAngle,tspan);
                theta2= 2*thetad*x2;
                figure;
                clf;
                plot(t2,theta2)
                xlabel('Time [Seconds]')
                ylabel('Angle [Radians]')
                title('Flexible Arm Angle v Time')
                
                %tip deflection
                num = [K1*r2 K1*(p2*r1-r2*p1) 0];
                den = [1 lambda3 lambda2 lambda1 lambda0];
                sysTFflexDisplacement = tf(num,den);
                
                [x3,t3] = step(sysTFflexDisplacement,tspan);
                figure;
                clf;
                plot(t3,x3)
                xlabel('Time [Seconds]')
                ylabel('Displacement [Meters]')
                title('Flexible Arm Tip Displacement v Time')
                
end