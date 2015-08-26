% segmentationDemo
imgList = strcat('sample images\', {'tm1_1_1.jpg', 'horse near sea.jpg',...
    'horses near sea.jpg', 'tiger in grass.jpg', 'tiger in snow.jpg'});
imgList = imgList(1); % all other images ignored for now
nClustersList = 4; %[3, 4, 5];
winDims = [31, 31];
winStep = [1, 1]; % increase to [1, 1] for miximal accuracy
isGrayScale = false;

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
        imgSegmentedStatMoments = segmentationStatMoments(inImg, nClusters, winDims, winStep, isGrayScale);
        timeStatMoments=toc;
        
        figure;
        subplot(2, 2, 1);
        imshow(inImg);
        title('Input texture image', 'FontSize', 18);
        
        subplot(2, 2, 2);
        imshow(imgSegmentedLBP, []);
        title( sprintf('Resulting segmentation LBP.\nRun time %.1f[sec].', timeLBP), 'FontSize', 18);
        
        subplot(2, 2, 3);
        imshow(imgSegmentedGLCM, []);
        title( sprintf('Resulting segmentation GLCM.\nRun time %.1f[sec].', timeGLCM), 'FontSize', 18);
        
        subplot(2, 2, 4);
        imshow(imgSegmentedStatMoments, []);
        title( sprintf('Resulting segmentation Stat. Moments.\nRun time %.1f[sec].', timeStatMoments), 'FontSize', 18);
    end
end