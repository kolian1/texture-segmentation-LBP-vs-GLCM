function outData=roundnS(inData, nEps)
%% roundnS
% The function calculates the nearest 10^nEps rounded value of input values.
%
%% Syntax
%  outData=roundnS(inData, nEps);
%
%% Description
% The function is aimed to replace the “roundn” function that is apparently part of the Matlab Mapping
% Toolbox, which may be missing from some of the users trying to run this code. As the
% implementation is trivial I implemented it, slightly changing the name to avoid over-riding the
% original function.
%
%% Input arguments (defaults exist):
% inArr- a matrix of numerical values.
% nEps- a numerical value, defining the quantization value. 
%
%% Output arguments
% outData- the resulting rounded matrix of numerical values of same type and dimensions as inData
%
%% Issues & Comments
%
%% Example
% for iFactor=0:4
%     outData=roundnS(511, iFactor)
% end
%
%% See also
%
%% Revision history
% First version: Nikolay S. 2014-05-22.
% Last update:   Nikolay S. 2014-05-22.
%
% *List of Changes:*
%

quantVal=10^nEps;
outData=round(inData/quantVal)*quantVal;