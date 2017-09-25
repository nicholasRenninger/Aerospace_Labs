To run our software, make sure the test input file is in the same directory as the .m file:

..\Sub Group Code\Sub_Group_2_Renn_Soto

And it is extracted from the .zip file, or MATLAB will not find the input files.

The main Monte Carlo simulation is a function called truss3d_main_simulation.m in the Sub_Group_2_Renn_Soto 
folder. It takes two input arguments:

	1) the input file name ex. "design_RS.txt"
	2) a true/false identifier
		True: run cycle of monte carlo simulations to determine FOS based on covergence
                       of probabilities of failure.
		
		 False: only run monte carlo simulation once
                        with FOS = 1 for analyzing external loading.



Sample function calls look like this:


>> truss3d_main_simulation('design_RS.txt', true) - Runs Monte Carlo Simulations until 
						    Probabilities Converge, to find optimal FOS
						    For more info on how this works
							- see Sec. IIc in lab document


>> truss3d_main_simulation('design_RS_extLoads.txt', false) - Runs only 1 Monte Carlo Simulation 
							      w/ FOS = 1 to find probability of failure
							      of basic truss design with an external load applied
							      This sample file contains the actual external
							      loading that caused failure in overall chosen design.



To run just one analysis on truss design, see output file w/ all bar forces, and see two truss visualizations
use truss3d in the Truss_3d_code_RS folder in this directory:

..\Sub Group Code\Sub_Group_2_Renn_Soto\Truss_3d_code_RS

like this:

>> truss3d('design_RS.txt', 'design_RS_out.txt') - output file is second argument, will print results to this file


- Nicholas Renninger