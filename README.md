# AutoDropen
AutoDropen is a fully automatic drop image analysis software in order to study the wetting properties of solid surfaces. It can analyze drop images in batches at one time, and output informations of left contact angle, right contact angle, average contact angle, and drop diameter. This software is developed in **MATLAB**.

AutoDropen is modified and improved base on [Dropen](https://doi.org/10.17632/wzchzbm58p.3), which is developed by Akbari. Therefore, please cite the following papers when you using AutoDropen in your study:

[1]

[2] R. Akbari, C. Antonini, Contact angle measurements: From existing methods to an open-source tool, Advances in Colloid and Interface Science 294 (2021) 102470. https://doi.org/10.1016/j.cis.2021.102470.

# How to use
Before run the code, make sure that your MATLAB has installed the **Image Processing Toolbox**.

**Step1**: open'AutoDropen_main.m'
![](AutoDropen/How to use/Step1)

**Step2**: set the input parameters 'scale' and 'Imag_suff'. 'scale' means the number of pixels in the image equal to 1mm. 'Imag_suff' means the images suffix, such as jpg,bmp,jpeg.

**Step3**: run the code and choose the images folder. Make sure that all the images have same suffix.

**Step4**: select where to crop the images. It is necessary to crop out the irrelevant background to improve the accuracy of the contact angle analysis.

**Step5**: The code will continue work until all images have been analyzed and a excel document will be generated.

 
