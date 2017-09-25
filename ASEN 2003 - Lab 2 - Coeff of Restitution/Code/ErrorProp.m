function totError = ErrorProp(func, dependents, vals, dependentError)
    
    %%% totError = ErrorProp(func, dependents, vals, dependentError)
    %%%
    %%% Uses a numeric formulation of the general error propogation formula
    %%% to calculate the total uncertainty of calculated value based on 
    %%% the uncertainty in the measurements used to compute the value.
    %%%
    %%% Ex. function call:
    %%%
    %%%     syms ho hn 
    %%%     e = @(ho,hn) ((hn/ho).^(1/2));
    %%%     sigma_ho = 0.1;
    %%%     sigma_hn = 0.2;
    %%%     sigma_e = ErrorProp(e,[hn ho], [10, 8], [sigma_ho, sigma_hn]);
    %%%
    %%% Inputs: 
    %%%        - func: inline function that maps the measures values to the
    %%%                calculated value.
    %%%
    %%%        - dependents: symbolic arguments to func, i.e. the
    %%%                      measurement variables that might have error in
    %%%                      them.
    %%%
    %%%        - vals: values of the dependent variables when used to
    %%%                calculate the independen variable.
    %%%
    %%%        - dependentError: the uncertainty in the measured values of
    %%%                          the dependent variables.
    %%%                      
    %%% Author: Jeffrey Mariner Gonzalez - modified from a ...
    %%% Date Created: 2/5/17
    %%% Last Modified: 2/15/17
    %%%
    
    %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%
    
    x = numel(dependents);
    temp = vpa(ones(1,x));

    % Compute Partials
    for i = 1:x
       temp(i) = diff(func,dependents(i),1); 
    end

    % Sum in quadrature to compute general error
    totError = sqrt( ( sum( (subs(temp,dependents,vals).^2) .* ...
                            (dependentError.^2) ) ) );
    totError = double(totError);

end