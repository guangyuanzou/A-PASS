function o = niftistruc(fmt)
% Create a data structure describing NIFTI headers
%__________________________________________________________________________
% Copyright (C) 2005-2017 Wellcome Trust Centre for Neuroimaging

%
% $Id: b9424fab3fd7a27f89a2c3e50c92d6ba6a405b7f $


if ~nargin, fmt = 'nifti1'; end
switch lower(fmt)
    case {'nifti1','ni1','n+1'}
        o = nifti1struc;
    case {'nifti2','ni2','n+2'}
        o = nifti2struc;
    otherwise
        error('Unknown format.');
end
