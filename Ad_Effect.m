function Ad_Effect (x)

subplot(2,2,1);imshow(x);
[W h Z]=size(x);
x=double(x);
x=x./255;

D=zeros(W,h);
R=x(:,:,1);
G=x(:,:,2);
B=x(:,:,3);

%Computation of H
H=acos(0.5*((R-G)+(R-B))./sqrt((R-G).^2+(R-B).*(G-B))+eps);
H(B>G)=(2*pi)-H(B>G);
H=H/(2*pi);

%Computation of S
S=1-3.*(min(min(R,G),B)./(R+G+B)+eps);

H(S==0)=0;        

%Computation of I
I=(R+G+B)/3;

A=uint16(ginput(3));
p1=[A(4),A(1)];%First selected point for the area of action
p2=[A(5),A(2)];%Second selected point
               % [A(6),A(3)] --> Reference pixel selected

Rr=x(A(6),A(3),1);%Computes the RGB reference value
Gr=x(A(6),A(3),2);
Br=x(A(6),A(3),3);

%Computation of Hr
Hr=acos(0.5*((Rr-Gr)+(Rr-Br))./sqrt((Rr-Gr).^2+(Rr-Br).*(Gr-Br))+eps);
Hr(Br>Gr)=(2*pi)-Hr(Br>Gr);
Hr=Hr/(2*pi);

%Algorithm to compute distances
for a=1:W
    for b=1:h
        %Evaluates if it's in the selected area
        if a>=p1(1)&&a<=p2(1)&&b>=p1(2)&&b<=p2(2)
            %Computes the distances
            if (H(a,b)-Hr)<=pi 
                D(a,b)=H(a,b)-Hr;
            end
            if (H(a,b)-Hr)>pi
                D(a,b)=(2*pi)-(H(a,b)-Hr);
            end
            %If the distance is greater than 10 degrees turns into Grey
            if abs(360*D(a,b))>10
                S(a,b)=0;       
                H(a,b)=0;
            end
        end
        %If is not in the selected area turns into Grey
        if a<p1(1)||a>p2(1)||b<p1(2)||b>p2(2) 
            S(a,b)=0;
            H(a,b)=0;
        end
    end
end

%Creates the HSI Matrix
hsi=cat(3,H,S,I);
subplot(2,2,2);imshow(abs(hsi));

%HSI --> RGB 
H=hsi(:,:,1)*2*pi;
S=hsi(:,:,2);
I=hsi(:,:,3);
R=zeros(size(hsi,1),size(hsi,2));
G=zeros(size(hsi,1),size(hsi,2));
B=zeros(size(hsi,1),size(hsi,2));

% RG sector (0<=H<2*pi/3).
idx=find((0<=H)&(H<2*pi/3));
B(idx)=I(idx).*(1-S(idx));
R(idx)=I(idx).*(1+S(idx).*cos(H(idx))./cos(pi/3-H(idx)));
G(idx)=3*I(idx)-(R(idx)+B(idx));
%BG sector (2*pi/3<=H<4*pi/3).
idx=find((2*pi/3<=H)&(H<4*pi/3));
R(idx)=I(idx).*(1-S(idx));
G(idx)=I(idx).*(1+S(idx).*cos(H(idx)-2*pi/3)./cos(pi-H(idx)));
B(idx)=3*I(idx)-(R(idx)+G(idx));
%BR sector.
idx=find((4*pi/3<=H)&(H<=2*pi));
G(idx)=I(idx).*(1-S(idx));
B(idx)=I(idx).*(1+S(idx).*cos(H(idx)-4*pi/3)./cos(5*pi/3-H(idx)));
R(idx)=3*I(idx)-(G(idx)+B(idx));

rgb(:,:,1)=R;
rgb(:,:,2)=G;
rgb(:,:,3)=B;

subplot(2,2,3);imshow(abs(rgb));
   
