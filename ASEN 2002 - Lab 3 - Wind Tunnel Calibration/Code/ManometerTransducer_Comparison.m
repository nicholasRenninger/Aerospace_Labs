%Authors:  Alexis Sotomayor/Nick Renninger 
%The purpose of this program is to compare the velocities from different
%pressure devices, versus voltage 

%The first half of the program utilizes pressure differentials from a
%manometer, while the second half uses the data from the pressure
%transducer 

%After the velocities are all computed, they are then compared in a plot

%Created November 14, 2016
%Modified November 15, 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Voltage Vector
VoltVec = [1.5 3.5 5.5 7.5 9.5];

%Pressure differentials(in pascals)
P_Diff_Vec = [41.12 123.36 370.09 699.07 1151.40];

VeloVec = PitotStatVelo(P_Diff_Vec);

%set up plot for velocity versus voltage
figure (1)
set (gcf,'defaultaxesfontsize',14)
hold on 
title ('Velocity Comparison (Manometer vs. Transducer)','FontName','Arial','FontSize',16)
xlabel('Voltage (Volts)','FontName','Times','FontSize',12)
ylabel('Velocity (m/s)','FontName','Times','FontSize',12)
axis([0,10,0,55]);
x = VoltVec;
y = VeloVec;

%plot points of the velocities and the voltages
plot(x,y,'*g','DisplayName','Using Manometer');


%Moving on to find velocities for Pressure Transducer Data 
filename = 'VelocityVoltage_S013_G05';%define file for reading

%creating columns for Pressure, Temperature, Delta P and Voltage 
a = xlsread(filename,'A2:A101');
b = xlsread(filename,'B2:B101'); 
c = xlsread(filename,'C2:C101'); 
g = xlsread(filename,'G2:G101'); 

%create large matrix using all of the columns
VelMatrix = [a b c g];
%USe function to compute airspeeds with given parameters
VeloVec2 = Velo_Calc_Pitot_Static(VelMatrix,false);
VoltVec2 = g;

%set up plot for velocity versus voltage for pressure transducer to plot on
%top of figure 1 
figure (1)
set (gcf,'defaultaxesfontsize',14)
hold on 
x2 = VoltVec2;
y2 = VeloVec2;
plot(x2,y2,'--','DisplayName','Using Transducer')


%Legend for Plot 
legend('show');

hold off







