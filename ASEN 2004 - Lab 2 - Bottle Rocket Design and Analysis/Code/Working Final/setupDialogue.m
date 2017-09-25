function settings = setupDialogue

% Call setup to make settings dialogue box
[settings, ~] = settingsdlg(...
   'Description'                        , ['Set Constants', ...
                                          ''], ...
   'title'                              , 'Bottle Rocket Setup', ...
   'separator'                          , 'Plotting', ...
   {['Save Figures to ', ...
    '..\..\Figures\?']; 'check'}        , true, ...
   'separator'                          , 'Sensitivity Analysis', ...
   {['Number of Sensitivity',...
    'Iteterations']; ...
    'num_sens_iter'}                    , 200, ...
    'separator'                         , 'Monte Carlo', ...
   {['Number of Monte Carlo',...
    'Iteterations']; ...
    'num_mc_iter'}                      , 200, ...
   'separator'                          , 'General Setup', ...
   'Model to Use'                       , {'New Thermo Model', ...
                                           'ISP Model', ...
                                           'Thrust Interpolation Model', ...
                                           'Old Thermo Model'});

end
   
       