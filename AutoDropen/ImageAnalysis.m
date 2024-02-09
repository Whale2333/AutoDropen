function [Gmag,Gdir,EDGE,I_New,AXx,AXy,Apex_x,Apex_y, Left_edgeTx,Left_edgeDx,Right_edgeTx,Right_edgeDx,Num_Down_L, Num_Up_L,Num_Down_R,...
    Num_Up_R,End_x_L,End_x_R] = ImageAnalysis(ID)
try
Gmag=[];
Gdir=[];
I_New=[];
AXx=[];
AXy=[];
Apex_x=[];
Apex_y=[];
Left_edgeTx=[];
Left_edgeDx=[];
Right_edgeTx=[];
Right_edgeDx=[];
Num_Down_L=[];
Num_Up_L=[];
Num_Down_R=[];
Num_Up_R=[];
End_x_L=[];
End_x_R=[];
%Generation of gradiant matrix 产生梯度矩阵，梯度矩阵的作用是找到图像中的边缘、角点、纹理等特征
[Gx,Gy] = imgradientxy(ID);
[Gmag,Gdir] = imgradient(Gx,Gy);

%Alteration of image gradiant by adjusting gray level
Gmag1=Gmag;
Gdir1=Gdir;
Max_Gmag=max(max(Gmag));
%Adaptive Thresholding
level = graythresh(Gmag);
     for ii=1:size(ID,1)
         for jj=1:size(ID,2)
             if Gmag(ii,jj)<(level*Max_Gmag)
                Gmag1(ii,jj)=0;
                Gdir1(ii,jj)=0;
             end
         end
     end

%Derivation of edge data from image using zerocross method
edge_image = edge(ID,'zerocross');

EDGE = bwareaopen(edge_image, round(size(ID,1)/2)); %removes small objects
EDGEa = bwmorph(EDGE,  'bridge', Inf);
EDGEb = bwmorph(EDGEa, 'close', Inf);
EDGEc = bwmorph(EDGEb, 'thin', Inf);

edge_image1=zeros(size(ID,1),size(ID,2));
     for ii=1:size(ID,1)
         for jj=1:size(ID,2)
             if EDGE(ii,jj)==false
                edge_image1(ii,jj)=0;
             end
             if EDGE(ii,jj)==true
                edge_image1(ii,jj)=1;
             end
         end
     end

% Derivation of drop boundaries using the edge image
[mat_boundaries, label_boundaries] = bwboundaries(edge_image1);
     for ii=1:size(mat_boundaries,1)
            mmx(ii)=size (mat_boundaries{ii,1},1);
     end
mmx=mmx.';
BL = find (mmx==max(mmx));

AXx1=mat_boundaries{BL(1),1}(:, 1);
AXy1=mat_boundaries{BL(1),1}(:, 2);

%Drop apex
Apex_x=min(AXx1);
%Apex_y=round(mean(AXy1(find(AXx1==Apex_x))));
Apex_y=round(mean(AXy1(AXx1==Apex_x)));

Low_x=max(AXx1);
%Low_y=round(mean(AXy1(find(AXx1==Low_x))));
Low_y=round(mean(AXy1(AXx1==Low_x)));


%Alteration of boundary to have only one boundary line in each side of drop
ll=0;
AXx=0;
AXy=0;
for kk=1:max(size(AXx1))
    rr=AXx1(kk);
    cc=AXy1(kk);
    if not(ismember(rr,AXx))
        %cc1=min(AXy1(find(AXx1==rr)));
        cc1=min(AXy1(AXx1==rr));
        ll=ll+1;
        AXx(ll,1)=rr;
        AXy(ll,1)=cc1;
        %cc2=max(AXy1(find(AXx1==rr)));
        cc2=max(AXy1(AXx1==rr));
        if cc2~=0 && cc2> cc1+5
        ll=ll+1;
        AXx(ll,1)=rr;
        AXy(ll,1)=cc2;  
        end
    end
end

%Search the final data in vertical axis (=x) the left and right side of drop
End_x_L=max(AXx(AXy<Apex_y));
End_y_L=min(AXy(AXx==End_x_L));
End_x_R=max(AXx(AXy>Apex_y));
End_y_R=max(AXy(AXx==End_x_R));
End_Data=max(End_x_R , End_x_L);

%Generation of new image in black and white using the border data
%Before the drop apex
I_New=zeros(size(ID,1),size(ID,2)); 
for ii=1:Apex_x
    for jj=1:size(ID,2)
        I_New(ii,jj)=1;
    end
end
%after the fanal border data
for ii=End_Data+1:size(ID,1)
    for jj=1:size(ID,2)
        I_New(ii,jj)=1;
    end
end
%in drop area
 for kk=1:max(size(AXx))
     rr=AXx(kk);
     cc=AXy(kk);
     if cc<Apex_y
     for jj=1:cc
        I_New(rr,jj)=1;
     end
     end
     if cc >= Apex_y
     for jj=cc:size(ID,2)
        I_New(rr,jj)=1;
     end
     end
 end
 %Alteration in new intensity matrix to avoid unexpected mistakes in the convolution
 %matrix
  if End_x_L < End_Data 
    for ii=End_x_L+1:End_Data
    for jj=1:End_y_L-1
        I_New(ii,jj)=1;
    end
    end
 end
 
 if End_x_R < End_Data
    for ii=End_x_R+1:End_Data
    for jj=End_y_R+1:size(ID,2)
        I_New(ii,jj)=1;
    end
    end
 end

%Search for the left edges of drop(= minimum of horizontal(=y) data of drop border)
%Top side
Left_edgeTy=min(AXy);
L_X=AXx(AXy==Left_edgeTy);
Left_edgeTx= min(L_X);

Right_edgeTy=max(AXy);
R_X=AXx(AXy==Right_edgeTy);
Right_edgeTx= min(R_X);

while I_New(Left_edgeTx,Left_edgeTy)==0
    if I_New(Left_edgeTx,Left_edgeTy)==0
        Left_edgeTx=Left_edgeTx+1;
    end
end
rr=Left_edgeTx;
cc=Left_edgeTy;
ia=0;
%finding the centeral data of the edge part
while ismember(rr,L_X)
    if I_New(rr,cc)~=0
       ia=ia+1;
       rr=rr+1;
    end
end
Left_edgeTx=abs(round((rr+Left_edgeTx)/2))-1;

%Reflection part
Left_edgeDx= max(L_X);
Left_edgeDy=min(AXy(find(AXx==Left_edgeDx)));
if Left_edgeDx > Left_edgeTx+20
while I_New(Left_edgeDx,Left_edgeDy)==0
    if I_New(Left_edgeDx,Left_edgeDy)==0
        Left_edgeDx=Left_edgeDx-1;
    end
end
end
%finding the central data of the edge part
rr=Left_edgeDx;
cc=Left_edgeDy;
ia=0;
while ismember(rr,L_X)
    if I_New(rr,cc)~=0
       ia=ia+1;
       rr=rr-1;
    end
end
Left_edgeDx=abs(round((rr+Left_edgeDx)/2))-1;
%this alteration is needed in some hydrophilic drops
if Left_edgeDx < Left_edgeTx 
    Left_edgeDx=Left_edgeTx;
end

%Search for the right edges of drop(= maximum of horizontal(=y) data of drop border)
while I_New(Right_edgeTx,Right_edgeTy)==0
    if I_New(Right_edgeTx,Right_edgeTy)==0
        Right_edgeTx=Right_edgeTx+1;
    end
end
rr=Right_edgeTx;
cc=Right_edgeTy;
ia=0;
%finding the centeral data of the edge part
while ismember(rr,R_X)
    if I_New(rr,cc)~=0
       ia=ia+1;
       rr=rr+1;
    end
end
Right_edgeTx=abs(round((rr+Right_edgeTx)/2))-1;

%Reflection part
Right_edgeDx= max(R_X);
%Right_edgeDy=max(AXy(find(AXx==Right_edgeDx)));
Right_edgeDy=max(AXy(AXx==Right_edgeDx));

if Right_edgeDx > Right_edgeTx+20
while I_New(Right_edgeDx,Right_edgeDy)==0
    if I_New(Right_edgeDx,Right_edgeDy)==0
        Right_edgeDx=Right_edgeDx-1;
    end
end
end

%finding the central data of the edge part
rr=Right_edgeDx;
cc=Right_edgeDy;
ia=0;

while ismember(rr,R_X)
    if I_New(rr,cc)~=0
       ia=ia+1;
       rr=rr-1;
    end
end
Right_edgeDx=abs(round((rr+Right_edgeDx)/2))-1;
%this alteration is needed in some hydrophilic drops
if Right_edgeDx < Right_edgeTx 
    Right_edgeDx=Right_edgeTx;
end

%counting the number of data upper than the top edge=Num_Up and after that=Num_Down
Num_Up_L=0;
Num_Down_L=0;
for kk=1:max(size(AXx))
    if AXy(kk)< Apex_y
        if AXx(kk) <= Left_edgeTx
        Num_Up_L=Num_Up_L+1;
        end
        if AXx(kk) > Left_edgeTx
            Num_Down_L=Num_Down_L+1;
        end
    end
end

Num_Up_R=0;
Num_Down_R=0;
for kk=1:max(size(AXx))
    if AXy(kk)> Apex_y
        if AXx(kk) <= Right_edgeTx
        Num_Up_R=Num_Up_R+1;
        end
        if AXx(kk) > Right_edgeTx
            Num_Down_R=Num_Down_R+1;
        end
    end
end


SE_L=0;
if Left_edgeDx==Left_edgeTx && Num_Down_L>=Num_Up_L*0.5 && Low_y~=Apex_y && (End_x_L-Apex_x)> 0.6*(Right_edgeTy-Left_edgeTy)
%&& (max(End_x_L,End_x_R)-Apex_x)<2*(Left_edgeTx-Apex_x)&& (max(End_x_L,End_x_R)-Apex_x)>(Right_edgeTy-Left_edgeTy)
    Left_edgeDx=End_x_L;
    SE_L=SE_L+1;
end

SE_R=0;
if Right_edgeDx==Right_edgeTx && Num_Down_R>=Num_Up_R*0.5 && Low_y~=Apex_y && (End_x_R-Apex_x)> 0.6*(Right_edgeTy-Left_edgeTy)
%&& (max(End_x_L,End_x_R)-Apex_x)<2*(Left_edgeTx-Apex_x)&& (max(End_x_L,End_x_R)-Apex_x)>(Right_edgeTy-Left_edgeTy)
    Right_edgeDx=End_x_R;
    SE_R=SE_R+1;
end

catch ME
    warning('Exception caught: %s', ME.message);
end

end


