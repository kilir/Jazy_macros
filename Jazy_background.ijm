//Version 0.0.2a
//-----------------------------------------------------------------------------------------
//---------------------------------------background-helper---------------------------------
//-----------------------------------------------------------------------------------------
function histoTOP(stripw){
		xwidth = getWidth();
		yheight = getHeight();
		i=yheight/stripw;
		makeRectangle(0,0,xwidth,i);
		getStatistics(area,mean,min,max);
		Dialog.create("mean gw");
		Dialog.addNumber("mean top", mean);
		Dialog.show();

		}


macro "get histogram top            [t]"{

stripw = 5;
Dialog.create("width of strip");
Dialog.addMessage("width of strip");
Dialog.addNumber("fraction: 1/",stripw);
Dialog.show();
stripw = Dialog.getNumber();

histoTOP(stripw);
run("Histogram");
}
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
function histoBOT(stripw){
		xwidth = getWidth();
		yheight = getHeight();
		i=yheight/stripw;
		makeRectangle(0,yheight-i,xwidth,i);
		getStatistics(area,mean,min,max);
		Dialog.create("mean gw");
		Dialog.addNumber("mean bottom", mean);
		Dialog.show();

		}


macro "get histogram bottom            [b]"{

stripw = 5;
Dialog.create("width of strip");
Dialog.addMessage("width of strip");
Dialog.addNumber("fraction: 1/",stripw);
Dialog.show();
stripw = Dialog.getNumber();

histoBOT(stripw);
run("Histogram");
}
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

function histoRIGHT(stripw){
		xwidth = getWidth();
		yheight = getHeight();
		i=xwidth/stripw;
		makeRectangle(xwidth-i-1,0,i,yheight);
		getStatistics(area,mean,min,max);
		Dialog.create("mean gw");
		Dialog.addNumber("mean right", mean);
		Dialog.show();
		}


macro "get histogram right            [r]"{

stripw = 5;
Dialog.create("width of strip");
Dialog.addMessage("width of strip");
Dialog.addNumber("fraction: 1/",stripw);
Dialog.show();
stripw = Dialog.getNumber();

histoRIGHT(stripw);
run("Histogram");
}


//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

function histoLEFT(stripw){
		xwidth = getWidth();
		yheight = getHeight();
		i=xwidth/stripw;
		makeRectangle(0,0,i,yheight);
		getStatistics(area,mean,min,max);
		Dialog.create("mean gw");
		Dialog.addNumber("mean left", mean);
		Dialog.show();
		
		}


macro "get histogram left            [l]"{

stripw = 5;
Dialog.create("width of strip");
Dialog.addMessage("width of strip");
Dialog.addNumber("fraction: 1/",stripw);
Dialog.show();
stripw = Dialog.getNumber();

histoLEFT(stripw);
run("Histogram");

}



//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
function histoBOT(stripw){
		xwidth = getWidth();
		yheight = getHeight();
		i=yheight/stripw;
		makeRectangle(0,yheight-i,xwidth,i);
		getStatistics(area,mean,min,max);
		Dialog.create("mean gw");
		Dialog.addNumber("mean bottom", mean);
		Dialog.show();

		}
function histoTOP(stripw){
		xwidth = getWidth();
		yheight = getHeight();
		i=yheight/stripw;
		makeRectangle(0,0,xwidth,i);
		getStatistics(area,mean,min,max);
		Dialog.create("mean gw");
		Dialog.addNumber("mean top", mean);
		Dialog.show();
		}


macro "correct top-bottom  sub  [f]"{

fname =getTitle();
xwidth = getWidth();
yheight = getHeight();
		
stripw = 5;
Dialog.create("width of strip");
Dialog.addMessage("width of strip");
Dialog.addNumber("fraction: 1/",stripw);
Dialog.show();
stripw = Dialog.getNumber();

histoTOP(stripw);
mean_TOP = Dialog.getNumber();
histoBOT(stripw);
mean_BOT = Dialog.getNumber();

diff  = mean_BOT - mean_TOP;

Dialog.create("difference BOT-TOP");
Dialog.addMessage("difference");
Dialog.addNumber("bottom - top =",diff);
Dialog.show();
diff = Dialog.getNumber();
diff =diff*yheight/(yheight-(yheight/stripw));
print(diff);
x = abs(diff/255);
print(x);
run("Select None");
newImage("T-B-ramp", "8-bit ramp", yheight, xwidth , 1);
run("Rotate 90 Degrees Right");
run("Multiply...", "value="+x+"");
if (diff<0){
	run("Flip Vertically");
	}

imageCalculator("Subtract create 32-bit", fname ,"T-B-ramp");
run("8-bit");
run("Histogram");
}



//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------



function histoLEFT(stripw){
		xwidth = getWidth();
		yheight = getHeight();
		i=xwidth/stripw;
		makeRectangle(0,0,i,yheight);
		getStatistics(area,mean,min,max);
		Dialog.create("mean gw");
		Dialog.addNumber("mean left", mean);
		Dialog.show();
		}
		
function histoRIGHT(stripw){
		xwidth = getWidth();
		yheight = getHeight();
		i=xwidth/stripw;
		makeRectangle(xwidth-i-1,0,i,yheight);
		getStatistics(area,mean,min,max);
		Dialog.create("mean gw");
		Dialog.addNumber("mean right", mean);
		Dialog.show();
		}


macro "correct left-right  sub  [d]"{

fname =getTitle();
xwidth = getWidth();
yheight = getHeight();
		
stripw = 5;
Dialog.create("width of strip");
Dialog.addMessage("width of strip");
Dialog.addNumber("fraction: 1/",stripw);
Dialog.show();
stripw = Dialog.getNumber();

histoLEFT(stripw);
mean_left = Dialog.getNumber();
histoRIGHT(stripw);
mean_right = Dialog.getNumber();

diff  = mean_left - mean_right;

Dialog.create("difference left-right");
Dialog.addMessage("difference");
Dialog.addNumber("left - right =",diff);
Dialog.show();
diff = Dialog.getNumber();
diff =diff*xwidth/(xwidth-(xwidth/stripw));

print(diff);
x = abs(diff/255);
print(x);
newImage("L-R-ramp", "8-bit ramp", xwidth, yheight, 1);
run("Multiply...", "value="+x+"");
if (diff>0){
	run("Flip Horizontally");
	}

imageCalculator("Subtract create", fname ,"L-R-ramp");
run("8-bit");
run("Histogram");
}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------


macro "correct  lrtb sequencial  sub    [c]"{
function histoBOT(stripw){
		xwidth = getWidth();
		yheight = getHeight();
		i=yheight/stripw;
		makeRectangle(0,yheight-i,xwidth,i);
		getStatistics(area,mean,min,max);
		Dialog.create("mean gw");
		Dialog.addNumber("mean bottom", mean);
		Dialog.show();
		}
function histoTOP(stripw){
		xwidth = getWidth();
		yheight = getHeight();
		i=yheight/stripw;
		makeRectangle(0,0,xwidth,i);
		getStatistics(area,mean,min,max);
		Dialog.create("mean gw");
		Dialog.addNumber("mean top", mean);
		Dialog.show();
		}
function histoLEFT(stripw){
		xwidth = getWidth();
		yheight = getHeight();
		i=xwidth/stripw;
		makeRectangle(0,0,i,yheight);
		getStatistics(area,mean,min,max);
		Dialog.create("mean gw");
		Dialog.addNumber("mean left", mean);
		Dialog.show();
		}
function histoRIGHT(stripw){
		xwidth = getWidth();
		yheight = getHeight();
		i=xwidth/stripw;
		makeRectangle(xwidth-i-1,0,i,yheight);
		getStatistics(area,mean,min,max);
		Dialog.create("mean gw");
		Dialog.addNumber("mean right", mean);
		Dialog.show();
		}

		
fname =getTitle();
xwidth = getWidth();
yheight = getHeight();
		
stripw = 6;
Dialog.create("width selection");
Dialog.addMessage("width of selection");
Dialog.addNumber("fraction: 1/",stripw);
Dialog.show();
stripw = Dialog.getNumber();


// correct Top-bottom
histoTOP(stripw);
mean_TOP = Dialog.getNumber();
histoBOT(stripw);
mean_BOT = Dialog.getNumber();

diff_TB = mean_TOP - mean_BOT;

Dialog.create("difference BOT-TOP");
Dialog.addMessage("difference");
Dialog.addNumber("bottom - top =",diff_TB);
Dialog.show();
diff_TB = Dialog.getNumber();
diff_TB =diff_TB*yheight/(yheight-(yheight/stripw));
print(diff_TB);
xTB = abs(diff_TB/255);
print(xTB);
newImage("T-B-ramp", "8-bit ramp", yheight, xwidth, 1);
run("Rotate 90 Degrees Right");
run("Multiply...", "value="+xTB+"");
if (diff_TB<0){
	run("Flip Vertically");
	}

imageCalculator("Subtract create 32-bit", fname ,"T-B-ramp");
run("8-bit");


// correct left right
histoLEFT(stripw);
mean_LEFT = Dialog.getNumber();
histoRIGHT(stripw);
mean_RIGHT = Dialog.getNumber();
diff_LR  = mean_LEFT - mean_RIGHT;

Dialog.create("difference left-right");
Dialog.addMessage("difference");
Dialog.addNumber("left - right =",diff_LR);
Dialog.show();
diff_LR = Dialog.getNumber();
diff_LR =diff_LR*xwidth/(xwidth-(xwidth/stripw));

print(diff_LR);
xLR = abs(diff_LR/255);
print(xLR);
newImage("L-R-ramp", "8-bit ramp", xwidth, yheight, 1);
run("Multiply...", "value="+xLR+"");
if (diff_LR>0){
	run("Flip Horizontally");
	}

imageCalculator("Subtract create 32-bit", fname ,"L-R-ramp");
run("8-bit");

}



//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
macro "correct center [z]"{ // does not really produce a good result

fname =getTitle();
xwidth = getWidth();
yheight = getHeight();
		
stripw = 6;
Dialog.create("width selection");
Dialog.addMessage("width of selection");
Dialog.addNumber("fraction: 1/",stripw);
Dialog.show();
stripw = Dialog.getNumber();
		


// get tiles
twidth = xwidth/stripw;
theight = yheight/stripw;
//run("Set Measurements...", " mean redirect=None decimal=3");
//get all means
a_mean = newArray(stripw*stripw+1);
for (i=1; i<= stripw; i++){
		for (j=1; j<=stripw; j++){
		count = count+1;
		makeRectangle(twidth*(i-1),theight*(j-1),twidth,theight);
		getStatistics(area,mean,min,max);
		a_mean[count]=mean;
			}
		}
//find largest
max_mean = 0;
for (k=1; k<=count; k++){
	temp_mean = a_mean[k];
	if (temp_mean > max_mean){
	   		max_mean = temp_mean;
			}
	}
print(max_mean);

min_mean = 255;
for (k=1; k<=count; k++){
	temp_mean = a_mean[k];
	if (temp_mean < min_mean){
	   		min_mean = temp_mean;
			}
	}
print(max_mean);
print(min_mean);
//find coordinates (indices for largest mean)
count = 0;
for (i=1; i<= stripw; i++){
		for (j=1; j<=stripw; j++){
		count = count+1;
		makeRectangle(twidth*(i-1),theight*(j-1),twidth,theight);
		getStatistics(area,mean,min,max);
		if (mean == max_mean){
			i_m = i;		
			j_m = j;
			print(i_m,j_m);
		}
		}
	}
run("Select All");
// determine center of i,j
x_st = round(i_m*(xwidth/stripw)-(xwidth/(2*stripw)));
y_st = round(j_m*(yheight/stripw)-(yheight/(2*stripw)));

//determine size of dome (largest distance)
if (x_st > xwidth/2){
	x_s = 0;
	} else {
	x_s = xwidth;
	}
if (y_st > yheight/2){
	y_s=0;
	} else { 
	y_s = yheight;
	}

print("center of max mean", x_s,y_s);
print("size of new window", x_st, y_st);

new_width = 2*abs(x_s - x_st);
new_height = 2*abs(y_s - y_st);

//find diff in min - max mean
diff = max_mean - min_mean;

Dialog.create("differences");
Dialog.addMessage("difference maximal mean - minimal mean");
Dialog.addNumber("max -min =",diff);
Dialog.show();
diff = Dialog.getNumber();
x = abs(diff/255);
print("x",x);
// makebackground
//todo: think about right size of new image (used square which is sort of ...wrong)
newImage("C-radial", "RGB white", new_width, new_height, 1);	
run("Select All");
run("Radial Gradient");
run("8-bit");

//make selection
if (x_s == 0){
	sel_x = 0;}
if (x_s == xwidth){
	sel_x = new_width - xwidth;}
	
if (y_s == 0){
	sel_y = 0;}
if (y_s == yheight){
	sel_y = new_height - yheight;}
makeRectangle(sel_x,sel_y,xwidth,yheight);
run("Duplicate...", "title=backg");
run("Multiply...", "value="+x+"");
run("Invert");
getStatistics(area,mean,min,max);
run("Subtract...", "value="+min+"");

imageCalculator("Subtract create 32-bit", fname ,"backg");
run("8-bit");

}



//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
macro "rolling ball... [k]"{
run("Subtract Background...")
}

