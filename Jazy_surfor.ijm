/*
Version 0.0.1a
-----------------------------------------------------------------------------------------
-------------------------------surfor implementation to imageJ---------------------------
---------------------------------------------ImageJ--------------------------------------
Generates smooth outlines of particles and derives the projection function of boundary
segments, a length weighted segment trend distribution (rose diagram) and the characteristic
shape

TODO:
write out results,
clean up cshape
*/



macro "surfor"{
// a) get xy cords
run("Select None");

//showMessage("Information" ,"Image will be scaled to pixels. If the macro fails, choose a smaller discard size.");
//run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");


var codist = "3"; 
{
        Dialog.create("coordinate distance");
        Dialog.addMessage("Enter pixel distance");
        Dialog.addNumber("Distance:", codist);
        Dialog.show();
        codist = Dialog.getNumber();
}


discard_size = pow(codist,2);//codist;
toScaled(discard_size);


run("Set Measurements...", "area perimeter invert decimal=3"); // do we need to get rid of invert here?
run("Analyze Particles...", "minimum="+discard_size+" maximum=999999 bins=20 show=Nothing exclude clear record");

autoUpdate(false);
setBatchMode(true);

setForegroundColor(123, 123, 123);

resultsX = newArray(1); // write final array
resultsY = newArray(1);
nPart = nResults; 
for (i=0; i<nPart; i++) {
    XX = getResult('XStart', i);
    YY = getResult('YStart', i);
    doWand(XX,YY);
    run("Interpolate", "interval="+codist+" smooth adjust");
    getSelectionCoordinates(x, y);
    toScaled(x,y);
    xtemp = Array.concat(x,x[0],0);
    ytemp = Array.concat(y,y[0],0);      	
    floodFill(XX, YY);
	resultsX= Array.concat(resultsX,xtemp);
	resultsY= Array.concat(resultsY,ytemp);
}
run("Select None");
setForegroundColor(255, 255, 255);
setBackgroundColor(0, 0, 0);


// b) get array of segment lengths
// get dx = xi+1 - xi
// get dy = yi+1 - yi
// unless separator
dx = newArray(resultsX.length-2*nPart-1); // numbers of separator: 1+2*n*particles
dy = newArray(dx.length);

counter=0;
for (i=1;i<resultsX.length ;i++){
	if (resultsX[i-1] != 0 && resultsX[i] != 0){
		dx[counter] = resultsX[i]-resultsX[i-1];
		dy[counter] = resultsY[i]-resultsY[i-1];
		counter=counter+1;
	}
}

// c) get array of segment directions theta and length d
// sqrt(dy^2 + dx^2)
// tan(dy/dx) / dow we care on signs? atan will do range -pi/2 - pi/2
d = newArray(dx.length);
theta= newArray(d.length);
for (i=0;i<d.length;i++){
	d[i] = sqrt(pow(dx[i],2)+pow(dy[i],2));
	theta[i] = atan(dy[i]/dx[i]);
}



// d) projection function 
// ask for steps
Dialog.create("angular binning");
Dialog.addMessage("Width of bins in degree:"); 
Dialog.addNumber(" ", 3);
Dialog.show;
binw = Dialog.getNumber();
nbins = 180/binw;

// add to each theta a delta (from 0-pi) and calc cos((theta+delta)*d) = xproj and sum for each delta
delta = Array.getSequence(nbins);
for (i=0;i<delta.length;i++){
delta[i]=delta[i]*binw/180*PI;
}

xproj=newArray(delta.length); // result of projections length for each delta angle
for (i=0;i<xproj.length;i++){ // fo+r each delta
	xprojsum= 0;
	for (j=0; j<d.length; j++){ // for each segment
 		xprojsum=xprojsum + abs(cos(theta[j]+delta[i])*d[j]);
	}
	xproj[i]= xprojsum;
}

// normalize to 1
Array.getStatistics(xproj, min, max) 
for (i=0;i<xproj.length;i++){
xproj[i]=xproj[i]/max;
}


// e) plot proj function
xproj_plot = Array.concat(xproj,xproj[0]);
delta_plot = Array.concat(delta,PI);
for (i=0;i<delta_plot.length; i++){
delta_plot[i]	= delta_plot[i]*180/PI;
}

autoUpdate(true);
setBatchMode(false);

Plot.create("segment_projection_function", "angle", "p-length");
Plot.setFrameSize(512,512);
Plot.setLimits(0, 180, 0, 1);
Plot.setColor("black");
Plot.setLineWidth(2);
Plot.add("line",delta_plot ,xproj_plot);
Plot.show();
//Plot.showValues();

// f) rose diagram
// use bins 
delta_bins = Array.concat(delta,PI);
// make theta be in the range 0-pi - no mod( available)
for (i=0;i<theta.length;i++){
	while (theta[i]<0){
	theta[i]=theta[i]+PI;
	}
	while (theta[i]>PI){
	theta[i]=theta[i]-PI;
	}
}
// find the correct bin and add the length of segments
rosed = newArray(nbins);
for (i=0; i<d.length; i++){
	c = 0;
	for (j=0;j<delta_bins.length-1;j++){
		if (theta[i] > delta_bins[j] && theta[i]<delta_bins[j+1]){
			binpos = j;
		}
	}
	rosed[binpos]=rosed[binpos]+d[binpos];
}
// normalize to 1
Array.getStatistics(rosed, min, max) 
for (i=0;i<rosed.length;i++){
	rosed[i]=rosed[i]/max;
}

// plot rose diagram ->convert to x,y coords
// get binscenter
bincenter = Array.copy(delta);
for (i=0; i<bincenter.length;i++){
	bincenter[i]=bincenter[i]+(binw/180*PI/2);
}
// get coords
xp = newArray(rosed.length);
yp = newArray(rosed.length);
for (i=0;i<rosed.length;i++){
	yp[i]=rosed[i]*sin(bincenter[i]);
	xp[i]=rosed[i]*cos(bincenter[i]);
}
// add zeros
xp0 = newArray(2*xp.length);
yp0 = newArray(2*xp.length);

c=0;
for (i=0;i<xp0.length;i+=2){ // every 2nd entry
	xp0[i]=xp[c];
	yp0[i]=yp[c];
	c=c+1;
}
xp0mir = Array.copy(xp0);
yp0mir = Array.copy(yp0);

// mirror because nicer
for (i=0;i<xp0mir.length;i++){ // every 2nd entry
	xp0mir[i]=xp0mir[i]*-1;
	yp0mir[i]=yp0mir[i]*-1;
}


xp0=Array.concat(xp0,xp0mir);
yp0=Array.concat(yp0,yp0mir);
// add a circle 
az = Array.getSequence(359);
az_x = newArray(az.length);
az_y = newArray(az.length);
for (i=0;i<az.length;i++){
	az_x[i] = cos(az[i]/180*PI);
	az_y[i] = sin(az[i]/180*PI);
}


Plot.create("length weighted rose diagram","","");
Plot.setFrameSize(512,512);
Plot.setLimits(-1,1,-1, 1);
Plot.setColor("black");
Plot.setLineWidth(2);
Plot.add("line", xp0, yp0);
Plot.setXYLabels("", "");
Plot.setFormatFlags("0");
Plot.setFontSize(0.0);
Plot.setAxisLabelSize(12.0, "plain");
Plot.add("line", az_x, az_y);
Plot.show()

// cshape sum up coordinates from rose diagram (recenter?)
xsum= newArray(xp0.length);
ysum= newArray(yp0.length);
xsum[0]=xp0[0];
ysum[0]=yp0[0];

for (i=1;i<xsum.length;i++){
	xsum[i]=xsum[i-1]+xp0[i];
	ysum[i]=ysum[i-1]+yp0[i];
}



//xy = xy./max([max(xy(:,1)) max(xy(:,2))]);
Array.getStatistics(xsum, min, max); xmax = max;
Array.getStatistics(ysum, min, max); ymax = max; 
maxAx = newArray(xmax,ymax);
Array.getStatistics(maxAx, min, max);

for (i=0;i<xsum.length;i++){
	xsum[i]=xsum[i]/max;
	ysum[i]=ysum[i]/max;
}
Array.getStatistics(xsum, min, max); xmax = max; xmin=min;
Array.getStatistics(ysum, min, max); ymax = max; ymin=min;
for (i=0;i<xsum.length;i++){
    xsum[i]=xsum[i]+(abs(xmin)-abs(xmax))/2;
    ysum[i]=ysum[i]+(abs(ymin)-abs(ymax))/2;
}
Array.getStatistics(xsum, min, max); xmax = max;
Array.getStatistics(ysum, min, max); ymax = max;
maxAx = newArray(xmax,ymax);
Array.getStatistics(maxAx, min, max);
lim=max+max/10;

Plot.create("characteristic shape","","");
Plot.setFrameSize(512,512);
Plot.setColor("black");
Plot.setLineWidth(2);
Plot.add("line", xsum, ysum);
Plot.setLimits(-lim,lim,-lim,lim);

// write output to results
run("Clear Results");
for (i=0; i < delta_plot.length; i++){
	setResult("projAngle", i,  delta_plot[i]); // angle increaments used for projection
	setResult("relProjLength", i,  xproj_plot[i]); // relative total proj. length
}
for (i=0; i < xp0.length; i++){
	setResult("rose_x", i,  xp0[i]); // x cords of rose diagram
	setResult("rose_y", i,  xp0[i]); // y coords of rose diagram
}
for (i=0;i<bincenter.length;i++){
	setResult("azi", i,  bincenter[i]); // bin centers for rose diagram 
	setResult("rho", i,  rosed[i]); // binpopulation for rose diagram
}
for (i=0;i<xsum.length;i++){
	setResult("cShape_x", i,  xsum[i]); // characteristic shape  
	setResult("cShape_y", i,  ysum[i]); // characteristic shape
}

updateResults();
selectWindow("Results");
}
