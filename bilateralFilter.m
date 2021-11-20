function imageFiltered = bilateralFilter(image, N, sigma_s, sigma_r)
% bilateralFilter: bilateral filtering of images.
%   imageFiltered = bilateralFilter(image, N, sigma_s, sigma_r):
%   performs the bilateral filter algorithm based on the
%   technique described in: 
%       C. Tomasi and R. Manduchi. "Bilateral Filtering for 
%       Gray and Color Images", Proceedings of the IEEE 
%       International Conference on Computer Vision, 1998.          
%
% @Parameters@
%   image = input array with double, the image to be filtered.
%   N = integer representing the kernel size with (2N+1) by (2N+1).
%   sigma_s = standard deviation of Gaussian function for spatial component.
%   sigma_r = standard deviation of Gaussian filter for radiometric component.
%
% @Returns@
%   imageFiltered = filtered image array with double.
%
% Copyright (c) 2012 Herbert H. Chang, Ph.D.
% Computational Biomedical Engineering Laboratory (CBEL)
% Department of Engineering Science and Ocean Engineering
% National Taiwan University, Taipei, Taiwan
% ------------------------------------------
% @version Aug 6 2012


% Obtain the size of the input image.
[height, width] = size(image);

% Augment the array by N in each component using symmetric boundary conditions.
imageSym = padarray(image, [N N], 'symmetric');

% Span of the filter.
span = 2 * N;
% Coordinates of the pixel under consideration.
cxy = N + 1;

% Pre-compute Gaussian distance array.
[X2, Y2] = meshgrid(-N:N);
dist2 = X2.^2 + Y2.^2;

% Pre-compute the square of the standard deviations and multiply them by 2.
sigmaS2 = 2.0 * sigma_s * sigma_s;
sigmaR2 = 2.0 * sigma_r * sigma_r;
% Compute the spatial component weight.
ws = exp(-dist2 ./ sigmaS2);

% Preallocation of memory for the filtered image array.
imageFiltered = zeros(height, width);
% Filter the image using the bilateral filtering pixel by pixel.
for x = 1:height
    for y = 1:width
        % Extract pixel with its neighbors for computation.
        kernel = imageSym(x:x+span, y:y+span);
        % Intensity of the pixel under consideration.
        uc = kernel(cxy, cxy);
        
        % Compute the square of the intensity difference.
        magDiff2 = (kernel - uc) .^ 2;
        % Compute the radiometric component.
        wr = exp(-magDiff2 ./ sigmaR2);
        
        % Compute the overall weight.
        wb = ws .* wr;
        % Compute the weighted intensity array.
        wk = wb .* kernel;
        
        % Compute the filtered intensity value.
        imageFiltered(x, y) = sum(wk(:)) / sum(wb(:));
    end
end