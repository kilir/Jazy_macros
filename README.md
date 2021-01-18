# Jazy_macros
Some macros for imageJ to assist with image analysis related tasks


Jazy_stripper: 			stripstar implementation used to deduce distributions of spheres from 
			        distributions of 2D cross secional areas
				(Bonus: plots distributions and determines the 3D mode using a simple kde)
			   			

Jazy_whatever_map:		grain property mapping from binary grain maps (properties available so far: area,  
			    	area equivalent diameter, equivalent diameter (perimeter corrected), aspect ratio,
			    	axial ratio, long axis trend, circularity, solidity, long axis of best fit ellipse)
			    		

Jazy_Env_map: 			grain property mapping involving convex hull-related grain shape properties
				(properties available so far: Paris factor, delta area, delta perimeter, delta radius)
						

Jazy_map_from_results: 			grain property mapping from the result file. The user needs to set the desired measurements
						and whatever is found in the results table will be mapped. Useful for data obtained through redirect 
						measurements
                    

Jazy_sparfor: 			surfor/paror/sparor implementation in imageJ, derives the projection function of boundary 
				segments and plot a length weighted segment trend distribution (rose diagram)
				and the characteristic shape
						

Jazy_XY_export_header:		produce input file with smoothed, interpolated coordinates of particles from a
				binary image which can be used in programs such as paror, surfor, ishapes (fortran)


Legacy macros:

Jazy_ACF: 			autocorrelation function related macros

Jazy_LUT:			look-up table operations

Jazy_background: 		background corrections

Jazy_boundaries: 		segmentation helpers used for create grain (boundary) maps

Jazy_erodilate: 		image cleaning helpers for binary images

Jazy_Voronoi: 			spatial distribution analysis, based on grain contacts, plots
						surface, grain area or frequency normalized results and the 
						binomial distribution
 
