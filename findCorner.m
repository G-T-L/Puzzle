% corners = findCorner(img_reg)
% from the top-left and go through clockwise
% 1%%%%2
% %%%%%
% %%%%%
% %%%%%
% 4%%%%3
% note :
% the return Value is coordinates not index! (so as divisionByCorner)
%
function corners = findCorner(img_reg)

corners=zeros(size(img_reg,1),4,2);

for i=1:size(img_reg,1)
    % left-top
    [~,index]=max(-img_reg(i).PixelList(:,1)-img_reg(i).PixelList(:,2));
    corners(i,1,1)=img_reg(i).PixelList(index,1);
    corners(i,1,2)=img_reg(i).PixelList(index,2);
    % top-right
    [~,index]=max(img_reg(i).PixelList(:,1)-img_reg(i).PixelList(:,2));
    corners(i,2,1)=img_reg(i).PixelList(index,1);
    corners(i,2,2)=img_reg(i).PixelList(index,2);
    % right-buttom
    [~,index]=max(img_reg(i).PixelList(:,1)+img_reg(i).PixelList(:,2));
    corners(i,3,1)=img_reg(i).PixelList(index,1);
    corners(i,3,2)=img_reg(i).PixelList(index,2);
    % buttom-left
    [~,index]=max(-img_reg(i).PixelList(:,1)+img_reg(i).PixelList(:,2));
    corners(i,4,1)=img_reg(i).PixelList(index,1);
    corners(i,4,2)=img_reg(i).PixelList(index,2);
end

end



