function [ERP_Laser_norm ERP_Rpeak_norm ERP_Laser_unfold ERP_Rpeak_unfold] = Funct__CalculateERP(EEG, start_epoch, end_epoch, channel_ERP)
% Function that calculates normal and UNFOLD ERPs for 'laser' and
% 'r_peak'-events

%% Calculate normal ERPs
EEG_laser = pop_epoch( EEG, {  'laser'  }, [start_epoch end_epoch],'epochinfo', 'yes');% normal ERP (without unfold) for laser
ERP_Laser_norm = mean(EEG_laser.data(channel_ERP,:,:), 3);

EEG_rpeak = pop_epoch( EEG, {  'r_peak'  }, [start_epoch end_epoch], 'epochinfo', 'yes');% normal ERP (without unfold) for r_peak
ERP_Rpeak_norm = mean(EEG_rpeak.data(channel_ERP,:,:), 3);


%% Calculate unfold ERPs

% unfold deconvolution
run('init_unfold.m');
cfgDesign = [];% Defining the 2x2 factorial design
cfgDesign.eventtypes = {{'laser'},{'r_peak'}};
cfgDesign.formula = {'y ~ 1','y ~ 1'};
EEG = uf_designmat(EEG,cfgDesign);

cfgTimeshift = [];% Timeshift
cfgTimeshift.timelimits = [start_epoch,end_epoch];
EEG = uf_timeexpandDesignmat(EEG,cfgTimeshift);

% uf_plotDesignmat(EEG,'timeexpand',1)
%  ylim([40 120])

EEG = uf_glmfit(EEG); % Fit the model
ufresult = uf_condense(EEG);
cfg = [];
cfg.channel = channel_ERP; %channel 11 = Cz

% ax = uf_plotParam(ufresult,cfg);

ERP_Laser_unfold = ufresult.beta(channel_ERP,:,1);
ERP_Rpeak_unfold = ufresult.beta(channel_ERP,:,2);





