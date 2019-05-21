---Folders---

data : evaluation data folder. you can add your own eval data folder like Set5 we did.

DRCN model : 3 DRCN models for each scale factors (x2, x3, x4)

result : default route for saving result

util : util codes for calculating PSNR/SSIM or trim images

snu_matconvnet : matconvnet with some differences. 

---Files---

readme.txt : this file

testDRCN.m : sample execution file.

DRCN.m : main function file. pre-process query image, run Super-Resloution, save result. calls runDRCN.m or runPatchDRCN.m

runDRCN.m : Super-resolution process via saved model.

runPatchDRCN.m : due to memory problem, for a large image, we should cut an image into 4 pieces. controlled by managableMax value.


---Instruction---

1. Run the snu_matconvnet/setup.m file to comfile matconvnet
  you can change the setting if you want. 
  you can follow the instruction from http://www.vlfeat.org/matconvnet/mfiles/vl_compilenn/

2. Run the snu_matconvnet/matlab/vl_setupnn.m to add paths for compiled files.

3. You can run the trained model using testDRCN.m

