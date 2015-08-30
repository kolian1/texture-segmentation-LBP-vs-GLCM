function fullFileName=filesFullName(inFile, filesExtList, dlgTitle, isErrMode)
%% filesFullName
% The function attempts to find a full file name (path+file name+extention), filling the
%  missing gaps.
%
%% Syntax
%  fullFileName=filesFullName(inFile, filesExtList);
%  fullFileName=filesFullName(inFile);
%
%% Description
% The function uses Matlab build in commands "fileattrib" and "which" to get the file
%   details, one of which is the files full path we desire. Files of file-type (extention)
%   not suiting the user defined files extentions list (filesExtList) will be filtered
%   out.
%
%% Input arguments (defaults exist):
%  inFile- input file name. inFile must include file name. File path may be ommited, if
%     file is in Matlab path. File extention can be ommited for simplisuty or out of
%     laziness.
%  filesExtList- a list of extentions describing the file type we wish to detect. While
%     usually defaylu shold be empty- which wiill accpet all types of file, currently
%     default file types are Graphical or Videos. If all filesExtList elements are non
%     empty, only files with extention from the filesExtList list will be processed.All
%     the rest will get empty output.
%  dlgTitle- a string used in the files explorer menu.
%  isErrMode- a logical variable defining function behaviour in case of missing file.
%     When enabled- an error messge will be issued (default behaviour). When disabled, an
%     empty name will be returned, without an error.
%
%% Output arguments
%   fullFileName-  a full file name (path+file name+extention).
%
%% Issues & Comments
% "fileattrib" command fails sometimes for an unknown reason, therefore slower "which"
%   command is used.
%
%% Example
%  filesFullName('peppers.png')
%
%% See also
% - folderSubFolders
%
%% Revision history
% First version: Nikolay S. 2012-05-01.
% Last update:   Nikolay S. 2013-12-12.
%
% *List of Changes:*
% % 2015-08-23- Added:
%    - search for file in Matlab path when both file extention and path are missing.
% 2013-12-12- Added:
%    - search for file in same folder with same name, when file extention is missing. 
%    - search for folder in case file extention is avalible, and file in Matlab path
% 2013-05-19- Support folder full path input- browse for file.
% 2013-04-25- minor bug fix.
% 2013-04-21- filesExtList treatment changed. If all filesExtList are non empty, only
%   files with extention from the list will be processed. An empty output will be returned
%   otherwise.
% 2012-11-14- isErrMode: user can select how to react in case of missing file.
% 2012-07-31- dlgTitle: custom browser title added.
% 2012-07-19- Empty or missing input file name result in opening a browser
% 2012-05-21- Taken care of fileattrib error.
%

%% Default input parameters
if nargin < 4
    isErrMode=true;
end
if nargin < 3
    dlgTitle='Select input file.';
end
if nargin < 2 || isempty(filesExtList)% if no filesExtList was provided try finding video or graphical files
    videoFormats= VideoReader.getFileFormats();
    videoExtList={videoFormats.Extension};    % video files extentions
    imageFormats=imformats;
    imageExtList=cat(2, imageFormats.ext);    % image files extentions
    filesExtListGUI=cat(2, videoExtList, imageExtList);
    filesExtList={};
else
    filesExtListGUI=filesExtList;
end

if nargin < 1
    inFile=[];
end

fullFileName=[];
if ischar(filesExtList) % Convert to cell array if needed
    filesExtList={filesExtList};
end

%% Open browser for missing file or folder input
if isempty(inFile) || isdir(inFile) 
    % ischar(inFile) && isdir(inFile) || iscell(inFile) && isdir(inFile{1})
    if ischar(filesExtListGUI) % Convert to cell array if needed
        filesExtListGUI={filesExtListGUI};
    end
    filesFilter=sprintf('*.%s;', filesExtListGUI{:});
    if isdir(inFile)
        % In case of a folder name browse to the file, opening the browser in the user
        % specified folder
        [fileName, pathName, ~] = uigetfile(filesFilter, dlgTitle, inFile); 
    else
        [fileName, pathName, ~] = uigetfile(filesFilter, dlgTitle);
    end
    if ischar(fileName) % single file was chosen
        fullFileName=strcat(pathName, fileName);
    else % cancel was pressed
        fullFileName=inFile;
    end
    return;
end % if isempty(inFile)



%% get file parts and each part stats
[filePath, fileName, fileExt] = fileparts(inFile);
isEmptyFilePath=isempty(filePath);
isEmptyFileName=isempty(fileName);
isEmptyFileExt=isempty(fileExt);
isFileExists=( exist(inFile, 'file')==2 );

if isEmptyFileName
    % Issue an error if no file name was found.
    assert( ~isErrMode, 'No such file exists.' );
    % If error mode is disabled, return empty spaces for non existent files
    return;
end

%% Try finding missing file attributes- extention and full path
if isEmptyFileExt && ~isEmptyFilePath % Missing file extention
    % File extention was not specified. Search filePath for files with same name, trying
    % to find relevant extention, if no list of legal extentions was specified
    folderFilesList=folderFiles(filePath);
    [~, folderFilesNames, folderFilesExt] =cellfun(@fileparts, folderFilesList,...
        'UniformOutput', false);
    isMatchingNames=strcmpi(folderFilesNames, fileName);
    if isempty(filesExtList)
        switch( sum(isMatchingNames) )
            case(0) % No match
                % Issue an error if no file found for such an extention
                assert( ~isErrMode, 'No such file exists.' );
                % If error mode is disabled, return empty spaces for non existent files
                return;
            case(1) % unique match
                fullFileName=strcat(filePath, filesep,...
                    folderFilesNames{isMatchingNames}, folderFilesExt{isMatchingNames});
                return;
            otherwise % ambiguous match
                % Issue an error if seevral files were found for such name and path
                assert( ~isErrMode,...
                    'More the one file with suiting folder and filename exists.' );
                % If error mode is disabled, return empty spaces for non existent files
                return;
        end % switch( sum(isMatchingNames) )
    else
        folderFilesExt=folderFilesExt(isMatchingNames);
        folderFilesNames=folderFilesNames(isMatchingNames);
        matchCounter=0;
        for iFileExt=1:length(filesExtList)
            isMatchingExt=strcmpi( folderFilesExt, strcat('.', filesExtList{iFileExt}) );
            if sum(isMatchingExt)==1
                matchCounter=matchCounter+1;
                matchingExt=folderFilesExt{isMatchingExt};
            end
        end
        switch( matchCounter )
            case(0) % No match
                % Issue an error if no file found for such an extention
                assert( ~isErrMode, 'No such file exists.' );
                % If error mode is disabled, return empty spaces for non existent files
                return;
            case(1) % unique match
                fullFileName=strcat(filePath, filesep,...
                    folderFilesNames{1}, matchingExt);
                return;
            otherwise % ambiguous match
                % Issue an error if several files were found for such name and path
                assert( ~isErrMode,...
                    'More the one file with suiting folder and filename exists.' );
                % If error mode is disabled, return empty spaces for non existent files
                return;
        end % switch( sum(isMatchingNames) )
    end % if isempty(filesExtList)
elseif isEmptyFileExt && isEmptyFilePath % Missing file path and extention
    candidateFiles = strcat(filePath, fileName, '.', filesExtList);
    existStat = cellfun( @exist, candidateFiles, repmat({'file'}, size(candidateFiles)),...
        'UniformOutput', false );
    isCandidateFileExists = cat(1, existStat{:}) == 2;
    nFoundFiles = sum(isCandidateFileExists);
    switch(nFoundFiles)
        case(0)
            % Issue an error if no file found for such an extention
            assert( ~isErrMode, 'No such file exists.' );
            % If error mode is disabled, return empty spaces for non existent files
            return;
        case(1)
            foundFile = candidateFiles{isCandidateFileExists};
            [stats, currFileAttr] = fileattrib(foundFile);
            if ~stats % if file exist, but fileattrib failed, try using which
                fullFileName = which(foundFile);
                return;
            end
            if strcmpi(currFileAttr, 'No such file or directory.')
                % Issue an error if no file found for such an extention
                assert( ~isErrMode, 'No such file exists.' );
                % If error mode is disabled, return empty spaces for non existent files
                return;
            end
    if ( stats && ~strcmpi(currFileAttr, 'Unknown error occurred.') )
        fullFileName = currFileAttr.Name;
        return;
    end
        otherwise
            % Issue an error if no file found for such an extention
            assert( ~isErrMode, 'Several such files exist.' );
            % If error mode is disabled, return empty spaces for non existent files
            return;
    end

elseif isEmptyFilePath % Missing file path
    [stats, currFileAttr]=fileattrib(inFile);
    if ~stats && isFileExists % if file exist, but fileattrib failed, try using which 
        fullFileName=which(inFile);
        return;
    end
    
    if strcmpi(currFileAttr, 'No such file or directory.')
        % Issue an error if no file found for such an extention
        assert( ~isErrMode, 'No such file exists.' );
        % If error mode is disabled, return empty spaces for non existent files
        return;
    end
    if ( stats && ~strcmpi(currFileAttr, 'Unknown error occurred.') )
        fullFileName=currFileAttr.Name;
        return;
    end
elseif ~isFileExists % not empty name, path and ext
    % [stats, currFileAttr]=fileattrib(inFile);

    if (isErrMode) % && ~stats
        error('No such file exists.' );  % if error mode error message
    end
    
    % fullFileName=currFileAttr.Name;
    % logically else- return empty input
    return;    
end % if isempty(filePath) && ~isempty(fileExt)

% Here either file extention and path (at list relative) are avalibe, or both are missing
if ~isFileExists || (isFileExists && isEmptyFileExt)
    % if no such file is found, or file found, but file extention was ommited by user
    if isErrMode
        % error if no file found for such an extention
        assert( isEmptyFileExt, 'No such file exists.' ); 
    else
        return;
    end
    for iFileExt=1:length(filesExtList) 
        % if no file extention was mentioned, try finding one from supported video file extentions list
        candidateFile=strcat(inFile, '.', filesExtList{iFileExt});
        if exist(candidateFile, 'file')==2
            inFile=candidateFile;
            break;
        end
    end % for iFileExt=1:length(filesExtList)
    if exist(inFile, 'file')~=2
        % Issue an error if no file found for such an extention
        assert( ~isErrMode, 'No such file exists.' );
        % If error mode is disabled, return empty spaces for non existent files
        return;
    end	% if exist(inFile, 'file')~=2
end	% if exist(inFile, 'file')~=2

[~, ~, fileExt] = fileparts(inFile);
isAllFilesTypes=isempty(filesExtList) || any( cellfun(@isempty, filesExtList) );
if ~any(strcmpi( fileExt(2:end), filesExtList )) && ~isAllFilesTypes
    % ignore files that do not match filesExtList
    return;
end
fullFileName=inFile;

[stats, currFileAttr]=fileattrib(fullFileName);
% sometimes fileattrib fails witout any explanation
% assert( stats && ~strcmpi(currFileAttr, 'Unknown error occurred.') );
if ( stats && ~strcmpi(currFileAttr, 'Unknown error occurred.') )
    fullFileName=currFileAttr.Name;
else
    % if file exists but fileattrib failed use which
    fullFileName=which(fullFileName);
end
