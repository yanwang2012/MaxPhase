% Cross-Correlation Coefficients analysis for two sets of est. sources.
% without spliting into different bands.

% Author: QYQ
% 06/22/2021

clear;
tic

%% Dir settings
simdataDir = '/Users/qyq/Library/Mobile Documents/com~apple~CloudDocs/Research/PulsarTiming/SimDATA/MultiSource/Investigation/Final/realizations/2bands/simData/Band_opt_diff';
estSrc1Dir = '/Users/qyq/Library/Mobile Documents/com~apple~CloudDocs/Research/PulsarTiming/SimDATA/MultiSource/Investigation/Final/realizations/2bands/results_diff_one';
estsrc1 = 'OneBand';
estSrc2Dir = '/Users/qyq/Library/Mobile Documents/com~apple~CloudDocs/Research/PulsarTiming/SimDATA/MultiSource/Investigation/Final/realizations/2bands/results_diff_opt_xMBLT';
estsrc2 = 'xMBLT';
Filename = 'GWBsimDataSKASrlz*Nrlz1';
ext = '.mat';

%% Files
estSrc1File = dir([estSrc1Dir,filesep,'*',Filename,'*',ext]);
estSrc2File = dir([estSrc2Dir,filesep,'*',Filename,'*',ext]);
simFile = dir([simdataDir,filesep,Filename,'*',ext]);
estSrc2Filename = sort_nat({estSrc2File.name});
estSrc1Filename = sort_nat({estSrc1File.name});
simFilename = sort_nat({simFile.name});


Nestsrc1 = length(estSrc1File); % only have one band
Nestsrc2 = length(estSrc2File);
Nrlzs = length(simFile);
Nite1 = Nestsrc1/Nrlzs;


for rlz = 3% 1:Nrlzs
    load([simdataDir,filesep,simFilename{rlz}]);
    %% Get estimated sources info
    EstSrc2 = {};
    EstSrc1 = {};
    [~,baseName] = fileparts(simFilename{rlz});
    exp = ['\d+_',baseName,'(?=_|\.mat)_?\d{0,2}\.mat']; % for initial band selection
    estSrc1File_tmp = regexp(estSrc1Filename,exp,'match');
    estSrc1File_tmp = estSrc1File_tmp(~cellfun(@isempty, estSrc1File_tmp));
    estSrc2File_tmp = regexp(estSrc2Filename,exp,'match');
    estSrc2File_tmp = estSrc2File_tmp(~cellfun(@isempty, estSrc2File_tmp));
    Nite2 = length(estSrc2File_tmp);
    for k = 1:Nite1
        path_to_estimatedDataestSrc1 = [estSrc1Dir,filesep,estSrc1File_tmp{k}{1}];
        EstSrc1{k} = ColSrcParams(path_to_estimatedDataestSrc1, simParams.Np);
    end
    
    for j = 1:Nite2
        path_to_estimatedDataestSrc2 = [estSrc2Dir,filesep,estSrc2File_tmp{j}{1}];
        EstSrc2{j} = ColSrcParams(path_to_estimatedDataestSrc2, simParams.Np);
    end
    % Cross-Corelation
    [gamma,rho,id_max,estSNR1,estSNR2] = ESNMTCW(EstSrc1,EstSrc2,simParams,yr,0.90);
    
    %% Eliminating spurious sources
    t = 0.70; % NMTC threshold used to identify sources.
    confirm_src = {}; % identified sources
    cnfrm_src_alpha = [];
    cnfrm_src_dec = [];
    cnfrm_src_snr = [];
    cnfrm_src_freq = [];
    
    [r,c,~] = find(gamma > t); % r is the row of rho, c is the column of gamma.
    % in gamma, rows correspond to EstSrc1, columns correspond to EstSrc2.
    % select the identified sources from est. sources.
    for rr = 1:length(r)
        confirm_src{rr} = EstSrc2{c(rr)};
        cnfrm_src_alpha = [cnfrm_src_alpha EstSrc2{c(rr)}.alpha];
        cnfrm_src_dec = [cnfrm_src_dec EstSrc2{c(rr)}.delta];
        [cnfrm_snr,~] = Amp2Snr(EstSrc2{c(rr)},simParams,yr);
        cnfrm_src_snr = [cnfrm_src_snr cnfrm_snr];
        cnfrm_src_freq = [cnfrm_src_freq EstSrc2{c(rr)}.omega/(2*pi*365*24*3600)]; % convert from rad/yr to Hz
    end
    
    NcnfrmsrcBand = zeros(Nband,1);
    for idb = 1:Nband
        NcnfrmsrcBand(idb) = sum(~cellfun('isempty',confirm_src(idb,:))); % # of identified sources in each band
    end
    save([estSrc2Dir,filesep,baseName,filesep,'Confirmed_Src_Est'],'confirm_src','NcnfrmsrcBand',...
        'cnfrm_src_alpha','cnfrm_src_dec','cnfrm_src_freq','cnfrm_src_snr');
    
end

toc

%END