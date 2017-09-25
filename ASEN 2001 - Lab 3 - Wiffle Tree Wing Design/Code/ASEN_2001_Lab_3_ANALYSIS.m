clear
close all
clc

%% Input

%%% reading in Input Files
ASEN_2001_Lab_3_readInput

heightFoam = 0.01905; % meters
heightBalsa = 0.0015875/2; % meters
distToCentroid = 0.009921875; % meters
c = 0.01031875; % meters

% define Youngs Modulus 
E_balsa = 3.0e9; % Pa
E_foam = 0.03e9; % Pa


%% calculate shear and moment diagrams for each test
TestData = data_cells{1, 1};
numberTests = length(TestData);

% initializations
x = zeros(numberTests, 1);
moment = zeros(numberTests, 1);
shear = zeros(numberTests, 1);

% initialize indicies of bending and shear stress vectors
bending_index = 1;
shear_index = 1;

% calculating shear and bending stress for every test
for i = 1:numberTests

    % test parameters from data file
    a = TestData(i, 3);
    F = TestData(i, 2);
    d_f = TestData(i, 5);
    w = TestData(i, 4);
    
   
    % calc moment and shear at point of failure
    [~, ~, ~, moment_d_f, shear_d_f] = ASEN_2001_Lab_3_moments_shear(a, F, d_f);
    
    % storing moments and shear
    moment(i) = moment_d_f;
    shear(i) = shear_d_f;
    
    % calc area of Foam
    A_f = heightFoam * w;
    
    % calculating second moment of area
    I_f = (1/12) * (heightFoam)^3 * w; % second moment for foam 

    PAT = heightBalsa * w * (distToCentroid)^2; % parallel axis theorem
    I_b = 2 * ( ( (w * heightBalsa^3) / 12 ) + PAT ); % second moment for balsa
    
    % calculate flexure and shear stress for each test
    curr_flexureStress = abs( (moment_d_f * c) / (I_b + (E_foam / E_balsa) * I_f) );
    curr_shearStress = (3/2) * ( shear_d_f / A_f );
    
    if curr_flexureStress > curr_shearStress % failed in bending
       
        % include current flexure stress if it was failure-causing
        flexureStress(bending_index) = curr_flexureStress;
        bending_index = bending_index + 1;
        
    else % failed in shear
    
        % include current shear stress if it was failure-causing
        shearStress(shear_index) = curr_shearStress;
        shear_index = shear_index + 1;
        
    end
    
        
end

%% Finding P_o

% Design using chosen FOS
FOS = 1.5;

% max flexure stress found by filtering bending failure data
max_flex_stress = 7.043878520620971e+06; % Pa

flex_stress_allow = max_flex_stress / FOS; % Pa


    
