function parsave(fname,tVec ,  popVec , newHiv ,...
        newImmHpv , newVaxHpv , newHpv , deaths , hivDeaths , ccDeath , ...
        newCC , artTreatTracker , vaxd , ccTreated , ...
        currYear , lastYear , popLast)

savdir = 'H:\HHCoM_Results';
save(fullfile(savdir , fname) , 'tVec' ,  'popVec' , 'newHiv' ,...
            'newImmHpv' , 'newVaxHpv' , 'newHpv' , 'deaths' , 'hivDeaths' , ...
            'ccDeath' , 'newCC' , 'artTreatTracker' , 'currYear' , 'lastYear' , 'popLast' ,'-v7.3')

end
