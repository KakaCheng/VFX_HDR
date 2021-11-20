clear all;clc;close all;
% get input image sequence
%dirName='Memorial_SourceImages';
dirName='scenery';
files = dir([dirName '\\' '*.jpg']);
fileSize = size(files, 1);
img = {};
% get exposures time
%exposures = 1./[0.5, 0.0625, 0.125, 0.25, 0.03125, ...
%    1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024]; %memorial
%exposures = [4/1235,2/405,1/135,1/90,1/60,1/40,3/80,9/160,27/320]; %ECFA
exposures = [];
for i = 1:fileSize
    img{i} = imread([dirName '\\' files(i).name]);
    info = imfinfo([dirName '\\' files(i).name]);
    exposures = [exposures info.DigitalCamera.ExposureTime];
end
B = log(exposures);

img_shift{1} = img{1};
%aligment
for i=1:fileSize-1
    %img1=imread([dirName '\\' files(i).name]);
    img2=imread([dirName '\\' files(i+1).name]);
    tmp=alignment(img{1},img2);
    img_shift = [img_shift uint8(tmp)];
end

% select sample pixel
Zmax = 256;
Zmin = 0;

[imgRow, imgCol, imgHeight] = size(img{1});
sampleNum = 100;
Z={};
Z{1}=zeros(sampleNum, fileSize);
Z{2}=zeros(sampleNum, fileSize);
Z{3}=zeros(sampleNum, fileSize);
count = 1;
while(count <= sampleNum) % calculate Z
    x = randi([round((imgRow/2)-(imgRow/4)), round((imgRow/2)+(imgRow/4))], 1, 1);
    y = randi([round((imgCol/2)-(imgCol/4)), round((imgCol/2)+(imgCol/4))], 1, 1);
    for count_2 = 1:fileSize
        Z{1}(count, count_2) = img_shift{count_2}(x, y, 1);
        Z{2}(count, count_2) = img_shift{count_2}(x, y, 2);
        Z{3}(count, count_2) = img_shift{count_2}(x, y, 3);
    end
    count = count + 1;
end

w = zeros(Zmin+1, Zmax-1);
for(count = Zmin+1:Zmax-1)
    if(count <= 0.5*(Zmin+Zmax))
        w(count) = count - Zmin;
    else
        w(count) = Zmax - count;
    end
end

% Get Response function
l = 8;
g={};
lE={};
for i=1:3
[g{i},lE{i}]=gsolve(Z{i}, B, l, w);
end
figure,plot([0:255],g{1},'R',[0:255],g{2},'G',[0:255],g{3},'B');

% recover the HDR image
HDRimage = zeros(imgRow, imgCol, imgHeight);
for(cou = 1:3)
    sumW = zeros(imgRow, imgCol);
    sumWGB = zeros(imgRow, imgCol);
    for(pic = 1:fileSize)
        tmp = img_shift{pic}(:, :, cou)+1;
        sumW = sumW + w(tmp);
        tempW_GB = w(tmp).*(g{cou}(tmp) - B(pic));
        sumWGB = sumWGB + tempW_GB;
    end
    HDRimage(:, :, cou) = sumWGB./sumW;
end

HDRimage = exp(HDRimage);

% figure
% imshow(HDRlnE(:, :, 1), []); colormap('jet');
% figure
% imshow(HDRlnE(:, :, 2), []); colormap('jet');
% figure
% imshow(HDRlnE(:, :, 3), []); colormap('jet');
figure, imshow(HDRimage, []);
hdrwrite(HDRimage, [dirName '.hdr']);
%HDRtonemap = tonemapping(HDRimage, 5, 1.6);
%imwrite(HDRtonemap, 'NTUscenery4_bilateral.tiff', 'tiff');
%figure, imshow(HDRtonemap, []);title('bilateral tonemap');
% HDRtonemap = photographic(HDRimage);
% imwrite(HDRtonemap, 'scenery_local.tiff', 'tiff');
% figure, imshow(HDRtonemap, []);title('photographic(local) tonemap');
%HDRtonemap = tonemap(HDRimage, 'AdjustLightness', [0.1 1], 'AdjustSaturation', 2);
%figure, imshow(HDRtonemap, []);