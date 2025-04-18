% PeGSv2 uses a modular format
%      all modules to be called using the following 3 inputs and 1 output
%      all other returned values are outputs to disk
%      document the output formats used in each module

% standard file structure is: topDir/imgDir/ (with example values)
%      FileParams.topDir = '/home/username1/DATA/';
%      FileParams.imgDir = 'images/';
%      FileParams.imgReg = '240726a.1*.jpg';

% standard module parameters structure looks like this: 
%      ModNameParams.diameter = 100; %pixels
%      ModNameParmas.filter = 7; 
% for all parameters the user will set to run the module
% use if ~exist() statements to provide default values inside function

% all modules should be functions called as follows:
%      ModuleName(MyFileParams, MyModParams, verbose)
%      and return(True) or return(False) depending on their success
%      setting verbose = True/False will turn on/off outputs

% by default, you can run the function from the directory where your
% images are stored, and it will write the output to that same
% directory in a subdirectory 'output' using all .jpg files in that directory

function PeGSModular(fileParams, moduleParams, verbose)

if exist('fileParams', 'var' ) == 0
    fileParams=struct;
end
if exist('verbose', 'var' ) == 0
   verbose = true;
end
fileParams = paramsSetUp(fileParams, verbose);


if ~exist('moduleParams', 'var')
    ipParams = struct;
    pdParams = struct;
    ptParams = struct;
    cdParams = struct;
    dsParams = struct;
    amParams = struct;
    vaParams = struct;
else
    if isfield(moduleParams, 'ipParams') ==1
        ipParams = moduleParams.ipParams;
    else
        ipParams = struct;
    end
    
    if isfield(moduleParams, 'pdParams') ==1
        pdParams = moduleParams.pdParams;
    else
        pdParams = struct;
    end

    if isfield(moduleParams, 'ptParams') ==1
        ptParams = moduleParams.ptParams;
    else
        ptParams = struct;
    end

    if isfield(moduleParams, 'cdParams') ==1
        cdParams = moduleParams.cdParams;
    else
        cdParams = struct;
    end

    if isfield(moduleParams, 'dsParams') ==1
        dsParams = moduleParams.dsParams;
    else
        dsParams = struct;
    end

    if isfield(moduleParams, 'amParams') ==1
        amParams = moduleParams.amParams;
    else
        amParams = struct;
    end
    
    if isfield(moduleParams, 'vaParams') ==1
        vaParams = moduleParams.vaParams;
    else
        vaParams = struct;
    end

end

% these are basic steps to run PeGS on the sample images

%% module to preprocess images for better lighting and clarity. Set parameters in ipParams structure
imagePreprocess(fileParams, ipParams, verbose);

%% module to detect contacts between particles. Set parameters in cdParams structure
particleDetect(fileParams, pdParams, verbose);


%% particleTrack is optional. Comment out if you do not want the particles tracked from frame to frame
% module to track particles and assign them from frame to frame with the
% same id, set parameters with ptParams


particleTrack(fileParams, ptParams, verbose);


%% module to detect contacts between particles. Set parameters in cdParams structure


contactDetect(fileParams, cdParams, verbose);

%% module to solve the forces on the particles. Set parameters in dsParams structure


diskSolve(fileParams, dsParams, verbose);


%% module create an adjacency matrix for all images in the data file. Set parameters in amParams structure


adjacencyMatrix(fileParams, amParams, verbose);

%% module to perform Voronoi analysis on the particle data. Set parameters in vaParams structure


voronoi(fileParams, vaParams, verbose);

return

end

%%%%%%%%%%%%%%%%%%%%%


function [fileParams] = paramsSetUp(fileParams, verbose)

if isfield(fileParams,'topDir') == 0
    fileParams.topDir = './testdata/'; % where the images are stored
end

if isfield(fileParams,'imgDir') == 0
    fileParams.imgDir = 'images'; % where the output is saved
    imgDirPath = fullfile(fileParams.topDir,fileParams.imgDir);
    if ~exist(imgDirPath , 'dir')
        mkdir(imgDirPath)
        error(['error: put your images in ', imgDirPath, ' or change your path'])
    end
end

if isfield(fileParams,'processedImgDir') == 0
    fileParams.processedImgDir = 'processed_images'; % where the preprocessed images are saved
end

if isfield(fileParams,'particleDir') == 0
    fileParams.particleDir = 'particles';
end

if isfield(fileParams,'contactDir') == 0
   fileParams.contactDir = 'contacts';
end

if isfield(fileParams,'solvedDir') == 0
   fileParams.solvedDir = 'solved';
end

if isfield(fileParams,'adjacencyDir') == 0
   fileParams.adjacencyDir = 'adjacency';
end

if isfield(fileParams,'voronoiDir') == 0
   fileParams.voronoiDir = 'voronoi';
end

if isfield(fileParams,'imgReg') == 0
    fileParams.imgReg = '*.jpg'; %image format and regex
    % several Step*.jpg files are present on GitHub as sample data
end

if verbose
    disp(fileParams)
end

end
