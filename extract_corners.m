%% INPUT: sigma represents the scaling factor
%% INPUT: image original image
function [rows, cols]=extract_corners(image, sigma)

% counting time
tic;
% color image to gray value image
img1 = rgb2gray(image);
%% construct Haar filter (n by n matrix)
n = round(round(4*sigma)/2)*2;
haar_x = [ones(n,n/2), -ones(n,n/2)];
haar_y = [ones(n/2,n); -ones(n/2,n)];
%% Haar filtering 
img1_x = imfilter(img1, haar_x/n);
img1_y = imfilter(img1, haar_y/n);
% imshow(img1_x)
%% prepare covariance matrix
img1_xx = img1_x.*img1_x;
img1_xy = img1_x.*img1_y;
img1_yy = img1_y.*img1_y;

m = round(round(5*sigma)/2);

threshold = 0.04;
%% build corner score matrix R
[h,w] = size(img1);
mask = zeros(h,w);
R = zeros(h,w);
for i = 1+m : h-m
    for j = 1+m : w-m
        C = [sum(sum(img1_xx(i-m:i+m,j-m:j+m))), ...
            sum(sum(img1_xy(i-m:i+m,j-m:j+m))); ...
            sum(sum(img1_xy(i-m:i+m,j-m:j+m))), ...
            sum(sum(img1_yy(i-m:i+m,j-m:j+m)))];
        det = C(1,1)*C(2,2)-C(1,2)*C(1,2);
        trace = C(1,1) + C(2,2);
        R(i,j) = det - threshold*(trace*trace);
    end
end
%% non maximum suppression
m = 20;
R = R./(max(R(:)));
for i = 1+m : h-m
    for j = 1+m : w-m
        temp = R(i-m:i+m,j-m:j+m);
        % set a threshold for the score matrix, 0.55
        if R(i,j) == max(temp(:)) && R(i,j) > 0.55 
            mask(i,j) = 1;
        end
    end
end

[rows, cols] = find(mask);
toc;
% imshow(img1), hold on;
% plot(cols, rows, 'y*');