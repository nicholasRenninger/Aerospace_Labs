function [joints,connectivity,reacjoints,reacvecs,loadjoints,loadvecs]=readinput3D(inputfile)
% function [joints,connectivity,reacjoints,reacvecs,loadjoints,loadvecs]=readinput(inputfile)
%
% read input file
%
% input: inputfile - name of input file
%
% output: joints       - coordinates of joints
%         connectivity - connectivity 
%         reacjoints   - joint id where reaction acts on
%         reacvecs     - unit vector associated with reaction force
%         loadjoints   - joint id where external load acts on
%         loadvecs     - load vector
%
% Author: Kurt Maute, Sept 21 2011
%
% Edited by Calvert, Desai, Tett
% Currently works for 3D problems.

% open inputfile
fid=fopen(inputfile);

if fid<0;error('inputfile does not exist');end

% initialze counters and input block id
counter=0;
inpblk=1;

% read first line
line=fgetl(fid);

% read input file
while line > 0
    
    % check if comment
    if strcmp(line(1),'#')
        % read next line and continue
        line=fgetl(fid);
        continue;
    end
    
    switch inpblk
        
        case 1 % read number of joints, bars, reactions, and loads
            
            dims=sscanf(line,'%d%d%d%d%d');             %WORKS
            
            numjoints = dims(1);            %WORKS
            numbars   = dims(2);
            numreact  = dims(3);
            numloads  = dims(4);            %WORKS
            
            % check for correct number of reaction forces
            if numreact~=6; error('incorrect number of reaction forces');end  %WORKS 
            
            % initialize arrays
            joints       = zeros(numjoints,3);          %WORKS
            connectivity = zeros(numbars,2);
            reacjoints   = zeros(numreact,1);
            reacvecs     = zeros(numreact,3);
            loadjoints   = zeros(numloads,1);
            loadvecs     = zeros(numloads,3);              %WORKS
            
            % check whether system satisfies static determiancy condition
            if 3*numjoints - 6 ~= numbars
                error('truss is not statically determinate');           
            end

            % expect next input block to be joint coordinates
            inpblk = 2;
            
        case 2 % read coordinates of joints
            
            % increment joint id
            counter = counter + 1;
            
            % read joint id and coordinates;
            tmp=sscanf(line,'%d%e%e');
            
            % extract and check joint id
            jointid=tmp(1);
            if jointid>numjoints || jointid<1
                error('joint id number need to be smaller than number of joints and larger than 0');
            end
            
            % store coordinates of joints
            joints(jointid,:)=tmp(2:4);
            
            % expect next input block to be connectivity
            if counter==numjoints
                inpblk  = 3;
                counter = 0;
            end
            
        case 3 % read connectivity of bars         %SHOULD WORK UP TO HERE
            
            % increment bar id
            counter = counter + 1;
            
            % read connectivity;
            tmp=sscanf(line,'%d%d%d');
            
            % extract bar id number and check
            barid=tmp(1);
            if barid>numbars || barid<0
                error('bar id number needs to be smaller than number of bars and larger than 0');
            end
            
            % check joint ids
            if max(tmp(2:3))>numjoints || min(tmp(2:3))<1
                error('joint id numbers need to be smaller than number of joints and larger than 0');
            end
            
            % store connectivity
            connectivity(barid,:)=tmp(2:3);
            
            % expect next input block to be reaction forces
            if counter==numbars
                inpblk  = 4;
                counter = 0;
            end
            
        case 4 % read reation force information
            
            % increment reaction id
            counter = counter + 1;
            
            % read joint id and unit vector of reaction force;
            tmp=sscanf(line,'%d%e%e');
            
            % extract and check joint id
            jointid=tmp(1);
            if jointid>numjoints || jointid<1
                error('joint id number need to be smaller than number of joints and larger than 0');
            end
            
            % extract untit vector and check length
            uvec=tmp(2:4);
            uvec=uvec/norm(uvec);
            
            % store joint id and unit vector
            reacjoints(counter)  = jointid;
            reacvecs(counter,:)  = uvec;
            
            % expect next input block to be external loads
            if counter==numreact
                inpblk  = 5;
                counter = 0;
            end
            
        case 5 % read external load information
            
            % increment reaction id
            counter = counter + 1;
            
            % read joint id and unit vector of reaction force;
            tmp=sscanf(line,'%d%e%e');
            
            % extract and check joint id
            jointid=tmp(1);
            if jointid>numjoints || jointid<1
                error('joint id number need to be smaller than number of joints and larger than 0');
            end
            
            % extract force vector
            frcvec=tmp(2:4);
            
            % store joint id and unit vector
            loadjoints(counter) = jointid;
            loadvecs(counter,:) = frcvec;
            
            % expect no additional input block
            if counter==numloads
                inpblk  = 99;
                counter = 0;
            end
            
        otherwise
            %fprintf('warning: unknown input: %s\n',line);
    end
    
    % read next line
    line=fgetl(fid);
end

% close input file
fclose(fid);

end
