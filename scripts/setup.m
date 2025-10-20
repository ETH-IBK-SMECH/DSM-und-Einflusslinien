function setup()
    %Ermöglicht es Funktionen zu rufen, von allen Ordner aus
    projectRoot = fileparts(fileparts(mfilename('fullpath'))); % -> project-root/scripts
    srcFolder   = fullfile(projectRoot, 'src');
    addpath(srcFolder);
    disp('[setup] Path set. You can now call package functions, e.g., MatrizenStatik(...)');
end
