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
function [VoltVec_mano, P_Diff_Vec_mano, VeloVec_mano, VoltVec_trans, VelMatrix_trans, VeloVec_trans] = VelocityVoltageForManometer()
    
    %% Manometer
    
    %Voltage Vector
    VoltVec_mano = [1.5 3.5 5.5 7.5 9.5];

    %Pressure differentials(in pascals)
    P_Diff_Vec_mano = [41.12 123.36 370.09 699.07 1151.40];

    VeloVec_mano = PitotStatVelo(P_Diff_Vec_mano);

    %% Transducer
    filename = '..\Data\All_Group_Data\VelocityVoltage\S_013\VelocityVoltage_S013_G05.csv'; % define file for reading

    %creating columns for Pressure, Temperature, Delta P and Voltage 
    a = xlsread(filename, 'A2:A101');
    b = xlsread(filename, 'B2:B101'); 
    c = xlsread(filename, 'C2:C101'); 
    g = xlsread(filename, 'G2:G101'); 

    %create large matrix using all of the columns
    VelMatrix_trans = [a b c g];
    %USe function to compute airspeeds with given parameters
    [VeloVec_trans, ~, ~, ~] = Velo_Calc_Pitot_Static(VelMatrix_trans, false, false);
    VoltVec_trans = g;

    
end







