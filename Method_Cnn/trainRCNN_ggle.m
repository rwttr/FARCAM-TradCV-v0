
data = load('ROI_nexusL1_fit.mat');%, 'ROI_nexusL1');
imgData = data.ROI_nexusL1_fit;

noTrainSample = 72;
imgTrain = imgData(1:noTrainSample,:);
imgTest =  imgData((noTrainSample+1):end,:);

% Transfer Learning : Googlenet
anet = googlenet;
aLayers = anet.Layers;
acpyLayers = aLayers(1:end-3);

mylayers = [
    acpyLayers
    fullyConnectedLayer(2,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer];

options = trainingOptions('sgdm', ...
  'MiniBatchSize', 32, ...
  'InitialLearnRate', 1e-6, ...
  'MaxEpochs', 20);

% Train RCNN
rcnn_ggle = trainRCNNObjectDetector(imgTrain,...
    mylayers, options,'RegionProposalFcn',@gaborProposal4,...
    'NumStrongestRegions',30,...
    'PositiveOverlapRange',[0.5 1],...
    'NegativeOverlapRange',[0 0.5]);

%//////////////////////////////////////////////////////////////////////////




%{
% Train Faster-RCNN
frcnn = trainFasterRCNNObjectDetector(imgTrain,...
    mylayers, options);

% test Faster-RCNN
%timer tt
tt(1:numel(imgTest.imageFilename)) = 0;
for i = 1:numel(imgTest.imageFilename)

    tic;
    imgurl = imgTest.imageFilename(i);
    imgtester1 = imread(imgurl{1});
    [bbox, score, label] = detect(frcnn, imgtester1);

    [score, idx] = max(score);

    bbox = bbox(idx, :);
    annotation = sprintf('%s: (Conf= %f)', label(idx), score);

    detectedImg = insertObjectAnnotation(imgtester1, 'rectangle', bbox, annotation);

    figure
    imshow(detectedImg)
    tt(i) = toc;
    
end

%}

