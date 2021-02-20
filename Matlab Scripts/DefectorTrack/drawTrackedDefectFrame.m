function [] = drawTrackedDefectFrame(procDefTracks,tS,figH,imgList,outImgDir,currF)
%DRAWTRACKEDDEFECTFRAMES overlays the set of defects present at the given
%time on top of the original image, as well as defect tracks associated
%with these.
%
%   INPUTS:
%       -procDefTracks: The defect track data structure, following the
%       usual format of FAST tracks. Additional fields include population
%       (1 for +1/2 defects, 2 for -1/2 defects, 3 for inconsistent
%       topological charge) and sparefeat1, which contains the topological
%       charge data over time for the defect.
%       -tS: User-defined settings for performing tracking. Structure
%       the fields incProp (training link inclusion fraction), tgtDensity
%       (the ambiguous link probability), dt (the timestep size in physical
%       units), minTrackLength (the minimum length of a track to be
%       included, in timesteps), pixSize (the physical size of a single
%       pixel) and imgHeight/imgWidth (the dimensions of the original
%       image, in physical units).
%       -figH: Handle to figure you want to plot into.
%       -imgList: Cell array containing strings defining paths to images
%       you wish to analyse.
%       -outImgDir: Location you want output overlays to be saved to. Set
%       to [] if plotting is set to false.
%       -currF: Frame index you want to plot.
%
%   Author: Oliver J. Meacock, (c) 2021

figure(figH)
axH = gca;
cla(axH)

imgDat = imread(imgList{currF});
imagesc(axH,imgDat)
colormap('gray')
axis(axH,'equal')
axis(axH,[0-size(imgDat,2)/20,21*size(imgDat,2)/20,0-size(imgDat,1)/20,21*size(imgDat,1)/20])

axH.XTick = [];
axH.YTick = [];
hold on

%%%START OF PLOTTING PARAMETERS %%%
[nx,ny] = size(imgDat);
nMax = max(nx,ny);
defectScale = nMax/100;
defectThickness = 2;
%%%END OF PLOTTING PARAMETERS%%%

for cInd = 1:size(procDefTracks,2)
    locInd = find(procDefTracks(cInd).times == currF,1);
    if ~isempty(locInd)
        plotX = procDefTracks(cInd).x(1:locInd)/tS.pixSize;
        plotY = procDefTracks(cInd).y(1:locInd)/tS.pixSize;
        
        if procDefTracks(cInd).population == 1
            plot(plotX,plotY,'r','LineWidth',2)
        elseif procDefTracks(cInd).population == 2
            plot(plotX,plotY,'b','LineWidth',2)
        end
        
        currX = procDefTracks(cInd).x(locInd)/tS.pixSize;
        currY = procDefTracks(cInd).y(locInd)/tS.pixSize;
        currOri = procDefTracks(cInd).phi(locInd);
        
        if procDefTracks(cInd).population == 1
            plot(axH,currX,currY,'ko','MarkerSize',defectScale,'MarkerFaceColor','k');
            plot(axH,currX,currY,'ro','MarkerSize',defectScale/1.5,'MarkerFaceColor','r');
            if ~isnan(currOri)
                plotarrow(currX,currY,cosd(currOri),sind(currOri),[1,0.5,0],defectScale*2,defectScale/defectThickness,defectScale/(defectThickness*2),axH);
            end
        elseif procDefTracks(cInd).population == 2
            if ~isnan(currOri)
                line([currX,currX+(cosd(currOri+60)*defectScale)],[currY,currY+(sind(currOri+60)*defectScale)],'Color',[0,0,0],'LineWidth',defectScale/defectThickness,'Parent',axH);
                line([currX,currX+(cosd(currOri+60)*defectScale)],[currY,currY+(sind(currOri+60)*defectScale)],'Color',[0,1,1],'LineWidth',defectScale/(defectThickness*2),'Parent',axH);
                line([currX,currX+(cosd(currOri+180)*defectScale)],[currY,currY+(sind(currOri+180)*defectScale)],'Color',[0,0,0],'LineWidth',defectScale/defectThickness,'Parent',axH);
                line([currX,currX+(cosd(currOri+180)*defectScale)],[currY,currY+(sind(currOri+180)*defectScale)],'Color',[0,1,1],'LineWidth',defectScale/(defectThickness*2),'Parent',axH);
                line([currX,currX+(cosd(currOri-60)*defectScale)],[currY,currY+(sind(currOri-60)*defectScale)],'Color',[0,0,0],'LineWidth',defectScale/defectThickness,'Parent',axH);
                line([currX,currX+(cosd(currOri-60)*defectScale)],[currY,currY+(sind(currOri-60)*defectScale)],'Color',[0,1,1],'LineWidth',defectScale/(defectThickness*2),'Parent',axH);
                
                plotTriangle(currX,currY,currOri + 60,defectScale/2,[0,0,0],axH);
                plotTriangle(currX,currY,currOri + 60,defectScale/3,[0,0,1],axH);
            else
                plotTriangle(currX,currY,60,defectScale/2,[0,0,0],axH);
                plotTriangle(currX,currY,60,defectScale/3,[0,0,1],axH);
            end
        end
    end
end

export_fig(fullfile(outImgDir,sprintf('Frame_%04d.tif',currF)),'-nocrop')