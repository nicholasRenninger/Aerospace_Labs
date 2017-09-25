function [index] = height_to_index(PLOT_SAMPLES, max_height, height)
    
    
    height_vec = linspace(0, max_height, PLOT_SAMPLES);
    
    index = find( height_vec == height );
    
    
end