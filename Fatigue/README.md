# Ergometer_Fatigue

## Ergometer_Baseline_MVC.m
Purpose: Measure the baseline and the MVC
Operation: 
1. Open the file in MATLAB R2020.
2. Click "RUN".
3. Enter the subjectID in the command windows.
4. Select the language (optional) of the task.
5. Follow the instructions on the interface. 
6. The .m file will generate three main .mat files: "SubjectID_Baseline.mat", "SubjectID_MVC_n.mat" and "Variables.mat".
           

## Ergometer_GUI.m
Purpose: This .m file is only for displaying/debugging the interface, not for data acquisition. 

## Ergometer_GUI_APP.m (No trigger added yet...)
Purpose: Provide real-time visual feedback according to the force applied by the participant. 
Operation: 
1. Open the file in MATLAB R2020.
2. Click "RUN".
3. Follow the instructions on the interface.
4. Press "ESC" key anytime if your participant feels fatigued and wants to quit the experiment.


## KeyPressFcnTest.m
Purpose: A function created to close the Screen by pressing "ESC" key.
