
if ~exist('fc_left')|~exist('cc_left')|~exist('kc_left')|~exist('alpha_c_left'),
   fprintf(1,'No intrinsic camera parameters available for left camera.\n');
   return;
end;

if ~exist('fc_right')|~exist('cc_right')|~exist('kc_right')|~exist('alpha_c_right'),
   fprintf(1,'No intrinsic camera parameters available for right camera.\n');
   return;
end;

cv_path = [output_dir 'opencv/'];

opencv_intrinsics_from_calibration(0, kc_left, fc_left, cc_left, cv_path);
opencv_intrinsics_from_calibration(1, kc_right, fc_right, cc_right, cv_path);