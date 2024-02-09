clc;
clear;
warning off

%% DataPreprocessing
% Input parameters setting  
scale=120; % set the Scale.The value meas the number of pixels in the image equal to 1mm. Here 120 means "1 mm = 120 pixels".
Imag_suff='jpeg'; % input the images suffix, such as jpg,bmp,jpeg
%Create an empty matrix for data.
Contact_angle_left_array=[];
Contact_angle_right_array=[];
Contact_angle_array=[];                                                                                                                                                                                                                                                                                                                                                                                        
D_array=[];

%% ImageReading
%read all images directory
folder_path = uigetdir('*.*','Choose the file');
folder_name = regexp(folder_path, '\', 'split');
folder_name=folder_name(end);
disp(strcat('folder_path:',folder_path));
all_imgs_dir=dir(strcat(folder_path,'/*.',Imag_suff));
sorted_name=sort_nat({all_imgs_dir.name});
for i=1:size(sorted_name,2)
    all_imgs_dir(i).name=cell2mat(sorted_name(i));
end

%Create an zero matrix for data.
Contact_angle_left_array=zeros(size(sorted_name,2),1);
Contact_angle_right_array=zeros(size(sorted_name,2),1);
Contact_angle_array=zeros(size(sorted_name,2),1);
D_array=zeros(size(sorted_name,2),1);


%% ImageCropping
%During image analysis, it is required that only the contours of the image are present; otherwise, it will affect the results. 
%In most experimental captures, due to various constraints, it is inevitable that the background outside the droplet contours will also be captured. 
%At this point, it is necessary to crop out the irrelevant background to improve the accuracy of the contact angle analysis.

%Read the position where to be cropped
I1=imread(strcat(folder_path,'/',all_imgs_dir(1).name));%read the first picture in folder.
imshow(I1);
rectangle = imrect;
pos = getPosition(rectangle);
I2 = imcrop(I1, pos);
imshow(I2);


%% ImageProcessing
for i=1:size(sorted_name,2)
    %ImageCrop
    disp(strcat('Processed images: ',num2str(i),'/',num2str(size(sorted_name,2))));
    src=imread(strcat(folder_path,'/',all_imgs_dir(i).name));
    src1=imcrop(src, pos);

    % ImageGrayscale
    src2=src1(:,:,1);
    src3 = imadjust(src2);
    ID=src3;

    % ImageAnalysis
    [Gmag,Gdir,EDGE,I_New,AXx,AXy,Apex_x,Apex_y, Left_edgeTx,Left_edgeDx,Right_edgeTx,Right_edgeDx,Num_Down_L, Num_Up_L,Num_Down_R,...
    Num_Up_R,End_x_L,End_x_R] = ImageAnalysis(ID);

    % ContactPointIdentification
    [b,D,alphac,alpham,Contact_angle_left,Contact_angle_right,Contact_angle,TiltAngle_S] ...
    = CircleMask(ID,Gmag,Gdir,EDGE,scale,I_New,AXx,AXy,Apex_x,Apex_y, Left_edgeTx,Left_edgeDx,Right_edgeTx,Right_edgeDx,...
    Num_Down_L, Num_Up_L,Num_Down_R,Num_Up_R,End_x_L,End_x_R);
    
    %Output 0 when the contact point cannot be found in a image.
    try
    Contact_angle_left_array(i)=Contact_angle_left;
    Contact_angle_right_array(i)=Contact_angle_right;
    Contact_angle_array(i)=Contact_angle;
    D_array(i)=D;
    catch ME
    Contact_angle_left_array(i)=0;
    Contact_angle_right_array(i)=0;
    Contact_angle_array(i)=0;
    D_array(i)=0;
    warning('Exception caught: %s', ME.message);
    end
end

%Combine all the data
data=[Contact_angle_left_array,Contact_angle_right_array,Contact_angle_array,D_array];
data_cell=mat2cell(data,ones(size(data, 1),1),ones(size(data, 2),1));
data_all=[sorted_name',data_cell];
title_1={'Name','LeftAngle(°)','RightAngle(°)','AverageAngle(°)','D(mm)'};
result=[title_1;data_all];

%write into the excel file
excel_file_name=strcat(folder_name,'.xls');
xlswrite(excel_file_name{1},result);
disp('Excel file generation succeed!')
close;
