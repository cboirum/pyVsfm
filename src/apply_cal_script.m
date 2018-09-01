%should have the name of the files to undistort. One per line. Should not
%have the extension
image_list = '/home/srinivasan/Data/042114_calibration/imagelist.txt';
image_extension = '.jpg';
input_path_prefix = '/home/srinivasan/Data/042114_calibration/';
output_path_prefix = '/home/srinivasan/Data/042114_calibration/output/';
calibration = 'Calib_Results.mat';

load(calibration);
fid = fopen(image_list,'r');
filename = fgetl(fid);

while ischar(filename)
    %% UNDISTORT THE IMAGE:
    
    fprintf(1,['Undistorting image: ',filename,'\n'])
    
    I = im2double(rgb2gray(imread([input_path_prefix,filename,image_extension])));
    rectI = rect(I,eye(3),fc,cc,kc,alpha_c,KK,fisheye);
    
    %% SAVE THE IMAGE IN FILE:
        
    imwrite(rectI,[output_path_prefix,filename,image_extension],'jpg');
    
    filename = fgetl(fid);
end

fclose(fid);