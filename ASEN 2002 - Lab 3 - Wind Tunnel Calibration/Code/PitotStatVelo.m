function [airspeed] = PitotStatVelo(deltaP)
%calculate velocity using these pressure differentials and Bernoulli's
%equation for pitot static tubes 
R_Air = 286.9;
T_atm = 304.303; %average atmospheric temperature during data compilation
P_atm = 83964.41944;%average atmospheric pressure during data compilation 

%returns airspeed in meters per a given differential pressure 
airspeed = sqrt( (2 * deltaP) .* ((R_Air .* T_atm) ./ (P_atm)) );
