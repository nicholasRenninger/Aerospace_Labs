%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This lab is concerned with the development of a MATLAB code for analyzing
% the forces and moments acting on a 3-D structure. For a given set of
% external forces and moments as well as support conditions you will
% develop a MATLAB code that analyzes the support configuration and
% computes the reaction forces and moments. Input text files should be
% placed in the text_files directory. DO NOT place the text files in the
% working directory, as they will not be found.
% 
% This function takes the input filename (do NOT include the .txt extensionin the filename)
% and writes the results of its analysis into another text file called
% 'filename'_output.txt
% 
% 
% Authors: Nick Renninger, Cody Goldman
% Created: 31 August 2016
% Updated: 23 September 2016, Nick Renninger
%
% DO NOT MODIFY THE DIRECTORY STRUCTURE, OR THE TEXT FILES TO RUN WILL NOT
% BE FOUND.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function truss3d(filename)
    
    %%% specify the name of a .txt file to read in the text_file folder.
    %%%     ex: set filename to the string '2001Lab1' to run the program using a file called "2001Lab1.txt" as the input file

    %%% Get data from input file
    [ forcesAndMoments, coordsOfExtForces , magAndDirOfExtForces , magAndDirMoments , forceReactionLocations, forceDirReaction, momDirReaction, filename_read ] = lab_1_fileRead(filename);

    %%% Use the formatted information from the text file to calculate reaction forces
    [ support_reaction_magnitudes, numberOfReactionForces ] = calculate_support_reactions( forcesAndMoments, coordsOfExtForces , magAndDirOfExtForces, magAndDirMoments , forceReactionLocations, forceDirReaction, momDirReaction );

    %%% Output the results to an textfile in the text_files folder
    lab_1_filewrite( filename_read, numberOfReactionForces, support_reaction_magnitudes );
    
end