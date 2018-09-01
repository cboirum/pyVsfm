%image_list = '/home/srinivasan/Data/042114_calibration/imagelist.txt';
image_extension = 'jpg';
input_path_prefix = 'C:\Users\BOIRUM\Desktop\Distorted\'%/home/srinivasan/Data/GLXP/original-subset/';
output_path_prefix = 'C:\Users\BOIRUM\Desktop\VsfmInput\'%'/home/srinivasan/Data/GLXP/rectified-subset/';
calibration = 'Calib_Results.mat';

load(calibration);

index = 1;

while 1
    
    imgs = dir([input_path_prefix '*' image_extension]);
    numImgs = size(imgs,1);
    
    if numImgs >= index
        
        %% UNDISTORT THE IMAGE:
    
        fprintf(1,['Undistorting image: ', imgs(index).name,'\n'])
        I = im2double(rgb2gray(imread([input_path_prefix imgs(index).name])));
        rectI = rect(I,eye(3),fc,cc,kc,alpha_c,KK,fisheye);
    
        %% SAVE THE IMAGE IN FILE:
        
        imwrite(rectI,[output_path_prefix,imgs(index).name], image_extension);
    
        index = index + 1;
    end

    %sleep for a few milliseconds
    pause(0.1);
end
