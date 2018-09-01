% AUTO_STEREO_CALIBRATOR_EFFICIENT(camera_vec, input_dir,output_dir,format_image,dX,dY,proj_tol)
% camera_vec -> Vector. The numerical index of the cameras. For stereo, usually [0 1]
% input-dir -> String. The directory where the images are stored
% output-dir -> String. The directory where the matlab output will be saved
% format_image -> String. The format of the images: 'bmp', 'jpg' etc.
% dX -> int. The length of each checkerboard square in mm in the X direction
% dY -> int. The length of each checkerboard square in mm in the Y direction
% nx_crnrs -> int. Number of expected corners in the X direction
% ny_crnrs -> int. Number of expected corners in the Y direction
% proj_tol -> float. The tolerance for reprojection of corners
% rotcam -> logical (1 or 0). Forces image to be rotated by 180 degrees. Useful for UAV cameras.
% Takes a set of images from a camera pair in the
% standard multicamera format, detects checkerboards, calibrates
% individually, then calibrates in stereo to produce a final output
% Dependant on the RADOCCToolbox

function auto_stereo_calibrator_efficient_acfr(camera_vec, input_dir, output_dir, format_image, dX, dY, nx_crnrs, ny_crnrs, proj_tol, rotcam, cam0_names, cam1_names, force_load)

% Make sure the vector is only 
cam_vec_sz = size(camera_vec);
rotcam_sz = size(rotcam);


% Argument sanity checking
if (cam_vec_sz(2) ~= rotcam_sz(2))
    display('Error: Your camera vector and rotation vector are of different sizes. Cannot continue.');
    return;
end
if (cam_vec_sz(2) > 2 || rotcam_sz(2) > 2)
    display('Error: You have specified more than 2 cameras to be stereo calibrated. Did you want to use auto_multi_calibrator_efficient?');
    return;
elseif (cam_vec_sz(2) < 2 || rotcam_sz(2) < 2)
    display('Error: You have specified less than 2 cameras to be stereo calibrated. Did you want to use auto_mono_calibrator_efficient?');
    return;
end

% Default image names
if (~exist('cam0_names','var'))
    cam0_names = ['cam' num2str(camera_vec(1)) '_image'];
end
if (~exist('cam1_names','var'))
    cam1_names = ['cam' num2str(camera_vec(2)) '_image'];
end

% For some of the export tasks, we need the input data directory without a
% trailing slash so that we can append the directory name
%output_dir_sz = size(output_dir);
%output_dir_woslash = output_dir(1:output_dir_sz(2)-1);
% Make sure the output directory exists
if (~exist(output_dir,'dir'))
    display(['Making a calibration directory at ''' output_dir '...']);
    mkdir(output_dir) % Make the directory if it doesn't already exist
end

% Change to the default output directory
cd(output_dir);

checkerboard_set = 0;

%%%%%%%%%%%%%%%%%% Monocular Calibrations %%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%% Calibrate Camera 0 %%%%%%%%%%%%%%%%%%%%%%%%
display('********** Performing monocular calibration on camera 0****************');
% Check if there is a matlab file with the checkerboards already in it so
% we don't have to calibrate again

% Camera 0 specific parameters
calib_name = cam0_names;
data_name = ['Calib_Data_' num2str(camera_vec(1))];
save_name = ['Calib_Results_' num2str(camera_vec(1))];

% Calibrate the monocular camera automatically
% and reject those images with error greater than proj_tol
flag = rotcam(1);
auto_mono_calibrator_efficient_acfr;

%analyse_error;
eval(['cam' num2str(camera_vec(1)) '_suppress_list = active_images;']);
save(['cam' num2str(camera_vec(1)) '_suppress_list'], ['cam' num2str(camera_vec(1)) '_suppress_list']);

display('********** Finished monocular calibration on camera 0****************');
%%%%%%%%%%%%% Reset some variables %%%%%%%%%%%
clear kk_save k_save kk ima_proc kk_first;

%%%%%%%%%%%%%%%%%%%% Calibrate Camera 1 %%%%%%%%%%%%%%%%%%%%%%%%
display('********** Performing monocular calibration on camera 1****************');
% Camera 1 specific parameters
calib_name = cam1_names;
data_name = ['Calib_Data_' num2str(camera_vec(2))];
save_name = ['Calib_Results_' num2str(camera_vec(2))];

% Calibrate the monocular camera automatically
% and reject those images with error greater than proj_tol
flag = rotcam(2);
auto_mono_calibrator_efficient_acfr;

eval(['cam' num2str(camera_vec(2)) '_suppress_list = active_images;']);
save(['cam' num2str(camera_vec(2)) '_suppress_list'], ['cam' num2str(camera_vec(2)) '_suppress_list']);

display('********** Finished monocular calibration on camera 1****************');

%%%%%%%% Normalise the variable naming for the next section %%%%%%%%%
eval(['suppress_list0 = cam' num2str(camera_vec(1)) '_suppress_list;']);
eval(['suppress_list1 = cam' num2str(camera_vec(2)) '_suppress_list;']);

%%%%%%%% Make sure that matching images are suppressed %%%%%%%%%
fprintf('\n********************** Generating matching suppression lists ********************\n');
len_list0 = size(suppress_list0);
len_list1 = size(suppress_list1);

if (len_list0(2) ~= len_list1(2))
    display('Error: The two images lists are not equal. Check to make sure all images have been found.');
    return;
end

for ii=1:1:len_list0(2)
    if (suppress_list0(ii) ~= suppress_list1(ii))
        suppress_list0(ii) = 0;
        suppress_list1(ii) = 0;
    end
end

% % % % Save the changes
% % % % save(['cam' num2str(camera_vec(1)) '_suppress_list'], ['suppress_list0']);
% % % % save(['cam' num2str(camera_vec(2)) '_suppress_list'], ['suppress_list1']);


%%%%%%%%%%%%%%%%%%%%% Stereo Calibration %%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%% Reload and recalibrate each camera based on the suppression list %%%%
fprintf('\n********************** Recalibration based on suppression list; preparing for stereo calibration... ********************\n');
% Left camera
load(['Calib_Results_' num2str(camera_vec(1)) '.mat']);
eval(['active_images = suppress_list0;']);
% Perform the optimisation
go_calib_optim;
% Save the output
save_name = ['Calib_Results_left'];
saving_calib_auto;

% Right camera
load(['Calib_Results_' num2str(camera_vec(2)) '.mat']);
eval(['active_images = suppress_list1 ;']);
% Perform the optimisation
go_calib_optim;
% Save the output
save_name = ['Calib_Results_right'];
saving_calib_auto;

%%%% Do the stereo calibration %%%%
fprintf('\n********************** Performing Stereo Calibration ********************\n');
calib_file_name_left = 'Calib_Results_left.mat';
calib_file_name_right = 'Calib_Results_right.mat';

fprintf('Loading the monocular results files');
%load_stereo_calib_files2_auto; % Load the monocular files
load_stereo_calib_files_auto; % Load the monocular files


% Don't recompute the intrinsics. This is necessary for future stereo
% calibrations in multicamera setups. May have to change.
recompute_intrinsic_left = 0;
recompute_intrinsic_right = 0;

%calib_stereo_auto2; % Perform stereo calibration
fprintf('Showing the stereo calibration before optimisation...');
show_stereo_calib_results; % Show the values before calibration

go_calib_stereo; % Perform stereo calibration
%calib_stereo_auto2; 

% Manually change back the rotation if we rotated one camera
if ((rotcam(1) == 1 && rotcam(2) == 0) || (rotcam(2) == 1 && rotcam(1) == 0))
    om(3) = om(3) + pi;
end

fprintf('Showing the stereo calibration after optimisation...');
show_stereo_calib_results; % Show the values after calibration

fprintf('Saving the stereo calibration results...');
saving_stereo_calib; % Save the stereo calibration

