# AutoDropen
AutoDropen is a fully automatic drop image analysis software in order to study the wetting properties of solid surfaces. It can analyze drop images in batches at one time, and output informations of left contact angle, right contact angle, average contact angle, and drop diameter. This software is developed in **MATLAB**.

AutoDropen is modified and improved base on [Dropen](https://doi.org/10.17632/wzchzbm58p.3), which is developed by Akbari. Therefore, please cite the following papers when you using AutoDropen in your study:

[1]

[2] R. Akbari, C. Antonini, Contact angle measurements: From existing methods to an open-source tool, Advances in Colloid and Interface Science 294 (2021) 102470. https://doi.org/10.1016/j.cis.2021.102470.

# How to use
Before run the code, make sure that your MATLAB has installed the **Image Processing Toolbox**.

**Step1**: open `AutoDropen_main.m`
![](https://github.com/Whale2333/AutoDropen/blob/main/How%20to%20use/Step1.png)

**Step2**: set the input parameters `scale` and `Imag_suff`. The `scale` means the number of pixels equal to 1mm in the image, that you can obtain by taking a picture of a ruler. The `scale` is used for dertermining the droplet diameter. If you only need the contact angle, you don't have to change it. The `Imag_suff` means the images suffix, such as jpg,bmp,jpeg.
![](https://github.com/Whale2333/AutoDropen/blob/main/How%20to%20use/Step2.png)

**Step3**: run the code and choose the images folder. Make sure that all the images have same suffix.
![](https://github.com/Whale2333/AutoDropen/blob/main/How%20to%20use/Step3.png)

**Step4**: crop the images. It is necessary to crop out the irrelevant background to improve the accuracy of the contact angle analysis. Remerber to retain partial reflection shadows to help the code identify the edge point.
![](https://github.com/Whale2333/AutoDropen/blob/main/How%20to%20use/Step4.png)

**Step5**: The code will continue work until all images have been analyzed, then a excel document will be generated.
![](https://github.com/Whale2333/AutoDropen/blob/main/How%20to%20use/Step5.png)

 
