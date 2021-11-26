function hdr = empty_hdr(fmt)
% Create an empty NIFTI header
% FORMAT hdr = empty_hdr
%__________________________________________________________________________
% Copyright (C) 2005-2017 Wellcome Trust Centre for Neuroimaging

%
% $Id: 22856e1e910c9be9977ad7d14c57c49ae447e4ec $


if ~nargin, fmt = 'nifti1'; end
org = niftistruc(fmt);
for i=1:length(org)
    hdr.(org(i).label) = feval(org(i).dtype.conv,org(i).def);
end
