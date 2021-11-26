function swe_rmodel
% Launches batch window containing SwE batch module for running a design.
% =========================================================================
% This function prepares (if needed) and launches the batch system with a
% job containing the batch module for the computation of a prespecified
% design.
% =========================================================================
% FORMAT swe_rmodel
% =========================================================================
% Written by Tom Maullin (05/09/2018)
% Version Info:  2020-06-18 15:16:32 +0200 0153229

    % Initiate a job
    if isempty(spm_figure('FindWin','Graphics'))
        % SPM not running
        swe_jobman('initcfg')
    end

    % Launch the batch system with the SwE tab
    swe_batch
    % Add the specification module to it
    swe_jobman('interactive','','swe.rmodel');

    return

end
