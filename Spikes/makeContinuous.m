function [cdata, cspikes] = makeContinuous(data, varargin)
    
% Description: makes continuous data from preloaded file separated abf
% data, and also can do the same for spikes when file length of data
% collected varies

    fn = fieldnames(data);
    
    cdata = struct;
    
    for name = 1:length(fn)
        store = [];
        for i = 1:length(data.(fn{name}))

            store = [store data.(fn{name}){i}];
        end
        cdata.(fn{name}) = store;
    end

    cdata.t = .0001 * (0:length(cdata.(fn{1})));
    cdata.t = cdata.t(1:end - 1);

    % if given spikes, align them with corresponding data files 
    if nargin == 2
        spikes = varargin{2};

        fn = fieldnames(spikes);
        
        cspikes = struct;
        
        for name = 1:length(fn)
            store = [];
            for i = 1:length(spikes.(fn{name}))
                if i == 1
                    elapsedTime = 0;
                else
                    elapsedTime = elapsedTime + (length(data.(fn{1}){i - 1}) /10000);
                end

                store = [store ;(spikes.(fn{name}){i} + elapsedTime)];
            end
        cspikes.(fn{name}) = store;
        end

    end