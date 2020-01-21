/*
Version 0.0.1a
-----------------------------------------------------------------------------------------
-------------------------surfor/paror implementation to imageJ---------------------------
---------------------------------------------ImageJ--------------------------------------
Uses smooth outlines of particles and derives the projection function of boundary
segments, a length weighted segment trend distribution (rose diagram) and the characteristic
shape, particle projection function and rose diagrams for longest particle projection axes
and the particle length normal to the shortest
Original programs were develope by Renee Heilbronner, see:
Panozzo, R., 1983. Two-dimensional analysis of shape fabric using projections of digitized 
                   lines in a plane. Tectonophysics, 95: 279-294.
Panozzo R., 1984.  Two-dimensional strain from the orientation of lines in a plane. J Struct 
                   Geol 6:215–221        
                              
Convention: we rotate particles ccw or the coordinate system cw

TODO:
- extract b/a
- write output automatically to file
- preedined bins positions are actually bad, better to determine bin positions based on 
  angular frequencies i.e. estimate maximum first and center bins around it
- use wrapped Gaussian to estimate density from rose plots  
*/


macro "sparfor"{
// a) get xy cords
run("Select None");

//showMessage("Information" ,"Image will be scaled to pixels. If the macro fails, choose a smaller discard size.");
//run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");

var codist = "3"; 
{
        Dialog.create("coordinate distance");
        Dialog.addMessage("Enter minmal pixel distance for smoothing:");
        Dialog.addNumber("Distance:", codist);
        Dialog.show();
        codist = Dialog.getNumber();
}

// ask for steps of paror 
Dialog.create("Angular binning for (s)paror");
Dialog.addMessage("Width of bins for paror in degree:"); 
Dialog.addNumber(" ", 3);
Dialog.show;
binwp = Dialog.getNumber();
nbinsp = 180/binwp;

//  get array of angles for paror from binwidth for angles
deltap = Array.getSequence(nbinsp);
for (i=0;i<deltap.length;i++){
deltap[i]=deltap[i]*binwp/180*PI;
}

// as for surfor angles 
Dialog.create("angular binning for surfor");
Dialog.addMessage("Width of bins for surfor in degree:"); 
Dialog.addNumber(" ", 3);
Dialog.show;
binw = Dialog.getNumber();
nbins = 180/binw;

//  get array of angles for surfor from binwidth for angles
deltas = Array.getSequence(nbins);
for (i=0;i<deltas.length;i++){
deltas[i]=deltas[i]*binw/180*PI;
}

//minimal particle to evaluate as a function of  smoothing distance between particles
discard_size = 10*codist;//codist;
toScaled(discard_size);

//-----------------------------------------------------------------------------------------
// start doing something
//-----------------------------------------------------------------------------------------
run("Set Measurements...", "area perimeter invert decimal=3"); // do we need to get rid of invert here?
run("Analyze Particles...", "minimum="+discard_size+" maximum=999999 bins=20 show=Nothing exclude clear record");
nPart = nResults; 

autoUpdate(false);
setBatchMode(true);
setForegroundColor(192, 192, 192);
resultsX = newArray(1); // write final array
resultsY = newArray(1);

totalPlength= newArray(deltap.length);  //sum of pLength for each particle
maxPLPart = newArray(nPart);            // max projection lengths for rose diagram
maxdeltapPL = newArray(nPart);          // angle corresponding to maxPLPart
sparPL = newArray(nPart);               // perpendicular projection length
spardeltaPL = newArray(nPart);          // corresponding angle
c= 0; // a counter for valid particles
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

    // ------------------------------------------------------
    // PAROR/SPAROR
    // rotate coordiantes from temp array
    pLengthx = newArray(deltap.length); // array for the projection lengths of each particle
    for (j=0; j<deltap.length; j++){ // iterate through angles, should return an array of projection length
     	x_rot=newArray(x.length);    
     		for (k=0; k<x.length; k++){ // rotate all coordiantes
         			x_rot[k] = cos(deltap[j])*x[k] + sin(deltap[j])* y[k];
         			//y_rot[k] = -sin(omega[j])*x[k] + cos(omega[j])*y[k]; // we just need the x-ccordinates
		         }      
        // find the projection lengthes against x-axis
        //Array.getStatistics(x_rot, min, max) 
      	id_max = Array.findMaxima(x_rot,0,2);
      	id_min = Array.findMinima(x_rot,0,2);
      	if (id_max.length != 0 || id_min.length != 0){
      		id_max=id_max[0];
      		id_min=id_min[0];
      		pLengthx[j]= x_rot[id_max] - x_rot[id_min];
      		}
     	}
    // find the maximum projection length and also angle to write to rose diagram
    maxPLPartid = Array.findMaxima(pLengthx,0,2);
    if (maxPLPartid.length != 0){
    	maxPLPartid=maxPLPartid[0]; // id of maximum
    	maxPLPart[c] = pLengthx[maxPLPartid]; // one length for each particle for rose //___________
    	maxdeltapPL[c] = deltap[maxPLPartid];  // one angle for each particle for rose //___________
    
		// perp to min projection length
		minPLPartid = Array.findMinima(pLengthx,0,2);
		minPLPartid = minPLPartid[0]; // id of minimum
    	// 90 degree correspond to half length deltaP in id
    	hD = floor(deltap.length /2);
    	iddelta = minPLPartid+hD;
    	if (iddelta > deltap.length){
    		iddelta = minPLPartid-hD;
    		}
     	    
    	sparPL[c] = pLengthx[iddelta-1];    // used for rose  ; -1 because  indexing starts at 0 //___________
    	spardeltaPL[c] = deltap[iddelta-1]; // used for rose  ; -1 because  indexing starts at 0 //___________
    	c=c+1; // count up
    } 
    // now sum up all projection functions for each angle sparPL spardeltaPL
    // used for paror plot
    for (j=0; j<deltap.length; j++){
    totalPlength[j] = totalPlength[j]+ pLengthx[j];
    }
} // end of measuring loop
// check for new length of nPart
nPart = maxPLPart.length;
// get rid of empty lines in maxPLPart maxdeltapPL ...


run("Select None");
setForegroundColor(255, 255, 255);
setBackgroundColor(0, 0, 0);
//--------------------------------------------------------
// SURFOR

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
// get array of segment directions theta and length d
// used for the rose diagram
// sqrt(dy^2 + dx^2)
// tan(dy/dx) / dow we care on signs? atan will do range -pi/2 - pi/2
d = newArray(dx.length);
theta= newArray(d.length);
for (i=0;i<d.length;i++){
	d[i] = sqrt(pow(dx[i],2)+pow(dy[i],2));
	theta[i] = atan(dy[i]/dx[i]);
}

// add to each theta the deltas (from 0-pi) and calc cos((theta+deltas)*d) = xproj and sum for each deltas
xproj=newArray(deltas.length); // result of projections length for each deltas (bin) angle
for (i=0;i<xproj.length;i++){ // for each deltas
	xprojsum= 0;
	for (j=0; j<d.length; j++){ // for each segment
 		xprojsum=xprojsum + abs(cos(theta[j]+deltas[i])*d[j]);
	}
	xproj[i]= xprojsum;
}

//------------------------------------------------------------
//plotting section
//------------------------------------------------------------
// for paror use for the
// projection function
// -> totalPlength and deltap
// for the paror rose diagram 
// -> maxPLPart and  maxdeltapPL
// for the sparor rose diagram 
// -> sparPL and spardeltaPL

// normalize to 1 surfor projections 
Array.getStatistics(xproj, min, max);
for (i=0;i<xproj.length;i++){
xproj[i]=xproj[i]/max;
}

// normalize to 1 paror projection
Array.getStatistics(totalPlength, min, max);
for (i=0;i<totalPlength.length;i++){
totalPlength[i]=totalPlength[i]/max;
}

//------------------------------------------------------------
// f) plot proj functions surfor 
xproj_plot = Array.concat(xproj,xproj[0]);
deltas_plot = Array.concat(deltas,PI);
for (i=0;i<deltas_plot.length; i++){
deltas_plot[i]	= deltas_plot[i]*180/PI;
}
autoUpdate(true);
setBatchMode(false);

Plot.create("segment_projection_function", "angle", "p-length");
Plot.setFrameSize(512,512);
Plot.setLimits(0, 180, 0, 1);
Plot.setColor("black");
Plot.setLineWidth(2);
Plot.add("line",deltas_plot ,xproj_plot);
Plot.show();
//Plot.showValues();

//------------------------------------------------------------
// f) plot projetion functions paror
paror_plot = Array.concat(totalPlength,totalPlength[0]);
deltap_plot = Array.concat(deltap,PI);
// reverse order (this needs to be done better)
paror_plot= Array.reverse(paror_plot);
for (i=0;i<deltap_plot.length; i++){
deltap_plot[i]	= deltap_plot[i]*180/PI;
}
autoUpdate(true);
setBatchMode(false);

Plot.create("particle_projection_function", "angle", "p-length");
Plot.setFrameSize(512,512);
Plot.setLimits(0, 180, 0, 1);
Plot.setColor("black");
Plot.setLineWidth(2);
Plot.add("line",deltap_plot ,paror_plot);
Plot.show();
//Plot.showValues();

//----------------------------------------------------------------
// f) rose diagram SURFOR (using d and theta)
// make bins go from 0 to PI
deltas_bins = Array.concat(deltas,PI);
// make theta be in the range 0-pi - no mod() available
// 
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
	for (j=0;j<deltas_bins.length-1;j++){
		if (theta[i] > deltas_bins[j] && theta[i]<deltas_bins[j+1]){
			binpos = j;
		}
	}
	rosed[binpos]=rosed[binpos]+d[binpos];
}

// normalize to 1
Array.getStatistics(rosed, min, max); 
for (i=0;i<rosed.length;i++){
	rosed[i]=rosed[i]/max;
}

// plot rose diagram ->convert to x,y coords
// get binscenter
bincenter = Array.copy(deltas);
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



// ---------------------------------
// a circle for plotting 
az = Array.getSequence(359);
az_x = newArray(az.length);
az_y = newArray(az.length);
for (i=0;i<az.length;i++){
	az_x[i] = cos(az[i]/180*PI);
	az_y[i] = sin(az[i]/180*PI);
}
// ---------------------------------

Plot.create("surface segments rose diagram (length weighted)","","");
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

//-----------------------------------------------------------------
// characteristic shape SURFOR
// cshape sum up coordinates from rose diagram (recenter?)
// TODO: close outline

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

// repeat first point at the end
xcsh = Array.concat(xsum,xsum[0]);
ycsh = Array.concat(ysum,ysum[0]);

Plot.create("characteristic shape","","");
Plot.setFrameSize(512,512);
Plot.setColor("black");
Plot.setLineWidth(2);
Plot.add("line", xcsh , ycsh);
Plot.setLimits(-lim,lim,-lim,lim);
Plot.show()

//----------------------------------------------------------------
// f) rose diagram PAROR / SPAROR
// -> maxPLPart and  maxdeltapPL
// for the sparor rose diagram 
// -> sparPL and spardeltaPL
// classes are deltap, nbinsp, binwp

// use bins for paror and sparor
deltap_binp = Array.concat(deltap,PI); // used for both sparor and paror
// find the correct bin and sum the length of segments for PAROR
rosedPAR = newArray(nbinsp);
for (i=0; i<maxPLPart.length; i++){
	for (j=0;j<deltap_binp.length-1;j++){		
		if (maxdeltapPL[i] >= deltap_binp[j] && maxdeltapPL[i]<deltap_binp[j+1]){
			binposPAR = j;
		}
	}
	rosedPAR[binposPAR]=rosedPAR[binposPAR]+maxPLPart[i];
}

// find the correct bin and sum the length of segments for SPAROR
rosedSPA = newArray(nbinsp);
for (i=0; i<sparPL.length; i++){
	for (j=0; j<deltap_binp.length-1; j++){
		if (spardeltaPL[i] >= deltap_binp[j] && spardeltaPL[i]<deltap_binp[j+1]){
			binposSPA = j;
		}
	}
	rosedSPA[binposSPA]=rosedSPA[binposSPA]+sparPL[i];
}

// normalize paror rose to 1
Array.getStatistics(rosedPAR, min, max); 
for (i=0;i<rosedPAR.length;i++){
	rosedPAR[i]=rosedPAR[i]/max;
}
// normalize sparor rose to 1
Array.getStatistics(rosedSPA, min, max); 
for (i=0;i<rosedSPA.length;i++){
	rosedSPA[i]=rosedSPA[i]/max;
}
//------------------------------------------------------------------------
// PAROR :  plot rose diagram ->convert to x,y coords --------------------
// get binscenter
bincenterSPAR = Array.copy(deltap_binp); // used for both sparor and paror
for (i=0; i<bincenterSPAR.length;i++){
	bincenterSPAR[i]=bincenterSPAR[i]+(binwp/180*PI/2);
}
// probably discard last entry, but it's not used anyways

// get coords PAROR
xPAR = newArray(rosedPAR.length);
yPAR = newArray(rosedPAR.length);
for (i=0;i<rosedPAR.length;i++){
	xPAR[i]=rosedPAR[i]*cos(bincenterSPAR[i]);
	yPAR[i]=rosedPAR[i]*sin(bincenterSPAR[i]);
}
// get coords SPAROR
xSPA = newArray(rosedSPA.length);
ySPA = newArray(rosedSPA.length);
for (i=0;i<rosedPAR.length;i++){
	xSPA[i]=rosedSPA[i]*cos(bincenterSPAR[i]);
	ySPA[i]=rosedSPA[i]*sin(bincenterSPAR[i]);
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// add zeros and mirro (becuase it's nice) PAROR
xp0PAR = newArray(2*xPAR.length);
yp0PAR = newArray(2*yPAR.length);
c=0;
for (i=0;i<xp0PAR.length;i+=2){ // every 2nd entry
	xp0PAR[i]=xPAR[c];
	yp0PAR[i]=yPAR[c];
	c=c+1;
}
xp0mirPAR = Array.copy(xp0PAR);
yp0mirPAR = Array.copy(yp0PAR);
for (i=0;i<xp0mirPAR.length;i++){ // every 2nd entry
	xp0mirPAR[i]=xp0mirPAR[i]*-1;
	yp0mirPAR[i]=yp0mirPAR[i]*-1;
}
xp0PAR=Array.concat(xp0PAR,xp0mirPAR);
yp0PAR=Array.concat(yp0PAR,yp0mirPAR);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// add zeros and mirro (becuase it's nice) SPAROR
xp0SPA = newArray(2*xSPA.length);
yp0SPA = newArray(2*ySPA.length);
c=0;
for (i=0;i<xp0SPA.length;i+=2){ // every 2nd entry
	xp0SPA[i]=xSPA[c];
	yp0SPA[i]=ySPA[c];
	c=c+1;
}
xp0mirSPA = Array.copy(xp0SPA);
yp0mirSPA = Array.copy(yp0SPA);
for (i=0;i<xp0mirSPA.length;i++){ // every 2nd entry
	xp0mirSPA[i]=xp0mirSPA[i]*-1;
	yp0mirSPA[i]=yp0mirSPA[i]*-1;
}
xp0SPA=Array.concat(xp0SPA,xp0mirSPA);
yp0SPA=Array.concat(yp0SPA,yp0mirSPA);

//-------------------------------------------------------------------
// plot PAROR
Plot.create("PAROR rose diagram (length weighted)","","");
Plot.setFrameSize(512,512);
Plot.setLimits(-1,1,-1, 1);
Plot.setColor("black");
Plot.setLineWidth(2);
Plot.add("line", xp0PAR, yp0PAR);
Plot.setXYLabels("", "");
Plot.setFormatFlags("0");
Plot.setFontSize(0.0);
Plot.setAxisLabelSize(12.0, "plain");
Plot.add("line", az_x, az_y);
Plot.show()


//-------------------------------------------------------------------
// plot SPAROR
Plot.create("SPAROR rose diagram (length weighted)","","");
Plot.setFrameSize(512,512);
Plot.setLimits(-1,1,-1, 1);
Plot.setColor("black");
Plot.setLineWidth(2);
Plot.add("line", xp0SPA, yp0SPA);
Plot.setXYLabels("", "");
Plot.setFormatFlags("0");
Plot.setFontSize(0.0);
Plot.setAxisLabelSize(12.0, "plain");
Plot.add("line", az_x, az_y);
Plot.show()


//-------------------------------------------------------------------
// compute b/a, assymmetry etc

//-------------------------------------------------------------------

// write output to results
run("Clear Results");
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// surfor pf
for (i=0; i < deltas_plot.length; i++){
	setResult("pAngle_surf", i,  deltas_plot[i]); // angle increaments used for projection
	setResult("pLength_surf", i,  xproj_plot[i]); // relative total proj. length
}
//- - cshape
for (i=0;i<xcsh.length;i++){
	setResult("cShape_x", i,  xcsh[i]); // characteristic shape  
	setResult("cShape_y", i,  ycsh[i]); // characteristic shape
}
//- - x,y cords incl. empty lines 
for (i=0; i < xp0.length; i++){
	setResult("rose_x_surf", i,  xp0[i]); // x cords of rose diagram
	setResult("rose_y_surf", i,  yp0[i]); // y coords of rose diagram
}
//- - azi, rho incl. empty lines
for (i=0; i < xp0.length; i++){
setResult("azi_surf", i,  atan2(yp0[i],xp0[i])*180/PI); // bin centers for rose diagram 
setResult("rho_surf", i,  sqrt(pow(xp0[i],2)+pow(yp0[i],2))); // binpopulation for rose diagram
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// paror pf
for (i=0; i < deltap_plot.length; i++){
	setResult("pAngle_par", i,  deltap_plot[i]); // angle increaments used for projection
	setResult("pLength_par", i,  paror_plot[i]); // relative total proj. length
}
//- - x,y cords incl. empty lines 
for (i=0; i < xp0PAR.length; i++){
	setResult("rose_x_par", i,  xp0PAR[i]); // x cords of rose diagram
	setResult("rose_y_par", i,  yp0PAR[i]); // y coords of rose diagram
}
//- - azi, rho incl. empty lines
for (i=0; i < xp0PAR.length; i++){
	setResult("azi_par", i,  atan2(yp0PAR[i],xp0PAR[i])*180/PI); // x cords of rose diagram
	setResult("rho_par", i,  sqrt(pow(xp0PAR[i],2)+pow(yp0PAR[i],2))); // y coords of rose diagram
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
//- - x,y cords incl. empty lines 
for (i=0; i < xp0SPA.length; i++){
	setResult("rose_x_spa", i,  xp0SPA[i]); // x cords of rose diagram
	setResult("rose_y_spa", i,  yp0SPA[i]); // y coords of rose diagram
}
//- - azi, rho incl. empty lines
for (i=0; i < xp0PAR.length; i++){
	setResult("azi_spa", i,  atan2(yp0SPA[i],xp0SPA[i])*180/PI); // x cords of rose diagram
	setResult("rho_spa", i,  sqrt(pow(xp0SPA[i],2)+pow(yp0SPA[i],2))); // y coords of rose diagram
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 


updateResults();
selectWindow("Results");
}
