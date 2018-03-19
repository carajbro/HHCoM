base = load('H:\HHCoM_Results\dap_0_prep_0_pVmmc_0.mat');
vmmc = load('H:\HHCoM_Results\dap_0_prep_0_pVmmc_0.5.mat');
prepVmmc = load('H:\HHCoM_Results\dap_0_prep_0.3_pVmmc_0.5.mat');
prepVmmcDap10 = load('H:\HHCoM_Results\dap_0.1_prep_0.3_pVmmc_0.5.mat');
prepVmmcDap20 = load('H:\HHCoM_Results\dap_0.2_prep_0.3_pVmmc_0.5.mat');

paramDir = [pwd , '\Params\'];
load([paramDir , 'general'])
load([paramDir , 'settings'])
c = fix(clock);
currYear = c(1); % get the current year
yearNow = round((currYear - startYear) * stepsPerYear);

% colors = [241, 90, 90;
%           240, 196, 25;
%           78, 186, 111;
%           45, 149, 191;
%           149, 91, 165]/255;
% 
% set(groot, 'DefaultAxesColor', [10, 10, 10]/255);
% set(groot, 'DefaultFigureColor', [10, 10, 10]/255);
% set(groot, 'DefaultFigureInvertHardcopy', 'off');
% set(0,'DefaultAxesXGrid','on','DefaultAxesYGrid','on')
% set(groot, 'DefaultAxesColorOrder', colors);
% set(groot, 'DefaultLineLineWidth', 3);
% set(groot, 'DefaultTextColor', [1, 1, 1]);
% set(groot, 'DefaultAxesXColor', [1, 1, 1]);
% set(groot, 'DefaultAxesYColor', [1, 1, 1]);
% set(groot , 'DefaultAxesZColor' , [1 , 1 ,1]);
% set(0,'defaultAxesFontSize',14)
% ax = gca;
% ax.XGrid = 'on';
% ax.XMinorGrid = 'on';
% ax.YGrid = 'on';
% ax.YMinorGrid = 'on';
% ax.GridColor = [1, 1, 1];
% ax.GridAlpha = 0.4;
reset(0)
set(0 , 'defaultlinelinewidth' , 2)
set(0, 'DefaultAxesFontSize',16)
%%
tVec = base.tVec; 
newHiv_Arr = {base.newHiv , vmmc.newHiv , prepVmmc.newHiv , prepVmmcDap10.newHiv , ...
    prepVmmcDap20.newHiv};
popVec_Arr = {base.popVec , vmmc.popVec , prepVmmc.popVec , prepVmmcDap10.popVec , ...
    prepVmmcDap20.popVec};
incMat = zeros(age , length(tVec) / stepsPerYear - 1);
annlz = @(x) sum(reshape(x , stepsPerYear , size(x , 1) / stepsPerYear)); 

%% Disease Incidence
inc = {incMat , incMat , incMat , incMat , incMat};
newHiv_Year = zeros(length(newHiv_Arr) , length(tVec) / stepsPerYear);
for i = 1 : length(newHiv_Arr)
    newHiv = sum(sum(sum(newHiv_Arr{i}(1 : end , 1 : gender , 4 : age , :)...
        ,2),3),4);
    popVec = popVec_Arr{i};
    hivSusInds = [toInd(allcomb(1 , 1 , 1 : hpvTypes , 1 : hpvStates , ...
        1 : periods , 1 : gender , 4 : age , 1 : risk)); ...
        toInd(allcomb(7 : 9 , 1 , 1 : hpvTypes , 1 : hpvStates , ...
        1 : periods , 1 : gender , 4 : age , 1 : risk))];
    hivSus = sum(popVec(1 : end , hivSusInds) , 2);
    hivSus_Year = annlz(hivSus) ./ stepsPerYear; % average susceptible population size per year
    newHiv_Year(i , :) = annlz(newHiv); % total new HIV infections per year
    inc{i} = newHiv_Year(i , 2 : end) ./ hivSus_Year(2 : end) .* 100;
end

figure()
for i = 1 : length(newHiv_Arr)
    plot(tVec(1 + stepsPerYear : stepsPerYear : end) , inc{i})
    xlim([tVec(stepsPerYear) , tVec(end)])
    hold on
end
xlabel('Year'); ylabel('Incidence per 100'); title('HIV Incidence')
legend('Base' , '50% VMMC coverage' , ...
    '50% VMMC, 30% PrEP coverage' , ...
    '50% VMMC, 30% PrEP, 10% Dapivirine coverage' , ...
    '50% VMMC, 30% PrEP, 20% Dapivirine coverage' , ...
    'Location' , 'northeastoutside')
T = table(tVec(1 + stepsPerYear : stepsPerYear : end)' , inc{1}' , inc{2}' , inc{3}' , ...
        inc{4}' , inc{5}');
    writetable(T , 'PreventionIncidence.csv' , 'Delimiter' , ',')

figure()
for i = 2 : length(newHiv_Arr)
    plot(tVec(1 + stepsPerYear : stepsPerYear : end) , ...
        (inc{i} - inc{1}) ./ inc{1} * 100)
    xlim([tVec(stepsPerYear) , tVec(end)])
    hold on
end
xlabel('Year'); ylabel('Percent Reduction') 
title('HIV Incidence Reduction')
legend('50% VMMC coverage' , ...
    '50% VMMC, 30% PrEP coverage' , ...
    '50% VMMC, 30% PrEP, 10% Dapivirine coverage' , ...
    '50% VMMC, 30% PrEP, 20% Dapivirine coverage' , ...
    'Location' , 'northeastoutside')

%% Effective ART coverage
% Males
figure()
hivInds = [toInd(allcomb(2 : 6 , 1 : viral , 1 : hpvTypes , 1 : hpvStates, ...
    1 : periods , 1 , 4 : age , 1 : risk)); toInd(allcomb(10 , 6 , ...
    1 : hpvTypes , 1 : hpvStates, 1 : periods , 1 , 4 : age , 1 : risk))];
artInds = toInd(allcomb(10 , 6 , 1 : hpvTypes , 1 : hpvStates, ...
    1 : periods , 1 , 4 : age , 1 : risk));
plot(tVec , sum(base.popVec(: , artInds) , 2) ./ sum(base.popVec(: , hivInds) , 2) * 100 ,...
    tVec , sum(vmmc.popVec(: , artInds) , 2) ./ sum(vmmc.popVec(: , hivInds) , 2) * 100 ,...
    tVec , sum(prepVmmc.popVec(: , artInds) , 2) ./ sum(prepVmmc.popVec(: , hivInds) , 2) * 100 , ...
    tVec , sum(prepVmmcDap10.popVec(: , artInds) , 2) ./ sum(prepVmmcDap10.popVec(: , hivInds) , 2) * 100 , ...
    tVec , sum(prepVmmcDap20.popVec(: , artInds) , 2) ./ sum(prepVmmcDap20.popVec(: , hivInds) , 2) * 100) 
legend('Base' , '50% VMMC coverage' , ...
    '50% VMMC, 30% PrEP coverage' , ...
    '50% VMMC, 30% PrEP, 10% Dapivirine coverage' , ...
    '50% VMMC, 30% PrEP, 20% Dapivirine coverage' , ...
    'Location' , 'northeastoutside')
title('Overall Male ART Coverage')
xlabel('Year'); ylabel('Coverage (%)')

% Females
figure()
hivInds = [toInd(allcomb(2 : 6 , 1 : viral , 1 : hpvTypes , 1 : hpvStates, ...
    1 : periods , 2 , 4 : age , 1 : risk)); toInd(allcomb(10 , 6 , ...
    1 : hpvTypes , 1 : hpvStates, 1 : periods , 2 , 4 : age , 1 : risk))];
artInds = toInd(allcomb(10 , 6 , 1 : hpvTypes , 1 : hpvStates, ...
    1 : periods , 2 , 4 : age , 1 : risk));
plot(tVec , sum(base.popVec(: , artInds) , 2) ./ sum(base.popVec(: , hivInds) , 2) * 100 ,...
    tVec , sum(vmmc.popVec(: , artInds) , 2) ./ sum(vmmc.popVec(: , hivInds) , 2) * 100 ,...
    tVec , sum(prepVmmc.popVec(: , artInds) , 2) ./ sum(prepVmmc.popVec(: , hivInds) , 2) * 100 , ...
    tVec , sum(prepVmmcDap10.popVec(: , artInds) , 2) ./ sum(prepVmmcDap10.popVec(: , hivInds) , 2) * 100 , ...
    tVec , sum(prepVmmcDap20.popVec(: , artInds) , 2) ./ sum(prepVmmcDap20.popVec(: , hivInds) , 2) * 100) 
legend('Base' , '50% VMMC coverage' , ...
    '50% VMMC, 30% PrEP coverage' , ...
    '50% VMMC, 30% PrEP, 10% Dapivirine coverage' , ...
    '50% VMMC, 30% PrEP, 20% Dapivirine coverage' , ...
    'Location' , 'northeastoutside')
title('Overall Female ART Coverage')
xlabel('Year'); ylabel('Coverage (%)')

%% Effective Dapivirine Coverage
dapInds = [toInd(allcomb(7 , 1 : viral , 1 : hpvTypes , 1 : hpvStates, ...
    1 : periods , 2 , 4 : 10 , 1 : risk))];
allFInds = [toInd(allcomb(1 : disease , 1 : viral , 1 : hpvTypes , 1 : hpvStates, ...
    1 : periods , 2 , 4 : 10 , 1 : risk))];
figure()

baseDapCover =  sum(base.popVec(: , dapInds) , 2) ...
    ./ sum(base.popVec(: , allFInds) , 2) * 100; 
vmmcDapCover = sum(vmmc.popVec(: , dapInds) , 2) ...
    ./ sum(vmmc.popVec(: , allFInds) , 2) * 100;
prepVmmcDapCover = sum(prepVmmc.popVec(: , dapInds) , 2)...
    ./ sum(prepVmmc.popVec(: , allFInds) , 2) * 10;
prepVmmcDap10Cover = sum(prepVmmcDap10.popVec(: , dapInds) , 2) ...
    ./ sum(prepVmmcDap10.popVec(: , allFInds) , 2) * 100;
prepVmmcDap20Cover = sum(prepVmmcDap20.popVec(: , dapInds) , 2) ...
    ./ sum(prepVmmcDap20.popVec(: , allFInds) , 2) * 100;

plot(tVec , baseDapCover ,...
    tVec , vmmcDapCover ,...
    tVec , prepVmmcDapCover , ...
    tVec , prepVmmcDap10Cover  , ...
    tVec , prepVmmcDap20Cover) 
legend('Base' , '50% VMMC coverage' , ...
    '50% VMMC, 30% PrEP coverage' , ...
    '50% VMMC, 30% PrEP, 10% Dapivirine coverage' , ...
    '50% VMMC, 30% PrEP, 20% Dapivirine coverage' , ...
    'Location' , 'northeastoutside')
title('Effective Dapivirine Coverage')
xlabel('Year'); ylabel('Coverage (%)')
T = table(tVec' , baseDapCover , ...
    vmmcDapCover , prepVmmcDapCover , prepVmmcDap10Cover ,  prepVmmcDap20Cover);
writetable(T , 'PreventionDapCoverage.csv' , 'Delimiter' , ',')

%% PrEP Coverage
prepInds = [toInd(allcomb(9 , 1 : viral , 1 : hpvTypes , 1 : hpvStates, ...
    1 : periods , 2 , 4 : 10 , 1 : risk))];
allFInds = [toInd(allcomb(1 : disease , 1 : viral , 1 : hpvTypes , 1 : hpvStates, ...
    1 : periods , 2 , 4 : 10 , 1 : risk))];
figure()

basePrepCover = sum(base.popVec(: , prepInds) , 2) ...
    ./ sum(base.popVec(: , allFInds) , 2) * 100;
vmmcPrepCover = sum(vmmc.popVec(: , prepInds) , 2)...
    ./ sum(vmmc.popVec(: , allFInds) , 2) * 100;
prepVmmcPrepCover = sum(prepVmmc.popVec(: , prepInds) , 2)...
    ./ sum(prepVmmc.popVec(: , allFInds) , 2) * 100;
prepVmmcDap10PrepCover = sum(prepVmmcDap10.popVec(: , prepInds) , 2)...
    ./ sum(prepVmmcDap10.popVec(: , allFInds) , 2) * 100;
prepVmmcDap20PrepCover = sum(prepVmmcDap20.popVec(: , prepInds) , 2) ...
    ./ sum(prepVmmcDap20.popVec(: , allFInds) , 2) * 100;

plot(tVec , basePrepCover ,...
    tVec , vmmcPrepCover ,...
    tVec , prepVmmcPrepCover , ...
    tVec , prepVmmcDap10PrepCover , ...
    tVec , prepVmmcDap20PrepCover) 
legend('Base' , '50% VMMC coverage' , ...
    '50% VMMC, 30% PrEP coverage' , ...
    '50% VMMC, 30% PrEP, 10% Dapivirine coverage' , ...
    '50% VMMC, 30% PrEP, 20% Dapivirine coverage' , ...
    'Location' , 'northeastoutside')
title('Effective PrEP Coverage')
xlabel('Year'); ylabel('Coverage (%)')
T = table(tVec' , basePrepCover , ...
    vmmcPrepCover , prepVmmcPrepCover , prepVmmcDap10PrepCover ,  prepVmmcDap20PrepCover);
writetable(T , 'PreventionPrepCoverage.csv' , 'Delimiter' , ',')

%% Circumcision Coverage
circInds = [toInd(allcomb(7 , 1 : viral , 1 : hpvTypes , 1 : hpvStates, ...
    1 : periods , 1 , 4 : 10 , 1 : risk))];
allMInds = [toInd(allcomb(1 : disease , 1 : viral , 1 : hpvTypes , 1 : hpvStates, ...
    1 : periods , 1 , 4 : 10 , 1 : risk))];
figure()
baseCircCover = sum(base.popVec(: , circInds) , 2)...
    ./ sum(base.popVec(: , allMInds) , 2) * 100;
vmmcCircCover = sum(vmmc.popVec(: , circInds) , 2)...
    ./ sum(vmmc.popVec(: , allMInds) , 2) * 100;
prepVmmcCircCover = sum(prepVmmc.popVec(: , circInds) , 2) ...
    ./ sum(prepVmmc.popVec(: , allMInds) , 2) * 100;
prepVmmcDap10CircCover = sum(prepVmmcDap10.popVec(: , circInds) , 2)...
    ./ sum(prepVmmcDap10.popVec(: , allMInds) , 2) * 100;
prepVmmcDap20CircCover = sum(prepVmmcDap20.popVec(: , circInds) , 2)...
    ./ sum(prepVmmcDap20.popVec(: , allMInds) , 2) * 100;


plot(tVec , baseCircCover ,...
    tVec , vmmcCircCover ,...
    tVec , prepVmmcCircCover , ...
    tVec , prepVmmcDap10CircCover , ...
    tVec , prepVmmcDap20CircCover) 
legend('Base' , '50% VMMC coverage' , ...
    '50% VMMC, 30% PrEP coverage' , ...
    '50% VMMC, 30% PrEP, 10% Dapivirine coverage' , ...
    '50% VMMC, 30% PrEP, 20% Dapivirine coverage' , ...
    'Location' , 'northeastoutside')
title('Effective Circumcision Coverage')
xlabel('Year'); ylabel('Coverage (%)')
T = table(tVec' , baseCircCover , ...
    vmmcCircCover , prepVmmcCircCover , prepVmmcDap10CircCover ,  prepVmmcDap20CircCover);
writetable(T , 'PreventionCircCoverage.csv' , 'Delimiter' , ',')