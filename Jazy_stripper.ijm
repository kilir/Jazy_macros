/*
Version 0.0.6a
-----------------------------------------------------------------------------------------
-------------------------------stripstar implementation to imageJ------------------------
---------------------------------------------ImageJ--------------------------------------
 measures white particles on black background, calculates perimeter corrected area-equivalent
 diameter and converts them to populations of diamteres of spheres using the Schwartz-Saltykow
 approach as realized in stripstar (Heilbronner & Bruhn 1998 https://doi.org/10.1016/S0191-8141(98)00010-8).
 A simple histogram is plotted for the realtiv frequencies
 of input diameters (h(d)), frequency of diamteres of spheres (h(D)), the volume fractions of 
 spheres (v(D)) as well as a Gaussian Kernel estimate is performed on v(D) to determine the 
 mode of v(D). Perimeter corrected equivalent diamteres and dstribution values are written to
 the results table as well as several basic statistical parameters to log.
 If you are looking for a more feature-rich, more sophisticated implementation e.g. have a look at Marco Lopezs
 Grain size tools (https://marcoalopez.github.io/GrainSizeTools/)

 TODO: works so far, but might need more testing
 TODO: fix empty bin bug
 requires imageJ >1.50n
*/

requires("1.50n")
macro "stripper [S]" {

Dialog.create("Correct perimeter?");
  items = newArray("area+perim", "area");
  Dialog.addRadioButtonGroup("Choose area definition", items, 2, 1, "area+perim");
  Dialog.show;
  eqDType = Dialog.getRadioButton;

setThreshold(255,255);
run("Options...", "iterations=1 count=2 black do=Nothing");
run("Set Measurements...", "area perimeter redirect=None decimal=3");
run("Analyze Particles...", "size=1-Infinity display clear");

// now set the result table
eqdia = newArray(nResults);
if(eqDType == "area+perim"){
for (i=0;i<nResults;i++){
	eqdia[i] = 2*sqrt( ( (getResult("Area",i)) + (getResult("Perim.",i)) ) /PI);
	setResult("EqDia", i, eqdia[i]);
	};
} else {
for (i=0;i<nResults;i++){
	eqdia[i] = 2*sqrt( ( (getResult("Area",i)) ) /PI);
	setResult("EqDia", i, eqdia[i]);
	};
}

//Array.print(eqdia);
	
// todo find min max and 
Array.getStatistics(eqdia, min, max); 
 // query for user input of maxval
max = getNumber("max. eq. d",max);
min = getNumber("min. eq. d",min);
numberofbins = getNumber("number of bins",10);

// ask for user defined bins

run("Distribution...", "parameter=EqDia or="+numberofbins+" and="+min+"-"+max+"");
selectWindow("EqDia Distribution");
Plot.getValues(BinArray, CountArray);
selectWindow("EqDia Distribution");
run("Close");

print(".................................");
print("trying to stripstar ...");
print(".................................");
print("histogram bins (eq.d) - left edge:");
Array.print (BinArray);
print("counts:");
Array.print (CountArray);

nBins=lengthOf(BinArray);
print("number of bins:  " +nBins+ " in range " +min+ "-" +max);

print(".................................");

// binwidth
// for now only linear bin, no log bins
ded = BinArray[1]-BinArray[0];

// calc distribution of spheres of uniform distribution
D = newArray(nBins,nBins);
r = createMatrix(D);
for (i=0;i<nBins;i++){
	for (j=i;j<nBins;j++){
		I =i+1;	
		J=j+1;
		val = (sqrt((J*J)-((I-1)*(I-1)))-sqrt((J*J)-(I*I)))/J;
		pos=newArray(j,i); // note:change colums and rows
		setMatrixValue(r,pos, val);
		}
	}


// make it work correctly - note this isn't done in strip star at this place 
for (i=0;i<nBins;i++){
	for (j=0;j<nBins;j++){
		pos=newArray(i,j);
		val= getMatrixValue(r,pos)/nBins*(i+1);
    	setMatrixValue(r,pos, val);
		}
	}
	
// find index of largest non-zero entry in countArray -1 
inonzero = lengthOf(CountArray)-1;
do {
   inonzero = inonzero-1;
   } while(CountArray[inonzero] == 0);

// populate array gg with matrix values
//gg = newArray(inonzero+1);
gg = newArray(inonzero+1);
pos= newArray(inonzero,inonzero); //id of r corresponding to last non-zero entry
val = getMatrixValue(r,pos);
//print("val",val); // ok
for (i=0;i<=inonzero;i++){        
       gg[i]=CountArray[i]*val/CountArray[inonzero];
	}

f = newArray(inonzero+1);
fneg = newArray(inonzero+1);
for (k=0;k<=inonzero;k++){
//print("k",k);
      m=inonzero-k; // +1 not needed since k starts at 0    
      pos=newArray(m,m);
      val= getMatrixValue(r,pos);
      factor=gg[m]/val;

       if(factor>0){
       	f[m]= factor;
       	}
	   fneg[m] = factor;
       for (i=0;i<=inonzero;i++){
        		pos=newArray(m,i);
        		val=getMatrixValue(r,pos);
        		gg[i]=gg[i]-factor*val;
 	      	}
	}
	
//recalculate sections from positive radii

//for whatever reason we calc gg again? - just to compare with stripstar output
gg = newArray(inonzero+1);
for (i=0;i<=inonzero;i++){
		gg[i]=CountArray[i]/CountArray[inonzero]; // gives rel. input sections
    	}

// cumsum of counts
gsum=0;
for (i=0;i<=inonzero;i++){
   		gsum=gsum+CountArray[i];
    	}

recalc = newArray(inonzero+1);
recalc[0]=0;
for (i=0;i<=inonzero;i++){
  	for (j=0;j<=inonzero;j++){
		pos = newArray(j,i);
  		val= getMatrixValue(r,pos);
   		recalc[i]=recalc[i]+val*f[j];
  		}
	}
for (i=0;i<=inonzero;i++){
	 recalc[i]=recalc[i]/recalc[inonzero];
	}

// weighted output
sumf=0; //sum hD
sumv=0; //sum vD
sumn=0; //sum hD*
sumx=0; // sum vD*
vsize=newArray(inonzero+1);
fvol=newArray(inonzero+1); //vD
fvox=newArray(inonzero+1); //vD*

for (i=0;i<=inonzero;i++){
      x=(i+1)*ded; //should be
      vsize[i]=pow(x,3); 
      fvol[i]=f[i]*vsize[i];
      fvox[i]=fneg[i]*vsize[i];
      }

for (i=0;i<=inonzero;i++){
      sumf=sumf+f[i];
      sumn=sumn+abs(fneg[i]);
      sumv=sumv+fvol[i];
      sumx=sumx+abs(fvox[i]);
      }
      
//normalize
for (i=0;i<=inonzero;i++){
      f[i]=100*f[i]/sumf;
      //print(f[i]);
      fneg[i]=100*fneg[i]/sumn;
      fvol[i]=100*fvol[i]/sumv;
      fvox[i]=100*fvox[i]/sumx;
      CountArray[i]=100*CountArray[i]/gsum;
      }



bc =newArray(inonzero+1); // input left edge but limited to n+1
for (i=0;i<=inonzero;i++){
	bc[i] = BinArray[i]+(ded/2);
}

print("..........Results..........");
print("eq. diamteres (bincenters)");
Array.print(bc);
print("--------------------------------------------");
print("h(d)");	
Array.print(CountArray);
print("--------------------------------------------");
print("h(D)");
Array.print(f);
print("--------------------------------------------");
print("v(D)");
Array.print(fvol);
print("--------------------------------------------");
print("h(D)*");
Array.print(fneg);
print("--------------------------------------------");
print("v(D)*");
Array.print(fvox);
print("--------------------------------------------");
print("--------------------------------------------");

// add results - if theres somethign empy, pad with 0
for (i=0;i<=inonzero;i++){
	setResult("bin", i,  BinArray[i]);
	setResult("bincenter", i,  bc[i]);
	setResult("h(d)", i,  CountArray[i]);
	setResult("h(D)", i,  f[i]);
	setResult("v(D)", i,  fvol[i]);
	setResult("h(D)*", i, fneg[i]);
	setResult("v(D)*", i, fvox[i]);
	}
updateResults();
// draw a histogram pad with 0 or with bc at 0

bcp=newArray(inonzero+1);
hdp=newArray(inonzero+1);
hDp=newArray(inonzero+1);
vDp=newArray(inonzero+1);
for (i=1;i<inonzero+1;i++){
	hdp[i] = CountArray[i-1];
	hDp[i] = f[i-1];
	vDp[i] = fvol[i-1];
	bcp[i] = bc[i-1];
	}
	
bcp[0]=bc[0]-(ded/2);
// check if smaller 0
for (i=0;i<lengthOf(bcp);i++){
	if (bcp[i]<0){
		bcp[i]=0;
		}
	}

	
//Array.print(bcp);
//Array.print(vDp);

Plot.create("Histogram","eq. diameter","%");
Plot.setLineWidth(2);
Plot.setColor("red");
Plot.add("Separated Bars", bcp, hdp);
Plot.setColor("blue");
Plot.add("Separated Bars", bcp, hDp);
Plot.setColor("green");
Plot.add("Separated Bars",  bcp, vDp);
Plot.setLimits(0,NaN,0,NaN);
Plot.setLegend("h(d)\th(D)\tv(D)", "Auto");
Plot.setFontSize(18);
Plot.show;


// get the vD mode
//-----------------------------------------------------------
// bin centers
bincenter =  Array.slice(bcp,1,lengthOf(bcp));
vD = Array.slice(vDp,1,lengthOf(bcp));
n = lengthOf(vD);

// ask for sigma
sig = 0.56*ded; // ded is binwidth
sig = getNumber("sigma of kernel used estimate mode (default 0.56*bw)",sig);


// get area

areaM=0;
for (i=0;i<n;i++){
areaM = areaM + ded*vD[i];
}

//normalize vD for area
for (i=0;i<n;i++){
	vD[i]=vD[i]/areaM;
}

// sample x on loong array 0:....bincenter(end+3*sigma)
x=Array.getSequence((3*sig+bincenter[lengthOf(bincenter)-1])*100);
for (i=0;i<lengthOf(x);i++){
	x[i]=x[i]/100;
	}

g = newArray(lengthOf(x));
gtot = newArray(lengthOf(x));

for (i=0;i<n;i++){
	mu = bincenter[i];
	// gaussian fit scaled to data
	for (j=0;j<lengthOf(x);j++){
		g[j] = vD[i]*(1/(sig*sqrt(2*PI)))*exp(-0.5*pow(((x[j]-mu)/(sig)) ,2));
		}
	//Plot.create("g","x","g",x,g);
	//Plot.show();
	//sdfdsf

	// and sum up
	for (j=0;j<lengthOf(x);j++){
		gtot[j] = gtot[j]+g[j];
		}
	}

// normalize gtot for area
area_g_tot=0;
xwidth = x[2]-x[1];
for (i=0;i<lengthOf(x);i++){
	area_g_tot = area_g_tot+ xwidth*gtot[i];
	}
for (i=0;i<lengthOf(x);i++){
	gtot[i]=gtot[i]/area_g_tot;
	}

// get the mode and plot it
Plot.create("Fit","eq. diameter","pdf");
Plot.setLineWidth(2);
Plot.setColor("red");
//add zeros  and other padding just for plotting
bcpad1 = newArray(1);
bcpad2 = newArray(1);
bcpad1[0] = bincenter[0]-(ded/2);
bcpad2[0] = bincenter[n-1]+(ded/2);
bcplot = Array.concat(bcpad1,bincenter,bcpad2);
z=newArray(1);
vDplot = Array.concat(z,vD,z);
Plot.add("Separated Bars",bcplot ,vDplot);
Plot.setColor("blue", "black");
Plot.add("line", x, gtot);


//-----------------------------------------------------------
//-----------------------------------------------------------
//-----------------------------------------------------------
// get some statistics
//-----------------------------------------------------------
//hd 
rms = calcRMS(eqdia);
Array.getStatistics(eqdia, min, max, mean, stdDev);
print("-------------------------------------");
print("h(d)    mean        rms           std");
print("           " +mean+ "   " +rms+ "   " +stdDev);
print("-------------------------------------");


//hD
bmean = binMean(f,bc);
bRMS = binRMS(f,bc);
bstd = binStd(f,bc);
print("-------------------------------------");
print("h(D)    mean        rms           std");
print("           " +bmean+ "    " + bRMS+  "   "+bstd);
print("-------------------------------------");


//vD
bmean = binMean(fvol,bc);
bRMS = binRMS(fvol,bc);
bstd = binStd(fvol,bc);
print("-------------------------------------");
print("v(D)    mean        rms           std");
print("           " +bmean+ "    " + bRMS+  "   "+bstd);
print("-------------------------------------");


// get the 3D mode
idmode = Array.findMaxima(gtot,0);
mode= x[idmode[0]];
print("-------------------------------------");
print("mode v(D) " +mode);
print("-------------------------------------");
Plot.setLegend("v(D)\t kernelfit mode ="+mode+"" ,"Auto Bottom-To-Top");
Plot.setFontSize(20);
//Plot.setLimits(0,bincenter[n-1]+ded,0,gtot[idmode[0]]*1.3);
Plot.setLimits(0,NaN,0,NaN);
//-----------------------------------------------------------
//-----------------------------------------------------------
//-----------------------------------------------------------
//-----------------------------------------------------------
//-----------------------------------------------------------
//---------------auxiliary functions-------------------------

// calc RMS from array
function calcRMS(array) {
	suma = 0;
	for(i=0 ; i<lengthOf(array); i++){
		suma = suma + pow(array[i],2);
		}
    rms = sqrt(suma/lengthOf(array));
	return rms;
}

// calc mean from binned data using binprobability and bincenter
function binMean(binprob,bincenter){
	bmean = 0;
	bsum =0;
	for (i=0 ; i<lengthOf(binprob); i++){
	bmean = bmean + binprob[i]*bincenter[i];
	bsum =  bsum + binprob[i];
	}
	bmean= bmean/bsum;
	return bmean
}

function binStd(binprob,bincenter){
	bsum =0; 
	for (i=0 ; i<lengthOf(binprob); i++){
	    bsum =  bsum + binprob[i]; // should be 1 resp 100 but who knows
	}
	bmean = binMean(binprob,bincenter);
	sumstd =0;
	for (i=0 ; i<lengthOf(binprob); i++){
	sumstd = sumstd + (binprob[i]*pow((bincenter[i] - bmean),2)) ;
	}
	sumstd= sqrt(sumstd/bsum);
	return sumstd
}

function binRMS(binprob,bincenter){
	bRMS = 0;
	bsum =0;
	for (i=0 ; i<lengthOf(binprob); i++){
	bRMS = bRMS + binprob[i]*pow(bincenter[i],2);
	bsum =  bsum + binprob[i]; // should be 1 resp 100 but who knows
	}
	bRMS= sqrt(bRMS/bsum);
	return bRMS
}

// 1D-multidimensinal matrix helpers
// from Oliver Burri, Lausanne
// first 1+n entries contain the number of dimensions and the size of each
// e.g. a 2D 10-by-10 matrix would be 2,10,10,...
// followed by 100 entries
// http://forum.imagej.net/t/multidimensional-arrays/4345/3

// create matrix value
function createMatrix(dims) {
	size1D = 1;
	nDims = dims.length;
	for(i=0; i<nDims;i++) {
		size1D *= dims[i];
	}
	arr = newArray(size1D+1+nDims);
	arr[0] = nDims;
	for(i=0; i<nDims;i++) {
		arr[i+1] = dims[i];
	}
	return arr;
}

// return matrix value
function getMatrixValue(mat, pos) {
	D = getDims(mat);
	pos = getPos(pos, D);
	return mat[pos+mat[0]+1];
}

// set value
function setMatrixValue(mat,pos, val) {
	//pos is an array of the same number of dims as the matrix
	D = getDims(mat);
	pos = getPos(pos, D);
	mat[pos+mat[0]+1] = val;
	return mat;
}
// get number of matrix dimensions
function getDims(mat) {
	D = newArray(mat[0]);
	for(i=1;i<=mat[0];i++) {
		D[i-1] = mat[i];
	}
	return D;
}

// returns the nD positions in linear indexing form
function getPos(posA, dims) {
	pos=0;
	for(i=0 ; i<dims.length ; i++) {
		fac = 1;
		for(j=i+1 ; j<dims.length ; j++) {
			fac *= dims[j];
		}
		pos+= fac*posA[i];
	}
	return pos;
}



}