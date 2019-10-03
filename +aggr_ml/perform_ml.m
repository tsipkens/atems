
% for ii=1:length(Imgs)
%     imwrite(Imgs(ii).binary,['../train-labels/img_',num2str(ii),'.jpg']);
%     imwrite(Imgs(ii).cropped,['../train-images/img_',num2str(ii),'.jpg']);
% end


imds = imageDatastore('../train-images');

classes = ["background" "particle"];
labels = [0 1];
pxds = pixelLabelDatastore('../train-labels',classes,labels);

tbl = countEachLabel(pxds)

% Specify the network image size. This is typically the same as the traing image sizes.
imageSize = [2240,1952];

% Specify the number of classes.
numClasses = numel(classes);

% Create DeepLab v3+.
lgraph = deeplabv3plusLayers(imageSize,numClasses,"resnet18",...
    'DownsamplingFactor',16);

% Reweight layers
imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
classWeights = median(imageFreq) ./ imageFreq;
pxLayer = pixelClassificationLayer('Name','labels','Classes',tbl.Name,...
    'ClassWeights',classWeights);
lgraph = replaceLayer(lgraph,"classification",pxLayer);



augmenter = imageDataAugmenter('RandXReflection',true,...
    'RandXTranslation',[-10 10],'RandYTranslation',[-10 10]);

pximds = pixelLabelImageDatastore(imds,pxds, ...
    'DataAugmentation',augmenter,...
    'ColorPreprocessing','gray2rgb',...
    'OutputSize',imageSize);

% Define training options. 
opts = trainingOptions('sgdm',...
    'MiniBatchSize',1,...
    'MaxEpochs',1);
net = trainNetwork(pximds,lgraph,opts);





%-- Test network -----------%


