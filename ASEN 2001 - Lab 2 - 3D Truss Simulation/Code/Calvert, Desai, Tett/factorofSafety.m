function [FoS] = factorofSafety(jstrmean,jstrcov,probFailure)
%This function is meant to determine the factor of safety of the truss
% 

Fdsr = icdf('normal', probFailure,jstrmean,jstrcov);

n = (jstrmean - Fdsr)/(jstrcov);

FoS = ((jstrmean)/(jstrmean-(n*jstrcov)));

%fprintf('Factor of Safety: %f\n',FoS);

end

