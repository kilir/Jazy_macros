//Version 0.0.4a
// Difference to Lazy grainboundareis: as black is 0, thicken lines must work with copy (AND)
// instead with copy (OR) and "max of stack" will be "min" of stack
//-----------------------------------------------------------------------------------------
//-----------------------------------Grain-boundary-segmentation-helpers-------------------
//-----------------------------------------------------------------------------------------
macro"RGB to stack[0]"{
run("RGB Stack");
}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
macro "crop and scale - fast [1]"{
if (selectionType != -1){
 run("Crop");
//ask for scale factor
scalefactor = 2;
Dialog.create("scaling factor");
Dialog.addMessage("scaling factor");
Dialog.addNumber("   ", scalefactor);
Dialog.show();
scalefactor = Dialog.getNumber();
run("Scale...", "x="+scalefactor+" y="+scalefactor+" interpolation=None process create title="+getTitle+"scaled.tif");

}else{
showMessage("Selection required");
}		
}
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
macro "crop and scale - smooth [2]"{
if (selectionType != -1){
 run("Crop");
//ask for scale factor
scalefactor = 2;
Dialog.create("scaling factor");
Dialog.addMessage("scaling factor");
Dialog.addNumber("   ", scalefactor);
Dialog.show();
scalefactor = Dialog.getNumber();
run("Scale...", "x="+scalefactor+" y="+scalefactor+" interpolation=Bicubic process create title="+getTitle+"scaled.tif");

}else{
showMessage("Selection required");
}		
}
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
macro "Median filter [u]"{
radius = 1;
Dialog.create("median radius");
Dialog.addMessage("radius for median filter");
Dialog.addNumber("radius (pixel)= ", radius);
Dialog.show();
radius = Dialog.getNumber();	
run("Median...", "radius="+radius+" stack")
}
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
macro "Sobel filter [o]"{
run("Find Edges", "stack");
}
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
macro "sharpen [s]"{
run("Sharpen", "stack");
}
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
macro "enhance [c]"{
satur = 1;
Dialog.create("saturated pixels");
Dialog.addMessage("saturated pixels");
Dialog.addNumber("in % = ", satur);
Dialog.show();
satur = Dialog.getNumber();	
run("Enhance Contrast...", "saturated="+satur+" normalize process_all")
}
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
macro "equalize [e]"{
satur = 0.4;
Dialog.create("saturated pixels");
Dialog.addMessage("saturated pixels");
Dialog.addNumber("in % = ", satur);
Dialog.show();
satur = Dialog.getNumber();	
run("Enhance Contrast...", "saturated="+satur+" equalize process_all")
}
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

//http://fiji.sc/wiki/index.php/Auto_Threshold
macro "threshold/density slice ... [T]"{
run("Threshold...");
}
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//This assumes a bimodal histogram. The histogram is iteratively smoothed using a running 
//average of size 3, until there are only two local maxima: j and k. The threshold t is then
//computed as (j+k)/2. Images with histograms having extremely unequal peaks or a broad and 
//ﬂat valley are unsuitable for this method.

macro "threshold Intermodes [I]"{
run("Convert to Mask", "method=Intermodes background=White calculate");
run("Invert LUT");
run("Invert");
}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
macro "threshold Mean [M]"{
run("Convert to Mask", "method=Mean background=White calculate");
run("Invert LUT");
run("Invert");
}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
	
macro "threshold Huang [H]"{
run("Convert to Mask", "method=Huang background=White calculate");
run("Invert LUT");
run("Invert");
}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
macro "average of stack [a]"{
if (nSlices >= 1){
run("Z Project...", "start=1 stop="+nSlices+" projection=[Average Intensity]");
}else{
showMessage("Stack required");}	
}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
macro "min of stack [z]"{ //
if (nSlices >= 1){
run("Z Project...", "start=1 stop="+nSlices+" projection=[Min Intensity]");
}else{
showMessage("Stack required");}	
}


//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
macro "thicken lines [t]"{
if (nSlices == 1){
run("Select All");
run("Copy");
setPasteMode("AND");
setSelectionLocation(1,0);
run("Paste");
setSelectionLocation(0,1);
run("Paste");
setPasteMode("COPY");
}else{
showMessage("single slice image required");}	
}
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
macro "skeletonize [j]"{
run("Skeletonize", "stack");
}
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
macro "prune [i]"{
run("Options...", "iterations=10 count=7 edm=Overwrite do=Erode stack");
}
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
macro "cut away rim (boundary map) [4]"{
	
xwidth = getWidth();
yheight = getHeight();
rimc = 5;
Dialog.create("width of rim");
Dialog.addMessage("width of rim");
Dialog.addNumber("in pixel",rimc);
Dialog.show();
rimc = Dialog.getNumber();

makeRectangle(rimc, rimc, xwidth-2*rimc, yheight-2*rimc);
run("Make Inverse")
run("Clear")
run("Select None");
setForegroundColor(0, 0, 0);
floodFill(1,1);

}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
macro "cut away rim (grain map) [5]"{
	
xwidth = getWidth();
yheight = getHeight();
rimc = 5;
Dialog.create("width of rim");
Dialog.addMessage("width of rim");
Dialog.addNumber("in pixel",rimc);
Dialog.show();
rimc = Dialog.getNumber();

makeRectangle(rimc, rimc, xwidth-2*rimc, yheight-2*rimc);
run("Make Inverse")
setForegroundColor(0, 0, 0);
fill();
run("Select None");
setForegroundColor(255, 255, 255);
floodFill(1,1);
}
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "invert image [y]"{
run("Invert");
}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
macro "scale to pixel  [x]"{
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
