//Version 0.0.14a
//-----------------------------------------------------------------------------------------
//-----------------------------------Map-particle-porperties-to-image----------------------
//---------------------------------------------ImageJ--------------------------------------
// todo : holes will not be filled, however, maybe one could ask the user if this is desired


macro "invert inverted LUT [z]"{
run("Invert LUT");
run("Invert");
}

macro "invert image [i]"{
run("Invert"); 
}

macro "whatevera map [a]"
{

//function calc_filcol(fval,user_max_val,user_min_val)
// shoudl calculate a color within the range
// maxC-minC, e.g. 1-255 or 0-254
// from values fval within the user supplied (or measured) 
// range user_min_val, user_max_val				
function calc_filcol(fval,user_max_val,user_min_val,maxC,minC) {
	return (((fval-user_min_val)/(user_max_val-user_min_val))*(maxC-minC))+minC
	}


	
//adapted from ROI color coder
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




// global minC maxC values (range of in LUT) - might be overwritten locally
minC=1;
maxC=254;


if(is("binary") == 1){
autoUpdate(false);
setBatchMode(true);
print("\\Clear");
roiManager("reset");
run("Select None");

otit = getTitle;

//--------------------------------create-info-dialog-------------------------------------------------	
Dialog.create("Info");
Dialog.addMessage("Use WHITE particles on BLACK background \n and do NOT use an inverted LUT.");
Dialog.show();

//--------------------------------create-info-dialog-------------------------------------------------	
Dialog.create("More Info");
Dialog.addMessage("This macro will set 'Process->Binary->Options...' \n to BLACK background. If you rely on white background, \n make sure to reset it afterwards.");
Dialog.show();


//--------------------------------1st measurement -------------------------------------------------	
// interesting option to set to make it work...form binary meanu
run("Options...", "iterations=1 count=1 black do=Nothing");
setThreshold(255,255);
// run this to get rid of particles touching edge ------------------------------------------------
run("Set Measurements...", "area redirect=None decimal=1");
run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Masks exclude clear");
run("Invert LUT");
run("Select None");
run("Remove Overlay");
rename(otit +"map_of_");

//selectWindow("Log");
//run("Close");
//selectWindow("ROI Manager");
//run("Close");
//run("Make Binary");


//--------------------------------create-map-type-dialog-------------------------------------------------	
Dialog.create("Select map type");
  items = newArray("Area", "Diameter", "DiameterCorr", "Aspect ratio", "Axial ratio" , "Angle" , "Circularity" , "Solidity" , "ElliLength" ,"ShapeFactor1");
  Dialog.addRadioButtonGroup("Maptype", items, 9, 1, "Area");
  Dialog.show;
  maptype = Dialog.getRadioButton;

//--------------------------------create-LUT-dialog-------------------------------------------------
 Dialog.create("Choose LUT ");
luts= getLutList();
Dialog.addChoice("LUT:", luts, luts[1]);
Dialog.show;	
luttype = Dialog.getChoice;
//print(luttype);

//--------------------------------measure-something---------------------------------------------------

run("Clear Results");

run("Set Measurements...", "area center perimeter fit shape redirect=None decimal=5");
run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing exclude clear record add");
// starting coordinates of each particle - later used for filling
n=roiManager("count");
xstart = newArray(n);
ystart = newArray(n);
for (i=0; i<roiManager("count"); i++){
        xstart[i] = getResult("XStart",i);
        ystart[i] = getResult("YStart",i);       
}


if (maptype =="Area"){ //----------------------------AREA[0 - ++]---------------------------------------------------
	qtype = "Area";
	maxval = 0;
	minval = getWidth * getHeight;
	}

if (maptype =="Diameter"){ //----------------------------Diameter--[0 - ++]-------------------------------------------------
	qtype = "Area";
	maxval = 0;
	minval = 2 * sqrt((getWidth * getHeight)/PI);
	}

if (maptype =="DiameterCorr"){ //----------------------------DiameterCorr--[0 - ++]-------------------------------------------------
	qtype = "Area";
	maxval = 0;
	minval = 2 * sqrt((getWidth * getHeight)/PI);
	}

if (maptype =="Aspect ratio"){ //----------------------------Aspect ratio--[1 - ++]-------------------------------------------------
	qtype = "AR";
	maxval = 0;
	minval = sqrt((getHeight * getHeight)+(getWidth * getWidth));
	}

if (maptype =="Axial ratio"){ //----------------------------Axial ratio--[0 - 1]------------------------------------------------
	qtype = "Round";
	maxval = 0;
	minval =1;
	}

if (maptype =="Angle"){ //----------------------------Angle-[0 - 180]--------------------------------------------------
	qtype = "Angle";
	//luttype = "Spectrum";
	maxval = 0;
	minval = 180;
	}

if (maptype =="Circularity"){ //----------------------------Circularity--[0 - 1]----------------------------------------------
	qtype = "Circ.";
	maxval = 0;
	minval = 1;
	}

if (maptype =="Solidity"){ //----------------------------Solidity---[0 - 1]------------------------------------------------
	qtype = "Solidity";
	maxval = 0;
	minval = 1;
	}

if (maptype =="ElliLength"){ //----------------------------ElliLength---[0 - ++1]------------------------------------------------
	qtype = "Major";
	maxval = 0;
	minval = getWidth * getHeight;
	}

if (maptype =="ShapeFactor1"){ //----------------------------ShapeFactor1---[1 - ++]------------------------------------------------
	qtype = "Nan";
	maxval = 0;
	minval = 100;
	}

//---------------------------get-max-min--------------------------------------------------------
// get results
n=nResults;
// initialize arrays
val=newArray(n);

// in case of adding diameter with perimeter,
// rescale to pixels
getPixelSize(un, ppx, ppy); // ppx/ppy is units/pixel

if (maptype =="DiameterCorr"){
	for (i=0;i<n; i++){
    	val[i] = getResult("Area",i) / pow(ppx,2) + getResult("Perim.",i)/ppx; 
	}

}else if (maptype =="ShapeFactor1"){
	for (i=0;i<n; i++){
    	val[i] = getResult("Perim.",i) / (2 * PI * sqrt(getResult("Area",i) / PI));
    	print(val[i]);
	}
	
}else {
	for (i=0;i<n; i++){
    	val[i] = getResult(qtype,i);      
	}
}
Array.getStatistics(val, min, max, mean, stdDev);
	
// special case for radius
if (maptype =="Diameter"){
	max=2 * sqrt(max/PI);
	min=2 * sqrt(min/PI);
}

if (maptype =="DiameterCorr"){
	max=2 * sqrt(max/PI) * ppx;
	min=2 * sqrt(min/PI) * ppx;
}


//------------------------ask-what-limits-to-use--------------------------------------------------------
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

//timer
t1=getTime();

//------------------------calculate-color-----------------------------------------------------------

for (i=0; i<roiManager("count"); i++){

        roiManager("select",i);
        run("Measure", "show=Nothing");

        fval = getResult(qtype);
        
		if (maptype =="Diameter"){
        	fval = 2* sqrt(fval/PI);
		}
		if (maptype =="DiameterCorr"){
        	fval = 2 * sqrt(val[i]/PI) * ppx;
		}	
		if (maptype =="ShapeFactor1"){
			fval = val[i];
    	}

		
        filcol = calc_filcol(fval,user_max_val,user_min_val,maxC,minC);
        //print(filcol);
        setForegroundColor(filcol, filcol, filcol);
    	//floodFill(xstart[i],ystart[i]);
        roiManager("Fill");

	   // write out results
	   setResult(maptype,i,fval);
       }
updateResults();

}

run(luttype);
getLut(reds, greens, blues);
reds[0]=255;
greens[0]=255;
blues[0]=255;

setLut(reds, greens, blues);
rename(getTitle +maptype);
//set label
setMetadata("Label", maptype);
//run("Invert");
run("Remove Overlay");

//print(minC);
//print(maxC);
//print(user_min_val);
//print(user_max_val);

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


