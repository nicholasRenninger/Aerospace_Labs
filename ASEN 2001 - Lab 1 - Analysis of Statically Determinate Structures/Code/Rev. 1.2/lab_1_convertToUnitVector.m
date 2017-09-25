%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Converts a 1x3 or 1x4 vector where the last three columns are vector
% coordinates into a unit vector of magnitude 1. If a 1x4 vector is
% received, the first cell is ignored.
%
% Authors: Nick Renninger, Cody Goldman
% Created: 12 September 2016
% Updated: 12 September 2016 Cody Goldman
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ unitVec ] = lab_1_convertToUnitVector( vec )
    
    if max( size(vec) ) == 3 %Determine whether a 1x3 or 1x4 is being submitted
        
        mag = norm(vec);
        
        if mag == 0
            unitVec = [0 0 0];
        else
            unitVec = vec / mag; %Divide each coordinate direction by the magnitude
        end
        
    elseif max( size(vec) ) == 4 %If the input vector also includes the magnitude, ignore it
        
        mag = norm( vec(2:4) );
        
        if mag == 0
            unitVec = [0 0 0];
        else
            unitVec = vec(2:4) / mag; %Do the same for the last 3 terms
        end
        
    end
    
end