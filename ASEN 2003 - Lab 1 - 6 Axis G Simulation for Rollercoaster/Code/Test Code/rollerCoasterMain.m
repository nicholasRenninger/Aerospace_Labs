%{

%}

%Define starting parameters
h0 = 125; %m
slope0 = 0;
rho0 = 0;
coord0 = [0, 0]; %x,y - may be better to have x,y,z than h separate 

%% First segment - Start and Loop: Starts at h0, ends at h2
    %Pass loop parameters
    direction = ;
    rLoop = ; %radius
    h1 = ; %starting height of loop
    slope1 = ; %starting slope
    rho1 = ; %starting curvature
    coord1 = [,]; %x, y pos
    
    %Calculate loop values
    [h2, s2, slope2, coord2, rho2] = loop(h1, slope1, rho1, coord1, rLoop);
        %note that s# refers to parametric equation
    
    %First transition (between start and loop)
    [s1] = transition(h0, slope0, rho0, h1, slope1, rho1);
        %returns parametric equation s given relevant information

%% Second segment - Zero-G: Starts at h2, ends at h3
    %Pass zeroG parameters

    %Calculate zeroG values
    [h3, s3, slope3, coord3] = zeroG(h2, ..);

    %Second transition (between loop and zero-G)
    [s3] = transition(h1, slope1, rho1, h2, slope2, rho2);

%% Banked transition: Starts at h3, ends at h4

%Third transition (between zero-G and bank)

%% Third segment - Helix: Starts at h4, ends at h5

%Fourth transition (between bank and helix)

%% Braking section: Starts at h5, ends at hf

%Final transition (between helix and braking section)