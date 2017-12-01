%%
load('general')
o90 = load('H:\HHCoM_Results\Vax_0.9_wane_0.mat'); % 90% coverage
o70 = load('H:\HHCoM_Results\Vax_0.7_wane_0.mat'); % 70% coverage
o50 = load('H:\HHCoM_Results\Vax_0.5_wane_0.mat'); % 50% coverage
oNo = load('H:\HHCoM_Results\Vax_0_wane_0.mat'); % No vaccine
tVec = o90.tVec;
%% Plot Settings

colors = [241, 90, 90;
          240, 196, 25;
          78, 186, 111;
          45, 149, 191;
          149, 91, 165]/255;

set(groot, 'DefaultAxesColor', [10, 10, 10]/255);
set(groot, 'DefaultFigureColor', [10, 10, 10]/255);
set(groot, 'DefaultFigureInvertHardcopy', 'off');
set(0,'DefaultAxesXGrid','on','DefaultAxesYGrid','on')
set(groot, 'DefaultAxesColorOrder', colors);
set(groot, 'DefaultLineLineWidth', 3);
set(groot, 'DefaultTextColor', [1, 1, 1]);
set(groot, 'DefaultAxesXColor', [1, 1, 1]);
set(groot, 'DefaultAxesYColor', [1, 1, 1]);
set(groot , 'DefaultAxesZColor' , [1 , 1 ,1]);
set(0,'defaultAxesFontSize',14)
ax = gca;
ax.XGrid = 'on';
ax.XMinorGrid = 'on';
ax.YGrid = 'on';
ax.YMinorGrid = 'on';
ax.GridColor = [1, 1, 1];
ax.GridAlpha = 0.4;
% set(0 , 'defaultlinelinewidth' , 2)
%%
ageGroups = age - 4 + 1;
wVec = zeros(age , 1);
wVec(5 : age) = [0.188 , 0.18 , 0.159 , 0.121 , 0.088 , 0.067 , 0.054 , ...
    0.046 , 0.038 , 0.029 , 0.017 , 0.013]; 
%% CC associated deaths
inds = {':' , 2 : 6 , 1};
files = {'General_CCMortality_VaxCover' , 'HivAll_CCMortality_VaxCover' , 'HivNeg_CCMortality_VaxCover'};
plotTits = {'General Cervical Cancer' , 'HIV+ Cervical Cancer' , 'HIV- Cervical Cancer'};
fac = 10 ^ 5;
vNo_MortAge = zeros(ageGroups , length(tVec) - 1);
v90_MortAge = vNo_MortAge;
v70_MortAge = vNo_MortAge;
v50_MortAge = vNo_MortAge;

for i = 1 : length(inds)
    for a = 1 : age
        % general
        allF = toInd(allcomb(1 : disease , 1 : viral , 1 : hpvTypes , 1 : hpvStates , ...
            1 : periods , 2 , a , 1 : risk));
        % All HIV-positive women (not on ART)
        allHivF = toInd(allcomb(2 : 6 , 1 : viral , 1 : hpvTypes , 1 : hpvStates , ...
            1 : periods , 2 , a , 1 : risk));
        % All HIV-negative women
        hivNeg = toInd(allcomb(1 , 1 : viral , 1 : hpvTypes , 1 : hpvStates , 1 : periods , ...
            2 , a , 1 : risk));
        
        genArray = {allF , allHivF , hivNeg};
        
        vNo_MortAge(a , :) = ...
            sum(sum(sum(oNo.ccDeath(2 : end , inds{i} , : , : , a),2),3),4) ./ ...
            sum((oNo.popVec(1 : end - 1 , genArray{i}) ...
            + oNo.popVec(2 : end , genArray{i})) * 0.5 , 2) * fac;
        
        v90_MortAge(a , :) = ...
            sum(sum(sum(o90.ccDeath(2 : end , inds{i} , : , : , a),2),3),4) ./ ...
            sum((o90.popVec(1 : end - 1 , genArray{i}) ...
            + o90.popVec(2 : end , genArray{i})) * 0.5 , 2) * fac;
        
        v70_MortAge(a , :) = ...
            sum(sum(sum(o70.ccDeath(2 : end , inds{i} , : , : , a),2),3),4) ./ ...
            sum((o70.popVec(1 : end - 1 , genArray{i}) ...
            + o70.popVec(2 : end , genArray{i})) * 0.5 , 2) * fac;
        
        v50_MortAge(a , :) = ...
            sum(sum(sum(o50.ccDeath(2 : end , inds{i} , : , : , a),2),3),4) ./ ...
            sum((o50.popVec(1 : end - 1 , genArray{i}) ...
            + o50.popVec(2 : end , genArray{i})) * 0.5 , 2) * fac;
    end
    
    % Perform age standardization
    vNo_Mort = sum(bsxfun(@times , vNo_MortAge , wVec));
    v90_Mort = sum(bsxfun(@times , v90_MortAge , wVec));
    v70_Mort = sum(bsxfun(@times , v70_MortAge , wVec));
    v50_Mort = sum(bsxfun(@times , v50_MortAge , wVec));
    
    figure()
    plot(tVec(2 : end) , vNo_Mort , tVec(2 : end) , v90_Mort , ...
        tVec(2 : end) , v70_Mort , tVec(2 : end) , v50_Mort)
    title([plotTits{i} , ' Mortality'])
    xlabel('Year'); ylabel('Mortality per 100,000')
    legend('No vaccination' , '90% coverage' , '70% coverage' , ...
        '50% coverage')
    % Reduction
    v90_Red = (v90_Mort - vNo_Mort) ./ vNo_Mort * 100;
    v70_Red = (v70_Mort - vNo_Mort) ./ vNo_Mort * 100;
    v50_Red = (v50_Mort - vNo_Mort) ./ vNo_Mort * 100;
    
    figure()
    plot(tVec(2 : end) , v90_Red , tVec(2 : end) , v70_Red , ...
        tVec(2 : end) , v50_Red)
    title([plotTits{i} , ' Mortality Reduction'])
    xlabel('Year'); ylabel('Reduction (%)')
    legend('90% coverage' , '70% coverage' , '50% coverage')
    axis([tVec(2) tVec(end) -100 0])
    
    T = table(tVec(2 : end)' , v90_Mort' , v70_Mort' , v50_Mort' , ...
        v90_Red' , v70_Red' , v50_Red');
    writetable(T , [files{i} , '_stand.csv'] , 'Delimiter' , ',')
end
%% By CD4
dVec = [2 : 6 , 10];
tits = {'Acute' , 'CD4 > 500' , 'CD4 500-350' , 'CD4 350-200' , 'CD4 < 200' , ...
    'ART'};
filenames = {'AcuteMort' , 'CD4_500Mort' , 'CD4_500_350Mort' , 'CD4_350_200Mort' , ...
    'CD4_200Mort' , 'ARTMort'};

vNo_wNoMortAge = zeros(age , length(tVec) - 1);

for d = 1 : length(dVec)
    for a = 1 : age
        hiv_ccSusAge = [toInd(allcomb(dVec(d) , 1 : viral , 1 : hpvTypes , 1 : 8 , 1 : periods , ...
            2 , 4 : age , 1 : risk)) ; toInd(allcomb(dVec(d) , 1 : viral , 1 : hpvTypes , ...
            9 : 10 , 1 : periods , 2 , 4 : age , 1 : risk))];

        vNo_wNoMortAge(a , :) = ...
            sum(sum(sum(sum(oNo.ccDeath(2 : end , dVec(d) , : , : , :),2),3),4),5) ./ ...
            sum((oNo.popVec(1 : end - 1 , hiv_ccSusAge) ...
            + oNo.popVec(2 : end , hiv_ccSusAge)) * 0.5 , 2) * fac;

        v90_MortAge(a , :) = ...
            sum(sum(sum(sum(o90.ccDeath(2 : end , dVec(d) , : , : , :),2),3),4),5) ./ ...
            sum((o90.popVec(1 : end - 1 , hiv_ccSusAge) ...
            + o90.popVec(2 : end , hiv_ccSusAge)) * 0.5 , 2) * fac;

        v70_MortAge(a , :) = ...
            sum(sum(sum(sum(o70.ccDeath(2 : end , dVec(d) , : , : , :),2),3),4),5) ./ ...
            sum((o70.popVec(1 : end - 1 , hiv_ccSusAge) ...
            + o70.popVec(2 : end , hiv_ccSusAge)) * 0.5 , 2) * fac;

        v50_MortAge(a , :) = ...
            sum(sum(sum(sum(o50.ccDeath(2 : end , dVec(d) , : , : , :),2),3),4),5) ./ ...
            sum((o50.popVec(1 : end - 1 , hiv_ccSusAge) ...
            + o50.popVec(2 : end , hiv_ccSusAge)) * 0.5 , 2) * fac;
    end
    
%     hiv_ccSus = sum(bsxfun(@times , hiv_ccSusAge , wVec));
    vNo_wNoMort = sum(bsxfun(@times , vNo_wNoMortAge , wVec));
    v90_Mort = sum(bsxfun(@times , v90_MortAge , wVec));
    v70_Mort = sum(bsxfun(@times , v70_MortAge , wVec));
    v50_Mort = sum(bsxfun(@times , v50_MortAge , wVec));
    
    figure(104)
    subplot(3 , 2 , d)
    plot(tVec(2 : end) , vNo_wNoMort , tVec(2 : end) , v90_Mort , ...
        tVec(2 : end) , v70_Mort , tVec(2 : end) , v50_Mort)
    title([tits{d} , ' Mortality'])
    xlabel('Year'); ylabel('Mortality per 100,000')
    legend('No vaccination' , '90% coverage' , '70% coverage' ,...
        '50% coverage' , 'Location' , 'northeastoutside')
    % Reduction
    v90_Red = (v90_Mort - vNo_wNoMort) ./ vNo_wNoMort * 100;
    v70_Red = (v70_Mort - vNo_wNoMort) ./ vNo_wNoMort * 100;
    v50_Red = (v50_Mort - vNo_wNoMort) ./ vNo_wNoMort * 100;

    figure(105)
    subplot(3 , 2 ,d)
    plot(tVec(2 : end) , v90_Red , tVec(2 : end) , v70_Red , ...
        tVec(2 : end) , v50_Red)
    title([tits{d} , ' Mortality Reduction'])
    xlabel('Year'); ylabel('Reduction (%)')
    legend('90% coverage' , '70% coverage' , '50% coverage', ...
        'Location' , 'northeastoutside')
    axis([tVec(2) tVec(end) -100 0])

    T = table(tVec(2 : end)' , v90_Mort' , v70_Mort' , v50_Mort' , ...
        v90_Red' , v70_Red' , v50_Red');
    writetable(T , ['VaxCover_' , filenames{d} , '_stand.csv'] , 'Delimiter' , ',')
end
%% new cervical cancers
newCC_90 = o90.newCC;
newCC_70 = o70.newCC;
newCC_50 = o50.newCC;
newCC_0 = oNo.newCC;

%% populations
pop90 = o90.popVec;
pop70 = o70.popVec;
pop50 = o50.popVec;
popNo = oNo.popVec;
%%
% General Incidence
% susceptible population
pop90_susGen = zeros(age , length(tVec) - 1);
pop70_susGen = pop90_susGen;
pop50_susGen = pop90_susGen;
popNo_susGen = pop90_susGen;
for a = 1 : age
    ccSusGen = [toInd(allcomb(1 : disease , 1 : viral , 1 : hpvTypes , 1 : 4 , 1 : periods , 2 , a , 1 : risk));
        toInd(allcomb(1 : disease , 1 : viral , 1 : hpvTypes , 8 : 10 , 1 : periods , 2 , a , 1 : risk))];
    pop90_susGen(a , :) = (sum(pop90(1 : end - 1 , ccSusGen) , 2) + sum(pop90(2 : end , ccSusGen) , 2)) * 0.5;
    pop70_susGen(a , :) = (sum(pop70(1 : end - 1 , ccSusGen) , 2) + sum(pop70(2 : end , ccSusGen) , 2)) * 0.5;
    pop50_susGen(a , :) = (sum(pop50(1 : end - 1 , ccSusGen) , 2) + sum(pop50(2 : end , ccSusGen) , 2)) * 0.5;
    popNo_susGen(a , :) = (sum(popNo(1 : end - 1 , ccSusGen) , 2) + sum(popNo(2 : end , ccSusGen) , 2)) * 0.5;
end
% cases in general population
genCC90Age = squeeze(sum(sum(sum(newCC_90 , 2),3),4))';
genCC70Age = squeeze(sum(sum(sum(newCC_70 , 2),3),4))';
genCC50Age  = squeeze(sum(sum(sum(newCC_50 , 2),3),4))';
genCCNoAge = squeeze(sum(sum(sum(newCC_0 , 2),3),4))';
%%
% incidence
fac = 10 ^ 5;
i_gen90 = sum(bsxfun(@times , genCC90Age(: , 2 : end) ./ pop90_susGen , wVec)) .* fac;
i_gen70 = sum(bsxfun(@times , genCC70Age(: , 2 : end) ./ pop70_susGen , wVec)) .* fac;
i_gen50 = sum(bsxfun(@times , genCC50Age(: , 2 : end) ./ pop50_susGen , wVec)) .* fac;
i_genNo = sum(bsxfun(@times , genCCNoAge(: , 2 : end) ./ popNo_susGen , wVec)) .* fac;
figure()
plot(tVec(2 : end) , i_gen90 , tVec(2 : end) , i_gen70 , tVec(2 : end) , i_gen50 , tVec(2 : end) , i_genNo)
title('General Cervical Cancer Incidence')
xlabel('Year'); ylabel('Incidence per 100,000')
legend('90% coverage' , '70% coverage' , '50% coverage' , 'No vaccination')

% relative incidence reduction
figure()
genRelRed_90 = (i_gen90 - i_genNo) ./ i_genNo * 100;
genRelRed_70 = (i_gen70 - i_genNo) ./ i_genNo * 100;
genRelRed_50 = (i_gen50 - i_genNo) ./ i_genNo * 100;
plot(tVec(2 : end) , genRelRed_90 , tVec(2 : end) , genRelRed_70 , tVec(2 : end) , genRelRed_50)
title('General Cervical Cancer Reduction')
axis([tVec(1) , tVec(end) , -100 , 0])
xlabel('Year'); ylabel('Relative Difference (%)')
legend('90% coverage' , '70% coverage' , '50% coverage')
%% Export general incidence and reduction as csv
T = table(tVec(2 : end)' , i_gen90' , i_gen70' , i_gen50' , i_genNo' , genRelRed_90' , ...
    genRelRed_70' , genRelRed_50');
writetable(T , 'General_Incidence_stand.csv' , 'Delimiter' , ',')

%% HIV specific incidence
%% By CD4
% incidence
fac = 10 ^ 5;
figure()
tits = {'Acute' , 'CD4 > 500' , 'CD4 500-350' , 'CD4 350-200' , 'CD4 < 200' , ...
    'ART'};
filenames = {'Acute' , 'CD4_500' , 'CD4_500_350' , 'CD4_350_200' , 'CD4_200' , ...
    'ART'};
hiv_vec = [2 : 6 , 10];
hivCC90 = zeros(age , length(tVec));
hivCC70 = hivCC90;
hivCC50 = hivCC90;
hivCCNo = hivCC90;
pop90_susHiv = zeros(age , length(tVec) - 1);
pop70_susHiv = pop90_susHiv;
pop50_susHiv = pop90_susHiv;
popNo_susHiv = pop90_susHiv;
for i = 1 : length(hiv_vec)
    for a = 1 : age
        d = hiv_vec(i);
        hivCC90(a , :) = sum(sum(newCC_90(: , d , : , : , a),3),4);
        hivCC70(a , :) = sum(sum(newCC_70(: , d , : , : , a),3),4);
        hivCC50(a , :) = sum(sum(newCC_50(: , d , : , : , a),3),4);
        hivCCNo(a , :) = sum(sum(newCC_0(: , d , : , : , a),3),4);
        
        hivSus = [toInd(allcomb(d , 1 : viral , 1 : hpvTypes , 1 : 4 , 1 : periods , ...
            2 , a , 1 : risk)) ; toInd(allcomb(d , 1 : viral , 1 : hpvTypes , ...
            9 : 10 , 1 : periods , 2 , a , 1 : risk))];
        pop90_susHiv(a , :) = (sum(pop90(1 : end - 1 , hivSus) , 2) + sum(pop90(2 : end , hivSus) , 2)) * 0.5;
        pop70_susHiv(a , :) = (sum(pop70(1 : end - 1 , hivSus) , 2) + sum(pop70(2 : end , hivSus) , 2)) * 0.5;
        pop50_susHiv(a , :) = (sum(pop50(1 : end - 1 , hivSus) , 2) + sum(pop50(2 : end , hivSus) , 2)) * 0.5;
        popNo_susHiv(a , :) = (sum(popNo(1 : end - 1 , hivSus) , 2) + sum(popNo(2 : end , hivSus) , 2)) * 0.5;
    end
    
    % Perform age standardization
    h_gen90 = sum(bsxfun(@times , hivCC90(: , 2 : end) ./ pop90_susHiv , wVec)) .* fac;
    h_gen70 = sum(bsxfun(@times , hivCC70(: , 2 : end) ./ pop70_susHiv , wVec)) .* fac;
    h_gen50 = sum(bsxfun(@times , hivCC50(: , 2 : end) ./ pop50_susHiv , wVec)) .* fac;
    h_genNo = sum(bsxfun(@times , hivCCNo(: , 2 : end) ./ popNo_susHiv , wVec)) .* fac;
    
    subplot(3 , 2 , i)
    plot(tVec(2 : end) , h_gen90 , tVec(2 : end) , h_gen70 , tVec(2 : end) , ...
        h_gen50 , tVec(2 : end) , h_genNo)
    title(['Cervical Cancer Incidence ', tits{i}])
    xlabel('Year'); ylabel('Incidence per 100,000')

    % Export HIV-positive incidence as csv
    T = table(tVec(2 : end)' , h_gen90' , h_gen70' , h_gen50' , h_genNo');
    writetable(T , [filenames{i} , '_Incidence_stand.csv'] , 'Delimiter' , ',')
end
legend('90% coverage' , '70% coverage' , '50% coverage' , 'No vaccination')

% relative incidence reduction
figure()
for i = 1 : length(hiv_vec)
    for a = 1 : age
        d = hiv_vec(i);
        hivCC90(a , :) = sum(sum(newCC_90(: , d , : , : , a),3),4);
        hivCC70(a , :) = sum(sum(newCC_70(: , d , : , : , a),3),4);
        hivCC50(a , :) = sum(sum(newCC_50(: , d , : , : , a),3),4);
        hivCCNo(a , :) = sum(sum(newCC_0(: , d , : , : , a),3),4);
        
        hivSus = [toInd(allcomb(d , 1 : viral , 1 : hpvTypes , 1 : 4 , 1 : periods , ...
            2 , a , 1 : risk)) ; toInd(allcomb(d , 1 : viral , 1 : hpvTypes , ...
            9 : 10 , 1 : periods , 2 , a , 1 : risk))];
        pop90_susHiv(a , :) = sum(pop90(1 : end - 1 , hivSus) , 2);
        pop70_susHiv(a , :) = sum(pop70(1 : end - 1 , hivSus) , 2);
        pop50_susHiv(a , :) = sum(pop50(1 : end - 1 , hivSus) , 2);
        popNo_susHiv(a , :) = sum(popNo(1 : end - 1 , hivSus) , 2);
    end
    h_gen90 = sum(bsxfun(@times , hivCC90(: , 2 : end) ./ pop90_susHiv , wVec)).* fac;
    h_gen70 = sum(bsxfun(@times , hivCC70(: , 2 : end) ./ pop70_susHiv , wVec)) .* fac;
    h_gen50 = sum(bsxfun(@times , hivCC50(: , 2 : end) ./ pop50_susHiv , wVec)) .* fac;
    h_genNo = sum(bsxfun(@times , hivCCNo(: , 2 : end) ./ popNo_susHiv , wVec)) .* fac;

    hivRelRed_90 = (h_gen90 - h_genNo) ./ h_genNo * 100;
    hivRelRed_70 = (h_gen70 - h_genNo) ./ h_genNo * 100;
    hivRelRed_50 = (h_gen50 - h_genNo) ./ h_genNo * 100;

    subplot(3 , 2 , i)
    plot(tVec(2 : end) , hivRelRed_90 , tVec(2 : end) , hivRelRed_70 , tVec(2 : end) , hivRelRed_50)
    title(['Cervical Cancer Reduction ', tits{i}])
    xlabel('Year'); ylabel('Relative Difference (%)')
    axis([tVec(1) , tVec(end) , -100 , 0])
    % Export HIV-positive reduction as csv
    T = table(tVec(2 : end)' , hivRelRed_90' , hivRelRed_70' , hivRelRed_50');
    writetable(T , [filenames{i} , '_Incidence_stand.csv'] , 'Delimiter' , ',')
end
legend('90% coverage' , '70% coverage' , '50% coverage')

%% Acute and CD4 > 500

fac = 10 ^ 5;
figure()
tit = 'Acute and CD4 > 500';
filename = 'Acute_CD4_500';
hivCC90 = zeros(age , length(tVec));
hivCC70 = hivCC90;
hivCC50 = hivCC90;
hivCCNo = hivCC90;
vec = [2 : 3];

for a = 1 : age
    hivCC90(a , :) = sum(sum(sum(newCC_90(: , vec , : , : , a),2),3),4);
    hivCC70(a , :) = sum(sum(sum(newCC_70(: , vec , : , : , a),2),3),4);
    hivCC50(a , :) = sum(sum(sum(newCC_50(: , vec , : , : , a),2),3),4);
    hivCCNo(a , :) = sum(sum(sum(newCC_0(: , vec , : , : , a),2),3),4);
    
    hivSus = [toInd(allcomb(d , 1 : viral , 1 : hpvTypes , 1 : 4 , 1 : periods , ...
        2 , a , 1 : risk)) ; toInd(allcomb(vec , 1 : viral , 1 : hpvTypes , ...
        9 : 10 , 1 : periods , 2 , a , 1 : risk))];
    pop90_susHiv(a , :) = (sum(pop90(1 : end - 1 , hivSus) , 2) + sum(pop90(2 : end , hivSus) , 2)) * 0.5;
    pop70_susHiv(a , :) = (sum(pop70(1 : end - 1 , hivSus) , 2) + sum(pop70(2 : end , hivSus) , 2)) * 0.5;
    pop50_susHiv(a , :) = (sum(pop50(1 : end - 1 , hivSus) , 2) + sum(pop50(2 : end , hivSus) , 2)) * 0.5;
    popNo_susHiv(a , :) = (sum(popNo(1 : end - 1 , hivSus) , 2) + sum(popNo(2 : end , hivSus) , 2)) * 0.5;
end

h_gen90 = sum(bsxfun(@times , hivCC90(: , 2 : end) ./ pop90_susHiv , wVec)) .* fac;
h_gen70 = sum(bsxfun(@times , hivCC70(: , 2 : end) ./ pop70_susHiv , wVec)) .* fac;
h_gen50 = sum(bsxfun(@times , hivCC50(: , 2 : end) ./ pop50_susHiv , wVec)) .* fac;
h_genNo = sum(bsxfun(@times , hivCCNo(: , 2 : end) ./ popNo_susHiv , wVec)) .* fac;

plot(tVec(2 : end) , h_gen90 , tVec(2 : end) , h_gen70 , tVec(2 : end) , ...
    h_gen50 , tVec(2 : end) , h_genNo)
title(['Cervical Cancer Incidence ', tit])
xlabel('Year'); ylabel('Incidence per 100,000')

% Export HIV-positive incidence as csv
T = table(tVec(2 : end)' , h_gen90' , h_gen70' , h_gen50' , h_genNo');
writetable(T , [filename , '_Incidence_stand.csv'] , 'Delimiter' , ',')

legend('90% coverage' , '70% coverage' , '50% coverage' , 'No vaccination')

% relative incidence reduction
figure()
for a = 1 : age
    hivCC90(a , :) = sum(sum(sum(newCC_90(: , vec , : , : , a),2),3),4);
    hivCC70(a , :) = sum(sum(sum(newCC_70(: , vec , : , : , a),2),3),4);
    hivCC50(a , :) = sum(sum(sum(newCC_50(: , vec , : , : , a),2),3),4);
    hivCCNo(a , :) = sum(sum(sum(newCC_0(: , vec , : , : , a),2),3),4);

    hivSus = [toInd(allcomb(vec , 1 : viral , 1 : hpvTypes , 1 : 4 , 1 : periods , ...
        2 , a , 1 : risk)) ; toInd(allcomb(vec , 1 : viral , 1 : hpvTypes , ...
        9 : 10 , 1 : periods , 2 , a , 1 : risk))];
    pop90_susHiv(a , :) = sum(pop90(1 : end - 1 , hivSus) , 2);
    pop70_susHiv(a , :) = sum(pop70(1 : end - 1 , hivSus) , 2);
    pop50_susHiv(a , :) = sum(pop50(1 : end - 1 , hivSus) , 2);
    popNo_susHiv(a , :) = sum(popNo(1 : end - 1 , hivSus) , 2);
end

h_gen90 = sum(bsxfun(@times , hivCC90(: , 2 : end) ./ pop90_susHiv , wVec)) .* fac;
h_gen70 = sum(bsxfun(@times , hivCC70(: , 2 : end) ./ pop70_susHiv , wVec)) .* fac;
h_gen50 = sum(bsxfun(@times , hivCC50(: , 2 : end) ./ pop50_susHiv , wVec)) .* fac;
h_genNo = sum(bsxfun(@times , hivCCNo(: , 2 : end) ./ popNo_susHiv , wVec)) .* fac;

hivRelRed_90 = (h_gen90 - h_genNo) ./ h_genNo * 100;
hivRelRed_70 = (h_gen70 - h_genNo) ./ h_genNo * 100;
hivRelRed_50 = (h_gen50 - h_genNo) ./ h_genNo * 100;

plot(tVec(2 : end) , hivRelRed_90 , tVec(2 : end) , hivRelRed_70 , tVec(2 : end) , hivRelRed_50)
title(['Cervical Cancer Reduction ', tit])
xlabel('Year'); ylabel('Relative Difference (%)')
axis([tVec(1) , tVec(end) , -100 , 0])
% Export HIV-positive reduction as csv
T = table(tVec(2 : end)' , hivRelRed_90' , hivRelRed_70' , hivRelRed_50');
writetable(T , [filename , '_Incidence_stand.csv'] , 'Delimiter' , ',')

legend('90% coverage' , '70% coverage' , '50% coverage')

%% Aggregate (without ART)
hivAllCC90 = zeros(age , length(tVec));
hivAllCC70 = hivAllCC90;
hivAllCC50 = hivAllCC90;
hivAllCCNo = hivAllCC90;
for a = 1 : age
    hivAllCC90(a , :) = sum(sum(sum(newCC_90(: , 2 : 6 , : , : , a),2),3),4);
    hivAllCC70(a , :) = sum(sum(sum(newCC_70(: , 2 : 6 , : , : , a),2),3),4);
    hivAllCC50(a , :) = sum(sum(sum(newCC_50(: , 2 : 6 , : , : , a),2),3),4);
    hivAllCCNo(a , :) =sum(sum(sum(newCC_0(: , 2 : 6 , : , : , a),2),3),4);
    
    hivAllSus = [toInd(allcomb(2 : 6 , 1 : viral , 1 : hpvTypes , 1 : 4 , 1 : periods , ...
        2 , a , 1 : risk)); toInd(allcomb(2 : 6 , 1 : viral , 1 : hpvTypes ,...
        8 : 10 , 1 : periods , 2 , a , 1 : risk))];
    pop90_susHiv(a , :) = sum(pop90(1 : end - 1 , hivAllSus) + pop90(2 : end , hivAllSus) , 2) ./ 2;
    pop70_susHiv(a , :) = sum(pop70(1 : end - 1 , hivAllSus) + pop70(2 : end , hivAllSus) , 2) ./ 2;
    pop50_susHiv(a , :) = sum(pop50(1 : end - 1 , hivAllSus) + pop50(2 : end , hivAllSus) , 2) ./ 2;
    popNo_susHiv(a , :) = sum(popNo(1 : end - 1 , hivAllSus) + popNo(2 : end , hivAllSus) , 2) ./ 2;
end
hivAllInc90 = sum(bsxfun(@times , hivAllCC90(: , 2 : end) ./ pop90_susHiv , wVec))* fac;
hivAllInc70 = sum(bsxfun(@times , hivAllCC70(: , 2 : end) ./ pop70_susHiv , wVec)) * fac;
hivAllInc50 = sum(bsxfun(@times , hivAllCC50(: , 2 : end) ./ pop50_susHiv , wVec)) * fac;
hivAllIncNo = sum(bsxfun(@times , hivAllCCNo(: , 2 : end) ./ popNo_susHiv , wVec)) * fac;
figure()

plot(tVec(2 : end) , hivAllInc90 , tVec(2 :end) , hivAllInc70 , ...
    tVec(2 : end) , hivAllInc50 , tVec(2 : end) , hivAllIncNo)
title('Cervical Cancer Incidence Among All HIV+')
xlabel('Year'); ylabel('Incidence per 100,000')
legend('90% coverage' , '70% coverage' , '50% coverage' , 'No vaccination')

hivAllRed_90 = (hivAllInc90 - hivAllIncNo) ./ hivAllIncNo * 100;
hivAllRed_70 = (hivAllInc70 - hivAllIncNo) ./ hivAllIncNo * 100;
hivAllRed_50 = (hivAllInc50 - hivAllIncNo) ./ hivAllIncNo * 100;
figure()
plot(tVec(2 : end) , hivAllRed_90 , tVec(2 :end) , hivAllRed_70 , ...
    tVec(2 : end) , hivAllRed_50)
title('Cervical Cancer Reduction Among All HIV+')
xlabel('Year'); ylabel('Reduction (%)')
legend('90% coverage' , '70% coverage' , '50% coverage')
axis([tVec(1) , tVec(end) , -100 , 0])
% Export HIV+ aggregate cervical cancer incidence and reduction as csv
T = table(tVec(2 : end)' , hivAllInc90' , hivAllInc70' , hivAllInc50' , ...
    hivAllIncNo' , hivAllRed_90' , hivAllRed_70' , hivAllRed_50');
    writetable(T , 'AllHiv_Incidence.csv' , 'Delimiter' , ',')
%% HIV-
% incidence
figure()
hivNegCC90 = zeros(age , length(tVec));
hivNegCC70 = hivNegCC90;
hivNegCC50 = hivNegCC90;
hivNegCCNo = hivNegCC90;
pop90_susHivNeg = zeros(age , length(tVec) - 1);
pop70_susHivNeg = pop90_susHivNeg;
pop50_susHivNeg = pop90_susHivNeg;
popNo_susHivNeg = pop90_susHivNeg;
for a = 1 : age
    hivNegCC90(a , :) = sum(sum(newCC_90(: , 1 , : , : , a),3),4);
    hivNegCC70(a , :) = sum(sum(newCC_70(: , 1 , : , : , a),3),4);
    hivNegCC50(a , :) = sum(sum(newCC_50(: , 1 , : , : , a),3),4);
    hivNegCCNo(a , :) = sum(sum(newCC_0(: , 1 , : , : , a),3),4);

    hivNegSus = [toInd(allcomb(1 , 1 : viral , 1 : hpvTypes , 1 : 4 , 1 : periods , ...
        2 , a , 1 : risk)) ; toInd(allcomb(1 , 1 : viral , 1 : hpvTypes , ...
        9 : 10 , 1 : periods , 2 , a , 1 : risk))];
    pop90_susHivNeg(a , :) = (sum(pop90(1 : end - 1 , hivNegSus) , 2) + sum(pop90(2 : end , hivNegSus) , 2)) * 0.5;
    pop70_susHivNeg(a , :) = (sum(pop70(1 : end - 1 , hivNegSus) , 2) + sum(pop70(2 : end , hivNegSus) , 2)) * 0.5;
    pop50_susHivNeg(a , :) = (sum(pop50(1 : end - 1 , hivNegSus) , 2) + sum(pop50(2 : end, hivNegSus) , 2)) * 0.5;
    popNo_susHivNeg(a , :) = (sum(popNo(1 : end - 1 , hivNegSus) , 2) + sum(popNo(2 : end, hivNegSus) , 2)) * 0.5;
end

h_neg90 = sum(bsxfun(@times , hivNegCC90(: , 2 : end) ./ pop90_susHivNeg , wVec)) .* fac;
h_neg70 = sum(bsxfun(@times , hivNegCC70(: , 2 : end) ./ pop70_susHivNeg , wVec)) .* fac;
h_neg50 = sum(bsxfun(@times , hivNegCC50(: , 2 : end) ./ pop50_susHivNeg , wVec)) .* fac;
h_negNo = sum(bsxfun(@times , hivNegCCNo(: , 2 : end) ./ popNo_susHivNeg , wVec)) .* fac;
plot(tVec(2 : end) , h_neg90 , tVec(2 : end) , h_neg70 , tVec(2 : end) , ...
    h_neg50 , tVec(2 : end) , h_negNo)
title('Cervical Cancer Incidence in HIV-')
xlabel('Year'); ylabel('Incidence per 100,000')
legend('90% coverage' , '70% coverage' , '50% coverage' , 'No vaccination')
% Export HIV-negative incidence as csv
T = table(tVec(2 : end)' , h_neg90' , h_neg70' , h_neg50' , h_negNo');
writetable(T , 'HIVNeg_Incidence_stand.csv' , 'Delimiter' , ',')

% relative incidence reduction
figure()
hivNegRelRed_90 = (h_neg90 - h_negNo) ./ h_negNo * 100;
hivNegRelRed_70 = (h_neg70 - h_negNo) ./ h_negNo * 100;
hivNegRelRed_50 = (h_neg50 - h_negNo) ./ h_negNo * 100;

plot(tVec(2 : end) , hivNegRelRed_90 , tVec(2 : end) , hivNegRelRed_70 , ...
    tVec(2 : end) , hivNegRelRed_50)
title('Cervical Cancer Reduction among HIV-')
xlabel('Year'); ylabel('Relative Difference (%)')
axis([tVec(1) , tVec(end) , -100 , 0])
legend('90% coverage' , '70% coverage' , '50% coverage')

% Export HIV-negative reduction as csv
T = table(tVec(2 : end)' , hivNegRelRed_90' , hivNegRelRed_70' , hivNegRelRed_50');
writetable(T , 'HIVNeg_Reduction_stand.csv' , 'Delimiter' , ',')

%% Waning
v90_w20 = load('H:\HHCoM_Results\Vax_0.9_wane_20.mat');
v90_w15 = load('H:\HHCoM_Results\Vax_0.9_wane_15.mat');
v90_w10 = load('H:\HHCoM_Results\Vax_0.9_wane_10.mat');
v90_w0 = load('H:\HHCoM_Results\Vax_0.9_wane_0.mat');
v0_w0 = load('H:\HHCoM_Results\Vax_0_wane_0.mat');

%% Deaths

inds = {':' , 2 : 6 , 1};
files = {'General_CCMortality' , 'allHiv_CCMortality' , 'hivNegMortality'};
plotTits = {'General Cervical Cancer' , 'HIV+ Cervical Cancer' , 'HIV- Cervical Cancer'};
v90_w20MortAge = vNo_wNoMortAge;
v90_w15MortAge = vNo_wNoMortAge;
v90_w10MortAge = vNo_wNoMortAge;
v90_wNoMortAge = vNo_wNoMortAge;
for i = 1 : length(inds)
    for a = 1 : age
        % general
        allF = toInd(allcomb(1 : disease , 1 : viral , 1 : hpvTypes , 1 : hpvStates , ...
            1 : periods , 2 , a , 1 : risk));
        % All HIV-positive women (not on ART)
        allHivF = toInd(allcomb(2 : 6 , 1 : viral , 1 : hpvTypes , 1 : hpvStates , ...
            1 : periods , 2 , a , 1 : risk));
        % All HIV-negative women
        hivNeg = toInd(allcomb(1 , 1 : viral , 1 : hpvTypes , 1 : hpvStates , 1 : periods , ...
            2 , a , 1 : risk));
        
        genArray = {allF , allHivF , hivNeg};
               
        vNo_wNoMortAge(a , :) = ...
            sum(sum(sum(v0_w0.ccDeath(2 : end , inds{i} , : , : , a),2),3),4) ./ ...
            sum((v0_w0.popVec(1 : end - 1 , genArray{i}) ...
            + v0_w0.popVec(2 : end , genArray{i})) * 0.5 , 2) * fac;
        
        v90_w20MortAge(a , :) = ...
            sum(sum(sum(v90_w20.ccDeath(2 : end , inds{i} , : , : , a),2),3),4) ./ ...
            sum((v90_w20.popVec(1 : end - 1 , genArray{i}) ...
            + v90_w20.popVec(2 : end , genArray{i})) * 0.5 , 2) * fac;
        
        v90_w15MortAge(a , :) = ...
            sum(sum(sum(v90_w15.ccDeath(2 : end , inds{i} , : , : , a),2),3),4) ./ ...
            sum((v90_w15.popVec(1 : end - 1 , genArray{i}) ...
            + v90_w15.popVec(2 : end , genArray{i})) * 0.5 , 2) * fac;
        
        v90_w10MortAge(a , :) = ...
            sum(sum(sum(v90_w10.ccDeath(2 : end , inds{i} , : , : , a),2),3),4) ./ ...
            sum((v90_w10.popVec(1 : end - 1 , genArray{i}) ...
            + v90_w10.popVec(2 : end , genArray{i})) * 0.5 , 2) * fac;
        
        v90_wNoMortAge(a , :) = ...
            sum(sum(sum(v90_w0.ccDeath(2 : end , inds{i} , : , : , a),2),3),4) ./ ...
            sum((v90_w0.popVec(1 : end - 1 , genArray{i}) ...
            + v90_w0.popVec(2 : end , genArray{i})) * 0.5 , 2) * fac;
    end
    
    vNo_wNoMort = sum(bsxfun(@times , vNo_wNoMortAge , wVec));
    v90_w20Mort = sum(bsxfun(@times , v90_w20MortAge , wVec));
    v90_w15Mort = sum(bsxfun(@times , v90_w15MortAge , wVec));
    v90_w10Mort = sum(bsxfun(@times , v90_w10MortAge , wVec));
    v90_wNoMort = sum(bsxfun(@times , v90_wNoMortAge , wVec));
    
    figure()
    plot(tVec(2 : end) , vNo_wNoMort , tVec(2 : end) , v90_wNoMort , ...
        tVec(2 : end) , v90_w20Mort , tVec(2 : end) , v90_w15Mort , ...
        tVec(2 : end) , v90_w10Mort)
    title([plotTits{i} , ' Mortality'])
    xlabel('Year'); ylabel('Mortality per 100,000')
    legend('No vaccination' , 'No Waning' , '20 years' , '15 years' , '10 years')
    % Reduction
    v90_wNoRed = (v90_wNoMort - vNo_wNoMort) ./ vNo_wNoMort * 100;
    v90_w20Red = (v90_w20Mort - vNo_wNoMort) ./ vNo_wNoMort * 100;
    v90_w15Red = (v90_w15Mort - vNo_wNoMort) ./ vNo_wNoMort * 100;
    v90_w10Red = (v90_w10Mort - vNo_wNoMort) ./ vNo_wNoMort * 100;
    
    figure()
    plot(tVec(2 : end) , v90_wNoRed , tVec(2 : end) , v90_w20Red , ...
        tVec(2 : end) , v90_w15Red , tVec(2 : end) , v90_w10Red)
    title([plotTits{i} , ' Mortality Reduction'])
    xlabel('Year'); ylabel('Reduction (%)')
    legend('No Waning' , '20 years' , '15 years' , '10 years')
    axis([tVec(2) tVec(end) -100 0])
    
    T = table(tVec(2 : end)' , v90_w20Mort' , v90_w15Mort' , v90_w10Mort' , ...
        v90_wNoMort' , v90_wNoRed' , v90_w20Red' , v90_w15Red' , v90_w10Red');
    writetable(T , ['waning_', files{i} , '_stand.csv'] , 'Delimiter' , ',')
end
%%
% By CD4

dVec = [2 : 6 , 10];
tits = {'Acute' , 'CD4 > 500' , 'CD4 500-350' , 'CD4 350-200' , 'CD4 < 200' , ...
    'ART'};
filenames = {'AcuteMort' , 'CD4_500Mort' , 'CD4_500_350Mort' , 'CD4_350_200Mort' , ...
    'CD4_200Mort' , 'ARTMort'};

for d = 1 : length(dVec)
    for a = 1 : age
    hiv_ccSus = [toInd(allcomb(dVec(d) , 1 : viral , 1 : hpvTypes , 1 : 8 , 1 : periods , ...
        2 , a , 1 : risk)) ; toInd(allcomb(dVec(d) , 1 : viral , 1 : hpvTypes , ...
        9 : 10 , 1 : periods , 2 , a , 1 : risk))];

    vNo_wNoMortAge(a , :) = ...
        sum(sum(sum(v0_w0.ccDeath(2 : end , dVec(d) , : , : , a),2),3),4) ./ ...
        sum((v0_w0.popVec(1 : end - 1 , hiv_ccSus) ...
        + v0_w0.popVec(2 : end , hiv_ccSus)) * 0.5 , 2) * fac;

    v90_w20MortAge(a , :) = ...
        sum(sum(sum(v90_w20.ccDeath(2 : end , dVec(d) , : , : , a),2),3),4) ./ ...
        sum((v90_w20.popVec(1 : end - 1 , hiv_ccSus) ...
        + v90_w20.popVec(2 : end , hiv_ccSus)) * 0.5 , 2) * fac;

    v90_w15MortAge(a , :) = ...
        sum(sum(sum(v90_w15.ccDeath(2 : end , dVec(d) , : , : , a),2),3),4) ./ ...
        sum((v90_w15.popVec(1 : end - 1 , hiv_ccSus) ...
        + v90_w15.popVec(2 : end , hiv_ccSus)) * 0.5 , 2) * fac;

    v90_w10MortAge(a , :) = ...
        sum(sum(sum(v90_w10.ccDeath(2 : end , dVec(d) , : , : , a),2),3),4) ./ ...
        sum((v90_w10.popVec(1 : end - 1 , hiv_ccSus) ...
        + v90_w10.popVec(2 : end , hiv_ccSus)) * 0.5 , 2) * fac;

    v90_wNoMortAge(a , :) = ...
        sum(sum(sum(v90_w0.ccDeath(2 : end , dVec(d) , : , : , a),2),3),4) ./ ...
        sum((v90_w0.popVec(1 : end - 1 , hiv_ccSus) ...
        + v90_w0.popVec(2 : end , hiv_ccSus)) * 0.5 , 2) * fac;
    end
    vNo_wNoMort = sum(bsxfun(@times , vNo_wNoMortAge , wVec));
    v90_w20Mort = sum(bsxfun(@times , v90_w20MortAge , wVec));
    v90_w15Mort = sum(bsxfun(@times , v90_w15MortAge , wVec));
    v90_w10Mort = sum(bsxfun(@times , v90_w10MortAge , wVec));
    v90_wNoMort = sum(bsxfun(@times , v90_wNoMortAge , wVec));
    figure(102)
    subplot(3 , 2 , d)
    plot(tVec(2 : end) , vNo_wNoMort , tVec(2 : end) , v90_wNoMort , ...
        tVec(2 : end) , v90_w20Mort , tVec(2 : end) , v90_w15Mort , ...
        tVec(2 : end) , v90_w10Mort)
    title([tits{d} , ' Mortality'])
    xlabel('Year'); ylabel('Mortality per 100,000')
    legend('No vaccination' , 'No Waning' , '20 years' , '15 years' , '10 years' ,...
        'Location' , 'northeastoutside')
    % Reduction
    v90_wNoRed = (v90_wNoMort - vNo_wNoMort) ./ vNo_wNoMort * 100;
    v90_w20Red = (v90_w20Mort - vNo_wNoMort) ./ vNo_wNoMort * 100;
    v90_w15Red = (v90_w15Mort - vNo_wNoMort) ./ vNo_wNoMort * 100;
    v90_w10Red = (v90_w10Mort - vNo_wNoMort) ./ vNo_wNoMort * 100;

    figure(103)
    subplot(3 , 2 ,d)
    plot(tVec(2 : end) , v90_wNoRed , tVec(2 : end) , v90_w20Red , ...
        tVec(2 : end) , v90_w15Red , tVec(2 : end) , v90_w10Red)
    title([tits{d} , ' Mortality Reduction'])
    xlabel('Year'); ylabel('Reduction (%)')
    legend('No Waning' , '20 years' , '15 years' , '10 years' , ...
        'Location' , 'northeastoutside')
    axis([tVec(2) tVec(end) -100 0])

    T = table(tVec(2 : end)' , v90_w20Mort' , v90_w15Mort' , v90_w10Mort' , ...
        v90_wNoMort' , v90_wNoRed' , v90_w20Red' , v90_w15Red' , v90_w10Red');
    writetable(T , [filenames{d} , '_stand.csv'] , 'Delimiter' , ',')
end
%% Acute and CD4 > 500
vec = [2 : 3];
tit = 'Acute and CD4 > 500';
filename = 'Acute_CD4_500Mort';
for a = 1 : age
    hiv_ccSus = [toInd(allcomb(vec , 1 : viral , 1 : hpvTypes , 1 : 8 , 1 : periods , ...
        2 , a , 1 : risk)) ; toInd(allcomb(vec , 1 : viral , 1 : hpvTypes , ...
        9 : 10 , 1 : periods , 2 , a , 1 : risk))];
    
    vNo_wNoMortAge(a , :) = ...
        sum(sum(sum(v0_w0.ccDeath(2 : end , vec , : , : , a),2),3),4) ./ ...
        sum((v0_w0.popVec(1 : end - 1 , hiv_ccSus) ...
        + v0_w0.popVec(2 : end , hiv_ccSus)) * 0.5 , 2) * fac;
    
    v90_w20MortAge(a , :) = ...
        sum(sum(sum(v90_w20.ccDeath(2 : end , vec , : , : , a),2),3),4) ./ ...
        sum((v90_w20.popVec(1 : end - 1 , hiv_ccSus) ...
        + v90_w20.popVec(2 : end , hiv_ccSus)) * 0.5 , 2) * fac;
    
    v90_w15MortAge(a , :) = ...
        sum(sum(sum(v90_w15.ccDeath(2 : end , vec , : , : , a),2),3),4) ./ ...
        sum((v90_w15.popVec(1 : end - 1 , hiv_ccSus) ...
        + v90_w15.popVec(2 : end , hiv_ccSus)) * 0.5 , 2) * fac;
    
    v90_w10MortAge(a , :) = ...
        sum(sum(sum(v90_w10.ccDeath(2 : end , vec , : , : , a),2),3),4) ./ ...
        sum((v90_w10.popVec(1 : end - 1 , hiv_ccSus) ...
        + v90_w10.popVec(2 : end , hiv_ccSus)) * 0.5 , 2) * fac;
    
    v90_wNoMortAge(a , :) = ...
        sum(sum(sum(v90_w0.ccDeath(2 : end , vec , : , : , a),2),3),4) ./ ...
        sum((v90_w0.popVec(1 : end - 1 , hiv_ccSus) ...
        + v90_w0.popVec(2 : end , hiv_ccSus)) * 0.5 , 2) * fac;
end

vNo_wNoMort = sum(bsxfun(@times , vNo_wNoMortAge , wVec));
v90_w20Mort = sum(bsxfun(@times , v90_w20MortAge , wVec));
v90_w15Mort = sum(bsxfun(@times , v90_w15MortAge , wVec));
v90_w10Mort = sum(bsxfun(@times , v90_w10MortAge , wVec));
v90_wNoMort = sum(bsxfun(@times , v90_wNoMortAge , wVec));

figure(109)
plot(tVec(2 : end) , vNo_wNoMort , tVec(2 : end) , v90_wNoMort , ...
    tVec(2 : end) , v90_w20Mort , tVec(2 : end) , v90_w15Mort , ...
    tVec(2 : end) , v90_w10Mort)
title([tit , ' Mortality'])
xlabel('Year'); ylabel('Mortality per 100,000')
legend('No vaccination' , 'No Waning' , '20 years' , '15 years' , '10 years' ,...
    'Location' , 'northeastoutside')
% Reduction
v90_wNoRed = (v90_wNoMort - vNo_wNoMort) ./ vNo_wNoMort * 100;
v90_w20Red = (v90_w20Mort - vNo_wNoMort) ./ vNo_wNoMort * 100;
v90_w15Red = (v90_w15Mort - vNo_wNoMort) ./ vNo_wNoMort * 100;
v90_w10Red = (v90_w10Mort - vNo_wNoMort) ./ vNo_wNoMort * 100;

figure(110)
plot(tVec(2 : end) , v90_wNoRed , tVec(2 : end) , v90_w20Red , ...
    tVec(2 : end) , v90_w15Red , tVec(2 : end) , v90_w10Red)
title([tit , ' Mortality Reduction'])
xlabel('Year'); ylabel('Reduction (%)')
legend('No Waning' , '20 years' , '15 years' , '10 years' , ...
    'Location' , 'northeastoutside')
axis([tVec(2) tVec(end) -100 0])

T = table(tVec(2 : end)' , v90_w20Mort' , v90_w15Mort' , v90_w10Mort' , ...
    v90_wNoMort' , v90_wNoRed' , v90_w20Red' , v90_w15Red' , v90_w10Red');
writetable(T , [filename , '_stand.csv'] , 'Delimiter' , ',')

%%
% General susceptibles
v90_w0_incAge = zeros(age , length(tVec) - 1);
v90_w20_incAge = v90_w0_incAge;
v90_w15_incAge = v90_w0_incAge;
v90_w10_incAge = v90_w0_incAge;

for a = 1 : age
    ccSus = [toInd(allcomb(1 : disease , 1 : viral , 1 : hpvTypes , 1 : 4 , 1 : periods , ...
        2 , a , 1 : risk)) ; toInd(allcomb(1 : disease , 1 : viral , 1 : hpvTypes , ...
        9 : 10 , 1 : periods , 2 , a , 1 : risk))];
    v90_w0_incAge(a , :)  = sum(sum(sum(sum(v90_w0.newCC(2 : end , : , : , : , a)...
        ,2),3),4),5) ./ sum(v90_w0.popVec(1 : end - 1 , ccSus) , 2) * fac;
    v90_w20_incAge(a , :)  = sum(sum(sum(sum(v90_w20.newCC(2 : end , : , : , : , a)...
        ,2),3),4),5) ./ sum(v90_w20.popVec(1 : end - 1 , ccSus) , 2) * fac;
    v90_w15_incAge(a , :)  = sum(sum(sum(sum(v90_w15.newCC(2 : end , : , : , : , a)...
        ,2),3),4),5) ./ sum(v90_w15.popVec(1 : end - 1 , ccSus) , 2) * fac;
    v90_w10_incAge(a , :)  = sum(sum(sum(sum(v90_w10.newCC(2 : end , : , : , : , a)...
        ,2),3),4),5) ./ sum(v90_w10.popVec(1 : end - 1 , ccSus) , 2) * fac;
end

v90_w0_inc = sum(bsxfun(@times , v90_w0_incAge , wVec));
v90_w20_inc = sum(bsxfun(@times , v90_w20_incAge , wVec));
v90_w15_inc = sum(bsxfun(@times , v90_w15_incAge , wVec));
v90_w10_inc = sum(bsxfun(@times , v90_w10_incAge , wVec));

figure()
plot(tVec(2 : end) , i_genNo , tVec(2 : end) , v90_w0_inc , tVec(2 : end) , v90_w20_inc , ...
    tVec(2 : end) , v90_w15_inc , tVec(2 : end) , v90_w10_inc)
title('Vaccine Waning Period and General Cervical Cancer Incidence')
xlabel('Year'); ylabel('Incidence per 100,000')
legend('No vaccination' , 'No waning' , '20 years' , '15 years' , '10 years')

% Relative reduction
wNo = (v90_w0_inc - i_genNo) ./ i_genNo * 100;
w20 = (v90_w20_inc - i_genNo) ./ i_genNo * 100;
w15 = (v90_w15_inc - i_genNo) ./ i_genNo * 100;
w10 = (v90_w10_inc - i_genNo) ./ i_genNo * 100;
figure()
plot(tVec(2 : end) , wNo , tVec(2 : end) , w20 , ...
    tVec(2 : end) , w15 , tVec(2 : end) , w10)
axis([tVec(2) tVec(end) -100 0])
title('Vaccine Waning Period and Reduction of General Cervical Cancer Incidence')
xlabel('Year'); ylabel('Reduction (%)')
legend('No waning' , '20 years' , '15 years' , '10 years')
% Export general incidence/reduction as csv
T = table(tVec(2 : end)' , v90_w0_inc' , v90_w20_inc' , v90_w15_inc' , v90_w10_inc' , ...
    wNo' , w20' , w15' , w10');
writetable(T , 'GenInc_Waning_stand.csv' , 'Delimiter' , ',')
%% HIV-negative
% incidence

v90_w0_incNegAge = zeros(age , length(tVec) - 1);
v90_w20_incNegAge = v90_w0_incNegAge;
v90_w15_incNegAge = v90_w0_incNegAge;
v90_w10_incNegAge = v90_w0_incNegAge;

for a = 1 : age
    ccNegSus = [toInd(allcomb(1 , 1 : viral , 1 : hpvTypes , 1 : 4 , 1 : periods , ...
        2 , a , 1 : risk)) ; toInd(allcomb(1 , 1 : viral , 1 : hpvTypes , ...
        9 : 10 , 1 : periods , 2 , a , 1 : risk))];
    v90_w0_incNegAge(a , :)  = sum(sum(sum(v90_w0.newCC(2 : end , 1 , : , : , a)...
        ,2),3),4) ./ sum(v90_w0.popVec(1 : end - 1 , ccNegSus) , 2) * fac;
    v90_w20_incNegAge(a , :)  = sum(sum(sum(v90_w20.newCC(2 : end , 1 , : , : , a)...
        ,2),3),4) ./ sum(v90_w20.popVec(1 : end - 1 , ccNegSus) , 2) * fac;
    v90_w15_incNegAge(a , :)  = sum(sum(sum(v90_w15.newCC(2 : end , 1 , : , : , a)...
        ,2),3),4) ./ sum(v90_w15.popVec(1 : end - 1 , ccNegSus) , 2) * fac;
    v90_w10_incNegAge(a , :)  = sum(sum(sum(v90_w10.newCC(2 : end , 1 , : , : , a)...
        ,2),3),4) ./ sum(v90_w10.popVec(1 : end - 1 , ccNegSus) , 2) * fac;
end

v90_w0_incNeg = sum(bsxfun(@times , v90_w0_incNegAge , wVec));
v90_w20_incNeg = sum(bsxfun(@times , v90_w20_incNegAge , wVec));
v90_w15_incNeg = sum(bsxfun(@times , v90_w15_incNegAge , wVec));
v90_w10_incNeg = sum(bsxfun(@times , v90_w10_incNegAge , wVec));

figure()
plot(tVec(2 : end) , h_negNo , tVec(2 : end) , v90_w0_incNeg , tVec(2 : end) ,...
    v90_w20_incNeg , tVec(2 : end) , v90_w15_incNeg , tVec(2 : end) , v90_w10_incNeg)
title('Vaccine Waning Period and HIV- Cervical Cancer Incidence')
xlabel('Year'); ylabel('Incidence per 100,000')
legend('No vaccination' , 'No waning' , '20 years' , '15 years' , '10 years')

% Relative reduction
wNoNeg = (v90_w0_incNeg - h_negNo) ./ h_negNo * 100;
w20Neg = (v90_w20_incNeg - h_negNo) ./ h_negNo * 100;
w15Neg = (v90_w15_incNeg - h_negNo) ./ h_negNo * 100;
w10Neg = (v90_w10_incNeg - h_negNo) ./ h_negNo * 100;
figure()
plot(tVec(2 : end) , wNoNeg , tVec(2 : end) , w20Neg , ...
    tVec(2 : end) , w15Neg , tVec(2 : end) , w10Neg)
axis([tVec(2) tVec(end) -100 0])
title('Vaccine Waning Period and Reduction of HIV- Cervical Cancer Incidence')
xlabel('Year'); ylabel('Reduction (%)')
legend('No waning' , '20 years' , '15 years' , '10 years')
% Export general incidence/reduction as csv
T = table(tVec(2 : end)' , v90_w0_incNeg' , v90_w20_incNeg' , v90_w15_incNeg' , ...
    v90_w10_incNeg' , wNoNeg' , w20Neg' , w15Neg' , w10Neg');
writetable(T , 'HIVNeg_Waning_stand.csv' , 'Delimiter' , ',')
%% HIV-positive
%% Aggregated
v90_w0_incHiv = zeros(age , length(tVec) - 1);
v90_w20_incHiv = v90_w0_incHiv;
v90_w15_incHiv = v90_w0_incHiv;
v90_w10_incHiv = v90_w0_incHiv;
for a = 1 : age
    % Incidence
    hiv_ccSus = [toInd(allcomb(2 : 6 , 1 : viral , 1 : hpvTypes , 1 : 4 , 1 : periods , ...
        2 , a , 1 : risk)) ; toInd(allcomb(2 : 6 , 1 : viral , 1 : hpvTypes , ...
        9 : 10 , 1 : periods , 2 , a , 1 : risk))];
    v90_w0_incHiv(a , :)  = sum(sum(sum(v90_w0.newCC(2 : end , 2 : 6 , : , : , a)...
        ,2),3),4) ./ (0.5 * (sum(v90_w0.popVec(1 : end - 1 , hiv_ccSus) , 2)...
        + sum(v90_w0.popVec(2 : end , hiv_ccSus) , 2))) * fac;
    v90_w20_incHiv(a , :)  = sum(sum(sum(v90_w20.newCC(2 : end , 2 : 6 , : , : , a)...
        ,2),3),4) ./ (0.5 * (sum(v90_w20.popVec(1 : end - 1 , hiv_ccSus) , 2) ...
        + sum(v90_w20.popVec(2 : end , hiv_ccSus) , 2))) * fac;
    v90_w15_incHiv(a , :)  = sum(sum(sum(v90_w15.newCC(2 : end , 2 : 6 , : , : , a)...
        ,2),3),4) ./ (0.5 * (sum(v90_w15.popVec(1 : end - 1 , hiv_ccSus) , 2) ...
        + sum(v90_w15.popVec(2 : end , hiv_ccSus) , 2)))* fac;
    v90_w10_incHiv(a , :)  = sum(sum(sum(v90_w10.newCC(2 : end , 2 : 6 , : , : , a)...
        ,2),3),4) ./ (0.5 * (sum(v90_w10.popVec(1 : end - 1 , hiv_ccSus) , 2)...
        + sum(v90_w10.popVec(2 : end , hiv_ccSus) , 2)))* fac;
end

v90_w0_incHiv = sum(bsxfun(@times , v90_w0_incHiv , wVec));
v90_w20_incHiv = sum(bsxfun(@times , v90_w20_incHiv , wVec));
v90_w15_incHiv = sum(bsxfun(@times , v90_w15_incHiv , wVec));
v90_w10_incHiv = sum(bsxfun(@times , v90_w10_incHiv , wVec));

figure()
plot(tVec(2 : end) , hivAllIncNo , tVec(2 : end) , v90_w0_incHiv , tVec(2 : end) , ...
    v90_w20_incHiv , tVec(2 : end) , v90_w15_incHiv , tVec(2 : end) , v90_w10_incHiv)
title('Vaccine Waning Period and General Cervical Cancer Incidence in HIV+ (90% coverage)')
xlabel('Year'); ylabel('Incidence per 100,000')
legend('No vaccination' , 'No waning' , '20 years' , '15 years' , '10 years' , ...
    'Location' , 'northeastoutside')

% Relative reduction
wNoRed = (v90_w0_incHiv - hivAllIncNo) ./ hivAllIncNo * 100;
w20Red = (v90_w20_incHiv - hivAllIncNo) ./ hivAllIncNo * 100;
w15Red = (v90_w15_incHiv - hivAllIncNo) ./ hivAllIncNo * 100;
w10Red = (v90_w10_incHiv - hivAllIncNo) ./ hivAllIncNo * 100;
figure()
plot(tVec(2 : end) , wNoRed , tVec(2 : end) , w20Red , tVec(2 : end) , ...
    w15Red , tVec(2 : end) , w10Red)
title('Vaccine Waning Period and General Cervical Cancer Reduction in HIV+')
xlabel('Year'); ylabel('Reduction(%)')
axis([tVec(2) tVec(end) -100 0 ]);
legend('No waning' , '20 years' , '15 years' , '10 years' , ...
    'Location' , 'northeastoutside')
% Export general incidence/reduction as csv
T = table(tVec(2 : end)' ,hivAllIncNo' , v90_w0_incHiv' , v90_w20_incHiv' , ...
    v90_w15_incHiv' , v90_w10_incHiv' , wNoRed' , w20Red' , w15Red' , w10Red');
writetable(T , 'AllHivInc_Waning_stand.csv' , 'Delimiter' , ',')

%% By CD4
dVec = [2 : 6 , 10];
tits = {'Acute' , 'CD4 > 500' , 'CD4 500-350' , 'CD4 350-200' , 'CD4 < 200' , ...
    'ART'};
filenames = {'Acute' , 'CD4_500' , 'CD4_500_350' , 'CD4_350_200' , 'CD4_200' , ...
    'ART'};
v90_wNo_incCD4 = zeros(age , length(tVec) - 1);
v90_w20_incCD4 = v90_wNo_incCD4;
v90_w15_incCD4 = v90_wNo_incCD4;
v90_w10_incCD4 = v90_wNo_incCD4;
hivCCNo = v90_w10_incCD4;

for d = 1 : length(dVec)
    for a = 1 : age
        % Incidence
        hiv_ccSus = [toInd(allcomb(dVec(d) , 1 : viral , 1 : hpvTypes , 1 : 4 , 1 : periods , ...
            2 , a , 1 : risk)) ; toInd(allcomb(dVec(d) , 1 : viral , 1 : hpvTypes , ...
            9 : 10 , 1 : periods , 2 , a , 1 : risk))];
        v90_wNo_incCD4(a , :)  = sum(sum(v90_w0.newCC(2 : end , dVec(d) , : , : , a)...
            ,3),4) ./ sum(v90_w0.popVec(1 : end - 1 , hiv_ccSus) , 2) * fac;
        v90_w20_incCD4(a , :)  = sum(sum(v90_w20.newCC(2 : end , dVec(d) , : , : , a)...
            ,3),4) ./ sum(v90_w20.popVec(1 : end - 1 , hiv_ccSus) , 2) * fac;
        v90_w15_incCD4(a , :)  = sum(sum(v90_w15.newCC(2 : end , dVec(d) , : , : , a)...
            ,3),4) ./ sum(v90_w15.popVec(1 : end - 1 , hiv_ccSus) , 2) * fac;
        v90_w10_incCD4(a , :)  = sum(sum(v90_w10.newCC(2 : end , dVec(d) , : , : , a)...
            ,3),4) ./ sum(v90_w10.popVec(1 : end - 1 , hiv_ccSus) , 2) * fac;
        hivCCNo(a , :) = sum(sum(newCC_0(2 : end , dVec(d) , : , : , a),3),4) ...
            ./ sum(popNo(1 : end - 1 , hiv_ccSus) , 2) * fac;
        
    end
    
    v90_wNo_incCD4 = sum(bsxfun(@times , v90_wNo_incCD4 , wVec));
    v90_w20_incCD4 = sum(bsxfun(@times , v90_w20_incCD4 , wVec));
    v90_w15_incCD4 = sum(bsxfun(@times , v90_w15_incCD4 , wVec));
    v90_w10_incCD4 = sum(bsxfun(@times , v90_w10_incCD4 , wVec));
    
    % base (no vaccine)
    h_genNo = sum(bsxfun(@times , hivCCNo , wVec));
    %     hivCCNo = sum(sum(sum(newCC_0(: , dVec(d) , : , : , :),3),4),5);
    %     popNo_susHiv = sum(popNo(1 : end - 1 , hiv_ccSus) , 2);
    %     h_genNo = hivCCNo(2 : end) ./ popNo_susHiv .* fac;
    
    figure(100)
    subplot(3 , 2 , d)
    plot(tVec(2 : end) , h_genNo , tVec(2 : end) , v90_wNo_incCD4 , tVec(2 : end) , ...
        v90_w20_incCD4 , tVec(2 : end) , v90_w15_incCD4 , tVec(2 : end) , v90_w10_incCD4)
    title(['Vaccine Waning Period and CC Incidence in ' , tits{d}])
    xlabel('Year'); ylabel('Incidence per 100,000')
    legend('No vaccination' , 'No waning' , '20 years' , '15 years' , '10 years' , ...
        'Location' , 'northeastoutside')
    
    % Relative reduction
    wNoRedCD4 = (v90_wNo_incCD4 - h_genNo) ./ h_genNo * 100;
    w20RedCD4 = (v90_w20_incCD4 - h_genNo) ./ h_genNo * 100;
    w15RedCD4 = (v90_w15_incCD4 - h_genNo) ./ h_genNo * 100;
    w10RedCD4 = (v90_w10_incCD4 - h_genNo) ./ h_genNo * 100;
    figure(101)
    subplot(3 , 2 , d)
    plot(tVec(2 : end) , wNoRedCD4 , tVec(2 : end) , w20RedCD4 , tVec(2 : end) , ...
        w15RedCD4 , tVec(2 : end) , w10RedCD4)
    axis([tVec(2) tVec(end) -100 0 ]);
    title(['Vaccine Waning Period and CC Reduction in ' tits{d}])
    xlabel('Year'); ylabel('Reduction (%)')
    legend('No waning' , '20 years' , '15 years' , '10 years' , ...
        'Location' , 'northeastoutside')
    % Export general incidence/reduction as csv
    T = table(tVec(2 : end)' , v90_wNo_incCD4' , v90_w20_incCD4' , ...
        v90_w15_incCD4' , v90_w10_incCD4' , wNoRedCD4' , w20RedCD4' , w15RedCD4' , ...
        w10RedCD4');
    writetable(T , [filenames{d} , '_Waning_stand.csv'] , 'Delimiter' , ',')
end

%% Acute and CD4 > 500
vec = [2 : 3];
tit = 'Acute and  CD4 > 500';
filename= 'Acute_500';
% Incidence
for a = 1 : age
    hiv_ccSus = [toInd(allcomb(vec , 1 : viral , 1 : hpvTypes , 1 : 4 , 1 : periods , ...
        2 , 4 : age , 1 : risk)) ; toInd(allcomb(vec , 1 : viral , 1 : hpvTypes , ...
        9 : 10 , 1 : periods , 2 , 4 : age , 1 : risk))];
    v90_wNo_incCD4(a , :)  = sum(sum(sum(sum(v90_w0.newCC(2 : end , vec , : , : , :)...
        ,2),3),4),5) ./ sum(v90_w0.popVec(1 : end - 1 , hiv_ccSus) , 2) * fac;
    v90_w20_incCD4(a , :)  = sum(sum(sum(sum(v90_w20.newCC(2 : end , vec , : , : , :)...
        ,2),3),4),5) ./ sum(v90_w20.popVec(1 : end - 1 , hiv_ccSus) , 2) * fac;
    v90_w15_incCD4(a , :)  = sum(sum(sum(sum(v90_w15.newCC(2 : end , vec , : , : , :)...
        ,2),3),4),5) ./ sum(v90_w15.popVec(1 : end - 1 , hiv_ccSus) , 2) * fac;
    v90_w10_incCD4(a , :)  = sum(sum(sum(sum(v90_w10.newCC(2 : end , vec , : , : , :)...
        ,2),3),4),5) ./ sum(v90_w10.popVec(1 : end - 1 , hiv_ccSus) , 2) * fac;
    % base (no vaccine)
    hivCCNo = sum(sum(sum(sum(newCC_0(: , vec , : , : , :), 2), 3),4),5);
    popNo_susHiv = sum(popNo(1 : end - 1 , hiv_ccSus) , 2);
    h_genNo = hivCCNo(2 : end) ./ popNo_susHiv .* fac;
end

v90_wNo_incCD4 = sum(bsxfun(@times , v90_wNo_incCD4, wVec));
v90_w20_incCD4 = sum(bsxfun(@times , v90_w20_incCD4, wVec));
v90_w15_incCD4 = sum(bsxfun(@times , v90_w15_incCD4, wVec));
v90_w10_incCD4 = sum(bsxfun(@times , v90_w10_incCD4, wVec));

figure(111)
plot(tVec(2 : end) , h_genNo , tVec(2 : end) , v90_wNo_incCD4 , tVec(2 : end) , ...
    v90_w20_incCD4 , tVec(2 : end) , v90_w15_incCD4 , tVec(2 : end) , v90_w10_incCD4)
title(['Vaccine Waning Period and CC Incidence in ' , tit])
xlabel('Year'); ylabel('Incidence per 100,000')
legend('No vaccination' , 'No waning' , '20 years' , '15 years' , '10 years' , ...
    'Location' , 'northeastoutside')

% Relative reduction
wNoRedCD4 = (v90_wNo_incCD4' - h_genNo) ./ h_genNo * 100;
w20RedCD4 = (v90_w20_incCD4' - h_genNo) ./ h_genNo * 100;
w15RedCD4 = (v90_w15_incCD4' - h_genNo) ./ h_genNo * 100;
w10RedCD4 = (v90_w10_incCD4' - h_genNo) ./ h_genNo * 100;
figure(101)
plot(tVec(2 : end) , wNoRedCD4 , tVec(2 : end) , w20RedCD4 , tVec(2 : end) , ...
    w15RedCD4 , tVec(2 : end) , w10RedCD4)
axis([tVec(2) tVec(end) -100 0 ]);
title(['Vaccine Waning Period and CC Reduction in ' tit])
xlabel('Year'); ylabel('Reduction (%)')
legend('No waning' , '20 years' , '15 years' , '10 years' , ...
    'Location' , 'northeastoutside')
% Export general incidence/reduction as csv
T = table(tVec(2 : end)' , v90_wNo_incCD4' , v90_w20_incCD4' , ...
    v90_w15_incCD4' , v90_w10_incCD4' , wNoRedCD4 , w20RedCD4 , w15RedCD4 , ...
    w10RedCD4);
writetable(T , [filename , '_Waning_stand.csv'] , 'Delimiter' , ',')
