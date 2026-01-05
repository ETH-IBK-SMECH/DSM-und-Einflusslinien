function startup()
% Setzt den MATLAB-Pfad zurück und fügt alle benötigten Projektordner hinzu.
% Wird beim Start von MATLAB automatisch ausgeführt.
restoredefaultpath;
rehash;
projectRoot = fileparts(mfilename('fullpath'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(genpath(fullfile(projectRoot, 'Beispiele')));
