% Load parameters and other input data. Accepts steps per year as an
% argument
function[] = loadUp(stepsPerYear)
load('settings')
%% import and save population parameters
file = [pwd , '\Config\PopData.xlsx'];
disp(['Loading data from ' , file , '...']);
disp('This may take a couple seconds...');
% demographic data
popInit = xlsread(file , 'Demographics' , 'B2:C17'); % [age x gender]; initial population
riskDistM = xlsread(file , 'Demographics' , 'G3:I18'); % [age x risk]; male risk distribution
riskDistF = xlsread(file , 'Demographics' , 'J3:L18'); % [age x risk]; female risk distribution
mue = xlsread(file , 'Demographics' , 'P4:Q19'); % [age x gender]; background mortality
fertility = xlsread(file , 'Demographics' , 'R4:W19'); % [age x disease]; fertility
fertility2 = xlsread(file , 'Demographics' , 'R29:W44'); % [age x disease]; fertility/2
partnersM = xlsread(file , 'Demographics' , 'Z3:AB18'); % [age x risk]; male partnerships per year
partnersF = xlsread(file , 'Demographics' , 'AC3:AE18'); % [age x risk]; female partnerships per year
actsPer = xlsread(file , 'Demographics' , 'AI2:AK3'); % [gender x risk]; acts per partnership
epsA = xlsread(file , 'Demographics' , 'AO2:AO4'); % [year] <1998 , 2003 , >2010; force of infection mixing by age
epsR = xlsread(file , 'Demographics' , 'AP2:AP4'); % [year] <1998 , 2003 , >2010; force of infection mixing by sexual risk
yr = xlsread(file , 'Demographics' , 'AN2:AN4'); % years
savdir = [pwd , '\Params']; 
save(fullfile(savdir , 'popData') , 'popInit' , 'riskDistM' , 'riskDistF' , 'mue' , 'fertility' , 'partnersM' , ...
    'partnersF' , 'actsPer' , 'epsA' , 'epsR' , 'fertility2' , 'yr');

%% import and save HIV parameters
file = [pwd , '\Config\HIVParameters.xlsx'];
disp(['Loading data from ' , file , '...']);
disp('This may take a couple seconds...');

% protection data
circ = xlsread(file , 'Protection' , 'Q18 : R18'); % Circumcision rate [1 x year] <2009, 2012>
circProtect = xlsread(file , 'Protection' , 'R3'); % Protection conferred by circumcision
condProtect = xlsread(file , 'Protection' , 'R4'); % Protection conferred by condom use
condUse = xlsread(file , 'Protection' , 'R10'); % Average proportion of population using condoms
% disease data
MTCTRate = xlsread(file , 'Disease Data' , 'Q2:Q4'); % <2004, 2005 , >2008; mother to child transmission rate
muHIV = xlsread(file , 'Disease Data' , 'BA3 : BF18'); %[Age x cd4], [12 x 6]; HIV mortality
mtctVec = linspace(MTCTRate(1) , MTCTRate(end) , size(MTCTRate , 1) * 4);
kCD4(1 , : , :) = xlsread(file , 'Disease Data' , 'AP30:AS34'); % [gender x vl x cd4]; male cd4 progression by vl
kCD4(2 , : , :) = xlsread(file , 'Disease Data' , 'AV30:AY34'); % [gender x vl x cd4]; female cd4 progression by vl
% viral load progression by CD4 count
kVl(1 , : , :) = xlsread(file , 'Disease Data' , 'AP39 : AS43'); % [gender x cd4 x vl]; male vl progression by cd4
kVl(2 , : , :) = xlsread(file , 'Disease Data' , 'AV39 : AY43'); % [gender x cd4 x vl]; female vl progression by cd4

%%
% Treatment intiation rates
toPrep = 0; % initially

% 2004 - 2006 begin ART
% below200Art_2004 = interp1([2004 , 2006] , [0 0.25] ,[2004 : 1 / stepsPerYear : 2006]); % ART coverage for persons with CD4 < 200
% above200Art_2004 = interp1([2004 , 2006] , [0 0.25] , [2004 : 1 / stepsPerYear : 2006]);
% pie4Vec_2004 = interp1([2004 , 2006] , [0 0.01] , [2004 : 1 / stepsPerYear : 2006]);
% % 2006 - 2013 begin ART
% below200Art_2006 = interp1([2006 , 2013] , [0.03 0.25] , [2006 : 1 / stepsPerYear : 2013]);
% pieVec5_2006 = interp1(linspace(2006 , 2013 , stepsPerYear) , [0.02 0.06]);
% pieVec4_2006 = interp1(linspace(2006 , 2013 , stepsPerYear) , [0.01 0.06]);
%
% if year >= 2014
%     pie(6 , : , : , 4 : end , :) = 0.06; % Home HTC study
%     pie(5 , : , : , 4 : end , :) = 0.02;
%     pie(4 , : , : , 4 : end , :) = 0.01;
% elseif year >= 2006
%     pie(6 , : , : , 4 : end, :) = 0.03; % ART coverage for persons with CD4 < 200
% end

% Treatment dropout rates
prepOut = xlsread(file , 'Disease Data' , 'B3');
artOut = xlsread(file , 'Disease Data' , 'C3');

save(fullfile(savdir , 'HIVParams')) % save HIV parameters to a workspace file

%% save general parameters
disease = 10;
viral = 6;
hpvTypes = 4;
hpvStates = 10;
periods = 3;
gender = 2;
age = 16;
risk = 3;

dim = [disease , viral , hpvTypes , hpvStates , periods , gender , age , risk];

% index retrieval function
k = cumprod([disease , viral , hpvTypes , hpvStates , periods , gender , age]);

toInd = @(x) (x(: , 8) - 1) * k(7) + (x(: , 7) - 1) * k(6) + (x(: , 6) - 1) * k(5) ...
    + (x(: , 5) - 1) * k(4) + (x(: , 4) - 1) * k(3) + (x(: , 3) - 1) * k(2) ...
    + (x(: , 2) - 1) * k(1) + x(: , 1);

sumall = @(x) sum(x(:));
modelYr1 = 1980;
modelYrLast = endYear;
save(fullfile(savdir ,'general'), 'disease' , 'viral' , 'hpvTypes' , 'hpvStates' , 'periods' ,...
    'gender' , 'age' , 'risk' , 'modelYr1' , ...
    'dim' , 'k' , 'sumall' , 'toInd' , 'circ' , ...
    'condUse' , 'stepsPerYear'); % save general model parameters to a workspace file

%% save parameters for mixInfect
load('settings')
step = 1 / stepsPerYear;
epsA_vec = cell(size(yr , 1) - 1, 1); % save data over time interval in a cell array
epsR_vec = cell(size(yr , 1) - 1, 1);
for i = 1 : size(yr , 1) - 1          % interpolate epsA/epsR values at steps within period
    period = [yr(i) , yr(i + 1)];
    epsA_vec{i} = interp1(period , epsA(i : i + 1 , 1) , ...
        yr(i) : step : yr(i + 1));
    epsR_vec{i} = interp1(period , epsR(i : i + 1 , 1) , ...
        yr(i) : step : yr(i + 1));
end
modelYrLast = endYear;

save(fullfile(savdir , 'mixInfectParams')  , 'epsA_vec' , ...
    'epsR_vec' , 'yr' , 'modelYr1' , 'modelYrLast' , ...
    'circProtect' , 'condProtect')

analProp = [0 , 0;
    0.5111 , 0.4266;
    0.5111 , 0.4266]; % risk x gender
analProp = analProp .* 0; % no anal transmission for now
analTrans = [138 ; 11] ./ 10 ^ 4; % gender x 1
vagTransM = 8 / 10 ^ 4 * ones(size(analProp , 1) , 1);
vagTransF = 4 / 10 ^ 4 * ones(size(analProp , 1) , 1);
transM = vagTransM .* (1 - analProp(: , 1)) + analTrans(1) * analProp(: , 1);
transF = vagTransF .* (1 - analProp(: , 2)) + analTrans(2) * analProp(: , 2);
betaHIV_F2M = bsxfun(@times , [7 1 5.8 6.9 11.9 0.04;
    7 1 5.8 6.9 11.9 0.04;
    7 1 5.8 6.9 11.9 0.04] , transF);
betaHIV_M2F = bsxfun(@ times , [7 1 5.8 6.9 11.9 0.04;
    7 1 5.8 6.9 11.9 0.04;
    7 1 5.8 6.9 11.9 0.04] , transM);

file = [pwd , '\Config\PopData.xlsx'];

maleActs = xlsread(file , 'Demographics' , 'AJ10 : AL25'); % [age x risk]; male acts
femaleActs = xlsread(file , 'Demographics' , 'AJ32 : AL47'); % [age x risk]; female acts
betaHIVF2M = zeros(age , risk , viral);
betaHIVM2F = betaHIVF2M;
for a = 1 : age % calculate per-partnership probability of HIV transmission
    betaHIVF2M(a , : , :) = 1 - (bsxfun(@power, 1 - betaHIV_F2M , maleActs(a , :)')); % HIV(-) males
    betaHIVM2F(a , : , :) = 1 - (bsxfun(@power, 1 - betaHIV_M2F , femaleActs(a , :)')); % HIV(-) females
end
save(fullfile(savdir , 'vlBeta') , 'betaHIVF2M' , 'betaHIVM2F' , 'betaHIV_F2M' , 'betaHIV_M2F' , ...
    'maleActs', 'femaleActs')
%% Load indices
% prompt = {'Calculate Indices? (1 = yes, 0 = no)'};
% tit = 'Calculate Indices?';
% input = inputdlg(prompt , tit);
% if str2double(input{1})
%     disp('Preparing indices...')
%     disp('This may take a while...')
%     syms d v h s p g a r
%     calcInds();
% else
%     disp('Skipped index calculation')
% end
%% Import HPV data
disp(' ')
disp('Importing HPV data...')
file = [pwd , '\Config\HPVData.xlsx'];
disp(['Loading data from ' , file , '...']);
disp('This may take a couple seconds...');
% demographic data
beta_hrHPV_val = xlsread(file , 'HPV' , 'B13'); % per-parnership probability of HPV transmission (common vaccine types 16/18/31/33)
beta_lrHPV_val = xlsread(file , 'HPV' , 'B14'); % oncogenic non-vaccine type

%pCinSize =  xlsread(file , 'HPV' , 'I3 : I11'); % [group size x 1]

rHivHpv = xlsread(file , 'HPV' , 'R12 : T15'); % HIV multipliers (<= 1) for HPV regression rate
hivCin2 = xlsread(file , 'HPV' , 'R21 : R23'); % HIV multipliers for precancer progression
hivCin3 = hivCin2;


muCC = xlsread(file , 'Cervical Cancer' , 'B24 : D29'); % undetected CC mortality
muCC_det = xlsread(file , 'Cervical Cancer' , 'F24 : H29'); % detected CC mortality
kRL = xlsread(file , 'Cervical Cancer' , 'H2'); % local -> regional  progression
kDR = xlsread(file , 'Cervical Cancer' , 'H3'); % regional -> distant progression
detCC = xlsread(file , 'Cervical Cancer' , 'K2 : K4'); % [region x 1] detection probability
kCC = xlsread(file , 'Cervical Cancer' , 'B3 : B11'); % [period] group size
hivCC = xlsread(file , 'Cervical Cancer' , 'O3 : O6'); % HIV multipliers (HR) for cervical cancer mortality rate
hivCC(end) = 1;

kPap = xlsread(file , 'Screening and Treatment' , 'N3'); % pap smear rate
hpvSens = xlsread(file , 'Screening and Treatment' , 'T4 : U4'); % [1 x Cin] 2 , 3; HPV primary screening sensitivity
cytoSens = xlsread(file , 'Screening and Treatment' , 'T5 : U5'); % [1 x Cin] 2 , 3; Cytology ASC-US or worse primary screening sensitivity
leep = 1- xlsread(file , 'Screening and Treatment' , 'Z2'); % rate of recurrence/persistence with LEEP
screenFreq = xlsread(file , 'Screening and Treatment' , 'Z7 : AA8'); % [Test x HIV status] (2 x 2); screening frequency
screenCover = xlsread(file , 'Screening and Treatment' , 'Z16'); % screening coverage
ageStart = xlsread(file , 'Screening and Treatment' , 'Z12'); % screening age start
ageEnd = xlsread(file , 'Screening and Treatment' , 'Z13'); % screening age end


% CIN transition data
%HPV 16/18/Vaccine type ohr
kCin1_Inf(: , 1) = xlsread(file , 'CIN Transition' , 'B47 : B62'); % HPV to CIN1
kCin2_Cin1(: , 1) = xlsread(file , 'CIN Transition' , 'C47 : C62'); % CIN1 to CIN2
kCin3_Cin2(: , 1) = xlsread(file , 'CIN Transition', 'D47 : D62'); %CIN2 to CIN3
kCC_Cin3(: , 1) = xlsread(file , 'CIN Transition', 'E47 : E62'); % CIN3 to undLocaliseed

rNormal_Inf(: , 1) = xlsread(file , 'CIN Transition' , 'F47 : F62'); % HPV to Well (natural immunity)
kInf_Cin1(: , 1) = xlsread(file , 'CIN Transition' , 'G47 : G62'); % CIN1 to HPV
kCin1_Cin2(: , 1) = xlsread(file , 'CIN Transition', 'H47 : H62'); % CIN2 to CIN1
kCin2_Cin3(: , 1) = xlsread(file , 'CIN Transition', 'I47 : I62'); % CIN3 to CIN2

% 9v type ohr
kCin1_Inf(: , 2) = xlsread(file , 'CIN Transition' , 'M47 : M62');
kCin2_Cin1(: , 2) = xlsread(file , 'CIN Transition' , 'N47 : N62');
kCin3_Cin2(: , 2) = xlsread(file , 'CIN Transition' , 'O47 : O62');
kCC_Cin3(: , 2) = xlsread(file , 'CIN Transition' , 'P47 : P62');

rNormal_Inf(: , 2) = xlsread(file , 'CIN Transition' , 'Q47 : Q62');
kInf_Cin1(: , 2) = xlsread(file , 'CIN Transition' , 'R47 : R62');
kCin1_Cin2(: , 2) = xlsread(file , 'CIN Transition', 'S47 : S62');
kCin2_Cin3(: , 2) = xlsread(file , 'CIN Transition', 'T47 : T62');

%Non-vaccine type ohr
kCin1_Inf(: , 3) = xlsread(file , 'CIN Transition' , 'W47 : W62');
kCin2_Cin1(: , 3) = xlsread(file , 'CIN Transition' , 'X47 : X62');
kCin3_Cin2(: , 3) = xlsread(file , 'CIN Transition', 'Y47 : Y62');
kCC_Cin3(: , 3) = xlsread(file , 'CIN Transition', 'Z47 : Z62');

rNormal_Inf(: , 3) = xlsread(file , 'CIN Transition' , 'AA47 : AA62');
kInf_Cin1(: , 3) = xlsread(file , 'CIN Transition' , 'AB47 : AB62');
kCin1_Cin2(: , 3) = xlsread(file , 'CIN Transition', 'AC47 : AC62');
kCin2_Cin3(: , 3) = xlsread(file , 'CIN Transition', 'AD47 : AD62');





hpv_hivMult = flipud(xlsread(file , 'HPV' , 'B21 : D24')); % [inc CD4 count x vaccine type]; HPV incidence multiplier by type and CD4 count
hpv_hivClear = xlsread(file , 'CIN Transition' , 'D68 : D71'); % [dec CD4 count]; HPV clearance multipliers
c3c2Mults = xlsread(file , 'CIN Transition' , 'B75 : B78'); % [dec CD4 count]; CIN2 to CIN3 multipliers
c2c1Mults = xlsread(file , 'CIN Transition' , 'B81 : B84'); % [dec CD4 count]; CIN1 to CIN2 multipliers
save(fullfile(savdir , 'hpvData') , 'beta_hrHPV_val' , 'beta_lrHPV_val' , 'kCC' , ...
    'rHivHpv' , 'hivCin2' , 'hivCin3' , 'muCC' , 'muCC_det' , 'kRL' , 'kDR' , 'detCC' , 'hivCC' , ...
    'kPap' , 'hpvSens' , 'cytoSens' , 'leep' , 'screenFreq' , 'ageStart' , 'ageEnd',...
    'kInf_Cin1' , 'kCin1_Cin2' , 'kCin2_Cin3' , 'kCin2_Cin1', ...
    'kCin3_Cin2' , 'kCC_Cin3' , 'kCin1_Inf' , 'rNormal_Inf' , 'hpv_hivClear' , ...
    'c3c2Mults' , 'c2c1Mults' , 'hpv_hivMult' , 'screenCover')
disp('HPV data loaded.')
disp(' ')
%% Actual data
% disp('Retrieving actual data')
% overallHivPrev_SA = xlsread('HIVParameters.xlsx' , 'Actual' , 'A22 : B32');
% overallHivPrev_KZN = xlsread('HIVParameters.xlsx' , 'Actual' , 'A33 : B43');
% overallHivPrev_KZN_2 = xlsread('HIVParameters.xlsx' , 'Actual' , 'E33 : H36');
% overallHivPrev_KZN_3 = xlsread('HIVParameters.xlsx' , 'Actual' , 'E22 : H27');
% overallHivPrev_KZN_3 = [overallHivPrev_KZN_3 ; xlsread('HIVParameters.xlsx' , 'Actual' , 'E33 : H36')];
% HivPrevWomen = xlsread('HIVParameters.xlsx' , 'Actual' , 'J5 : Q11'); %  age group (15 - 19 to 45 - 49) x year (2004-2011)
% HivPrevMen = xlsread('HIVParameters.xlsx' , 'Actual' , 'U5 : AB11');
% prevYears = xlsread('HIVParameters.xlsx' , 'Actual' , 'U4 : AB4');
% save('actual')
% disp('Actual data loaded')
% disp(' ')
%% Weights and costs
clear
disp('Retrieving weights and costs...')
file = [pwd , '\Config\WeightsCosts.xlsx'];
savdir = [pwd , '\Params']; 
hivTreatCost = xlsread(file , 'Costs' , 'B3 : B6'); % [inc CD4 count]; average HIV hositalization costs
artTreatCost = xlsread(file , 'Costs' , 'B7'); % HIV hospitalization costs on ART
kCCDet = xlsread(file , 'Costs' , 'B23:B25'); %(local, regional, distant); probability of symptom detection
vaxPrice = xlsread(file , 'Costs' , 'B17'); % bivalent HPV vaccine costs per vaccinated girl
ccCost = xlsread(file , 'Costs' , 'B12:B14'); % (local, regional, distant); CC costs
hivTreatCost = flipud(hivTreatCost);
save(fullfile(savdir , 'cost_weights'))
disp('Done')
%% Retrieve calibration data
% dimensions = [pos , N]
clear
file = [pwd , '\Config\CalibrationTargets.xlsx'];
savdir = [pwd , '\Params']; 
cinPos2014_obs = xlsread(file , 'Calibration' , 'D2 : F11'); %CIN2/CIN3 Prevalence (HIV+) 2014, by age
cinNeg2014_obs = xlsread(file , 'Calibration' , 'D12 : F21'); %CIN2/CIN3 Prevalence (HIV-) 2014, by age
hpv_hiv_2008_obs = xlsread(file , 'Calibration' , 'D32 : F41'); % HPV Prevalence in HIV+ Women (no CIN2/3) 2008, by age
hpv_hivNeg_2008_obs = xlsread(file , 'Calibration' , 'D42 : F51'); % HPV Prevalence in HIV- Women (no CIN2/3) 2008, by age

hpv_hiv_obs = xlsread(file , 'Calibration' , 'D144 : F152'); % HPV Prevalence in HIV+ Women (All) 2014, by age
hpv_hivNeg_obs = xlsread(file , 'Calibration' , 'D153 : F161'); % HPV Prevalence in HIV- Women (All) 2014, by age

hivPrevM_obs = xlsread(file , 'Calibration' , 'D60 : F101'); % HIV Prevalence in Men 2003, by age
hivPrevF_obs = xlsread(file , 'Calibration' , 'D102 : F143'); % HIV Prevalence in Women 2003, by age
save(fullfile(savdir , 'calibData'))
clear
