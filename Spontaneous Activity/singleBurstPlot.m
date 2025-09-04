%%
% cpv 6
exp50_11 = plotOverview("auto", 50, 992, "Intact", 0, 11);
exp50_21 = plotOverview("auto", 50, 992, "Intact", 0, 34);

% gm5b
exp54_11 = plotOverview("auto", 54, 992, "Intact", 0, 11);
exp54_21 = plotOverview("auto", 54, 992, "Intact", 0, 33);

% p1, gm6
exp62_11 = plotOverview("auto", 62, 992, "Intact", 0, 34);
exp62_21 = plotOverview("auto", 62, 992, "Intact", 0, 44);

% gm5a
exp63_11 = plotOverview("auto", 63, 992, "Intact", 0, 70);
exp63_21 = plotOverview("auto", 63, 992, "Intact", 0, 79);

% p2
exp96_11 = plotOverview("auto", 96, 992, "Intact", 0, 1);
exp96_21 = plotOverview("auto", 96, 992, "Intact", 0, 10);



%%
cpv6_11 = exp50_11.Vm2;
cpv6_21 = exp50_21.Vm2;

gm5b_11 = exp54_11.Vm1;
gm5b_21 = exp54_21.Vm1;

gm5a_11 = exp63_11.Vm1;
gm5a_21 = exp63_21.Vm1;

gm6_11 = exp62_11.Vm3;
gm6_21 = exp62_21.Vm3;

p1_11 = exp62_11.Vm2;
p1_21 = exp62_21.Vm2;

p2_11 = exp96_11.Vm3;
p2_21 = exp96_21.Vm3;
%%
cpv4_11 = exp96_11.Vm1;
cpv4_21 = exp96_21.Vm1;

%%
data = [gm5b_11; gm5b_21; gm6_11; gm6_21; gm5a_11; gm5a_21; p1_11; p1_21; p2_11; p2_21; cpv4_11; cpv4_21; cpv6_11; cpv6_21];
labels = ["gm5b", "gm6", "gm5a", "p1", "p2", "cpv4", "cpv6"];
%%
time = exp50_11.t - exp50_11.t(1);
figure
j = 1;
t = tiledlayout(7, 2);
% plot and link y axes along rows for consistent scaling
for i = 1:14
    nexttile
    plot(time, data(i, :), 'k-', LineWidth=1.5)
    set(gca,'xticklabel',[])
    ax = gca;
    ax.XColor = 'none';
    
    if i < 5
        xlim([0, 10])
    else
        xlim([0, 1])
    end

    if i == 1
        title("11 °C ")
    end

    if i == 2
        title("21 °C ")
    end

   if mod(i, 2) == 1
       ylabel(labels(j), Rotation=0)
       j = j + 1;
       neighbor = gca;
   else
       thisOne = gca;
       neighbors = [neighbor, thisOne];
       linkaxes(neighbors, 'y')
   end


end

%%
% make sure all x axes are the same length
allAxes = findall(gcf,'type','axes');

for i= 1:length(allAxes)
    lims = get(allAxes(i),'XLim');
    if i > 10
        allAxes(i).XLim = [lims(1) lims(1) + 10];
    else
        allAxes(i).XLim = [lims(1) lims(1) + 1.5];
    end

end
 
set(findall(gcf,'-property','fontname'),'fontname','arial')
set(findall(gcf,'-property','box'),'box','off')
set(findall(gcf,'-property','fontsize'),'fontsize',17)

%% 

