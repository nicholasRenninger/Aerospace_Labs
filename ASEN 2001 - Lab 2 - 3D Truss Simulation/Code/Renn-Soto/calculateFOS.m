%%% Takes Mean Joint Strength, Variation of Joint Strength and desired
%%% probabbility of failure to determine the FOS for the truss.
%%% 
%%% Authors: Alexis Sototmayor & Nicholas Renninger
%%% Last Updated: 10/10/16

function FOS = calculateFOS( MEAN_JOINT_STRENGTH, JOINT_STRENGTH_VARIATION, PROBABILITY_FAILURE)


    F_desired_in_bars = icdf('normal', PROBABILITY_FAILURE, ...
                                       MEAN_JOINT_STRENGTH, ...
                                       JOINT_STRENGTH_VARIATION);

    FOS = MEAN_JOINT_STRENGTH / F_desired_in_bars;

    
    if FOS < 1
        error('FOS cannot be less than 1. Adjust failure parameters')
    end
    
end