close all
clc
clear all
%% loading images for each dataset
imageName1 = 'figures/set1/pic1.jpg';
imageName2 = 'figures/set1/pic2.jpg';
img1 = imread(imageName1);
img2 = imread(imageName2);
%% finding corners for each image
sigma = 1.2;
[c1r, c1c] = extract_corners(img1, sigma);
[c2r, c2c] = extract_corners(img2, sigma);

% figure(1), imshow(img1), hold on;
% plot(c1c, c1r, 'y*');
% figure(2), imshow(img2), hold on;
% plot(c2c, c2r, 'y*');
%% matching

%% side by side image
img_big = [img1,img2];
imshow(img_big,[]),hold on;


%% draw all the corners
plot(c1c, c1r, 'y*');
plot(c2c+800, c2r, 'y*');
%% compute feasible corners using SSD
img1 = double(rgb2gray(img1));
img2 = double(rgb2gray(img2));

d1 = size(c1r, 1);
d2 = size(c2r, 1);
bs = 20;
for i = 1 : d1
    top1 = 100000;
    top2 = 100000;
    j_top = 0;
    for j = 1 : d2
        img1block = img1(c1r(i)-bs:c1r(i)+bs, c1c(i)-bs:c1c(i)+bs);
        img2block = img2(c2r(j)-bs:c2r(j)+bs, c2c(j)-bs:c2c(j)+bs);
        e = sum(sum((img1block - img2block).*(img1block - img2block)))/((2*bs+1.0)^2);
        if e < top1
            top2 = top1;
            top1 = e;
            j_top = j;
        elseif e < top2
            top2 = e;
        end

    end
    if top1/top2<0.8 && top1 < 1200
        plot([c1c(i),c2c(j_top)+800],[c1r(i),c2r(j_top)],'b-');
    end
    
end