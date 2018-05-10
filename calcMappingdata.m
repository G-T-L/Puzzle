% mappingdata = calcMappingdata(img_reg)
% mappingdata = calcMappingdata(img_reg,img_property)
% mappingdata = calcMappingdata(img_reg,img_property,calcRelevanceMode)
% mappingdata = calcMappingdata(img_reg,img_property,calcRelevanceMode,searchRange)
%
% from the top and go through clockwise
function mappingdata = calcMappingdata(img_reg,img_property,edgePixelGroups,calcRelevanceMode,searchRange)
if nargin<5
    searchRange=2;
end
if nargin<4
    calcRelevanceMode='balance';
end
if nargin<3
    edgePixelGroups=divisionByCorner(img_reg);
end
if nargin<2
    img_property=[];
end

corners=findCorner(img_reg);
N=size(edgePixelGroups,1);
mappingdata=zeros(N,4,N);

for i=1:N
    for j=1:4
        for m=1:N
            n=mod(j+1,4)+1;
            dx=corners(m,mod(j-2,4)+1,1)-corners(i,j,1);
            dy=corners(m,mod(j-2,4)+1,2)-corners(i,j,2);
            [correspondingPoints,ismatchedMatrix]=findNearbyPixel([edgePixelGroups{i,j}(:,1)+dx,edgePixelGroups{i,j}(:,2)+dy],edgePixelGroups{m,n},searchRange);
            if isempty(img_property)
                mappingdata(i,j,m)=calcRelevance(edgePixelGroups{i,j}(:,3),correspondingPoints(:,3),ismatchedMatrix);
                disp('warning: no property value was specified, automaticlly generated from pixelValue in img_reg');
            else
                propertyValue1=zeros(size(edgePixelGroups{i,j},1),size(img_property,3));
                propertyValue2=zeros(size(edgePixelGroups{i,j},1),size(img_property,3));
                for k=1:size(edgePixelGroups{i,j},1)
                    propertyValue1(k,:)=img_property(edgePixelGroups{i,j}(k,2),edgePixelGroups{i,j}(k,1),:);
                    propertyValue2(k,:)=img_property(correspondingPoints(k,2),correspondingPoints(k,1),:);
                end
                mappingdata(i,j,m)=calcRelevance(propertyValue1,propertyValue2,ismatchedMatrix,calcRelevanceMode);
            end
        end
    end
end
% [mappingMatrix(:,:,2),mappingMatrix(:,:,1)] = max(mappingdata(:,:,:),[],3);
end



% edgePixelGroups = divisionByCorner(img_reg)
% edgePixelGroups = divisionByCorner(img_reg,corners)
%
% the mapping num of the four direction
% from the top and go through clockwise
%
% %%1 %%
% %%%%%
% 4 %%% 2
% %%%%%
% %%3 %%
%
% Description :
% From the img_reg(calcated by fun regionprops)
% we divide each region's pixel into four direction groups by their
% distance to corners
%
% example :
% if this pixel has min sum distance to corner1(top-left) and 2(top-right)
% then it's classified into the top group
%
% Struct :
% edgePixelGroups contain pixels of each direction within each region
% and the pixel elements contain the coordinates and the Property Value
% To extract :
% edgePixelGroups{regionNum,directionNum}(pixelIndex,[x,y,value])
% note :
% the returned Value is coordinates not index! (so as findCorner)
function edgePixelGroups = divisionByCorner(img_reg,corners)
if nargin<2
    corners=findCorner(img_reg);
end

edgePixelGroups = cell(size(img_reg,1),4);
pixelValues = {img_reg.PixelValues};
pixelLists = {img_reg.PixelList};
for i=1:size(img_reg,1)
    distance2=zeros(0);
    distance=(pixelLists{i}(:,1)-corners(i,:,1)).^2+(pixelLists{i}(:,2)-corners(i,:,2)).^2;
    distance2(:,1)=distance(:,1)+distance(:,2);
    distance2(:,2)=distance(:,2)+distance(:,3);
    distance2(:,3)=distance(:,3)+distance(:,4);
    distance2(:,4)=distance(:,4)+distance(:,1);
    
    [~,groupIndex]=min(distance2,[],2);
    topPixels=ones(0);
    rightPixels=ones(0);
    bottomPixels=ones(0);
    leftPixels=ones(0);
    for j=1:size(img_reg(i).PixelList,1)
        switch(groupIndex(j))
            case 1
                topPixels=[topPixels;[pixelLists{i}(j,1),pixelLists{i}(j,2)],pixelValues{i}(j)];
            case 2
                rightPixels=[rightPixels;[pixelLists{i}(j,1),pixelLists{i}(j,2)],pixelValues{i}(j)];
            case 3
                bottomPixels=[bottomPixels;[pixelLists{i}(j,1),pixelLists{i}(j,2)],pixelValues{i}(j)];
            case 4
                leftPixels=[leftPixels;[pixelLists{i}(j,1),pixelLists{i}(j,2)],pixelValues{i}(j)];
        end
    end
    edgePixelGroups(i,:)={topPixels,rightPixels,bottomPixels,leftPixels};
end

end



% soupporte matrix input by recures
function [points,isfinds] = findNearbyPixel(inputPoint,lookupPoints,serachRnge)
nbPoints=zeros(0);%near by points
points=zeros(0);
isfinds=zeros(0);
if size(inputPoint,1) ==1
    for i=-serachRnge:serachRnge
        for j=-serachRnge:serachRnge
            nbPoints=[nbPoints;[inputPoint(1)+i,inputPoint(2)+j]];
        end
    end
    
    [flag,index_ismember]=ismember(nbPoints,lookupPoints(:,1:2),'rows');
    
    if any(flag)
        distance=(nbPoints(:,1)-inputPoint(:,1)).^2+(nbPoints(:,2)-inputPoint(:,2)).^2;
        distance=distance+~flag.*max(distance+1);%if not plus 1,then you cannot tell the center and the corner
        [~,index]=min(distance);
        points=lookupPoints(index_ismember(index),:);
        isfinds=1;
    else
        %         points=inputPoint;
        points=[1,1,0];
        isfinds=0;
    end
    
else
    for i=1:size(inputPoint,1)
        [point,isfind]=findNearbyPixel(inputPoint(i,:,:),lookupPoints,serachRnge);
        points=cat(1,points,point);
        isfinds=cat(1,isfinds,isfind);
    end
end


end