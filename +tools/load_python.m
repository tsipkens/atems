
% LOAD_PYTHON  Load the Python environment for carboseg.
% AUTHOR: Timothy Sipkens, 2021-01-05
%=========================================================================%

py_exec = 'C:\Users\tsipk\anaconda3\envs\carboseg\python.exe';

%-- Start python environment ---------------------------------------------%
tools.textheader('Initializing python');


py_root = fileparts(py_exec);
p = getenv('PATH');
p = strsplit(p, ';');
add_to_path = {
    py_root
    fullfile(py_root, 'Library', 'mingw-w64', 'bin')
    fullfile(py_root, 'Library', 'usr', 'bin')
    fullfile(py_root, 'Library', 'bin')
    fullfile(py_root, 'Scripts')
    fullfile(py_root, 'bin')
    };
p = [add_to_path(:); p(:)];
p = unique(p, 'stable');
p = strjoin(p, ';');

setenv('PATH', p);

pyenv('ExecutionMode', 'OutOfProcess');  % execute outside of Matlab

% Add carboseg folder, containing python code.
addpath carboseg;
if count(py.sys.path, 'carboseg') == 0
    insert(py.sys.path,int32(0), 'carboseg');
end

    
pe = pyenv();
disp('Python running.');
disp(' ');
disp(pe);

tools.textheader();
%-------------------------------------------------------------------------%

