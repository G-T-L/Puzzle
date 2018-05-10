clear all;close all;
tic
src=im2double(imread('3.jpg'));

img_bw = ~imbinarize(rgb2gray(src), 0.95);
img_bw=imrotate(img_bw,43);
img_reg=regionprops(img_bw>0,img_bw,'all');
for i=1:size(img_reg)
    if img_reg(i).Area<66||img_reg(i).BoundingBox(3)<10||img_reg(i).BoundingBox(4)<10
        for j=1:size(img_reg(i).PixelList,1)
            img_bw(img_reg(i).PixelList(j,2),img_reg(i).PixelList(j,1))=0;
        end
    end
end

% figure;imshow(img_bw);
src=img_bw(:,:,[1,1,1]).*imrotate(src,43);d
img_reg=regionprops(img_bw>0,img_bw,'all');

img_edge_mask=bwperim(img_bw);
img_edge=img_edge_mask(:,:,[1,1,1]).*src;
img_edge_reg = regionprops(img_edge_mask>0,img_edge_mask,'all');

figure;imshow(src);
for i = 1:size(img_reg, 1)
    text(img_reg(i).Centroid(1), img_reg(i).Centroid(2),num2str(i));
end

pixelGroups_edge=divisionByCorner(img_edge_reg);
mappingdata=calcMappingdata(img_edge_reg,img_edge,pixelGroups_edge,'balance',1);
mappingdata=(mappingdata>mean(mappingdata)).*mappingdata;

allocationMatrix = calcRegionAllocation(mappingdata);
img_splice = generateSplicingImg(src,img_reg,pixelGroups_edge,allocationMatrix,0);
figure;imshow(img_splice);
toc




