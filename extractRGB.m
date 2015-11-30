clear all;
folderPath='./data';
scenes={'fountain_dense', 'herzjesu_dense', 'castle_entry_dense', 'castle_dense'};
idx=0;
for i=1:size(scenes, 2)
    scenePath=fullfile(folderPath, scenes{i}, '/urd');
    files=dir(scenePath);
    for j=3:size(files, 1)
        if ~strcmp(files(j).name(end-3:end), '.png')
            continue;
        end
        filePath=[scenePath, files(j).name];
        colorPath=[scenePath, [files(j).name(1:end-4), '_rgb.mat'];
        img=imread(filePath);
        r=single(img(:, :, 1));
        g=single(img(:, :, 2));
        b=single(img(:, :, 3));
        histR=hist(r(:), 10);
        histG=hist(g(:), 10);
        histB=hist(b(:), 10);
        rgbColor=[histR, histG, histB];
        rgbColor=rgbColor./norm(rgbColor);
        save(colorPath, 'rgbColor');
        disp(idx);
        idx=idx + 1;
    end
end
