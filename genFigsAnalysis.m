% GENERATES BINNED SPACE, TIME-NORMALIZED (xy and angle), AND VELOCITY PROFILES (also generates text files to run in R/lmer to compare profiles)
% CODE FOR RUNNING STATS AND VISUALIZATION: TIME-NORMALIZED (T-TESTS ALONG INTERPOLATED BINS; xy and angle) AND ANGLE REGRESSION PLOTS (REGRESSION ALONG INTERPOLATED BINS)
% 9 figs, automatically saved and merged into single pdf

% NEED FUNCTION FILES: savemultfigs, append_pdfs

% NOTES:
% make sure to remove participants who appeared to be randomly guessing, remove from allData
% play with outlier removal conditions, such as people who are using a mouse or trackpad ...
% or those who can or cannot see the blue square, and/or filter to look at only trajs where motion time is longer than latency time

% TODO
% look at slow and fast trials, compare? - Need to know what the average or median response might be... 
% figure out how to do space-bin t-tests between conditions within this program
% do velocity profile stats analysis within this program - not sure how to do this

clear;
close all;
% SET THE FOLLOWING VARIABLES
ROOT = '/Users/nduran/Desktop/ALL_PROJECTS/DecepDyanmicsNew/deceptMTBasic/allData/';
cd(ROOT);

tot_flag = 0;
keep_tot = 0;
tot_all = 0;

%%% for time normalized
keepYF = 0;
keepYT = 0;
keepNF = 0;
keepNT = 0;

%%% for space normalized
timebin1 = 500;
timebin2 = 1000;
timebin3 = 1500;

%%% for velocity profiles
VELAJBIN = 6;

%%% for sorting data
ESCAPE = 80; % escape region around origin where "motion" begins

% PULL IN TRIAL BY TRIAL
files_list = dir(ROOT);
num_files = numel(files_list);
% if (strcmp(holdtemp,'.') ~= 1) && (strcmp(holdtemp,'..') ~= 1) && (strcmp(holdtemp,'.DS_Store') ~= 1),
for k = 4:num_files, % bypasses hidden files, ".", "..", ".DS_Store"
%     k
    information = files_list(k);
    file_name = {information.name};
    fid = fopen([ROOT cell2mat(file_name)]);
    tc = textscan(fid,'%f%f%f%s%s%s%s%s%s%s%s%s%s%s','Delimiter','\t');
    fclose(fid); % clear information, etc

    var_name = {file_name{1}(1:end-4)}; % remove '.txt'
    n1 = textscan(cell2mat(var_name),'%s%s','delimiter','_');    
%   1=t; 2=x; 3=y; 4=prompt; 5=answer; 6=lastword; 7=side; 8=stimlist; 9=turknum; 10=readtime; 11=IP; 12=survey]
 
    % PREP DATA FOR ANALYSIS (SPECIFIC CONSTRAINTS INTRODUCED WITH DIFFERENT STUDIES)
    y = -1*(tc{3}-tc{3}(1));
    x = tc{2}-tc{2}(1);
    t = tc{1}*25;
 
    prompt = cell2mat(tc{4}(1));
    answer = cell2mat(tc{5}(1));
    survey = cell2mat(tc{12}(1));    
%     side = cell2mat(tc{7}(1));
    square = cell2mat(tc{13}(1)); % 1 - yes, see it; 2 - no, do not see it
    trackpad = cell2mat(tc{14}(1)); % 1 - computer mouse; 2 - trackpad        

    readtime = cell2mat(tc{10}(1));
    readtime = str2num(readtime);
    readtime = readtime*10;

    if cell2mat(tc{8}(1)) == '2', % flip the participants in counterbalance 2 condition % stimlist = cell2mat(tc{8}(1));, ALL YES responses go to the LEFT (like stimlist=1)
        x = -1*x;
    end
    
    if (strcmp(prompt,'True_Res')) && (strcmp(answer,'No')) && (strcmp(survey,'Yes')),
        flag = '1';
    elseif (strcmp(prompt,'True_Res')) && (strcmp(answer,'Yes')) && (strcmp(survey,'No')),
        flag = '1';
    elseif (strcmp(prompt,'False_Res')) && (strcmp(answer,'Yes')) && (strcmp(survey,'Yes')),
        flag = '1';
    elseif (strcmp(prompt,'False_Res')) && (strcmp(answer,'No')) && (strcmp(survey,'No')),
        flag = '1';
    else
        flag = '0';
    end
    if (flag == '1'),
        tot_flag = tot_flag + 1;
    end
        
    % SORT OUT POTENTIAL OUTLIERS, BAD DATA - CAN ALSO FILTER OR TAG SLOW TRIALS AND FAST TRIALS HERE?
    
    [latency_indx,xtrim,ytrim] = trim0(x,y,ESCAPE); % only x,y coordinates after "escaping" an initial N pixel range around the origin of movement
    DV_latency = t(latency_indx-1); % latency time (ms) - to begin moving
    DV_inmot = t(length(t))-DV_latency; % motion time (ms) - time spent moving, % !!!! only get ones that people are certain that they are true or false, also, for people clearly randomly guessing, need to remove those here as well

    [out1,out2] = outlierRemove(x,y,100,100); % outlierRemove in master library
    tot_all = tot_all + 1;
    if (flag == '0') && (t(length(t)) < 8000) ... % basic outlier removal, in data folders, remove Ps that have 20% or more flagged data
            && (out1 < .25) && (out2 == 0) && (square == '1') ... % gets rid of wild trajectorioes, also if people could not see the blue square
            && (DV_inmot > DV_latency), % interesting distinction here, looks at trajs where motion time is longer than latency, and vice versa
%             && (trackpad == '1'), % looks only at trajs where Ps are using a computer mouse (1) or trackpad (2)
        
        keep_tot = keep_tot + 1;
        % tag slow or fast trials here? need to figure out the best way...
        
        % for velocity profiles
        [veloc,accel,jerk] = velaj(t,x,y,VELAJBIN);
        
        % INTERPOLATE
        it = (t-t(1)); % takes starts t off at zero
        it = it/it(length(it)); % normalize the it vector (between 0 and 1) 
        ix = interp1(it,x,[0:.01:1]); % make x the same length for all participants, 101 time points
        iy = interp1(it,y,[0:.01:1]);
        
        % COLLECT MEASURES FOR FIGURES AND VARIOUS ANALYSES, FOR EACH CONDITION
        if strcmp(answer,'Yes') && strcmp(prompt,'False_Res'), % condition 1
            keepYF = keepYF + 1;
            
            %%% time-normalized
            Trajs.xinfo.yf(keepYF,:) = ix;
            Trajs.yinfo.yf(keepYF,:) = iy;
            
            %%% binned space
            Trajs.x.yf(keepYF,1:3) = [x(length(t(t<timebin1))) x(length(t(t<timebin2))) x(length(t(t<timebin3)))];
            Trajs.y.yf(keepYF,1:3) = [y(length(t(t<timebin1))) y(length(t(t<timebin2))) y(length(t(t<timebin3)))];
            
            %%%angle regression and angle trajectory 
            Trajs.angle.yf(keepYF,:) = [str2num(cell2mat((n1{1}))) (atan2(ix,iy)*(180/pi))/(max(abs(atan2(ix,iy)))*(180/pi))]; 

            %%%velocity profiles
            veloc(1000) = 0; % pad veloc to trail with zeros
            Trajs.veloc.yf(keepYF,1:1001) = [str2num(cell2mat((n1{1}))) ; veloc]; 

        elseif strcmp(answer,'Yes') && (strcmp(prompt,'True_Res')), % condition 2
            keepYT = keepYT + 1;
            
            %%% time-normalized
            Trajs.xinfo.yt(keepYT,:) = ix;
            Trajs.yinfo.yt(keepYT,:) = iy;

            %%% binned space
            Trajs.x.yt(keepYT,1:3) = [x(length(t(t<timebin1))) x(length(t(t<timebin2))) x(length(t(t<timebin3)))];
            Trajs.y.yt(keepYT,1:3) = [y(length(t(t<timebin1))) y(length(t(t<timebin2))) y(length(t(t<timebin3)))];
            
            %%%angle regression and angle trajectory 
            Trajs.angle.yt(keepYT,:) = [str2num(cell2mat((n1{1}))) (atan2(ix,iy)*(180/pi))/(max(abs(atan2(ix,iy)))*(180/pi))];
 
            %%%velocity profiles
            veloc(1000) = 0; % pad veloc to trail with zeros
            Trajs.veloc.yt(keepYT,1:1001) = [str2num(cell2mat((n1{1}))) ; veloc];            
            
        elseif strcmp(answer,'No') && (strcmp(prompt,'False_Res')), % condition 3
            keepNF = keepNF + 1;
            
            %%% time-normalized
            Trajs.xinfo.nf(keepNF,:) = ix;
            Trajs.yinfo.nf(keepNF,:) = iy;

            %%% binned space
            Trajs.x.nf(keepNF,1:3) = [x(length(t(t<timebin1))) x(length(t(t<timebin2))) x(length(t(t<timebin3)))];
            Trajs.y.nf(keepNF,1:3) = [y(length(t(t<timebin1))) y(length(t(t<timebin2))) y(length(t(t<timebin3)))];
            
            %%%angle regression and angle trajectory 
            Trajs.angle.nf(keepNF,:) = [str2num(cell2mat((n1{1}))) (atan2(ix,iy)*(180/pi))*-1/(max(abs(atan2(ix,iy)))*(180/pi))];
            
            %%%velocity profiles
            veloc(1000) = 0; % pad veloc to trail with zeros
            Trajs.veloc.nf(keepNF,1:1001) = [str2num(cell2mat((n1{1}))) ; veloc]; 
            
        else % condition 4
            keepNT = keepNT + 1;
            
            %%% time-normalized
            Trajs.xinfo.nt(keepNT,:) = ix;
            Trajs.yinfo.nt(keepNT,:) = iy;
            
            %%% binned space
            Trajs.x.nt(keepNT,1:3) = [x(length(t(t<timebin1))) x(length(t(t<timebin2))) x(length(t(t<timebin3)))];
            Trajs.y.nt(keepNT,1:3) = [y(length(t(t<timebin1))) y(length(t(t<timebin2))) y(length(t(t<timebin3)))];
            
            %%%angle regression and angle trajectory 
            Trajs.angle.nt(keepNT,:) = [str2num(cell2mat((n1{1}))) (atan2(ix,iy)*(180/pi))*-1/(max(abs(atan2(ix,iy)))*(180/pi))];
            
            %%%velocity profiles
            veloc(1000) = 0; % pad veloc to trail with zeros
            Trajs.veloc.nt(keepNT,1:1001) = [str2num(cell2mat((n1{1}))) ; veloc];         
        
        end
        clear veloc    
    end
end





%%%%
%FIGURES, STATS, AND PREP FOR R
%%%%





%% TIME NORMALIZED PLOTS XY

% figure('Visible','Off')
figure(1)
hold on
%%%%%%%%%%%%%%%%%%%%%%%
plot(mean(Trajs.xinfo.yf),mean(Trajs.yinfo.yf),'ro-','linewidth',2) % 
plot(mean(Trajs.xinfo.yt),mean(Trajs.yinfo.yt),'ko-','linewidth',2)
plot(mean(Trajs.xinfo.nf),mean(Trajs.yinfo.nf),'rx-','linewidth',2) % 
plot(mean(Trajs.xinfo.nt),mean(Trajs.yinfo.nt),'kx-','linewidth',2)

% plot(mean(Trajs.xinfo.yf),mean(Trajs.yinfo.yf),'ro-','linewidth',2) % plot them all going in the same direction, o = yes 
% plot(mean(Trajs.xinfo.yt),mean(Trajs.yinfo.yt),'ko-','linewidth',2) % plot them all going in the same direction, o = yes
% plot(mean(Trajs.xinfo.nf)*-1,mean(Trajs.yinfo.nf),'rx-','linewidth',2) % plot them all going in the same direction, x = no
% plot(mean(Trajs.xinfo.nt)*-1,mean(Trajs.yinfo.nt),'kx-','linewidth',2) % plot them all going in the same direction, x = no
%%%%%%%%%%%%%%%%%%%%%%%

fh = figure(1); % returns the handle to the figure object
set(fh, 'color', 'white'); % sets the background color to white
set(gca,'Box','off','TickDir','out','FontSize',14,'XTick',[-350 -250 -150 0 150 250 350],'FontName','Times'); 
set(gca, 'YTick', 600,'FontSize', 14,'FontName','Times');
drawaxis(gca, 'y', 0, 'movelabel', 1)
set(gca,'ycolor',[1,1,1]);
% set(fh,'name','time_norm_xy','numbertitle','off')
title('time norm xy')

legend('False/yes','True/yes','False/no','True/no','Location','NorthEastOutside')

scrsz = get(0,'ScreenSize');
set(fh,'Position',[1 scrsz(4)/2.5 scrsz(3)/2.5 scrsz(4)/2.5])

% text(275,490,'NO','FontSize', 16, 'FontWeight', 'normal','FontName','Times');
% text(-315,490,'YES','FontSize', 16, 'FontWeight', 'normal','FontName','Times');
% text(-70,-50,'x-coordinate','FontSize', 16, 'FontWeight', 'normal','FontName','Times');
% text(20,350,'y-coordinate','FontSize', 16, 'FontWeight', 'normal','FontName','Times','Rotation', 90);

% set(gcf, 'PaperPosition', [0, 0, 10, 6]);
% saveas(gcf, 'time_normalized', 'jpeg');
% close all 
hold off

%% TIME NORMALIZED PLOTS ANGLE

% figure('Visible','Off')
figure(3)
hold on
%%%%%%%%%%%%%%%%%%%%%%%
plot(mean(Trajs.angle.yf(:,2:end)),'ro-','linewidth',2)
plot(mean(Trajs.angle.yt(:,2:end)),'ko-','linewidth',2)
plot(mean(Trajs.angle.nf(:,2:end)),'rx-','linewidth',2)
plot(mean(Trajs.angle.nt(:,2:end)),'kx-','linewidth',2)
plot(1:102,0,'k-','linewidth',2)

% plot(mean(Trajs.xinfo.yf),mean(Trajs.yinfo.yf),'ro-','linewidth',2) % plot them all going in the same direction, o = yes 
% plot(mean(Trajs.xinfo.yt),mean(Trajs.yinfo.yt),'ko-','linewidth',2) % plot them all going in the same direction, o = yes
% plot(mean(Trajs.xinfo.nf)*-1,mean(Trajs.yinfo.nf),'rx-','linewidth',2) % plot them all going in the same direction, x = no
% plot(mean(Trajs.xinfo.nt)*-1,mean(Trajs.yinfo.nt),'kx-','linewidth',2) % plot them all going in the same direction, x = no
%%%%%%%%%%%%%%%%%%%%%%%

fh = figure(3); % returns the handle to the figure object
set(fh, 'color', 'white'); % sets the color to white
set(gca,'Box','off','TickDir','out','FontSize',14,'FontName','Times'); % here gca means get current axis

legend('False/yes','True/yes','False/no','True/no','Location','NorthEastOutside')

scrsz = get(0,'ScreenSize');
set(fh,'Position',[1 scrsz(4)/2.5 scrsz(3)/2.5 scrsz(4)/2.5])
% set(fh,'name','time_norm_ang','numbertitle','off')
title('time norm ang')

% set(gcf, 'PaperPosition', [0, 0, 10, 6]);
% saveas(gcf, 'time_normalized', 'jpeg');
% close all 
hold off

%% ANGLE REGRESSION ANALYSIS

% for subjnum = unique(Trajs.angle.yf(:,1)), % generate beta weights on a participant by participant basis? not enough trials for this type of design
clear Beta
for i = 2:102,
    
    % column 1 = participant number, column 2 = DV (angle), column 3 = time bin, column 4 = yes vs. no, column 5 = false vs. true, column 6 = interaction
    getColYF = [Trajs.angle.yf(:,1) Trajs.angle.yf(:,i) i*(ones(size(Trajs.angle.yf,1),1)) 1*(ones(size(Trajs.angle.yf,1),1)) 1*(ones(size(Trajs.angle.yf,1),1)) 1*(ones(size(Trajs.angle.yf,1),1))]; 
    getColYT = [Trajs.angle.yt(:,1) Trajs.angle.yt(:,i) i*(ones(size(Trajs.angle.yt,1),1)) 1*(ones(size(Trajs.angle.yt,1),1)) -1*(ones(size(Trajs.angle.yt,1),1)) -1*(ones(size(Trajs.angle.yt,1),1))]; 
    getColNF = [Trajs.angle.nt(:,1) Trajs.angle.nt(:,i) i*(ones(size(Trajs.angle.nt,1),1)) -1*(ones(size(Trajs.angle.nt,1),1)) -1*(ones(size(Trajs.angle.nt,1),1)) 1*(ones(size(Trajs.angle.nt,1),1))]; 
    getColNT = [Trajs.angle.nf(:,1) Trajs.angle.nf(:,i) i*(ones(size(Trajs.angle.nf,1),1)) -1*(ones(size(Trajs.angle.nf,1),1)) 1*(ones(size(Trajs.angle.nf,1),1)) -1*(ones(size(Trajs.angle.nf,1),1))]; 

    masterSub = [getColYF ; getColYT ; getColNF ; getColNT]; 
    dv_var = masterSub(:,2);
    iv_var = [ones(size(masterSub(:,4))) masterSub(:,4) masterSub(:,5) masterSub(:,6)];
    stats_beta = regress(dv_var,iv_var); 

    Beta.all(i,1:3) = [stats_beta(2) stats_beta(3) stats_beta(4)]; % drop intercept, include yes/no, false/true, interaction
end

figure(4)
hold on
% plot(Beta.all(:,1),'col','k','LineWidth',3) % yes/no effect 
% plot(Beta.all(:,2),'col','b','LineWidth',3) % true/false effect 
plot(smooth(Beta.all(:,1),15,'moving'),'col','k','LineWidth',3) % yes/no effect 
plot(smooth(Beta.all(:,2),15,'moving'),'col','b','LineWidth',3) % true/false effect 
% plot(smooth(Beta.all(:,3),15,'moving'),'col','k','LineWidth',3) % interaction effect 

fh = figure(4); % returns the handle to the figure object
set(fh, 'color', 'white'); % sets the color to white
set(gca,'Box','off','TickDir','out','FontSize',14,'FontName','Times'); % here gca means get current axis

scrsz = get(0,'ScreenSize');
set(fh,'Position',[1 scrsz(4)/2.5 scrsz(3)/2.5 scrsz(4)/2.5])

legend('Yes/No','True/False','Location','NorthEastOutside')
% set(fh,'name','ang_regression','numbertitle','off')
title('ang regression')

hold off

%% BINNED SPACE PLOTS

figure(2)
plot([0,mean(Trajs.x.yf(:,1))],[0,mean(Trajs.y.yf(:,1))],'r-','linewidth',2) % 
hold on
plot([mean(Trajs.x.yf(:,1)),mean(Trajs.x.yf(:,2))],[mean(Trajs.y.yf(:,1)),mean(Trajs.y.yf(:,2))],'r-','linewidth',2)
plot([mean(Trajs.x.yf(:,2)),mean(Trajs.x.yf(:,3))],[mean(Trajs.y.yf(:,2)),mean(Trajs.y.yf(:,3))],'r-','linewidth',2)
plot(mean(Trajs.x.yf(:,1)),mean(Trajs.y.yf(:,1)),'or','MarkerSize',15,'linewidth',2)
plot(mean(Trajs.x.yf(:,2)),mean(Trajs.y.yf(:,2)),'*r','MarkerSize',15,'linewidth',2) % 
plot(mean(Trajs.x.yf(:,3)),mean(Trajs.y.yf(:,3)),'xr','MarkerSize',15,'linewidth',2) % 

plot([0,mean(Trajs.x.yt(:,1))],[0,mean(Trajs.y.yt(:,1))],'--k','linewidth',2) % 
plot([mean(Trajs.x.yt(:,1)),mean(Trajs.x.yt(:,2))],[mean(Trajs.y.yt(:,1)),mean(Trajs.y.yt(:,2))],'--k','linewidth',2)
plot([mean(Trajs.x.yt(:,2)),mean(Trajs.x.yt(:,3))],[mean(Trajs.y.yt(:,2)),mean(Trajs.y.yt(:,3))],'--k','linewidth',2)
plot(mean(Trajs.x.yt(:,1)),mean(Trajs.y.yt(:,1)),'ok','MarkerSize',15,'linewidth',2)
plot(mean(Trajs.x.yt(:,2)),mean(Trajs.y.yt(:,2)),'*k','MarkerSize',15,'linewidth',2) % 
plot(mean(Trajs.x.yt(:,3)),mean(Trajs.y.yt(:,3)),'xk','MarkerSize',15,'linewidth',2) % 

plot([0,mean(Trajs.x.nf(:,1))],[0,mean(Trajs.y.nf(:,1))],'r-','linewidth',2) % 
plot([mean(Trajs.x.nf(:,1)),mean(Trajs.x.nf(:,2))],[mean(Trajs.y.nf(:,1)),mean(Trajs.y.nf(:,2))],'r-','linewidth',2)
plot([mean(Trajs.x.nf(:,2)),mean(Trajs.x.nf(:,3))],[mean(Trajs.y.nf(:,2)),mean(Trajs.y.nf(:,3))],'r-','linewidth',2)
plot(mean(Trajs.x.nf(:,1)),mean(Trajs.y.nf(:,1)),'or','MarkerSize',15,'linewidth',2)
plot(mean(Trajs.x.nf(:,2)),mean(Trajs.y.nf(:,2)),'*r','MarkerSize',15,'linewidth',2) % 
plot(mean(Trajs.x.nf(:,3)),mean(Trajs.y.nf(:,3)),'xr','MarkerSize',15,'linewidth',2) % 

plot([0,mean(Trajs.x.nt(:,1))],[0,mean(Trajs.y.nt(:,1))],'--k','linewidth',2) % 
plot([mean(Trajs.x.nt(:,1)),mean(Trajs.x.nt(:,2))],[mean(Trajs.y.nt(:,1)),mean(Trajs.y.nt(:,2))],'--k','linewidth',2)
plot([mean(Trajs.x.nt(:,2)),mean(Trajs.x.nt(:,3))],[mean(Trajs.y.nt(:,2)),mean(Trajs.y.nt(:,3))],'--k','linewidth',2)
plot(mean(Trajs.x.nt(:,1)),mean(Trajs.y.nt(:,1)),'ok','MarkerSize',15,'linewidth',2)
plot(mean(Trajs.x.nt(:,2)),mean(Trajs.y.nt(:,2)),'*k','MarkerSize',15,'linewidth',2) % 
plot(mean(Trajs.x.nt(:,3)),mean(Trajs.y.nt(:,3)),'xk','MarkerSize',15,'linewidth',2) % 

fh = figure(2);
set(fh, 'color', 'white'); % sets the color to white
set(gca,'Box','off','TickDir','out','FontSize',14,'FontName','Times'); % here gca means get current axis
set(gca, 'YTick', [.80],'FontSize',14,'FontName','Times');
drawaxis(gca, 'y', 0, 'movelabel', 1)
set(gca,'ycolor',[1,1,1]);
% set(fh,'name','space_norm_xy','numbertitle','off')
title('space norm xy')

scrsz = get(0,'ScreenSize');
set(fh,'Position',[1 scrsz(4)/2.5 scrsz(3)/2.5 scrsz(4)/2.5])

% text(.6,.77,'NO','FontSize', 16, 'FontWeight', 'normal','FontName','Times');
% text(-.93,.77,'YES','FontSize', 16, 'FontWeight', 'normal','FontName','Times');
% text(-.12,-.085,'normed-x','FontSize', 16, 'FontWeight', 'normal','FontName','Times');
% text(.04,.59,'normed-y','FontSize', 16, 'FontWeight', 'normal','FontName','Times','Rotation', 90);
% set(gcf, 'PaperPosition', [0, 0, 10, 6]);
% saveas(gcf, 'time_normalized', 'jpeg');
% close all 
hold off

%% TIME NORMALIZED ANALYSIS (SHOULD REPLACE THIS WITH GROWTH CURVE ANALYSIS)
%% T-TESTS ON DIFFERENCES BETWEEN X-VALUES
%% T-TESTS ON DIFFERENCES BETWEEN ANGLE 

NTvNF1 = [];
YTvYF1 = [];
NTvYT1 = [];
NFvYF1 = [];

NTvNF2 = [];
YTvYF2 = [];
NTvYT2 = [];
NFvYF2 = [];

% run t-tests at each time step, along the x values 
for i=1:101,
	[h1,p1,stats1] = ttest2(Trajs.xinfo.nt(:,i),Trajs.xinfo.nf(:,i)); % nt vs nf
    [h2,p2,stats2] = ttest2(Trajs.angle.nt(:,i),Trajs.angle.nf(:,i)); % nt vs nf
    NTvNF1 = [NTvNF1 ; p1];
    NTvNF2 = [NTvNF2 ; p2];

    [h1,p1,stats1] = ttest2(Trajs.xinfo.yt(:,i),Trajs.xinfo.yf(:,i)); % yt vs. yf 
    [h2,p2,stats2] = ttest2(Trajs.angle.yt(:,i),Trajs.angle.yf(:,i)); % nt vs nf
    YTvYF1 = [YTvYF1 ; p1]; % save p values
    YTvYF2 = [YTvYF2 ; p2]; % save p values
    
    [h1,p1,stats1] = ttest2(Trajs.xinfo.nt(:,i),Trajs.xinfo.yt(:,i)*-1); % nt vs. yt
    [h2,p2,stats2] = ttest2(Trajs.angle.nt(:,i),Trajs.angle.yt(:,i)); % nt vs nf
    NTvYT1 = [NTvYT1 ; p1];
    NTvYT2 = [NTvYT2 ; p2];
    
	[h1,p1,stats1] = ttest2(Trajs.xinfo.nf(:,i),Trajs.xinfo.yf(:,i)*-1); % nf vs. yf
    [h2,p2,stats2] = ttest2(Trajs.angle.nf(:,i),Trajs.angle.yf(:,i)); % nt vs nf
    NFvYF1 = [NFvYF1 ; p1];    
    NFvYF2 = [NFvYF2 ; p2];        
end

% for x,y trajs
test_NTvNF1 = [[1:101]' NTvNF1 < .05]; 
test_YTvYF1 = [[1:101]' YTvYF1 < .05];
test_NTvYT1 = [[1:101]' NTvYT1 < .05]; 
test_NFvYF1 = [[1:101]' NFvYF1 < .05];

fh = figure(6);
hold on
plot(test_NTvNF1(:,2),'ro-')
plot(test_YTvYF1(:,2),'ro--')
% set(fh,'name','ttest_xy_TF','numbertitle','off')
title('ttest xy TF')
hold off
fh = figure(7);
hold on
plot(test_NTvYT1(:,2),'kx-')
plot(test_NFvYF1(:,2),'kx--')
% set(fh,'name','ttest_xy_NY','numbertitle','off')
title('ttest xy NY')
hold off

% for angle trajs
test_NTvNF2 = [[2:102]' NTvNF2 < .05]; 
test_YTvYF2 = [[2:102]' YTvYF2 < .05];
test_NTvYT2 = [[2:102]' NTvYT2 < .05]; 
test_NFvYF2 = [[2:102]' NFvYF2 < .05];

fh = figure(8);
hold on
plot(test_NTvNF2(:,2),'ro-')
plot(test_YTvYF2(:,2),'ro--')
% set(fh,'name','ttest_ang_TF','numbertitle','off')
title('ttest ang TF')
hold off
fh = figure(9);
hold on
plot(test_NTvYT2(:,2),'kx-')
plot(test_NFvYF2(:,2),'kx--')
% set(fh,'name','ttest_ang_YN','numbertitle','off')
title('ttest ang YN')
hold off

%% VELOCITY PLOTS

figure(5)
% clear Newvels
% colMark = 0;
% for i=1:VELAJBIN:1000,
%     colMark = colMark + 1;
%     Newvels.yf(:,colMark) = mean(Trajs.veloc.yf(:,i:i+(VELAJBIN-1)),2); % is this absolutely necessary, smoothing
%     Newvels.yt(:,colMark) = mean(Trajs.veloc.yt(:,i:i+(VELAJBIN-1)),2); 
%     Newvels.nf(:,colMark) = mean(Trajs.veloc.nf(:,i:i+(VELAJBIN-1)),2); 
%     Newvels.nt(:,colMark) = mean(Trajs.veloc.nt(:,i:i+(VELAJBIN-1)),2); 
% end

hold on
% plot((1:50)*(VELAJBIN*25),mean(Newvels.yf(:,1:50)))
% plot((1:50)*(VELAJBIN*25),mean(Newvels.yt(:,1:50)))
% plot((1:50)*(VELAJBIN*25),mean(Newvels.nf(:,1:50)))
% plot((1:50)*(VELAJBIN*25),mean(Newvels.nt(:,1:50)))
% hold off

plot((2:125)*25,smooth(mean(Trajs.veloc.yf(:,2:125)),15,'moving'),'r--','LineWidth',3) % sampled every 25 ms
plot((2:125)*25,smooth(mean(Trajs.veloc.yt(:,2:125)),15,'moving'),'k--','LineWidth',3) 
plot((2:125)*25,smooth(mean(Trajs.veloc.nf(:,2:125)),15,'moving'),'r-','LineWidth',3) 
plot((2:125)*25,smooth(mean(Trajs.veloc.nt(:,2:125)),15,'moving'),'k-','LineWidth',3) 
hold off

fh = figure(5); % returns the handle to the figure object
% set(fh,'name','veloc_prof','numbertitle','off')
title('veloc prof')
% set(fh, 'color', 'white'); % sets the color to white
set(gca,'Box','off','TickDir','out','FontSize',14,'FontName','Times'); % here gca means get current axis   

xlabel('Time (ms)','FontSize', 16, 'FontWeight', 'normal','FontName','Times');
ylabel('Velocity (pixels/sec)','FontSize',16, 'FontWeight', 'normal','Rotation',90);

%% velocity profiles: generate text files for analysis with R 
% system('rm -f all_vel_data_nf.txt');
% system('rm -f all_vel_data_nt.txt');
% system('rm -f all_vel_data_yf.txt');
% system('rm -f all_vel_data_yt.txt');
% 
% varnames = ['yf';'yt';'nf';'nt'];
% ny = ['y','y','n','n'];
% tf = ['f','t','f','t'];
% 
% for fl=1:length(varnames),
%     fh = fopen(['all_vel_data_' varnames(fl,:) '.txt'],'a');
%     for i=1:eval(['size(Trajs.veloc.' [varnames(fl,:) '(:,1:125)'] ',1)'])   
%         i;
%         for j=2:eval(['size(Trajs.veloc.' [varnames(fl,:) '(:,1:125)'] ',2)'])  
%             j;
% %             c('subj', 'answer', 'prompt', 'time', 'velocity')
%             fprintf(fh,'%d %s %s %d %d\n', eval([['Trajs.veloc.' varnames(fl,:)] '(i,1)']), ny(fl), tf(fl), j*25, eval([['Trajs.veloc.' varnames(fl,:)] '(i,j)']) ); 
%         end
%     end
%     fclose(fh);
% end


%%
ROOT = '/Users/nduran/Desktop/ALL_PROJECTS/DecepDyanmicsNew/deceptMTBasic';
cd(ROOT);

savemultfigs % opens a GUI that saves all open figures to PDFs

% RUN AFTER ALL FIGS HAVE BEEN SAVED TO CWD
% append_pdfs(['inmot_MandT_' num2str(keep_tot) '_' num2str(tot_all) '.pdf'], 'filename1.pdf', 'filename2.pdf', 'filename3.pdf', 'filename4.pdf', 'filename5.pdf', 'filename6.pdf', 'filename7.pdf', 'filename8.pdf', 'filename9.pdf')
% system('rm -f filename1.pdf'); system('rm -f filename2.pdf'); system('rm -f filename3.pdf'); system('rm -f filename4.pdf');
% system('rm -f filename5.pdf'); system('rm -f filename6.pdf'); system('rm -f filename7.pdf'); system('rm -f filename8.pdf');
% system('rm -f filename9.pdf');

