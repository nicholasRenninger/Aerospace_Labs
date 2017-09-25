%%% Calculating Moments and Shear forces along bar due to 4 point bending
%%% test

function [x, moments, shear, moment_d_f, shear_d_f] = ASEN_2001_Lab_3_moments_shear(a, F, d_f)
   
    % defininf conversion factors
    IN_TO_METER = 0.0254;

    % total length of bar in m
    length_bar = 36 * IN_TO_METER;

    % overhang of bar past support in m
    overhang = 1.5 * IN_TO_METER; 

    % distance between two supports in m
    dist_supported = length_bar - (2 * overhang);

    % defining distance from support to where force is applied - a in m

    % define distance between two applied loads
    b = dist_supported - (2 * a);

    % define applied force in N
    R_1 = F / 2;

    % create x vector, distance from left support to every point along the
    % bar in m
    x = linspace(0, dist_supported, 1000);

    % create Moment and Shear vector for every point along x direction of Bar
    moments = zeros(1, length(x));
    shear = zeros(1, length(x));

    
    % default values for moment and shear at failure
    moment_d_f = 0;
    shear_d_f = 0;
    
    
    %%

    %%% Define 3 Regions along the Bar - 3 sets of eqns. for Moment and Shear

    %% region 1: 0 < x <= a

    % vector of x position in the range of the current region
    x_0_to_a = x( x <= a );

    % use equation for bending moment in first region of bar
    moments( 1:length(x_0_to_a) ) = x_0_to_a * R_1;
    
    % calc moments and shear at d_f 
    if 0 < d_f  && d_f <= a
        
       moment_d_f =  d_f * R_1;
       
       shear_d_f = R_1;
       
    end
    
    % use equation for internal shear in first region of bar
    shear( 1:length(x_0_to_a) ) = R_1;


    %% region 2: a < x <= a + b

    % find where a < x <= a + b
    indeces_of_current_region = logical( ( (x <= ( a + b )) .* (a < x) ) );

    % vector of x position in the range of the current region
    x_a_to_ab = x( indeces_of_current_region );

    final_x_index = length(x_0_to_a) + length(x_a_to_ab);
    start_end_current_region = length(x_0_to_a) + 1:final_x_index;

    % use equation for bending moment in first region of bar
    moments( start_end_current_region ) = (x_a_to_ab * R_1) - ( (x_a_to_ab - a) * (F / 2) );
    
    % calc moments and shear at d_f 
    if a < d_f  && d_f <= a + b
        
       moment_d_f =  (d_f * R_1) - ( (d_f - a) * (F / 2) );
       
       shear_d_f = 0;
       
    end

    % use equation for internal shear in first region of bar
    shear( start_end_current_region ) = 0;


    %% region 3: a + b < x <= 2a + b

    % find where a < x <= a + b
    indeces_of_current_region = logical( ( (x <= ( 2*a + b )) .* ( (a+b) < x ) ) );

    % vector of x position in the range of the current region
    x_ab_to_2ab = x( indeces_of_current_region );

    initial_x_index =  length(x_0_to_a) + length(x_a_to_ab);
    final_x_index = initial_x_index + length(x_ab_to_2ab);
    start_end_current_region = initial_x_index + 1:final_x_index;

    % use equation for bending moment in first region of bar
    moments( start_end_current_region ) = (x_ab_to_2ab * R_1) - (F/2) * (2*x_ab_to_2ab - 2*a - b);
    
    % calc moments and shear at d_f 
    if a + b < d_f  && d_f <= 2*a + b
        
       moment_d_f =  (d_f * R_1) - (F/2) * (2*d_f - 2*a - b);
       
       shear_d_f = -(F/2);
       
    end

    % use equation for internal shear in first region of bar
    shear( start_end_current_region ) = -(F/2);
    
    
end

