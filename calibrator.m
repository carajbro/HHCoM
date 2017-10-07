function negSumLogL = calibrator(initParams)
hpvOn = 1;
hivOn = 1;
% Load up parameters and data
load('popData')
load('general');
load('settings');
load('mixInfectIndices')
load('vlAdvancer')
load('fertMat')
load('hivFertMats')
load('deathMat')
load('circMat')
load('vaxer')
load('mixInfectParams');
load('hpvData')
load('popData')
load('HIVParams')
load('hivIndices')
load('hpvIndices')
load('ager')
load('vlBeta')
load('hpvTreatIndices')
load('calibData')
load('calibParams')
load('vaxInds')
import java.util.LinkedList
vaxerAger = ager;
vaxRate = 0;
%% Initial population

startYear = 1975;
endYear = 2013; % run to 2013 for calibration
mInit = popInit(: , 1);
MsumInit = sum(mInit);

fInit = popInit(: , 2);
FsumInit = sum(fInit);

MpopStruc = riskDistM;
FpopStruc = riskDistF;

mPop = zeros(age , risk);
fPop = mPop;

for i = 1 : age
    mPop(i , :) = MpopStruc(i, :).* mInit(i) / 1.5;
    fPop(i , :) = FpopStruc(i, :).* fInit(i) / 1.5;
end

dim = [disease , viral , hpvTypes , hpvStates , periods , gender , age ,risk];
initPop = zeros(dim);
initPop(1 , 1 , 1 , 1 , 1 , 1 , : , :) = mPop;
initPop(1 , 1 , 1 , 1 , 1 , 2 , : , :) = fPop;

dim = [disease , viral , hpvTypes , hpvStates , periods , gender , age ,risk];
initPop = zeros(dim);
initPop(1 , 1 , 1 , 1 , 1 , 1 , : , :) = mPop;
initPop(1 , 1 , 1 , 1 , 1 , 2 , : , :) = fPop;
initPop_0 = initPop;
if hivOn
    %     toInfectM = (sum(mPop(:)) + sum(fPop(:))) * 0.001* 0.5;
    %     toInfectF = (sum(mPop(:)) + sum(fPop(:))) * 0.001 * 0.5;
    %     initPop(3 : 4 , 2 : 4 , 1 , 1 , 1 , 1 , 5 , 2) = 1; % initial HIV infected males (acute)
    %     initPop(3 : 4 , 2 : 4 , 1 , 1 , 1 , 2 , 4 , 2) = 1; % initial HIV infected females (acute)
    initPop(3 , 2 , 1 , 1 , 1 , 1 , 4 : 6 , 2 : 3) = 0.006 / 2 .* ...
        initPop_0(1 , 1 , 1 , 1 , 1 , 1 , 4 : 6 , 2 : 3); % initial HIV infected male (4% prevalence)
    initPop(1 , 1 , 1 , 1 , 1 , 1 , 4 : 6 , 2 : 3) = ...
        initPop_0(1 , 1 , 1 , 1 , 1 , 1 , 4 : 6 , 2 : 3) .* (1 - 0.006 / 2); % moved to HIV infected
    initPop(3 , 2 , 1 , 1 , 1 , 2 , 4 : 6 , 2 : 3) = 0.006 / 2 .*...
        initPop_0(1 , 1 , 1 , 1 , 1 , 2 , 4 : 6 , 2 : 3); % initial HIV infected female (4% prevalence)
    initPop(1 , 1 , 1 , 1 , 1 , 2 , 4 : 6 , 2 : 3) = ...
        initPop_0(1 , 1 , 1 , 1 , 1 , 2 , 4 : 6 , 2 : 3) .* (1 - 0.006 / 2); % moved to HIV infected

        if hpvOn
            initPopHiv_0 = initPop;
            % HPV infected HIV+
            % females
            initPop(3 , 2 , 1 , 1 , 1 , 2 , 4 : 6 , 1 : 3) = 0.45 .* ...
                initPopHiv_0(3 , 2 , 1 , 1 , 1 , 2 , 4 : 6 , 1 : 3);

            % males
            initPop(3 , 2 , 1 , 1 , 1 , 1 , 4 : 6 , 1 : 3) = 0.45 .* ...
                initPopHiv_0(3 , 2 , 1 , 1 , 1 , 1 , 4 : 6 , 1 : 3);

            for h = 2 : 3
                % females
                initPop(3 , 2 , h , 1 , 1 , 2 , 4 : 6 , 1 : 3) = 0.55 / 2 .* ...
                    initPopHiv_0(3 , 2 , 1 , 1 , 1 , 2 , 4 : 6 , 1 : 3);
               % males
                initPop(3 , 2 , h , 1 , 1 , 1 , 4 : 6 , 1 : 3) = 0.55 / 2 .* ...
                    initPopHiv_0(3 , 2 , 1 , 1 , 1 , 1 , 4 : 6 , 1 : 3);
            end
        end
end
assert(~any(initPop(:) < 0) , 'Some compartments negative after seeding HIV infections.')

if hpvOn
    % initPop(1 , 1 , 2 : 4 , 1 , 1 , : , 4 : 9 , :) = 2; % initial HPV hr and lr infecteds (test)
    infected = initPop_0(1 , 1 , 1 , 1 , 1 , : , 6 : 9 , :) * 0.30; % try 30% intial HPV prevalence among age groups 6 - 9 (sexually active)
    initPop(1 , 1 , 1 , 1 , 1 , : , 6 : 9 , :) = ...
        initPop_0(1 , 1 , 1 , 1 , 1 , : , 6 : 9 , :) - infected;
    infected45 = initPop_0(1 , 1 , 1 , 1 , 1 , : , 4 : 5 , :) * 0.60; %try 60% initial HPV prevalence among age groups 4 - 5 (more sexually active)
    initPop(1 , 1 , 1 , 1 , 1 , : , 4 : 5 , :) = ...
        initPop_0(1 , 1 , 1 , 1 , 1 , : , 4 : 5 , :) - infected45;
    for h = 2 : 3
        initPop(1 , 1 , h , 1 , 1 , : , 6 : 9 , :) = infected ./ 2;
        initPop(1 , 1 , h , 1 , 1 , : , 4 : 5 , :) = infected45 ./ 2;
        initPop(1 , 1 , h , 3 , 1 , : , 6 : 13 , :) = ...
            initPop_0(1 , 1 , 1 , 1 , 1 , : , 6 : 13 , :) .* 0.07 ./ 2;
        initPop(1 , 1 , h , 4 , 1 , : , 6 : 13 , :) = ...
            initPop_0(1 , 1 , 1 , 1 , 1 , : , 6 : 13 , :) .* 0.03 ./ 2;
        initPop(1 , 1 , 1 , 1 , 1 , : , 6 : 13 , :) = ...
            initPop_0(1 , 1 , 1 , 1 , 1 , : , 6 : 13 , :) * 0.9 ./ 2;
    end
    initPop = max(initPop , 0);
end
assert(~any(initPop(:) < 0) , 'Some compartments negative after seeding HPV infections.')

% Intervention start years
circStartYear = 1990;
vaxStartYear = 2017;

% betaHIVM2F(a , : , :) = 1 - (bsxfun(@power, 1 - betaHIV_M2F , femaleActs(a , :)')); % HIV(-) females
%% calibration parameters
kCin2_Cin3(: , 1) = initParams(1 : age);
kCin3_Cin2(: , 1) = initParams(age + 1 : 2 * age);
kCC_Cin3(: , 1) = initParams(2 * age + 1 : 3 * age);
kCin2_Cin3(: , 2) = initParams(3 * age + 1 : 4 * age);
kCin3_Cin2(: , 2) = initParams(4 * age + 1 : 5 * age);
kCC_Cin3(: , 2) = initParams(5 * age + 1 : 6 * age);
kCin2_Cin3(: , 3) = initParams(6 * age + 1 : 7 * age);
kCin3_Cin2(: , 3) = initParams(7 * age + 1 : 8 * age);
kCC_Cin3(: , 3) = initParams(8 * age + 1 : 9 * age);
rImmuneHiv = initParams(9 * age + 1 : 9 * age + 1 + 3);
c3c2Mults = initParams(9 * age + 5 : 9 * age + 8);
c2c1Mults = initParams(9 * age + 9 : 9 * age + 12);
artHpvMult = initParams(9 * age + 13);
perPartnerHpv = initParams(9 * age + 14);


%% Simulation variable preparation
OMEGA(1 : 3) = 0;
OMEGA(4 : age) = logspace(-log(1 - 0.05) , - log(1 - 0.4) , age - 3);
hivPositiveArtAll = sort(toInd(allcomb(10 , 6 , 1 : hpvStates , 1 : hpvTypes , ...
    1 : periods , 1 : gender  , 1 : age , 1 : risk)));
fImm(1 : age) = 1; % all infected individuals who clear HPV get natural immunity
lambdaMultImm(1 : 4) = 1 - 0.01;
lambdaMultImm(5 : 10) = 1 - logspace(log10(0.01) , log10(0.1) , 6);
lambdaMultImm(11 : age) = lambdaMultImm(10);
lambdaMultVax = 1 - (0.9 * 0.8);
% Initialize vectors
timeStep = 1 / stepsPerYear;
years = endYear - startYear;
s = 1 : timeStep : years + 1; % stepSize and steps calculated in loadUp.m
artDistMat = zeros(size(prod(dim) , 20)); % initialize artDistMat to track artDist over past 20 time steps
popVec = spalloc(years / timeStep , prod(dim) , 10 ^ 8);
popIn = reshape(initPop , prod(dim) , 1); % initial population to "seed" model
newHiv = zeros(length(s) - 1 , gender , age , risk);
newHpv = zeros(length(s) - 1 , gender , disease , age , risk);
newImmHpv = newHpv;
newVaxHpv = newHpv;
newCC = zeros(length(s) - 1 , disease , viral , hpvTypes , age);
ccDeath = newCC;
hivDeaths = zeros(length(s) - 1 , age);
deaths = popVec;
artTreatTracker = zeros(length(s) - 1 , disease , viral , gender , age , risk);
popVec(1 , :) = popIn;
k = cumprod([disease , viral , hpvTypes , hpvStates , periods , gender , age]);
artDist = zeros(disease , viral , gender , age , risk); % initial distribution of inidividuals on ART = 0

%% Simulation
for i = 2 : length(s) - 1
    tic
    year = startYear + s(i) - 1;
    currStep = round(s(i) * stepsPerYear);
    tspan = [s(i) , s(i + 1)]; % evaluate diff eqs over one time interval
    popIn = popVec(i - 1 , :);
    if hpvOn
        hystOption = 'on';
        [~ , pop , newCC(i , : , : , : , :) , ccDeath(i , : , : , : , :)] ...
            = ode4xtra(@(t , pop) ...
            hpv(t , pop , immuneInds , infInds , cin1Inds , ...
            cin2Inds , cin3Inds , normalInds , ccInds , ccRegInds , ccDistInds , ...
            kInf_Cin1 , kCin1_Cin2 , kCin2_Cin3 , ...
            kCin2_Cin1 , kCin3_Cin2 , kCC_Cin3 , kCin1_Inf  ,...
            rNormal_Inf , hpv_hivClear , c3c2Mults , ...
            c2c1Mults , fImm , kRL , kDR , muCC , disease , viral , age , hpvTypes , ...
            rImmuneHiv , vaccinated , hystOption) , tspan , popIn);
        popIn = pop(end , :);

        %                 [~ , pop] = ode4x(@(t , pop) hpvTreat(t , pop , disease , viral , hpvTypes , age , ...
        %                     periods , detCC , hivCC , muCC , ccRInds , ccSusInds , ...
        %                     hystPopInds , screenFreq , screenCover , hpvSens , ccTreat , ...
        %                     cytoSens , cin1Inds , cin2Inds , cin3Inds ,  normalInds , getHystPopInds ,...
        %                     OMEGA , leep , hystOption , year) , tspan , pop(end , :));
    end
    if hpvOn
        [~ , pop , newHpv(i , : , : , : , :) , newImmHpv(i , : , : , : , :) , ...
            newVaxHpv(i , : , : , : , :)] = ...
            ode4xtra(@(t , pop) mixInfectHPV(t , pop , currStep , ...
            gar , perPartnerHpv , lambdaMultImm , lambdaMultVax , artHpvMult , epsA_vec , epsR_vec , yr , modelYr1 , ...
            circProtect , condProtect , condUse , actsPer , partnersM , partnersF , ...
            hpv_hivMult , hpvSus , hpvImm , hpvVaxd , toHpv , toHpv_ImmVax , ...
            disease , viral , gender , age , risk , hpvStates , hpvTypes , ...
            hrInds , lrInds , hrlrInds,  k , periods , startYear , stepsPerYear , year) , tspan , popIn);
        popIn = pop(end , :); % for next mixing and infection module
        if any(pop(end , :) < 0)
            disp('After mixInfectHPV')
            break
        end
    end

    if hivOn
        [~ , pop , newHiv(i , : , : , :)] = ...
            ode4xtra(@(t , pop) mixInfectHIV(t , pop , currStep , ...
            gar , hivSus , toHiv , mCurr , fCurr , ...
            mCurrArt , fCurrArt ,epsA_vec , epsR_vec , yr , modelYr1 , ...
            circProtect , condProtect , condUse , actsPer , partnersM , partnersF , ...
            betaHIVF2M , betaHIVM2F , disease , viral , gender , age , risk , ...
            hpvStates , hpvTypes , k , periods , startYear , stepsPerYear , year) , tspan , popIn);
        if any(pop(end , :) < 0)
            disp('After mixInfectHIV')
            break
        end
    end

    if hivOn
        [~ , pop , hivDeaths(i , :) , artTreat] =...
            ode4xtra(@(t , pop) hiv(t , pop , vlAdvancer , artDist , muHIV , ...
            kCD4 , disease , viral , gender , age , risk , k , hivInds , ...
            stepsPerYear , year) , tspan , pop(end , :));
        artTreatTracker(i , : , : , : , :  ,:) = artTreat;
        if any(pop(end , :) < 0)
            disp('After hiv')
            break
        end
        %             [~ , artTreat] = ode4x(@(t , artDist) treatDist(t , popCopy(end , :) , year) , tspan , artDist);
        %             if size(artDistList) >= 20
        %                 artDistList.remove(); % remove earlier artDist matrix more than "20 time steps old"
        %             else
        %                 artDistList.add(artTreat);
        %             end
        %             artDist = calcDist(artDistList);
    end


    [~ , pop , deaths(i , :)] = ode4xtra(@(t , pop) bornAgeDie(t , pop , ...
        ager , year , currStep , age , fertility , fertMat , hivFertPosBirth ,...
        hivFertNegBirth , deathMat , circMat , vaxerAger , MTCTRate , circStartYear , ...
        vaxStartYear , vaxRate , startYear , endYear , stepsPerYear) , tspan , pop(end , :));
    if any(pop(end , :) < 0)
        disp('After bornAgeDie')
        break
    end
    % add results to population vector
    popVec(i , :) = pop(end , :)';
end
popLast = popVec(end , :);

popVec = sparse(popVec); % compress population vectors

negSumLogL = likeFun(popVec , cinPos2008_obs , cinNeg2008_obs ,...
    hpv_hiv_2008_obs , hpv_hivNeg_2008_obs , hpv_hiv_obs , hpv_hivNeg_obs , ...
	hivPrevM_obs , hivPrevF_obs , disease , viral , gender , age , risk , ...
	hpvTypes , hpvStates , periods , startYear , stepsPerYear);

