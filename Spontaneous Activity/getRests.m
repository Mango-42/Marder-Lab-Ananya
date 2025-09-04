function [idxRest, vrests] = getRests(t, v)
    
    %% Description: gets baseline vrest for a trace 
    % Looks for areas of consistency and interpolates values between them
    % Instead of using negative peaks which can sometimes produce outliers

    % Inputs:
        % t (double []) - time series data to plot against at the end
        % v (double []) - voltage trace 
    
    % Outputs:
        % idxRest (int []) - indices for which there is interpolated vrest
            % data, matching time series. 
        % vrests (double []) - resting membrane voltage in mV at idxRests

    % Last edited: Ananya Dalal July 16


    changes = ischange(v, "mean", Threshold=1000);
    idxChanges = find(changes);
    
    timeBetweenChanges = diff(idxChanges);
    % at least 3 seconds of time between "changes" (spikes)
    idxLongRests = find(timeBetweenChanges > 3000);
    
    % remove 1s buffer on each side where voltage may be coming back to rest
    t1 = idxChanges(idxLongRests) + 1000;
    t2 = idxChanges(idxLongRests + 1) - 1000;
    
    idxRest = [];
    vRest = [];
    for i = 1:length(t1)
        % add the indices for which there's at least 3 sec of rest
    
        idxRest = [idxRest, t1(i):t2(i)];
    
        % get the mean value of sections of rest 
        meanVal = mean(v(t1(i):t2(i)));
        vRest = [vRest, ones([1 (t2(i)-t1(i) + 1)]) * meanVal];
    
    end
    
    %% Interpolate values between sections of rest 
    vrests = interp1(idxRest, vRest, idxRest(1):idxRest(end));
    time = t(idxRest(1):idxRest(end));
    idxRest = idxRest(1):idxRest(end);
    
    disp(idxRest(1:100))



%% Optionally plot for verification
figure
subplot(2, 1, 1)
plot(t, v)

subplot(2, 1, 2)
plot(time, vrests)



allAxes = findall(gcf,'type','axes');
linkaxes(allAxes, 'x')


