function [ uvdPCRGB ] = ConvertPCToRGBIm( cameras, xyzPC )
%ConvertPCToRGBIm Take the point cloud and convert the xy to uv in the RGB
%image
%   Undo the z transform, undo the depth camera, apply the image camera
%
% INPUT
%   cameras - depth and image camera parameters from SetCameraParams
%   xyzPC - the point cloud returned from depthImageProc

zInv = 1 / xyzPC(:,3);
u = ( cameras.depthfc(1) .* xyzPC(:,1) + 0 ) .* zInv + cameras.depthcc(1) + 0.5;
v = ( cameras.depthfc(2) .* xyzPC(:,2) + 0 ) .* zInv + cameras.depthcc(2) + 0.5;

uRGB = (u - cameras.imagecc(1)) * 
        *iter_x = (u - center_x) * depth * constant_x;
        *iter_y = (v - center_y) * depth * constant_y;
double inv_Z = 1.0 / xyz_depth.z();
	int u = (depth_fx * xyz_depth.x() + depth_Tx) * inv_Z + depth_cx + 0.5;
	int v = (depth_fy * xyz_depth.y() + depth_Ty) * inv_Z + depth_cy + 0.5;
	double depth_fx = camera_model.fx();
	double depth_fy = camera_model.fy();
	double depth_cx = camera_model.cx(), depth_cy = camera_model.cy();
	double depth_Tx = camera_model.Tx(), depth_Ty = camera_model.Ty();    

  // Use correct principal point from calibration
  float center_x = model_.cx();
  float center_y = model_.cy();

  // Combine unit conversion (if necessary) with scaling by focal length for computing (X,Y)
  double unit_scaling = DepthTraits<T>::toMeters( T(1) );
  float constant_x = unit_scaling / model_.fx();
  float constant_y = unit_scaling / model_.fy();
  float bad_point = std::numeric_limits<float>::quiet_NaN ();
  
  const T* depth_row = reinterpret_cast<const T*>(&depth_msg->data[0]);
  int row_step = depth_msg->step / sizeof(T);
  const uint8_t* rgb = &rgb_msg->data[0];
  int rgb_skip = rgb_msg->step - rgb_msg->width * color_step;

  sensor_msgs::PointCloud2Iterator<float> iter_x(*cloud_msg, "x");
  sensor_msgs::PointCloud2Iterator<float> iter_y(*cloud_msg, "y");
  sensor_msgs::PointCloud2Iterator<float> iter_z(*cloud_msg, "z");
  sensor_msgs::PointCloud2Iterator<uint8_t> iter_r(*cloud_msg, "r");
  sensor_msgs::PointCloud2Iterator<uint8_t> iter_g(*cloud_msg, "g");
  sensor_msgs::PointCloud2Iterator<uint8_t> iter_b(*cloud_msg, "b");
  sensor_msgs::PointCloud2Iterator<uint8_t> iter_a(*cloud_msg, "a");

  for (int v = 0; v < int(cloud_msg->height); ++v, depth_row += row_step, rgb += rgb_skip)
  {
    for (int u = 0; u < int(cloud_msg->width); ++u, rgb += color_step, ++iter_x, ++iter_y, ++iter_z, ++iter_a, ++iter_r, ++iter_g, ++iter_b)
    {
      T depth = depth_row[u];

      // Check for invalid measurements
      if (!DepthTraits<T>::valid(depth))
      {
        *iter_x = *iter_y = *iter_z = bad_point;
      }
      else
      {
        // Fill in XYZ
        *iter_x = (u - center_x) * depth * constant_x;
        *iter_y = (v - center_y) * depth * constant_y;
        *iter_z = DepthTraits<T>::toMeters(depth);
      }

      // Fill in color
      *iter_a = 255;
      *iter_r = rgb[red_offset];
      *iter_g = rgb[green_offset];
      *iter_b = rgb[blue_offset];
    }
  }


end

