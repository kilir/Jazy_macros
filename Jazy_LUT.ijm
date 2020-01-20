//0.0.3a
//--------------------------------------------------------------------------------
//----------------------------LUT-helpers-----------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------

macro "show and export LUT [e]"{
run("Show LUT");
//List and save as
}
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
macro "import text LUT [i]"{
run("LUT... ");
}
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
macro "invert LUT [x]"{
run("Invert LUT");
}

//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
macro "reset LUT [z]"{
run("Grays");
}
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------

macro "invert LUT and image [f]"{
getLut(reds,greens, blues);
reds = Array.reverse(reds);
greens = Array.reverse(greens);
blues = Array.reverse(blues);
setLut(reds, greens, blues);
run("Invert");
}
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------

macro "apply LUT [t]"{
run("RGB Color");
run("8-bit");
}

//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------

macro "print LUT [k]"{
run("Show LUT");
run("8-bit");
}


//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
macro "log LUT [l]"{
getLut(reds,greens, blues);
scale = 255.0 / (log(255.0)/log(10));
for (i=1; i<=255; i++){
    	v = round((log(i)/log(10)) * scale);
    	reds[i]=v;
    	greens[i]=v;
    	blues[i]=v;
	}
setLut(reds, greens, blues);
}
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//built-in applying LUT
macro "log transform [L]"{
run("Macro...", "code=v=round((log(v)/log(10))*255/(log(255)/log(10)))");
//run("Log"); //alternative built-in
}

//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------

macro "Gamma correction Tool LUT [g]" {

var gamma=1;
  gamma = getNumber("Gamma:",gamma);
  w=minOf(getWidth,getHeight)*0.5;
  createGammaLUT(gamma) ;
}

function createGammaLUT(gamma) {
	a=newArray(261);
	b=newArray(261);
	r=newArray(256);
 for (i=0; i<256; i++) {
   r[i] = pow(i/255, 1/gamma)*255;
   a[i]=i/(255/w);
   b[i]=w-r[i]/(255/w);
 }
 setLut(r,r,r);
 a[255]=w; a[256]=0;a[257]=0;a[258]=w;a[259]=w;a[260]=0;
 b[255]=0;b[256]=0;b[257]=w;b[258]=0;b[259]=w;b[260]=w;
 makeSelection('freeline', a, b);
 showStatus('Gamma: '+d2s(gamma,2));
}
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//built-in aplying TUT
macro "gamma transform [G]"{
run("Gamma...");	
}

//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
macro "square LUT [s]"{ 
getLut(reds,greens, blues);
for(i=1; i<=255; i++){
	v = round((i)*(i)/255);
	reds[i]=v;
	greens[i]=v;
	blues[i]=v;
	}
setLut(reds, greens, blues);
}
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
macro "square transform [S]"{ 
run("Macro...", "code=v=round(v*v/255)");
}

//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
macro "make steps [T]"{ //looks ok

steps = 10;

Dialog.create("Steps");
Dialog.addMessage("Number of steps");
Dialog.addNumber("",steps);
Dialog.show();
steps = Dialog.getNumber();

step_size = 256/steps;
delta = 256/(steps-1);
next_step = round(step_size);
level = 255;
getLut(reds,greens, blues);

for (i = 0; i<=255; i++){
    if (i >= next_step){
      next_step = round(next_step + step_size);
      level = level - delta;
      }
    if (level < 0){
    	level = 0;
    }
reds[i] = level;
greens[i] = level;
blues[i] = level;
}
setLut(reds, greens, blues);
}

//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
macro "sawtooth LUT [W]"{ // looks ok

sigbit = 8;

Dialog.create("Sig. bits");
Dialog.addMessage("Number of significant bits");
Dialog.addNumber("1-8",sigbit);
Dialog.show();
sigbit = Dialog.getNumber();

if (sigbit == 8){ sloplen = 256;}
if (sigbit == 7){ sloplen = 128;}
if (sigbit == 6){ sloplen = 64;}
if (sigbit == 5){ sloplen = 32;}
if (sigbit == 4){ sloplen = 16;}
if (sigbit == 3){ sloplen = 8;}
if (sigbit == 2){ sloplen = 4;}
if (sigbit == 1){ sloplen = 2;}

nslopes =256/sloplen;
grayinc =256/sloplen;
getLut(reds,greens,blues);
 for (j = 1; j <= nslopes; j++){
    istart = (j-1)*sloplen;
    for (i = 1; i <= sloplen; i++){     
    	level = ((i-1)*grayinc);
    	reds[i+istart-1] = level;
    	greens[i+istart-1] = level;
    	blues[i+istart-1] = level;
    	}
  }
setLut(reds,greens,blues);
}
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
macro "color LUT for x phases [3]"{
fname=getTitle();
run("Histogram");
selectWindow(fname);
num_phase = 3;
Dialog.create("number of phases");
Dialog.addMessage("Number of phases( max = 8)");
Dialog.addNumber("(min=2)",num_phase);
Dialog.show();
num_phase = Dialog.getNumber();
getLut(reds,greens,blues);
lim=newArray(num_phase+2);
for (i = 1; i <= num_phase; i++){
 	
 	lim[i] = i;
	Dialog.create("uper limit");
	Dialog.addMessage("upper limits of phase no."+i+"");
	Dialog.addNumber("1-255",lim[i]);
	Dialog.show();
	lim[i] = Dialog.getNumber();
	}
	
print(num_phase);
Array.print(lim);
ph_max = num_phase+1;
lim[ph_max]=255;

col1 = newArray(  0,  0,    0,    137,  255, 255, 255, 255);
col2 = newArray(255,  0,  198,      0,    0,  93, 190, 255);
col3 = newArray( 73, 255,  255,   227,  229, 117,  93,  85);
for (i = 0; i < num_phase; i++){
  	for (j = lim[i]; j<= lim[i+1]; j++){
     		reds[j]=col1[i];
    		greens[j]=col2[i];
    		blues[j]=col3[i];
  		}
	}
setLut(reds,greens,blues);
}


//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
macro "grey LUT for x phases [5]"{
fname=getTitle();
run("Histogram");
selectWindow(fname);
num_phase = 3;
Dialog.create("number of phases");
Dialog.addMessage("Number of phases");
Dialog.addNumber("(min=2)",num_phase);
Dialog.show();
num_phase = Dialog.getNumber();
getLut(reds,greens,blues);

lim=newArray(num_phase+2);


for (i = 1; i <= num_phase; i++){
 	
 	lim[i] = i;
	Dialog.create("uper limit");
	Dialog.addMessage("upper limits of phase no."+i+"");
	Dialog.addNumber("1-254",lim[i]);
	Dialog.show();
	lim[i] = Dialog.getNumber();
	}
	
print(num_phase);
Array.print(lim);
ph_max = num_phase+1
lim[ph_max]=255;

for (i = 0; i < num_phase; i++){
	col1 = (lim[i]+lim[i+1])/2;
  	for (j = lim[i]; j<= lim[i+1]; j++){
	
     		reds[j]=col1;
    		greens[j]=col1;
    		blues[j]=col1;
  		}
	}
setLut(reds,greens,blues);
}

