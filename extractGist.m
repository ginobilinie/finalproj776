%to extract gist descritor
clear all;
folderPath='./data';
scenes={'fountain_dense', 'herzjesu_dense', 'castle_entry_dense', 'castle_dense'};

% GIST Parameters:
%param.imageSize=[256 384]; % it works also with non-square images (use the most common aspect ratio in your set)
param.orientationsPerScale=[8 8 8 8]; % number of orientations per scale
param.numberBlocks=4;
param.fc_prefilt=4;

for i=1:size(scenes, 2)
    scenePath=[folderPath, scenes{i}, '/urd'];
    files=dir(scenePath);
    for j=3:size(files, 1)
        if ~strcmp(files(j).name(end-3:end), '.png')
            continue;
        end
        filePath=[scenePath, files(j).name];
        gistPath=[scenePath, [files(j).name(1:end-4), '.mat']];
        % Computing gist:
        img=imread(filePath);
        [gist, param]=LMgist(img, '', param);
        save(gistPath, 'gist');
        % Visualization
        subplot(121)
        imshow(img)
        title(filePath)
        subplot(122)
        showGist(gist, param)
        title(gistPath)
    end
end