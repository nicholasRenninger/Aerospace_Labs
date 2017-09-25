%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Takes the name of the file being read, the number of reaction forces,
% and the solved x vector from the equillibirum equation:
%       A * x = b
% where x contains the magintudes of the support reaction (both couples
% & moments).
% 
% Writes the formatted results of the support analysis into a text file
% named accoring to the inputed filename. The output file includes the full
% text of the input file, and appends the output to the end of this file.
% 
% Authors: Nick Renninger, Cody Goldman
% Created: 29 August 2016
% Last Updated: 23 September 2016, Nick Renninger
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function lab_1_filewrite( filename_read, numberOfReactionForces, support_reaction_magnitudes )

    %%% creating read and write file names
    filename_write = cat( 2, filename_read, '_output.txt');
    filename_read_full = cat( 2, filename_read, '.txt' );

    fid = fopen(filename_write, 'w+'); % create/open the output file with write privileges
    fclose(fid); % close the file after creating it.

    %%% copy the problem setup into the new file
    copyfile(filename_read_full, filename_write, 'f');

    fid = fopen(filename_write, 'a+'); % now re-open the file with append privileges


    %%% printing header and the results of analysis:
    if isempty( support_reaction_magnitudes ) % if the system is not solveable
        
        fprintf(fid, '\r\n\r\n# The system is not solveable.\r\n');
        
    else % the system is solveable and the solution was found
        
        fprintf(fid, '\r\n\r\n# Magnitudes of Reaction Moments and Forces:\r\n\r\n');
        
        for i = 1:numberOfReactionForces % printing reaction forces
            
            fprintf(fid, 'The magnitude of Reaction Force %d is: %f\r\n', i, support_reaction_magnitudes(i) );
            
        end
        
        for i = numberOfReactionForces + 1:6 % printing reaction moments
            
            fprintf(fid, 'The magnitude of Reaction Moment %d is: %f\r\n', i - numberOfReactionForces, support_reaction_magnitudes(i) );
            
        end
        
    end

    fclose(fid);
    
end