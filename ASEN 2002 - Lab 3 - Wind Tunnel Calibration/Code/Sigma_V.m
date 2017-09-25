function [sigmaV] = Sigma_V(velocity_test_matrices, isManometerComparison,...
                                 pitot_air_velocity, venturi_air_velocity, ...
                                 P_Diff_Vec_mano, VelMatrix_trans)

                             
    %Constants for Pitot Static and Venturi
    A2 = 1;
    A1 = 9.5;
    R_Air = 286.9;

    % taking partials
    sigma_T_Atm = 0.25; % degrees celcius
    sigma_Delta_P_mano = 51.4387; % Pa
    sigma_Delta_p_trans = 68.9476; % 1 percent of the range which is 1 psid which is 6.89 pa
    sigma_P_Atm = 3450; % 1.5 PERCENT OF THE FULL SCALE SPAN FROM 20-250 KPA
     
                             
    if isManometerComparison
        
        %Initialize variables for Pitot Static
        Delta_P_trans = VelMatrix_trans(:, 3); %Change in pressure of Pitot Static
        T_Atm_trans = VelMatrix_trans(:, 2); %Atmospheric Temperature Pitot Static
        P_Atm_trans = VelMatrix_trans(:, 1); %Atmospheric Pressure Pitot Static
         
        Delta_P_mano = P_Diff_Vec_mano;
        P_Atm_mano = [ 83961.0762, 83964.5, 83960.8748, 83963.493, 83972.1532];
        T_Atm_mano = [ 304.29825, 304.3048, 304.3115, 304.30505, 304.29535 ];
        
        syms Delta_P_sym T_Atm_sym P_Atm_sym
        q_pitot =  sqrt( (2 * Delta_P_sym) .* ((R_Air .* T_Atm_sym) ./ (P_Atm_sym)) );
        
        dq_d_deltaP_pitot = diff(q_pitot, Delta_P_sym);
        dq_dPatm_pitot = diff(q_pitot, P_Atm_sym);
        dq_dTatm_pitot = diff(q_pitot, T_Atm_sym);
        
        
        sym_array = {Delta_P_sym P_Atm_sym T_Atm_sym};
        exact_array_trans = {Delta_P_trans P_Atm_trans T_Atm_trans}; %transducer
        exact_array_mano = {Delta_P_mano P_Atm_mano T_Atm_mano}; %manometer
        
        % Transducer Uncertainty
        dq_d_deltaP_exact_trans = double( subs(dq_d_deltaP_pitot, sym_array, exact_array_trans) );
        dq_dPatm_exact_trans = double( subs(dq_dPatm_pitot, sym_array, exact_array_trans) );
        dq_dTatm_exact_trans = double( subs(dq_dTatm_pitot, sym_array, exact_array_trans) );
        
        % Manometer Uncertainty
        dq_d_deltaP_exact_mano = double( subs(dq_d_deltaP_pitot, sym_array, exact_array_mano) );
        dq_dPatm_exact_mano = double( subs(dq_dPatm_pitot, sym_array, exact_array_mano) );
        dq_dTatm_exact_mano = double( subs(dq_dTatm_pitot, sym_array, exact_array_mano) );
        
        
        % calculate error terms to be added in quadrature (Transducer)
        dq_d_deltaP_sigma_delta_p_trans = dq_d_deltaP_exact_trans * sigma_Delta_p_trans;
        dq_dPatm_sigma_P_Atm_trans = dq_dPatm_exact_trans * sigma_P_Atm;
        dq_dTatm_sigma_T_Atm_trans = dq_dTatm_exact_trans * sigma_T_Atm;
        
        % calculate error terms to be added in quadrature (Manometer)
        dq_d_deltaP_sigma_delta_p_mano = dq_d_deltaP_exact_mano * sigma_Delta_P_mano;
        dq_dPatm_sigma_P_Atm_mano = dq_dPatm_exact_mano * sigma_P_Atm;
        dq_dTatm_sigma_T_Atm_mano = dq_dTatm_exact_mano * sigma_T_Atm;
        
        % use general error formula to sum all of the above errors in
        % quadrature (transducer)
        sigmaV_trans = sqrt( dq_d_deltaP_sigma_delta_p_trans .^2 + dq_dPatm_sigma_P_Atm_trans .^2 + ...
                          dq_dTatm_sigma_T_Atm_trans .^2 );              
                      
        % use general error formula to sum all of the above errors in
        % quadrature (Pitot Static)
        sigmaV_mano = sqrt( dq_d_deltaP_sigma_delta_p_mano .^2 + dq_dPatm_sigma_P_Atm_mano .^2 + ...
                          dq_dTatm_sigma_T_Atm_mano .^2 );
        
        sigmaV = {sigmaV_trans, sigmaV_mano};
        
    else % quantify error overall
        
        
        %Initialize variables for Pitot Static
        Delta_P_PS = velocity_test_matrices{1,1}(:, 3); %Change in pressure of Pitot Static
        T_Atm_PS = velocity_test_matrices{1,1}(:, 2); %Atmospheric Temperature Pitot Static
        P_Atm_PS = velocity_test_matrices{1,1}(:, 1); %Atmospheric Pressure Pitot Static

        %Initialize variables for Venturi Tube
        Delta_P_VT = velocity_test_matrices{1,2}(:, 3); %Change in Pressure of Venturi Tube
        T_Atm_VT = velocity_test_matrices{1,2}(:, 2); %Atmospheric Temperature Venturi Tube
        P_Atm_VT = velocity_test_matrices{1,2}(:, 1); %Atmospheric Pressure Venturi Tube
        
        
        syms Delta_P_sym T_Atm_sym P_Atm_sym
        q_venturi = sqrt( (2 * Delta_P_sym .* R_Air .* T_Atm_sym) ./ (P_Atm_sym .* (1 - (A2/A1)^2)) );
        q_pitot =  sqrt( (2 * Delta_P_sym) .* ((R_Air .* T_Atm_sym) ./ (P_Atm_sym)) );


        dq_d_deltaP_venturi = diff(q_venturi, Delta_P_sym);
        dq_dPatm_venturi = diff(q_venturi, P_Atm_sym);
        dq_dTatm_venturi = diff(q_venturi, T_Atm_sym);

        dq_d_deltaP_pitot = diff(q_pitot, Delta_P_sym);
        dq_dPatm_pitot = diff(q_pitot, P_Atm_sym);
        dq_dTatm_pitot = diff(q_pitot, T_Atm_sym);

        sym_array = {Delta_P_sym P_Atm_sym T_Atm_sym};
        exact_array_PS = {Delta_P_PS P_Atm_PS T_Atm_PS}; %Pitot Static
        exact_array_VT = {Delta_P_VT P_Atm_VT T_Atm_VT}; %Venturi Tube

        %Pitot Static
        dq_d_deltaP_exact_PS = double( subs(dq_d_deltaP_pitot, sym_array, exact_array_PS) );
        dq_dPatm_exact_PS = double( subs(dq_dPatm_pitot, sym_array, exact_array_PS) );
        dq_dTatm_exact_PS = double( subs(dq_dTatm_pitot, sym_array, exact_array_PS) );

        %Venturi Tube
        dq_d_deltaP_exact_VT = double( subs(dq_d_deltaP_venturi, sym_array, exact_array_VT) );
        dq_dPatm_exact_VT = double( subs(dq_dPatm_venturi, sym_array, exact_array_VT) );
        dq_dTatm_exact_VT = double( subs(dq_dTatm_venturi, sym_array, exact_array_VT) );

        % calculate error terms to be added in quadrature (Pitot Static)
        dq_d_deltaP_sigma_delta_p_PS = dq_d_deltaP_exact_PS * sigma_Delta_p_trans;
        dq_dPatm_sigma_P_Atm_PS = dq_dPatm_exact_PS * sigma_P_Atm;
        dq_dTatm_sigma_T_Atm_PS = dq_dTatm_exact_PS * sigma_T_Atm;

        % calculate error terms to be added in quadrature (Venturi)
        dq_d_deltaP_sigma_delta_p_VT = dq_d_deltaP_exact_VT * sigma_Delta_p_trans;
        dq_dPatm_sigma_P_Atm_VT = dq_dPatm_exact_VT * sigma_P_Atm;
        dq_dTatm_sigma_T_Atm_VT = dq_dTatm_exact_VT * sigma_T_Atm;
                  
        % use general error formula to sum all of the above errors in
        % quadrature (Pitot Static)
        sigmaV_PS = sqrt( dq_d_deltaP_sigma_delta_p_PS .^2 + dq_dPatm_sigma_P_Atm_PS .^2 + ...
                          dq_dTatm_sigma_T_Atm_PS .^2 );
                      
        % use general error formula to sum all of the above errors in
        % quadrature (Pitot Static)
        sigmaV_VT = sqrt( dq_d_deltaP_sigma_delta_p_VT .^2 + dq_dPatm_sigma_P_Atm_VT .^2 + ...
                          dq_dTatm_sigma_T_Atm_VT .^2 );
                      
        sigmaV = {sigmaV_PS, sigmaV_VT};
                      

        %% Plotting

        %Overlay plots of error to find largest contributing source of error
        %contributing to velocity for Pitot Static
        hFig = figure;
        set(hFig, 'Position', [100 100 1600 900])

        plot(pitot_air_velocity, dq_d_deltaP_sigma_delta_p_PS, 'LineWidth', 2)
        hold on
        plot(pitot_air_velocity, dq_dPatm_sigma_P_Atm_PS, 'LineWidth', 2)
        plot(pitot_air_velocity, dq_dTatm_sigma_T_Atm_PS, 'LineWidth', 2)

        set(gca,'FontSize', 28)
        xlim([min(pitot_air_velocity), max(pitot_air_velocity)])
        ylim([0, inf])
        xlabel('Velocity (m/s)');
        ylabel('Uncertainty in Velocity (m/s)');
        title('Pitot Static Error');
        legend (sprintf('\\Delta Pressure Uncertainty'),'Atmospheric Pressure Uncertainty','Atmospheric Temperature Uncertainty');
        hold off

        %Overlay plots of error to find largest contributing source of error
        %contributing to velocity for Venturi Tubes
        hFig = figure;
        set(hFig, 'Position', [100 100 1600 900])

        plot(venturi_air_velocity, dq_d_deltaP_sigma_delta_p_VT, 'LineWidth', 2)
        hold on
        plot(venturi_air_velocity, dq_dPatm_sigma_P_Atm_VT, 'LineWidth', 2)
        plot(venturi_air_velocity, dq_dTatm_sigma_T_Atm_VT, 'LineWidth', 2)

        set(gca,'FontSize', 28)
        xlim([min(venturi_air_velocity), max(venturi_air_velocity)])
        ylim([0, inf])
        xlabel('Velocity (m/s)');
        ylabel('Uncertainty in Velocity (m/s)');
        title('Venturi Tube Error');
        legend (sprintf('\\Delta Pressure Uncertainty'),'Atmospheric Pressure Uncertainty','Atmospheric Temperature Uncertainty');
        hold off

       

    end
              
end


