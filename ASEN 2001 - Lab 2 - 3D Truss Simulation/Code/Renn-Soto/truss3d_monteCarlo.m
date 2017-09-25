%
% Stochastic analysis of 3-D statically determinate truss by
% Monte Carlo Simulation. Only positions and strength of joints
% treated as random variables
%
% Assumption: variation of joint strength and positions described
%             via Gaussian distributions
%
%             joint strength : mean = 4.8 (N)
%                              std. dev = 0.4
%             joint position :
%                              coefficient of varation = 0.01
%                              (defined wrt to maximum dimension of truss)
%
%             number of samples is set to 1e4
%
%
%%% function takes input file, truss paramters, and the theoretical
%%% probability of failure and computes a more refined estimate of the
%%% probability of failure for the system
%
% Author: Kurt Maute for ASEN 2001, Oct 13 2012
%
% Updated to 3d on 10/10/16 by
% Alexis Sotomayor & Nicholas Renninger
    
function [current_probability_of_failure, FOS, maxForces, maxReact] = truss3d_monteCarlo(inputfile, NUM_SAMPLES,...
                                                                           MEAN_JOINT_STRENGTH, JOINT_STRENGTH_VARIATION,...
                                                                           JOINT_POSITION_COEF_VARIATION, PROBABILITY_FAILURE, use_dynamic_FOS)
    
    if use_dynamic_FOS 
    
        FOS = calculateFOS( MEAN_JOINT_STRENGTH, JOINT_STRENGTH_VARIATION, PROBABILITY_FAILURE); % find accepted FOS based on joint parameters and allowable failure probability
    else
        FOS = 1.0;
    end
    
    % recalculate joint strength based on FOS
    MEAN_JOINT_STRENGTH = MEAN_JOINT_STRENGTH / FOS;
    
    % read input file
    [joints, connectivity, reacJoints, reacVecs, loadJoints, loadVecs] = readinput(inputfile);

    % determine extension of truss
    ext_x = max(joints(:, 1)) - min(joints(:, 1));   % extension in x-direction
    ext_y = max(joints(:, 2)) - min(joints(:, 2));   % extension in y-direction
    ext_z = max(joints(:, 3)) - min(joints(:, 3));   % extension in z-direction
    ext  = max([ext_x, ext_y, ext_z]);

    % loop overall samples
    num_joints = size(joints, 1);       % number of joints
    maxForces = zeros(NUM_SAMPLES, 1);  % maximum bar forces for all samples
    maxReact = zeros(NUM_SAMPLES, 1);   % maximum support reactions for all samples
    failure = zeros(NUM_SAMPLES, 1);    % failure of truss

    for i = 1:NUM_SAMPLES

        % generate random joint strength limit
        variable_strength = JOINT_STRENGTH_VARIATION * randn(1,1);

        joint_strength = MEAN_JOINT_STRENGTH + variable_strength;

        % generate random samples
        var_joints = (JOINT_POSITION_COEF_VARIATION * ext) * randn(num_joints, 3);

        % perturb joint positions
        rand_joints = joints + var_joints;

        % compute forces in bars and reactions
        [barForces, reacForces] = forceanalysis(rand_joints, connectivity, reacJoints, reacVecs, loadJoints, loadVecs);

        % determine maximum force magnitude in bars and supports
        maxForces(i) = max(abs(barForces));
        maxReact(i)  = max(abs(reacForces));

        % determine whether truss failed
        if maxForces(i) > joint_strength || maxReact(i) > joint_strength
            %fprintf('Joint Strength: %f\nVariable Strength: %f\nJoint Strength Variation: %f\nMax Force: %f\nMax Reaction: %f\n\n', joint_strength, variable_strength, JOINT_STRENGTH_VARIATION, maxForces(i), maxReact(i))
            failure(i) = maxForces(i) > joint_strength || maxReact(i) > joint_strength;
        end
        
        % calc. the percent probability of failure
        current_probability_of_failure = sum(failure)/NUM_SAMPLES;
        
    end