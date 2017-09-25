function [barForces, reacForces] = forceanalysis(joints, connectivity, reacJoints, reacVecs, loadJoints, loadVecs)
    
    % function [barforces,reacforces]=forceanalysis(joints,connectivity,reacjoints,reacvecs,loadjoints,loadvecs)
    %
    % compute forces in bars and reaction forces
    %
    % input:  joints       - coordinates of joints
    %         connectivity - connectivity 
    %         reacjoints   - joint id where reaction acts on
    %         reacvecs     - unit vector associated with reaction force
    %         loadjoints   - joint id where external load acts on
    %         loadvecs     - load vector
    %
    % output: barforces    - force magnitude in bars
    %         reacforces   - reaction forces
    %
    % Author: Kurt Maute, Sept 21 2011
    % updated: Nicholas Renninger, Alexis Sotomayor, Sept 27 2016

    % extract number of joints, bars, reactions, and loads
    numJoints = size(joints, 1);
    numBars   = size(connectivity, 1);
    numReact  = size(reacJoints, 1);
    if size(loadJoints, 1) == 0
        numLoads = 0;
    else
        numLoads  = size(loadJoints, 2);
    end

    % number of equations
    numEqns = 3 * numJoints;

    % allocate arrays for linear system
    A = zeros(numEqns);
    b = zeros(numEqns, 1);
    
    % weight of joint material
    massSteelJoint = 0.00783;
    weightSteelJoint = massSteelJoint * 9.807;

    % build Amat - loop over all joints
    numOfWeights = 0;
    for i = 1:numJoints

       % equation id numbers (row indicies for x, y, z equations of equilibrium)
       IDx = 3*i - 2;
       IDy = 3*i - 1;
       IDz = 3*i;

       % get all bars connected to joint
       [currentBarRow, currentBarCol] = find( connectivity == i );

       % loop over all bars connected to joint
       for ib = 1:length(currentBarRow)

           % get bar id
           barID = currentBarRow(ib);

           % get coordinates for joints "i" and "j" of bar "barid"
           current_joint = joints(i, :);
           
           if currentBarCol(ib) == 1
               rowID = connectivity(barID, 2);
           else
               rowID = connectivity(barID, 1);
           end
           
           joint_row = joints(rowID, :);

           % compute unit vector pointing away from joint i
           connectivity_vec = joint_row - current_joint;
           lengthBar = norm(connectivity_vec);
           weightOfBar = lengthToWeight(lengthBar);
           
           % compute self weight vector of bar at each joiint
           numOfWeights = numOfWeights + 1;
           weight_joints(numOfWeights) = i;
           weight_vecs(numOfWeights, :) = [ 0 0 -weightOfBar / 2];
           
           uVec   = connectivity_vec / norm(connectivity_vec);

           % add unit vector into Amat
           A( [IDx IDy IDz], barID ) = uVec;
           
       end
    end

    % build contribution of support reactions 
    for i = 1:numReact

        % get joint id at which reaction force acts
        rowID = reacJoints(i);

        % equation id numbers (row inidicies of x, y, z equilibrium equations)
        IDx = 3*rowID - 2;
        IDy = 3*rowID - 1;
        IDz = 3*rowID;

        % add unit vector into Amat
        A( [IDx IDy IDz], numBars + i ) = reacVecs(i, :);
    end

    % build load vector
    for i = 1:numLoads

        % get joint id at which external force acts
        rowID = loadJoints(i);

        % equation id numbers (row inidicies of x, y, z equilibrium equations)
        IDx = 3*rowID - 2;
        IDy = 3*rowID - 1;
        IDz = 3*rowID;

        % add unit vector into bvec (sign change)
        b( [IDx IDy IDz] ) = -loadVecs(i,:);
    end
    
    % build self weight component of truss bars for load vector
    for i = 1:numOfWeights

        % get joint id at which external force acts
        rowID = weight_joints(i);

        % equation id numbers (row inidicies of x, y, z equilibrium equations)
        IDx = 3*rowID - 2;
        IDy = 3*rowID - 1;
        IDz = 3*rowID;

        % add unit vector into bvec (sign change)
        b( [IDx IDy IDz] ) = b( [IDx IDy IDz] ) - weight_vecs(i, :)';
    end
    
    % build self weight component of steel balls for load vector
    for i = 1:numJoints

        % get joint id at which external force acts
        rowID = i;

        % equation id numbers (row inidicies of x, y, z equilibrium equations)
        IDx = 3*rowID - 2;
        IDy = 3*rowID - 1;
        IDz = 3*rowID;
        
        steelBallWeightVec = [ 0; 0; -weightSteelJoint];
        
        % add unit vector into bvec (sign change)
        b( [IDx IDy IDz] ) = b( [IDx IDy IDz] ) - steelBallWeightVec;
    end
    
    %fprintf('Rank of A: %f\n', rank(A))
    
    % check for invertability of Amat
    if det(A) == 0
       
        error('Amat is not invertible.');
        
    else
         % solve system
        x = A\b;
        %fprintf('size A: %f\nrank A: %f\n', max(size(A)), rank(A))
        
    end

   

    % extract forces in bars and reaction forces
    barForces = x( 1:numBars );
    reacForces = x( (numBars + 1):end );

end