clear;
tic
%% Extract parameters of sources in frequency bin X (Mauritius Poster)
% Load the frequency bin edges from the search parameter file for bin X.
simParamsDir = '~/Research/PulsarTiming/SimDATA/Mauritius/searchParams_GWBsimDataSKA';
simDataDir = '~/Research/PulsarTiming/SimDATA/Mauritius/GWBsimDataSKA';
estDataDir = '~/Research/PulsarTiming/SimDATA/Mauritius/MauritiusNew_results_mat';
% Load the source parameters across the entire frequency range
load([simDataDir,filesep,'GWBsimDataSKASrlz1Nrlz9.mat'],'omega', ...
    'timingResiduals_tmp', 'yr','snr_chr','simParams');

%% setting fig axis
y = [];
ybin_up = [];
ybin_low = [];
x = [];

sy = [];
sx = [];

%% reading the files and sort it naturely
inParamsList = dir([simParamsDir,filesep,'*.mat']);
inDataList = dir([estDataDir,filesep,'*Nrlz9.mat']);
inParamNames = {};
inDataNames = {};
% get the name and sort it
for n = 1:10
    inParamNames = [inParamNames inParamsList(n).name];
    inDataNames = [inDataNames inDataList(n).name];
end
inParamNames = sort_nat(inParamNames);
inDataNames = sort_nat(inDataNames);

%% data pre-processing
for i = 1:length(inDataList)
    % load bands and estimated data
    load([simParamsDir,filesep,char(inParamNames(i))]);
    load([estDataDir,filesep,char(inDataNames(i))],'bestRealLoc');
    path_to_estimatedData = [estDataDir,filesep,char(inDataNames(i))];
    
    % Find the sources with frequencies in bin 4
    binsrcOmgIndx = find(omega >= xmaxmin(3,2) & ...
        omega <= xmaxmin(3,1));
    ybin_up = [ybin_up xmaxmin(3,1)];% saving the band boundary
    ybin_low = [ybin_low xmaxmin(3,2)];
    
    if isempty(binsrcOmgIndx)
        disp(["There's no signal injected in band",num2str(i)]);
        continue
    end
    % Get their frequencies in Hz
    binsrcOmega = omega(binsrcOmgIndx);
    y = [y binsrcOmega];
    %binsrcF = (binsrcOmega/(2*pi))/(24*3600*365);
    % Get their SNR
    binsrcSNR = snr_chr(binsrcOmgIndx);
    x = [x binsrcSNR];
    %% Estimated source
    %path_to_simulationData = '~/Research/PulsarTiming/SimDATA/Mauritius/GWBsimDataSKA/GWBsimDataSKASrlz1Nrlz9.mat';
    %path_to_pulsar_catalog = 'survey_ska.mat';
    phiI = bestRealLoc(8:1007);% esimated pulsar phases
    estFreq = bestRealLoc(3)/(2*pi*365*24*3600);
    [sourceParams]=ColSrcParams(path_to_estimatedData);
    %[pulsarParams]=ColPsrParams(path_to_pulsar_catalog);
    estSNR = Amp2Snr(sourceParams,simParams,phiI,yr);
    sy = [sy estFreq];
    sx = [sx estSNR];
    %%
    % Plot the FFT of the timing residuals of the sources in bin 4
    timingResFFt = fft(timingResiduals_tmp');
    timingResPdg = timingResFFt(1:(floor(130/2)+1),:);
    timingResPdg = abs(timingResPdg);
    freqVec = (0:(floor(130/2)))*(1/((yr(end)-yr(1))*365*24*3600));
    % figure(1)
    % plot(freqVec,timingResPdg);
    % hold on
    % plot(bin5srcF,6e-6,'.')
    %%
    % Reproduce the Mauritius poster figure (Source frequency vs SNR)
    %     figure(1)
    %     plot(binsrcSNR,binsrcF,'o',estSNR,estFreq,'r*');
    %     xlabel('Network Signal to Noise Ratio');
    %     ylabel('Source Frequency (Hz)');
    %     legend('Injected source','Estimated source');
    %
    %     title(['Realization#9 bin',num2str(i)]);
    %     figname = ['Realization#9 bin',num2str(i)];
    % saveas(gcf,figname,'png')
    % Spacing of source frequencies relative to Fourier frequency spacing
    % [bin5srcFsort,bin5srcFsortIndx] = sort(bin5srcF,'descend');
    % figure(3)
    % plot(bin5srcSNR(bin5srcFsortIndx),[0,diff(sort(bin5srcFsort))/(freqVec(2)-freqVec(1))],'o');
    % xlabel('Network Signal to Noise Ratio');
    % ylabel(' Frequency spacing\times Data duration');
end
y = y/(2*pi*365*24*3600);
binSNR = 0:1:450;
ybin_up = ybin_up/(2*pi*365*24*3600);
ybin_up = repmat(ybin_up,length(binSNR),1);% stack itself vertically to broadcast to the dimension of x
ybin_low = ybin_low/(2*pi*365*24*3600);
ybin_low = repmat(ybin_low,length(binSNR),1);
%% plot the entire map
figure(2)
yyaxis left
loglog(sx,sy,'*','MarkerSize',10);
%plot(x,y,'o',sx,sy,'*');
% semilogy(x,y,'o',sx,sy,'*');
% plot grids
%hold on
% for j=1:10
%     semilogy(binSNR,ybin_up(:,j),'b-');
%     %plot(binSNR,ybin_up(:,j),'b-');
%     semilogy(binSNR,ybin_low(:,j),'b--');
%     %plot(binSNR,ybin_low(:,j),'b--');
% end
xlabel('SNR');
ylabel('Frequency');
%saveas(gcf,'MauritiusNewEstiFig','png');
toc