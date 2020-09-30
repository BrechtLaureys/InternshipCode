function [EEG_withCFA EEG_noCFA] = Funct__RemoveArtifacts(EEG)
% Output: 1. EEG with all artifacts removed except CFA, 2. EEG with all artifacts removed including CFA

%RUN ICA
ALLEEG = EEG;
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);
eeglab redraw;

%Identify components using SASICA
SASICA;
text1 = sprintf('1. COMPUTE SASICA \n2. Search for Cardiac Field Artifact (CFA) component \n3. Memorize number of CFA component \n4. Change "Reject" to "Accept" for CFA component \n5. Close SASICA by clicking OK \n\nDone? Click OK');
waitfor(msgbox(text1));

CFA_component = inputdlg('6. Enter CFA component: ');%input CFA
waitfor(~isempty(CFA_component));
CFA_component = str2num(CFA_component{:});

text2 = sprintf('7. EEGLAB menu select Tools > Remove components \n8. Copy the list of components \n9. Click CANCEL \n\nDone? Click OK');
waitfor(msgbox(text2));

%Remove clear artifacts in continuous data
ClearArtifacts_components = inputdlg('10. Paste list of other components: ');%input components
ClearArtifacts_components = str2num(ClearArtifacts_components{:});

EEG_withCFA = pop_subcomp( EEG, ClearArtifacts_components, 0);

%Remove CFA in continuous data
EEG_noCFA = pop_subcomp( EEG_withCFA, CFA_component, 0);
