% Cross-Correlation Coefficients Matrix
% True sources vs. Identified sources
% Update to multi version

% Author: QYQ
% 05/27/2021

clear;
tic

%% Dir settings
searchParamsDir = '/Users/qyq/Library/Mobile Documents/com~apple~CloudDocs/Research/PulsarTiming/YuYang_data/searchParams/Band_opt';
simdataDir = '/Users/qyq/Library/Mobile Documents/com~apple~CloudDocs/Research/PulsarTiming/YuYang_data';
repdataDir = '/Users/qyq/Library/Mobile Documents/com~apple~CloudDocs/Research/PulsarTiming/YuYang_data/results_iMBLT';
Filename = 'GWBsimDataSKASrlz1Nrlz1';
%% IMPORTANT:MAKE SURE THIS IS CORRECT
SNR_Threshold = 20;
%%
reportFilename = ['RepSrc_SNR',num2str(SNR_Threshold)];
ext = '.mat';

%% Files
simFile = dir([simdataDir,filesep,Filename,ext]);
Nrlzs = length(simFile);
simFileNames = sort_nat({simFile.name});

%% Main
for rlz = 1:Nrlzs
    [~,simFileName,~] = fileparts(simFileNames{rlz});
    paraFile = dir([searchParamsDir,filesep,simFileName,filesep,'searchParams*',ext]);
    simFile = [simdataDir,filesep,simFileName,ext];
    % idFolder = 'id-Union2-xMBLT-vs-Union2-xMBLT-iMBLT';
    repFile = [repdataDir,filesep,simFileName,filesep,reportFilename,ext];
    simSrcFile = [repdataDir,filesep,simFileName,filesep,'simSrc.mat'];
    
    paraFilename = sort_nat({paraFile.name});
    exp = 'searchParams_Nyquist\d.mat'; % regular expressions for desire file names
    paraFilename = regexp(paraFilename,exp,'match');
    paraFilename = paraFilename(~cellfun(@isempty,paraFilename)); % get rid of empty cells
    Nband = length(paraFilename);
    
    
    load(simFile);
    load(repFile);
    load(simSrcFile);
    report_src = RepSrc_SNR;
    
    %% simulate source parameters
    % Ntsrc = length(alpha); % Number of true sources.
    SrcSNR = {simSrc.SrcSNR};
    SrcAlpha = {simSrc.SrcAlpha};
    SrcAmp = {simSrc.SrcAmp};
    SrcDelta = {simSrc.SrcDelta};
    SrcIota = {simSrc.SrcIota};
    SrcOmega = {simSrc.SrcOmega};
    SrcPhi0 = {simSrc.SrcPhi0};
    SrcThetaN = {simSrc.SrcThetaN};
    
    % create new sets which excludes sources below certain snr
    snr_cut = 5; % excludes true sources below snr 5
    RSrcSNR = {};
    RSrcAlpha = {};
    RSrcAmp = {};
    RSrcDelta = {};
    RSrcIota = {};
    RSrcOmega = {};
    RSrcPhi0 = {};
    RSrcThetaN = {};
    
    %% Sort sources in different bands
    
    for j = 1:Nband
        % Assign SNR cut to simulated sources
        RSrcSNR{j} = SrcSNR{j}(SrcSNR{j} >= snr_cut);
        RSrcAlpha{j} = SrcAlpha{j}(SrcSNR{j} >= snr_cut);
        RSrcDelta{j} = SrcDelta{j}(SrcSNR{j} >= snr_cut);
        RSrcAmp{j} = SrcAmp{j}(SrcSNR{j} >= snr_cut);
        RSrcIota{j} = SrcIota{j}(SrcSNR{j} >= snr_cut);
        RSrcOmega{j} = SrcOmega{j}(SrcSNR{j} >= snr_cut);
        RSrcPhi0{j} = SrcPhi0{j}(SrcSNR{j} >= snr_cut);
        RSrcThetaN{j} = SrcThetaN{j}(SrcSNR{j} >= snr_cut);
    end
    RsimSrc = struct('SrcSNR',RSrcSNR,'SrcAlpha',RSrcAlpha,'SrcDelta',RSrcDelta,'SrcAmp',RSrcAmp,...
        'SrcIota',RSrcIota,'SrcOmega',RSrcOmega,'SrcPhi0',RSrcPhi0,'SrcThetaN',RSrcThetaN); % Simulated sources parameters but exclude weaker sources
    
    %% Get identified sources info
    % idsrcBand1 = sum(~cellfun('isempty',idsrc(1,:))); % number of sources in a band.
    % idsrcBand2 = sum(~cellfun('isempty',idsrc(2,:)));
    % idsrcBand = struct('Band1',idsrcBand1,'Band2',idsrcBand2);
    idsrcBand = NrepsrcBand;
    
    %% Cross-Corelation
    
    % Max Weighted CC
    % [rho,rho_max,dif_freq_max,dif_ra_max,dif_dec_max,id_max,estSNR] = MWC(Nband,NestsrcBand,SrcAlpha,SrcDelta,SrcOmega,SrcPhi0,SrcIota,SrcThetaN,SrcAmp,SrcSNR,EstSrc,simParams,yr,'snr');
    
    % Max Weighted Ave. CC
    % [rho,rho_max,dif_freq_max,dif_ra_max,dif_dec_max,id_max,estSNR] = MWAC(Nband,NestsrcBand,SrcAlpha,SrcDelta,SrcOmega,SrcPhi0,SrcIota,SrcThetaN,SrcAmp,SrcSNR,EstSrc,simParams,yr,'snr');
    
    % Max over Threshold CC
    % [rho,rho_max,dif_freq_max,dif_ra_max,dif_dec_max,id_max,estSNR] = MTC(Nband,NestsrcBand,SrcAlpha,SrcDelta,SrcOmega,SrcPhi0,SrcIota,SrcThetaN,SrcAmp,EstSrc,simParams,yr,0.85);
    
    % Normalized MTC
    [rho,rho_max,dif_freq_max,dif_ra_max,dif_dec_max,id_max,estSNR] = NMTC(Nband,idsrcBand,simSrc,report_src,simParams,yr,0.80);
    
    
    % Minimum distance Maximum CC.
    % [rho,rho_max,dif_freq_max,dif_ra_max,dif_dec_max,id_max,estSNR] =
    % MinDMaxC(Nband,NestsrcBand,SrcAlpha,SrcDelta,SrcOmega,SrcPhi0,SrcIota,SrcThetaN,SrcAmp,EstSrc,simParams,yr);
    
    %% Eliminating spurious sources
    t = 0.70; % NMTC threshold used to identify sources.
    confirm_src = {}; % identified sources.
    r = {}; % rows
    c = {}; % columns
    cnfrm_src_alpha = [];
    cnfrm_src_dec = [];
    cnfrm_src_snr = [];
    cnfrm_src_freq = [];
    for b = 1:Nband
        [r{b},c{b},~] = find(rho_max{b} > t); % r is the row of rho, c is the column of rho.
        % in rho, rows correspond to EstSrc2, columns correspond to EstSrc1.
        % select the identified sources from est. sources.
        for rr = 1:length(r{b})
            confirm_src{b,rr} = report_src{b,r{b}(rr)};
            cnfrm_src_alpha = [cnfrm_src_alpha report_src{b,r{b}(rr)}.alpha];
            cnfrm_src_dec = [cnfrm_src_dec report_src{b,r{b}(rr)}.delta];
            [cnfrm_snr,~] = Amp2Snr(report_src{b,r{b}(rr)},simParams,yr);
            cnfrm_src_snr = [cnfrm_src_snr cnfrm_snr];
            cnfrm_src_freq = [cnfrm_src_freq report_src{b,r{b}(rr)}.omega/(2*pi*365*24*3600)]; % convert from rad/yr to Hz
        end
    end
    
    NcnfrmsrcBand = zeros(Nband,1);
    for idb = 1:Nband
        NcnfrmsrcBand(idb) = sum(~cellfun('isempty',confirm_src(idb,:))); % # of identified sources in each band
    end
    save([repdataDir,filesep,simFileName,filesep,'Confirmed_Src_SNR',num2str(SNR_Threshold)],'confirm_src','NcnfrmsrcBand',...
        'cnfrm_src_alpha','cnfrm_src_dec','cnfrm_src_freq','cnfrm_src_snr');
    
    %% Save matched true sources
    % save sky locations
    matched_alpha = []; % right ascension
    matched_alpha_rep = [];
    matched_dec = []; % declination
    matched_dec_rep = [];
    matched_snr = [];
    matched_snr_rep = [];
    matched_freq = [];
    id_max_cnfrm = zeros(size(id_max));
    
    for band = 1:Nband
        % matching true sources to reported sources
        matched_alpha_rep = [matched_alpha_rep SrcAlpha{band}(id_max(id_max(:,band) ~= 0, band))]; % exclude 0 elements
        matched_dec_rep = [matched_dec_rep SrcDelta{band}(id_max(id_max(:,band) ~= 0, band))];
        matched_snr_rep = [matched_snr_rep SrcSNR{band}(id_max(id_max(:,band) ~= 0, band))];
        % matching true sources to confirmed source
        matched_alpha = [matched_alpha SrcAlpha{band}(id_max(r{band},band))]; % exclude 0 elements
        matched_dec = [matched_dec SrcDelta{band}(id_max(r{band},band))];
        matched_snr = [matched_snr SrcSNR{band}(id_max(r{band},band))];
        matched_freq = [matched_freq SrcOmega{band}(id_max(r{band},band))/(2*pi*365*24*3600)]; % convert rad/yr to Hz
        id_max_cnfrm(r{band},band) = id_max(r{band},band);
    end
    
    save([repdataDir,filesep,simFileName,filesep,'Matched_Sources_SNR',num2str(SNR_Threshold),'.mat'],'id_max','matched_alpha','matched_dec','matched_snr',...
        'matched_freq','SrcAlpha','SrcDelta','id_max_cnfrm','matched_alpha_rep','matched_dec_rep','matched_snr_rep');
    %% Plotting
    metric = 'NMTC';
    methods = ['True vs reported_SNR',num2str(SNR_Threshold)];
    prefix = [repdataDir,filesep,'fig',filesep,simFileName,filesep,metric,'-',methods];
    mkdir(prefix);
    
    figname1 = metric;
    for fig = 1:Nband
        figure
        imagesc(rho_max{fig});
        a = colorbar;
        xlabel('True sources')
        ylabel('Reported sources')
        ylabel(a,'Corss-Correlation Coefficients')
        title(['Band ',num2str(fig)])
        saveas(gcf,[prefix,filesep,figname1,'Band ',num2str(fig)],'png');
        savefig([prefix,filesep,figname1,'Band ',num2str(fig)]);
    end
    
    
    figname2 = [metric,'-SNR'];
    for fig2 = 1:Nband
        N = idsrcBand(fig2);
        figure
        plot(estSNR(fig2,1:N),rho_max{fig2},'ob')
        xlabel('Estimated SNR')
        ylabel(metric)
        title(['Band ',num2str(fig2)])
        saveas(gcf,[prefix,filesep,figname2,'Band ',num2str(fig2)],'png');
        savefig([prefix,filesep,figname2,'Band ',num2str(fig2)]);
    end
    
    % figname3 = [metric,'identified sources'];
    %
    % for fig = 1:Nband
    %     ifreq = arrayfun(@(x) isrc{fig,x}.omega/(2*pi*365*24*3600), 1:length(r{fig}));
    %     figure
    %     plot(SrcSNR{fig},SrcOmega{fig}/(2*pi*365*24*3600),'ob',estSNR(fig,r{fig}),ifreq,'sr')
    %     text(SrcSNR{fig}+0.5,SrcOmega{fig}/(2*pi*365*24*3600), num2str((1:numel(SrcSNR{fig}))'), 'Color', '#0072BD')
    %     text(estSNR(fig,r{fig})-2,ifreq, num2str(r{fig}), 'HorizontalAlignment','right', 'Color', '#D95319')
    %     title(['Identified Sources Band ',num2str(fig)])
    %     xlabel('SNR')
    %     ylabel('Frequency(Hz)')
    %     legend('True Source','Identified Source')
    %     saveas(gcf,[prefix,filesep,figname3,'Band ',num2str(fig)],'png');
    %     savefig([prefix,filesep,figname3,'Band ',num2str(fig)]);
    % end
    
    % figname6 = [metric,'-freq'];
    %
    % for fig = 1:Nband
    %     switch fig
    %         case 1
    %             N = idsrcBand1;
    %         case 2
    %             N = idsrcBand2;
    %     end
    %     figure
    %     plot(dif_freq_max(1:N,fig),rho_max{fig},'ob')
    %     xlabel('Difference of Freq. Percentage (%)')
    %     ylabel(metric)
    %     title(['Band ',num2str(fig)])
    %     saveas(gcf,[prefix,filesep,figname6,'Band ',num2str(fig)],'png');
    %     savefig([prefix,filesep,figname6,'Band ',num2str(fig)]);
    % end
    %
    % figname7 = [metric,'-RA'];
    %
    % for fig = 1:Nband
    %     switch fig
    %         case 1
    %             N = idsrcBand1;
    %         case 2
    %             N = idsrcBand2;
    %     end
    %     figure
    %     plot(dif_ra_max(1:N,fig),rho_max{fig},'ob')
    %     xlabel('Difference of RA Percentage (%)')
    %     ylabel(metric)
    %     title(['Band ',num2str(fig)])
    %     saveas(gcf,[prefix,filesep,figname7,'Band ',num2str(fig)],'png');
    %     savefig([prefix,filesep,figname7,'Band ',num2str(fig)]);
    % end
    %
    % figname8 = [metric,'-DEC'];
    %
    % for fig = 1:Nband
    %     switch fig
    %         case 1
    %             N = idsrcBand1;
    %         case 2
    %             N = idsrcBand2;
    %     end
    %     figure
    %     plot(dif_dec_max(1:N,fig),rho_max{fig},'ob')
    %     xlabel('Difference of DEC Percentage (%)')
    %     ylabel(metric)
    %     title(['Band ',num2str(fig)])
    %     saveas(gcf,[prefix,filesep,figname8,'Band ',num2str(fig)],'png');
    %     savefig([prefix,filesep,figname8,'Band ',num2str(fig)]);
    % end
    close all
end

toc
%END