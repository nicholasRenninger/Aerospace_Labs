%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This lab is concerned with the development of a MATLAB code for analyzing
% the forces and moments acting on a 3-D structure. For a given set of
% external forces and moments as well as support conditions you will
% develop a MATLAB code that analyzes the support configuration and
% computes the reaction forces and moments.
%
% Authors: Nick Renninger, Cody Goldman
% Created: 31 August 2016
% Updated: 31 August 2016 Cody Goldman
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get data from input file
[ forcesAndMoments, coordsOfExtForces , magAndDirOfExtForces, locExtMoments , magAndDirMoments , supportLocations, momDirReaction ] = lab_1_fileRead();