

% Plot scatter precision recall
scatter(precision,recall)
axis([0 1 0 1]);
% Add textCell
for ii = 1:15 
    text(precision(ii)+0.01, recall(ii)+0.01 ,textCell{ii},'FontSize',8) 
end