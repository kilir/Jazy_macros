
macro "relative Error [E]" {
	print("\\Clear");
	run("Clear Results");
	// some precautions (set black BG, fix invert LUT)
	run("Options...", "iterations=1 count=1 black do=Nothing");
	if (is("Inverting LUT")){run("Invert LUT");
	}
	//
	run("Set Measurements...", "area perimeter invert redirect=None decimal=3");
	run("Analyze Particles...", "pixel clear");
	getHistogram(histvalues, histcounts, 2);
	//print(histcounts[1]);
	n = nResults;
	run("Summarize");
	mean=getResult("Area", nResults -4);
	std=getResult("Area", nResults -3);
	phasefrac=100*histcounts[1]/(histcounts[1]+histcounts[0]);

	// compute error
	er1 = sqrt( pow(std/mean,2) +1 ) / sqrt(n); // relative error in fraction
	er2 = sqrt( pow(2*std/mean,2) +1 ) / sqrt(n); // relative error in fraction
	er3 = sqrt( pow(3*std/mean,2) +1 ) / sqrt(n); // relative error in fraction
	
	print(">>----------------------------------------------------------------------<<");
	print("all pixels:" +histcounts[1]);
	print("pixel fraction:" +phasefrac+ "%");
	print("rel. error 1 sigma: " +er1);
	print("rel. error 2 sigma: " +er2);
	print("rel. error 3 sigma: " +er3);	
	print("abs. error 1 sigma: " +phasefrac*er1+ "%");
	print("abs. error 2 sigma: " +phasefrac*er2+ "%");
	print("abs. error 3 sigma: " +phasefrac*er3+ "%");
	print(">>----------------------------------------------------------------------<<");
	}



macro "rel. Error Pcorr [C]" {
	print("\\Clear");
	run("Clear Results");
	// some precautions (set black BG, fix invert LUT)
	run("Options...", "iterations=1 count=1 black do=Nothing");
	if (is("Inverting LUT")){run("Invert LUT");
	}
	//	
	run("Set Measurements...", "area perimeter invert redirect=None decimal=3");
	run("Analyze Particles...", "pixel clear");
	
	// add corrected perimeter
	areaC_tot = 0;
	for (i=0;i<nResults;i++){
		setResult("areaC", i, getResult("Area",i) + getResult("Perim.",i));
		areaC_tot = areaC_tot+getResult("areaC", i);
	};

	n = nResults;
	run("Summarize");
	mean=getResult("areaC", nResults -4);
	std=getResult("areaC", nResults -3);
	getRawStatistics(nPixels);
	phasefrac=100*areaC_tot/nPixels;

	// compute error
	er1 = sqrt( pow(std/mean,2) +1 ) / sqrt(n); // relative error in fraction
	er2 = sqrt( pow(2*std/mean,2) +1 ) / sqrt(n); // relative error in fraction
	er3 = sqrt( pow(3*std/mean,2) +1 ) / sqrt(n); // relative error in fraction
	
	print(">>----------------------------------------------------------------------<<");
	print("all pixels (perim. corrected):" +areaC_tot);
	print("pixel fraction:" +phasefrac+ "%");
	print("rel. error 1 sigma: " +er1);
	print("rel. error 2 sigma: " +er2);
	print("rel. error 3 sigma: " +er3);	
	print("abs. error 1 sigma: " +phasefrac*er1+ "%");
	print("abs. error 2 sigma: " +phasefrac*er2+ "%");
	print("abs. error 3 sigma: " +phasefrac*er3+ "%");
	print(">>----------------------------------------------------------------------<<");
	}
}


