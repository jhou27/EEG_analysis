
%add path to fieldtrip toolbox
addpath('/path/to/fieldtrip')

% Load your data
load('mydata.mat') % Your data should be in a variable called 'mydata'

% Convert to Fieldtrip data format
cfg = [];
cfg.dataset = 'mydata.mat'; % Change this to the name of your data file
cfg.channel = 'all';
cfg.trialdef.eventtype = 'trigger'; % Change this to the name of the event type
cfg.trialdef.eventvalue = '20'; % Change this to the name of the event value
cfg.trialdef.prestim = 0.5; % Change this to the length of the baseline period in seconds
cfg.trialdef.poststim = 1.0; % Change this to the length of the post-stimulus period in seconds
data = ft_preprocessing(cfg);

% Define the conditions of interest
cfg = [];
cfg.trials = find(data.trialinfo(:,1) == 1 & data.trialinfo(:,2) == 1); % High constraint verb trials
cfg.latency = [-0.2 1.0]; % The time window of interest
hcverb = ft_redefinetrial(cfg, data);

cfg = [];
cfg.trials = find(data.trialinfo(:,1) == 1 & data.trialinfo(:,2) == 2); % High constraint classifier trials
cfg.latency = [-0.2 1.0]; % The time window of interest
hcclass = ft_redefinetrial(cfg, data);

cfg = [];
cfg.trials = find(data.trialinfo(:,1) == 2 & data.trialinfo(:,2) == 1); % Low constraint verb trials
cfg.latency = [-0.2 1.0]; % The time window of interest
lcverb = ft_redefinetrial(cfg, data);

cfg = [];
cfg.trials = find(data.trialinfo(:,1) == 2 & data.trialinfo(:,2) == 2); % Low constraint classifier trials
cfg.latency = [-0.2 1.0]; % The time window of interest
lcclass = ft_redefinetrial(cfg, data);

% Define the configuration parameters for the cluster analysis
cfg = [];
cfg.channel = 'all'; % Use all electrodes
cfg.latency = [0.1 0.5]; % Time window of interest, in seconds
cfg.avgovertime = 'yes'; % Average across the time window of interest
cfg.avgoverchan = 'no'; % Don't average across electrodes
cfg.parameter = 'trial'; % Use the trial data

% Define the statistical test to perform
cfg.statistic = 'ft_statfun_depsamplesT'; % Use dependent samples T-test
cfg.method = 'montecarlo'; % Use Monte Carlo method to estimate the null distribution
cfg.correctm = 'cluster'; % Perform cluster-level correction for multiple comparisons
cfg.clusteralpha = 0.05; % Alpha level for cluster-level correction
cfg.clusterstatistic = 'maxsum'; % Use the maximum cluster size as the test statistic
cfg.minnbchan = 2; % Minimum number of adjacent electrodes required to form a cluster
cfg.tail = 0; % Two-tailed test
cfg.clustertail = 0; % Two-tailed test for the cluster-level statistic
cfg.alpha = 0.05; % Alpha level for the permutation test
cfg.numrandomization = 1000; % Number of permutations to use

% Define the design matrix for the statistical test
nsubj = size(data.trial, 1); % Number of subjects
design = zeros(2, 2*nsubj); % Initialize design matrix
for i = 1:nsubj
    design(1, 2*(i-1)+1:2*i) = i;
    design(2, 2*(i-1)+1:2*i) = [1 2]; % Design matrix has two factors: context and constraint
end
cfg.design = design;
cfg.uvar = 1; % Independent variable is the subject

% Perform the cluster analysis
stat = ft_timelockstatistics(cfg, data); %replace 'data' with each of the four conditions hcverb, hcclass, lcbver, lcclass

% Display the significant clusters
cfg = [];
cfg.alpha = 0.05;
cfg.parameter = 'stat';
cfg.zlim = [-3.5 3.5];
cfg.highlight = 'on';
cfg.highlightcolorpos = [0 0.5 0];
cfg.highlightcolorneg = [0.5 0 0];
cfg.highlightsize = 10;
cfg.comment = 'no';
cfg.layout = 'your_electrode_layout.mat'; % Replace with your electrode layout file
ft_clusterplot(cfg, stat);
