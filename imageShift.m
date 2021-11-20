function output = imageShift(tb, x, y)

[row, col] = size(tb);
tmp = zeros(row, col);
output = zeros(row, col);

% for i = 1:row
%     for j =1:col
%         if(i+y>=1 && i+y<=row && j+x>=1 && j+x<=col)
%             output(i+y,j+x) = tb(i,j);
%         end
%     end
% end

if(x < 0)
    tmp(:,1:col+x) = tb(:,1-x:col);
else
    tmp(:,1+x:col) = tb(:,1:col-x);
end
if(y < 0)
    output(1:row+y,:) = tmp(1-y:row,:);
else
    output(1+y:row,:) = tmp(1:row-y,:);
end

