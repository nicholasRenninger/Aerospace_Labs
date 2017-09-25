function choice = startDialogue

    choice = 'exit';
    d = dialog('Position',[400 200 350 200],'Name','ASEN 2004 - Lab 2 - Group 5');
    txt = uicontrol('Parent',d,...
           'Style','text',...
           'fontsize', 20, ...
           'Position',[60 150 200 40],...
           'String','Select Action');
       
    popup = uicontrol('Parent',d,...
           'Style','popup',...
           'Position',[40 80 275 40],...
           'fontsize', 20, ...
           'String',{'Calculate Trajectory';
                     'Sensitivity Analysis'; 
                     'Monte Carlo Simulation';
                     'Input Flight Conditions'; 
                     'Setup'}, ...
           'Callback', @popup_callback);
       
    close_btn = uicontrol('Parent',d,...
                'fontsize', 20, ...
                'Position',[110 10 100 40],...
                'String', 'Exit',...
                'Callback', @exit_callback);
            
       
    % Wait for d to close before running to completion
    uiwait(d);
   
   %% Call Back Functions 
   
   % selection menu call back
   function popup_callback(popup,event)
      idx = popup.Value;
      popup_items = popup.String;
      choice = char(popup_items(idx,:));
      delete(gcf)
      return
   end


   % exit button call back
   function exit_callback(~,~)
      choice = 'exit';
      delete(gcf)
      return
   end
   
       
end