%THe exact definition for SmallestAbsRelCg is the absolute value of the smallest relative rotation between two nematic angles within [-pi/2,pi/2] defined in %Method to obtain winding number is refered from (in appendix a): 
% Huterer et al. - Distribution of singularities in the cosmic
% microwave background polarization - PRD 72, 043004 (2005)


%NOTE: 
%all angles involved here are nematic angles Specifically:
% 1st quadrant Vector [0,pi/2] = Nem [0,pi/2], 
% 2nd quadrant Vecotr (pi/2 , pi] = Nem (-pi/2 ,0],
% 3rd quadrant Vector (-pi, -pi/2) = Nem (0,pi/2)
% 4th quadrant Vector [-pi/2, 0] = Nem [-pi/2,0]
%In Practice, its very easy... just take Nem Angle =atan(y/x)


function AbsSmallestRelCg=GetAbsSmallestRelCg(angle1,angle2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
       
       
           temp=angle1-angle2;
           if temp<= pi/2 && temp >= -pi/2
               beta=0;
           end

           if temp < -pi/2
               beta=pi;
           end

           if temp > pi/2
               beta=-pi;
           end
           AbsSmallestRelCg=abs(temp+beta);  %absolute value of the rotation (because sometimes it can be + or -)
       
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end