function problem2()
clear all;
imageInd = 4;
myScale=1/4;
%datapath = './data/castle_entry_dense_images/castle_entry_dense/urd/';
%datapath = './data/castle_dense_images/castle_dense/urd/';
%datapath='./data/fountain_dense_images/fountain_dense/urd/';
datapath='./data\herzjesu_dense_images\herzjesu_dense\urd/';
%radius=[5,10,15,20,25];
radius=[15];
neighborCount=3;
steps=500;
for r=radius
    optimalDepth=sweepPlane(datapath,imageInd,myScale, r, neighborCount ,steps);
    imagesc(optimalDepth);axis image;colorbar;drawnow;
    saveas(gcf,[datapath, sprintf('%04d_depth_%d.png', imageInd,r)]);
end

save([datapath, sprintf('%04d_depth', imageInd)], 'optimalDepth');
return