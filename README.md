# Jendryka_et_al_ACC_imaging_5CSRTT
## important note: raw data (behavioral and calcium imaging data) will be made public upon publication in a peer-reviewed journal. 
how to use repository
1. clone repository to desired folder using git clone https://github.com/martinjendryka/Jendryka_et_al_ACC_imaging_5CSRTT.git or download the repository as a zip file from Github.com
2. Create a new folder where the data and results (pdf, excel and mat files) will be stored. In  the following this folder is referred to as the dataResults folder 
3. Create a text file inside the repository (Jendryka_et_al_ACC_imaging_5CSRTT) and name it userpath.txt
4. Open userpath.txt with a text editor and type in the directory of the DataResults folder you created in step 2. Make sure it ends with the name of the folder and there is no / at the end (i.e. yourpath/dataResults)
5. Start MATLAB (everything from v2019 should be fine) and using the editor go to the repository folder (Jendryka_et_al_ACC_imaging_5CSRTT)
6. In the command window, type add2path. This adds the functions and scripts to the path and creates a folder structure for storing the raw behavioral data and pre-processed calcium imaging data.
7. Go to the dataResults folder. Inside the folder data, there are two folders: behavior and miniscope. 
8. Open the behavior folder. Go to the public repository (link will be added) to download the raw behavioral files and unpack the zip file into the behavioral folder. 
9. Open the miniscope folder. Go to the public repository (link will be added) and unpack the calcium imaging data into the corresponding experiment folder. Make sure that there are five folders with the names: varITI, cb800ms, cbExt1, cbExt2, cbDeval1, mixedChall
10. In Matlab type runMaster into the command window. This will start a script to reproduce the figures. They will be stored into dataResults/results/figs. 
