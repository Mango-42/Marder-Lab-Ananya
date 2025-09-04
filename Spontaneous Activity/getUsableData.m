function [validIdx] = getUsableData(t, v, thresh)

% finds areas where electrode likely fell out in a trace, and returns a 
% vector validIdx that has where recording is usable (1) vs unusuable (0)
% for analysis due to electrode issue

%figure

% plot the initial trace
% subplot(2, 1, 1)
% plot(t / 60, v)

% find regions that are useable or not by using moving avg 
avgVals = movmean(v, 10000);
useable = find( -100 < avgVals & avgVals < thresh);
f1 = zeros([1, length(t)]);
f1(useable) = 1;
f2 = f1;


% all valid regions must be > 2 minutes, otherwise more likely to be sus
changes = ischange(f1);
changes = find(changes);

for i = 1:length(changes) - 1

    % changing from invalid to valid, if between the switchover there's
    % less than 2 min of valid signal between two switch points --> invalid
    if f1(changes(i)) == 1 && sum( f1(changes(i):changes(i+1)) ) < 120000 
       f2(changes(i):changes(i+1)) = 0;
    end
end

changes = ischange(f2);
changes = find(changes);
f3 = f2;

% add 10 s of buffer on each side of an invalid region bc those regions
% are counted in frequency determination for a point
for i = changes
        
        
        % if you change to valid, next 20 seconds are invalid
        if f2(i) == 1

            % make sure not to exceed size of array 
            if i + 20000 > length(v) 
                boundary = length(v);
            else
                boundary = i + 20000;
            end

           f3(i: boundary) = 0;
       % if you change to invalid, last ten seconds are also invalid
        elseif f2(i) == 0

            if i - 20000 < 1
                boundary = 1;
            else
                boundary = i - 20000;
            end

           f3(boundary: i) = 0;
        end

end

% optionally plot 1 for usable, and 0 for unusable
% subplot(2, 1, 2)
% plot(t / 60, f3, 'r')
% hold on
% plot(t / 60, f2, 'b--')
% 
% 
% allAxes = findall(gcf,'type','axes');
% linkaxes(allAxes, 'x')

validIdx = f3;