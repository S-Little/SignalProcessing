function [spg,spc,time]= wavelet_FT_clean(dat, Fs, frq, plt);

% Use fieldtrip wavelet function to create a wavelet spectrogram with an
% associated time axis.
% This function also adds some padding beforehand to avoid edge effects
% and cuts it off afterwards.
% Note the settings of the wavelet (10 and 5)are hardcoded but can be
% changed. These are reasonable settings that have been published in the
% literature. You will need fieldtrip on your matlab path.
%
% Input:
% dat       Input data (rows x columns) = channels x time. Ie single channel
%           should be long row
% Fs        Sample rate
% frq       Range of frequencies e.g. [1:120]. Note f2 < Fs/2
% plt       Set plt = 1 if you want to show a plot of first row data.


% Output:
% spg       spectrogram (amplitude) that has been cleaned of padding.
% spc       complex spectrogram that has been cleaned of padding if you are
%           interested in phase relationships.
% time      time in seconds of x axis.

% Simon Little 5/21/2019

% Create time axis to go into Wavelet analysis.
dt=1/Fs;
st=-(size(dat,2)*dt)/2;
ed=-st;
time=[st:dt:ed]; time(end)=[];

% Padding - 5 seconds as standard. May need to increase if intersted in
% very low frequencies and getting NaNs in those frequencies.
pl=10;
pad=zeros(size(dat,1),Fs*pl);
datN=[pad dat pad];
time=[1:size(datN,2)]/1000;

% Use fieldtrip to do wavelet analysis
[spectrum,freqoi,timeoi]=ft_specest_wavelet(datN, time, 'freqoi',frq,'width',10,'gwidth',5,'verbose',1);

% Get amplitude
Pw=abs(spectrum);
sA=Pw;

% Trim off padding
trim=size(pad,2);
sA(:,:,1:trim)=[];
sA(:,:,end-trim+1:end)=[];
spg=squeeze(sA);

spc=spectrum;
spc(:,:,1:trim)=[];
spc(:,:,end-trim+1:end)=[];
spc=squeeze(sA);

% Clean up time output
time(:,1:trim)=[];
time(:,end-trim+1:end)=[];
time=time-time(1);

% Plot output if selected.
if plt==1
    figure;
    imagesc(time,freqoi,squeeze(spg(1,:,:)))
    set(gca,'YDir','normal')
    colormap jet
    xlabel('Time (s)');
    ylabel('Hz');
    box off
end

end