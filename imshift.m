function outImg=imshift(inImg, shiftVec, varargin)
%% function varargout=imshift(shiftVec,varargin)
% Shifts input images, computing it via convolutions with shifted 2D delta function.
%
%% Syntax
% [shiftImg]=imshift(shiftImg, shiftVec)
% [shiftImg]=imshift(shiftImg, shiftVec, BoundaryOption)
%
%% Description
% This functions goal is to shift image by user defined shiftVec. The shift is performed
%  by convolution with appropriate delta function. User may choose Boundary Options in a
%  manner similar to imfilter.The function receives an arbitrial number of inputs to
%  operate on- all will be shifted simultaneosly by shiftVec.
%
%% Input arguments (defaults exist):
% shift_coordinates- 1X2[rows,columns] vector. Describes desired shift of rows and
%    columns. Naturally must be an integer. Positive and negative values are supported.
%
% Boundary Options- one of the following options {'symmetric', 'replicate',
%  'circular'} is supported. When no boundary option is specified, Input array values
%  outside the bounds of the array are implicitly assumed to have 0 value (default).
%
% varargin- the input images subject to shift 2 or 3 dimantional inputs of any size.
%  Each will result in an apropriate output. Function supports all types of inpus
%  supported by imfilter- 2-D logical, UINT8, DOUBLE etc..., and 3-D UINT8, DOUBLE etc...
%
%% Output arguments
% The sfited varaints of the input 1/2/3-Dimentional inputs
%
%% Issues & Comments 
% This functions utilizes the matlab IMFILTER function, which allowes mutliple image data
%  types support, and various Boundary Options. The drwaback, is relatively slow
%  performance, copmared to circshift and normShift. In addition imshift  is limited to
%  1-D,2-D and 3-D inputs.
%
%% Example I
% img=imread('peppers.png');
% figure; imshow(img); title('Original image');
% figure; imshow(imshift([20,18],img)); title('Shifted image- zero bounds');
% figure; imshow(imshift([20,18],img,'symmetric')); title('Shifted image- mirror-reflecting bounds');
%
%% Example II- applying fractional shift to multiple images simultaneosly
% [img1, img2]=imshift([20.95,18.03],imread('peppers.png'), imread('ngc6543a.jpg'),'symmetric');
% figure;
% subplot(1,2,1);
% imshow(img1);  title('Shifted "peppers" image- mirror-reflecting bounds');
% subplot(1,2,2);
% imshow(img2);  title('Shifted "ngc6543a" image- mirror-reflecting bounds');

%% Example III- using fractional shift to generate image interpolation
% img=imread('peppers.png');
% img=imcrop(img, [190, 80, 60, 60]);
% img1_1=img;
% img1_2=imshift([0, 0.5], img);
% img2_1=imshift([0.5, 0], img);
% img2_2=imshift([0.5, 0.5], img);
% 
% imdDims=size(img);
% imgInterp=zeros( 2*imdDims(1), 2*imdDims(2), imdDims(3), class(img) );
% imgInterp(1:2:end, 1:2:end, :)=img1_1;
% imgInterp(1:2:end, 2:2:end, :)=img1_2;
% imgInterp(2:2:end, 1:2:end, :)=img2_1;
% imgInterp(2:2:end, 2:2:end, :)=img2_2;
% 
% figure;
% subplot(1,2,1)
% imshow(imgInterp); title('Bilinear interpolation using "imshift"');
% subplot(1,2,2)
% imshow( imresize(img, 2, 'nearest') ); title('Nearest neighbour interpolation using "imshift"');
%
%% See also
% imfilter;  % Matlab Image processing function- see for supported types and Boundary Options
% circshift; % Matlab function- a fast and all datatypes and dimentions supporting
%            % function. Note that in this case however that only 'circular' Boundary
%            % Option is
% possible.
% normShift % A custom function, hghly similar to circshift, but with ZERO Boundary Option
%
%% Revision history
% First version: Nikolay S. 2011-05-07.
% Last update:   Nikolay S. 2014-01-18.
%
% *List of Changes:*
% 2014-01-18 Supporting non-integer image shifting, and padding out of image by user defined value.

[boundaryOption, varargin]=validateVarargin( {'symmetric', 'replicate', 'circular'}, varargin{:} );
if isempty(boundaryOption)
    % Another optio for boundary option is a single numerical value used to
    % pad values out of image margins. Try to find one such value
    inputsNElems=cellfun( @numel, varargin, 'UniformOutput', false);
    isSingleElem=(cat(1, inputsNElems{:})==1);
    if any(isSingleElem) && isnumeric(varargin{isSingleElem})
        boundaryOption=varargin{isSingleElem};
        varargin=varargin(~isSingleElem);
    end
end
shiftFilt=generateShiftFilter(shiftVec);

if isempty(boundaryOption)
    outImg=imfilter(inImg, shiftFilt, 'same'); % output is input convolved with delta
else
    outImg=imfilter(inImg, shiftFilt, boundaryOption, 'same');
    % output is input convolved with delta, with user defined Boundary Option applied
end


% Inputs validation servise function
function [foundKeyWord, varargout]=validateVarargin(keyWordsCell, varargin)
%function [foundKeyWord,varargout]=validateVarargin(keyWordsCell,varargin)
%
% Functional purpose: The function detects a keyword amoung the inputs. If no keyword is
%  found foundKeyWord will be returned empty. All non keyword varargin elements will be
%  saved unchanged. Keyword varargin elements will be removed, while the last one of them
%  will be sent to the calling environment inside foundKeyWord
%
% Input arguments:
%       keyWordsCell- a cell array of keywords we are looking for.
%
%       varargin- cell array standart input to a function
%
% Output Arguments:
%       foundKeyWord- the last found  Key Word, empty if none was found
%
%       varargout- standart fucntion output cell array, with KeyWordls ommited
%
% Issues & Comments:
%
% Author and Date: Nikolay S. 05/07/2011
% Last update:     Nikolay S. 05/07/2011
%
foundKeyWord=[];

if ischar(keyWordsCell)
    keyWordsCell={keyWordsCell}; % if input is a string- convert to cell
end

isNonKeyWord=true(size(varargin));
for ivarArgIn=1:length(varargin)
    if ischar(varargin{ivarArgIn})
        isKeyWordsCell=strcmpi(varargin{ivarArgIn},keyWordsCell);
        if any(isKeyWordsCell)
            isNonKeyWord(ivarArgIn)=false;
            foundKeyWord=keyWordsCell{isKeyWordsCell};
        end
    end
end
varargout={varargin(isNonKeyWord)};

function shiftFilt=generateShiftFilter(shiftVec)
%% generateShiftFilter
% The function returns a filter with delta devided amoung pixles to result in fractional shift.
%
%% Syntax
%  shiftFilt=generateShiftFilter(shiftVec);
%
%% Description
% The function is desighned to return a delta filter for image shifting operation generation. For
%   case of non integer elements in shiftVec the delta function will be devided between up to 4
%   neighbouring elements.
%
%% Input arguments (defaults exist):
% shiftVec- a 1D vector of numericals (integrs or floating) defining the desired shift.
%
%% Output arguments
% shiftFilt- the resulting filter, capable of shifiting the image properly.
%
%% Issues & Comments
% - Increase in shiftFilt elements values results in larger filter support causing computaional
%   burded and slower urn time.
%
%% Example
% shiftFilt=generateShiftFilter([-16, 7.61]);
% figure;
% imshow( shiftFilt, [] );
% title('Fractional shift filter, including interpolaiton capabilities');
%
%% See also
%
%% Revision history
% First version: Nikolay S. 2014-01-18.
% Last update:   Nikolay S. 2014-01-18.

if all( mod(shiftVec,1)==0 )
    shiftFiltCenter=abs(shiftVec);
    shiftFilt=zeros(2*shiftFiltCenter+1); % build filter of minimal dimentions
    shiftFilt(1-shiftVec(1)+shiftFiltCenter(1),1-shiftVec(2)+shiftFiltCenter(2))=1;
    return;
end

nEps=-3;
shiftVec=-shiftVec;     % to fit the circshift shift direction convention
shiftVec=roundnS(shiftVec, nEps);

% Matrix indexes should be integers
shiftVecFloor=floor(shiftVec);
shiftVecCeil=ceil(shiftVec);

shiftVecDistFloor=1-abs( shiftVecFloor-shiftVec );
shiftVecDistCeil=1-abs( shiftVecCeil-shiftVec );

% Find minimal filter dimentions, based on indexes
filtDims=2*ceil( abs(shiftVec) )+1;

filtCenter=(filtDims+1)/2;

%% Convert cotersian coordinates to matrix elements coordinates via simple shift
shiftVecFloor=shiftVecFloor+filtCenter;
shiftVecCeil=shiftVecCeil+filtCenter;


%% Generate the filter- each 2D slice for filter element
shiftFilt=zeros(filtDims); % initate filter with zeros
% The delta is devided between 1 and 4 neigbouring pixels.
shiftFilt( shiftVecFloor(1), shiftVecFloor(2) )=...
    shiftFilt( shiftVecFloor(1), shiftVecFloor(2) )+shiftVecDistFloor(1)+shiftVecDistFloor(2);

shiftFilt( shiftVecFloor(1), shiftVecCeil(2) )=...
    shiftFilt( shiftVecFloor(1), shiftVecCeil(2) )+shiftVecDistFloor(1)+shiftVecDistCeil(2);

shiftFilt( shiftVecCeil(1), shiftVecFloor(2) )=...
    shiftFilt( shiftVecCeil(1), shiftVecFloor(2) )+shiftVecDistCeil(1)+shiftVecDistFloor(2);

shiftFilt( shiftVecCeil(1), shiftVecCeil(2) )=...
    shiftFilt( shiftVecCeil(1), shiftVecCeil(2) )+shiftVecDistCeil(1)+shiftVecDistCeil(2);

shiftFilt=shiftFilt/sum( shiftFilt(:) ); % norm to result in filter with sum of elements=1

