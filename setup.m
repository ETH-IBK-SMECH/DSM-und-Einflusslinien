function setup()
%Ermöglicht es Funktionen zu rufen, von allen Ordner aus
restoredefaultpath;
rehash;
projectRoot = fileparts(mfilename('fullpath')); % -> project-root/scripts
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src'))); % all code
addpath(genpath(fullfile(projectRoot, 'Beispiele')));

% === Add MBeautifier ===
beautifierPath = fullfile(projectRoot, 'MBeautifier-1.4.0');
if isfolder(beautifierPath)
    addpath(genpath(beautifierPath));
    disp('[setup] MBeautifier added to path.');
else
    warning('[setup] MBeautifier not found at %s', beautifierPath);
end

rehash;
disp('[setup] Path set. You can now call package functions, e.g., MatrizenStatik(...).');
end
