%[CircleMask.m]
function [b,D,alphac,alpham,Contact_angle_left,Contact_angle_right,Contact_angle,TiltAngle_S] ...
    = CircleMask(ID,Gmag,Gdir,EDGE,scale,I_New,AXx,AXy,Apex_x,Apex_y, Left_edgeTx,Left_edgeDx,Right_edgeTx,Right_edgeDx,...
Num_Down_L, Num_Up_L,Num_Down_R,Num_Up_R,End_x_L,End_x_R)

try
b = [];
D = [];
alphac = [];
alpham = [];
Contact_angle_left = [];
Contact_angle_right = [];
Contact_angle = [];
TiltAngle_S=[];
%Variables
b=20;%matrix size=2b+1
m=2*b+1;
R=b+1;
Mask=zeros(m,m);%Mask, ones up
Ar=zeros(size(ID,1),size(ID,2)); % convolution area
alphac=zeros(size(ID,1),size(ID,2)); %alphac=Calculated angle in 2D system
IA=zeros(m,m);%Locale area matrix
lambda=1;%sgn(slope)
MP=zeros(m,m);%Mask, ones up
MM=zeros(m,m);%Mask, ones down
MS=0;%Mask size
v=0;
vv=0;
vx=0;
%alpham=Calculated angle data

%Generation of masks (characterization mask)
 for ii = 1:m
   for jj = 1:m
       condition = ((ii - R)^2+ (jj - R)^2)/(b^2);
        if condition <=1  && ii<=b
            Mask(ii,jj) = 1;
        end
        if condition <=1  &&  ii>(b+1)
            Mask(ii,jj) = -1;
        end
   end
end
ArTotal1=nnz(Mask);
 

%Generation of masks (angle calculation masks)
for ii = 1:m
   for jj = 1:m
       condition = ((ii - (b+1))^2+ (jj - (b+1))^2)/(b^2);
        if condition <=1  && jj <=(b+1)
            MP(jj,ii) = 1;
            MS=MS+1;
        end
        if condition <=1  && jj >=(b+1)
            MM(jj,ii) = 1;
        end
   end
end
ArTotal=2*MS-2*b-1;

% calculation of the convolution area and tangent angle in each point of border 
%using the circle mask
up=0;
down=0;
m_up=0;
m_down=0;
for kk=1:max(size(AXx))
    rr=AXx(kk);
    cc=AXy(kk);
    if rr>b && rr<size(ID,1)-b && cc>b && cc<size(ID,2)-b  
        if cc<=Apex_y
            IA=I_New(rr-b:rr+b,cc-b+1:cc+b+1);
        end
        if cc>Apex_y
            IA=I_New(rr-b:rr+b,cc-b-1:cc+b-1);
        end
        IA1=IA.*Mask;
        IA3=sum(IA1,'all');%baseline identification factor
        if (rr<= Left_edgeTx && cc<=Apex_y ) || (rr<= Right_edgeTx && cc>Apex_y ) %upper side
           up=up+1;
           IA2=IA.*MP;
           Ar(rr,cc)=sum(IA2,'all');
        end
        if (rr> Left_edgeDx  && rr> Left_edgeTx  && cc<=Apex_y) || (rr> Right_edgeDx  && rr> Right_edgeTx  && cc > Apex_y)  %Down side
           down=down+1;
           IA2=IA.*MM;
           Ar(rr,cc)=sum(IA2,'all');
        end
        if IA3>=0 && ((rr> Left_edgeTx && rr<= Left_edgeDx && cc<=Apex_y) ||(rr> Right_edgeTx && rr<= Right_edgeDx && cc> Apex_y))  %down part of middle
            IA2=IA.*MM;
            Ar(rr,cc)=(sum(IA2,'all'));
            m_down=m_down+1;
        end
        if  IA3<0 && ((rr> Left_edgeTx &&  rr<= Left_edgeDx && (Num_Down_L> Num_Up_L*0.5 )&& cc<=Apex_y) ||(rr> Right_edgeTx &&  rr<= Right_edgeDx && (Num_Down_R> Num_Up_R*0.5 )&& cc>Apex_y)) %top part of middle 
            IA2=IA.*MP;
            Ar(rr,cc)=(sum(IA2,'all'));
            m_up=m_up+1;
        end    
        alphac(rr,cc)=180-(180/pi)*(2*pi* Ar(rr,cc)/(ArTotal));
        if  alphac(rr,cc)> 171
             alphac(rr,cc)= alphac(rr-5,cc);
        end
    end
end  
vv;

%Gathering of the area and angle data
ss=0;
 for kk=1:max(size(AXx))
     rr=AXx(kk);
     cc=AXy(kk);
           ss=ss+1;
           lambda=1;
           if cc<Apex_y
               lambda=-1;
           end
           if rr<= size(ID,1) && cc<=size(ID,2)   && Ar(rr,cc)~=0
           alpham(1,ss)=rr;
           alpham(2,ss)=cc;
           alpham(3,ss)=lambda*sqrt((rr-Apex_x)^2+(cc-Apex_y)^2);% length of arc (from the apex)
           alpham(4,ss)=Ar(rr,cc);
           alpham(5,ss)=alphac(rr,cc);
           end
end
ss;
%Idenifiction of baseline and left and right contact points
M_MioL=max(max(alphac(1:End_x_L-3,1:Apex_y)));
M_MioR=max(max(alphac(1:End_x_R-3,Apex_y:size(ID,2))));

colXR=0;
[rowXL,colXL]=find(round(alphac(:,1:Apex_y),1)==round(M_MioL,1));
[rowXR,colXR]=find(round(alphac(:,Apex_y:size(ID,2)),1)==round(M_MioR,1));
%[rowXL,colXL]=find(floor(alphac(:,1:Apex_y))==floor(M_MioL));
%[rowXR,colXR]=find(floor(alphac(:,Apex_y:size(ID,2)))==floor(M_MioR));
colXR=colXR+Apex_y-1;

x_CPL= min(rowXL);
if M_MioL<89
    M_MioL=max(max(alphac(1:Left_edgeTx,1:Apex_y)));
    [rowXL,colXL]=find(round(alphac(:,1:Apex_y),1)==round(M_MioL,1));
    for ii=1:size(rowXL)
    drL(ii)=rowXL(ii)-Left_edgeTx;
    end
    mindrL=min(abs(drL(:)));

    for  ii=1:size(rowXL)
        if drL(ii)==-mindrL 
    x_CPL=rowXL(ii);
        end
    end
end
%y_CPL=colXL(find(rowXL==x_CPL));
y_CPL=colXL(rowXL==x_CPL);

x_CPR= min(rowXR);
if M_MioR<89
    colXR=0;
    M_MioR=max(max(alphac(1:Right_edgeTx,Apex_y:size(ID,2))));
    [rowXR,colXR]=find(round(alphac(:,Apex_y:size(ID,2)),1)==round(M_MioR,1));
    colXR=colXR+Apex_y-1;
     for ii=1:size(rowXR)
    drR(ii)=rowXR(ii)-Right_edgeTx;
    end
    mindrR=min(abs(drR(:)));
    for  ii=1:size(rowXR)
        if drR(ii)==-mindrR
    x_CPR=rowXR(ii);
        end
    end
end
%y_CPR=colXR(find(rowXR==x_CPR));
y_CPR=colXR(rowXR==x_CPR);

TiltAngle_S=0; %baseline tilt angle
if x_CPL~=x_CPR
   TiltAngle_S= atan2(x_CPR-x_CPL, y_CPR-y_CPL) * 180/pi;
end
TiltAngle_S;
%Calculation of contact angles
Contact_angle_left=round(alphac(x_CPL,y_CPL)+TiltAngle_S,2);
Contact_angle_right=round(alphac(x_CPR,y_CPR)-TiltAngle_S,2);
Contact_angle=(Contact_angle_left+Contact_angle_right)/2;
D=round((((x_CPL(1)-x_CPR(1))^2+(y_CPL(1)-y_CPR(1))^2)^0.5)/scale,6);  %the unit of D is millimeter

catch ME
    D=0;
    Contact_angle_left=0;
    Contact_angle_right=0;
    Contact_angle=0;
    warning('Exception caught: %s', ME.message);
end

end
