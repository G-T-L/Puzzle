% splicingImg = generateSplicingImg(src,img_reg,allocationMatrix)
% splicingImg = generateSplicingImg(src,img_reg,coordinatesOffsetMatrix)
% function splicingImg = generateSplicingImg(src,img_reg,allocationMatrix,searchRange)
% if nargin<4
%     searchRange=1;
% end
% 
% if size(img_reg,1)~=size(allocationMatrix,1)
%     coordinatesOffsetMatrix = calcCoordinatesOffsetMatrix(img_reg,allocationMatrix,searchRange);
% else
%     coordinatesOffsetMatrix=allocationMatrix;
% end
% 
% length=2.*round(sqrt(img_reg(1).Area).*size(img_reg,1));
% splicingImg=zeros(length,length,size(src,3));
% for i=1:size(img_reg)
%     for j=1:size(img_reg(i).PixelList,1)
%         %             for k=1:size(src,3)
%         splicingImg(img_reg(i).PixelList(j,2)+coordinatesOffsetMatrix(i,1),img_reg(i).PixelList(j,1)+coordinatesOffsetMatrix(i,2),:)= src(img_reg(i).PixelList(j,2),img_reg(i).PixelList(j,1),:);
%         %             end
%     end
% end
% if size(splicingImg,3)>1
%     img_gray=rgb2gray(splicingImg);
% else
%     img_gray=splicingImg;
% end
% reg=regionprops(img_gray>0,img_gray,'BoundingBox');
% rect=reg.BoundingBox;
% 
% splicingImg=imcrop(splicingImg,rect);
% 
% 
% end




% the optimal solution :
% when labled as connected whole img
% move around to
% maximize the Area
% and minimize the FilledArea

function img_splice = generateSplicingImg(src,img_reg,pixelGroups_edge,allocationMatrix,searchRange)
if nargin<4
    searchRange=1;
end
% function coordinatesOffsetMatrix = calcCoordinatesOffsetMatrix(src,img_reg,allocationMatrix,searchRange)

img_splice=zeros(2.*round(sqrt(img_reg(1).Area).*size(img_reg,1)));
img_splice=img_splice(:,:,ones(size(src,3),1));

coordinatesOffsetMatrix=zeros(size(img_reg,1),2);
coordinatesOffsetMatrix(1,1)=round(size(img_splice,1)/2-img_reg(1).Centroid(2));
coordinatesOffsetMatrix(1,2)=round(size(img_splice,1)/2-img_reg(1).Centroid(1));

allocatedMatrix=zeros(size(allocationMatrix));
mid=(size(allocationMatrix,1)-1)/2+1;
allocatedMatrix(mid,mid)=allocationMatrix(mid,mid);
% initiallize the splicing img
i=img_reg(allocatedMatrix(mid,mid)).PixelList(:,2)+coordinatesOffsetMatrix(1,1);
j=img_reg(allocatedMatrix(mid,mid)).PixelList(:,1)+coordinatesOffsetMatrix(1,2);
for k=1:size(i)
    img_splice(i(k),j(k),:)=src(img_reg(allocatedMatrix(mid,mid)).PixelList(k,2),img_reg(allocatedMatrix(mid,mid)).PixelList(k,1),:);
end
% update untill finished
while any(any(allocationMatrix-allocatedMatrix))
    
    edgePixelIndexs = getEdge(allocatedMatrix);
    for i=1:size(edgePixelIndexs,1)
        toAllocateRegion=allocationMatrix(edgePixelIndexs(i,1),edgePixelIndexs(i,2));
        if toAllocateRegion
            nearbyCoordinateOffset=[-1,0;0,1;1,0;0,-1];
            direction=[];
            nballocatedRegion=[];
            for j=1:4
                reg=allocatedMatrix(edgePixelIndexs(i,1)+nearbyCoordinateOffset(j,1),edgePixelIndexs(i,2)+nearbyCoordinateOffset(j,2));
                if reg
                    
                    allocatedMatrix(edgePixelIndexs(i,1),edgePixelIndexs(i,2))=toAllocateRegion;
                    direction=[direction,j];
                    nballocatedRegion=[nballocatedRegion,reg];
                end
            end
            [coordinatesOffsetMatrix,img_splice]=calcCoordinationOffset(coordinatesOffsetMatrix,img_splice,src,img_reg,pixelGroups_edge,toAllocateRegion,nballocatedRegion,direction,searchRange);
  
        end
    end
end

img_splice_gray=mean(img_splice,3);
reg=regionprops(img_splice_gray>0,img_splice_gray,'BoundingBox');
rect=reg.BoundingBox;
img_splice=imcrop(img_splice,rect);

end

function edgePixelIndexs = getEdge(currentAllocateMatrix)

se=[0,1,0;1,1,1;0,1,0];
currentAllocateMatrix=currentAllocateMatrix>0;
edge=imdilate(currentAllocateMatrix,se)-currentAllocateMatrix;
lable=edge>0;
reg=regionprops(lable,edge,'all');
edgePixels=reg.PixelList;
edgePixelIndexs(:,1)=edgePixels(:,2);
edgePixelIndexs(:,2)=edgePixels(:,1);

end

function [coordinatesOffsetMatrix,img_splice] = calcCoordinationOffset(varargin)
[coordinatesOffsetMatrix,img_splice,src,img_reg,pixelGroups_edge,toAllocateRegion,nballocatedRegion,direction,searchRange]=varargin{:};
if nargin<9
    searchRange=1;
else
    searchRange=varargin{9};
end

persistent corners nearbyCoordinateOffset
if isempty(corners)
    corners = findCorner(img_reg);
%     pixelGroups = divisionByCorner(img_reg,corners);
    nearbyCoordinateOffset=[-1,0;0,1;1,0;0,-1];
end

img_splice_gray=mean(img_splice,3); %in case it is two dimension
img_splice_gray=bwperim(img_splice_gray);
reg=regionprops(double(img_splice_gray>0),img_splice_gray,'all');
edgePixels=[reg.PixelList(:,2),reg.PixelList(:,1)];

% the corners return the coordinates not index
di=corners(nballocatedRegion(1),mod(direction(1)-2,4)+1,2)-corners(toAllocateRegion,direction(1),2)+coordinatesOffsetMatrix(nballocatedRegion(1),1);
dj=corners(nballocatedRegion(1),mod(direction(1)-2,4)+1,1)-corners(toAllocateRegion,direction(1),1)+coordinatesOffsetMatrix(nballocatedRegion(1),2);
lastPropertyValue=-inf;
lastdi=di;
lastdj=dj;
for i=di-searchRange:di+searchRange
    for j=dj-searchRange:dj+searchRange
        % calc property value
        
        propertyValue=0;
        isexist=[];
        for k=length(direction)
            isexist=ismember(pixelGroups_edge{toAllocateRegion,direction(k)}(:,2:-1:1)+[i,j]+nearbyCoordinateOffset(direction(k),:),edgePixels(:,:),'rows');
            propertyValue=propertyValue+mean(isexist);
        end
        propertyValue=propertyValue/length(direction);
        if propertyValue>lastPropertyValue
            lastPropertyValue=propertyValue;
            lastdi=i;
            lastdj=j;
        end
    end
end

coordinatesOffsetMatrix(toAllocateRegion,1)=lastdi;
coordinatesOffsetMatrix(toAllocateRegion,2)=lastdj;
for k=1:size(img_reg(toAllocateRegion).PixelList(:,2),1)
    i=img_reg(toAllocateRegion).PixelList(k,2);
    j=img_reg(toAllocateRegion).PixelList(k,1);
    img_splice(i+lastdi,j+lastdj,:)=src(i,j,:);
end

end


