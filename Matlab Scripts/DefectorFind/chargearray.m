function [pD,nD] =chargearray(nx,ny,qc) 
%CHARGEARRAY finds the location of defects within the specified topological
%charge field.
%
%   INPUTS:
%       -nx, ny: Number of x and y-coordinates in sampling lattice
%       -qc: Charge field, containing values of +0.5 at locations of +1/2
%       defects and -0.5 at locations of =1/2 defects.
%
%   OUTPUTS:
%       -pD: Coordinates of +1/2 defects, in pixels
%       -nD: Coordinates of -1/2 defects, in pixels
%
%   Author: Amin Doostmohammadi, (c) 2021

xpq=[];ypq=[]; xnq=[]; ynq=[];
for i=2:nx-1
    for j=2:ny-1
        x1=0;y1=0;n1=0;
        if(abs(qc(i,j))>0.4) %If there is a defect detected here
            ql=sign(qc(i,j)); x1=i;y1=j;n1=1;qc(i,j)=0;
            for ii=-1:1 %loop over a 3x3 sqare around this pixel
                for jj=-1:1
                    if(ql*qc(i+ii,j+jj)>0.4) %If this is tagged with the same defect marker
                        x1=x1+i+ii;y1=y1+j+jj;n1=n1+1;
                        qc(i+ii,j+jj)=0;
                    end
                end
            end
            if(ql>0)
                xpq=[xpq;x1/n1]; %Mean x and y coordinates of the marked defect
                ypq=[ypq;y1/n1];
            else
                xnq=[xnq;x1/n1];
                ynq=[ynq;y1/n1];
            end
        end
    end
end
ypq = (ypq-1);
xpq = (xpq-1);
ynq = (ynq-1);
xnq = (xnq-1);

pD=[xpq,ypq];
nD=[xnq,ynq];