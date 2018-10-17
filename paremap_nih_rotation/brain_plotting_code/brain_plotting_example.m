%Brain plotting example

% vert = [0 0; 1 0; 1 1; 0 1; 2 2];
% fac = [1 2 2;
%        2 3 4;
%        1 5 2];
% patch('Faces', fac, 'Vertices', vert, 'FaceColor', 'red')


% FVCD = repmat([0.5 0.5 0.5], size(V,1),1);
% fig = patch('Faces',F,'Vertices',V,'edgecolor', 'none','FaceColor','interp','FaceVertexCData',FVCD)
% set(gcf,'Renderer','OpenGL')
% set(gca,'visible','off');
% set(gca, 'cLim', [-3 3]);
% set(gcf,'Renderer','OpenGL')
%   set(fig,'SpecularStrength',.1, ...
% 	  'DiffuseStrength',.6, ...
% 	  'SpecularColorReflectance',0, ...
% 	  'AmbientStrength',.45)
% 
% lighting phong
% view([0 0]);        camlight infinite;
% view([180 0]);      camlight infinite;
% view([-180 -90]);   camlight infinite;
% % view([90 0]);       camlight infinite;
pat_s = 'NIH034';

%This loads the electrode information files from FRNU
els = load_electrode_info(pat_s,1);%second input is 1 = bipolar, 0 = monopolar

elec_locs = [[els.x]' [els.y]' [els.z]'];%Create matrix of size electrodes X 3 containing the x,y,z, coordinates of each electrode

n_elecs = numel(els);

elec_data = rand(n_elecs,1);%create random data to be plotted for each electrode

load ROI.mat %load matrix of size number of ROIs X 3 containing the x,y,z, coordinates of each ROI

radius = 12.5; % in mm
elecToROI = create_el_to_roi_matrix(ROI,elec_locs,radius);%This creates a rois X electrode matrix that will be used to convert electrode values into ROI values

roi_vals = elecToROI*elec_data;%This creates a vector of values to be plotted for each ROI

[plots,brains]=plot3brains_base;%This plots 3 brains and returns the handles to the axes and the brain surfaces

s = struct();
% s.clim = [cmin cmax];
h = [];
use_rwb = 0;
h = update3brains_v2(brains,roi_vals,s,'Title String','Colorbar Title',use_rwb,h);
%You can call this function passing h back into the function to update the
%brain plots