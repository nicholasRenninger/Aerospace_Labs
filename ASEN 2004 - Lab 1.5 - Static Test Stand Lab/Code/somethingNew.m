function [ water_mass, pressure, temp, group_num, time, thrust, ISP ] = ...
    somethingNew( filename )

    %%% Author: Marshall Herr & Nicholas Renninger
    %%%
    %%% Purpose: To load a STS datafile, extract the relavent information,
    %%% correct the thrust for the sensors, and calculate ISP
    %%%
    %%% Inputs:
    %%% filename: the file location name for the datafile
    %%%
    %%% Outputs:
    %%% water_mass: the mass of water used [kg]
    %%%
    %%% pressure: the pressure inside of the bottle [Pa]
    %%%
    %%% temp: the temperature [K]
    %%%
    %%% group_num: the group number
    %%%
    %%% time: the time vector for the data [s]
    %%%
    %%% thrust: the thrust vector for the data [N]
    %%%
    %%% ISP: the specific impulse [s]
    %%%
    %%% Date Created: 12 April 2017
    %%%
    %%% Last Editted: 19 April 2017
    
    %% Error Checking
    
    % generating file ID
    fID = fopen( filename );
    
    % extracting as string
    string = textscan( fID, '%c' );
    
    % while the file is being stored in a 1x1 cell array
    while isa( string, 'cell' )
        
        string = string{1};
        
    end
    
    % if it is a column vector instead of a row vector
    if ( size( string, 2 ) == 1 ) && ( length( string ) ~= 1 )
        
        % transpose it
        string = string';
        
    end
    
    % to search for numbers
    number_string = double( string );
    
    % extracting the char_to_double for numbers
    num_chars = '0123456789.';
    
    % initialization
    num_local = zeros( 1, length( string ) );
    
    for i = 1: length( num_chars )
        
        % determining the double equivalent
        num = double( num_chars(i) );
        
        % finding any location with the number
        % by adding them together it becomes effectively a big or statement
        num_local = num_local + ( number_string == num );
        
    end
    
    % for simplicity
    string = lower( string );
    
    % find where the data rate is located
    rate_local = strfind( string, 'frequency' );
    
    % if not reported for some reason
    if ~any( rate_local )
        
        error( 'Data rate not reported.' )
        
    end
    
    % finding the first number after 'water'
    num_start = find( num_local( rate_local : end ), 1, 'first' ) + ...
        rate_local - 1;
    
    % finding the first non-number after the first number
    num_end = find( ~num_local( num_start : end ), 1, 'first' ) + ...
        num_start - 2;
    
    % extracting the water mass ( should be kHz when extracted )
    rate = str2double( string( num_start : num_end ) ) * 1000; % s^-1
    
    % find where the water mass is located
    water_local = strfind( string, 'water' );
    
    % if not reported for some reason
    if ~any( water_local )
        
        error( 'Water mass not reported.' )
        
    end
    
    % finding the first number after 'water'
    num_start = find( num_local( water_local : end ), 1, 'first' ) + ...
        water_local - 1;
    
    % finding the first non-number after the first number
    num_end = find( ~num_local( num_start : end ), 1, 'first' ) + ...
        num_start - 2;
    
    % extracting the water mass ( should be grams when extracted )
    water_mass = str2double( string( num_start : num_end ) ) / 1000; % kg
    
    % test if the data is of the TA baseline or not
    if water_mass > 1.05
        error('Test Data in %s used too much water: %0.3gkg', filename, ...
                                                              water_mass)
    elseif water_mass < 0.98
        error('Test Data in %s used too little water: %0.3gkg', filename, ...
                                                                water_mass)
    end
    
    % find where the pressure is located
    pressure_local = strfind( string, 'pressure' );
    
    % if not reported for some reason
    if ~any( pressure_local )
        
        error( 'Pressure not reported.' )
        
    end
    
    % finding the first number after 'pressure'
    num_start = find( num_local( pressure_local : end ), 1, 'first' ) + ...
        pressure_local - 1;
    
    % finding the first non-number after the first number
    num_end = find( ~num_local( num_start : end ), 1, 'first' ) + ...
        num_start - 2;
    
    % extracting the pressure ( should be psi when extracted )
    pressure = str2double( string( num_start : num_end ) ) * 6894.76; % Pa
    
    % find where the temperature is located
    temp_local = strfind( string, 'temperature' );
    
    % if not reported for some reason
    if ~any( temp_local )
        
        error( 'Temperature not reported.' )
        
    end
    
    % finding the first number after 'temperature'
    num_start = find( num_local( temp_local : end ), 1, 'first' ) + ...
        temp_local - 1;
    
    % finding the first non-number after the first number
    num_end = find( ~num_local( num_start : end ), 1, 'first' ) + ...
        num_start - 2;
    
    % extracting the temperature ( should be C when extracted )
    temp = str2double( string( num_start : num_end ) ) + 273.15; % K
    
    % find where the group number is located
    group_num_local = strfind( string, 'group' );
    
    % if not reported for some reason
    if ~any( group_num_local )
        
        error( 'Group Number not reported.' )
        
    end
    
    % extracting the group number
    group_num = str2double( filename(end-22:end-21) );
    
    %% Pull Out Data
    
    % importing the thrust data
    data = load( filename );
    
    % is in lbf when extracted
    thrust = data( :, 3 )' * 4.44822; % N
    
    % finding max thrust and location
    [ ~, max_local ] = max( thrust );
    
    % finding when the thrusting began (last negative is right before
    % thrust)
    thrust_start = find( thrust( 1 : max_local ) < 0, 1, 'last' );
    
    % cutting out pre-thrust data
    thrust = thrust( thrust_start : end ); % N
    
    thrust_start = find( thrust > 5, 1, 'first' );
    
    thrust = thrust( thrust_start : end ); % N
    
    % inverting data and smoothing
    search_thrust = -thrust;
    
    % really, really smooth it out
        
    search_thrust = smooth( search_thrust );
        
    [ ~, thrust_end ] = max( search_thrust );
    
    % cutting out post thrust data
    thrust = thrust( 1 : thrust_end ); % N
    
    time = linspace( 0, length( thrust ), length( thrust ) ) ./ rate; % s

    % creating points for sensor adjustment correction
    point1 = [ time(1), 0 ];
    
    point2 = [ time(end), thrust(end) ];
    
    slope = ( point2(2) - point1(2) ) / ( point2(1) - point1(1) ); % N s^-1
    
    % the amount the sensor has adjusted
    adjustment = slope .* time; % N
    
    
%     figure()
%     
%     plot( time, thrust, 'b' )
%     
%     hold on
%     
%     plot( time, adjustment, 'r' )
    
    
    % adjusting thrust to correct for sensors
    thrust = thrust - adjustment; % N
    
    water_weight = water_mass * 9.81; % N
    
    % total I [N s] divided by water weight [N] to get ISP [s]
    ISP = trapz( time, thrust ) / water_weight; % s
    
    % plot( time, thrust, 'm' )
    
    fclose(fID);
    
end