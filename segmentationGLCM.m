function imgSegmented = segmentationGLCM(inImg, nClusters, winDims, winStep, isGrayScale)
%% segmentationGLCM
% The function performs image segmentation using sub-image GLCM  histogram.
%
%% Syntax
%  imgSegmented = segmentationGLCM(inImg);
%  imgSegmented = segmentationGLCM(inImg, nClusters);
%  imgSegmented = segmentationGLCM(inImg, nClusters, winDims);
%  imgSegmented = segmentationGLCM(inImg, nClusters, winDims, winStep);
%  imgSegmented = segmentationGLCM(inImg, nClusters, winDims, winStep, isGrayScale);
%
%% Description
% The function implements a rather primitive sheme for image segmentation. Each sub-image is
% processed using "blockproc" to acquire a feature vector for the central sub-image pixel. The
% feature vector is generated via wrapped "graycomatrix" implementic Haralic GLCM. Thus a 3D matrix
% is acquired. Each pixel feature vector along the matrix 3’d dimension is clustered via K-means
% clustering. As a result, each pixel is clustered resulting in image segmentation scheme.
% image->feature vectors->clustering->segmented image The scheme is quiet primitive and can be
% improved in multiple ways. It is merely implemented to explain a basic segmentation scheme and a
% platform to compare various feature spaces.
%
%% Input arguments (defaults exist):
% inImg- input image, or an image file name.
% nClusters- number of clusters used by the K-means Clustering. Should be similar to number of
%   segments in the image. Default value- 3.
% winDims- 2 elements vector specifying the dimensions of the sub image processed via "blockproc" to
%   generate feature vector. Default value [31, 31], resulting in 32x32 sub-image.
% winStep- 2 elements vector specifying the steps [columns, rows] between processed windows. Minimal
%   value of [1, 1] will result in pixel-wise image processing- very intensive in computational and
%   memory aspects. Default value [1, 1]- achieving maximal precision.
% isGrayScale- a logical flag. When enabled- true converts the input image to grayscale. processing
%   all colors of and RGB image is computationally intensive while the results improvement in not
%   high. Default value- true.
%
%% Output arguments
%   imgSegmented- the segmented image.
%
%% Issues & Comments
% - This scheme is not efficient, but clear and allows easy understanding, and good comparison to
%   other schemes LBP and Statistical Moments.
% - In case of "out of memory errors" reduce image dimensions, enable isGrayScale, increase winStep.
% - Static environment is used to achieve better memory utilization and run time.
%
%% Example
% See segmentationDemo
% inImg = imread('tm1_1_1.png');
% inImg = imresize(inImg, 1/4, 'bicubic');
% imgSegmented = segmentationGLCM(inImg, 3, [31, 31], [1, 1], true);
% figure;
% subplot(1, 2, 1);
% imshow(inImg);
% title('Input texture image', 'FontSize', 18);
% subplot(1, 2, 2);
% imshow(imgSegmented, []);
% title('Resulting segmentation GLCM', 'FontSize', 18);
%
%% See also
% segmentationLBP           - similar function with LBP based feature space
% segmentationStatMoments   - similar function with central statistical monmets based feature space
% segmentationDemo          - a demo script comparing segmentation schemes
% blockproc     - http://www.mathworks.com/help/images/ref/blockproc.html?searchHighlight=blockproc  
% graycomatrix  - http://www.mathworks.com/help/images/ref/graycomatrix.html
% k_means       - http://www.mathworks.com/matlabcentral/fileexchange/19344-efficient-k-means-clustering-using-jit
%
%% Revision history
% First version: Nikolay S. 2015-03-13.
% Last update:   Nikolay S. 2015-03-13.
%
% *List of Changes:*
% 2015-03-13- first release version.

%% Default params
if nargin < 2
    nClusters=3;
end
if nargin < 3
    winDims=[31, 31];
end
if nargin < 4
    winStep=[1, 1];
end
if nargin < 5
    isGrayScale = true;
end

if ischar(inImg) && exist(inImg, 'file') == 2
    inImg = imread(inImg);
end

nClrs = size(inImg, 3);
if isGrayScale && nClrs==3
    inImg = rgb2gray(inImg);
    nClrs = 1;
end

ParamsGLCM=struct ('angGLSM', [0, 45, 90, 135], 'distGLSM', [0, 1, 3],...
    'NumLevels', 8, 'Symmetric', true, 'GrayLimits', [],...
    'isRawOut', false);
   
winDims=winDims+mod(winDims+1, 2); % make diention odd

winNeigh=floor(winDims/2);
imgFeatSpace=blockproc(inImg, winStep, @raw2FeatSpace, 'BorderSize', winNeigh,...
    'TrimBorder', false, 'PadPartialBlocks', true, 'PadMethod', 'symmetric' );

imgDims=size(imgFeatSpace);
nRows=imgDims(1)*imgDims(2);
reorderedData = reshape(imgFeatSpace, nRows, []);

idxCluster = k_means( reorderedData, nClusters); % "k_means", use "kmeans" if you have statistical toolbox
imgSegmented=reshape(idxCluster, imgDims(1), imgDims(2) );

%% Nested Servise function trasfering row data to feature space vector of each sliding window
    function outData=raw2FeatSpace(inImg)
        outData = [];
        for iClr = 1:nClrs
            imgClr = inImg.data(:, :, iClr);
            outData=cat(3, outData,...
                reshape( textureGLCM(imgClr, ParamsGLCM) , 1, 1, [] ));    
        end
    end
end