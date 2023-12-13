%% V1 complex cell model
% Modelling complex cell receptive fields as two garbor filters in spatial
% quadrature (shifted in spatial phase by 90 degree) but having the same
% orientation and frequency

% for  n = 1:101
%     x = imread(['screen_shots_' num2str(n-1) '.jpg']);
%     allImages(:,:,ii) = double(frame(:,:,1));
% end

%% Convert video into image sequence
% 1 second video at each location (20 frames/sec, pick the last one)

clear all
workingDir = 'P:\Bonvision\Masa_two_tracks_tunnel_V1_model\track_sequence'
cd(workingDir)

for n = 1:121*5
    if n == 1
        track = 1;
        ii = 1;
    elseif n == 122
        track = 2;
        ii = 1;
    elseif n == 243
        track = 3;
        ii = 1;
    elseif n == 364
        track = 4;
        ii = 1;
    elseif n == 485
        track = 5;
        ii = 1;
    end

    Video = VideoReader(sprintf('Track Image Sequence%i.avi',n));
    %     Video = VideoReader(sprintf('Track Image Sequence%i.avi',n));
    frame = read(Video,Video.NumFrames);
    track_frames.(sprintf('t%i',track))(ii,:,:) = double(frame(:,:,1));
    filename = [sprintf('%03d',ii) '.jpg'];
    fullname = fullfile(workingDir,sprintf('Track%i',track),filename);
    imwrite(frame,fullname);    % Write out to a JPEG file (img1.jpg, img2.jpg, etc.)
    cd(workingDir)

    ii = ii + 1;
end
% For now we included track 3 (Aman's original track)
save track_frames track_frames -v7.3


% Modelling complex cell receptive fields as two garbor filters in spatial
% quadrature (shifted in spatial phase by 90 degree) but having the same
% orientation and frequency

clear all
workingDir = 'P:\Bonvision\Masa_two_tracks_tunnel_V1_model\track_sequence'
cd(workingDir)

receptive_field_size = 80;
receptive_field_location = [];
receptive_field_location(1,:) = [1920/2:80:1680]; % Right
receptive_field_location(2,:) = [240:80:1920/2]; % Left
orientation = 0:15:165;
frequency = 0.03:0.01:0.08;
plotTag = 0;

V1_model = [];
V1_respond = [];

% This step takes a long time

cd(workingDir)
load track_frames
for track = 1:5
    cd(workingDir)
    cd(sprintf('Track%i',track))
    allImages =  track_frames.(sprintf('t%i',track));
    if track == 3 | track == 5
        rf_location = receptive_field_location(2,:);
    else
        rf_location = receptive_field_location(1,:);
    end

    for s = 1:length(frequency)
        tic
        for x = 1:length(rf_location)
            %                 [FiltOut0,smthFiltOut0(s,x_idx,:), speaks0(s,x_idx),  peakPos0(sf_idx,x_idx)]  = makeGaborfilter(allImages, sfreq(sf_idx), rf_size, x(x_idx), 0, plotTag);
            %                 [FiltOut30,smthFiltOut30(s,x_idx,:),speaks30(s,x_idx),peakPos30(sf_idx,x_idx)] = makeGaborfilter(allImages, sfreq(sf_idx), rf_size, x(x_idx), 30, plotTag);
            %                 [FiltOut60,smthFiltOut60(s,x_idx,:),speaks60(s,x_idx),peakPos60(sf_idx,x_idx)] = makeGaborfilter(allImages, sfreq(sf_idx), rf_size, x(x_idx), 60, plotTag);
            %                 [FiltOut90,smthFiltOut90(s,x_idx,:),speaks90(s,x_idx),peakPos90(sf_idx,x_idx)] = makeGaborfilter(allImages, sfreq(sf_idx), rf_size, x(x_idx), 90, plotTag);
            window = rf_location(x);
            sf = frequency(s);
            parfor ori = 1:length(orientation)
%                 if track == 3 |  track == 4
%                     [~, ~,FiltOut(s,x,ori,:),smthFiltOut(s,x,ori,:),peak1(s,x,ori,:),peak2(s,x,ori,:),smod(s,x,ori)] =...
%                         makeGaborfilter(allImages, sf, receptive_field_size, window, orientation(ori),plotTag);
%                     %                 [gaborFilterA(s,x,ori,:,:), gaborFilterB(s,x,ori,:,:),FiltOut(s,x,ori,:),smthFiltOut(s,x,ori,:),peak1(s,x,ori,:),peak2(s,x,ori,:),smod(s,x,ori)] =...
%                     %                     makeGaborfilter(allImages, sf, receptive_field_size, window, orientation(ori),plotTag);
%                 else 
                    [~, ~,FiltOut(s,x,ori,:),smthFiltOut(s,x,ori,:),peak1(s,x,ori,:),peak2(s,x,ori,:),smod(s,x,ori)] =...
                        makeGaborfilter_5_segments(allImages, sf, receptive_field_size, window, orientation(ori),plotTag);
                    
%                 end
            end

        end
        toc
    end
    V1_model.(sprintf('t%i',track)).FiltOut = FiltOut;
    V1_model.(sprintf('t%i',track)).smthFiltOut = smthFiltOut;
    V1_model.(sprintf('t%i',track)).peak1 = peak1;
    V1_model.(sprintf('t%i',track)).peak2 = peak2;
    V1_model.(sprintf('t%i',track)).smod = smod;

%     gaborFilter1.(sprintf('t%i',track)) = gaborFilterA;
%     gaborFilter2.(sprintf('t%i',track)) = gaborFilterB;
end

cd(workingDir)
save V1_model V1_model -v7.3
% save gaborFilter gaborFilter1 gaborFilter2
 
% for track = 1:3
%     gaborFilter1.(sprintf('t%i',track)) = V1_model.(sprintf('t%i',track)).gaborFilterA;
%     gaborFilter2.(sprintf('t%i',track)) = V1_model.(sprintf('t%i',track)).gaborFilterB;
% end
% save gaborFilter gaborFilter1 gaborFilter2 -v7.3
ori_index = [1:2:12];

load V1_model
for track = 1:5
    nfig = figure(track)
    nfig.Position = [770 260 1080 660];
    smod = V1_model.(sprintf('t%i',track)).smod;
    sgtitle(sprintf('Spatial Modulation on Track %i',track))
    for ori = 1:6
        subplot(2,3,ori)
        matrix(:,:) = smod(:,:,ori_index(ori));
        imagesc(matrix)
        colorbar
        title(sprintf('Orientation (%i)',orientation(ori_index(ori))))
        if track == 3 |track == 5
            rfl = 2;
        else
            rfl = 1;
        end
        xticks(1:1:10)
        xticklabels(receptive_field_location(rfl,:))    
        xlabel('receptive field location')

        yticks(1:1:6)
        yticklabels(frequency)
        ylabel('Spatial Frequency')
    end
%     saveas(gcf,sprintf('Spatial Modulation on Track %i.fig',track))
%     orient(nfig,'landscape')
%     saveas(gcf,sprintf('Spatial Modulation on Track %i.pdf',track))
end



%%
clear all
workingDir = 'P:\Bonvision\Masa_two_tracks_tunnel_V1_model\track_sequence';
cd(workingDir)
load([workingDir,'\track_frames.mat'])
receptive_field_size = 80;
receptive_field_location = [];
receptive_field_location(1,:) = [1920/2:80:1680]; % Right
receptive_field_location(2,:) = [240:80:1920/2]; % Left
orientation = 0:15:165;
frequency = 0.03:0.01:0.08;
plotTag = 0;

% Aman track
sf = 0.04;
allImages = track_frames.t1;
figure
makeGaborfilter_5_segments(allImages, sf, receptive_field_size, 1600, 0,1);
figure
makeGaborfilter_5_segments(allImages, sf, receptive_field_size, 1600, 30,1);
figure
makeGaborfilter_5_segments(allImages, sf, receptive_field_size, 1600, 60,1);
figure
makeGaborfilter_5_segments(allImages, sf, receptive_field_size, 1600, 90,1);

% Track 1
sf = 0.04;
allImages = track_frames.t2;
figure
makeGaborfilter_5_segments(allImages, sf, receptive_field_size, 1600, 0,1);
% figure
% makeGaborfilter_5_segments(allImages, sf, receptive_field_size, 1600, 45,1);
% figure
% makeGaborfilter_5_segments(allImages, sf, receptive_field_size, 1600, 60,1);
figure
makeGaborfilter_5_segments(allImages, sf, receptive_field_size, 1600, 90,1);


% Track 2
allImages = track_frames.t3;
figure
makeGaborfilter_5_segments(allImages, sf, receptive_field_size, 320, 0,1);
% figure
% makeGaborfilter_5_segments(allImages, sf, receptive_field_size, 320, 135,1);
% figure
% makeGaborfilter_5_segments(allImages, sf, receptive_field_size, 320, 60,1);
figure
makeGaborfilter_5_segments(allImages, sf, receptive_field_size, 320, 90,1);


allImages = track_frames.t4;
figure
makeGaborfilter(allImages, sf, receptive_field_size, 1520, 0,1);
% figure
% makeGaborfilter(allImages, sf, receptive_field_size, 1520, 30,1);
% figure
% makeGaborfilter(allImages, sf, receptive_field_size, 1520, 60,1);
figure
makeGaborfilter(allImages, sf, receptive_field_size, 1520, 90,1);

allImages = track_frames.t5;
figure
% makeGaborfilter(allImages, sf, receptive_field_size, 320, 0,1);
figure
makeGaborfilter(allImages, sf, receptive_field_size, 320, 45,1);
figure
makeGaborfilter(allImages, sf, receptive_field_size, 320, 135,1);
% figure
% makeGaborfilter(allImages, sf, receptive_field_size, 320, 90,1);