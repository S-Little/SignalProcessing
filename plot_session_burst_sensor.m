function plot_session_burst_sensor(subj_info, session_num, varargin)

defaults = struct('base_dir', 'c:\burst', 'channel', 'MLP34');  %define default values
params = struct(varargin{:});
for f = fieldnames(defaults)',  
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

session_dir=fullfile(params.base_dir, subj_info.subj_id,...
    num2str(session_num));
D=spm_eeg_load(fullfile(session_dir, sprintf('rcresp_Tafdf%dC.mat',session_num)));

zero_time=D.time(length(D.time)/2);
ntrials=size(D,3);
times=(D.time-zero_time)*1000;
time_idx=[1:length(times)];
% if length(params.time_limits)>0
%     time_idx=intersect(find(times>=params.time_limits(1)),find(times<=params.time_limits(2)));
% end

meg_ch_idx=D.indchantype('MEG');
mean_trial=mean(D(meg_ch_idx,:,:),3);
mag_trial=max(mean_trial,[],2)-min(mean_trial,[],2);
max_chan=find(mag_trial==max(mag_trial));
chan_idx=meg_ch_idx(max_chan);
disp(sprintf('Using channel %s', D.chanlabels{chan_idx}));

mean_tc=squeeze(mean(D(chan_idx,time_idx,:),3));
stderr_tc=squeeze(std(D(chan_idx,time_idx,:),[],3))./sqrt(size(D,3));
peak_time=find(mean_tc==max(mean_tc));
left_min=find(mean_tc(1:peak_time-1)==min(mean_tc(1:peak_time-1)));
right_min=peak_time+find(mean_tc(peak_time+1:end)==min(mean_tc(peak_time+1:end)));

% Position of each meg channel
ch_pos=D.coor2D(meg_ch_idx);
% Label for each meg channel
ch_labels=D.chanlabels(meg_ch_idx);
trials=setdiff([1:ntrials],D.badtrials);
    
mean_scalp_vals=squeeze(mean(D(meg_ch_idx,[left_min peak_time right_min],trials),3));
    
fig=figure('Position',[1 1 1600 400],'PaperUnits','points',...
    'PaperPosition',[1 1 1600 400],'PaperPositionMode','manual');
for i=1:size(mean_scalp_vals,2)
    ax=subplot(2,4,[i i+4]);
    in.f=fig;
    in.ParentAxes=ax;
    in.noButtons=true;
    in.type='MEG';
    in.min=min(mean_scalp_vals(:));
    in.max=max(mean_scalp_vals(:));
    [ZI,f]=spm_eeg_plotScalpData(mean_scalp_vals(:,i),ch_pos,ch_labels,in);
    children=get(f,'Children');
    d=get(children(2),'UserData');
    set(d.ht(max_chan),'visible','on');
    xdata=get(d.hp,'XData');
    ydata=get(d.hp,'YData');
    set(d.hp,'XData',xdata(max_chan));
    set(d.hp,'YData',ydata(max_chan));
end

 
subplot(2,4,4);
hold all;
for trial_idx=1:ntrials
    plot(times(time_idx), squeeze(D(chan_idx,time_idx,trial_idx)));
end
yl=ylim();
plot([times(left_min) times(left_min)],yl,'r','LineWidth',2);
plot([times(peak_time) times(peak_time)],yl,'r','LineWidth',2);
plot([times(right_min) times(right_min)],yl,'r','LineWidth',2);
hold off;
xlim([times(time_idx(1)) times(time_idx(end))]);
ylabel('Field Intensitiy (fT)');

subplot(2,4,8);
hold on;
shadedErrorBar(times(time_idx), mean_tc, stderr_tc, 'b');
yl=ylim();
plot([times(left_min) times(left_min)],yl,'r','LineWidth',2);
plot([times(peak_time) times(peak_time)],yl,'r','LineWidth',2);
plot([times(right_min) times(right_min)],yl,'r','LineWidth',2);
hold off;
xlim([times(time_idx(1)) times(time_idx(end))]);
xlabel('Time (ms)');
ylabel('Field Intensitiy (fT)');

saveas(fig, fullfile(session_dir, 'sensor_data.png'), 'png');
saveas(fig, fullfile(session_dir, 'sensor_data.eps'), 'eps');
saveas(fig, fullfile(session_dir, 'sensor_data.fig'), 'fig');
