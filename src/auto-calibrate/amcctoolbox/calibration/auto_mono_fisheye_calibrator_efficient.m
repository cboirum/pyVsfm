% AUTO_MONO_FISHEYE_CALIBRATOR_EFFICIENT: Using the efficient methods that use only
% one image at a time, calibrate the monocular camera

% Set the variable if it doesn't exist
if ~exist('fisheye','var')
    fisheye = false;
end

% Set the save name if it doesn't exist
if ~exist('save_name','var')
    save_name = 'Calib_Results_0';
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
        fprintf('Largest error (%f pixels) occurs in image %d. Removing image from active list.\n', max_err, max_err_img);
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