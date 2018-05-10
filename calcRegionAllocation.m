% calc the region allocation matrix
% allocateMatrix = calcRegionAllocation(mappingdata)
% allocateMatrix = calcRegionAllocation(mappingdata,allocationSize)
function allocateMatrix = calcRegionAllocation(mappingdata,allocationSize)
if nargin<2
    allocationSize=[];
end

global searchMartrix searchedMartrix
searchMartrix={};
searchedMartrix={};
initialAllocateMatrix=zeros(1+2*size(mappingdata,1));
initialAllocateMatrix(size(mappingdata,1)+1,size(mappingdata,1)+1)=1;
averageRelevance=0;
priority=1;
searchMartrix(1,:)={initialAllocateMatrix,averageRelevance,priority};

% resultMatrix={};
while true
    %     [searchMartrix,searchedMartrix,iscomplete] = updateSearchMartrix(searchMartrix,searchedMartrix,mappingdata);
    iscomplete = updateSearchMartrix(mappingdata,allocationSize);
    if iscomplete.value
        allocateMatrix=iscomplete.matrix;
        
        %         averageRelevance=calcAverageRelevance(iscomplete.matrix,mappingdata);
        %         priority=calcPriority(iscomplete.matrix,averageRelevance);
        %         resultMatrix(end+1,:)={iscomplete.matrix,averageRelevance,priority};
        %         if size(resultMatrix,1)>100
        %
        %         averageRelevanceMatrix=cat(1,resultMatrix{:,2});
        %         [~,index]=max(averageRelevanceMatrix);
        %         allocateMatrix=resultMatrix{index,1};
        break;
        %         end
    end
end



end

function iscomplete = updateSearchMartrix(mappingdata,allocationSize)
%find the maximum priority one and extract to generate sequence
% could use optimized binary tree(Huffman Tree) to accelerate
global searchMartrix searchedMartrix

iscomplete.value=false;

priority=cat(1,searchMartrix{:,3});
[~,index]=max(priority);
currentAllocateMatrix=searchMartrix{index,1};
edgePixels = getEdge(currentAllocateMatrix);
searchedMartrix(end+1,:)=searchMartrix(index,:);
searchMartrix{index,3}=0;

regions=1:size(mappingdata,1);
regionLeftIndex=~ismember(regions,currentAllocateMatrix(:));
regionLeft=regions(regionLeftIndex);
if ~any(regionLeftIndex)
    % search complete
    iscomplete.value=true;
    iscomplete.matrix=currentAllocateMatrix;
    return
end

for i=1:size(edgePixels,1)
    for j=1:size(regionLeft,2)
        newAllocateMatrix=currentAllocateMatrix;
        newAllocateMatrix(edgePixels(i,1),edgePixels(i,2))=regionLeft(j);
        %preexamine
        coordinateOffset=[-1,0;0,1;1,0;0,-1];
        for k=1:4
            nearbyRegion=newAllocateMatrix(edgePixels(i,1)+coordinateOffset(k,1),edgePixels(i,2)+coordinateOffset(k,2));
            if nearbyRegion
                if mappingdata(newAllocateMatrix(edgePixels(i,1),edgePixels(i,2)),k,nearbyRegion)>0
                    % examine validity(isexist already)
                    % and append to the searchMartrix
                    averageRelevance=calcAverageRelevance(newAllocateMatrix,mappingdata);
                    priority=calcPriority(newAllocateMatrix,averageRelevance,allocationSize);
                    if ~isexist(newAllocateMatrix,averageRelevance,searchMartrix)
                        
                        searchMartrix(end+1,:)={newAllocateMatrix,averageRelevance,priority};
                    end
                end
            end
        end
        
    end
end
end

function isexist = isexist(newAllocateMatrix,averageRelevance,searchMartrix)

isexist=false;
% use relevance as the hashing table value
relevanceMatrix=cat(1,searchMartrix{:,2});
[flag,index]=ismember(averageRelevance,relevanceMatrix);
if flag
    isexist=true;
    if searchMartrix{index,1}~=newAllocateMatrix
        disp('two different Matrix share the same hashing value');
        disp('error may occor at calcRegionAllocation-isexist');
    end
end
% for i=1:size(searchMartrix,1)
%         if newAllocateMatrix==searchMartrix{i,1}% could use hashing table to accelerate
%             isexist = true;
%             break;
%         end
% end
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

function averageRelevance = calcAverageRelevance(allocateMatrix,mappingdata)
% get pixel coordinates
lable=allocateMatrix>0;
reg=regionprops(lable,allocateMatrix,'PixelList');
pixelCoordinates=reg.PixelList;
pixelIndex(:,1)=pixelCoordinates(:,2);
pixelIndex(:,2)=pixelCoordinates(:,1);
% calc
sum=0;
count=0;
coordinateOffset=[-1,0;0,1;1,0;0,-1];
for i=1:size(pixelIndex,1)
    for j=1:4
        nearbyRegion=allocateMatrix(pixelIndex(i,1)+coordinateOffset(j,1),pixelIndex(i,2)+coordinateOffset(j,2));
        if nearbyRegion
            count=count+1;
            sum=sum+mappingdata(allocateMatrix(pixelIndex(i,1),pixelIndex(i,2)),j,nearbyRegion);
        end
    end
end
averageRelevance=roundn(sum/count,-10);

end


% this value guide the peogram behavior
% adjust to achieve better performance
function priority = calcPriority(allocateMatrix,averageRelevance,allocationSize)

% regionCounts=size(allocateMatrix(allocateMatrix>0),1);

lable=double(allocateMatrix>0);
reg=regionprops(lable,allocateMatrix,'all');
rect=reg.BoundingBox;
regionCounts=reg.Area;
width=rect(1,3);
hight=rect(1,4);
if ~isempty(allocationSize)
    if width<=allocationSize(1)&&hight<=allocationSize(2)
        
        % priority=666*averageRelevance-regionCounts.^3-6.*(width+hight);%magic weight num here
        % priority=666*averageRelevance-regionCounts-(width+hight);
        priority=averageRelevance;
    else
        priority=0;
    end
else
    priority=66*averageRelevance-100*regionCounts-(width+hight).^2;
end
end




