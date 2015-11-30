%This script is written to extract sift features from data in given path
function []=extractSiftDescriptor( scenePathes )
run('./Tools/vlfeat-0.9.19/toolbox/vl_setup');
% extract descriptors
all_sift={};
all_key_points={};
idx=0;
images={};
for i=1:size(scenePathes, 2)
    files=dir(scenePathes{i});
    for j=3:size(files, 1)
        if ~strcmp(files(j).name(end-3:end), '.png')
            continue;
        end
        idx=idx + 1;
        images{idx}.filePath=fullfile(scenePathes{i}, files(j).name);
        img=imread(images{idx}.filePath);
        img_gray=rgb2gray(img);
        
        step=200;radius=100;
        %get mask
        [m, n]=size(img_gray);
        mask_grid=false([m, n]);
        s=floor(step/2);
        mask_grid(s:step:m, s:step:n)=1;
        [cy, cx]=find(mask_grid);
        
        %get sift
        [all_key_points{idx}, all_sift{idx}]=vl_sift(single(img_gray),...
            'frames',[cx'; cy'; radius*ones(1,numel(cx));zeros(1,numel(cx))],...
            'orientations');
        disp(images{idx}.filePath);
    end
end

save('all_sift_descriptors', 'all_key_points', 'all_sift');
%}
% build dictionary and code features
load('all_sift_descriptors.mat');
siftMat=cell2mat(all_sift);
[I, siftDict]=kmeans(single(siftMat'), 300);
save('sift_dict.mat', 'siftDict', 'I');

siftFeature=zeros(idx, 300);
k=0;
for i=1:idx
    for j=1:size(all_sift{i}, 2);
        k=k+1;
        siftFeature(i, I(k))=siftFeature(i, I(k)) + 1;
    end
    sift=siftFeature(i, :);
    save([images{i}.filePath(1:end-4), '_sift'], 'sift');
end
save('sift_feature.mat', 'siftFeature');
return