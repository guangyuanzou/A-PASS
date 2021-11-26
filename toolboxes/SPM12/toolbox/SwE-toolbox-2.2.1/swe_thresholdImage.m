function swe_thresholdImage(threshold, minimumClusterSize)
% Threshold an image, specified by selection window.
% =========================================================================
% FORMAT: swe_thresholdImage(threshold, minimumClusterSize)
% -------------------------------------------------------------------------
% Inputs:
%
%  - threshold - minimum value (inclusive) of the surviving voxels
%  - minimumClusterSize - the minimum size ofthe surviving clusters
% =========================================================================
% Version Info:  2020-06-18 15:16:32 +0200 0153229

  inputImageName = spm_select(1, 'image');
  [pth, bnm, ext] = spm_fileparts(inputImageName);
  VI = swe_data_hdr_read(inputImageName);
  [Z, XYZ] = swe_data_read(VI);
  XYZ = inv(VI.mat) * [XYZ; ones(1,VI.dim(1)*VI.dim(2)*VI.dim(3))];
  XYZ = round(XYZ(1:3,:));

  Z = swe_data_read(inputImageName, 'xyz', XYZ);
  VI.fname = fullfile(pth, [bnm '_thresholded' ext]);
  VI.descrip = [VI.descrip sprintf(' thresholdValue: %fminimumClusterSize: %i', threshold, minimumClusterSize)];
  VI = swe_data_hdr_write(VI);

  %-Calculate height threshold filtering
  %--------------------------------------------------------------------------
  Q      = find(Z >= threshold);

  %-Apply height threshold
  %--------------------------------------------------------------------------
  Z      = Z(:,Q);
  XYZ    = XYZ(:,Q);
  if isempty(Q)
    fprintf('\n');                                                      %-#
    warning('SwE:NoVoxels','No voxels survive the thresholding');
  else

    %-Calculate extent threshold filtering
    %----------------------------------------------------------------------
    A     = spm_clusters(XYZ);
    Q     = [];
    for i = 1:max(A)
      j = find(A == i);
      if length(j) >= minimumClusterSize; Q = [Q j]; end
    end

    % ...eliminate voxels
    %----------------------------------------------------------------------
    Z     = Z(:,Q);
    XYZ   = XYZ(:,Q);
    if isempty(Q)
      fprintf('\n');                                                  %-#
      warning('SwE:NoVoxels','No voxels survive the thresholding');
    end

  end

  tmp= zeros(VI.dim);
  Q = cumprod([1,VI.dim(1:2)])*XYZ - ...
    sum(cumprod(VI.dim(1:2)));
  tmp(Q) = Z;
  swe_data_write(VI, tmp);


