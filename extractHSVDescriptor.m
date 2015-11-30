function [] = extractHSVDescriptor( scenePathes )
idx = 0;
for i = 1:size(scenePathes, 2)
    scenePath = scenePathes{i};
    files = dir(scenePath);
    for j = 3:size(files, 1)
        if ~strcmp(files(j).name(end-3:end), '.png')
            continue;
        end
        filePath = fullfile(scenePath, files(j).name);
        colorPath = fullfile(scenePath, [files(j).name(1:end-4), '_hsv.mat']);
        img = imread(filePath);
        [h,s,v] = rgb2hsv(img);%whose three planes contain the hue, saturation, and value components for the image.
        hist_h = hist(h(:), 10);
        hist_s = hist(s(:), 10);
        hist_v = hist(v(:), 10);
        hsv_color = [hist_h, hist_s, hist_v];
        hsv_color = hsv_color./norm(hsv_color);
        save(colorPath, 'hsv_color');
        disp(colorPath);
        idx = idx + 1;
    end
end
