% pixelGroups = divisionByCorner(img_reg)
% pixelGroups = divisionByCorner(img_reg,corners)
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
% pixelGroups contain pixels of each direction within each region
% and the pixel elements contain the coordinates and the Property Value
% To extract :
% pixelGroups{regionNum,directionNum}(pixelIndex,[x,y,value])
% note :
% the returned Value is coordinates not index! (so as findCorner)
function pixelGroups = divisionByCorner(img_reg,corners)
if nargin<2
    corners=findCorner(img_reg);
end

pixelGroups = cell(size(img_reg,1),4);
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
    pixelGroups(i,:)={topPixels,rightPixels,bottomPixels,leftPixels};
end

end