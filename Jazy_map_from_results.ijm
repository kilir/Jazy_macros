//Version 0.0.3a
//-----------------------------------------------------------------------------------------
//-------------------------------plot-property from-results-----------------------------------
//---------------------------------------------ImageJ--------------------------------------
// Map any property from the results table, e.g. also suitable for redirected measurements
// The user must set set the measurements before the macro is run


macro "colorize something from results file"{

// start here-------------------------------------------------------------------------------------
	if(is("binary") == 1){
// set batch mode and prepare to clean everything
autoUpdate(false);
setBatchMode(true);
print("\\Clear");
roiManager("reset");
run("Select None");

// global minC maxC values (range of in LUT) - might be overwritten locally
minC=1;
maxC=254;

//--------------------------------read-results-file------------------------------------------------	
Dialog.create("Info");
Dialog.addMessage("This macro will measure particles and colorize any chosen result. Make sure properties are set properly.");
Dialog.show();

//--------------------------------analyze------------------------------------------------	
Dialog.create("Exclude edges");
Dialog.addMessage("Exclude particles touching the edges?"); 
Dialog.addCheckbox("Yes", true)
Dialog.show;
choice =  Dialog.getCheckbox();
if (choice==true){
run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing exclude clear record");
} else{
run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing clear record");
}
//--------------------------------create-map-type-dialog-------------------------------------------------

//Returns the label of the specified row in the results table, or an empty string if Display 

  Dialog.create("map choice");
  headings = split(String.getResultsHeadings);
  len=lengthOf(headings);
  Dialog.addChoice("maptype", headings, 1);
  Dialog.show;
  maptype = Dialog.getChoice;

 // how many grains where there
 nold=nResults;

// copy map type property to array
n=nResults;
plotprop = newArray(n);
for (i=0;i<n; i++){
        plotprop[i] = getResult(maptype,i);     
}
for (i=0;i<n; i++){
        print(plotprop[i]);     
}
//--------------------------------create-LUT-dialog-------------------------------------------------
 Dialog.create("Choose LUT ");
luts= getLutList();
Dialog.addChoice("LUT:", luts, luts[1]);
Dialog.show;	
luttype = Dialog.getChoice;

//-----------starting coordinates of each particle - later used for filling--------------------

n=nResults;
x = newArray(n);
y = newArray(n);
for (i=0;i<n; i++){
        x[i] = getResult("XStart",i);
        y[i] = getResult("YStart",i);       
}

//------------------------ask-what-limits-to-use--------------------------------------------------------

Array.getStatistics(plotprop, min, max, mean, stdDev);
	
 // query for user input of maxval
Dialog.create("max" +maptype+"");
Dialog.addMessage("Maximal "+maptype+"");
Dialog.addNumber("user_max_val:", max);
Dialog.show();
user_max_val = Dialog.getNumber();

// query for user input of minval
Dialog.create("min" +maptype+"");
Dialog.addMessage("Minimal "+maptype+"");
Dialog.addNumber("user_min_val:", min);
Dialog.show();
user_min_val = Dialog.getNumber();

//------------------------calculate-color-----------------------------------------------------------
for (i=0;i<n; i++){
    filcol = calc_filcol(plotprop[i], user_max_val,user_min_val,maxC,minC);
    //print(filcol);
    if (filcol > 254) // prevent silly colors
    		{
       		filcol = 254;
       		}
    if (filcol == 0) // make those with prop 0 not the same color as background
    		{
       		filcol = 1;
       		}   		
    setForegroundColor(filcol, filcol, filcol);
    doWand(x[i],y[i]);
    fill();
}
// clean up
run("Select None");
run("Remove Overlay");
//set lut
run(luttype);
// set background and edge particles color
getLut(reds, greens, blues);
reds[0]=255;
greens[0]=255;
blues[0]=255;
reds[255]=255;
greens[255]=255;
blues[255]=255;
setLut(reds, greens, blues);
rename(getTitle +maptype);
//set label
setMetadata("Label", maptype);
//run("Invert");
run("Remove Overlay");

if (minC > 0){
   minC= minC;
   }
   
if (maxC < 255){
   maxC= maxC;
   }

   print(minC);
   print(maxC); 
   print(user_min_val);
   print(user_max_val);

run("Calibrate...", "function=[Straight Line] unit=[Unit] text1=["+minC+" "+maxC+"] text2=["+user_min_val+" "+user_max_val+"]");
height = getHeight;
zoom = floor(height/999)+1;
run("Calibration Bar...", "location=[Lower Left] fill=[White] label=Black number=5 decimal=2 font=10 zoom="+zoom+" bold");
//set label
setMetadata("Label", maptype);
//print(getTime()-t1);
//updateResults();
autoUpdate(true);
setBatchMode("exit and display");
}else{
showMessage("binary image required");	
}


// prep functions -----------------------------------------------------------------------------
// calc colors - might reequire adaption depending on the range of value (0-1, 1-inf, 0-inf)
//function calc_filcol(fval,user_max_val){
//	return (254*fval/user_max_val);
//	}

function calc_filcol(fval,user_max_val,user_min_val,maxC,minC) {
	return (((fval-user_min_val)/(user_max_val-user_min_val))*(maxC-minC))+minC
	}

//adapted from ROI color coder for the LUT choice menue
function getLutList() {
  luts= getFileList(getDirectory("luts"));
  for (i=0, count=0; i<luts.length; i++)
      if (endsWith(luts[i], ".lut"))
          count++;
  list= newArray(count+3);
  list[0]= "Fire"; list[1]= "Ice"; list[2]= "Spectrum";
  for (i=0, j=3; i<luts.length; i++)
      if (endsWith(luts[i], ".lut"))
          list[j++]= substring(luts[i], 0, lengthOf(luts[i])-4);
  return list;
}	


	
}
