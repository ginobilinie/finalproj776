function [centers, I] = MeanShift(dataSet, h, minStep)
%MYMEANSHIFT Summary of this function goes here
%   Detailed explanation goes here
%h = 3;
%minStep = 0.01;

[m, ~] = size(dataSet);
centers = [];
I = zeros(m, 1, 'int32');

for i = 1:m
    x = meanShift(dataSet, dataSet(i, :), h, minStep);
    n = size(centers, 1);
    if(size(centers, 1) == 0)
        centers(1, :) = x;
        I(i) = 1;
    else
        for j = 1:n
            if sum((x - centers(j, :)).^2) < h^2
                I(i) = j;
            end
        end
        if I(i) == 0
            centers(n+1, :) = x;
            I(i) = n+1;
        end
    end
end
end
%%
function [x] = meanShift(dataSet, x, h, minStep)
    [m, ~] = size(dataSet);
    %plot(x(1), x(2), 'r+');
    lastX = x;
    numerator = 0;
    denominator = 0;
    for i = 1:m
        kernel = sum(((x-dataSet(i,:))/h).^2);
        if(kernel > 1)
            continue;
        else
            g = 1/sqrt(2*pi)*exp(-1/2*kernel);
        end
        numerator = numerator + dataSet(i, :) * g;
        denominator = denominator + g;
    end
    x = numerator / denominator;
    
    while sum((lastX - x).^2) >= minStep
        %plot(x(1), x(2), 'r+');
        lastX = x;
        numerator = 0;
        denominator = 0;
        for i = 1:m
            g = 1/sqrt(2*pi)*exp(-1/2*sum(((x-dataSet(i,:))/h).^2));
            numerator = numerator + dataSet(i, :) * g;
            denominator = denominator + g;
        end
        x = numerator / denominator;
    end
end

