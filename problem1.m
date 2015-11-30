function problem1()
datapath1='./data/fountain_dense_images/fountain_dense/urd';
datapath2='./data/herzjesu_dense_images/herzjesu_dense/urd';
datapath3= './data/castle_entry_dense_images/castle_entry_dense/urd';
datapath4='./data/castle_dense_images/castle_dense/urd';
dataPathes={datapath1, datapath2,datapath3 ,datapath4 };

% extract sift features, and stor there
extractSiftDescriptor(dataPathes);
% extract hsv color histograms
extractHSVDescriptor(dataPathes);


% meanshift clustering
dataSet=[];
pathSet={};
idx=0;
sceneNum=zeros(size(dataPathes, 2), 1);
for i=1:size(dataPathes, 2)
    scenePath=dataPathes{i};
    files=dir(fullfile(scenePath, '*.png'));
    for j=1:size(files, 1)
        sceneNum(i)=sceneNum(i) + 1;
        filePath=fullfile(scenePath, files(j).name);
        hsvPath=fullfile(scenePath, [files(j).name(1:end-4), '_hsv.mat']);
        load(hsvPath);
        siftPath=fullfile(scenePath, [files(j).name(1:end-4), '_sift.mat']);
        load(siftPath);
        idx=idx + 1;
        dataSet(idx, :)=[hsv_color, sift/norm(sift)];
        pathSet{idx}=filePath;
        clear hsv_color rgb_color gist;
    end
end

[coeff, ~, scores]=princomp(dataSet);

bestH=0;
bestN=0;
maxRate=0;
params=[];
%chooset the optimal parameter combination
for h=0.01:0.01:0.15
    for n=2:10
        newDataSet=dataSet * coeff(:, 1:n);
        newDataSet=newDataSet/norm(newDataSet);
        [centers, I]=MeanShift(newDataSet, h ,0.000001);
        interSum=0;interCount=0;
        intraSum=zeros(size(unique(I), 1), 1);
        intraCount=zeros(size(unique(I), 1), 1);
        for i=1:(size(I, 1)-1)
            for j=(i+1):size(I, 1);
                if(I(i) == I(j))
                    intraSum(I(i), 1)=intraSum(I(i), 1) + sum((newDataSet(i, :)-newDataSet(j, :)).^2);
                    intraCount(I(i), 1)=intraCount(I(i), 1) + 1;
                else
                    interSum=interSum + sum((newDataSet(i, :)-newDataSet(j, :)).^2);
                    interCount=interCount + 1;
                end
            end
        end
        intraSum=sum((intraSum+eps)./intraCount);
        interSum=interSum/(interCount+eps);
        rate=interSum/(intraSum + interSum);
        params=[params; rate, h, n, size(unique(I), 1)];
        if(rate > maxRate && size(unique(I), 1) == 4)
            maxRate=rate;
            bestH=h;
            bestN=n;
        end
        fprintf('%f, %d, %f\n', h, n, rate);
    end
end

dataSet= dataSet * coeff(:, 1:bestN);
dataSet=dataSet/norm(dataSet);
[centers, I]=MeanShift(dataSet, bestH ,0.000001);

% show result
fprintf('%f\n', maxRate);
figure;
subplot(121);
colors='bgrcmyk';
sceneNum=cumsum(sceneNum);

for i=1:size(dataSet, 1)
    for j=1:size(sceneNum, 1)
        if i <= sceneNum(j)
            break;
        end
    end
    if bestN < 3
        plot(dataSet(i, 1), dataSet(i, 2), [colors(mod(j, size(colors, 2))+1), 'o']);hold on;
    else
        plot3(dataSet(i, 1), dataSet(i, 2), dataSet(i, 3),[colors(mod(j, size(colors, 2))+1), 'o']);hold on;
    end
end

subplot(122);
for i=1:size(dataSet, 1)
    if bestN < 3
        plot(dataSet(i, 1), dataSet(i, 2), [colors(mod(I(i), size(colors, 2))+1), 'o']);hold on;
    else
        plot3(dataSet(i, 1), dataSet(i, 2), dataSet(i, 3), [colors(mod(I(i), size(colors, 2))+1), 'o']);hold on;
    end
end
end