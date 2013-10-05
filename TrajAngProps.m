
% STANDARDIZED CODE FOR TRAJS/ANG ANALYSIS 
% TAKES AS INPUT: SINGLE TRAJECTORY (x,y) AND TIME STAMPS (t)
% INDICES(27), OUTLIER MEASURES(9)

% NECESSARY INITIALIZATION REQUIREMENTS 
% 1) Analysis over single trajectories (raw), ensure trajectory begins at 0,0
% 2) Correct for counterbalancing schemes (if used), all answer/target of same type on one or the other side (e.g., all "YES" responses on RightSide, all "NO" responses on LeftSide)
% 3) Make sure to include the following functions: trim0, trim1, xflip, velaj, sampen (also uses atan2, trapz)
% 4) If generating figures, make sure to create a folder named "figure" in ROOT (might also need to correct pathname for saving)

clear;
% SET THE FOLLOWING VARIABLES
ROOT = '...'; % set the root directory where experiment files/trajectories are included
FIGURE_RUN = 1; % figure generation, either 1 to run or 0 to not run
ESCAPE = 100; % escape region around origin where latency/motion measures begin, in pixels
ESCAPE_INIT = 100; % region around origin in which initial angle is measured, in pixels
DWELL_FIN = 100; % region around final click where dwell measures are computed, in pixels
VELAJBIN = 6; % number of timesteps in which to compute/average velocity
% also remember to adjust sampen defaults if desired

cd(ROOT);

%%% initializing, adding headers UPDATE CONDITION CODES %%%
f1o = fopen('trajAngDVs.xls','w'); 

fprintf(f1o,'subnum\ttrialnum\t...'); % add all experiment-specific condition codes
fprintf(f1o,'tottm\tlatency\tinmot\tdwell\tdist\t');       
fprintf(f1o,'distInmot\tmaxVeloc\tvelocStart\tmaxAcc\taccStart\t');   
fprintf(f1o,'jerk\txflpLat\txflpMot\txflpDwl\taflpLat\t');       
fprintf(f1o,'aflpMot\taflpDwl\tareaUnder\tareaUnderX\ttmaxDeviat\t');         
fprintf(f1o,'deviatStart\ttmaxAngle\ttangleStart\tinitAngle\t');  
fprintf(f1o,'maxX\tminX\tmaxY\tminY\tpercentNeg\t');
fprintf(f1o,'longLat\tvelocLat\taccelLat\tlatBelowY\t');
fprintf(f1o,'xe1\txe2\txe3\txe4\txe5\t');
fprintf(f1o,'ye1\tye2\tye3\tye4\tye5\t');
fprintf(f1o,'ae1\tae2\tae3\tae4\tae5\n');

% [INSERT EXPERIMENT-SPECIFIC CODE HERE TO GET PARTICIPANT DATA, TRAJECTORY BY TRAJECTORY]


%% properties over trajs only

%%% total time %%%%
DV_total_time = t(length(t));

%%%% latency time only %%%%
%%%% motion time w/ no latency (includes dwell time) %%%%
%%%% dwell time only %%%%
[latency_indx xtrim ytrim] = trim0(x,y,ESCAPE); % only x,y coordinates after "escaping" an initial N pixel range around the origin of movement
DV_latency = t(latency_indx-1); % latency time (ms) - to begin moving
DV_inmot = t(length(t))-DV_latency; % motion time (ms) - time spent moving
xlatency = x(1:latency_indx-1); % the truncated x trajectory only in latency region (e.g., 100 pixel radius)
ylatency = y(1:latency_indx-1); % the truncated y trajectoy only in latency region (e.g., 100 pixel radius)
[latency_indx3 xtrim3 ytrim3] = trim1(x,y,DWELL_FIN); % only x,y coordinates within N pixel range around the final click "response dwell region"
DV_dwell = t(end)-t(latency_indx3+1); % response dwell time (ms) - to commit to a final response

%%%% distance (euclidean) %%%%
distx = (x(2:length(x))-x(1:length(x)-1)).^2; % (x2-x1)^2
disty = (y(2:length(y))-y(1:length(y)-1)).^2; % (y2-y1)^2
DV_dist = sum(sqrt(distx+disty)); % distance traveled by one trajectory

%%%% dist w/ no latency %%%%
distlatx = (xtrim(2:length(xtrim))-xtrim(1:length(xtrim)-1)).^2; % (x2-x1)^2
distlaty = (ytrim(2:length(ytrim))-ytrim(1:length(ytrim)-1)).^2; % (y2-y1)^2
DV_dist_inmot = sum(sqrt(distlatx+distlaty)); % distance traveled by one trajectory... outside of the latency ESCAPE pixel region!

%%%% velocity max value %%%%
%%%% velocity max timing %%%%
%%%% acceleration %%%% 
%%%% jerk (number of increases and decreases) %%%%
[veloc accel jerk] = velaj(t,x,y,VELAJBIN); % within a VELAJBIN window
% veloc = veloc(~isinf(veloc)); % fix for problems with time sampling in early python code           
% accel = accel(~isinf(accel)); % fix for problems with time sampling in early python code           
DV_velmax = max(veloc); % maximum velocity
DV_velmax_start = t(find(veloc==DV_velmax,1)); % at what point does maximum velocity occur
DV_accmax = max(accel); % maximum acceleration
DV_accmax_start = t(find(accel==DV_accmax,1)+VELAJBIN); % at what point does maximum acceleration occur
% DV_accmin = min(accel); % minimum acceleration
% DV_accmin_start = t(find(accel==DV_accmin,1)+VELAJBIN); % at what point is there the greatest change in decreasing velocity
DV_jerk = 'NA'; % not sure how to interpret jerk

%% properties over trajs and angle

trajAng = atan2(x,y)*(180/pi); % the trajectories converted to angle plane, with implicit origin at 0,0; compared to y-axis (at 0 degrees), fans out between 0 to 90/-90, with 45/-45 degree angle being direct route to target, see Scherbaum et al, 2010 (Cognition) 

%%%% change in direction (flips) for x (latency, motion, dwell) %%%%
%%%% change in direction for angle trajectories (latency, motion, dwell) %%%% 
DV_xflp_lat = xflip(xlatency); % look at function file % flipping in the first X pixel radius (depends on how trim0 was set above)
DV_xflp_mot = xflip(xtrim); % look at function file % flipping after the first X pixel radius (depends on how trim0 was set above)
DV_aflp_lat = xflip(trajAng(1:latency_indx-1)); 
DV_aflp_mot = xflip(trajAng(latency_indx:length(trajAng))); 

xlatency3 = x(latency_indx3+1:length(x)); % the truncated x trajectory only in reponse dwell time (last N pixel radius - see trim1 above)            
DV_xflp_dwl = xflip(xlatency3); % x flipping in reponse dwell region
DV_aflp_dwl = xflip(trajAng(latency_indx3+1:length(trajAng))); % angle flipping in reponse dwell region

%%% entropy along x-axis %%% 
%%% entropy along y-axis %%%
%%% entropy along trajectory angle %%%
[DV_xe, xse] = sampen(x,5,.2,1,0,1); % sample entropy along the x-axis
[DV_ye, yse] = sampen(y,5,.2,1,0,1);
[DV_ae, ase] = sampen(y,5,.2,1,0,1);

%% following measures depend on whether target is on right or left side, properties over trajs and angle 

%%%% area under the curve
if sign(x(end)) == 1, % answer on the right side (x > 0), so get deviation toward the left side (x < 0, from point of origin)
    DV_area = trapz(max(y,0),min(x,0)*-1); % grabs portion of trajectory that is x < 0 and y > 0, get integral using trapezoidal method
    DV_areax = trapz(min(x,0)*-1); % alternative method
elseif sign(x(end)) == -1, % answer on the left side (x < 0), so get deviation toward the right side (x > 0, from point of origin)
    DV_area = trapz(max(y,0),max(x,0)); % grabs portion of trajectory that is x > 0 and y > 0, get integral using trapezoidal method
    DV_areax = trapz(max(x,0));
end

%%%% how much PULL to the distractor response - absolute values %%%%
%%%% pull max timing %%%%
if sign(x(end)) == 1, % rightside
    DV_maxpull = abs(min(x)); % toward left, either 0 (no pull), or larger
    DV_maxpull_start = t(find(x==min(x),1)); % either 1 (no pull), or larger
elseif sign(x(end)) == -1, % leftside
    DV_maxpull = abs(max(x)); % toward right, either 0 (no pull), or larger
    DV_maxpull_start = t(find(x==max(x),1)); % either 1 (no pull), or larger
end

%%%% severity of ANGLE to the distractor response while in motion (no latency region) - absolute values
%%%% angle max timing %%%%
motTrajAng = trajAng(latency_indx:length(trajAng)); % just the region of trajectory outside of latency region
if sign(x(end)) == 1, % rightside 
    DV_maxang = min(motTrajAng); % toward left distractor, should be between 0 and -90
    if DV_maxang >= 0, % if DV_maxang is above 0, then in rightside region and no deviation
        DV_maxang = 0;
        DV_maxang_start = 0;
    else
        DV_maxang_start = t(find(motTrajAng==min(motTrajAng),1));
    end
elseif sign(x(end)) == -1, % leftside
    DV_maxang = max(motTrajAng); % toward right distractory, should be between 0 and 90
    if DV_maxang <= 0, % if DV_maxang is below 0, then in leftside region and no deviation
        DV_maxang = 0;
        DV_maxang_start = 0;
    else
        DV_maxang_start = t(find(motTrajAng==max(motTrajAng),1));
    end     
end
DV_maxang = abs(DV_maxang); % get absolute value for angle deviation

%%%% severity of INITIAL ANGLE to the distractor response, after committing to N pixels (some initial region) - absolute values
[lat_indx2 xtrim2 ytrim2] = trim0(x,y,ESCAPE_INIT); % only x,y coordinates after "escaping" an initial ESCAPE_INIT pixel range around the origin of movement
DV_initang = trajAng(lat_indx2-1); % what is the angle when trajectory leaves the ESCAPE_INIT region, should be between -90 to 90
if (sign(x(end)) == 1 && DV_initang >= 0), % if Target is on right, and DV_initang is above 0, then no initial deviation
    DV_initang = 0;    
elseif (sign(x(end)) == -1 && DV_initang <= 0), % if Target is on left, and DV_initang is below 0, then no initial deviation
    DV_initang = 0;
end
DV_initang = abs(DV_initang); % get absolute value for initial angle deviation

%% Get a few useful potential outlier measures and/or quick analysis of quality of trajectories

%%% max x, y; min x, y; %%% detect wild trajectories
OL_maxx = max(x); OL_minx = min(x); OL_maxy = max(y); OL_miny = min(y);

%%% percentage of trajectory that is not moving toward or away from attractor/distractor, negative movements (y < 0) 
traj_ang_pos = trajAng;
less1 = find(traj_ang_pos < -90);
traj_ang_pos(less1) = -90;
more1 = find(traj_ang_pos > 90);
traj_ang_pos(more1) = 90;  
OL_negmove = (length(less1) + length(more1))/length(trajAng);

%%% Is motion time longer than latency time? Gets at whether cognitive processing is mostly occuring in latency region.   
if DV_inmot < DV_latency, 
    OL_1 = '1';
else
    OL_1 = '0';
end

%%% Is max velocity inside of latency region? Gets at whether strongest commitment to a response occurs in latency region. 
if find(veloc==DV_velmax,1) < latency_indx,
    OL_2 = '1';
else
    OL_2 = '0';
end

%%% Is max acceleration inside of latency region? Gets at whether strongest commitment to a response occurs in latency region.
if find(accel==DV_accmax,1) < latency_indx,
    OL_3 = '1';
else
    OL_3 = '0';
end 

%%% Does trajectory dive below y axis after escapting latency region? Gets at whether the trajectory is particulaly wild. 
if (DV_maxang >= 90 || DV_initang >= 90),
    OL_4 = '1';
else
    OL_4 = '0';
end

%% Generate useful figures

if FIGURE_RUN == 1,
    % generate quick plots of angle trajectories (see Scherbaum et al., 2010; Cognition)
    figure('Visible','Off')
    plot(t,trajAng,'col','r')            
    set(gca,'YDir','reverse');
    hold on
    plot(t(latency_indx),trajAng(latency_indx),'.r','MarkerSize',20) % mark where latency "escape" region begins
    plot(t(length(t(t<500))),trajAng(length(t(t<500))),'*k','MarkerSize',10) % mark 500 ms into processing
    plot(t(length(t(t<1000))),trajAng(length(t(t<1000))),'sk','MarkerSize',10) % mark 1000 ms into processing
    plot(t(length(t(t<1500))),trajAng(length(t(t<1500))),'*k','MarkerSize',10) % mark 1500 ms into processing
    plot(t,traj_ang_pos,'col','k') % plot only positive/negative angles that do not go below 90/-90 degrees
    plot(t(latency_indx3),trajAng(latency_indx3),'.b','MarkerSize',20) % mark where final "dwell" region begins
    title(DV_total_time)
    saveas(gcf, ['figure/' num2str(subj) '_' num2str(listnum) '_ang'], 'jpeg');
    close all

    % generate quick plots of x,y, trajectories
    figure('Visible','Off')
    plot(x,y)
    hold on
    plot(x(latency_indx),y(latency_indx),'.r','MarkerSize',20)
    plot(x(length(t(t<500))),y(length(t(t<500))),'*k','MarkerSize',10)
    plot(x(length(t(t<1000))),y(length(t(t<1000))),'sk','MarkerSize',10)
    plot(x(length(t(t<1500))),y(length(t(t<1500))),'*k','MarkerSize',10)
    plot(x(latency_indx3),y(latency_indx3),'.b','MarkerSize',20)
    title(DV_total_time)
    saveas(gcf, ['figure/' num2str(subj) '_' num2str(listnum) '_xy'], 'jpeg');
    close all
end


%% saving data for excel/r analysis UPDATE CONDITION CODES

%%% saving data
fprintf(f1o,'%s\t%s\t...', var1, var2, ...); % add all experiment specific condition codes
fprintf(f1o,'%f\t%f\t%f\t%f\t%f\t', DV_total_time, DV_latency, DV_inmot, DV_dwell, DV_dist);
fprintf(f1o,'%f\t%f\t%f\t%f\t%f\t', DV_dist_inmot, DV_velmax, DV_velmax_start, DV_accmax, DV_accmax_start);
fprintf(f1o,'%s\t%f\t%f\t%f\t%f\t', DV_jerk, DV_xflp_lat, DV_xflp_mot, DV_xflp_dwl, DV_aflp_lat);
fprintf(f1o,'%f\t%f\t%f\t%f\t%f\t', DV_aflp_mot, DV_aflp_dwl, DV_area, DV_areax, DV_maxpull);
fprintf(f1o,'%f\t%f\t%f\t%f\t', DV_maxpull_start,DV_maxang,DV_maxang_start,DV_initang);
fprintf(f1o,'%f\t%f\t%f\t%f\t%f\t', OL_maxx, OL_minx, OL_maxy, OL_miny,OL_negmove);
fprintf(f1o,'%s\t%s\t%s\t%s\t', OL_1,OL_2,OL_3,OL_4); 
fprintf(f1o,'%f\t%f\t%f\t%f\t%f\t', DV_xe(1), DV_xe(2), DV_xe(3), DV_xe(4), DV_xe(5));
fprintf(f1o,'%f\t%f\t%f\t%f\t%f\t', DV_ye(1), DV_ye(2), DV_ye(3), DV_ye(4), DV_ye(5));
fprintf(f1o,'%f\t%f\t%f\t%f\t%f\n', DV_ae(1), DV_ae(2), DV_ae(3), DV_ae(4), DV_ae(5));

clear DV_total_time DV_dist DV_dist_inmot DV_latency DV_inmot DV_velmax DV_velmax_start DV_accmax DV_accmax_start DV_area DV_areax DV_jerk DV_xflp_lat DV_xflp_mot DV_aflp_lat DV_aflp_mot DV_maxpull DV_maxpull_start DV_maxang DV_maxang_start DV_initang OL_maxx OL_minx OL_maxy OL_miny OL_negmove OL_1 OL_2 OL_3 OL_4 DV_dwell DV_xflp_dwl DV_aflp_dwl
clear DV_xe DV_ye DV_ae

%%% make sure to close any individual files opened with textscan
fclose(fid);

%%% add at the very, very end
% fclose(f1o);



