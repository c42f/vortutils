function [keywords, extras] = keyword_parse(actualArgs, defaultArgs, noDefaultIsError)
% [keywords, extras] = keyword_parse(actualArgs, defaultArgs, noDefaultIsError)
%
% This function parses keyword parameter lists in an attemt to make it easy and
% to construct interfaces which take 'keyword',argument pairs.  This is
% inspired by existing practise in functions such as the inbuilt plot().  For
% instance, we want to write
%
%   plot(x,y,'linewidth', 1)
%
% rather than using positional arguments;
%
%   plot(x,y, ..., 1)
%
%
% Parameters:
% -----------
% actualArgs - a varargs cell array passed in from the calling function
% noDefaultIsError - When true, throws an error if keywords in actualArgs don't
%                    have corresponding defaults (default = true).
% defaultArgs = {default_keyword1, default_arg1, ...}
%                  - cell array of default keyword, argument pairs.
%
%
% Output:
% -------
% keywords - a struct such that keyword.word1 = value1, etc.
% extras - a cell array containing any key,value pairs which didn't have
%          corresponding defaults in the defaultArgs array.  This is useful for
%          passing keywords through one function and into another while only
%          extracting some of them.
%
% Example:
% --------
% keyword_parse could be used in a function as follows:
%
% function my_fxn(required_vars, varargin)
%   kwargs = keyword_parse(varargin, {'x', 314, 'y', 42});
%
%   disp({'running my_fxn with keyword parameter ''x'' = ', kwargs.x})
%   do_something(kwargs.x, kwargs.y);
% end
%
% And we could then execute my_fxn as
%   my_fxn(10, 'x', 30);
%
%
% Why bother?
% -----------
% Often in matlab we resort to using variable-length parameter lists with an
% expected positional arguments being given some default value if the length
% of the parameter list is less than the position in question.  This creates a
% bit of a maintainence nightmare - consider the following:
%
% function my_fxn(required, x, y)
%   if nargin < 2; x = 314; end
%   if nargin < 3; y = 42; end
%   % blah blah ...
% end
%
% Imagine that we've used this function extensively in old code.  Now imagine
% that in the future we decide that we don't want the parameter x anymore, and
% we remove it to give the interface:
%
% function my_fxn(required, y)
%
% Code which calls my_fxn(some_required_val, some_x_value) is then _silently_
% broken without any error message, since my_fxn now recieves some_x_value and
% interprets it as the variable y.  On the other hand, if the user had used
% keyword_parse then my_fxn would be called as my_fxn(some_required_val, 'x', some_x_value)
% and 'x' would not interfere with the correct operation of the program.  In
% fact, it would be flagged clearly as an error if noDefaultIsError = true.
%
% Author:
% -------
% Chris Foster - chris42f _at_ gmail.com

if nargin < 3
  noDefaultIsError = true;
end

% Check that we potentially have _pairs_ of keywords and arguments
if mod(length(actualArgs),2) ~= 0
  error('Keword or argument missing from argument list')
end
if mod(length(defaultArgs),2) ~= 0
  error('Keword or argument missing from default argument list')
end

% Pick out the keywords from the argument list.
defaultArgNames = defaultArgs(1:2:end);
actualArgNames = actualArgs(1:2:end);
% Check that keywords are actually strings.
if ~iscellstr(defaultArgNames)
  error('default argument list contains a non-string as a keyword');
end
if ~iscellstr(actualArgNames)
  error('argument list contains a non-string as a keyword');
end

% Pick out the arguments corresponding to the keywords above.
defaultArgValues = defaultArgs(2:2:end);
actualArgValues = actualArgs(2:2:end);

% Deal with arguments which don't have default values.
[noDefaultNames, noDefaultIdx] = setdiff(actualArgNames, defaultArgNames);
if noDefaultIsError
  % Complain when keywords in the argument list are present which have no
  % defined defaults.
  if length(noDefaultNames) > 0
    error('Keyword argument "%s" has no default', noDefaultNames{1});
  end
elseif nargout >= 2
  % Extra (keyword,value) pairs which don't have corresponding defaults go into
  % the extras structure.
  if length(noDefaultNames) > 0
    extras = cell(1, 2*length(noDefaultNames));
    extras(1:2:end) = noDefaultNames;
    extras(2:2:end) = actualArgValues(noDefaultIdx);
  else
    extras = {};
  end
end

% Trim off default names which are initialized in the non-default argument list.
[defaultArgNames, idxDefaults] = setdiff(defaultArgNames, actualArgNames);
defaultArgValues = defaultArgValues(idxDefaults);

% Create the keyword struct.
keywords = cell2struct(cat(2, actualArgValues, defaultArgValues), ...
                       cat(2, actualArgNames, defaultArgNames), 2);

end
