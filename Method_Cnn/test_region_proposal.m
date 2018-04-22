% Region Proposal Function Test

data = load('ROI_nexusL1_fit.mat');
imgData = data.ROI_nexusL1_fit;

noOfImg = 10;

%{
for  i = 1:102
    Itest = imread(imgData.imageFilename{i}); 
    [a,b,I_testshow] = gaborProposal2(Itest);
    
    for j = 1:length(b)
    I_testshow = insertObjectAnnotation(I_testshow,'Rectangle',a(j,:),'bb','LineWidth',1,'FontSize',8);
    end
    figure(); imshow(I_testshow);
end
%}

% timer added
time_proposal(1:noOfImg) = 0;
overlap_matrix(1:noOfImg) = 0;
noOfWin_matrix(1:noOfImg) = 0;
for img_no = 1:noOfImg
    
    tic;    
        Itest = imread(imgData.imageFilename{img_no}); 
        groundTruthBboxes = imgData.tapArea(img_no,:);     
        [bboxAll,bbscore] = gaborProposal3(Itest);    
    time_proposal(img_no) = toc;
    
    noOfWin_matrix(img_no) = numel(bbscore);
    %[precision,recall] = bboxPrecisionRecall(bboxes,groundTruthBboxes)
    overlap_matrix(img_no) =...
        max(bboxOverlapRatio(bboxAll,groundTruthBboxes));
    % average of detected window (IoU>0.5) 
    iou_matrix = bboxOverlapRatio(bboxAll,groundTruthBboxes);
    iou_matrixTH = iou_matrix-0.5;    
    %disp(img_no);
        
end

disp(mean(overlap_matrix));
disp(mean(noOfWin_matrix));
disp(mean(time_proposal));

%{

% save result : each file 
%{
SAVE_DIR = 'C:\Users\Rattachai\Desktop\ShpAna2\GaborProposal2_test';
for img_no = 1:3
    %tic;
    Itest = imread(imgData.imageFilename{img_no}); 
    [bboxAll,bbScore,I_testshow] = gaborProposal(Itest);
    time_proposal(img_no) = toc;
    for j = 1:length(bbScore)
    I_testshow = insertObjectAnnotation(I_testshow,...
        'Rectangle',bboxAll(j,:),'bb','LineWidth',1,'FontSize',8);
    end
    %ttim = toc;
    %fig1 = figure(); 
        
    imshow(I_testshow);    truesize;    
    %fname = int2str(img_no);
    %saveas(fig1, fullfile(SAVE_DIR, fname), 'png');
    %close all
end
%}

% Evaluate Performance
iou_matrix(1:numel(bbscore)) = zeros;

for i = 1: numel(bbscore)

bbGroundTruth = imgData.tapArea(1,:);  % ground truth;
bboxB = bbGroundTruth + 50;        % loop for all bb from gaborProposal2

% find each precision and recall for each box
overlapRatio = bboxOverlapRatio(bbGroundTruth,bboxB);

end

%}