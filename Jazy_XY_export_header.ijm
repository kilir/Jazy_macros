//Version 0.0.9a by rkilian
//-----------------------------------------------------------------------------------------
//----------------------------------------Export-x-y-coordinates---------------------------
//---------------------------------------------ImageJ-------------------------------------- 
// This macro exports XY-coodinates, at reagular spacing in pixels an/or/smoothed to a file,
// with header, which can be directly used in surfor, paror. Separator is 0. The legacy option
// produces a file without header, ready to use in scasmo. Spacing between nodes (codist) should not
// be too large (e.g. <10). Particles with codist^2 are not analysed
// 0.0.4 added ignore particles touching edge
// 0.0.9 added adjust to match
// 0.0.10 stupid syntax update

macro "XYexport-regdist-smooth [1]"{ 
print("\\Clear");
run("Select None");

//showMessage("Information" ,"Image will be scaled to pixels. If the macro fails, choose a smaller discard size.");
//run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");

var codist = "1"; 
{
        Dialog.create("coordinate distance");
        Dialog.addMessage("Enter pixel distance");
        Dialog.addNumber("Distance:", codist);
        Dialog.show();
        codist = Dialog.getNumber();
}

var header = "header"; 
{
        Dialog.create("header");
        Dialog.addMessage("Enter some text");
        Dialog.addString("Text:", header, 12);
        Dialog.show();
        header = Dialog.getString();
}

discard_size = codist*codist;//codist;
toScaled(discard_size);


run("Set Measurements...", "area perimeter invert decimal=3");
run("Analyze Particles...", "minimum="+discard_size+" maximum=999999 bins=20 show=Nothing exclude clear record");
run("Outline");


print(header);
print("numlines");
countr = 0;

autoUpdate(false);
setBatchMode(true);

for (i=0; i<nResults; i++) {
    XX = getResult('XStart', i);
    YY = getResult('YStart', i);

        doWand(XX, YY);
        run("Interpolate", "interval="+codist+" smooth adjust");
        getSelectionCoordinates(x, y);
        	toScaled(x, y);
        	{
             		for (j=0; j<x.length-1; j++)
         			print(x[j]+ "  " + -1*y[j]);
         			print(x[0], -1*y[0]);
        	}
       	print(0, 0);
//    	countr = countr+(x.length+1);
    	countr = countr+j+1;
}
countr = countr + i
print("\\Update 1:"+countr+"");

run("Select None");
//selectWindow("Log");
//saveAs("Text", "");
content = getInfo("log");


f = File.open("");
print(f,content);
File.close(f);

}


// This macro exports XY-coodinates, at reagular spacing in pixels an/or/smoothed

macro "XYexport-regdist [2]"{ 
print("\\Clear");
run("Select None");
showMessage("Information" ,"Image will be scaled to pixels. If the macro fails, choose a smaller discard size.");
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");



var codist = "3"; 
{
        Dialog.create("coordinate distance");
        Dialog.addMessage("Enter pixel distance");
        Dialog.addNumber("Distance:", codist);
        Dialog.show();
        codist = Dialog.getNumber();
}

var header = "header"; 
{
        Dialog.create("header");
        Dialog.addMessage("Enter some text");
        Dialog.addString("Text:", header, 12);
        Dialog.show();
        header = Dialog.getString();
}

discard_size = codist*codist;

run("Set Measurements...", "area perimeter circularity decimal=3");
run("Analyze Particles...", "minimum="+discard_size+" maximum=999999 bins=20 show=Nothing exclude clear record");
run("Outline");


print(header);
print("numlines");
countr = 0;

autoUpdate(false);
setBatchMode(true);
for (i=0; i<nResults; i++) {
    XX = getResult('XStart', i);
    YY = getResult('YStart', i);

        doWand(XX,YY);
        run("Interpolate", "interval="+codist+" adjust");
        getSelectionCoordinates(x, y);
        	{
             		for (j=0; j<x.length; j++)
         			print(x[j]+ "  " + -1*y[j]);
         			print(x[0], -1*y[0]);
        	}
       	print( 0, 0);
	
//	countr = countr+(x.length+1);
	countr = countr+j+1;
}
countr = countr + i
print("\\Update 1:"+countr+"");

run("Select None");
//selectWindow("Log");
//saveAs("Text", "");
content = getInfo("log");


f = File.open("");
print(f,content);
File.close(f);

}


// This macro exports XY-coodinates

macro "XYexport-legacy [3]"{ 
print("\\Clear");
run("Select None");
showMessage("Information" ,"Image will be scaled to pixels.");
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");


run("Set Measurements...", "area perimeter circularity decimal=3");
run("Analyze Particles...", "minimum=1 maximum=999999 bins=20 show=Nothing exclude clear record");
run("Outline");


autoUpdate(false);
setBatchMode(true);
for (i=0; i<nResults; i++) {
    XX = getResult('XStart', i);
    YY = getResult('YStart', i);

        doWand(XX,YY);
        getSelectionCoordinates(x, y);
        	{
             		for (j=0; j<x.length; j++)
         			print(x[j]+ "  " + -1*y[j]);
         			print(x[0], -1*y[0]);
        	}
       	print( 0, 0);

}


run("Select None");

content = getInfo("log");


f = File.open("");
print(f,content);
File.close(f);

}

