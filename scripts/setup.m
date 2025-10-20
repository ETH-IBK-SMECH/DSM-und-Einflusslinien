function setup()
%SETUP Adds only the src/ folder to the MATLAB path (packages handle the rest).
projectRoot = fileparts(fileparts(mfilename('fullpath'))); % -> project-root/scripts
srcFolder   = fullfile(projectRoot, 'src');
addpath(srcFolder);
disp('[setup] Path set. You can now call package functions, e.g., dsm.io.validateAnalysisModel(...)');
end
