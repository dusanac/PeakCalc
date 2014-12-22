PeakCalc
========

A program for PTR-TOF-MS data analysis

Authors: Dušan Materić and Ramon Gonzalez Mendez

This is a program for Kore’s PTR-TOF-MS data analysis. The program takes mass window values for the primary ions and analyte, and then calculates the normalised peak area of the analyte. By selecting a path to the folder where the data are storage as .csv files, the program calculates areas of all files and stores them in a report file.  The program is especially useful when dealing with large number of data files (for example: plant VOC measurement, compound signal measurement, E/N study, etc.). The default reagent ion in this case is water and the data are normalised to one million reagent ions (H3O+).

To install it please follow the steps:
1.	Make a folder (for example in C: ) and name it peakCalc
2.	Copy peakCalc.pl and defaults.txt to the folder (C:\peakCalc)
3.	Make a subfolder named “data” in C:\peakCalc
4.	Copy test .csv files in the subfolder C:\peakCalc\data

To run/test the software please follow the steps:
1.	Copy your/test .csv files in the subfolder C:\peakCalc\data
2.	Start->Run and type “cmd” to open the commander
3.	Type “perl C:\peakCalc\peakCalc.pl” to execute the program
4.	Read the report file which is generated in C:\peakCalc

The program is multiplatform and has been tested on Windows, OSX and Linux.

If you have any issues please send an e-mail to: dusan.materic@gmail.com

	


