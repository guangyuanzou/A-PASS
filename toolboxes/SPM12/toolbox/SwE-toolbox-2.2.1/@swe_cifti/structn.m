function t = structn(obj)
% Convert a NIFTI-1 object into a form of struct
%__________________________________________________________________________
% Copyright (C) 2005-2017 Wellcome Trust Centre for Neuroimaging

%
% $Id: 43d7723983caf4416ffbaf1c36bae6a3fb2b804c $


if numel(obj)~=1
    error('Too many elements to convert.');
end
fn = fieldnames(obj);
for i=1:length(fn)
    tmp = subsref(obj,struct('type','.','subs',fn{i}));
    if ~isempty(tmp)
        t.(fn{i}) = tmp;
    end
end
