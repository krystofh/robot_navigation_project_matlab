function saveResizedImage(img_src,output_name, scale)
    % saves resized image
    img = imread(img_src);
    img_resized = imresize(img, scale);
    imwrite(img_resized, output_name);
end

