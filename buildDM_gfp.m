% buildDM_gfp


% goal: build a data matrix of parameters (each column) over time
%       (rows) for single-cell lineages in specified xy positions.


% strategy:
%              0. initialize
%              1. loop through all movies (xy)
%              2. collect parameters of interest for each track (single-cell data over time)
%                       - see code section 0. for list of compiled parameters
%              3. concatenate data vertically into a single vector for each
%              4. output a single matrix with each parameter vector as a unique column


% note: script adapted from buildDM_glycogen, but edited for only one GFP column


% last updated: jen, 2022 January 19
% commit: edit for juani's gfp experiments


function [dm] = buildDM_gfp(D5,xy_start,xy_end,dt)
%% 0. initialize all values
  
tn_counter = 0;
dropThreshold = -0.75; % consider greater negatives a division event


Time = [];              % 1. Time
lengthVals = [];        % 2. lengthVals
isDrop = [];            % 3. isDrop
widthVals = [];         % 4. widthVals
vaVals = [];            % 5. vaVals
surfaceArea = [];       % 6. surfaceArea
x_pos = [];             % 7. x coordinate of centroid
y_pos = [];             % 8. y coordinate of centroid
orig_frame = [];        % 9. orig_frame
eccentricity = [];      % 10. eccentricity
angle = [];             % 11. angle of rotation of fit ellipse
trackNum = [];          % 12. trackNum  =  total track number (vs ID which is xy based)
GFP = [];               % 13. GFP
particleID = [];        % 14. particleID from tracking

%% 1. loop through all xy positions and all tracks for data concatenation

for n = xy_start:xy_end % n = each inidividual xy position from experiment (movie)
    
    for m = 1:length(D5{n}) % m = each individual cell track from current movie
   
        % frame number in original image
        frameTrack = D5{n}(m).Frame;
        orig_frame = [orig_frame; frameTrack];
        
        %% particleID from particle tracking
        
        idTrack = ones(length(frameTrack),1)*m;
        particleID = [particleID; idTrack];
        
        %% track number
        tn_counter = tn_counter + 1;
        tnTrack = ones(length(frameTrack),1)*tn_counter;
        trackNum = [trackNum; tnTrack];
        
        %% time
        timeTrack = (frameTrack-1)*dt;  % dt = timestep between frames in min
        Time = [Time; timeTrack];                                         
        clear frameTrack
        
        %% lengths
        lengthTrack = D5{n}(m).MajAx;%(7:lengthCurrentTrack+6);              % collect lengths (um)
        lengthVals = [lengthVals; lengthTrack];                            % concatenate lengths
        
        %% drop?
        dropTrack = diff(lengthTrack);
        trackDrops = dropTrack < dropThreshold;                                % converts different to a Boolean based on dropThreshold
        trackDrops = [0; trackDrops];                                              % * add zero to front, to even track lengths
        isDrop = [isDrop; trackDrops];
        
        
        %% widths
        widthTrack = D5{n}(m).MinAx;%(7:lengthCurrentTrack+6);               % collect widths (um)
        widthVals = [widthVals; widthTrack];                               % concatenate widths
        
        %% volume as a cylinder with hemispherical caps
        
        %v_cylinder = pi * lengthTrack .* (widthTrack/2).^2;                % approx. volume as a cylinder = pi * r^2 * h
        %v_ellipse = 4/3 * pi * lengthTrack/2 .* (widthTrack/2).^2;         % approx. volume as an ellipse
        vol_smallCylinder = pi * (widthTrack/2).^2 .* (lengthTrack - widthTrack);
        vol_sphere = 4/3 * pi * (widthTrack/2).^3;
        v_anupam = vol_smallCylinder + vol_sphere;                         % approx. volume as cylinder with spherical caps
        
        vaVals = [vaVals; v_anupam];
        
        clear v_ellipse v_cylinder vol_sphere vol_smallCylinder
        
        %% surface area
        sa_rectangle = (lengthTrack - widthTrack) .* widthTrack;
        sa_sphere = 4 * pi .* (widthTrack/2);
        sa_total = sa_rectangle + sa_sphere;
        
        surfaceArea = [surfaceArea; sa_total];
        
        clear sa_total sa_sphere sa_rectangle
        
        %% x positions in original image
        xTrack = D5{n}(m).X;%(7:lengthCurrentTrack+6);
        x_pos = [x_pos; xTrack];
        clear xTrack
        
        %% y positions in original image
        yTrack = D5{n}(m).Y;%(7:lengthCurrentTrack+6);
        y_pos = [y_pos; yTrack];
        clear yTrack
        
        %% eccentricity of ellipses used in particle tracking
        eccTrack = D5{n}(m).Ecc;%(7:lengthCurrentTrack+6);
        eccentricity = [eccentricity; eccTrack];
        clear eccTrack
        
        %% angle of ellipses used in particle tracking
        angTrack = D5{n}(m).Angle;%(7:lengthCurrentTrack+6);
        angle = [angle; angTrack];
        clear angTrack
        
        %% GFP
        gfpTrack = D5{n}(m).GFP;
        GFP = [GFP; gfpTrack];
        
        clear gfpTrack
        
    end % for m
    
    disp(['Tracks (', num2str(m), ') assembled from movie (', num2str(n), ') !'])
    
end % for n


% compile data into single matrix
dm = [Time lengthVals isDrop widthVals vaVals surfaceArea x_pos y_pos orig_frame eccentricity angle trackNum GFP particleID];
% 1. Time
% 2. lengthVals
% 3. isDrop
% 4. widthVals  
% 5. vaVals
% 6. surfaceArea
% 7. x_pos
% 8. y_pos
% 9. orig_frame
% 10. eccentricity
% 11. angle
% 12. trackNum  =  total track number (vs ID which is xy based)
% 13. GFP
% 14. particleID

end