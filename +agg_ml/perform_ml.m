
% for ii=1:length(Imgs)
%     imwrite(Imgs(ii).binary,['../train-labels/img_',num2str(ii),'.jpg']);
%     imwrite(Imgs(ii).cropped,['../train-images/img_',num2str(ii),'.jpg']);
% end


imds = imageDatastore('images/train');

classes = ["background" "particle"];
labels = [0 1];
pxds = pixelLabelDatastore('images/train-labels',classes,labels);

tbl = countEachLabel(pxds)

% Specify the network image size. This is typically the same as the traing image sizes.
imageSize = [2240,1952];

% Specify the number of classes.
numClasses = numel(classes);

%{
%-- Use DeepLab --%
% Create DeepLab v3+.
net = deeplabv3plusLayers(imageSize,numClasses,"resnet18");

% Reweight layers
imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
classWeights = median(imageFreq) ./ imageFreq;
pxLayer = pixelClassificationLayer('Name','labels','Classes',tbl.Name,...
    'ClassWeights',classWeights);
net = replaceLayer(net,"classification",pxLayer);
%}
%%
%-- Custom layers ----------------------------------------%
numFilters = 64;
filterSize = 3;
layers = [
    imageInputLayer(imageSize)
    convolution2dLayer(filterSize,numFilters,'Padding',1)
    reluLayer()
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(filterSize,numFilters,'Padding',1)
    reluLayer()
    transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1);
    convolution2dLayer(1,numClasses);
    softmaxLayer()
    pixelClassificationLayer()
    ];
imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
classWeights = median(imageFreq) ./ imageFreq;
layers(end) = pixelClassificationLayer('Classes',tbl.Name,...
    'ClassWeights',classWeights);
%_-------------------------------------------%


augmenter = imageDataAugmenter('RandXReflection',true,...
    'RandXTranslation',[-10 10],'RandYTranslation',[-10 10]);

% pximds = pixelLabelImageDatastore(imds,pxds, ...
%     'DataAugmentation',augmenter,...
%     'ColorPreprocessing','gray2rgb',...
%     'OutputSize',imageSize);
pximds = pixelLabelImageDatastore(imds,pxds, ...
    'DataAugmentation',augmenter,...
    'OutputSize',imageSize);

% Define training options. 
opts = trainingOptions('sgdm',...
    'MiniBatchSize',1,...
    'MaxEpochs',2);
net = trainNetwork(pximds,layers,opts);





%-- Test network -----------%


