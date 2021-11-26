function extras = read_extras(fname)
% Read extra bits of information
%__________________________________________________________________________
% Copyright (C) 2005-2018 Wellcome Trust Centre for Neuroimaging

%
% $Id: cf01166aa4d4cebc0bd8914f7fb6f011ec9e285b $


extras = struct;
[pth,nam,ext] = fileparts(fname);
switch ext
    case {'.hdr','.img','.nii'}
        mname = fullfile(pth,[nam '.mat']);
    case {'.HDR','.IMG','.NII'}
        mname = fullfile(pth,[nam '.MAT']);
    otherwise
        mname = fullfile(pth,[nam '.mat']);
end

try
    is_extra = spm_existfile(mname);
catch
    is_extra = exist(mname,'file') > 0;
end

if is_extra
    try
        extras = load(mname);
    catch
        warning('Can not load "%s" as a binary MAT file.', mname);
    end
end
