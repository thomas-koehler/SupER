---Folders---

data : evaluation data folder. you can add your own eval data folder like Set5 we did.

VDSR model : VDSR model

result : default route for saving result

util : util codes for calculating PSNR/SSIM or trim images

matconvnet : matconvnet (1.0-beta20 version)

---Files---

readme.txt : this file

testVDSR.m : sample execution file.

VDSR.m : main function file. pre-process query image, run Super-Resloution, save result. calls runVDSR.m or runPatchVDSR.m

runVDSR.m : Super-resolution process via saved model.

runPatchVDSR.m : due to memory problem, for a large image, we should cut an image into 4 pieces. controlled by managableMax value.


---Instruction---

1. Run the matconvnet/matlab/vl_compilenn.m file to comfile matconvnet
  you can change the setting if you want. 
  you can follow the instruction from http://www.vlfeat.org/matconvnet/mfiles/vl_compilenn/

2. Run the matconvnet/matlab/vl_setupnn.m file to add paths for compiled files.

3. You can run the trained model using testDRCN.m

