function [Density] = Density_Calculator(P_Atm,T_Atm)

R_Air = 286.9;%gas constant for air, in joules/kg*K
Density = P_Atm/(R_Air*T_Atm);
%Returns density in kilograms per meters cubed or kg/m^3