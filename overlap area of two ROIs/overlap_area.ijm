

// This macro outputs the area for roi1, roi2 and overlap region of roi1 & roi2 for time series (in batch).
// The input folder should consist of multiple datasets.
// Each dataset should have 3 files, as follows:
// (1) .tif file, named as xxx.tif            (this is the image stack)
// (2) .zip file, named as xxx.tif_roi1.zip   (this is the roiset.zip for roi1)
// (3) .zip file, named as xxx.tif_roi2.zip   (this is the roiset.zip for roi2)
//
// * Remember NOT TO "Remove Positions" when drawing the ROIs.
//
// Written by hui ting, 3 March 2021.


pathname = getDirectory("Choose an input folder");

list = getFileList(pathname);

res_folder = pathname+"Results";
File.makeDirectory(res_folder);


for (i = 0; i < list.length; i++) {

	if (endsWith(list[i], ".tif")){


filename = list[i];

roiManager("reset");
run("Clear Results");  
Table.create("Overlap area");   
count_all = 0;

open(pathname+filename);
name = getTitle;

/////////////////////////////////////////////////////////////////////////////////////////////////

open(pathname+filename+"_roi1.zip");
roiManager("Sort");

total_roi1 = roiManager("count");
area_roi1 = newArray(total_roi1);

for (c_roi1=0;c_roi1<total_roi1;c_roi1++){

selectWindow(name);
roiManager("Select", c_roi1);

area_roi1[c_roi1] = getValue("Area");
run("Create Mask");
rename(c_roi1+1);

}

run("Images to Stack", "name=roi1 title=[] use");

/////////////////////////////////////////////////////////////////////////////////////////////////

roiManager("reset");

open(pathname+filename+"_roi2.zip");
roiManager("Sort");

total_roi2 = roiManager("count");
area_roi2 = newArray(total_roi2);

for (c_roi2=0;c_roi2<total_roi2;c_roi2++){

selectWindow(name);
roiManager("Select", c_roi2);

area_roi2[c_roi2] = getValue("Area");
run("Create Mask");
rename(c_roi2+1);

}

run("Images to Stack", "name=roi2 title=[] use");

/////////////////////////////////////////////////////////////////////////////////////////

imageCalculator("AND create stack", "roi1","roi2");
rename("Overlap region");
setThreshold(100,255);
total_frames = nSlices;
overlap_area = newArray(total_frames);

for (fr = 1; fr <= total_frames; fr++) {

selectWindow("Overlap region");
setSlice(fr);
run("Create Selection");
overlap_area[fr-1] = getValue("Area");

Table.set(" ", count_all,count_all+1,"Overlap area");
Table.set("Filename", count_all, filename,"Overlap area");

Table.set("ROI 1 area", count_all, area_roi1[fr-1],"Overlap area");
Table.set("ROI 2 area", count_all, area_roi2[fr-1],"Overlap area");

Table.set("Overlap area", count_all, overlap_area[fr-1],"Overlap area");

count_all = count_all+1;

}

/////////////////////////////////////////////////////////////////////////////////////////////////

Table.update;
saveAs("Results", res_folder+File.separator+filename+"_overlap area.csv");
run("Close");
selectWindow("Overlap region");
run("Select None");
saveAs("Tiff", res_folder+File.separator+filename+"_overlap region.tif");
close();
selectWindow("roi1");
saveAs("Tiff", res_folder+File.separator+filename+"_roi1.tif");
close();
selectWindow("roi2");
saveAs("Tiff", res_folder+File.separator+filename+"_roi2.tif");
close();

run("Close All");

	}
}

roiManager("reset");


