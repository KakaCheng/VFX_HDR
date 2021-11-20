function output = alignment(img1, img2)
img1 = double(img1);
img2 = double(img2);
gray1 = (54*img1(:,:,1) + 183*img1(:,:,2) + 19*img1(:,:,3)) / 256;
gray2 = (54*img2(:,:,1) + 183*img2(:,:,2) + 19*img2(:,:,3)) / 256;

direction = {[-1,-1], [-1,0], [-1,1], [0,-1], [0,0], [0,1], [1,-1], [1,0], [1,1]};
shift = zeros(1,2); 
current = zeros(1,2);
for level = 6:-1:1
    mtb1 = imresize(gray1, 1/2^(level-1));
    mtb2 = imresize(gray2, 1/2^(level-1));
    %thresolds
    th1 = median(mtb1(:));
    th2 = median(mtb2(:));
    [row, col] = size(mtb1);
    tb1 = zeros(row, col);
    tb2 = zeros(row, col);
    eb1 = zeros(row, col);
    eb2 = zeros(row, col);
    %compute threshold bitmap
    for i = 1:row
        for j = 1:col
            if(mtb1(i,j) <= th1)
                tb1(i,j) = 0;
            else
                tb1(i,j) = 1;
            end
            if(mtb2(i,j) <= th2)
                tb2(i,j) = 0;
            else
                tb2(i,j) = 1;
            end
        end
    end
    %compute exclusion bitmap
    for i = 1:row
        for j = 1:col
            if(mtb1(i,j) <= th1+4 && mtb1(i,j) >= th1-4)
                eb1(i,j) = 0;
            else
                eb1(i,j) = 1;
            end
            if(mtb2(i,j) <= th2+4 && mtb2(i,j) >= th2-4)
                eb2(i,j) = 0;
            else
                eb2(i,j) = 1;
            end
        end
    end
    
    min_error = row*col;
    current(1) = shift(1)*2;
    current(2) = shift(2)*2;
    %find shift
    for n = 1:length(direction)
        x = current(1) + direction{n}(1);
        y = current(2) + direction{n}(2);
        tb_shift = imageShift(tb2, x, y);
        eb_shift = imageShift(eb2, x, y);
        diff = xor(tb1, tb_shift);
        diff = diff & eb1 & eb_shift;
%         figure, imshow(uint8(diff), []);
        error = sum(diff(:));
        if(error < min_error)
            shift(1) = x;
            shift(2) = y;
            min_error = error;
        end
    end
end

output(:,:,1) = imageShift(img2(:,:,1), current(1), current(2));
output(:,:,2) = imageShift(img2(:,:,2), current(1), current(2));
output(:,:,3) = imageShift(img2(:,:,3), current(1), current(2));

        