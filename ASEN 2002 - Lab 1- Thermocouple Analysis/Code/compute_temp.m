clear
clc

sum_v = input('Please enter the measured voltage (uV).\n');
t_ref = input('Please enter the reference temperature (C).\n');
object_uncertainty = input('object uncertainty in uV: ');
is_there_system_bias = input('is there a systematic bias? ');

if is_there_system_bias == 1
    bias = input('system bias in uV: ');
else
    bias = 0;
end

ref_v = tempToVolt(t_ref);

disp('Reference Voltage in uV is:');
disp(ref_v);
    
v = sum_v + ref_v - bias;
disp('The voltage of the object in uV is:');
disp(v);

t_meas = voltToTemp(v);
disp('The measured temperature in C is:');
disp(t_meas);

v_high = v + object_uncertainty;
v_low = v - object_uncertainty;

t_high = voltToTemp(v_high);
t_low = voltToTemp(v_low);
t_error = t_high - t_low;
fprintf('The Temperature Error in C is:\n\t%f\n', t_error);
