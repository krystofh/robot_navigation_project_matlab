function map = loadMap(src)
    img = imread(src);
    img = rgb2gray(img);
    img = img>127;
    [M, N] = size(img);
    for i = 1:M   % invert 1 and 0 so that 1 = obstacle and 0=free space
        for j = 1:N
            if(img(i,j)==0)
                img(i,j) = 1;
            else
                img(i,j) = 0;
            end
        end
    end
    map = img;
end