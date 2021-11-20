function output = tonemapping(HDRimage, targetContrast, absolute_scale)

[imgRow, imgCol, imgHeight] = size(HDRimage);
Y = 0.2126.*HDRimage(:,:,1)+0.7152.*HDRimage(:,:,2)+0.0722.*HDRimage(:,:,3);
log_Y = log(Y);
R = HDRimage(:,:,1)./Y;
G = HDRimage(:,:,2)./Y;
B = HDRimage(:,:,3)./Y;
sigma_s = 0.02 * min(imgRow, imgCol);
base = bilateralFilter(log_Y, 0, sigma_s, 1);
detail = log_Y - base;

maxbase = max(base(:));
minbase = min(base(:));
%targetContrast = 5;
compressionfactor = log(targetContrast)/(maxbase - minbase);
absolute_scale = maxbase*compressionfactor
%save absolute_scale;
outputY = base.*compressionfactor + detail - absolute_scale;
outputR = (R.*(10.^outputY)).^(1.0/1.6);
outputG = (G.*(10.^outputY)).^(1.0/1.6);
outputB = (B.*(10.^outputY)).^(1.0/1.6);
output(:,:,1) = outputR;
output(:,:,2) = outputG;
output(:,:,3) = outputB;