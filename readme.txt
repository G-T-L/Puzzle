How to use
bwperim--->extract edge
regionprops--->img_edge_reg

pixelGroups_edge=divisionByCorner(img_edge_reg);
mappingdata=calcMappingdata(img_edge_reg,img_edge,pixelGroups_edge);
allocationMatrix = calcRegionAllocation(mappingdata);
img_splice = generateSplicingImg(src,img_reg,pixelGroups_edge,allocationMatrix);
figure;imshow(img_splice);
