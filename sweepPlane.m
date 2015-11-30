%This script is written to implement sweepPlane algorithm
%params
%refCamInd: reference camera index
%neighborCount: means a image refer to the neighbouring images
%myScale: the scale to resize images
%output:
%optimalDepth: the optimal depth
function [ optimalDepth ]=sweepPlane( path, refCamInd , myScale, radius, neighborCount, steps)

%read data
images={};%to load image info
cameras={};%to load info about camera
bounds={};%to load boundbing information
files=dir(fullfile(path, '*.png'));
for i=-neighborCount:neighborCount
    fileIdx=mod(i+refCamInd, size(files, 1));
    imgPath=fullfile(path, [sprintf('%04d', fileIdx),'.png']);
    images{i+neighborCount+1}.img=imread(imgPath);
    images{i+neighborCount+1}.path=imgPath;
    %read camera
    cameraPath=[imgPath, '.camera'];
    cameraFile=fopen(cameraPath);
    %calibration matrix K
    cameras{i+neighborCount+1}.K=zeros(3, 3);
    cameras{i+neighborCount+1}.K(1, :)=fscanf(cameraFile, '%f %f %f', 3);
    cameras{i+neighborCount+1}.K(2, :)=fscanf(cameraFile, '%f %f %f', 3);
    cameras{i+neighborCount+1}.K(3, :)=fscanf(cameraFile, '%f %f %f', 3);
    fscanf(cameraFile, '%f %f %f', 3);% 3 0s, discarded
    %transposed camera rotation matrix
    cameras{i+neighborCount+1}.R=zeros(3, 3);
    cameras{i+neighborCount+1}.R(:, 1)=fscanf(cameraFile, '%f %f %f', 3);
    cameras{i+neighborCount+1}.R(:, 2)=fscanf(cameraFile, '%f %f %f', 3);
    cameras{i+neighborCount+1}.R(:, 3)=fscanf(cameraFile, '%f %f %f', 3);
    %the camera position ~ C
    cameras{i+neighborCount+1}.C=fscanf(cameraFile, '%f %f %f', 3);
    %the image width w and height h.
    cameras{i+neighborCount+1}.ImgSize=flipud(fscanf(cameraFile, '%f %f', 2));
    fclose(cameraFile);
    %read bound
    boundsPath=[imgPath, '.bounding'];
    boundsFile=fopen(boundsPath);
    bounds{i+neighborCount+1}=zeros(2, 3);
    bounds{i+neighborCount+1}(1, :)=fscanf(boundsFile, '%f %f %f', 3);
    bounds{i+neighborCount+1}(2, :)=fscanf(boundsFile, '%f %f %f', 3);
    fclose(boundsFile);
end

%resize
%myScale=1/4;
for i=1:size(images, 2)
    images{i}.img=imresize(images{i}.img, myScale);
    cameras{i}.K=cameras{i}.K * myScale;
    cameras{i}.K(3, 3)=1;
    cameras{i}.ImgSize=size(images{i}.img)';
end

T=zeros(3, size(images, 2));
for i=1:size(images, 2)
    T(:, i)=-cameras{i}.R * cameras{i}.C;
end
for i=1:size(images, 2)
    if i ~= neighborCount+1
        T(:, i)=T(:, neighborCount+1) - cameras{neighborCount+1}.R * cameras{i}.R' * T(:, i);
        cameras{i}.R=cameras{neighborCount+1}.R * cameras{i}.R';
    end
end


%compute depth range
minDepth=realmin;
maxDepth=realmax;
for i=1 : neighborCount*2+1
    if i ~= neighborCount+1%this is the refCamImage
        boundPoints=[];
        boundPoints=[boundPoints, bounds{i}(1, :)'];
        boundPoints=[boundPoints, [bounds{i}(1, 1:2), bounds{i}(2, 3)]'];
        boundPoints=[boundPoints, [bounds{i}(1, 1), bounds{i}(2, 2), bounds{i}(1, 3)]'];
        boundPoints=[boundPoints, [bounds{i}(1, 1), bounds{i}(2, 2:3)]'];
        boundPoints=[boundPoints, [bounds{i}(2, 1), bounds{i}(1, 2:3)]'];
        boundPoints=[boundPoints, [bounds{i}(2, 1), bounds{i}(1, 2), bounds{i}(2, 3)]'];
        boundPoints=[boundPoints, [bounds{i}(2, 1:2), bounds{i}(1, 3)]'];
        boundPoints=[boundPoints, bounds{i}(2, :)'];
        boundPoints=[boundPoints; ones(1, 8)];
        boundPoints=[cameras{neighborCount+1}.R, T(:, neighborCount+1)] * boundPoints;
        minDepth=max(min(boundPoints(3, :)), minDepth);
        maxDepth=min(max(boundPoints(3, :)), maxDepth);
    end
end

%Core parts for sweepPlane Algorithm
%maxDepth=maxDepth - 0.5;%%
step=(maxDepth - minDepth)/steps;
minDiff=repmat(realmax, [cameras{neighborCount+1}.ImgSize(1), cameras{neighborCount+1}.ImgSize(2)]);
optimalDepth=zeros(cameras{neighborCount+1}.ImgSize(1), cameras{neighborCount+1}.ImgSize(2));
for depth=minDepth:step:maxDepth
    for neighborIdx=1 : neighborCount*2+1
        if neighborIdx == neighborCount+1
            continue;
        end
        %using the homography computing equation
        H=cameras{neighborCount+1}.K * (cameras{neighborIdx}.R - T(:, neighborIdx) * [0, 0, -1] / depth) / cameras{neighborIdx}.K;
        %builds a TFORM struct for an N-dimensional projective transformation
        trans=maketform('projective', H');
        %imtransform Apply 2-D spatial transformation to image, so we can
        %get a new image
        newImage=imtransform(images{neighborIdx}.img, trans, 'XData', [1, cameras{neighborCount+1}.ImgSize(2)], 'YData', [1, cameras{neighborCount+1}.ImgSize(1)]);
        %using SSD to compute similarity
        currDiff=sum((single(newImage) - single(images{neighborCount+1}.img)).^2, 3);
        currDiff=imfilter(currDiff, ones(radius));%here imfilter use 'Same' and add 0 pads by default
        %get the minimal index, 
        mask=currDiff <minDiff;
        minDiff(mask)=currDiff(mask);
        %update depth map
        optimalDepth(mask)=depth;
    end
    figure(1);
    subplot(1,2,1);
    imshow(images{neighborCount+1}.img);
        
    subplot(1,2,2);
    imagesc(optimalDepth);axis image;colorbar;drawnow;
end
end

