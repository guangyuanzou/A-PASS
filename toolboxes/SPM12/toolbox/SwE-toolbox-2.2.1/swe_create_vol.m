function vol=swe_create_vol(fname, DIM, M, varargin)
% Initialise a new volume for writing
% =========================================================================
% FORMAT vol = swe_create_vol(fname, DIM, M [, descrip])
% -------------------------------------------------------------------------
% Inputs:
%   - fname:    Filename of new image
%   - DIM:      Row vector giving image dimensions
%   - M:        4x4 homogeneous transformation, from V.mat
%   - descrip:  Description to enter into image header
%   - meshData: Boolean stating whether we output gifti or not.
%   - metadata: metadata from GIfTI file (SPM set metadata = {} for NIfTI)
% =========================================================================
% Version Info:  2020-06-18 15:16:32 +0200 0153229

    if nargin > 3
        descrip = varargin{1};
    else
        descrip = '';
    end

    if nargin > 4
        meshData = varargin{2};
    else
        meshData = false;
    end

    if nargin > 5
        metadata = varargin{3};
    else
        metadata = {};
    end

    vol = struct(...
      'fname',    fname,...
      'dim',      DIM',...
      'dt',       [spm_type('float32') spm_platform('bigend')],...
      'mat',      M,...
      'pinfo',    [1 0 0]',...
      'descrip',  descrip,...
      metadata{:});

    if meshData
        vol = spm_data_hdr_write(vol);
    else
        vol = spm_create_vol(vol);
    end

end
