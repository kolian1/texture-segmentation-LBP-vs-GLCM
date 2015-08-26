function LBP = shiftBasedLBP(inImg, varargin) % filtR, isRotInv, isChanWiseRot
%% shiftBasedLBP
% The function implements LBP (Local Binary Pattern analysis), in a shift based manner.
%
%% Syntax
%  LBP= shiftBasedLBP(inImg);
%  LBP= shiftBasedLBP(inImg, 'argName', argVal...);
%
%% Description
% The LBP tests the relation between pixel and it's neighbors, encoding this relation into
%   a binary word. This allows detection of texture and more complicated patterns & features.
% The function is inspired by materials published by Matti Pietikainen in
%   http://www.cse.oulu.fi/CMV/Research/LBP . This implementation hovewer is not totally
%   allighned with the methods proposed by Professor Pietikainen (see Issues & Comments).
% The current method proposes an implementation based on shifted images-
%   which is benefitical in run time, espcially in cases of large filter
%   support. This is also a different way of thinking about the LBP algorithm. 
%   Two image shift functions are proposed- a circshift based one- which is
%   faster, but less accuare, and filter2 based one- which takes more time
%   and actually is exactly the same as efficientLBP proposed before.
%
%% Input arguments (defaults exist):
% inImg- input image, a 2D matrix (3D color images will be converted to 2D intensity
%     value images)
% filtR- a 2D matrix representing a arbitrary shaped filter. It can be generated using
%   generateRadialFilterLBP function. Default filter is simple  4neigbours
%   1 unit neigborhood filter (a simple cross- top, down, left right/ North, East, South, West).
% isRotInv- a logical flag. When enabled  (true  valued) generated rotation invariant LBP accuired via
%     fining an angle at whitch the LBP of a given pixel is minimal. Increases run time, and
%     results in a relatively sparce hsitogram (as many combinations disappear). 
%     Be careful when applying to a non circulat filter shape.
% isChanWiseRot- a logical flag, when enabled (default value) allowes channel wise rotation. 
%     When disabled (false valued), rotation carried out based on roation of first color
%     channel. Supported only when "isEfficent" floag is enabled. When  "isEfficent" is
%     disabled "isChanWiseRot" is true.
% hShiftFunc- the function used to shift the images {@floatingCircShift, @imshift}.
%     For details see on image shifting see:
%     http://www.mathworks.com/matlabcentral/fileexchange/32078-image-matrix-shift.
%     - imshift- results in a more accurate shift- and actually results and
%       run time are same as in efficientLBP implementation proposed before: 
%       http://www.mathworks.com/matlabcentral/fileexchange/36484-local-binary-patterns
%     - floatingCircShift- achives same results and better run time (especially for large support 
%       filters) for integer shift values. For non integer shift values run
%       time increases by factort of 2, and accuracy is reduced, due to
%       naive floating value linear interpolation scheme used. Still
%       results are fair, and run time is better the efficient LBP. 
%     See demoImgShifting fof shifting results and run time analysis.
%     See demoShiftBasedLBP for comparison between this (shiftBasedLBP) and 
%       previous  implementations.
%
%% Output arguments
%   LBP-    LBP image UINT8/UINT16/UINT32/UINT64/DOUBLE of same dimentions
%     [Height x Width] as inImg.
%
%% Issues & Comments
% - This scehme is facster, especially for large filters especially when
%     shift are integer values. For non intger shift values both run time and
%     accuracy are degraded, so using hShiftFunc = @imshift should be considered.
% - Currenlty, all neigbours are treated alike. Basically, we can use wighted/shaped
%     filter.
% - The rotation invariant LBP histogram includes less then bins then regular LBP BY
%     DEFINITION the zero trailing binary words are excluded for example, so it can be
%     reduced to a mush more component representation. Actually for 8 niegbours it's 37
%     bins, instead of 256. An efficnet way to calculate those bins value is needed.
%
%% Example
% See demoShiftBasedLBP
%
%% See also
% pixelwiseLBP          % a straigh forward iplmenetation of LBP, should achive same results
% buildShiftValsLBP     % custom function generating circulat filters
%
%% Revision history
% First version: Nikolay S. 2015-02-21.
% Last update:   Nikolay S. 2015-02-21.
%
% *List of Changes:*
% 2015-02-21- first release version.


%% Deafult params
isRotInv=false;
isChanWiseRot=false;
filtR=[0, 1; -1, 0; 0, -1; 1, 0]; %generateRadialFilterLBP(4, 1, 'shiftBasedLBP');
hShiftFunc=@imshift; % @imshift, @floatingCircShift

%% Get user inputs overriding default values
funcParamsNames={'filtR', 'isRotInv', 'isChanWiseRot', 'hShiftFunc'};
assignUserInputs(funcParamsNames, varargin{:});

if ischar(inImg) && exist(inImg, 'file')==2 % In case of file name input- read graphical file
    inImg=imread(inImg);
end

nClrChans=size(inImg, 3);

inImgType=class(inImg);
calcClass='single';

isCalcClassInput=strcmpi(inImgType, calcClass);
if ~isCalcClassInput
    inImg=cast(inImg, calcClass);
end
imgSize=size(inImg);

nNeigh=size(filtR, 1);

if nNeigh<=8
    outClass='uint8';
elseif nNeigh>8 && nNeigh<=16
    outClass='uint16';
elseif nNeigh>16 && nNeigh<=32
    outClass='uint32';
elseif nNeigh>32 && nNeigh<=64
    outClass='uint64';
else
    outClass=calcClass;
end

if isRotInv
    nRotLBP=nNeigh;
    nPixelsSingleChan=imgSize(1)*imgSize(2);
    iSingleChan=reshape( 1:nPixelsSingleChan, imgSize(1), imgSize(2) );
else
    nRotLBP=1;
end

nEps=-3;
weigthVec=reshape(2.^( (1:nNeigh) -1), 1, 1, nNeigh);
weigthMat=repmat( weigthVec, imgSize([1, 2]) );
% binaryWord=zeros(imgSize(1), imgSize(2), nNeigh, calcClass);
LBP=zeros(imgSize, outClass);
binaryWord=zeros(imgSize(1), imgSize(2), nNeigh, calcClass);
possibleLBP=zeros(imgSize(1), imgSize(2), nRotLBP);
if nargout > 1
    diffImgChan=zeros(imgSize(1), imgSize(2), nNeigh);
end

for iChan=1:nClrChans  
    % Initiate neighbours relation filter and LBP's matrix
    for iShift=1:nNeigh
        % calculate shifted image
        if nargout > 1
            diffImgChan(:, :, iShift)=hShiftFunc( inImg(:, :, iChan), filtR(iShift, :) )-...
                inImg(:, :, iChan);
        end      
        % calculate relevant LBP elements via difference of original image and it's shifted version
        binaryWord(:, :, iShift)=cast( ...
            roundnS(hShiftFunc( inImg(:, :, iChan), filtR(iShift, :) )-inImg(:, :, iChan),...
            nEps) >= 0, calcClass );      
    end % for iShift=1:nNeigh

    for iRot=1:nRotLBP
        % find all relevant LBP candidates
        possibleLBP(:, :, iRot)=sum(binaryWord.*weigthMat, 3);
        if iRot < nRotLBP
            binaryWord=circshift(binaryWord, [0, 0, 1]); % shift binaryWord elements
        end
    end
    
    if isRotInv
        if iChan==1 || isChanWiseRot
            % Find minimal LBP, and the rotation applied to first color channel
            [minColroInvLBP, iMin]=min(possibleLBP, [], 3);
            
            % calculte 3D matrix index
            iCircShiftMinLBP=iSingleChan+(iMin-1)*nPixelsSingleChan;
        else
            % the above rotation of the first channel, holds to rest of the channels
            minColroInvLBP=possibleLBP(iCircShiftMinLBP);
        end % if iChan==1 || isChanWiseRot
    else
        minColroInvLBP=possibleLBP;
    end % if isRotInv
    
    if strcmpi(outClass, calcClass)
        LBP(:, :, iChan)=minColroInvLBP;
    else
        LBP(:, :, iChan)=cast(minColroInvLBP, outClass);
    end
end % for iChan=1:nClrChans