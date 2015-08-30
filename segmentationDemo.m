%% segmentationDemo
imgList = strcat('sample images\', {'tm1_1_1.jpg', 'horse near sea.jpg',...
    'horses near sea.jpg', 'tiger in grass.jpg', 'tiger in snow.jpg'});
nClustersList = 4;      % [3, 4, 5]; % Number of expected image segments
winDims = [63, 63];     % Dimentions of image section to be analyzed each type. Should include at least
    % a whole texton in it
winStep = [5, 5];       % The step between each generation of feature vector.
    % Minimal step is [1, 1] resulting in miximal accuracy, and maximal run-time.
    % Higher value will improve run-time, but decrease segmentation accuracy
isGrayScale = false;    % When enabled (set to true) convertts input data to gray-scale image-
    % decreasing run time by factor of 3, also decreasing accuaraccy.

for nClusters = nClustersList
    for iImgFile = 1:length(imgList)
        inImg = imread(imgList{iImgFile}); % 'tm1_1_1.png'
        %inImg = rgb2gray(inImg);
        %inImg = imresize(inImg, 1/4, 'bicubic');
        
        tic;
        imgSegmentedLBP = segmentationLBP(inImg, nClusters, winDims, winStep, isGrayScale);
        timeLBP=toc;
        
        tic;
        imgSegmentedGLCM = segmentationGLCM(inImg, nClusters, winDims, winStep, isGrayScale);
        timeGLCM=toc;
        
        tic;
        imgSegmentedStatMoments = segmentationStatMoments(inImg, nClusters, winDims, winStep,...
            isGrayScale);
        timeStatMoments=toc;
        
        figureFullScreen;
        subplotMargins = [0.07, 0.07];
        subplot_tight(2, 2, 1, subplotMargins);
        imshow(inImg);
        title('Input texture image', 'FontSize', 18, 'Color', 'r');
        hRect = rectangle( 'Position', [5, 5, winDims(2), winDims(1)],...
            'EdgeColor', 'b', 'LineWidth', 2, 'LineStyle', '--' );
        if iImgFile == 1 && nClusters == nClustersList(1)
            %% Demonstarte image window scanning for the first image
            for iRow = 1:5*winStep(2):size(inImg, 1)
                for iCol = 1:5*winStep(1):size(inImg, 2)
                    set( hRect, 'Position', [iCol, iRow, winDims(2), winDims(1)] );
                    pause(0.01);
                end
            end
            set( hRect, 'Position', [5, 5, winDims(2), winDims(1)] );
        end
        
        %% Present segmentation results
        subplot_tight(2, 2, 2, subplotMargins);
        imshow(imgSegmentedLBP, []);
        title( sprintf('Resulting segmentation LBP.\nRun time %.1f[sec].', timeLBP),...
            'FontSize', 18, 'Color', 'r');
        
        subplot_tight(2, 2, 3, subplotMargins);
        imshow(imgSegmentedGLCM, []);
        title( sprintf('Resulting segmentation GLCM.\nRun time %.1f[sec].', timeGLCM),...
            'FontSize', 18, 'Color', 'r');
        
        subplot_tight(2, 2, 4, subplotMargins);
        imshow(imgSegmentedStatMoments, []);
        title( sprintf('Resulting segmentation Stat. Moments.\nRun time %.1f[sec].',...
            timeStatMoments), 'FontSize', 18, 'Color', 'r');
        
        drawnow;
    end
end