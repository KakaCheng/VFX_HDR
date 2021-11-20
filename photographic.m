function result = photographic(hdr)


H = 0.2126.*hdr(:,:,1)+0.7152.*hdr(:,:,2)+0.0722.*hdr(:,:,3);;

L = H(:,:,1);
[row col] = size(L);
%compute L-bar w
epsi = 0.01;
a = 0.5;
%----------------------
Lw_bar = exp(sum( log(L(:)+epsi) )/(row*col));


Lm = L.*(a./Lw_bar);

%
level = 8;
blur = {};
%-----------------------
for(s = 1:level)
    
    gauFilter = fspecial('gaussian', 20, s-1+epsi);
    blur{s} = imfilter(Lm, gauFilter, 'symmetric');
    
end

%
phi = 2;
V = {};
xlon = 0.001;
smax = zeros(row, col);
%-----------------------
for(cou = 1:row)
    for(cou1 = 1:col)
        for(s = 1:level-1)
            
            v = (blur{s}(cou, cou1) - blur{s+1}(cou, cou1))/...
                (2^phi/(s^2)+blur{s}(cou, cou1));
            
            if(abs(v) < xlon)
                smax(cou, cou1) = s;
                break;
            end
            
            
        end
        
        if(smax(cou, cou1) == 0)
            smax(cou, cou1) = level;
        end
    end
end


%
Ld = zeros(row, col);
%---------------------------


for(cou = 1:row)
    for(cou1 = 1:col)
        
        Ld(cou, cou1) = Lm(cou, cou1)/(1+blur{smax(cou, cou1)}(cou, cou1));
    end
end


H(:,:,1) = Ld;

result = hdr;

result(:,:,1) = result(:,:,1)./L.*Ld;
result(:,:,2) = result(:,:,2)./L.*Ld;
result(:,:,3) = result(:,:,3)./L.*Ld;


end