% Calculates indices
function calcInds()
% Compartment parameters
disease = 10;
viral = 6;
hpvTypes = 4;
hpvStates = 10;
periods = 3;
gender = 2;
age = 16;
risk = 3;

% index retrieval function
k = cumprod([disease , viral , hpvTypes , hpvStates , periods , gender , age]);

toInd = @(x) (x(: , 8) - 1) * k(7) + (x(: , 7) - 1) * k(6) + (x(: , 6) - 1) * k(5) ...
    + (x(: , 5) - 1) * k(4) + (x(: , 4) - 1) * k(3) + (x(: , 3) - 1) * k(2) ...
    + (x(: , 2) - 1) * k(1) + x(: , 1);

sumall = @(x) sum(x(:));
% Indices
%% Load indices
paramDir = [pwd , '\Params\'];
disp('Preparing indices...')
disp('This may take a while...')
%% mixInfect.m indices
mCurr = zeros(age , risk , viral - 1 , 5 * hpvStates * hpvTypes * periods); % 5 HIV+ disease states
fCurr = zeros(age , risk , viral - 1 , 5 * hpvStates * hpvTypes * periods);
mCurrArt = zeros(age , risk , 1 , 1 * hpvStates * hpvTypes * periods); % 1 HIV+ ART disease state
fCurrArt = zeros(age , risk , 1 , 1 * hpvStates * hpvTypes * periods);
for a = 1 : age
    for r = 1 : risk
        for v = 1 : 5 % viral load (up to vl = 6). Note: last index is (viral - 1) + 1. Done to align pop v index with betaHIV v index.
            mCurr(a , r , v , :) = toInd(allcomb(2 : 6 , v , 1 : hpvTypes , ...
                1 : hpvStates , 1 : periods , 1 , a , r)); %mCurrInd(v , a , r));
            fCurr(a , r , v , :) = toInd(allcomb(2 : 6 , v , 1 : hpvTypes , ...
                1 : hpvStates , 1 : periods , 2 , a , r)); %fCurrInd(v , a , r));
        end
        mCurrArt(a , r , 1 , :) = toInd(allcomb(10 , 6 , 1 : hpvTypes , ...
            1 : hpvStates , 1 : periods , 1 , a , r)); %mCurrInd(v , a , r));
        fCurrArt(a , r , 1 , :) = toInd(allcomb(10 , 6 , 1 : hpvTypes , ...
            1 : hpvStates , 1 : periods , 2 , a , r)); %fCurrInd(v , a , r));
    end
end

gar = zeros(gender , age , risk , disease * viral * hpvTypes * hpvStates * periods);

for g = 1 : gender
    for a = 1 : age
        for r = 1 : risk
            gar(g , a , r , :) = sort(toInd(allcomb(1 : disease , 1 : viral ,...
                1 : hpvTypes , 1 : hpvStates , 1 : periods , g , a , r)));
        end
    end
end



naive = zeros(gender , age , risk , periods);

for g = 1 : gender
    for a = 1 : age
        for r = 1 : risk
            naive(g , a , r , :) = sort(toInd(allcomb(1 , 1 , 1 , 1 , 1 : periods , g , a , r)));
        end
    end
end

coInf = zeros(hpvTypes , gender , age , risk , periods);

for h = 1 : hpvTypes
    for g = 1 : gender
        for a = 1 : age
            for r = 1 : risk
                coInf(h , g , a , r , :) = sort(toInd(allcomb(2 , 2 , h , 2 , 1 : periods , g , a , r)));
            end
        end
    end
end

hivSus = zeros(disease , gender , age , risk , hpvStates * hpvTypes * periods);

for d = 1 : disease
    for g = 1 : gender
        for a = 1 : age
            for r = 1 : risk
                hivSus(d , g , a , r , :) =...
                    sort(toInd(allcomb(d , 1 , 1 : hpvTypes , 1 : hpvStates , 1 : periods , g , a , r)));
            end
        end
    end
end

hpvSus = zeros(disease, hpvTypes , gender , age , risk , viral);
hpvImm = zeros(disease , hpvTypes , gender , age , risk , viral);
hpvVaxd = zeros(disease , hpvTypes , gender , age , risk , viral);
hpvVaxd2 = hpvVaxd;
for d = 1 : disease
    for g = 1 : gender
        for a = 1 : age
            for r = 1 : risk
                for h = 1 : hpvTypes
                    hpvSus(d , h , g , a , r , :) = ...
                        sort(toInd(allcomb(d , 1 : viral , h , 1 , 1 , g , a , r)));
                    hpvImm(d , h , g , a , r , :) = ...
                        sort(toInd(allcomb(d , 1 : viral , h , 10 , 1 , g , a , r)));
                    hpvVaxd(d , h , g , a , r , :) = ...
                        sort(toInd(allcomb(d , 1 : viral , h , 9 , 1 , g , a , r)));
                    hpvVaxd2(d , h , g , a , r , :) = ...
                        sort(toInd(allcomb(d , 1 : viral , h , 1 , 2 , g , a , r)));
                end
            end
        end
    end
end

toHiv = zeros(gender , age , risk , hpvTypes * hpvStates * periods);
for g = 1 : gender
    for a = 1 : age
        for r = 1 : risk
            toHiv(g , a , r , :) = ...
                sort(toInd(allcomb(2 , 1 , 1 : hpvTypes , 1 : hpvStates , 1 : periods , g , a , r)));
        end
    end
end

toHpv = zeros(disease , hpvTypes , gender , age , risk , viral);
toHpv_ImmVax = zeros(size(hpvVaxd));
toHpv_Imm = zeros(size(toHpv_ImmVax));
toHpv_ImmVaxNonV = toHpv_Imm;

for d = 1 : disease
    for g = 1 : gender
        for a = 1 : age
            for h = 1 : hpvTypes
                for r = 1 : risk
                    toHpv(d , h , g , a , r , :) = ...
                        sort(toInd(allcomb(d , 1 : viral , h , 1 , 1 , g , a , r)));
                    toHpv_Imm(d , h , g , a , r , :) = ...
                        sort(toInd(allcomb(d , 1 : viral , h , 1 , 1 , g , a , r)));
                    toHpv_ImmVax(d , h , g , a , r , :) = ...
                        sort(toInd(allcomb(d , 1 : viral , h , 1 , 2 , g , a , r))); % vaccinated -> vaccine type infection
                    toHpv_ImmVaxNonV(d , h , g , a , r , :) = ...
                        sort(toInd(allcomb(d , 1 : viral , h , 1 , 3 , g , a , r))); % vaccinated -> non-vaccine type infection
                end
            end
        end
    end
end

hrInds = zeros(gender , age , risk , disease * viral * 7 * periods + disease * viral);
lrInds = hrInds;
hrlrInds = hrInds;

for g = 1 : gender
    for a = 1 : age
        for r = 1 : risk
            hrInds(g , a , r , :) = ...
                sort([toInd(allcomb(1 : disease , 1 : viral , 2 , ...
                1 : 7 , 1 : periods , g , a , r)); toInd(allcomb(1 : disease , 1 : viral , 2 , ...
                9 , 2 , g , a , r))]);
            lrInds(g , a , r , :) = ...
                sort([toInd(allcomb(1 : disease , 1 : viral , 3 , ...
                1 : 7 , 1 : periods , g , a , r)); toInd(allcomb(1 : disease , 1 : viral , 3 , ...
                9 , 2 , g , a , r))]);
            hrlrInds(g , a , r , :) = ...
                sort([toInd(allcomb(1 : disease , 1 : viral , 4 , ...
                1 : 7 , 1 : periods , g , a , r)); toInd(allcomb(1 : disease , 1 : viral , 4 , ...
                9 , 2 , g , a , r))]);
        end
    end
end

save([paramDir , 'mixInfectIndices'] , 'naive' , 'coInf' , 'hivSus' , 'hpvSus' , 'toHiv' , ...
    'toHpv' , 'toHpv_ImmVax' , 'toHpv_ImmVaxNonV' , 'toHpv_Imm' , ...
    'mCurr' , 'fCurr' , 'mCurrArt' , 'fCurrArt' , 'gar' , 'hrInds' , ...
    'lrInds' , 'hrlrInds' , 'hpvImm' , 'hpvVaxd' , 'hpvVaxd2')
disp('mixInfect indices loaded')
%% hiv.m , treatDist.m indices
% hivInds(d , v , g , a , r) = makeVec('d' , 'v' , 1 : hpvTypes , 1 : hpvStates , ...
%     1 : periods , 'g' , 'a' , 'r');
% hivInds = matlabFunction(hivInds);

hivInds = zeros(disease , viral , gender , age , risk , hpvTypes * hpvStates * periods);
for d = 1 : disease
    for v = 1 : viral
        for g = 1 : gender
            for a = 1 : age
                for r = 1 :risk
                    hivInds(d , v , g , a , r , :) = ...
                        sort(toInd(allcomb(d , v , 1 : hpvTypes , 1 : hpvStates , ...
                        1 : periods , g , a , r)));
                end
            end
        end
    end
end

save([paramDir , 'hivIndices'] , 'hivInds')
disp('treatDist indices loaded')
%% vlAdv.m indices
% vlInds(d , v , g) = makeVec(d , v , 1 : hpvTypes , 1 : hpvStates , ...
%     1 : periods , g , 1 : age , 1 : risk);
% vlInds = matlabFunction(vlInds , 'Optimize' , false);
% save('vlIndices' , 'vlInds')
%% bornDie.m indices
% hivInd(d , v , g , a) = makeVec('d' , 'v' , 1 : hpvTypes , 1 : hpvStates , ...
%     1 : periods , 'g' , 'a' , 1 : risk);
% hivInd = matlabFunction(hivInd);
% birthsInds(d , g , r) = makeVec('d' , 1 , 1 , 1 , 1 , 'g' , 1 , 'r');
% birthsInds = matlabFunction(birthsInds);
% % deathInds(g , a) = allcomb(1 : disease , 1 : viral , 1 : hpvTypes , 1 : hpvStates , ...
% %     1 : periods , g , a , 1 : risk);
% % deathInds = matlabFunction(deathInds , 'Optimize' , false);
% vaxInds(h , s , g , a) = makeVec(1 : disease , 1 : viral , 'h' , 's' , ...
%     1 : periods , 'g' , 'a' , 1 : risk);
% vaxInds = matlabFunction(vaxInds);
% save('bornDieIndices' , 'hivInd' , 'birthsInds' , 'vaxInds')
% disp('bornDie indices loaded')

%% hpv.m indices
% load('hpvData')
disp('Preparing indices for HPV modules...')
disp('This might take a while...')


ccInds = zeros(disease , hpvTypes , age , periods , viral * risk);
ccRegInds = ccInds;
ccDistInds = ccInds;
cin1Inds = ccInds;
cin2Inds = ccInds;
cin3Inds = ccInds;
ccLocDetInds = zeros(disease , hpvTypes , age , viral * risk);
ccRegDetInds = ccLocDetInds;
ccDistDetInds = ccRegDetInds;

for d = 1 : disease
    for h = 2 : hpvTypes
        for a = 1 : age
            for p = 1 : 2
                ccInds(d , h , a , p , :) = sort(toInd(allcomb(d , 1 : viral , h , 5 , p , 2 , a , 1 : risk)));
                ccRegInds(d , h , a , p , :) = sort(toInd(allcomb(d , 1 : viral , h , 6 , p , 2 , a , 1 : risk)));
                ccDistInds(d , h , a , p , :) = sort(toInd(allcomb(d , 1 : viral , h , 7 , p , 2 , a , 1 : risk)));
                cin1Inds(d , h , a , p , :) = sort(toInd(allcomb(d , 1 : viral , h , 2 , p , 2 , a , 1 : risk)));
                cin2Inds(d , h , a , p , :) = sort(toInd(allcomb(d , 1 : viral , h , 3 , p , 2 , a , 1 : risk)));
                cin3Inds(d , h , a , p , :) = sort(toInd(allcomb(d , 1 : viral , h , 4 , p , 2 , a , 1 : risk)));
            end
            ccLocDetInds(d , h , a , :) = sort(toInd(allcomb(d , 1 : viral , h , 5 , 3 , 2 , a , 1 : risk)));
            ccRegDetInds(d , h , a , :) = sort(toInd(allcomb(d , 1 : viral , h , 6 , 3 , 2 , a , 1 : risk)));
            ccDistDetInds(d , h , a , :) = sort(toInd(allcomb(d , 1 : viral , h , 7 , 3 , 2 , a , 1 : risk)));
        end
    end
end

ccTreatedInds = zeros(disease , hpvTypes , age , viral * risk * periods);
for d = 1 : disease
    for h = 2 : hpvTypes
        for a = 1 : age
            ccTreatedInds(d , h , a , :) = sort(toInd(allcomb(d , 1 : viral , h , 8 , 1 : periods , 2 , a , 1 : risk)));
        end
    end
end

screen35PlusInds = zeros(disease , hpvTypes , (age - 8 + 1) * risk * periods * viral);
screen25_35Inds = zeros(disease , hpvTypes , 2 * risk , periods * viral);

for d = 1 : disease
    for h = 2 : hpvTypes
        screen35PlusInds(d , h , :) = sort(toInd(allcomb(d , 1 : viral , h , 4 , 1 : periods , 2 , 8 : age , 1 : risk)));
        screen25_35Inds(d , h , :) = sort(toInd(allcomb(d , 1 : viral , h , 4 , 1 : periods , 2 , 6 : 7 , 1 : risk)));
    end
end


ccRInds = zeros(disease , hpvTypes , hpvStates , periods , age * risk * viral);
cc2SusInds = zeros(disease , age * risk * viral);


for d = 1 : disease
    for v = 1 : viral
        cc2SusInds(d , :) = sort(toInd(allcomb(d , 1 : viral , 1 , 1 , 1 , 2 , 1 : age , 1 : risk)));
        for h = 2 : hpvTypes
            for s = 1 : hpvStates
                for p = 1 : periods
                    ccRInds(d , h , s , p , :) = ...
                        sort(toInd(allcomb(d , 1 : viral , h , s , p , 2 , 1 : age , 1 : risk)));
                end
            end
        end
    end
end

normalInds = zeros(disease , gender , age , periods ,  viral * risk);
infInds = zeros(disease , hpvTypes , gender , age , periods ,  viral * risk);
immuneInds = infInds;
for g = 1 : gender
    for d = 1 : disease
        for a = 1 : age
            for p = 1 : 2
                normalInds(d , g , a , p , :) = ...
                    sort(toInd(allcomb(d , 1 : viral , 1 , 1 , p , g , a , 1 : risk)));
                for h = 2 : hpvTypes
                    immuneInds(d , h , g , a , p , :) = ...
                        sort(toInd(allcomb(d , 1 : viral , h , 10 , p , g , a , 1 : risk)));
                    infInds(d , h , g , a , p  , :) = ...
                        sort(toInd(allcomb(d , 1 : viral , h , 1 , p , g , a , 1 : risk)));
                end
            end
        end
        
    end
end

save([paramDir , 'hpvIndices'] , 'infInds' , 'cin1Inds' , 'cin2Inds' , 'cin3Inds' , 'normalInds' , ...
    'ccRInds' , 'screen35PlusInds' , 'screen25_35Inds' , 'ccInds' , 'ccRegInds' , ...
    'ccDistInds' ,'immuneInds' , 'ccTreatedInds' , 'ccLocDetInds' , 'ccDistDetInds' , 'ccRegDetInds')
disp('hpv indices loaded')
%% hpvTreat.m indices
ccRInds = zeros(disease , viral , hpvTypes , hpvStates , periods , age , risk);
ccSusInds = zeros(disease , viral , hpvStates , age , risk);

for d = 1 : disease
    for v = 1 : viral
        for h = 2 : hpvTypes
            for s = 5 : 7 % 5 - 7 cervical cancer
                for a = 1 : age
                    for p = 1 : periods
                        ccRInds(d , v , h , s , p , a , :) = toInd(allcomb(d , v , h , s , p , 2 , a , 1 : risk));
                    end
                end

            end
        end
    end
end

for d = 1 : disease
    for v = 1 : viral
        for h = 1 : hpvTypes
            for a = 1 : age
                ccSusInds(d , v , h , a , :) = toInd(allcomb(d , v , h , 1 , 1 , 2 , a , 1 : risk));
            end
        end
    end
end
getHystPopInds = zeros(age , disease * viral * hpvTypes * 7 * risk * periods);
hystPopInds = zeros(age , disease * viral * hpvTypes * periods * risk);
for a = 1 : age
    getHystPopInds(a , :) = toInd(allcomb(1 : disease , 1 : viral , 1 : hpvTypes , 1 : 7 , ...
        1 : periods , 2 , a , 1 : risk));
    hystPopInds(a , :) = toInd(allcomb(1 : disease , 1 : viral , 1 : hpvTypes , 8 , ...
        1 : periods , 2 , a , 1 : risk));
end

save([paramDir , 'hpvTreatIndices'] , 'ccRInds' , 'ccSusInds' , 'getHystPopInds' , 'hystPopInds')
disp('hpvTreatIndices loaded')
%% cinAdv.m indices
% inf1 = toInd(allcomb(1 : disease , 1 : viral , 2 : 4 , 1 : hpvStates ,...
%     1 , 1 : gender , 1 : age , 1 : risk));
% %kAdv = 1 / (stepsPerYear .* pCinSize); % pCinSize is a vector detailing the interval sizes of each CIN period group
% kCC = 1 / (stepsPerYear .* pCCSize);% pCCSize is a vector detailing the interval sizes of each CC period group
% local = toInd(allcomb(1 : disease , 1 : viral , 2 : 4 , 5 , 1 : periods ,...
%         1 : gender , 1 : age , 1 : risk));
% regional = toInd(allcomb(1 : disease , 1 : viral , 2 : 4 , 6 , 1 : periods ,...
%         1 : gender , 1 : age , 1 : risk));
% distant = toInd(allcomb(1 : disease , 1 : viral , 2 : 4 , 7 , 1 : periods ,...
%         1 : gender , 1 : age , 1 : risk));
% save('cinAdvData' , 'kCC')
% save('cinAdvIndices' , 'inf1' , 'local' , 'regional' , 'distant')
% disp('cinAdv indices loaded')
%% agePop.m indices
% Pre-calculate agePop indices
% genPrevInds = zeros(gender , age - 1 , risk , 7 * viral * hpvTypes * hpvStates * periods);
% prepPrevInds = zeros(gender , age - 1 , risk , 2 * viral * hpvTypes * hpvStates * periods);
% artPrevInds = zeros(gender , age - 1 , risk , 1 * viral * hpvTypes * hpvStates * periods);
%
% genNextInds = zeros(gender , age - 1 , risk , 7 * viral * hpvTypes * hpvStates * periods);
% prepNextInds = zeros(gender , age - 1 , risk , 2 * viral * hpvTypes * hpvStates * periods);
% artNextInds = zeros(gender , age - 1 , risk , 1 * viral * hpvTypes * hpvStates * periods);
%
% genLastInds = zeros(gender , risk , 7 * viral * hpvTypes * hpvStates * periods);
% prepLastInds = zeros(gender , risk , 2 * viral * hpvTypes * hpvStates * periods);
% artLastInds = zeros(gender , risk , 1 * viral * hpvTypes * hpvStates * periods);
%
% for g = 1 : gender
%     for a = 2 : age
%         for r = 1 : risk
%             %indices for previous generation
%             genPrevInds (g , a - 1 , r , :) =...
%                 toInd(allcomb(1 : 7 , 1 : viral , 1 : hpvTypes , 1 : hpvStates , 1 : periods , g , a - 1 , r));
%             prepPrevInds(g , a - 1 , r , :) = ...
%                 toInd(allcomb(8 : 9 , 1 : viral , 1 : hpvTypes , 1 : hpvStates , 1 : periods , g , a - 1 , r));
%             artPrevInds(g , a - 1 , r , :) = ...
%                 toInd(allcomb(10 , 1 : viral , 1 : hpvTypes , 1 : hpvStates , 1 : periods , g , a - 1 , r));
%             for rr = 1 : risk
%                 % indices for subsequent generation
%                 genNextInds(g , a - 1 , rr , :) = ...
%                     toInd(allcomb(1 : 7 , 1 : viral , 1 : hpvTypes , 1 : hpvStates , 1 : periods , g , a , rr));
%                 prepNextInds(g , a - 1 , rr , :) = ...
%                     toInd(allcomb(8 : 9 , 1 : viral , 1 : hpvTypes , 1 : hpvStates , 1 : periods , g , a , rr));
%                 artNextInds(g , a - 1 , rr , :) = ...
%                     toInd(allcomb(10 , 1 : viral , 1 : hpvTypes , 1 : hpvStates , 1 : periods , g , a , rr));
%             end
%         end
%     end
% end
%
% for g = 1 : gender
%     for r = 1 : risk
%         genLastInds(g , r , :) = ...
%             toInd(allcomb(1 : 7 , 1 : viral , 1 : hpvTypes , 1 : hpvStates , 1 : periods , g , age , r));
%         prepLastInds(g , r , :) = ...
%             toInd(allcomb(8 : 9 , 1 : viral , 1 : hpvTypes , 1 : hpvStates , 1 : periods , g , age , r));
%         artLastInds(g , r , :) = ...
%             toInd(allcomb(10 , 1 : viral , 1 : hpvTypes , 1 : hpvStates , 1 : periods , g , age , r));
%     end
% end
% genPrevInds = sort(genPrevInds);
% prepPrevInds = sort(prepPrevInds);
% artPrevInds = sort(artPrevInds);
% genNextInds = sort(genNextInds);
% prepNextInds = sort(prepNextInds);
% artNextInds = sort(artNextInds);
% genLastInds = sort(genLastInds);
% prepLastInds = sort(prepLastInds);
% artLastInds = sort(artLastInds);
%
% save('ageIndices' , 'genPrevInds' , 'prepPrevInds' , 'artPrevInds' , 'genNextInds' , 'prepNextInds' ,...
%     'artNextInds' , 'genLastInds' , 'prepLastInds' , 'artLastInds');

%% ageRisk.m indices

ageInd = zeros(gender , age , disease * viral * hpvTypes * hpvStates * periods * risk);
riskInd = zeros(gender , age , risk , disease * viral * hpvTypes * hpvStates * periods);

for g = 1 : gender
    for a = 1 : age
        ageInd(g , a , :) = toInd(allcomb(1 : disease , 1 : viral , 1 : hpvTypes , ...
            1 : hpvStates, 1 : periods , g , a , 1 : risk));   
        for r = 1 : risk
            riskInd(g , a , r , :) = toInd(allcomb(1 : disease , 1 : viral , 1 : hpvTypes , ...
                1 : hpvStates, 1 : periods , g , a , r));
        end
    end
end

save([paramDir , 'ageRiskInds'] , 'ageInd' , 'riskInd')
%% Vaccinated group indices

vaccinated = zeros(age , disease * viral * gender * risk);
waned = vaccinated;

vaccinated = toInd(allcomb(1 : disease , 1 : viral , 1 , 9 , 1 , 1 : gender , ...
    1 : age , 1 : risk));
waned = toInd(allcomb(1 : disease , 1 : viral , 1 , 1 , 1 , 1 : gender , ...
    1 : age , 1 : risk));

save([paramDir , 'vaxInds'] , 'waned' , 'vaccinated')
disp('Done')
disp('All indices loaded.')
disp(' ')
