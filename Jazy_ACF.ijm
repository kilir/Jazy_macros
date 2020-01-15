//Version 0.0.6a
//-----------------------------------------------------------------------------------------
//----------------------------------------ACF-related-macros-for---------------------------
//---------------------------------------------ImageJ--------------------------------------
//todo - fix LUT - where?
//14.3.14 add threshold to size (thresholded ACF will have a certain size in units related to image)

macro "make grid overlay [o]"{

grid_size = 256;
xinit = 0;
yinit = 0;
 
Dialog.create("x-start");
Dialog.addMessage("x-start coordinates");
Dialog.addNumber("", xinit);
Dialog.show();
xinit = Dialog.getNumber();

Dialog.create("y-start");
Dialog.addMessage("y-start coordinates");
Dialog.addNumber("", yinit);
Dialog.show();
yinit = Dialog.getNumber();

Dialog.create("grid size");
Dialog.addMessage("grid size");
Dialog.addNumber("", grid_size);
Dialog.show();
grid_size = Dialog.getNumber();

xwidth = getWidth();
yheight = getHeight();

nx =floor((xwidth-xinit)/grid_size);
ny =floor((yheight-yinit)/grid_size);


setForegroundColor(0 ,0 , 0);
setLineWidth(1);

for (i=0; i <= nx; i++){
x = (i * grid_size) + xinit;
y = yinit;

Overlay.moveTo(x,y);
Overlay.lineTo(x,(ny*grid_size)+yinit); //Overlay.drawLine(x, y, x, yheight)
Overlay.add;
Overlay.show;

}

for (i = 0; i <= ny; i++ ){
x = xinit;
y = (i * grid_size) + yinit;
Overlay.moveTo(x,y);
Overlay.lineTo((nx*grid_size)+xinit,y); //Overlay.drawLine(x, y, xwidth, y)
Overlay.add;
Overlay.show;
}
}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "make grid [g]"{

run("Remove Overlay");
grid_size = 256;
xinit = 0;
yinit = 0;
 
Dialog.create("x-start");
Dialog.addMessage("x-start coordinates");
Dialog.addNumber("", xinit);
Dialog.show();
xinit = Dialog.getNumber();

Dialog.create("y-start");
Dialog.addMessage("y-start coordinates");
Dialog.addNumber("", yinit);
Dialog.show();
yinit = Dialog.getNumber();

Dialog.create("grid size");
Dialog.addMessage("grid size");
Dialog.addNumber("", grid_size);
Dialog.show();
grid_size = Dialog.getNumber();

xwidth = getWidth();
yheight = getHeight();

nx =floor((xwidth-xinit)/grid_size);
ny =floor((yheight-yinit)/grid_size);


setForegroundColor(0 ,0 , 0);
setLineWidth(1);

for (i=0; i <= nx; i++){
x = (i * grid_size) + xinit;
y = yinit;

moveTo(x,y); 				
lineTo(x,(ny*grid_size)+yinit); 	
					
					
}

for (i = 0; i <= (ny); i++ ){
x = xinit;
y = (i * grid_size) + yinit;
moveTo(x,y); 			
lineTo((nx*grid_size)+xinit,y);
				
				
}
}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "make 2n*2n ROI [1]"{

//roiManager("reset");
grid_size = 256;
Dialog.create("grid size");
Dialog.addMessage("Enter grid size (2^n)");
Dialog.addNumber("Pixels ", grid_size);
Dialog.show();
grid_size = Dialog.getNumber();
makeRectangle(0,0,grid_size,grid_size);
//roiManager("Add");
//roiManager("select",0);
}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "make ROI there [2]"{

getCursorLoc(x, y, z, flags);
xwidth = getWidth();
yheight = getHeight();

xinit = x;
yinit = y;

roi_size = 256;

Dialog.create("x-start");
Dialog.addMessage("x-start coordinates");
Dialog.addNumber("", xinit);
Dialog.show();
xinit = Dialog.getNumber();

Dialog.create("y-start");
Dialog.addMessage("y-start coordinates");
Dialog.addNumber("", yinit);
Dialog.show();
yinit = Dialog.getNumber();

Dialog.create("roi size");
Dialog.addMessage("roi size");
Dialog.addNumber("", roi_size);
Dialog.show();
roi_size = Dialog.getNumber();
makeRectangle(xinit,yinit,roi_size,roi_size);
}


//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "single ACF of ROI in 2-layer stack [3]"{

function doACFsingle(fname){
	run("FD Math...", "image1="+fname+" operation=Correlate image2="+fname+" result=temp do");
	run("Invert");}

//do ACF in ROI in Image
fname = getTitle();
autoUpdate(false);
setBatchMode(true);
run("Add Slice");
Stack.setSlice(1);
selectWindow(fname);
run("Copy");

getSelectionBounds(x, y, width, height)
newImage("temp", "8-bit white", width, height, 1);
selectWindow("temp");
run("Paste");
doACFsingle("temp");
run("Copy");
selectWindow(fname);
Stack.setSlice(2);
run("Paste");
close("\\Others");
autoUpdate(true);
setBatchMode(false);
}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------


macro "single ACFcenter of ROI in 2-layer stack [4]"{

function doACFsingle(fname){
	run("FD Math...", "image1="+fname+" operation=Correlate image2="+fname+" result=Result do");
	run("Invert");}
	
//do ACF in ROI in Image
fname = getTitle();
autoUpdate(false);
setBatchMode(true);

run("Add Slice");
Stack.setSlice(1);
selectWindow(fname);
//roiManager("select",0);
run("Copy");

getSelectionBounds(x, y, width, height)

xc = x;
yc = y;
center = width/2;
corner = center/2;

newImage("temp", "8-bit white", width, height, 1);
selectWindow("temp");
run("Paste");
doACFsingle("temp");
makeRectangle(corner,corner,center,center);

run("Copy");
run("Select None");
selectWindow(fname);
Stack.setSlice(2);
makeRectangle(x+corner,y+corner,center,center);
run("Paste");
close("\\Others");
autoUpdate(true);
setBatchMode(false);
}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "tiling of ACFs in 2-layer stack [5]"{


function doACFsingle(fname){
	run("FD Math...", "image1="+fname+" operation=Correlate image2="+fname+" result=Result do");
	}



fname = getTitle();
selectWindow(fname);
run("Add Slice");
Stack.setSlice(1);


//query start point and size
grid_size = 256;
xinit = 0;
yinit = 0;
 
Dialog.create("x-start");
Dialog.addMessage("x-start coordinates");
Dialog.addNumber("", xinit);
Dialog.show();
xinit = Dialog.getNumber();

Dialog.create("y-start");
Dialog.addMessage("y-start coordinates");
Dialog.addNumber("", yinit);
Dialog.show();
yinit = Dialog.getNumber();

Dialog.create("grid size");
Dialog.addMessage("grid size");
Dialog.addNumber("", grid_size);
Dialog.show();
grid_size = Dialog.getNumber();

xwidth = getWidth();
yheight = getHeight();

nx =floor((xwidth-xinit)/grid_size);
ny =floor((yheight-yinit)/grid_size);


Dialog.create("grids in x direction");
Dialog.addMessage("#y");
Dialog.addNumber("", nx);
Dialog.show();
nx = Dialog.getNumber();

Dialog.create("grids in y direction");
Dialog.addMessage("#y");
Dialog.addNumber("", ny);
Dialog.show();
ny = Dialog.getNumber();


t1=getTime();

selectWindow(fname);
Stack.setSlice(1);

autoUpdate(false);
setBatchMode(true);
newImage("temp", "8-bit white", grid_size, grid_size, 1);

for (i=1; i<=nx; i++){
	
	for (j=1; j<=ny; j++){
		
	selectWindow(fname);
	Stack.setSlice(1);
	makeRectangle(xinit+(i-1)*grid_size,yinit+(j-1)*grid_size,grid_size,grid_size);
	run("Copy");
	selectWindow("temp");
	run("Paste");
	doACFsingle("temp");
	run("Copy");
	selectWindow(fname);
	Stack.setSlice(2);
	run("Paste");
	close("Result");
	}}
close("temp");
selectWindow(fname);
Stack.setSlice(2);
run("Select All")
//run("Invert", "slice");
print(getTime()-t1);
autoUpdate(true);
setBatchMode(false);
}


//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "tiling of ACFcenters in 2-layer stack [6]"{


function doACFsingle(fname){
	run("FD Math...", "image1="+fname+" operation=Correlate image2="+fname+" result=Result do");
	}



fname = getTitle();
selectWindow(fname);
run("Add Slice");
Stack.setSlice(1);


//query start point and size
grid_size = 256;
xinit = 0;
yinit = 0;
 
Dialog.create("x-start");
Dialog.addMessage("x-start coordinates");
Dialog.addNumber("", xinit);
Dialog.show();
xinit = Dialog.getNumber();

Dialog.create("y-start");
Dialog.addMessage("y-start coordinates");
Dialog.addNumber("", yinit);
Dialog.show();
yinit = Dialog.getNumber();

Dialog.create("grid size");
Dialog.addMessage("grid size");
Dialog.addNumber("", grid_size);
Dialog.show();
grid_size = Dialog.getNumber();

xwidth = getWidth();
yheight = getHeight();

nx =floor((2*(xwidth-xinit)/grid_size)-1);
ny =floor((2*(yheight-yinit)/grid_size)-1);

center = grid_size/2;
corner = center/2;

Dialog.create("grids in x direction");
Dialog.addMessage("#y");
Dialog.addNumber("", nx);
Dialog.show();
nx = Dialog.getNumber();

Dialog.create("grids in y direction");
Dialog.addMessage("#y");
Dialog.addNumber("", ny);
Dialog.show();
ny = Dialog.getNumber();

t1=getTime();

selectWindow(fname);
Stack.setSlice(1);

autoUpdate(false);
setBatchMode(true);
newImage("temp", "8-bit white", grid_size, grid_size, 1);

for (i=1; i<=nx; i++){
	
	for (j=1; j<=ny; j++){
		
	selectWindow(fname);
	Stack.setSlice(1);
	makeRectangle(xinit+(i-1)*center,yinit+(j-1)*center,grid_size,grid_size);
	run("Copy");
	selectWindow("temp");
	run("Paste");
	doACFsingle("temp");
	makeRectangle(corner, corner, center, center);
	run("Copy");
	selectWindow(fname);
	Stack.setSlice(2);
	makeRectangle(corner+xinit+(i-1)*center,corner+yinit+(j-1)*center,center,center);
	run("Paste");
	close("Result");
	}}
close("temp");
//selectWindow(fname);
//Stack.setSlice(2);
//run("Select All")
//run("Invert", "slice");
print(getTime()-t1);
autoUpdate(true);
setBatchMode(false);
}


//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "tiling of ACFcenters in 3-layer stack (scaled) [7]"{


function doACFsingle(fname){
	run("FD Math...", "image1="+fname+" operation=Correlate image2="+fname+" result=Result do");
	}


//silly thing to get the scaling
info = getInfo();
index1 = indexOf(info, "Resolution: "); 
    if (index1==-1)
       {scale=1; unit = "pixel"; return;}
       index2 = indexOf(info, "\n", index1);
       line = substring(info, index1+12, index2);
       words = split(line, "");
       scale = 0+words[0];
       unit = words[3]; 
run("Set Scale...", "distance=1 known=1 pixel=1 unit=pixel");

print("scale="+scale);

fname = getTitle();
selectWindow(fname);
run("Add Slice");
run("Add Slice");
Stack.setSlice(1);


//query start point and size
grid_size = 256;
xinit = 0;
yinit = 0;
 
Dialog.create("x-start");
Dialog.addMessage("x-start coordinates");
Dialog.addNumber("", xinit);
Dialog.show();
xinit = Dialog.getNumber();

Dialog.create("y-start");
Dialog.addMessage("y-start coordinates");
Dialog.addNumber("", yinit);
Dialog.show();
yinit = Dialog.getNumber();

Dialog.create("grid size");
Dialog.addMessage("grid size");
Dialog.addNumber("", grid_size);
Dialog.show();
grid_size = Dialog.getNumber();

xwidth = getWidth();
yheight = getHeight();

nx =floor((2*(xwidth-xinit)/grid_size)-1);
ny =floor((2*(yheight-yinit)/grid_size)-1);

center = grid_size/2;
corner = center/2;

darea = (center*center)/50;
darea = darea * scale * scale;

Dialog.create("Thresholded ACF size");
Dialog.addMessage("Size of thresholded ACF? \n You can use image units \n default 2% of image area =");
Dialog.addNumber("", darea);
Dialog.show();
darea = Dialog.getNumber();
threshold = (center*center)-darea;

Dialog.create("grids in x direction");
Dialog.addMessage("#y");
Dialog.addNumber("", nx);
Dialog.show();
nx = Dialog.getNumber();

Dialog.create("grids in y direction");
Dialog.addMessage("#y");
Dialog.addNumber("", ny);
Dialog.show();
ny = Dialog.getNumber();

t1=getTime();

selectWindow(fname);
Stack.setSlice(1);

autoUpdate(false);
setBatchMode(true);
newImage("temp", "8-bit white", grid_size, grid_size, 1);
newImage("temp2", "8-bit white", center, center, 1);

for (i=1; i<=nx; i++){
	
	for (j=1; j<=ny; j++){
		
	selectWindow(fname);
	Stack.setSlice(1);
	makeRectangle(xinit+(i-1)*center,yinit+(j-1)*center,grid_size,grid_size);
	run("Copy");
	selectWindow("temp");
	run("Paste");
	doACFsingle("temp");
	makeRectangle(corner, corner, center, center);
	run("Copy");
	selectWindow(fname);
	Stack.setSlice(2);
	makeRectangle(corner+xinit+(i-1)*center,corner+yinit+(j-1)*center,center,center);
	run("Paste");

	selectWindow("temp2");
	run("Paste");

	getHistogram(values, counts, 256);
	sum = 0;
	index = 0;
	for 	(k =1; k <= 255; k++){
		sum = sum+counts[k];
		
		if 	(sum > threshold && index == 0){
			index = k;
			}
			
		}
	print("index="+index);
	setThreshold(0, index);
	run("Make Binary", "thresholded remaining black");
	run("Select All");
	run("Copy");

	selectWindow(fname);
	Stack.setSlice(3);
	makeRectangle(corner+xinit+(i-1)*center,corner+yinit+(j-1)*center,center,center);
	run("Paste");

	
	close("Result");
	}
	}
	
close("temp");
close("temp2");
run("Set Scale...", "distance="+scale+" known=1 pixel=1 unit="+unit+"");
//selectWindow(fname);
//Stack.setSlice(2);
//run("Select All")
//run("Invert", "slice");
//Stack.setSlice(3);
//run("Select All")
//run("Invert", "slice");
print(getTime()-t1);
autoUpdate(true);
setBatchMode(false);
}
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "tiling of ACFcenters in 3-layer stack (unscaled)"{


function doACFsingle(fname){
	run("FD Math...", "image1="+fname+" operation=Correlate image2="+fname+" result=Result do");
	}



fname = getTitle();
selectWindow(fname);
run("Add Slice");
run("Add Slice");
Stack.setSlice(1);


//query start point and size
grid_size = 256;
xinit = 0;
yinit = 0;
 
Dialog.create("x-start");
Dialog.addMessage("x-start coordinates");
Dialog.addNumber("", xinit);
Dialog.show();
xinit = Dialog.getNumber();

Dialog.create("y-start");
Dialog.addMessage("y-start coordinates");
Dialog.addNumber("", yinit);
Dialog.show();
yinit = Dialog.getNumber();

Dialog.create("grid size");
Dialog.addMessage("grid size");
Dialog.addNumber("", grid_size);
Dialog.show();
grid_size = Dialog.getNumber();

xwidth = getWidth();
yheight = getHeight();

nx =floor((2*(xwidth-xinit)/grid_size)-1);
ny =floor((2*(yheight-yinit)/grid_size)-1);

center = grid_size/2;
corner = center/2;

darea = (center*center)/50;


Dialog.create("Thresholded ACF size");
Dialog.addMessage("Size of thresholded ACF? \n You can use pixel units \n default 2% of image area =");
Dialog.addNumber("", darea);
Dialog.show();
darea = Dialog.getNumber();
threshold = (center*center)-darea;

Dialog.create("grids in x direction");
Dialog.addMessage("#y");
Dialog.addNumber("", nx);
Dialog.show();
nx = Dialog.getNumber();

Dialog.create("grids in y direction");
Dialog.addMessage("#y");
Dialog.addNumber("", ny);
Dialog.show();
ny = Dialog.getNumber();

t1=getTime();

selectWindow(fname);
Stack.setSlice(1);

autoUpdate(false);
setBatchMode(true);
newImage("temp", "8-bit white", grid_size, grid_size, 1);
newImage("temp2", "8-bit white", center, center, 1);

for (i=1; i<=nx; i++){
	
	for (j=1; j<=ny; j++){
		
	selectWindow(fname);
	Stack.setSlice(1);
	makeRectangle(xinit+(i-1)*center,yinit+(j-1)*center,grid_size,grid_size);
	run("Copy");
	selectWindow("temp");
	run("Paste");
	doACFsingle("temp");
	makeRectangle(corner, corner, center, center);
	run("Copy");
	selectWindow(fname);
	Stack.setSlice(2);
	makeRectangle(corner+xinit+(i-1)*center,corner+yinit+(j-1)*center,center,center);
	run("Paste");

	selectWindow("temp2");
	run("Paste");

	getHistogram(values, counts, 256);
	sum = 0;
	index = 0;
	for 	(k =1; k <= 255; k++){
		sum = sum+counts[k];
		
		if 	(sum > threshold && index == 0){
			index = k;
			}
			
		}
	print("index="+index);
	setThreshold(0, index);
	run("Make Binary", "thresholded remaining black");
	run("Select All");
	run("Copy");

	selectWindow(fname);
	Stack.setSlice(3);
	makeRectangle(corner+xinit+(i-1)*center,corner+yinit+(j-1)*center,center,center);
	run("Paste");

	
	close("Result");
	}
	}
	
close("temp");
close("temp2");
//selectWindow(fname);
//Stack.setSlice(2);
//run("Select All")
//run("Invert", "slice");
//Stack.setSlice(3);
//run("Select All")
//run("Invert", "slice");
print(getTime()-t1);
autoUpdate(true);
setBatchMode(false);
}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "threshold ACF at area (scaled) [s] "{

fname = getTitle();

//silly thing to get the scaling
info = getInfo();
index1 = indexOf(info, "Resolution: "); 
    if (index1==-1)
       {scale=1; unit = "pixel"; return;}
       index2 = indexOf(info, "\n", index1);
       line = substring(info, index1+12, index2);
       words = split(line, "");
       scale = 0+words[0];
       unit = words[3]; 
print(scale);

run("Set Scale...", "distance=1 known=1 pixel=1 unit=pixel");

selectWindow(fname);
run("Add Slice");
Stack.setSlice(1);


xwidth = getWidth();
yheight = getHeight();
area = xwidth*yheight;

darea = 21;
Dialog.create("Thresholded ACF size");
Dialog.addMessage("Thresholded ACF size? \n area =");
Dialog.addNumber("", darea);
Dialog.show();
darea = Dialog.getNumber();
print("beforescaling"+darea);

darea = darea * scale * scale;
print("afterscaling"+darea);


threshold = area-darea;

selectWindow(fname);
Stack.setSlice(1);

autoUpdate(false);
setBatchMode(true);
newImage("temp", "8-bit white", xwidth, yheight, 1);


selectWindow(fname);
Stack.setSlice(1);
run("Copy");
selectWindow("temp");
run("Paste");
getHistogram(values, counts, 256);
sum = 0;
index = 0;
for 	(k =1; k <= 255; k++)
	{
	sum = sum+counts[k];
		if 	(sum >= threshold && index == 0)
		{
		index = k;
		}
	}
	setThreshold(0, index);
	
	run("Make Binary", "thresholded remaining black");
	
selectWindow("temp");
run("Copy");
selectWindow(fname);
Stack.setSlice(2);
run("Paste");
run("Set Scale...", "distance="+scale+" known=1 pixel=1 unit="+unit+"");
close("Result");
}
}
	
close("temp");
autoUpdate(true);
setBatchMode(false);

}
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "threshold ACF at area (unscaled) [S]"{

fname = getTitle();

selectWindow(fname);
run("Add Slice");
Stack.setSlice(1);


xwidth = getWidth();
yheight = getHeight();
area = xwidth*yheight;

darea = 21;
Dialog.create("Thresholded ACF size");
Dialog.addMessage("Thresholded ACF size? \n area =");
Dialog.addNumber("", darea);
Dialog.show();
darea = Dialog.getNumber();

threshold = area-darea;

selectWindow(fname);
Stack.setSlice(1);

autoUpdate(false);
setBatchMode(true);
newImage("temp", "8-bit white", xwidth, yheight, 1);


selectWindow(fname);
Stack.setSlice(1);
run("Copy");
selectWindow("temp");
run("Paste");
getHistogram(values, counts, 256);
sum = 0;
index = 0;
for 	(k =1; k <= 255; k++)
	{
	sum = sum+counts[k];
		if 	(sum >= threshold && index == 0)
		{
		index = k;
		}
	}
	setThreshold(0, index);
	
	run("Make Binary", "thresholded remaining black");
	
selectWindow("temp");
run("Copy");
selectWindow(fname);
Stack.setSlice(2);
run("Paste");
close("Result");
}
}
	
close("temp");
autoUpdate(true);
setBatchMode(false);
}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------


macro "individual ACFcenters to stack [8]" {


function doACFsingle(fname){
	run("FD Math...", "image1="+fname+" operation=Correlate image2="+fname+" result=Result do");
	}



fname = getTitle();
selectWindow(fname);

//query start point and size
grid_size = 256;
xinit = 0;
yinit = 0;
 
Dialog.create("x-start");
Dialog.addMessage("x-start coordinates");
Dialog.addNumber("", xinit);
Dialog.show();
xinit = Dialog.getNumber();

Dialog.create("y-start");
Dialog.addMessage("y-start coordinates");
Dialog.addNumber("", yinit);
Dialog.show();
yinit = Dialog.getNumber();

Dialog.create("grid size");
Dialog.addMessage("grid size");
Dialog.addNumber("", grid_size);
Dialog.show();
grid_size = Dialog.getNumber();

xwidth = getWidth();
yheight = getHeight();

nx =floor((2*(xwidth-xinit)/grid_size)-1);
ny =floor((2*(yheight-yinit)/grid_size)-1);

center = grid_size/2;
corner = center/2;

Dialog.create("grids in x direction");
Dialog.addMessage("#y");
Dialog.addNumber("", nx);
Dialog.show();
nx = Dialog.getNumber();

Dialog.create("grids in y direction");
Dialog.addMessage("#y");
Dialog.addNumber("", ny);
Dialog.show();
ny = Dialog.getNumber();

t1=getTime();

selectWindow(fname);

autoUpdate(false);
setBatchMode(true);

newImage("ACF_stack", "8-bit white", center, center, nx*ny);
newImage("temp", "8-bit white", grid_size, grid_size, 1);

for (i=1; i<=nx; i++){
	
	for (j=1; j<=ny; j++){

	lc = lc+1; //counter
	selectWindow(fname);
	makeRectangle(xinit+(i-1)*center,yinit+(j-1)*center,grid_size,grid_size);
	run("Copy");
	selectWindow("temp");
	run("Paste");
	doACFsingle("temp");
	makeRectangle(corner, corner, center, center);
	run("Copy");
	selectWindow("ACF_stack");
	Stack.setSlice(lc);
	run("Paste");
	close("Result");
	}}
	
close("temp");


selectWindow("ACF_stack");

setBatchMode(false);
autoUpdate(true);

//run("Invert", "stack");


print(getTime()-t1);
}


//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "analysis of ACF stack [9]"{


fname = getTitle();

if (nSlices > 1){

xwidth = getWidth();
yheight = getHeight();

darea=(xwidth*yheight)/50;
Dialog.create("Thresholded ACF size");
Dialog.addMessage("Thresholded ACF size? \n 2% area =");
Dialog.addNumber("", darea);
Dialog.show();
darea = Dialog.getNumber();
threshold=(xwidth*yheight)-darea;



newImage("ACF_thresholded_stack", "8-bit white", xwidth, yheight, nSlices);
autoUpdate(false);
setBatchMode(true);
newImage("temp", "8-bit white", xwidth, yheight, 1);

for (j = 1; j <= nSlices; j++){
	
	selectWindow(fname);
	Stack.setSlice(j);
	run("Select All");
	run("Copy");
	
	selectWindow("temp");
	run("Paste");
	getHistogram(values, counts, 256);
	
	sum = 0;
	index = 0;
		for 	(k =0; k <= 255; k++){
			sum = sum+counts[k];
	
			if 	(sum > threshold && index == 0){
				index = k;
				}
			print(index);
			}

	setThreshold(0, index);
	//run("Make Binary","thresholded remaining black");
	run("Convert to Mask");
	run("Select All");
	run("Copy");
	selectWindow("ACF_thresholded_stack");
	Stack.setSlice(j);
	run("Paste");
	}
	
selectWindow("ACF_thresholded_stack");
run("Set Scale...", "pixel=1 unit=pixel");
run("Clear Results");
run("Set Measurements...", "area center perimeter fit shape  invert redirect=None decimal=3");
run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing display exclude clear record add stack");
close("temp");

autoUpdate(true);

}else{
showMessage("Stack required");}
}


//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "calibrate ACF to 100%  [t]"{
//run("Invert LUT");
run("Calibrate...", "function=[Straight Line] unit=[ACF(%)] text1=[255 0] text2=[100 0]");
//run("Invert");
}	

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "subtract minimum of ACF [a]"{

showMessage("subtracts minimum in select reference area, (default = entire image)");
getStatistics(area, mean, min, max)

Dialog.create("minimum");
Dialog.addMessage("minimum");
Dialog.addNumber("", min);
Dialog.show();
min = Dialog.getNumber();

run("Select All");
factor =255/(255-min);
run("Add...", "value="+-min+"");
run("Divide...", "value="+factor+"");
}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "ACF thresholding at 30 % [b]"{

run("Select All");
getSelectionBounds(x, y, width, height)
run("Copy");
newImage("thresholdACF30", "8-bit white", width, height, 1);
run("Paste")
//run("Invert LUT");
setThreshold(77, 255);
//run("Invert");
//run("Create Selection");
//run("Add to Manager");
run("Convert to Mask");
run("Invert LUT");
}


//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "ACF thresholding at 39 % [c]"{
run("Select All");
getSelectionBounds(x, y, width, height)
run("Copy");
newImage("thresholdACF39", "8-bit white", width, height, 1);
run("Paste")
//run("Invert LUT");
setThreshold(100, 255);
//run("Invert");
//run("Create Selection");
//run("Add to Manager");
run("Convert to Mask");
run("Invert LUT");
}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "analysis of thresholded ACF to list [d]"{
roiManager("Reset");
run("Clear Results");
run("Select None");
run("Invert");
run("Set Scale...", "pixel=1 unit=pixel");
run("Set Measurements...", "area center perimeter fit shape  invert redirect=None decimal=3");
run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing display exclude record add stack");
}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "analysis of ACFs -> list & label [e]"{

roiManager("reset");

run("Select None");
run("Set Scale...", "pixel=1 unit=pixel");
run("Set Measurements...", "area center perimeter fit shape  invert redirect=None decimal=3");
run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing display exclude record add");

setFont("Sanserif", 10);

for (i=0; i<roiManager("count"); i++){

        roiManager("select",i);
        run("Measure");
        aspect_ratio = getResult("AR");
	angle= getResult("Angle");
	k1 = getResult("XM")+20;
	k2 = getResult("YM")+40;
	drawString("aspect ratio \n "+aspect_ratio+" ", k1, k2);

	drawString("angle \n "+angle+" ", k1, k2-40);
	
	print(k1, k2);
	
	}
}


//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------


// what does it do??
macro "threshold ACF stack [f]"{

fname = getTitle();
if (nSlices > 1){

Stack.setSlice(1);
xwidth = getWidth();
yheight = getHeight();

tarea = xwidth;
Dialog.create("ACF size");
Dialog.addMessage("Thresholded ACF size?");
Dialog.addNumber("window diameter =", tarea);
Dialog.show();
tarea = Dialog.getNumber();

tarea=0.25*tarea*tarea*3.14159;
darea=round(tarea);
threshold=xwidth*yheight-darea;

autoUpdate(false);
setBatchMode(true);
newImage("temp", "8-bit white", xwidth, yheight, 1);

for (j = 1; j <= nSlices; j++){
	
	selectWindow(fname);
	Stack.setSlice(j);
	run("Select All");
	run("Copy");
	
	selectWindow("temp");
	run("Paste");
	//run("Invert LUT");
	getHistogram(values, counts, 256);
	
	sum = 0;
	index = 0;
		for 	(k =0; k <= 255; k++){
			sum = sum+counts[k];
	
			if 	(sum > threshold && index == 0){
				index = k;
				}
			print(index);
			}

	setThreshold(0, index);
	//run("Make Binary","thresholded remaining black");
	run("Convert to Mask");
	run("Invert LUT");
	run("Select All");
	run("Copy");
	selectWindow(fname);
	Stack.setSlice(j);
	run("Paste");
	}

}else{
showMessage("Stack required");}

}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "red line at level [v]"{

run("Calibrate...", "function=[Straight Line] unit=[ACF(%)] text1=[255 0] text2=[100 0]");

level = 50;

Dialog.create("Set level");
Dialog.addMessage("Set level");
Dialog.addNumber("level =", level);
Dialog.show();
level = Dialog.getNumber();

level=level*2.55;

getLut(reds, greens, blues);
reds[level]=255;
greens[level]=0;
blues[level]=0;

//reds[level-1]=255;
//reds[level+1]=255;
//greens[level+1]=0;
//blues[level+1]=0;
//greens[level-1]=0;
//blues[level-1]=0;
setLut(reds, greens, blues);

}


//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "yellow strip at level [w]"{


run("Calibrate...", "function=[Straight Line] unit=[ACF(%)] text1=[255 0] text2=[100 0]");


llevel = 50;

Dialog.create("Set lower level");
Dialog.addMessage("Set lower level");
Dialog.addNumber("level =", llevel);
Dialog.show();
llevel = Dialog.getNumber();

llevel=llevel*2.55;


ulevel = 50;

Dialog.create("Set upper level");
Dialog.addMessage("Set upper level");
Dialog.addNumber("level =", ulevel);
Dialog.show();
ulevel = Dialog.getNumber();


ulevel=ulevel*2.55;

getLut(reds, greens, blues);
for (i = llevel; i <= ulevel; i++){
reds[i]=255;
greens[i]=255;
blues[i]=0;
}
setLut(reds, greens, blues);

}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "transform to 20 levels [y]"{

run("Grays");

run("Calibrate...", "function=[Straight Line] unit=[ACF(%)] text1=[255 0] text2=[100 0]");

getLut(reds, greens, blues);

for (k = 0; k <= 12; k++){
	reds[k]=255;
	greens[k]=255;
	blues[k]=255;
	}

for (j = 1; j<= 18; j++){

	level = (j*255)/19;
	klo =(j-1)*230/18 + 12;
	kup =j*230/18 + 12;

    		for (l = klo; l <= kup; l++){
    			reds[l]=255-level;
			greens[l]=255-level;
			blues[l]=255-level;
			}
	}

for (k = kup+1; k<=255; k++){	
	reds[k]=0;
	greens[k]=0;
	blues[k]=0;
	}

setLut(reds, greens, blues);
}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "reset LUT [r]"{
run("Grays");
}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

macro "invert LUT [i]"{
run("Invert LUT");
}


//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------


macro " reset calibrtion [z]"{
run("Calibrate...", "function=[Straight Line] unit=[ACF(%)] text1=[255 0] text2=[255 0]");
}
