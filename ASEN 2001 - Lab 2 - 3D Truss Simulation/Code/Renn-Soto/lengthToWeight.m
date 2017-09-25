% compute forces in bars and reaction forces
%
% input:  length - length of truss rod in inches
%
% output: weight of truss rod in kg
%
% Author: Nicholas Renninger, Alexis Sotomayor Sept 21 2011
% updated: Nicholas Renninger, Alexis Sotomayor, Sept 27 2016

function weight = lengthToWeight(length_inches)
    
    length_meters = length_inches * 0.0254; % convert distance in inches to meters  
    linear_density_truss_rod = 0.0483466; % linear density of avg truss rod in kg / m
    
    weight = length_meters * linear_density_truss_rod * 9.807;

end