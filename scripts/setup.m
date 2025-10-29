function setup()
    %Ermöglicht es Funktionen zu rufen, von allen Ordner aus
    restoredefaultpath; rehash; clear classes;
    projectRoot = fileparts(fileparts(mfilename('fullpath'))); % -> project-root/scripts
    addpath(projectRoot);
    addpath(genpath(fullfile(projectRoot,'src')));  % all code
    rehash; clear classes;
    disp('[setup] Path set. You can now call package functions, e.g., MatrizenStatik(...)');
end
