//0.0.4a
//--------------------------------------------------------------------------------
//----------------------------Voronoi-helpers-------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------


macro "boundaries from phasemaps [A]"{

run("Options...", "iterations=1 count=1 black do=Nothing");
showMessage("Information" ,"The starting stack must contain 3 slices: \n 1: white surfaces \n 2: white phaseA, \n 3: white phaseB \n \n" +
"The final stack will have a total of 10 slices:" +
"\n 1: total surfaces/contacts \n 2: phaseA \n 3: phaseB \n 4: contacts AA \n 5: contacts BB \n 6: surface A " +
"\n 7: surface B  \n 8: contacts AB \n 9: grains A \n 10: grains B");

//check stack
if ( nSlices != 3){ exit("Stack of 3 required");}
else {
for (i =1; i <= nSlices; i++){
	Stack.setSlice(i);
	if(is("binary") == 1){
	}else{ exit("Binary stack required");}
	}
Stack.setSlice(3);
for (i= 1; i<=7; i++){ run("Add Slice");}

Stack.setSlice(2);
run("Select All");
run("Copy");
Stack.setSlice(4);
setPasteMode("Copy");
run("Paste");
run("Options...", "iterations=1 count=1 edm=Overwrite do=Dilate slice");


Stack.setSlice(6);
setPasteMode("Copy");
run("Paste");
run("Options...", "iterations=1 count=1 edm=Overwrite do=Erode slice");


Stack.setSlice(8);
setPasteMode("Copy");
run("Paste");
run("Options...", "iterations=1 count=1 edm=Overwrite do=Erode slice");


Stack.setSlice(3);
run("Select All");
run("Copy");
Stack.setSlice(5);
setPasteMode("Copy");
run("Paste");
run("Options...", "iterations=1 count=1 edm=Overwrite do=Dilate slice");

Stack.setSlice(7);
setPasteMode("Copy");
run("Paste");
run("Options...", "iterations=1 count=1 edm=Overwrite do=Erode slice");

Stack.setSlice(1);
run("Select All");
run("Copy");
Stack.setSlice(9);
setPasteMode("Copy");
run("Paste");
run("Invert", "slice");

Stack.setSlice(10);
setPasteMode("Copy");
run("Paste");
run("Invert", "slice");


Stack.setSlice(5);
run("Select All");
run("Copy");
Stack.setSlice(8);
run("Options...", "iterations=1 count=1 edm=Overwrite do=Erode slice");
setPasteMode("AND");
run("Paste");
setMetadata("Label", "contacts A-B");


Stack.setSlice(1);
run("Select All");
run("Copy");
Stack.setSlice(4);
setPasteMode("AND");
run("Paste");
setMetadata("Label", "contacts A-A");


Stack.setSlice(5);
setPasteMode("AND");
run("Paste");
setMetadata("Label", "contacts B-B"); 


Stack.setSlice(6);
setPasteMode("AND");
run("Paste");
setMetadata("Label", "surface A");


Stack.setSlice(7);
setPasteMode("AND");
run("Paste");
setMetadata("Label", "surface B");



Stack.setSlice(2);
run("Select All");
run("Copy");
Stack.setSlice(9);
setPasteMode("AND");
run("Paste");
setMetadata("Label", "grains A");


Stack.setSlice(3);
run("Select All");
run("Copy");
Stack.setSlice(10);
setPasteMode("AND");
run("Paste");
setMetadata("Label", "grains B"); 

setPasteMode("Copy");
}
}




//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
macro "boundaries from phasemaps -> 1px  [B]"{

run("Options...", "iterations=1 count=1 black do=Nothing");
showMessage("Information" ,"The starting stack must contain 3 slices: \n 1: white surfaces \n 2: white phaseA, \n 3: white phaseB \n \n" +
"The final stack will have a total of 10 slices:" +
"\n 1: total surfaces/contacts \n 2: phaseA \n 3: phaseB \n 4: contacts AA \n 5: contacts BB \n 6: surface A " +
"\n 7: surface B  \n 8: contacts AB \n 9: grains A \n 10: grains B \n" +
" \n Boundaries will be 1 px thick, use to count line length.");

//check stack
if ( nSlices != 3){ exit("Stack of 3 required");}
else {
for (i =1; i <= nSlices; i++){
	Stack.setSlice(i);
	if(is("binary") == 1){
	}else{ exit("Binary stack required");}
	}
Stack.setSlice(3);
for (i= 1; i<=7; i++){ run("Add Slice");}

Stack.setSlice(2);
run("Select All");
run("Copy");
Stack.setSlice(4);
setPasteMode("Copy");
run("Paste");
run("Options...", "iterations=1 count=1 edm=Overwrite do=Dilate slice");

Stack.setSlice(6);
setPasteMode("Copy");
run("Paste");
run("Options...", "iterations=1 count=1 edm=Overwrite do=Erode slice");


Stack.setSlice(8);
setPasteMode("Copy");
run("Paste");
run("Options...", "iterations=1 count=1 edm=Overwrite do=Erode slice");

Stack.setSlice(3);
run("Select All");
run("Copy");
Stack.setSlice(5);
setPasteMode("Copy");
run("Paste");
run("Options...", "iterations=1 count=1 edm=Overwrite do=Dilate slice");

Stack.setSlice(7);
setPasteMode("Copy");
run("Paste");
run("Options...", "iterations=1 count=1 edm=Overwrite do=Erode slice");

Stack.setSlice(1);
run("Select All");
run("Options...", "iterations=1 count=1 black do=Skeletonize");
setMetadata("Info", "Skeletonized");
run("Copy");
Stack.setSlice(9);
setPasteMode("Copy");
run("Paste");
run("Invert", "slice");

Stack.setSlice(10);
setPasteMode("Copy");
run("Paste");
run("Invert", "slice");

Stack.setSlice(5);
run("Select All");
run("Copy");
Stack.setSlice(8);
run("Options...", "iterations=1 count=1 edm=Overwrite do=Erode slice");
setPasteMode("AND");
run("Paste");
run("Options...", "iterations=1 count=1 black do=Skeletonize slice");
setMetadata("Label", "contacts A-B");

Stack.setSlice(1);
run("Select All");
run("Copy");
Stack.setSlice(4);
setPasteMode("AND");
run("Paste");
setMetadata("Label", "contacts A-A");


Stack.setSlice(5);
setPasteMode("AND");
run("Paste");
setMetadata("Label", "contacts B-B"); 


Stack.setSlice(6);
setPasteMode("AND");
run("Paste");
setMetadata("Label", "surface A");


Stack.setSlice(7);
setPasteMode("AND");
run("Paste");
setMetadata("Label", "surface B");


Stack.setSlice(2);
run("Select All");
run("Copy");
Stack.setSlice(9);
setPasteMode("AND");
run("Paste");
setMetadata("Label", "grains A");


Stack.setSlice(3);
run("Select All");
run("Copy");
Stack.setSlice(10);
setPasteMode("AND");
run("Paste");
setMetadata("Label", "grains B"); 

setPasteMode("Copy");
}
}




//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
macro "Make 3 slices stack from 2 [C]"{
	showMessage("Append a third slice, being the inverted of slice 2");
//check stack
if ( nSlices > 2){ showMessage("Stack has more than 2 slices. Are you sure you want to add another slice?");}
Stack.setSlice(2);
run("Add Slice");
Stack.setSlice(2);
run("Select All");
run("Copy");
Stack.setSlice(3);
setPasteMode("Copy");
run("Paste");
run("Invert", "slice");
}


//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
macro "erode image a lot (4)... [4]"{
run("Options...", "iterations=1 count=4 edm=Overwrite  black do=Erode");
}

macro "erode image  more (5)... [5]"{
run("Options...", "iterations=1 count=5 edm=Overwrite  black do=Erode");
}

macro "erode image (6)... [6]"{
run("Options...", "iterations=1 count=6 edm=Overwrite  black do=Erode");
}
macro "erode image just a bit (7)... [7]"{
run("Options...", "iterations=1 count=7 edm=Overwrite black do=Erode");
}
macro "erode image weakest (8)... [8]"{
run("Options...", "iterations=1 count=8 edm=Overwrite black do=Erode");
}


macro "dilate image even more (4)... [E]"{
run("Options...", "iterations=1 count=4 edm=Overwrite black do=Dilate");
}

macro "dilate image more (5)... [D]"{
run("Options...", "iterations=1 count=5 edm=Overwrite black do=Dilate");
}

macro "dilate image (6)... [F]"{
run("Options...", "iterations=1 count=6 edm=Overwrite black do=Dilate");
}
macro "dilate image a little (7)... [G]"{
run("Options...", "iterations=1 count=7 edm=Overwrite black do=Dilate");
}
macro "dilate image weakest (8)... [H]"{
run("Options...", "iterations=1 count=8 edm=Overwrite black do=Dilate");
}


//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
macro "invert image [y]"{
run("Invert", "slice");
}


//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------

macro "analyse processed stack [D]"{
run("Clear Results");
print("\\Clear");
otit = getTitle;
run("Set Measurements...", "mean redirect=None decimal=5");
// gather data
nPx=newArray(nSlices);
for (i=0; i<nSlices; i++){
	Stack.setSlice(i+1);
    getRawStatistics(nPixels, mean, min, max, std, histogram);
    nPx[i] = histogram[255];
}
allpx=nPixels;


// get number fractions
// work around: since we cannot assume that particles4. class will be installed everywhere
// just copy paste, thicken line and destroy
// for some reason this need to move prior to loggin-> log window is cleared
// check IF we have a skeletonized stack -based on metadata inserted in macro B
Stack.setSlice(1);
if (startsWith(getMetadata("Info"), "Skeletonized")) {
autoUpdate(false);
setBatchMode(true);
Stack.setSlice(9);
run("Duplicate...", "use");
// thicken lines
run("Select All");
run("Copy");
setPasteMode("AND");
setSelectionLocation(1,0);
run("Paste");
setSelectionLocation(0,1);
run("Paste");
setPasteMode("COPY");
run("Set Measurements...", "mean redirect=None decimal=5");
run("Analyze Particles...", "clear slice");
nA=nResults();
run("Close");
selectWindow(otit);
Stack.setSlice(10);
run("Duplicate...", "use");
run("Select All");
run("Copy");
setPasteMode("AND");
setSelectionLocation(1,0);
run("Paste");
setSelectionLocation(0,1);
run("Paste");
setPasteMode("COPY");
run("Set Measurements...", "mean redirect=None decimal=5");
run("Analyze Particles...", "clear slice");
nB=nResults();
run("Close");
autoUpdate(true);
setBatchMode(false);
selectWindow(otit);
}
else{
Stack.setSlice(9);
run("Set Measurements...", "mean redirect=None decimal=5");
run("Analyze Particles...", "clear slice");
nA=nResults();
Stack.setSlice(10);
run("Set Measurements...", "mean redirect=None decimal=5");
run("Analyze Particles...", "clear slice");
nB=nResults();
}
nPart = newArray(1);
nPart[0] = nA/(nA+nB);


// start logging
print("---------------------------------");
print(" \n  ");
print("*********************************");
print("Stack Anaylsis of  "+getTitle	);
print("*********************************");
print(" \n  ");

// area fractions
sn = newArray(1,2); // note that indexing starts at 0! so this is slice number -1
label=newArray("phaseA", "phaseB");
areaAll = newArray(2);
areaRel = newArray(2);
print("---------------------------------");
for (i=0; i<sn.length; i++){
	areaAll[i]=nPx[sn[i]]/allpx;
	areaRel[i]=nPx[sn[i]]/(nPx[1]+nPx[2]);
	print(label[i]+" pixel = \t"+nPx[sn[i]]+"\t or phase fraction = \t"+areaRel[i]+"\t or total fraction = \t"+areaAll[i]);
}
print("---------------------------------");
// surface fractions totals
sn = newArray(0,3,4,5,6,7);// note that indexing starts at 0! so this is slice number -1
label=newArray("total surface","contact AA","contact BB","surface A","surface B","contact AB" );
for (i=0; i<sn.length; i++){
	print(label[i]+"  pixel = \t"+nPx[sn[i]]+"\t and  % =\t"+nPx[sn[i]]/nPx[0]*100);
}
print("---------------------------------");

// input for plotting surface frations cp to binomial distribution
whats =newArray("surface-fraction = ", "(AA)/total boundary = ", "(BB)/total boundary = ", "(AB)/total boundary = ");
SA = (nPx[3]+nPx[5])/(nPx[3]+nPx[5]+nPx[4]+nPx[6]);//grain boundary fractions A (allA+AA)/(allA+AA+allB+BB) becaues gboundaries need to count double
Stot = nPx[3]+nPx[4]+nPx[7];
SAA = nPx[3]/Stot; //AA
SBB = nPx[4]/Stot; //BB
SAB = nPx[7]/Stot; //AB
res = newArray(SA, SAA, SBB, SAB); 
for (i=0;i<res.length;i++){
print(whats[i]+" \t "+res[i]);
}
// print number fractions
print("---------------------------------");
print("number fraction phase A  = \t"+nPart[0]+"\t n total = \t"+nA);
print("number fraction phase B  = \t"+(1-nPart[0])+"\t n total = \t"+nB);
print("---------------------------------");




// Calc model distribution; just the funny lines
A=newArray(101);
AA=newArray(101);
BB=newArray(101);
AB=newArray(101);
for (i=0;i<A.length;i++) {
	A[i]=(0+i)/100;
	AA[i]=A[i]*A[i];
	BB[i]=(1-A[i])*(1-A[i]);
	AB[i]=2*A[i]*(1-A[i]);
	}

colors=newArray("blue", "red", "green");

// plot	-------------- for surface fraction
Plot.create("dist rand clust", "A-surf-fraction", "probability");
Plot.setFrameSize(512,512);
Plot.setLimits(0, 1, 0, 1);
Plot.setColor(colors[0]);
Plot.setLineWidth(2);
Plot.add("line", A ,AA);
Plot.setColor(colors[1]);
Plot.setLineWidth(2);
Plot.add("line", A ,BB);
Plot.setColor(colors[2]);
Plot.setLineWidth(2);
Plot.add("line", A ,AB);

// now the dots
for (i=1;i<res.length;i++){
Plot.setColor("black",colors[i-1]);
x=newArray(1);
x[0]=res[0]; //<-------- here's the difference
y=newArray(1);
y[0]=res[i]; 
Plot.add("circle",x ,y);
}
Plot.addText("ordered", 0.42, 0.03);
Plot.addText("clustered", 0.42, 0.94);
Plot.show();

// plot	-------------- for area fraction
Plot.create("dist rand clust", "A-area-fraction", "probability");
Plot.setFrameSize(512,512);
Plot.setLimits(0, 1, 0, 1);
Plot.setColor(colors[0]);
Plot.setLineWidth(2);
Plot.add("line", A ,AA);
Plot.setColor(colors[1]);
Plot.setLineWidth(2);
Plot.add("line", A ,BB);
Plot.setColor(colors[2]);
Plot.setLineWidth(2);
Plot.add("line", A ,AB);

// now the dots
for (i=1;i<res.length;i++){
Plot.setColor("black",colors[i-1]);
x=newArray(1);
x[0]=areaRel[0]; //<-------- here's the difference
y=newArray(1);
y[0]=res[i];
Plot.add("circle",x ,y);
}
Plot.addText("ordered", 0.42, 0.03);
Plot.addText("clustered", 0.42, 0.94);
Plot.show();

// plot	-------------- for n fraction
Plot.create("dist rand clust", "A-number-fraction", "probability");
Plot.setFrameSize(512,512);
Plot.setLimits(0, 1, 0, 1);
Plot.setColor(colors[0]);
Plot.setLineWidth(2);
Plot.add("line", A ,AA);
Plot.setColor(colors[1]);
Plot.setLineWidth(2);
Plot.add("line", A ,BB);
Plot.setColor(colors[2]);
Plot.setLineWidth(2);
Plot.add("line", A ,AB);

// now the dots
for (i=1;i<res.length;i++){
Plot.setColor("black",colors[i-1]);
x=newArray(1);
x[0]=nPart[0]; //<-------- here's the difference
y=newArray(1);
y[0]=res[i];
Plot.add("circle",x ,y);
}
Plot.addText("ordered", 0.42, 0.03);
Plot.addText("clustered", 0.42, 0.94);
Plot.show();
//
//content = getInfo("log");
//f = File.open("");
//print(f,content);
//File.close(f);
//
}
  
