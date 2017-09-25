function AIAAplot( datacell, labelcell, linespecs )
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%                                                                 %%%
    %%%                                                                 %%%
    %%% PURPOSE: To make AIAA formatted plots with nice stuffs          %%%
    %%%                                                                 %%%
    %%% INPUTS:                                                         %%%
    %%%     datacell: a cell containing {xdata, ydata, zdata}           %%%
    %%%                                                                 %%%
    %%%     xdata: a cell containing the x data(s) for line(s)          %%%
    %%%                                                                 %%%
    %%%     ydata: a cell containing the y data(s) for line(s)          %%%
    %%%                                                                 %%%
    %%%     zdata: a cell containing the z data(s) for line(s)          %%%
    %%%                                                                 %%%
    %%%     labelcell: a cell containing {xlabel, ylabel, zlabel,       %%%
    %%%                title, legend}                                   %%%
    %%%                                                                 %%%
    %%%     xlabel: a string containing the x label                     %%%
    %%%                                                                 %%%
    %%%     ylabel: a string containing the y label                     %%%
    %%%                                                                 %%%
    %%%     zlabel: a string containing the z label                     %%%
    %%%                                                                 %%%
    %%%     title: a string containing the title                        %%%
    %%%                                                                 %%%
    %%%     legend: a cell containing the legend entries                %%%
    %%%                                                                 %%%
    %%%     linespecs: a cell containing {colors, linetype}             %%%
    %%%                                                                 %%%
    %%%     colors: a cell containing the line colors (strings or       %%%
    %%%             [r,g,b])                                            %%%
    %%%                                                                 %%%
    %%%     linetype: a cell containing the line style(s) and point     %%%
    %%%               style(s)                                          %%%
    %%%                                                                 %%%
    %%% OUTPUTS:                                                        %%%
    %%% Dank memes and/or plots                                         %%%
    %%%                                                                 %%%
    %%% DATE CREATED: 01 March 2017                                     %%%
    %%%                                                                 %%%
    %%% DATE LAST EDITED: 17 March 2017                                 %%%
    %%%                                                                 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%                                                                 %%%
    %%% INTERNAL VARIABLES:                                             %%%
    %%% FontSize: the size of the font for the axis labels and legend   %%%
    %%%                                                                 %%%
    %%% TitleFontSize: the size of the font for the title               %%%
    %%%                                                                 %%%
    %%% FontName: the name of the font to be used throughout            %%%
    %%%                                                                 %%%
    %%% Interpreter: the interpreter to be used throughout              %%%
    %%%                                                                 %%%
    %%% AxisAdjustment: the % value to shift the axis past the original %%%
    %%% range of datapoints being plotted                               %%%
    %%%                                                                 %%%
    %%% pass: the successfulness of the color import                    %%%
    %%%                                                                 %%%
    %%% dimensions: the number of dimensions                            %%%
    %%%                                                                 %%%
    %%% entries: the number of line entries                             %%%
    %%%                                                                 %%%
    %%% stopper: how many axis labels are given                         %%%
    %%%                                                                 %%%
    %%% skip: whether or not to skip the legend to name the title       %%%
    %%%                                                                 %%%
    %%% lgnd: whether or not there is a legend                          %%%
    %%%                                                                 %%%
    %%% C_not_given: the number of line color(s) not accounted for in   %%%
    %%%              the inputs                                         %%%
    %%%                                                                 %%%
    %%% colorlist: an imported variable containing cool colors          %%%
    %%%                                                                 %%%
    %%% pass: if the loading of colorlist was successful                %%%
    %%%                                                                 %%%
    %%% L_not_given: the number of line type(s) not accounted for in    %%%
    %%%              the inputs                                         %%%
    %%%                                                                 %%%
    %%% xhold: holds the default x axis limits                          %%%
    %%%                                                                 %%%
    %%% yhold: holds the default y axis limits                          %%%
    %%%                                                                 %%%
    %%% zhold: holds the default z axis limits                          %%%
    %%%                                                                 %%%
    %%% xrange: the default x axis range                                %%%
    %%%                                                                 %%%
    %%% yrange: the default y axis range                                %%%
    %%%                                                                 %%%
    %%% zrange: the default z axis range                                %%%
    %%%                                                                 %%%
    %%% xadj: the adjustment to the bounds of the x axis limits         %%%
    %%%                                                                 %%%
    %%% yadj: the adjustment to the bounds of the y axis limits         %%%
    %%%                                                                 %%%
    %%% zadj: the adjustment to the bounds of the z axis limits         %%%
    %%%                                                                 %%%
    %%% xmin: the new minimum value for the x axis                      %%%
    %%%                                                                 %%%
    %%% ymin: the new minimum value for the y axis                      %%%
    %%%                                                                 %%%
    %%% zmin: the new minimum value for the z axis                      %%%
    %%%                                                                 %%%
    %%% xlim: the limits for the x axis                                 %%%
    %%%                                                                 %%%
    %%% ylim: the limits for the y axis                                 %%%
    %%%                                                                 %%%
    %%% zlim: the limits for the z axis                                 %%%
    %%%                                                                 %%%
    %%% h: if hold on is currently applied                              %%%
    %%%                                                                 %%%
    %%% a: the current axes                                             %%%
    %%%                                                                 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Demo Mode
    
    % if no inputs given
    if ~any( nargin )
        
        % this generates a really cool set of lines for plotting
        t = linspace( -100 * pi, 100 * pi, 10^5);
        
        x = { ( t.^4 .* sin(t) .* cos(t) ) / ( 5 .* 10.^9 ), ...
              ( asin(t).^3 ) / 200, ...
              ( t.^4 .* sin(t) .* cos(t) ) / ( 5 .* 10.^9 ) };
        
        y = { ( asin(t).^3 ) / 200, ...
              ( t.^4 .* sin(t) .* cos(t) ) / ( 5 .* 10.^9 ), ...
              ( cos(t) .* t.^3 ) / ( 4 .* 10.^7 ) };
        
        z = { ( cos(t) .* t.^3 ) / ( 4 .* 10.^7 ), ...
              ( cos(t) .* t.^3 ) / ( 4 .* 10.^7 ), ...
              ( asin(t).^3 ) / 200 };
          
        datacell = { x, y, z };
        
        labelcell = { '$\textnormal{X Label}$', ...
                      '$\textnormal{Y Label}$', ...
                      '$\textnormal{Z Label}$', ...
                      { '$\textnormal{Line 1}$', ...
                        '$\textnormal{Line 2}$', ...
                        '$\textnormal{Line 3}$' }, ...
                      '$\textnormal{Demo Plot}$' };
        
        linespecs = { { 'r', 'g', 'b' } };
        
        AIAAplot( datacell, labelcell, linespecs )
        
        return;
        
    end
    
    %% Initialization
    
    FontSize = 20;
    
    TitleFontSize = 20;
    
    MarkerSize = 5;
    
    LineWidth = 2;
    
    FontName = 'timesnewroman';
    
    Interpreter = 'latex';
    
    AxisAdjustment = 5;
    
    % pass is the successfulness of the color import
    pass = 1;
    
    try
        
        colorlist = load('ColorList.mat');
        
    catch
        
        pass = 0;
        
    end
    
    %% Examining datacell:
    
    dimensions = 0;
    
    entries = 0;
    
    % checking to make sure more than one dimension
    if isa( datacell, 'cell' ) && ~isempty( datacell )
        
        % n is the length of datacell
        dimensions = length( datacell );
        
        % checking for multiple line entries
        if isa( datacell{1}, 'cell' )
            
            % number of line entries
            entries = length( datacell{1} );
            
            [ xdata, ydata, zdata ] = deal( cell( 1, entries ) );
            
            for i = 1:entries
                
                % n is the number of data points in each entry
                n = length( datacell{1}{i} );
                
                for j = 1:n
                    
                    xdata{i}(j) = datacell{1}{i}(j);
                    
                    if dimensions >= 2
                        
                        ydata{i}(j) = datacell{2}{i}(j);
                        
                    end
                    
                    if dimensions >= 3
                        
                        zdata{i}(j) = datacell{3}{i}(j);
                        
                    end
                    
                end
                
            end
        
        else
            
            % only one line of values
            entries = 1;
            
            % in case 1-3 vectors are given
            xdata = datacell(1);
            
            if dimensions >= 2
                
                ydata = datacell(2);
                
            end
            
            if dimensions >= 3
                
                zdata = datacell(3);
                
            end
            
        end
        
    elseif ~isempty( datacell )
        
        % only one dimensioned
        dimensions = 1;
        
        entries = 1;
        
        % only a vector given
        xdata = {datacell};
        
    end
    
    % creating blanks for non-existing inputs
    if nargin < 3
        
        linespecs = cell(0);
        
        if nargin < 2
            
            labelcell = cell(0);
            
        end
        
    end
    
    %% Examining labelcell:
    
    % if the labelcell is a cell
    if isa( labelcell, 'cell' )
        
        % n is the labelcell length
        n = length( labelcell );
        
        % stopper indicates how many labels have been given
        stopper = 0;
        
        xlabel = '';
        
        ylabel = '';
        
        zlabel = '';
        
        % if the dimension is greater than one
        % and the length is at least one
        test1 = ( dimensions > 1 ) && ( 1 <= n );
        
        % if the dimension is one
        % and at least one label given
        test3 = ( dimensions == 1 ) && ( 1 <= n );
        
        if test1
            
            % making sure the legend is not given by itself
            if ~isa( labelcell{1}, 'cell' )
            
                xlabel = labelcell{1};
                
            else
                
                % no labels given (string so ~any returns a 0)
                stopper = '0';
                
            end
            
        elseif test3
            
            % making sure the legend is not given by itself
            if ~isa( labelcell{1}, 'cell' )
                
                % since 1D data gets plotted vs the input #, if one label
                % is given it is intended as the ylabel
                ylabel = labelcell{1};
                
            else
                
                % no labels given (string so ~any returns a 0)
                stopper = '0';
                
            end
            
        end
        
        % if the dimension is at least two, the length is at least two,
        % and the legend has not already been given
        test1 = ( ( dimensions >= 2 ) && ( 2 <= n ) ) && ~any( stopper );
        
        % if is 1D and more than one label is given
        test3 = ( ( dimensions == 1 ) && ( 2 <= n ) ) && ~any( stopper );
        
        if test1
            
            % if the next entry is not the legend
            if ~isa( labelcell{2}, 'cell' )
                
                ylabel = labelcell{2};
                
            else
                
                % one label given
                stopper = 1;
                
            end
            
        elseif test3
            
            % if the next entry is not the legend
            if ~isa( labelcell{2}, 'cell' )
                
                % the first label was intended as the xlabel
                xlabel = ylabel;
                
                % and the second as the ylabel
                ylabel = labelcell{2};
                
                % only the xy plane is shown for 1D lines
                stopper = 2;
                
            else
                
                % one label given
                stopper = 1;
                
                
            end
            
        end
        
        % if the dimension is at least 3, the length is at least 3,
        % and the legend has not already been given
        test1 = ( ( dimensions >= 3 ) && ( 3 <= n ) ) && ~any( stopper );
        
        if test1
            
            % if the next entry is not the legend
            if ~isa( labelcell{3}, 'cell' )
                
                zlabel = labelcell{3};
                
                % three labels given
                stopper = 3;
                
            else
                
                % two labels given
                stopper = 2;
                
            end
            
        end
        
        if isa( stopper, 'char' )
            
            % make it a number if it is '0'
            stopper = str2double( stopper );
            
        end
        
        % if there is a title or not
        skip = 0;
        
        title = '';
        
        % if there is a legend or not
        lgnd = 0;
        
        % since stopper indicates how many labels there are, stoper + 1 is
        % the label after the last axis label (IE the title or legend)
        if n >= stopper + 1
            
            % if the next value is not the legend
            if ~isa( labelcell{stopper + 1}, 'cell' )
                
                % it is the title
                title = labelcell{stopper + 1};
                
                % and a title has been provided
                skip = 1;
                
            else % if it is the legend
                
                lgndstr = labelcell{stopper + 1};
                
                % a legend has been provided
                lgnd = 1;
                
            end
            
        end
        
        if n >= stopper + 2
            
            % check to see if title is filled
            if skip
                
                % if it is, is the next entry a cell?
                if isa( labelcell{stopper + 2}, 'cell' )
                    
                    % if it is, perfect... it shall be the legend cell
                    lgndstr = labelcell{stopper + 2};
                    
                    % legend has been provided
                    lgnd = 1;
                    
                else
                    
                    % it is a single char array and need to be stored as a
                    % cell
                    lgndstr = labelcell(stopper + 2);
                    
                    % legend has been provided
                    lgnd = 1;
                    
                end
                
            else % if the title is not filled (IE the legend is filled)
                
                % the next entry MUST be the title
                title = labelcell{stopper + 2};
                
            end
            
        end
        
    % if there is an xlabel only as a char array
    elseif ~isempty( labelcell )
        
        xlabel = labelcell(:);
        
    end
    
    %% Examining linespecs:
    
    % preallocating nothing in case nothing is given
    colors = cell(0);
    
    linetype = cell(0);
    
    % if the linespecs is a cell
    if isa( linespecs, 'cell' )
        
        % n is the linespecs length
        n = length( linespecs );
        
        if n >= 1
            
            % if it is a cell
            if isa( linespecs{1}, 'cell' )
                
                % perfect, save it as that
                colors = linespecs{1};
                
            else % if it is a single char array
                
                % save it as a 1x1 cell
                colors = linespecs(1);
                
            end
            
        end
        
        if n >= 2
            
            % if it is a cell
            if isa( linespecs{2}, 'cell' )
                
                % perfect, save it as that
                linetype = linespecs{2};
                
            else % if it is a single char array
                
                % save it as a 1x1 cell
                linetype = linespecs(2);
                
            end
            
        end
        
    % if there is only one colors entry as a char array
    elseif ~isempty( linespecs )
        
        colors = {linespecs(:)};
        
    end
    
    % finding the number of colors not given
    C_not_given = entries - length( colors );
    
    if C_not_given < 0
        
        C_not_given = 0;
        
    end
    
    % for all of the colors not given
    for i = 1:C_not_given
        
        % if the cool colors have been loaded
        if pass
            
            % n is the length of the colorlist
            n = size( colorlist, 1 );
            
            % fill in the missing colors with cool ones
            colors{ length( colors ) + 1 } = colorlist{ randi( n ), 2 };
            
        else % if the cool colors haven't been loaded
            
            % fill them in with not cool random ones
            colors{ length( colors ) + 1 } = [ rand, rand, rand ];
            
        end
        
    end
    
    % finding the number of linetypes not given
    L_not_given = entries - length( linetype );
    
    if L_not_given < 0
        
        L_not_given = 0;
        
    end
    
    % for all of the line types not given
    for i = 1:L_not_given
        
        % just make it a standard line
        linetype{ length( linetype ) + 1 } = '-';
        
    end
    
    %% Plotting
    
    % if hold was previously applied
    h = ishold;
    
    hold on;
    
    % for all of the datasets
    for i = 1:entries
        
        % if it is 3D
        if dimensions >= 3
            
            plot3( xdata{i}, ydata{i}, zdata{i}, linetype{i}, ...
                   'markersize', MarkerSize, ...
                   'linewidth', LineWidth, 'color', colors{i} )
            
             % if it is 2D
        elseif dimensions >= 2
            
            plot( xdata{i}, ydata{i}, linetype{i},  ...
                  'markersize', MarkerSize, ...
                  'linewidth', LineWidth, 'color', colors{i} )
            
        else % if it is 1D
            
            plot( xdata{i}, linetype{i},  ...
                  'markersize', MarkerSize, ...
                  'linewidth', LineWidth, 'color', colors{i} )
            
        end
        
    end
    
    % the current axes
    a = gca;
    
    % defining all of the things
    set(a.XLabel, 'Interpreter', Interpreter)
        
    set(a.XLabel, 'String', xlabel)
    
    set(a.XLabel, 'FontSize', FontSize)
    
    set(a.XLabel, 'FontName', FontName)
    
    set(a.YLabel, 'Interpreter', Interpreter)
    
    set(a.YLabel, 'String', ylabel)
    
    set(a.YLabel, 'FontSize', FontSize)
    
    set(a.YLabel, 'FontName', FontName)
    
    set(a.ZLabel, 'Interpreter', Interpreter)
    
    set(a.ZLabel, 'String', zlabel)
    
    set(a.ZLabel, 'FontSize', FontSize)
    
    set(a.ZLabel, 'FontName', FontName)
    
    set(a.Title, 'Interpreter', Interpreter)
    
    set(a.Title, 'String', title)
    
    set(a.Title, 'FontSize', TitleFontSize)
    
    set(a.Title, 'FontName', FontName)
    
    if lgnd
        
        legend(lgndstr, 'Location', 'best', 'Interpreter', Interpreter, ...
               'FontSize', FontSize, 'FontName', FontName)
        
    end
    
    % editing the axes so data is not on the edges of the graph
    xhold = get(a, 'XLim');
    
    yhold = get(a, 'YLim');
    
    zhold = get(a, 'ZLim');
    
    xrange = xhold(2) - xhold(1);
    
    yrange = yhold(2) - yhold(1);
    
    zrange = zhold(2) - zhold(1);
    
    xadj = xrange * AxisAdjustment / 100;
    
    yadj = yrange * AxisAdjustment / 100;
    
    zadj = zrange * AxisAdjustment / 100;
    
    xmin = xhold(1) - xadj;
    
    xmax = xhold(2) + xadj;
    
    ymin = yhold(1) - yadj;
    
    ymax = yhold(2) + yadj;
    
    zmin = zhold(1) - zadj;
    
    zmax = zhold(2) + zadj;
    
    xlim = [ xmin, xmax ];
    
    ylim = [ ymin, ymax ];
    
    zlim = [ zmin, zmax ];
    
    set(a, 'XLim', xlim)
    
    set(a, 'YLim', ylim)
    
    set(a, 'ZLim', zlim)
    
    % setting the viewpoint if need be (this is a good 3D angle)
    if dimensions >= 3
        
        view(45, 45)
        
    end
    
    % returning hold to its original setting
    if ~h
        
        hold off
        
    end
    
end