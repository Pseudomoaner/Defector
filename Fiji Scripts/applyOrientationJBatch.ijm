Root = "C:\\Users\\olijm\\Desktop\\Fingerprint\\"; //Point to the location containing the raw (grayscale) images, formatted as 'Frame_XXXX.tif' (where XXXX is a four digit number indicating the timepoint, e.g. 0049 for timepoint 49).
tmax = 1; //Number of timepoints within dataset that you want to process (will run from t=0 to this timepoint)
tensorSize = 12; //Size of smoothing Gaussian. Set larger to reduce number of defects detected.

oriRoot = Root + "Orientations\\";

if (!File.isDirectory(oriRoot)) {
	File.makeDirectory(oriRoot);
}

//Create paired list of input file names and output file names
inFiles = newArray();
outFiles = newArray();
for (t = 0; t < tmax; t++) {
	if (t < 10) {
		tLong = "000" + t;
	} else if (t < 100) {
		tLong = "00" + t;
	} else if (t < 1000) {
		tLong = "0" + t;
	} else {
		tLong = "" + t;
	}
			
	inFiles = Array.concat(inFiles, Root +  "Frame_" + tLong + ".tif");
	outFiles = Array.concat(outFiles, oriRoot + "Frame_" + tLong + ".tif");
}

for (i = 0; i < inFiles.length; i++) {
	open(inFiles[i]);
	run("OrientationJ Analysis", "log=0.0 tensor=" + tensorSize + " gradient=0 orientation=on  harris-index=on s-distribution=on hue=Orientation sat=Coherency bri=Original-Image "); // cannot put color survey-on, if not will make negative into positive
	selectWindow("OJ-Orientation-1");
	saveAs("Tiff",outFiles[i]);
	close();
	selectWindow("OJ-Color-survey-1");
	close();
	close();
}