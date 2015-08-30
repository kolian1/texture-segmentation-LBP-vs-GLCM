function outData = switchMatrixlabels(inData)
% Re-arrange labeled data. The function swithes input matrix labes (numerical values), so most
% frequent elements (those repating higher number of times) value will be higher. thsi will result
% in more similar segmenttaion maps.
% It would be nice to make this label switching in-pace, but I found no eficient way to achieve this.
labels = unique( inData(:) );
nLabels = numel(labels);

labelsHist = zeros(nLabels, 1);
for iLabel = 1:(nLabels-1)
    isLabel = ( inData == labels(iLabel) );
    labelsHist(iLabel) = sum( isLabel(:) );
end
labelsHist(nLabels) = numel(inData) - sum(labelsHist); % we can save last iteratoin....

[~, iSort] = sort(labelsHist, 'ascend'); % find who occupies more elements
outData = zeros( size(inData), 'like', inData );
histSortedLabels = labels(iSort);
for iLabel = 1:nLabels
    isLabel = ( inData == histSortedLabels(iLabel) );
    outData(isLabel) = labels(iLabel);
end
