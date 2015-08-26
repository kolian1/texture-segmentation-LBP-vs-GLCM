function shiftedMat=floatingCircShift(inMat, shiftSize)
%% function shiftedMat=floatingCircShift(inMat,shiftSize)
% Efficiently shifts input matrix in a manner similar to Matlab circshift, with minimal
%  value out of input matrix assumed.
%
%% Syntax
% shiftedMat=floatingCircShift(inMat, shiftSize)
%
%% Description
% This functions goal is to shift a matrix of any type and dimentions by user defined
%  shiftSize. The functions is highly similar to Matlab build in circshift, but instead of
%  assuming periodic matrix, it assumes a matrix with zero (actually minimal exisitng value)
%  values outside input matrix bounds.
%
%% Input arguments:
% inMat- an input matrix subject to the shift. Can be of any dimention and any type.
%
% shiftSize- 1:N dimentional vector, whre N is numer of dimentions of inMat. Describes
%  desired shift in each dimention. Naturally must be an integer. Positive and negative
%  values are supported.
% 
%
%% Output arguments
% shiftedMat- the sfited varaints of the input 1/2/3-Dimentional inputs
%
%% Issues & Comments (None)
% Non-integer shift value results in decreast contarst (out of focus) image, due to linear
%   interpolation...
%
%% Example
% img=imread('peppers.png');
% figure; imshow(img); title('Original image');
% figure; imshow(floatingCircShift(img,[20,-18.15])); title('Normal Shifted image- zero bounds are assumed');
%
%% See also
% normshift; % A custom function, operating on various input types capable of (zero or X) values
%            %  outside of limits.
% imShift;   % A custom function, operating only on images, with user defined Boundary
%            %  Options
%
%% Revision history
% First version: Nikolay S. 2011-05-07.
% Last update:   Nikolay S. 2014-01-17.
%
% *List of Changes:*
% 2014-01-17 added suport of non-integer inputs, via matrix interpolation in case of numeric inputs


% Verify legal inputs
nShift=length(shiftSize);
assert( ndims(inMat)>=nShift, ...
  'Shifting vector length is %d while it should not exceed input matrix dimentions %d ',...
  ndims(inMat), length(shiftSize) );

% devide shiftSize to integr value and reminder
shiftInt=round(shiftSize);
shiftRem=shiftSize-shiftInt;

%% Perform integer part shift
shiftedMatInt=circshift(inMat, shiftInt);
shiftedMat=shiftedMatInt;

%% For numerical inputs perform non-integer part shift (interpolation)
if ~isnumeric(inMat)
    return;
end

% Convert to double, for proper interpolation
inClass=class(inMat);
calcClass='double';
shiftedMatInt=cast(shiftedMatInt, calcClass);
shiftedMat=cast(shiftedMat, calcClass);
isRem=(shiftRem~=0);
for iShift=1:nShift
    % for each shiftSize vetor element with on integer shift, carry our the fractional shift by
    %   interpolating two shifted matrixes, with proper weightning
    if ~isRem(iShift)
        continue;
    end
    
    % initiate current shdit vector
    currShift=zeros( size(shiftSize) ); 
    currShift(iShift)=sign( shiftRem(iShift) );
    % perofrm shit
    shiftedMatRem=circshift(shiftedMatInt, currShift);
    
    % calculate the weighted averate of the two matrixes
    shiftedMat=(1-abs( shiftRem(iShift) ))*shiftedMat+abs( shiftRem(iShift) )*shiftedMatRem;
end
% convert back to original class
shiftedMat=cast(shiftedMat, inClass);