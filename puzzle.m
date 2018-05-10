clear;close all;
tic
src = im2double(imread('mona_puzzle.jpg'));

figure;imshow(src);
img_bw = ~imbinarize(rgb2gray(src), 0.99);

img_reg=regionprops(img_bw>0,img_bw,'all');
for i=1:size(img_reg)
    if img_reg(i).BoundingBox(3)<10||img_reg(i).BoundingBox(4)<10
        for j=1:size(img_reg(i).PixelList,1)
            img_bw(img_reg(i).PixelList(j,2),img_reg(i).PixelList(j,1))=0;
        end
    end
end

%remove edge by 1 pixel because of the bad value contained
img_bw=img_bw-bwperim(img_bw);
img_gray=img_bw.*rgb2gray(src);
lable=bwlabeln(img_bw);
img_reg = regionprops(lable,img_gray,'all');

%calc edge
img_edge_mask=bwperim(img_bw);
img_edge_rgb=img_edge_mask(:,:,[1,1,1]).*src;
img_edge_gray=rgb2gray(img_edge_rgb);
img_edge_lable=lable.*img_edge_mask;
img_edge_reg = regionprops(img_edge_lable,img_edge_gray,'all');

% plot
rects = cat(1, img_reg.BoundingBox);
centroids=cat(1,img_reg.Centroid);
corners=findCorner(img_reg);
figure();imshow(img_bw);
hold on;
% plot(centroids(:,1), centroids(:,2), 'r*'),
plot(corners(:,:,1), corners(:,:,2), 'r*'),
for i = 1:size(rects, 1)
    rectangle('position', rects(i, :), 'EdgeColor', 'r');
    text(centroids(i,1)-5, centroids(i,2),num2str(i));
end

pixelGroups_edge=divisionByCorner(img_edge_reg);
mappingdata=calcMappingdata(img_edge_reg,img_edge_rgb,pixelGroups_edge,'balance',1);
mappingdata=(mappingdata>mean(mappingdata)).*mappingdata;

allocationMatrix = calcRegionAllocation(mappingdata);
img_splice = generateSplicingImg(src,img_reg,pixelGroups_edge,allocationMatrix,0);
figure;imshow(img_splice);
toc
















