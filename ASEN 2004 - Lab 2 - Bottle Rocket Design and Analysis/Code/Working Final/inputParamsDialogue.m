function inputParamsDialogue
    
    %% define conversion constants:
    PSI_TO_PA  = 6894.76; % [psi] -> [Pa]
    G_TO_KG = 1/1000; % [g] -> [kg]
    F_TO_K = @(T_f) (T_f + 459.67) * (5/9); % [def F] -> [K]
    MPH_TO_MPS = 0.44704; % [mph] -> [m/s]

    
    %% get user input
    prompt = {'Guage Pressure in Rocket, P_{o, air} (psi):', ... % sens. var
              'Propellent Mass (g):', ... % sens. var
              'C_D', ... % sens. var
              'Launch Angle, \theta, (deg):', ... % sens. var
              'Propellent Density, \rho, (kg / m^3)', ... % sens. var
              'Dry Mass of Rocket (g):', ... % other global var
              'Air Temperature (\circF):', ... % other global var
              'Ambient Air Pressure (Pa):', ... % other global var 
              'Surface Wind Magnitude (mph):', ... % other global var
              'Surface Wind Direction (Cardinal-deg from N):', ...
              'Winds Aloft Magnitude (mph):', ... % other global var
              'Winds Aloft Direction (Cardinal-deg from N):', ...
              };

    name = 'Launch Conditions';
    defaultans = {'39', ...
                  '550', ...
                  '0.439', ...
                  '45', ...
                  '1000', ...
                  '131', ...
                  '65', ...
                  '82943.93', ...
                  '0', ...
                  '0', ...
                  '0', ...
                  '0', ...
                  };
    options.Interpreter = 'tex';
    params = inputdlg(prompt, name, [1 50], defaultans, options);
    
    if isempty(params)
        return % user pressed cancel
    end


    %% convert inputed params to correct units
    for i = 1:length(params)
        params{i} = str2double(params{i});
    end

    params{1} = (params{1} * PSI_TO_PA) + params{8}; % [Pa]
    params{2} = (params{2} * G_TO_KG) / params{5}; % [m^3], calc vol. of prop
    params{3} = params{3}; % [unitless]
    params{4} = deg2rad(params{4}); % [rad]
    params{5} = params{5}; % [kg / m^3]
    params{6} = params{6} * G_TO_KG; % [kg]
    params{7} = F_TO_K(params{7}); % [K]
    params{8} = params{8}; % [Pa]
    params{9} = params{9} * MPH_TO_MPS; % [m/s]
    params{10} = deg2rad(params{10}); % [rad]
    params{11} = params{11} * MPH_TO_MPS; % [m/s]
    params{12} = deg2rad(params{12}); % [rad]

    % set global sens. vars:
    global_sens_conditions = [params{1}, ...
                              params{2}, ...
                              params{3}, ...
                              params{4}, ...
                              params{5}];
    
    setSensGlobals(global_sens_conditions);

    % set other global vars
    global_other_conditions = {params{6}, ...
                               params{7}, ...
                               params{8}, ...
                               [params{9}, params{10}, 0], ...
                               [params{11}, params{12}, 0]};

    setOtherGlobals(global_other_conditions);

    
    
end 