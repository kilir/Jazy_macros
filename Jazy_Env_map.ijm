// Version 0.0.5a
//-----------------------------------------------------------------------------------------
//-------------------------------Map-envelop-related-properties-to-image-------------------
//---------------------------------------------ImageJ--------------------------------------
//  needs some work
//  TODO:
//  - adapt size of calibration bar to image size (?)
//  - label map property
//  - fix calibation bar rounding non-sense
//  - write results to results window (they are calculated anyways)
//

//---------------------------------------------------------------------------------------------
macro "invert inverted LUT [z]"
{
    run("Invert LUT");
    run("Invert");
}
//---------------------------------------------------------------------------------------------
macro "invert image [i]"
{
    run("Invert");
}
//---------------------------------------------------------------------------------------------

macro "map env. prop [p]"
{

    // prep functions -----------------------------------------------------------------------------
    // calc colors - might reequire adaption depending on the range of value (0-1, 1-inf, 0-inf)

    // this one is for values of 0-inf
    function calc_filcol(fval, user_max_val, user_min_val, maxC, minC) {
        return (((fval - user_min_val) / (user_max_val - user_min_val)) * (maxC - minC)) + minC
    }

    // global minC maxC values (range of in LUT) - might be overwritten locally
    minC = 1;
    maxC = 254;

    // adapted from ROI color coder for the LUT choice menue
    function getLutList()
    {
        luts = getFileList(getDirectory("luts"));
        for (i = 0, count = 0; i < luts.length; i++)
            if (endsWith(luts[i], ".lut"))
                count++;
        list = newArray(count + 3);
        list[0] = "Fire";
        list[1] = "Ice";
        list[2] = "Spectrum";
        for (i = 0, j = 3; i < luts.length; i++)
            if (endsWith(luts[i], ".lut"))
                list[j++] = substring(luts[i], 0, lengthOf(luts[i]) - 4);
        return list;
    }

    // start here-------------------------------------------------------------------------------------
    if (is("binary") == 1) {
        // set batch mode and prepare to clean everything
        autoUpdate(false);
        setBatchMode(true);
        print("\\Clear");
        roiManager("reset");
        run("Select None");

        //--------------------------------create-info-dialog-------------------------------------------------
        Dialog.create("Map env. prop");
        Dialog.addMessage("Use map of white particles on black background");
        Dialog.show();

        //--------------------------------create-info-dialog-------------------------------------------------
        Dialog.create("More Info");
        Dialog.addMessage("This macro will set 'Process->Binary->Options...' \n to BLACK background. If you rely on white background, \n make sure to reset it afterwards.");
        Dialog.show();

        //--------------------------------1st measurement -------------------------------------------------
        // interesting option to set to make it work...form binary meanu
        run("Options...", "iterations=1 count=1 black do=Nothing");
        setThreshold(255, 255);

        // run this to get rid of particles touching edge ------------------------------------------------
        run("Set Measurements...", "area redirect=None decimal=1");
        run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Masks exclude clear");
        run("Invert LUT");
        run("Select None");
        run("Remove Overlay");

        //--------------------------------create-map-type-dialog-------------------------------------------------
        Dialog.create("Radio Buttons");
        items = newArray("paris", "deltP", "deltA", "radiusDelta");
        Dialog.addRadioButtonGroup("Maptype", items, 4, 1, "paris");
        Dialog.show;
        maptype = Dialog.getRadioButton;

        //--------------------------------create-LUT-dialog-------------------------------------------------
        Dialog.create("Choose LUT ");
        luts = getLutList();
        Dialog.addChoice("LUT:", luts, luts[1]);
        Dialog.show;
        luttype = Dialog.getChoice;

        //--------------------------------measure-something---------------------------------------------------
        // various options: use ROI manager or use start x,y
        // use XStart YStart - turns out to be much faster than ROI manager

        run("Set Scale...", "pixel=1 unit=pixel");
        run("Clear Results");
        run("Set Measurements...", "area perimeter redirect=None decimal=3");
        run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing exclude clear record add");

        // starting coordinates of each particle - later used for filling
        n = nResults;
        x = newArray(n);
        y = newArray(n);
        for (i = 0; i < n; i++) {
            x[i] = getResult("XStart", i);
            y[i] = getResult("YStart", i);
        }

        // run through results select and make convex hull
        // the following might not be needed
        // run("Set Measurements...", "area perimeter redirect=None decimal=3");

        // initialize arrays
        perim = newArray(n);
        chull = newArray(n);
        area = newArray(n);
        areaP = newArray(n);
        // numROI=roiManager("count");
        for (i = 0; i < n; i++) {
            run("Clear Results");
            doWand(x[i], y[i]);
            run("Interpolate", "interval=1 smooth"); // makes perim larger than it should be
            // run("Measure");
            // perim[i]=getResult("Perim.",0);
            // area[i]=getResult("Area",0);
            // run("Clear Results");
            List.setMeasurements; //
            perim[i] = List.getValue("Perim."); //
            area[i] = List.getValue("Area"); //
            List.clear(); //
            doWand(x[i], y[i]);
            run("Convex Hull");
            // run("Measure");
            // chull[i]=getResult("Perim.",0);
            // areaP[i]=getResult("Area",0);
            List.setMeasurements; //
            chull[i] = List.getValue("Perim."); //
            areaP[i] = List.getValue("Area"); //
        }
        // make sure that chull,areaP is not larger then perim - silly workaround
        for (i = 0; i < n; i++) {
            if (chull[i] > perim[i]) {
                perim[i] = chull[i];
            }
            if (area[i] > areaP[i]) {
                area[i] = areaP[i];
            }
        }
        // calc Paris, deltP, deltA, radiusDelta
        paris = newArray(n);
        deltP = newArray(n);
        deltA = newArray(n);
        radiusDelta = newArray(n);
        for (i = 0; i < n; i++) {
            paris[i] = 2 * (perim[i] - chull[i]) / chull[i] * 100;
            deltP[i] = (perim[i] - chull[i]) / perim[i] * 100;
            deltA[i] = (areaP[i] - area[i]) / area[i] * 100;
            radiusDelta[i] = sqrt(pow(deltP[i], 2) + pow(deltA[i], 2));
            // print(paris[i]);
        }

        //------------------------ask-what-limits-to-use--------------------------------------------------------

        if (maptype == "paris") {
            mapVal = paris;
        }
        if (maptype == "deltP") {
            mapVal = deltP;
        }
        if (maptype == "deltA") {
            mapVal = deltA;
        }
        if (maptype == "radiusDelta") {
            mapVal = radiusDelta;
        }
        // print(maptype);
        //  get min/max of maptype
        Array.getStatistics(mapVal, min, max, mean, stdDev);

        // query for user input of maxval
        Dialog.create("max" + maptype + "");
        Dialog.addMessage("Maximal " + maptype + "");
        Dialog.addNumber("user_max_val:", max);
        Dialog.show();
        user_max_val = Dialog.getNumber();

        // query for user input of minval
        Dialog.create("min" + maptype + "");
        Dialog.addMessage("Minimal " + maptype + "");
        Dialog.addNumber("user_min_val:", min);
        Dialog.show();
        user_min_val = Dialog.getNumber();

        //------------------------calculate-color-----------------------------------------------------------
        for (i = 0; i < n; i++) {
            filcol = calc_filcol(mapVal[i], user_max_val, user_min_val, maxC, minC);
            // print(filcol);
            setForegroundColor(filcol, filcol, filcol);
            doWand(x[i], y[i]);
            fill();
        }

        // set label
        setMetadata("Label", maptype);

        // clean up
        run("Select None");
        run("Remove Overlay");

        // set lut
        run(luttype);
        // set background and edge particles color
        getLut(reds, greens, blues);
        reds[0] = 255;
        greens[0] = 255;
        blues[0] = 255;

        setLut(reds, greens, blues);
        // get an extra image with a calibration bar
        run("Calibrate...", "function=[Straight Line] unit=[Gray Value] text1=[" + minC + " " + maxC + "] text2=[" + user_min_val + " " + user_max_val + "]");
        // size of calib bar
        height = getHeight;
        zoom = floor(height / 999) + 1;
        run("Calibration Bar...", "location=[Lower Left] fill=[White] label=Black number=5 decimal=2 font=10 zoom=" + zoom + " bold");
        // set label
        setMetadata("Label", maptype);
        // reset batch mode
        autoUpdate(true);
        setBatchMode("exit and display");

        // write out results
        run("Clear Results");
        for (i = 0; i < n; i++) {
            setResult("paris", i, paris[i]);
            setResult("deltP", i, deltP[i]);
            setResult("deltA", i, deltA[i]);
            setResult("radiusDelta", i, radiusDelta[i]);
        }
        updateResults();

    } else {
        showMessage("binary image required");
    }
}
