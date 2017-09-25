function [barforces,reacforces]=forceanalysis(joints,connectivity,reacjoints,reacvecs,loadjoints,loadvecs)
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
numeqns = 2 * numjoints;

% allocate arrays for linear system
Amat = zeros(numeqns);
bvec = zeros(numeqns,1);

% build Amat - loop over all joints

for i=1:numjoints
    
   % equation id numbers
   idx = 2*i-1;
   idy = 2*i;
   
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
       Amat([idx idy],barid)=uvec;
   end
end

% build contribution of support reactions 
for i=1:numreact
    
    % get joint id at which reaction force acts
    jid=reacjoints(i);

    % equation id numbers
    idx = 2*jid-1;
    idy = 2*jid;

    % add unit vector into Amat
    Amat([idx idy],numbars+i)=reacvecs(i,:);
end

% build load vector
for i=1:numloads
    
    % get joint id at which external force acts
    jid=loadjoints(i);

    % equation id numbers
    idx = 2*jid-1;
    idy = 2*jid;

    % add unit vector into bvec (sign change)
    bvec([idx idy])=-loadvecs(i,:);
end

% check for invertability of Amat
if rank(Amat) ~= numeqns
    error('Amat is rank defficient: %d < %d\n',rank(Amat),numeqns);
end

% solve system
xvec=Amat\bvec;

% extract forces in bars and reaction forces
barforces=xvec(1:numbars);
reacforces=xvec(numbars+1:end);

end