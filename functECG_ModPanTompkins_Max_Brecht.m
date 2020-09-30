function [posRPeak, valueRPeak] = functECG_ModPanTompkins_Max_Brecht(signal_raw, srate, x)
% Output: position and value of R-peaks

    error(nargchk(2,3,nargin));



    if nargin < 3, x = [1:1: numel(signal_raw)]; end
    t=x./srate;
    
    Fs = 1/(t(2)-t(1));

    signal_filt = bandpass(signal_raw,[5 15], srate);
    
    signal=signal_filt;
     
    %five point derivative
    for i=3:numel(signal)-2
        fivepderiv(i) = (-signal(i+2)+8*signal(i+1)-8*signal(i-1)+signal(i-2))/(12/srate); 
    end
    
    PT_squaring_signal = fivepderiv.^2;
    signal_PT = smooth(PT_squaring_signal,srate/7);
    
    x_PT = x(3:end);
     
    MinPeakDistanceTh = 0.25;
    MinPeakDistance = MinPeakDistanceTh*srate;
    
    %MinPeakProminence = 1e7; 
    %MinPeakProminence = 1.5*mean(signal_PT); 
    MinPeakProminence = 0.9*mean(envelope(signal_PT));
    
    [valueRPeakPT,posRPeakPT] = findpeaks(signal_PT, 'MinPeakHeight',MinPeakProminence, 'MinPeakDistance',MinPeakDistance);
    
%     MinPeakProminence = 0.5*mean(valueRPeakPT); 
     MinPeakProminence = 0.5*mean(valueRPeakPT);%Test for i=52
   
    clear valueRPeakPT posRPeakPT
    [valueRPeakPT,posRPeakPT] = findpeaks(signal_PT, 'MinPeakHeight',MinPeakProminence, 'MinPeakDistance',MinPeakDistance);
    
      clear signal
      signal = signal_raw;
      
    for i=1:numel(posRPeakPT)
        
        tmpinizio = posRPeakPT(i)-50;
        tmpfine =posRPeakPT(i)+50;
        if (tmpinizio < 1)
            tmpinizio =1;
        end
        if (tmpfine > numel(signal))
            tmpfine =numel(signal);
        end
        tmpY = signal(tmpinizio:tmpfine);
        tmpX= x(tmpinizio:tmpfine);
        
        %[valueRPeaktmp,posRPeaktmp] =max(tmpY);
        [valueRPeaktmp,posRPeaktmp,w,p] =findpeaks(tmpY,'SortStr','descend','NPeaks',2);
        
        if (p(1) > p(2))
           posRPeaktmp2=posRPeaktmp(1);
        else
           posRPeaktmp2=posRPeaktmp(2);
        end
        clear posRPeaktmp
        posRPeaktmp=posRPeaktmp2;
        
        posRPeak(i) = posRPeaktmp+tmpinizio-1;
        valueRPeak(i)=tmpY(posRPeaktmp);
    end
   
    %remove duplicates
    [~, ind] = unique(posRPeak);
    posRPeak = posRPeak(ind);
    valueRPeak = valueRPeak(ind);
   
    %plotting - comment this!
%     figure(101);plot(x,signal_raw);
%     hold on; plot(posRPeak,valueRPeak,'xr');
%     figure(102); plot(x,signal_filt);
%     figure(103); plot(x_PT,signal_PT);
%     hold on; plot(posRPeakPT+2,valueRPeakPT,'xr');
end