function featuresGLCM = textureGLCM(imgInt, varargin)

%% Default params
nAnglRes=45*pi/180;
angGLSM=0:nAnglRes:(pi-nAnglRes);
distRes=1;
distGLSM=1:distRes:4;
offsets=[];
NumLevels=8;
Symmetric=true;
GrayLimits=[];

%% get user inputs

funcParamsNames={'angGLSM', 'distGLSM', 'offsets',...
    'NumLevels', 'Symmetric', 'GrayLimits'};
assignUserInputs( funcParamsNames, varargin{:} );

if isempty(offsets)
    offsets=calcOffsetsGLCM(angGLSM, distGLSM);
end

nOffsets=size(offsets, 1);
nClrs=size(imgInt, 3);
featuresList={'Contrast', 'Correlation', 'Energy', 'Homogeneity'};
nFeatures=length(featuresList);
featuresGLCM=zeros(1, nFeatures*nOffsets*nClrs);

for iClr=1:nClrs
    if isstruct(imgInt)
        currData=imgInt.data;
    else
        currData=imgInt;
    end
    glcms=graycomatrix(currData(:, :, iClr), 'Offset', offsets, 'NumLevels', NumLevels,...
        'Symmetric', Symmetric, 'GrayLimits', GrayLimits);
    StatsGLCM=graycoprops(glcms, featuresList );
    
    for iFeature=1:nFeatures
        featuresGLCM( (iClr-1)*nFeatures*nOffsets+(iFeature-1)*nOffsets+(1:nOffsets) )=...
            StatsGLCM.(featuresList{iFeature});
    end
end
% for some reason Correlation is NaN's for some images
featuresGLCM( isnan(featuresGLCM) )=0;


function offsetsGLCM=calcOffsetsGLCM(angGLSM, distGLSM)
[theta, r]=meshgrid(180*angGLSM/pi, distGLSM); % convert to radians

[cols, rows] = pol2cart( theta(:), r(:) );

rows=round(rows);
cols=round(cols);
offsetsGLCM = cat(2, rows, cols);
offsetsGLCM=unique(offsetsGLCM, 'rows'); % , 'stable'
offsetsGLCM(sum( abs(offsetsGLCM), 2 )==0, :)=[]; % 0,0 is illegal
