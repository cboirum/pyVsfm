
if ~exist('fc_left')|~exist('cc_left')|~exist('kc_left')|~exist('alpha_c_left'),
   fprintf(1,'No intrinsic camera parameters available for left camera.\n');
   return;
end;

if ~exist('fc_right')|~exist('cc_right')|~exist('kc_right')|~exist('alpha_c_right'),
   fprintf(1,'No intrinsic camera parameters available for right camera.\n');
   return;
end;

kk = input('Which pair number would you like to examine (A single number only please)? ');

% Left image:

I = load_image(kk,calib_name_left,format_image_left,type_numbering_left,image_numbers_left,N_slots_left, input_dir);

fprintf(1,'Computing the undistorted left image...')

[I2] = rect(I,eye(3),fc_left,cc_left,kc_left,alpha_c_left,KK_left,fisheye);

fprintf(1,'done\n');

left_name = write_image(I2,kk,[calib_name_left '_undistorted'],format_image_left,type_numbering_left,image_numbers_left,N_slots_left, [input_dir 'undistorted/']);

fprintf(1,'\n');

% Right image:

I = load_image(kk,calib_name_right,format_image_right,type_numbering_right,image_numbers_right,N_slots_right, input_dir);

fprintf(1,'Computing the undistorted right image...\n');

[I2] = rect(I,eye(3),fc_right,cc_right,kc_right,alpha_c_right,KK_right,fisheye);

right_name = write_image(I2,kk,[calib_name_right '_undistorted'],format_image_right,type_numbering_right,image_numbers_right,N_slots_right, [input_dir 'undistorted/']);

fprintf(1,'\n');



%% Get the homography matrix
H_from_calibration;

% Left Camera
T0 = [1 0 0 0;
      0 1 0 0;
      0 0 1 0];

K0 = [fc_left(1) alpha_c_left cc_left(1);
      0  fc_left(2)   cc_left(2);
      0  0    1];

P0 = K0*T0;

% Right Camera
T1 = H(1:3,1:4);

K1 = [fc_right(1) alpha_c_right cc_right(1);
      0  fc_right(2)   cc_right(2);
      0  0    1];

P1 = K1*T1;
pmr = P1;


im0 = imread(left_name);
im1 = imread(right_name);

% Compute F from P's
F = vgg_F_from_P(P0, P1);

% Display
vgg_gui_F(im0, im1, F');
 disp('Computed epipolar geometry. Move the mouse to verify')
