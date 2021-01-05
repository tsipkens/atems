
py_exec = 'C:\Users\tsipk\anaconda3\envs\carboseg\python.exe';
py_root = fileparts(py_exec);
p = getenv('PATH');
p = strsplit(p, ';');
addToPath = {
    py_root
    fullfile(py_root, 'Library', 'mingw-w64', 'bin')
    fullfile(py_root, 'Library', 'usr', 'bin')
    fullfile(py_root, 'Library', 'bin')
    fullfile(py_root, 'Scripts')
    fullfile(py_root, 'bin')
    };
p = [addToPath(:); p(:)];
p = unique(p, 'stable');
p = strjoin(p, ';');
pyenv('ExecutionMode', 'OutOfProcess');
setenv('PATH', p);

if count(py.sys.path, '') == 0
    insert(py.sys.path,int32(0), '');
end

%%
disp('Importing segmenter ...');
py.importlib.import_module('segmenter')
disp('Complete.');
disp(' ');

%%
seg = py.segmenter.Segmenter;

% Run the classifier to get predictions.
pred = seg.run( ...
    py.list({ ...
    ['input', filesep, '201805A_A6_004.png'], ...
    ['input', filesep, '20180529_A9_003.png'], ...
    ['input', filesep, '20180529_A9_011.png']}));

% Convert to Matlab types.
pred_local0 = cell(pred);
pred_local = {};
for ii=1:length(pred_local0)
    pred_local{ii} = double(pred_local0{ii});
end
    
