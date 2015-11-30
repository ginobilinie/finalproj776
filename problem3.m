function problem3()

datapath = './data/castle_dense_images/castle_dense/urd/';
%datapath='../';
im_names = dir(fullfile(datapath, '*.png'));

for i=1:length(im_names)
    filename=[datapath, im_names(i).name];   
    mat=im2double(imread(filename));
    rmat=imresize(mat,0.4);
    segmentation1 = grabcut(rmat);
    imwrite(rmat,'test1.png');
    saveas(gcf,sprintf('%s',im_names(i).name));
end
return