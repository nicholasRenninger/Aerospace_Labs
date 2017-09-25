%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Takes properly formatted parameters from lab_1_fileRead:
%   
%   number of external forces and moments (forcesAndMoments)
%   coordinates of external forces (coordsOfExtForces)
%   magnitude and direction of external forces (magAndDirOfExtForces)
%   magnitude and direction of the external moments (magAndDirMoments)
%   locations of the supports (supportLocations)
%   type and direction of the reaction forces (forceDirReaction)
%   type and direction of the reaction moments (momDirReaction)

% and outputs the computed support reaction magnitudes
%
% Solves for these reaction by contructing a 6x6 matrix A such that its
% first three rows represent the direction of the reaction forces in x, y,
% and z and its last three rows represnt the direction of the reaction 
% moments in x, y, and z. Then, it solves the system of linear equations:
%           A * x = b
%           x = A^-1 * b
% where x is the vector containing the support reaction magnitudes.
%
% Authors: Nick Renninger, Cody Goldman
% Created: 29 August 2016
% Last Updated: 23 September 2016, Nick Renninger
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ support_reaction_magnitudes, numberOfReactionForces ] = calculate_support_reactions( forcesAndMoments, coordsOfExtForces , magAndDirOfExtForces, magAndDirMoments , forceReactionLocations, forceDirReaction, momDirReaction )

    b = zeros(6,1); % initialize the external force/moment vector, b

    numberOfReactionForces = size( forceDirReaction, 1 ); % find the number of reaction forces

    %%% Building b with the external forces - contribute to the forces and
    %%% moments of the system
    
    for i = 1:3 % For the x, y, and z components of the forces
        for j = 1:forcesAndMoments(1) %For the number of external forces

            % Sum of external forces in each component
            forceWithUnitVector = [ magAndDirOfExtForces(j, 1) , lab_1_convertToUnitVector( magAndDirOfExtForces(j, :) ) ];
            b(i) = b(i) + ( forceWithUnitVector(1) * forceWithUnitVector(i + 1) );

            % Calculating the moment created by external forces and adding the
            % moment values to the B matrix
            momentVec = cross( coordsOfExtForces(j, :) , forceWithUnitVector(1) * forceWithUnitVector(2:4) );
            momentVec_transpose = momentVec';
            b(i + 3) = b(i + 3) + momentVec_transpose(i);

        end
    end

    %%% Building b with the external moments - these are couple moments so
    %%% they only contribute moments to the system
    
    for i = 4:6 % For the x, y, and z components of the moments
        for j = 1:forcesAndMoments(2) % For the number of external couple moments

            % Sum of moments about (0, 0, 0)
            momentWithUnitVector = [ magAndDirMoments(j, 1) , lab_1_convertToUnitVector( magAndDirMoments(j, :) ) ];
            b(i) = b(i) + ( momentWithUnitVector(1) * momentWithUnitVector(i-2) );

        end
    end

    b = -1 .* b; % change all signs in b to reflect the fact b is built by subtracting the forces 
    
    
    %%% building the forces rows of A by creating unit vectors from
    %%% reaction force direction
    
    for i = 1:6 % Converting direction of reaction forces to unit vectors

        if i <=  numberOfReactionForces % if adding non-zero force direction contributions to the matrix
            
            reactionForces(i, :) = lab_1_convertToUnitVector( forceDirReaction(i, :) );
            
        else % if adding zero force contirbutions to the martix
            
            reactionForces(i, :) = [0 0 0];
            
        end

    end

    
    %%% Building the moments rows of A by finding unit vectors in the direction of the moments
    
    for i = 1:6 % Converting direction of reaction moments to unit vectors

        if i <= numberOfReactionForces % the moment contributions from the reaction forces
            
            reactionMoments(i, :) = cross( forceReactionLocations(i, :), reactionForces(i, :) );
            
        else % the moment contributions from the couple moments
            
            reactionMoments(i, :) = lab_1_convertToUnitVector( momDirReaction(i - numberOfReactionForces, :) );
            
        end

    end

    A = cat( 1, reactionForces', reactionMoments' ); % transpose the reaction forces and moments matricies, and vertically concat
    det_A = det(A); % take the determinant of A to check for invertibility. A is invertible iff det ~= 0

    if det_A ~= 0 % if the matrix is invertible

        A_inv = inv(A); % find inverse of A
        x = A_inv * b; % solve the system by multiplying A^-1 * b to find x.

        support_reaction_magnitudes = x; % re-name the x vector to something more meaningful for return

    else % if the matrix is non-invertible (linearly dependent vecotrs within)

        disp( 'The system is not solvable. :(' ); % let the user know that system is not solveable
        support_reaction_magnitudes = []; % return an empty array in this case

    end
    
end