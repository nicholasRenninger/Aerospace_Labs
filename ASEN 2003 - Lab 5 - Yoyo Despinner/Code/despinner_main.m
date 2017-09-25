%{
The purpose of this code...

Written by:
Created: 3/21
Last modified:
%}

%% Declare constants
%spacecraft constants
I = 165; %lb(m)*in^2, total moment of inertia without despin masses
R = 4.25; %in, outer radius
%convert to metric
I = I*0.453592*0.00064516^2; %(lb(m)*in^2)*(kg/lb(m))*(m^2/in^2)=kg*m^2
R = R*0.00064516; %(in)*(m/in)=m

%despin mass constants
m = 125/1000; %grams*kg/g = kg

%% Calculations for tangential release of despinners
%Constants specific to this section:
w = 100; %rpm, initial angular velocity

%Calculate the required length, L, of the string and time of deployment
despinner_tangential(I, R, m, w_0);

%% Calculations for radial release of despinners
%Constants specific to this section:      ????
w = 100; %rpm, initial angular velocity   ????

%Calculate angular acceleration and velocity of satellite, and tension in
%string
despinner_radial(I, R, m, w_0); %matrix with columns [a (rad/s^2), w (rad/s), T (N), t(s)]
