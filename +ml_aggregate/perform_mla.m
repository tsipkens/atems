
% for ii=1:length(Imgs)
%     imwrite(Imgs(ii).binary,['../train-labels/img_',num2str(ii),'.jpg']);
%     imwrite(Imgs(ii).cropped,['../train-images/img_',num2str(ii),'.jpg']);
% end


imdsTrain = imageDatastore('../train-images');

classes = ["background" "particle"];
labels = [0 1];
pxdsTrain = pixelLabelDatastore('../train-labels',classes,labels);

pximdsTrain = pixelLabelImageDatastore(imdsTrain,pxdsTrain);
tbl = countEachLabel(pximdsTrain)

% Specify the network image size. This is typically the same as the traing image sizes.
imageSize = [2240,1952,1];

% Specify the number of classes.
numClasses = numel(classes);

% Create DeepLab v3+.
lgraph = deeplabv3plusLayers(imageSize, numClasses, "resnet18");

% Reweight layers
imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
classWeights = median(imageFreq) ./ imageFreq;
pxLayer = pixelClassificationLayer('Name','labels','Classes',tbl.Name,...
    'ClassWeights',classWeights);
lgraph = replaceLayer(lgraph,"classification",pxLayer);




%{


layers = [
    imageInputLayer(inputSize)
    
    convolution2dLayer(filterSize,numFilters,'DilationFactor',1,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    convolution2dLayer(filterSize,numFilters,'DilationFactor',2,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    convolution2dLayer(filterSize,numFilters,'DilationFactor',4,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    convolution2dLayer(1,numClasses)
    softmaxLayer
    pixelClassificationLayer('Classes',classNames,'ClassWeights',classWeights)];


options = trainingOptions('sgdm', ...
    'MaxEpochs', 100, ...
    'MiniBatchSize', 64, ... 
    'InitialLearnRate', 1e-3);

net = trainNetwork(pximdsTrain,layers,options);
%}



%-- Test network -----------%


