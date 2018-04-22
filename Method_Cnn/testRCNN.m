load('rcnn_alex_60.mat');

data = load('ROI_nexusL1_fit.mat');%, 'ROI_nexusL1');
imgData = data.ROI_nexusL1_fit;

noTrainSample = 72;
noTestSample = 102-noTrainSample;

imgTrain = imgData(1:noTrainSample,:);
imgTest =  imgData((noTrainSample+1):end,:);

% test RCNN
tt(1:numel(imgTest.imageFilename)) = 0;%timer tt
predictBBox(1:noTestSample,1:4)  = zeros;
predictScore(1:noTestSample,1) = zeros;

for i = 1:noTestSample

    tic;
    imgurl = imgTest.imageFilename(i);
    imgtester1 = imread(imgurl{1});
    groundTruthBox = imgTest.tapArea(i,:);
    [predictBox, score, label] = ...
        detect(rcnn_alex, imgtester1,'NumStrongestRegions',10);
   
    [predictScore(i), idx] = max(score);
    
    predictBBox(i,:) = predictBox(idx, :);
    
    
    results(i).Boxes = {predictBBox(i,:)};
    results(i).Scores = {predictScore(i)};
    groundTruth(i).Boxes = {groundTruthBox};
    
    %{
    annotation = sprintf('%s: (prob. = %f)', label(idx), predictScore(i));
    detectedImg = insertObjectAnnotation(imgtester1, 'rectangle', predictBBox(i,:), annotation,'TextBoxOpacity',0.2);
    detectedImg = insertObjectAnnotation(detectedImg, 'rectangle', groundTruthBox, 'GT','Color','red','TextBoxOpacity',0.1);
    figure;imshow(detectedImg);truesize;
    %}
    tt(i) = toc;
    
end
detectionResults = struct2table(results);
groundTruthData  = struct2table(groundTruth);

[averagePrecision,recall,precision] =...
    evaluateDetectionPrecision(detectionResults,groundTruthData);


% External Evaluation
%   Predicted Coordinate pd1 pd2
distance1(1:noTestSample,1) = zeros;
distance2(1:noTestSample,1) = zeros;

for i = 1:noTestSample

    x1 = predictBBox(i,1);
    y1 = predictBBox(i,2);
    x2 = x1+ predictBBox(i,3);
    y2 = y1+ predictBBox(i,4);

    pd1 = [x1;y1]; 
    pd2 = [x2;y2];

    % GroundTruth Coordinate : pt1 pt2
    xt1 = imgTest.tapArea(i,1);
    yt1 = imgTest.tapArea(i,2);
    xt2 = xt1+imgTest.tapArea(i,3);
    yt2 = yt1+imgTest.tapArea(i,4);

    pt1 = [xt1;yt1];
    pt2 = [xt2;yt2];

    distance1(i,1) = norm(pd1-pt1);
    distance2(i,1) = norm(pd2-pt2);

end

error_distance = [distance1 distance2];

figure
plot(recall,precision)
grid on
title(sprintf('Average Precision = %.1f',averagePrecision))


%{

   for i = 1:40
        imgurl = imgTest.imageFilename(i);
        imgtester1 = imread(imgurl{1});
        groundTruthBox = imgTest.tapArea(i,:);
        [bboxes,scores,label] = detect(rcnn_alex, imgtester1,'NumStrongestRegions',8);
        results(i).Boxes = bboxes;
        results(i).Scores = scores;
        groundTruth(i).Boxes = {groundTruthBox};
   end

detectionResults = struct2table(results);
groundTruthData  = struct2table(groundTruth);

[averagePrecision,recall,precision] =...
    evaluateDetectionPrecision(detectionResults,groundTruthData);


% External Evaluation
%   Predicted Coordinate pd1 pd2
distance1(1:noTestSample,1) = zeros;
distance2(1:noTestSample,1) = zeros;

for i = 1:noTestSample

    x1 = predictBox(i,1);
    y1 = predictBox(i,2);
    x2 = x1+ predictBox(i,3);
    y2 = y1+ predictBox(i,4);

    pd1 = [x1;y1]; 
    pd2 = [x2;y2];

    % GroundTruth Coordinate : pt1 pt2
    xt1 = imgTest.tapArea(i,1);
    yt1 = imgTest.tapArea(i,2);
    xt2 = xt1+imgTest.tapArea(i,3);
    yt2 = yt1+imgTest.tapArea(i,4);

    pt1 = [xt1;yt1];
    pt2 = [xt2;yt2];

    distance1 = norm(pd1-pt1);
    distance2 = norm(pd2-pt2);

end

%}

