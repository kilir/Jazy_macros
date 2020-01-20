//Version 0.0.2a
//-----------------------------------------------------------------------------------------
//-------------------------------plot-property from-file-----------------------------------
//---------------------------------------------ImageJ--------------------------------------

// this macro should take a user imported value and assign a color-coding to each particle
// input e.g. ishapes, must be saved as a tab delimited text and for now should not contain
// any discarded particles
// needs testing

macro "invert inverted LUT [z]"{
run("Invert LUT");
run("Invert");
}
//---------------------------------------------------------------------------------------------
macro "invert image [i]"{
run("Invert");
}
//---------------------------------------------------------------------------------------------

macro "colorize any function from the results file"{

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

//--------------------------------create-info-dialog-------------------------------------------------	
Dialog.create("info");
Dialog.addMessage("select a file with tab-seperated columns of same length as grains");
Dialog.show();


// select file
run("Results... ", "open=");


//--------------------------------create-map-type-dialog-------------------------------------------------

//Returns the label of the specified row in the results table, or an empty string if Display 

Dialog.create("Radio Buttons");

  //items = newArray("paris", "deltP", "deltA", "radiusDelta");
  headings = split(String.getResultsHeadings);
  len=lengthOf(headings);
  Dialog.addRadioButtonGroup("maptype", headings, len, 1," ");
  Dialog.show;
  maptype = Dialog.getRadioButton;

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

//--------------------------------measure-something---------------------------------------------------
// and get the particles in the ROI manager
// measure just to get it in the ROI manager (it would actualyl be sufficient to use the start x,y)
run("Set Scale...", "pixel=1 unit=pixel");
run("Clear Results");
run("Set Measurements...", "area perimeter redirect=None decimal=3");

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

// starting coordinates of each particle - later used for filling
n=nResults;
x = newArray(n);
y = newArray(n);
for (i=0;i<n; i++){
        x[i] = getResult("XStart",i);
        y[i] = getResult("YStart",i);       
}


// check wheter nResults and nold are identical
if (nold !=  n)
exit("number of grain not identical");
else

//------------------------ask-what-limits-to-use--------------------------------------------------------


//print(maptype);				
// get min/max of maptype
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
    if (filcol == 0) // make those with paris factor of 0 not the same color as background
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
	
}
