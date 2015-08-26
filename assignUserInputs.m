function assignUserInputs(funcParamsNames, varargin)
%% assignUserInputs
% Load user inputs into calling environment variables/parameters easily.
%
%% Syntax
% assignUserInputs({'param1', 'param1', 'param2'}, StructureOfInputs, 'param1',  val,...
%   'param2',  val)
%
%% Description
% The goal of this function is allow easy and intuitive parsing of user
%   inputs. The function supports three common way to pass variables to
%   functions:
%     (1) "Name value" pairs- the "variable name" string is followed by the
%           "variable value". The inputs orders is arbitrary, and the user
%           can specify the relevant inputs.
%     (2) Structure input- the structure field names will specify the variable name, and
%           field content is the variable value.
%     (3) Regular case, where variables name is defined by their position in function call.  
%   Both methods "name-value" pairs and structure can be combined. User are advised to
%   load default values, before calling this function, to guarantee all variable are
%   initialized. 
%   User inputs will be interpreted by the default Matlab way, only if none
%   of the inputs was interpreted by the other two methods.
%
%% Input arguments (defaults exist):
% funcParamsNames- a cell array of string specifying the names of supported inputs.
% The remaining variables can be either pairs of variable names- variable values,
%   structures, whose filed names specify the variable names, and filed content, their
%   combination. Several structures can be used. 
% Alternatively, the remaining inputs can be the designated values, to be populated into
%   variables defined by funcParamsNames cell array elements. This is a way
%   to mimic custom/regular Matlab variables transfer mode, where only values are
%   passed, and their order defined the variables names. While this results in short
%   function calls, it leaves much place for errors, especially when number of input
%   variables increases. This mode is allowed only if no structure and
%   "pair values" inputs were detected.
%
%% Output arguments
% None.
%
%% Issues & Comments
% The user is advised to use the "funcParamsNames", to result in tight control over the
%   variables passed to the calling environment. Not using this variable will result in
%   sending variables defined by the input pairs or structure filed. those can override
%   existing calling environment variables, or even functions. Consider a case with
%   structure containing field names such as "struct", "cell" or "length".
% An option where only "funcParamsNames" unattained elements will be processed by further
%   functions can be added.
%
%% Example I- transfering variables via structure and "name value" pairs
% clear all;
% S=struct( 'param1', true, 'param2', 'bla bla bla', 'param3', {10} );
% funcParamsNames=fieldnames(S);
% funcParamsNames=cat(1, funcParamsNames, 'param4');
% who
% assignUserInputs(funcParamsNames, S, 'param4', rand(3,2) );
% fprintf('Now see the newly added variables: %s, %s, %s, %s.\n', funcParamsNames{:});
% who
%
%% Example II- transfering variables the old fasion Matlab way
% clear all;
% funcParamsNames={'param1', 'param2', 'param3'};
% who
% assignUserInputs(funcParamsNames, true, 'bla bla bla', rand(3,2) );
% fprintf('Now see the newly added variables\n');
% who
%
%% See also
% - inputParser             % Matlab alternative, IMHO somewhat harder to use.
% - assignin                % Matlab function
%
%% Revision history
% First version: Nikolay S. 2013-12-01.
% Last update:   Nikolay S. 2014-01-06.
% 
% *List of Changes:*
% 2014-01-06 fixed bug resulting from unique- reordering values
% 2014-01-01 dealing with empty structures case
% 2013-12-30 not allowing repeating initiation of a variable
% 2013-12-29 added support of custom input- only values, without structures and input
%   names.

%% Load uses params, overifding default ones

% The list of all legal input parameter names. Others will be ignored
if ~(iscell(funcParamsNames) && all( cellfun(@ischar, funcParamsNames) ))
    % if no cell array of string was specified as funcParamsNames input, consider it to
    % be empty, and append varargin
    varargin=cat(2, funcParamsNames, varargin); % varargin is a 1xN cell array
    funcParamsNames=[];
end

if numel(varargin)==1 && isempty(varargin{1}) % functioned called wihout arguments
    return;
end

% verify if no funcParamsNames input was specified
if isempty(funcParamsNames)
    isNoFuncParamsNames=true;
else
    if verLessThan('matlab', '7.14') % again, old version do not support 'stable'. 
        funcParamsNames=unique(funcParamsNames); % This can lead to bugs :(
    else
        funcParamsNames=unique(funcParamsNames , 'stable');
    end%
    isNoFuncParamsNames=false;
end

unUsedVarargin=varargin;
isUsedParamsName=false( size(funcParamsNames) );
%% Load "param name"- "param value" pairs.
nVarargin=length(varargin);
if nVarargin > 1
    isSpecificParam=false(1, nVarargin);
    iArg=1;
    while iArg <= (nVarargin-1)
        % automatically get all RELEVANT input pairs and store in local vairables
        isFuncParamsNames=strcmpi(varargin{iArg}, funcParamsNames);
        if isNoFuncParamsNames || any( isFuncParamsNames  )
            assignin('caller', varargin{iArg}, varargin{iArg+1});
            
            isSpecificParam( [iArg, iArg+1] )=true; % parameters come in Name-Value pairs
            iArg=iArg+1;
            isUsedParamsName(isFuncParamsNames)=true;
        end
        iArg=iArg+1;
    end % while iArg < (nVarargin-1)
    unUsedVarargin=varargin(~isSpecificParam); % Save varargin elements that were not used
    funcParamsNames=funcParamsNames(~isUsedParamsName); % do not allow repeating 
                                                        % initialisation of variables
    isUsedParamsName=false( size(funcParamsNames) );                                                 
end % if nargin>1

%% Attempt loading users parameters from input structures.
% In this case structure field name will be parameter name, and filed content will be
% parameter value.

iStructures=find( cellfun(@isstruct, unUsedVarargin) );
if ~isempty(iStructures)
    isSpecificParam=false(iStructures);
end
for iStruct=iStructures
    % analyze each structure unattained by previous "Load param name- param value pairs"
    % process
    CurrStruct=unUsedVarargin{iStruct};
    if numel(CurrStruct)>1
        CurrStruct=CurrStruct(1);
        warning('Structure arrays are not supported, 1''st element will be used.');
    elseif isempty(CurrStruct) % Ignore empty structures
        continue;
    end
    currFieldNames=fieldnames(CurrStruct);
    if isNoFuncParamsNames
        funcParamsNames=currFieldNames;
    end

    nFields=length(currFieldNames);
    for iFieldStr=1:nFields
        % Find relevant structure field names supported by function legal input names
        isFuncParamsNames=strcmpi(currFieldNames{iFieldStr}, funcParamsNames);
        if sum(isFuncParamsNames) > 1 % if several names were found try case sensitive match
            isFuncParamsNames=strcmp(currFieldNames{iFieldStr}, funcParamsNames);
        end
        
        % in case of ambiguty, use the first appearing name, as they are identical.
        iFirstFittingName=find(isFuncParamsNames, 1, 'first'); 
        
        if ~isempty(iFirstFittingName) % Load parameters into current environment
            assignin('caller',  funcParamsNames{iFirstFittingName},...
                CurrStruct.(currFieldNames{iFieldStr}) );
            isSpecificParam(iStruct)=true; % mark used input
            isUsedParamsName(iFirstFittingName)=true;
        end
    end % for iFieldStr=1:nFields
    if isNoFuncParamsNames
        funcParamsNames=[];
    else
        funcParamsNames=funcParamsNames(~isUsedParamsName); % do not allow repeating
                                                        % initialisation of variables
    end
end % for iStruct=find( cellfun(@isstruct, unUsedVarargin) )


if ~isempty(iStructures)
    % remove used input elements
    unUsedVarargin=unUsedVarargin( iStructures(~isSpecificParam) ); 
end
if isequal(unUsedVarargin, varargin) % neither inputs were used to extract user inputs
    % Preserve custom Matlab input parameters transfer scheme. Here inpus order defines
    % the variable destination.
    nInputs=min( numel(varargin), numel(funcParamsNames) );
    for iVargin=1:nInputs
        assignin( 'caller',  funcParamsNames{iVargin}, varargin{iVargin} );
    end
end