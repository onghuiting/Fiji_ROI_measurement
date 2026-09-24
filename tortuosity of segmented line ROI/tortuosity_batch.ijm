

// This macro measures tortuosity.
//
// Written by Hui Ting, 3 Dec 2020.


////////////////////////////     USER INPUT      ////////////////////////////////////////////////////////////////

pixel_size = 1;
zip_suffix = "_roiset.zip";  // The name for roiset.zip, should be filename_roiset.zip (filename, without .tif)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

pathname = getDirectory("Choose a input folder")

list = getFileList(pathname);

res_folder = pathname+"Results";
File.makeDirectory(res_folder);

run("Set Measurements...", "  redirect=None decimal=3");
roiManager("reset");
run("Clear Results");  
Table.create("tt");   
count_all = 0;


for (ifile=0;ifile<list.length;ifile++){

	if (endsWith(list[ifile],".tif")){
		
filename = list[ifile];
zip_filename = replace(filename, ".tif", zip_suffix);

open(pathname+filename);
run("Select None");

open(pathname+zip_filename);

total_roi = roiManager("count");

for (c_roi=0;c_roi<total_roi;c_roi++){

selectWindow(filename);
roiManager("Select", c_roi);

   getSelectionCoordinates(x, y); // in pixels

	x1 = x[0];
	y1 = y[0];

	x2 = x[x.length-1];
	y2 = y[y.length-1];

	dx = x2-x1; 
	dy = y2-y1;
    straight_dist = pixel_size*sqrt(dx*dx+dy*dy); // in micron

    List.setMeasurements;
	length = List.getValue("Length");

	tt = length/straight_dist;

roi_index = c_roi+1;

Table.set(" ", count_all,count_all+1,"tt");
Table.set("Filename", count_all,zip_filename,"tt");
Table.set("ROI", count_all, roi_index,"tt");

Table.set("Length", count_all, length,"tt");
Table.set("Straight distance", count_all, straight_dist,"tt");
Table.set("tortuosity", count_all, tt,"tt");

count_all = count_all+1;

}

Table.update;

run("Close All");
roiManager("reset");

	}
}


Table.save(res_folder+File.separator+"Results of tortuosity.csv","tt");






