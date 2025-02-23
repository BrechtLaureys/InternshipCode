function [EEG_Rpeaks] = Funct__Find_RPeaks(EEG_orig, ECG_chann, remove_path, remove_file)
% Function that identifies r-peaks in ECG data
% When r-peaks are unclear, remove this data segment

% Data
EEG = EEG_orig;
ECG = EEG.data(ECG_chann,:,:);%Select ECG

% Calculate R-latencies
[R_latency, valueRpeak] = functECG_ModPanTompkins_Max_Brecht(ECG, EEG.srate);

% Plot data to check if R-peaks are ok?
figure();
plot(EEG.times/1000, ECG); %change from ms to s
hold on; plot(R_latency/EEG.srate,valueRpeak,'xr'); %change from srate to s

% Remove data if bad R-peaks
ask_rem = menu('Remove datasegments with bad R-peaks using EEGLAB?','Yes','No');
close(gcf)

if ask_rem == 1
    while ask_rem == 1
     
                % Open EEGLAB to reject
        eeglab redraw;pop_eegplot(EEG);
        
        % Show the name under which to save data
        text1 = sprintf(['Reject bad datasegments and save data manually in EEGLAB using the filename: \n"' remove_file '"\n\nDone? Click OK']);
        waitfor(msgbox(text1));
        
        % Use rejected data?
        stop_rem = menu('Did you remove data?','Yes','No');

        
        % Continue with original data
        if stop_rem == 2
            break;
        end
        
        % Continue with modified data
        if stop_rem == 1
            EEG = pop_loadset('filename',remove_file,'filepath',remove_path);
            ECG = EEG.data(ECG_chann,:,:);
            
            % Recalculate Rpeaks
            [R_latency, valueRpeak] = functECG_ModPanTompkins_Max_Brecht(ECG, EEG.srate);
            
            % Check if ok
            figure();
            plot(EEG.times/1000, ECG); %change from ms to s
            hold on; plot(R_latency/EEG.srate,valueRpeak,'xr'); %change from srate to s
            
            %Remove further data?
            ask_rem = menu('Remove further data?','Yes','No');
            close all;
        end
    end
end

% Add to structure
n_rpeak = size(R_latency, 2);
n_orig_events=size(EEG.event, 2);

for i_rpeak = 1:n_rpeak
        EEG.event(n_orig_events+i_rpeak) = struct('type', {'r_peak'}, 'value', [], 'latency', R_latency(1,i_rpeak), 'duration', 0, 'urevent', []);
end

% Output
EEG_Rpeaks = EEG;





