% AUTO_MONO_CALIBRATOR_EFFICIENT: Using the efficient methods that use only
% one image at a time, calibrate the monocular camera

% Set the save name if it doesn't exist
if ~exist('save_name','var')
    save_name = 'Calib_Results_0';
end

% Force the fisheye variable to false if it doesn't exist
if (~exist('fisheye','var'))
    fisheye = false;
end

% Force the k3_enable variable to false if it doesn't exist
if (~exist('k3_enable','var'))
    k3_enable = false;
end

% Force the input_dir to the current directory
if (~exist('input_dir','var'))
    input_dir = './';
end

% Force the output_dir to the current directory
if (~exist('output_dir','var'))
    output_dir = './';
end


%load the images
data_calib_no_read_auto;

% Automatically detect corners
click_calib_no_read_auto;

% Perform the optimisation
if fisheye
    fprintf('\n\n ***** Runing Calibration for fisheye lens *****\n\n')
    go_calib_optim_fisheye_no_read;
else
    fprintf('\n\n ***** Runing Calibration for normal lens *****\n\n')
    go_calib_optim;
end

% Recursively remove cameras with pixel values outside the required range
valid = false;
max_err = 0.0;
max_err_img = -1;

while (valid == false)
    fprintf('\n*** Determining image with largest error... ***\n\n');
    extract_error
    
    if (max_err_img == -1)
        valid = true;
    else
        display(['Largest error (' num2str(max_err) ' pixels) occurs in image ' num2str(max_err_img) '. Removing image from active list.']);
        % Suppress the image with the biggest error
        ima_numbers = max_err_img;
        suppress_auto;
        % If the error is extremely large, don't bother recalibrating, just
        % reject that image
        if (max_err < 2*proj_tol)
            % Recalibrate
            fprintf('\n*** Recalibrating... ***\n');
            if fisheye
                fprintf('\n\n ***** Reruning Calibration for fisheye lens *****\n\n')
                go_calib_optim_fisheye_no_read;
            else
                fprintf('\n\n ***** Reruning Calibration for normal lens *****\n\n')
                go_calib_optim;
            end     
        end
    end
end

% Save the output
saving_calib_auto;