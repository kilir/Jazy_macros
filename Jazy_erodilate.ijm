//Version 0.0.1a
//-----------------------------------------------------------------------------------------
//-----------------------------------Ero-Dilate-helpers------------------------------------
//-----------------------------------------------------------------------------------------

macro "erode image strongest [1]"{
run("Options...", "iterations=1 count=1 edm=Overwrite do=Erode slice");
}
macro "erode image ... [2]"{
run("Options...", "iterations=1 count=2 edm=Overwrite do=Erode slice");
}
macro "erode image ... [3]"{
run("Options...", "iterations=1 count=3 edm=Overwrite do=Erode slice");
}
macro "erode image ... [4]"{
run("Options...", "iterations=1 count=4 edm=Overwrite do=Erode slice");
}
macro "erode image ... [5]"{
run("Options...", "iterations=1 count=5 edm=Overwrite do=Erode slice");
}
macro "erode image ... [6]"{
run("Options...", "iterations=1 count=6 edm=Overwrite do=Erode slice");
}
macro "erode image ... [7]"{
run("Options...", "iterations=1 count=7 edm=Overwrite do=Erode slice");
}
macro "erode image weakest [8]"{
run("Options...", "iterations=1 count=8 edm=Overwrite do=Erode slice");
}

macro "dilate image strongest [a]"{
run("Options...", "iterations=1 count=1 edm=Overwrite do=Dilate slice");
}
macro "dilate image ... [b]"{
run("Options...", "iterations=1 count=2 edm=Overwrite do=Dilate slice");
}
macro "dilate image ... [c]"{
run("Options...", "iterations=1 count=3 edm=Overwrite do=Dilate slice");
}
macro "dilate image ... [d]"{
run("Options...", "iterations=1 count=4 edm=Overwrite do=Dilate slice");
}
macro "dilate image ... [e]"{
run("Options...", "iterations=1 count=5 edm=Overwrite do=Dilate slice");
}
macro "dilate image ... [f]"{
run("Options...", "iterations=1 count=6 edm=Overwrite do=Dilate slice");
}
macro "dilate image ... [g]"{
run("Options...", "iterations=1 count=7 edm=Overwrite do=Dilate slice");
}
macro "dilate image weakest [h]"{
run("Options...", "iterations=1 count=8 edm=Overwrite do=Dilate slice");
}


macro "back to saved [x]"{
run("Revert");
}


macro "reset LUT [r]"{
run("Grays");
//run("Invert");
}


macro "scale to pixel  [x]"{
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
}


macro "invert image [r]"{
run("Invert");
}

macro "invert LUT [z]"{
run("Invert LUT");
}

macro "apply inverted LUT [c]"{
getLut(reds,greens, blues);
reds = Array.reverse(reds);
greens = Array.reverse(greens);
blues = Array.reverse(blues);
setLut(reds, greens, blues);
}


macro "make binary [l]"{
run("make Binary");
}


macro "Median filter [m]"{
radius = 1;
Dialog.create("median radius");
Dialog.addMessage("radius for median filter");
Dialog.addNumber("radius (pixel)= ", radius);
Dialog.show();
radius = Dialog.getNumber();	
run("Median...", "radius="+radius+" stack")
}


macro "prune [i]"{
run("Options...", "iterations=10 count=7 edm=Overwrite do=Erode stack");
}


macro "skeletonize [j]"{
run("Skeletonize", "stack");
}

macro "outline [O]"{
run("Outline");
}

macro "thicken lines [t]"{
if (nSlices == 1){
run("Select All");
run("Copy");
setPasteMode("OR");
setSelectionLocation(1,0);
run("Paste");
setSelectionLocation(0,1);
run("Paste");
}else{
showMessage("single slice image required");}	
}


macro "super thicken lines [w]"{
if (nSlices = 1){
run("Select All");
run("Copy");
setPasteMode("OR");
setSelectionLocation(1,0);
run("Paste");
setSelectionLocation(0,1);
run("Paste");
setSelectionLocation(-1,0);
run("Paste");
setSelectionLocation(0,-1);
run("Paste");
}else{
showMessage("single slice image required");}	
}




macro "minimum filter image [u]"{
run("Minimum...");
}

macro "maximum filter image [v]"{
run("Maximum...");
}
