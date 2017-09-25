function [joints, connectivity, reacJoints, reacVecs, loadJoints, loadVecs] = readinput(inputfile)
    % function [joints,connectivity,reacjoints,reacvecs,loadjoints,loadvecs]=readinput(inputfile)
    %
    % read input file
    %
    % input: inputfile - name of input file
    %
    % output: joints       - coordinates of joints in inches
    %         connectivity - connectivity 
    %         reacjoints   - joint id where reaction acts on
    %         reacvecs     - unit vector associated with reaction force
    %         loadjoints   - joint id where external load acts on
    %         loadvecs     - load vector
    %
    % Author: Kurt Maute, Sept 21 2011
    % updated: Nicholas Renninger, Alexis Sotomayor, Sept 27 2016
    
    % open inputfile
    fid = fopen(inputfile);

    if fid < 0
        error('inputfile does not exist');
    end

    % initialze counters and input block id
    counter = 0;
    inpblk = 1;

    % read first line
    line = fgetl(fid);

    % read input file
    while line > 0

        % check if comment
        if strcmp(line(1),'#')
            % read next line and continue
            line = fgetl(fid);
            continue;
        end

        switch inpblk

            case 1 % read number of joints, bars, reactions, and loads

                dims = sscanf(line,'%d%d%d%d%d');

                numJoints = dims(1);
                numBars   = dims(2);
                numReact  = dims(3);
                numLoads  = dims(4);

                % check for correct number of reaction forces
                if numReact ~= 6
                    disp('incorrect number of reaction forces');
                end

                % initialize arrays
                joints       = zeros(numJoints, 3);
                connectivity = zeros(numBars, 2);
                reacJoints   = zeros(numReact, 1);
                reacVecs     = zeros(numReact, 3);
                loadJoints   = zeros(numLoads, 1);
                loadVecs     = zeros(numLoads, 3);

                % check whether system satisfies static determiancy condition
                if 3*numJoints - 6 ~= numBars
                    disp('truss is not statically determinate');
                end

                % expect next input block to be joint coordinates
                inpblk = 2;

            case 2 % read coordinates of joints

                % increment joint id
                counter = counter + 1;

                % read joint id and coordinates;
                current_line = sscanf(line,'%d%e%e%e');
                %current_line = [current_line(1); current_line(2:end) .* 0.0254]; % convert to meters from inches

                % extract and check joint id
                jointID = current_line(1);
                if jointID > numJoints || jointID < 1
                    error('joint id number need to be smaller than number of joints and larger than 0');
                end

                % store coordinates of joints
                joints(jointID,:) = current_line(2:4);

                % expect next input block to be connectivity
                if counter == numJoints
                    inpblk  = 3;
                    counter = 0;
                end

            case 3 % read connectivity of bars

                % increment bar id
                counter = counter + 1;

                % read connectivity;
                current_line = sscanf(line,'%d%d%d');

                % extract bar id number and check
                barid = current_line(1);
                if barid > numBars || barid < 0
                    error('bar id number needs to be smaller than number of bars and larger than 0');
                end

                % check joint ids
                if max( current_line(2:3) ) > numJoints || min( current_line(2:3) ) < 1
                    error('joint id numbers need to be smaller than number of joints and larger than 0');
                end

                % store connectivity
                connectivity(barid, :) = current_line(2:3);

                % expect next input block to be reaction forces
                if counter == numBars
                    inpblk  = 4;
                    counter = 0;
                end

            case 4 % read reation force information

                % increment reaction id
                counter = counter + 1;

                % read joint id and unit vector of reaction force;
                current_line = sscanf(line,'%d%e%e%e');

                % extract and check joint id
                jointID = current_line(1);
                if jointID > numJoints || jointID < 1
                    error('joint id number need to be smaller than number of joints and larger than 0');
                end

                % extract untit vector and check length
                uvec = current_line(2:4);
                uvec = uvec/norm(uvec);

                % store joint id and unit vector
                reacJoints(counter)  = jointID;
                reacVecs(counter, :)  = uvec;

                % expect next input block to be external loads
                if counter == numReact
                    inpblk  = 5;
                    counter = 0;
                end

            case 5 % read external load information

                % increment reaction id
                counter = counter + 1;

                % read joint id and unit vector of reaction force;
                current_line = sscanf(line,'%d%e%e%e');

                % extract and check joint id
                jointID = current_line(1);
                if jointID > numJoints || jointID < 1
                    error('joint id number need to be smaller than number of joints and larger than 0');
                end

                % extract force vector
                reacForceVec = current_line(2:4);

                % store joint id and unit vector
                loadJoints(counter) = jointID;
                loadVecs(counter, :) = reacForceVec;

                % expect no additional input block
                if counter == numLoads
                    inpblk  = 99;
                    counter = 0;
                end

            otherwise
                %fprintf('warning: unknown input: %s\n',line);
        end

        % read next line
        line = fgetl(fid);
    end

    % close input file
    fclose(fid);

end
