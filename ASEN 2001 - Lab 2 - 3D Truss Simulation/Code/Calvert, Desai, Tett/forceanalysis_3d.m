function [barforces,reacforces]=forceanalysis_3d(joints,connectivity,reacjoints,reacvecs,loadjoints,loadvecs)
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

% extract number of joints, bars, reactions, and loads
numjoints = size(joints,1);
numbars   = size(connectivity,1);
numreact  = size(reacjoints,1);
numloads  = size(loadjoints,1);

% number of equations
numeqns = 3 * numjoints;

% allocate arrays for linear system
Amat = zeros(numeqns);
bvec = zeros(numeqns,1);

%
%Linear density
lDensity = 0.00122174; %(kg/m)
rods = findLength(joints,connectivity,lDensity);


% build Amat - loop over all joints
wNum = 0;
for i=1:numjoints
    
   % equation id numbers
   idx = 3*i-2;
   idy = 3*i-1;
   idz = 3*i;
   
   % get all bars connected to joint
   [ibar,ijt]=find(connectivity==i);
   
   % loop over all bars connected to joint
   
   for ib=1:length(ibar)
       
       % get bar id
       barid=ibar(ib);
       
       % get coordinates for joints "i" and "j" of bar "barid"
       joint_i = joints(i,:);                   
       if ijt(ib) == 1
           jid = connectivity(barid,2);
       else
           jid = connectivity(barid,1);
       end
       joint_j = joints(jid,:);                 
       
       % compute unit vector pointing away from joint i
       vec_ij = joint_j - joint_i;
       uvec   = vec_ij/norm(vec_ij);
       
       % add unit vector into Amat
       Amat([idx idy idz],barid)=uvec;
       
       wNum = wNum + 1;
       jWeight(wNum) = i;
       wVec(wNum,:) = [0 0 -rods((ib),2)/2];
       
   end
end

% build contribution of support reactions 
for i=1:numreact
    
    % get joint id at which reaction force acts
    jid=reacjoints(i);

    % equation id numbers
    idx = 3*jid-2;
    idy = 3*jid-1;
    idz = 3*jid;

    % add unit vector into Amat
    Amat([idx idy idz],numbars+i)=reacvecs(i,:);
end

% build load vector
for i=1:numloads
    
    % get joint id at which external force acts
    jid=loadjoints(i);

    % equation id numbers
     idx = 3*jid-2;
    idy = 3*jid-1;
    idz = 3*jid;

    % add unit vector into bvec (sign change)
    bvec([idx idy idz])=-loadvecs(i,:);
end


%accounting for self weights of bars
for i=1:wNum
   
    
    jid = jWeight(i);
    
    idx = 3*jid - 2;
    idy = 3*jid - 1;
    idz = 3*jid;
    
    
   bvec([idx idy idz])=  bvec([idx idy idz]) - wVec(i,:)';
    
    
end
    

%accounting for weight of the balls
ballWeight = 0.00835*9.8;
for j=1:numjoints


jid = j;

idx = 3*jid - 2;
idy = 3*jid - 1;
idz = 3*jid;

ballWeightVec = [0 0 -ballWeight];


 bvec([idx idy idz])=  bvec([idx idy idz]) - ballWeightVec';

end

% check for invertability of Amat
if rank(Amat) ~= numeqns
   %error('Amat is rank defficient: %d < %d\n',rank(Amat),numeqns);
end

% solve system
%xvec=Amat\bvec;
xvec = pinv(Amat)*(bvec);


% extract forces in bars and reaction forces
barforces=xvec(1:numbars);
reacforces=xvec(numbars+1:end);

end