function [radInterpFilt]=generateRadialFilterLBP(p, r, filerDestination)
%% generateRadialFilterLBP
% The function returns a filter with indexes arranged clock-wise in a circular shape.
%
%% Syntax
%  outArr=uniqueUnsortedVec(inArr);
%
%% Description
% The function is aimed to return a radial filter for LBP generation. See for details:  
%   Ojala T, Pietik?inen M & M?enp?? T (2002) "Multiresolution gray-scale and rotation
%   invariant texture classification with Local Binary Patterns". IEEE Transactions on
%   Pattern Analysis and Machine Intelligence 24(7):971-987.
%
%% Input arguments (defaults exist):
% inArr- a 1D vector of: numericals, logicals, characters, categoricals, or a cell array
%   of strings.
%
%% Output arguments
% p- an integer number specifying the number of neigbours- number of enabled filter
%   elemnts.
% r- a positive number specifying the raduis of the filter. Can be a non integer
%
%% Issues & Comments
% - User should be careful- some inputs combination results a filter with more lements
%    then just the round edges.
%
%% Example
% [radInterpFilt]=generateRadialFilterLBP(40, 20);
% figure;
% imshow( sum(radInterpFilt, 3)~=0 );
% title('Wighted filter');
%
%% See also
%
%% Revision history
% First version: Nikolay S. 2014-01-09.
% Last update:   Nikolay S. 2014-01-16.
%
% *List of Changes:*
%
% 2015-02-15 filerDestination parameter added to generate filter suited for "shiftBasedLBP".  
% 2014-01-16 Alighned with "Gray Scale and Rotation Invariant Texture Classi?cation
%   with Local Binary Patterns" from http://www.ee.oulu.fi/mvg/files/pdf/pdf_6.pdf.
%   Changed filter direction (to CCW), starting point (3 o'clock instead of 12), support 
%   pixels interpolation.

%% Default params
if nargin<3
    filerDestination = 'pixelWiseLBP'; % {'pixelWiseLBP', 'effLBP', 'efficientLBP', 'shiftBasedLBP'}
    if nargin<2
        r=1;
        if nargin<1
            p=8;
        end
    end
end

%% verify params leget values
r=max(1, r);    % radius below 1 is illegal
p=round(p);     % non integer number of neighbours sound oucward
p=max(1, p);    % number of neighbours below 1 is illegal


%% find elements angles, aranged counter clocwise starting from "X axis"
% See http://www.ee.oulu.fi/mvg/files/pdf/pdf_6.pdf for illustration
theta=linspace(0, 2*pi, p+1)+pi/2;   
theta=theta(1:end-1);           % remove obsolite last element (0=2*pi)

%% Find relevant coordinates
[rowsFilt, colsFilt] = pol2cart(theta, repmat(r, size(theta) )); % convert to cartesian
nEps=-3;
rowsFilt=roundnS(rowsFilt, nEps);
colsFilt=roundnS(colsFilt, nEps);

if strcmpi(filerDestination, 'shiftBasedLBP')
    % note the -1- shift direction is contorversial
    radInterpFilt = -1*cat( 2, rowsFilt(:), colsFilt(:) ); 
    return
end

% Matrix indexes should be integers
rowsFloor=floor(rowsFilt);
rowsCeil=ceil(rowsFilt);

colsFloor=floor(colsFilt);
colsCeil=ceil(colsFilt);

rowsDistFloor=1-abs( rowsFloor-rowsFilt );
rowsDistCeil=1-abs( rowsCeil-rowsFilt );
colsDistFloor=1-abs( colsFloor-colsFilt );
colsDistCeil=1-abs( colsCeil-colsFilt );

% Find minimal filter dimentions, based on indexes
filtDims=[ceil( max(rowsFilt) )-floor( min(rowsFilt) ),...
    ceil( max(colsFilt) )-floor( min(colsFilt) ) ];
filtDims=filtDims+mod(filtDims+1, 2); % verify filter dimentions are odd

filtCenter=(filtDims+1)/2;

%% Convert cotersian coordinates to matrix elements coordinates via simple shift
rowsFloor=rowsFloor+filtCenter(1);
rowsCeil=rowsCeil+filtCenter(1);
colsFloor=colsFloor+filtCenter(2);
colsCeil=colsCeil+filtCenter(2);


%% Generate the filter- each 2D slice for filter element  
radInterpFilt=zeros( [filtDims,  p], 'single'); % initate filter with zeros
for iP=1:p
    radInterpFilt( rowsFloor(iP), colsFloor(iP), iP )=...
        radInterpFilt( rowsFloor(iP), colsFloor(iP), iP )+rowsDistFloor(iP)+colsDistFloor(iP);
    
    radInterpFilt( rowsFloor(iP), colsCeil(iP), iP )=...
        radInterpFilt( rowsFloor(iP), colsCeil(iP), iP )+rowsDistFloor(iP)+colsDistCeil(iP);
    
    radInterpFilt( rowsCeil(iP), colsFloor(iP), iP )=...
        radInterpFilt( rowsCeil(iP), colsFloor(iP), iP )+rowsDistCeil(iP)+colsDistFloor(iP);
   
    radInterpFilt( rowsCeil(iP), colsCeil(iP), iP )=...
        radInterpFilt( rowsCeil(iP), colsCeil(iP), iP )+rowsDistCeil(iP)+colsDistCeil(iP);
    
    radInterpFilt( :, :, iP )=radInterpFilt( :, :, iP )/sum(sum(radInterpFilt( :, :, iP )));
end
% imshow(sum(radInterpFilt,3), []);

% Substract 1 at central element to get difference between central element and relevant
% neighbours: (5) T=p{s(g1-g0), s(g2-g0),...,s(gn-g0)}
radInterpFilt( filtCenter(1), filtCenter(2), : )=...
    radInterpFilt( filtCenter(1), filtCenter(2), : )-1; 

% % Find linear indexes
% rowsFiltInt=round( filtCenter(1)+rowsFilt );
% colsFiltInt=round( filtCenter(2)+colsFilt );
% 
% iFilt=sub2ind(filtDims, rowsFiltInt, colsFiltInt); 
% % iFilt=uniqueUnsortedVec(iFilt); % Remove repeating indexes, without changing their order! 
% 
% %% Generate radial filter indexes
% radFiltIndx=zeros( filtDims ); % initate filter with zeros
% radFiltIndx(iFilt)=1:p;
% % radFiltIndx(iFilt)=1:length(iFilt); % populate relevant filter location with numbers, 
%         % specifying both relevant elements, and their ordering

