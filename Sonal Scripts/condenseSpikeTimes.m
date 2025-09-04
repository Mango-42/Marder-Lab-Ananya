folderid = "/Users/ananyadalal/Documents/MATLAB/tools/scripts/Marder/Crabsorts/992_058";
fids = dir(folderid);
elapsedTime = 0;
%   PD_int = []; %spiketimes you want - initialize
%    IC = [];
%    VD = [];
%      DG = [];
     LP = [];
%     PD = [];
%      LC= [];
%     SC= [];
%     SC2= [];
%     LC2= [];
%       PY = [];

for ii=1:(length(fids)) %for all the files in our data set...
   if mod(ii,20)==1  %print the file number ever 20 files
            ii;
   end

    if strfind(fids(ii).name,'crabsort') %only look at files that end in 'crabsort'
        
         load(fids(ii).name,'-mat'); %save the data from the abf file
         
        try 
            next_LP = ...
                 crabsort_obj.spikes.lvn.LP*1e-4 + elapsedTime;
        catch %catch files where there are no spikes
            next_LP = []; 
        end       
%         try
%             next_IC = ...
%                 crabsort_obj.spikes.mvn.IC*1e-4 + elapsedTime; 
%         catch, next_IC = []; 
%         end
%         try
%             next_VD = ...
%                 crabsort_obj.spikes.mvn.VD*1e-4 + elapsedTime;
%         catch, next_VD = []; 
%         end
%         try
%             next_DG = ...
%                 crabsort_obj.spikes.dgn.DG*1e-4 + elapsedTime;
%         catch,  next_DG = []; 
%         end
%          try
%             next_agr = ...
%                 crabsort_obj.spikes.dgn.AGR*1e-4 + elapsedTime;
%         catch,  next_agr = []; 
%         end
%         try
%             next_LC = ...
%                 crabsort_obj.spikes.cg1.LC1*1e-4 + elapsedTime;
%         catch, next_LC = [];
%         end
%         try
%             next_SC = ...
%                 crabsort_obj.spikes.cg1.SC1*1e-4 + elapsedTime;
%         catch, next_SC = [];
%         end
%         try
%             next_LC2 = ...
%                 crabsort_obj.spikes.cg2.LC2*1e-4 + elapsedTime;
%         catch, next_LC2 = [];
%         end
%         try
%             next_SC2 = ...
%                 crabsort_obj.spikes.cg2.SC2*1e-4 + elapsedTime;
%         catch, next_SC2 = [];
%         end
%         try
%             next_PD = ...
%                 crabsort_obj.spikes.pdn.PD*1e-4 + elapsedTime;
%         catch, next_PD = [];
%         end
%         try
%             next_PD_int = ...
%                 crabsort_obj.spikes.PD.PD*1e-4 + elapsedTime;
%         catch, next_PD_int = [];
%          end
%         try
%             next_PY = ...
%                 crabsort_obj.spikes.pyn.PY*1e-4 + elapsedTime;
%         catch, next_PY = [];
%         end
 %             if there are spikes, get the spikes from this file on the
%             nerve that we are interested in 
%             CHANGE FOR DIFFERENT NERVES/UNITS
                    
            LP = [LP; next_LP]; %add current file spikes to the overall array of spikes
%           IC = [IC; next_IC];
%           VD = [VD; next_VD];
%              DG = [DG; next_DG];
%            PD = [PD; next_PD];
%            LC = [LC; next_LC];
%            PD_int = [PD_int; next_PD_int];
% %          
%             SC = [SC; next_SC];
%             SC2 = [SC2; next_SC2];
%             LC2 = [LC2; next_LC2];
%             PY = [PY; next_PY];
%         
        elapsedTime = elapsedTime + 120; %add up overall time
     end 

    
end