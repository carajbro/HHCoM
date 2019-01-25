function negSumLogL = calibratorAll(initParams)

%% Load parameters
paramDir = [pwd ,'\Params\'];
load([paramDir,'settings'])
load([paramDir,'popData'])
load([paramDir,'HIVParams'])
load([paramDir,'general'])
load([paramDir,'mixInfectParams'])
load([paramDir,'vlBeta'])
load([paramDir,'hpvData'])
load([paramDir,'calibData'])
load([paramDir,'mixInfectIndices'])
load([paramDir,'hivIndices'])
load([paramDir,'hpvIndices'])
load([paramDir,'hpvTreatIndices'])
load([paramDir,'ageRiskInds'])
load([paramDir,'vaxInds'])
load([paramDir,'ager'])
load([paramDir,'vlAdvancer'])
load([paramDir,'fertMat'])
load([paramDir,'hivFertMats'])
load([paramDir,'fertMat2'])
load([paramDir,'hivFertMats2'])
load([paramDir,'vaxer'])
load([paramDir,'circMat'])
load([paramDir,'deathMat'])

import java.util.LinkedList

hyst = 'off';
hpvOn = 1;
hivOn = 1;

startYear = 1980;
endYear = 2015; % run to 2015 for calibration
years = endYear - startYear;
circStartYear = 1990;
vaxStartYear = 2017;

%% Initial population
mInit = popInit(: , 1);
fInit = popInit(: , 2);

riskDistF = riskDistM;

MpopStruc = riskDistM;
FpopStruc = riskDistF;

mPop = zeros(age , risk);
fPop = mPop;

for i = 1 : age
    mPop(i , :) = MpopStruc(i, :).* mInit(i) ./ 1.25;
    fPop(i , :) = FpopStruc(i, :).* fInit(i) ./ 1.25;
end

dim = [disease , viral , hpvTypes , hpvStates , periods , gender , age ,risk];
initPop = zeros(dim);
initPop(1 , 1 , 1 , 1 , 1 , 1 , : , :) = mPop; % HIV-, acute infection, HPV Susceptible, no precancer, __, male
initPop(1 , 1 , 1 , 1 , 1 , 2 , : , :) = fPop; % HIV-, acute infection, HPV Susceptible, no precancer, __, female
initPop_0 = initPop;
if hivOn
    initPop(3 , 2 , 1 , 1 , 1 , 1 , 4 : 6 , 2 : 3) = 0.005 / 2 .* ...
        initPop_0(1 , 1 , 1 , 1 , 1 , 1 , 4 : 6 , 2 : 3); % initial HIV infected male (age groups 4-6, med-high risk) (% prevalence)
    initPop(1 , 1 , 1 , 1 , 1 , 1 , 4 : 6 , 2 : 3) = ...
        initPop_0(1 , 1 , 1 , 1 , 1 , 1 , 4 : 6 , 2 : 3) .* (1 - 0.005 / 2); % moved to HIV infected
    initPop(3 , 2 , 1 , 1 , 1 , 2 , 4 : 6 , 2 : 3) = 0.005 / 2 .*...
        initPop_0(1 , 1 , 1 , 1 , 1 , 2 , 4 : 6 , 2 : 3); % initial HIV infected female (% prevalence)
    initPop(1 , 1 , 1 , 1 , 1 , 2 , 4 : 6 , 2 : 3) = ...
        initPop_0(1 , 1 , 1 , 1 , 1 , 2 , 4 : 6 , 2 : 3) .* (1 - 0.005 / 2); % moved to HIV infected

        if hpvOn
            initPopHiv_0 = initPop;
            % HIV+ not infected by HPV
            % females
            initPop(3 , 2 , 1 , 1 , 1 , 2 , 4 : 6 , 1 : 3) = 0.3 .* ...
                initPopHiv_0(3 , 2 , 1 , 1 , 1 , 2 , 4 : 6 , 1 : 3);

            % males
            initPop(3 , 2 , 1 , 1 , 1 , 1 , 4 : 6 , 1 : 3) = 0.3 .* ...
                initPopHiv_0(3 , 2 , 1 , 1 , 1 , 1 , 4 : 6 , 1 : 3);

            for h = 2
                % HIV+ infected by HPV
                % females
                initPop(3 , 2 , h , 1 , 1 , 2 , 4 : 6 , 1 : 3) = 0.7 .* ...
                    initPopHiv_0(3 , 2 , 1 , 1 , 1 , 2 , 4 : 6 , 1 : 3);
                % males
                initPop(3 , 2 , h , 1 , 1 , 1 , 4 : 6 , 1 : 3) = 0.7 .* ...
                    initPopHiv_0(3 , 2 , 1 , 1 , 1 , 1 , 4 : 6 , 1 : 3);
            end
        end
end
assert(~any(initPop(:) < 0) , 'Some compartments negative after seeding HIV infections.')

if hpvOn
    infected = initPop_0(1 , 1 , 1 , 1 , 1 , : , 4 : 9 , :) * 0.20; % 20% initial HPV prevalence among age groups 4 - 9 (sexually active) (HIV-)
    initPop(1 , 1 , 1 , 1 , 1 , : , 4 : 9 , :) = ...
        initPop_0(1 , 1 , 1 , 1 , 1 , : , 4 : 9 , :) - infected; % moved from HPV-

    % Omni-HPV type (transition rates weighted by estimated prevalence in population)
    initPop(1 , 1 , 2 , 1 , 1 , : , 4 : 9 , :) = infected; % moved to HPV+
end
assert(~any(initPop(:) < 0) , 'Some compartments negative after seeding HPV infections.')

%% Calibration parameters
epsA = initParams(1:3); 
epsR = initParams(4:6); 
prepOut = initParams(7);
%(8):       artOut, [1x1], (0.0 to 1.0), reset in hiv2a to 0
%(9:56):    maleActs, [age,risk], (0.0 to 365) 
%(57:104):  femaleActs, [age,risk], (0.0 to 365)
%(105):     perPartnerHpv, [1x1], (0.0 to 1.0)
%(106):     perPartnerHpv_lr, val, (0.0 to 1.0)
%(107):     perPartnerHpv_nonV, val, (0.0 to 1.0)
%(108:111): hpv_hivMult, [CD4x1], (0.0 to 1.0) 
%(112:127): kCin1_Inf, [agex1], init, (/10 to x10) or (0.0 to 1.0)
%(128:143): kCin2_Cin1, [agex1], init, (/10 to x10)
%(144:159): kCin3_Cin2, [agex1], init, (/10 to x10)
%(160:175): kCC_Cin3, [agex1], init, (/10 to x10)
%(176:191): rNormal_Inf, [agex1], init, (/10 to x10)
%(192:207): kInf_Cin1, [agex1], init, (/10 to x10)
%(208:223): kCin1_Cin2, [agex1], init, (/10 to x10)
%(224:239): kCin2_Cin3, [agex1], init, (/10 to x10)
%(240:243): hpv_hivClear, [CD4x1], (0.0 to 1.0)
%(244:247): rImmuneHiv, [CD4x1], (0.0 to 1.0)
%(248:251): c3c2Mults, [CD4x1], init, (all ones to x10)
%(252:255): c2c1Mults, [CD4x1], init, (all ones to x10)
%(256:271): lambdaMultImm, [agex1], (0.0 to 1.0)
%(272):     kRL, [1x1], (0.0 to 1.0)
%(273):     kDR, [1x1], (0.0 to 1.0)
%(274:276): kCCDet, [3x1], (0.0 to 1.0)
%(277:308): kCD4, [genderxvlxcd4], (0.0 to 10.0)
%(309:340): kVL, [genderxcd4xvl], (0.0 to 10.0)
%(341:342): maxRateM_vec,[2x1], (0.0 to 1.0), reset in mainCalibrated
%(343:344): maxRateF_vec, [2x1], (0.0 to 1.0), reset in mainCalibrated
%(345):     artHpvMult, [1x1], (1.0 to x10)

partnersM(4 , :) = partnersM(4 , :) .* [1.25 , 1.75 , 1.75];
partnersF(4 , :) = partnersF(4 , :) .* [1.25 , 1.75 , 1.75];
partnersM(5 , :) = partnersM(5 , :) .* [1.25 , 1.5 , 1.75];
partnersF(5 , :) = partnersF(5 , :) .* [1.25 , 1.5 , 1.75];

femaleActs(4 : 5 , :) = femaleActs(4 : 5 , :) .* 1.2 ;
femaleActs(6 : 10 , :) = femaleActs(6 : 10 , :) .* 0.9;
maleActs(4 : 5 , :) = maleActs(4 : 5 , :);

for i = 0 : 2
    maleActs(: , i + 1) = maleActs(: , i + 1) .* initParams(39 + i);
    femaleActs(: , i + 1) = femaleActs(: , i + 1) .* initParams(42 + i);
end

for i = 0 : 2
    partnersM(: , i + 1) = partnersM(: , i + 1) .* initParams(45 + i);
    partnersF(: , i + 1) = partnersF(: , i + 1) .* initParams(48 + i);
end

for a = 1 : age
    betaHIVF2M(a , : , :) = 1 - (bsxfun(@power, 1 - betaHIV_F2M , maleActs(a , :)')); % HIV(-) males
    betaHIVM2F(a , : , :) = 1 - (bsxfun(@power, 1 - betaHIV_M2F , femaleActs(a , :)')); % HIV(-) females
end
betaHIVM2F = permute(betaHIVM2F , [2 1 3]); % risk, age, vl
betaHIVF2M = permute(betaHIVF2M , [2 1 3]); % risk, age, vl













%% Simulation parameters
fImm(1 : age) = 1; % all infected individuals who clear HPV get natural immunity

lambdaMultVax = ones(age , 2);

% Initialize vectors
timeStep = 1 / stepsPerYear;

s = 1 : timeStep : years + 1; % stepSize and steps calculated in loadUp.m
artDistMat = zeros(size(prod(dim) , 20)); % initialize artDistMat to track artDist over past 20 time steps
popVec = spalloc(years / timeStep , prod(dim) , 10 ^ 8);
popIn = reshape(initPop , prod(dim) , 1); % initial population to "seed" model
newHiv = zeros(length(s) - 1 , gender , age , risk);
newHpv = zeros(length(s) - 1 , gender , disease , age , risk);
newImmHpv = newHpv;
newVaxHpv = newHpv;
newCC = zeros(length(s) - 1 , disease , hpvTypes , age);
ccDeath = newCC;
ccTreated = zeros(length(s) - 1 , disease , hpvTypes , age , 3); % 3 cancer stages: local, regional, distant
vaxd = zeros(length(s) - 1 , 1);
hivDeaths = zeros(length(s) - 1 , gender , age);
deaths = popVec;
artTreatTracker = zeros(length(s) - 1 , disease , viral , gender , age , risk);
popVec(1 , :) = popIn;
k = cumprod([disease , viral , hpvTypes , hpvStates , periods , gender , age]);
artDist = zeros(disease , viral , gender , age , risk); % initial distribution of inidividuals on ART = 0


vaxRate = 0;



maxRateM1 = maxRateM_vec(1);
maxRateM2 = maxRateM_vec(2);
maxRateF1 = maxRateF_vec(1);
maxRateF2 = maxRateF_vec(2);

%% Simulation
for i = 2 : length(s) - 1
    tic
    year = startYear + s(i) - 1;
    currStep = round(s(i) * stepsPerYear);
    tspan = [s(i) , s(i + 1)]; % evaluate diff eqs over one time interval
    popIn = popVec(i - 1 , :);

    if hpvOn
        hystOption = 'on';
        [~ , pop , newCC(i , : , : , :) , ccDeath(i , : , : , :) , ...
            ccTreated(i , : , : , : , :)] ...
            = ode4xtra(@(t , pop) ...
            hpvCCdet(t , pop , immuneInds , infInds , cin1Inds , ...
            cin2Inds , cin3Inds , normalInds , ccInds , ccRegInds , ccDistInds , ...
            ccTreatedInds , ccLocDetInds , ccRegDetInds , ccDistDetInds ,...
            kInf_Cin1 , kCin1_Cin2 , kCin2_Cin3 , ...
            kCin2_Cin1 , kCin3_Cin2 , kCC_Cin3 , kCin1_Inf  ,...
            rNormal_Inf , hpv_hivClear , c3c2Mults , ...
            c2c1Mults , fImm , kRL , kDR , muCC , muCC_det , kCCDet , ...
            disease , viral , age , hpvTypes , ...
            rImmuneHiv , vaccinated , hystOption) , tspan , popIn);
        popIn = pop(end , :);
        if any(pop(end , :) <  0)
            disp('After hpv')
            break
        end

    end

    [~ , pop , newHpv(i , : , : , : , :) , newImmHpv(i , : , : , : , :) , ...
        newVaxHpv(i , : , : , : , :) , newHiv(i , : , : , :)] = ...
        ode4xtra(@(t , pop) mixInfect(t , pop , currStep , ...
        gar , perPartnerHpv , perPartnerHpv_lr , perPartnerHpv_nonV , ...
        lambdaMultImm , lambdaMultVax , artHpvMult , epsA_vec , epsR_vec , yr , modelYr1 , ...
        circProtect , condProtect , condUse , actsPer , partnersM , partnersF , ...
        hpv_hivMult , hpvSus , hpvImm , toHpv_Imm , hpvVaxd , hpvVaxd2 , toHpv , toHpv_ImmVax , ...
        toHpv_ImmVaxNonV , hivSus , toHiv , mCurr , fCurr , mCurrArt , fCurrArt , ...
        betaHIVF2M , betaHIVM2F , disease , viral , gender , age , risk , hpvStates , hpvTypes , ...
        hrInds , lrInds , hrlrInds , periods , startYear , stepsPerYear , year) , tspan , popIn);
    popIn = pop(end , :); % for next mixing and infection module
    if any(pop(end , :) < 0)
        disp('After mixInfect')
        break
    end

    if hivOn
        [~ , pop , hivDeaths(i , : , :) , artTreat] =...
            ode4xtra(@(t , pop) hiv2a(t , pop , vlAdvancer , artDist , muHIV , ...
            kCD4 ,  maxRateM1 , maxRateM2 , maxRateF1 , maxRateF2 , disease , ...
            viral , gender , age , risk , k , hivInds , ...
            stepsPerYear , year) , tspan , pop(end , :));
        artTreatTracker(i , : , : , : , :  ,:) = artTreat;
        if any(pop(end , :) < 0)
            disp('After hiv')
            break
        end
    end

    [~ , pop , deaths(i , :) ] = ode4xtra(@(t , pop) ...
        bornAgeDieRisk(t , pop , year , currStep ,...
        gender , age , risk , fertility , fertMat , fertMat2 , hivFertPosBirth ,...
        hivFertNegBirth , hivFertPosBirth2 , hivFertNegBirth2 , deathMat , circMat , ...
        MTCTRate , circStartYear , ageInd , riskInd , riskDist , startYear , ...
        endYear, stepsPerYear) , tspan , pop(end , :));
    if any(pop(end , :) < 0)
        disp('After bornAgeDieRisk')
        break
    end
    % add results to population vector
    popVec(i , :) = pop(end , :)';
end
popLast = popVec(end , :);

popVec = sparse(popVec); % compress population vectors

negSumLogL = likeFun(popVec , newCC , cinPos2014_obs , cinNeg2014_obs ,...
    hpv_hiv_2008_obs , hpv_hivNeg_2008_obs , hpv_hiv_obs , hpv_hivNeg_obs , ...
	hivPrevM_obs , hivPrevF_obs , disease , viral , gender , age , risk , ...
	hpvTypes , hpvStates , periods , startYear , stepsPerYear);
