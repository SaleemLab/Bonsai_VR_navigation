%% Creating backgroud texture using white noise and then concatenate and smooth
% texsize = 512;
cd P:\Bonvision\Masa_two_tracks_V1_model\Textures
cd P:\Bonvision\Masa_two_tracks_test\Textures
texsize = 400;
wn_contrast = 0.5;

% Making a 2D Gaussian filter to convolve
% Unfiltered Whitenoise

filtSize = 100;
sigma = 15;
sigma1 = 15;

x = 1:filtSize;

segments = 4;% 4 textrures
% segments = 5; % 5 textures

for texID = 1:4

    %     if texID==4; sigma = 30; end;
    %     if texID==3; sigma = 5; end;

    y = exp(-((x-round(filtSize/2)).^2)/(2*sigma^2));
    y1 = exp(-((x-round(filtSize/2)).^2)/(2*sigma1^2));
    y = y./sum(y);
    y1 = y1./sum(y1);


    filt2 = y'*y1;
    % imagesc(filt2); colormap(gray)

    rng(texID+4)
    Im_segments = rand(texsize/8+filtSize*2,floor(texsize*2/5*2));% for 2 repeating segments
    rng(texID+100)
%     % For spatial modulation (120cm track)
% %     Im_segement_start = [rand(texsize/8+filtSize*2,filtSize) Im_segments(:,size(Im_segments,2)/2:end)]% Start
    % For spatial modulation (150cm track (120cm + additional 20cm at the start))
    Im_segement_start = [rand(texsize/8+filtSize*2,filtSize) Im_segments]% Start
%     Im_segement_start = [rand(texsize/8+filtSize*2,filtSize) Im_segments]% Start
    %     % If okay to be unique
    %     Im_segement_start = rand(texsize/8+filtSize*2,texsize*2/5+filtSize);% Start
    rng(texID+200)
    % For spatial modulation
    Im_segement_end = [Im_segments(:,1:floor(size(Im_segments,2)/2)) rand(texsize/8+filtSize*2,filtSize)];% end
    %     % If end segment is okay to be unique
    %     Im_segement_end = rand(texsize/8+filtSize*2,texsize*2/5+filtSize);% end

    Im = [Im_segement_start Im_segments Im_segments Im_segement_end];

    % Convolving and normalizing the image to 100% contrast
    Imf = conv2(filt2,Im);
    Imf = Imf(filtSize+floor(filtSize/2):end-ceil(filtSize/2)-filtSize,filtSize+floor(filtSize/2):end-ceil(filtSize/2)-filtSize);
    Imf = Imf - min(min(Imf));
    Im_full = Imf./max(max(Imf));
    Im_new = ((Im_full-0.5)*wn_contrast) + 0.5;
    textures(texID).matrix = Im_new;
    imwrite(Im_new,sprintf('smoothed_fwn%i.jpg',texID))
end

for texID = 1:4
    figure
    imshow(textures(texID).matrix)
end


%% Making cross and plus segments
textures = [];
texsize = 512;
wn_contrast = 1;
% sf = [6 12 24]; % no.of bars visible
sf = [1]; % no.of bars visible
texture_name = [{'black plus'},{'white plus'},{'black bar'},{'white bar'},{'white cross'},{'black cross'}];


texsize = 512;
% Vertical grating
%     pattern = ones(1,texsize);
%     pattern(texsize/5*2:texsize/5*3) = -sin(0:(5*pi/texsize):(pi-(2*pi/texsize)))+1;
%     textures(1).sf(s).matrix = (repmat(pattern,texsize,1) + repmat(pattern',1,texsize))/2;
pattern = ones(1,texsize);
pattern(texsize/5*2:texsize/5*3) = 0;


combined = (repmat(pattern,texsize,1) + repmat(pattern',1,texsize))-1;
textures(1).matrix  = combined;
textures(3).matrix  = repmat(pattern,texsize,1);

pattern = zeros(1,texsize);
pattern(texsize/5*2:texsize/5*3) = 1;
combined = (repmat(pattern,texsize,1) + repmat(pattern',1,texsize));
textures(2).matrix  = combined;
textures(4).matrix  = repmat(pattern,texsize,1);

combined = diag(ones(1,texsize));
for n = [1:sqrt(2)*texsize/10]
    tempt = diag(ones(1,texsize),n);
    combined = combined + tempt(1:512,1:512);
    tempt = diag(ones(1,texsize),-n);
    combined = combined + tempt(1:512,1:512);
end
textures(5).matrix = combined + flip(combined);

combined = textures(5).matrix;
combined(combined==1) = 2;
combined(combined==0) = 1;
combined(combined==2) = 0;
textures(6).matrix = combined + flip(combined);


% cd P:\Bonvision\Masa_two_tracks_tunnel_V1_model\Textures
cd P:\Bonvision\Masa_two_tracks_tunnel\Textures
for i = 1:length(textures)
    imwrite(textures(i).matrix,sprintf('%s.jpg',texture_name{i}));
end

for i = 1:6
    figure
    imshow(textures(i).matrix)
end

%% Grating segments
textures = [];
texsize = 512;
wn_contrast = 1;
sf = [6 12 24]; % no.of bars visible
sf = [1]; % no.of bars visible
texture_name = [{'VertGrat'},{'45Grat'},{'135Grat'},{'HorGrat'},{'plaid'}];

for s = 1:length(sf)
    texsize = 512;
    % Vertical grating
    textures(1).sf(s).matrix = 0.5+0.5*repmat(sin(0:((2*sf(s)*pi)/texsize):(2*sf(s))*pi-(((2*sf(s))*pi)/texsize)),texsize,1);
    % Horizontal grating
    textures(4).sf(s).matrix = 0.5+0.5*repmat(sin(0:(((2*sf(s))*pi)/texsize):(2*sf(s))*pi-(((2*sf(s))*pi)/texsize))',1,texsize);
    % Plaid
    textures(5).sf(s).matrix = (textures(1).sf(s).matrix + textures(4).sf(s).matrix)/2;

%     texsize = 724;% will crop later to become 512
    texsize = 1024;% will crop later to become 512
    grating = 0.5+0.5*repmat(sin(0:((2*2*sf(s)*pi)/texsize):(2*2*sf(s))*pi-(((2*2*sf(s))*pi)/texsize)),texsize,1);
    grating_45 =  imrotate(grating, 45,'crop');
    grating_45_crop = imcrop(grating_45,[length(grating_45)/4 length(grating_45)/4 length(grating_45)/4*2-1 length(grating_45)/4*2-1]);
    grating_135 =  imrotate(grating, 135,'crop');
    grating_135_crop = imcrop(grating_135,[length(grating_135)/4 length(grating_135)/4 length(grating_135)/4*2-1 length(grating_135)/4*2-1]);
    textures(2).sf(s).matrix = grating_45_crop;
    textures(3).sf(s).matrix = grating_135_crop;
%     textures(6).sf(s).matrix = (grating_45_crop + grating_135_crop)/2;
    cd P:\Bonvision\Masa_two_tracks_tunnel_V1_model\Textures
    for i = 1:length(textures)
        imwrite(textures(i).sf(s).matrix,sprintf('%s_%i.jpg',texture_name{i},sf(s)));
    end
end


%% Create shape texture for first segment

cd P:\Bonvision\Masa_two_tracks_tunnel\Textures
% cd P:\Bonvision\Masa_two_tracks_tunnel_V1_model\Textures

% color_patterns{1} = ...
%     {'w','w','w',...
%     'w','k','w',...
%     'w','w','w'};
% Making single dots
color_patterns = [];
color_patterns{1} = ...
    {'k'};
color_patterns{2} = ...
    {'w'};

color_patterns = [];
color_patterns{1} = ...
    {'k','w','w',...
    'w','w','k',...
    'k','w','w'};
color_patterns{2} = ...
    {'w','k','k',...
    'k','k','w',...
    'w','k','k'};
color_patterns{3} = ...
    {'w','k','w',...
    'w','w','k',...
    'w','k','w'};
color_patterns{4} = ...
    {'k','w','k',...
    'k','k','w',...
    'k','w','k'};
centers = [];
centers = ...
    [[1 1]; [2 1]; [3 1];...
    [1 2]; [2 2]; [3 2];...
    [1 3]; [2 3]; [3 3]];
% sz = [10 10 10 10 5000 10 10 10 10
sz = [5000];
centers = [2 2];
% centers = ...
%     [[1 1]; [2 1];...
%     [1 2]; [2 2]]

option = 1;
% option = 2;
% option = 3;

% for option = 1:4
for pattern =  1:1
    for n = 1:size(centers,1)
        % viscircles(centers(n,:), radii,'Color',color_patterns2{n});
        if option == 1
            scatter(centers(n,1),centers(n,2),sz(n),'filled','MarkerFaceColor',color_patterns{pattern}{n});
        elseif option == 2
            scatter(centers(n,1),centers(n,2),sz(n),'^','filled','MarkerFaceColor',color_patterns{pattern}{n});
        elseif option == 3
            scatter(centers(n,1),centers(n,2),sz(n),'square','filled','MarkerFaceColor',color_patterns{pattern}{n});
        elseif option == 4
            scatter(centers(n,1),centers(n,2),sz(n),'pentagram','filled','MarkerFaceColor',color_patterns{pattern}{n});
        end
        %         xlim([-1 5])
        %         ylim([-1 5])

        hold on
    end
    xlim([0.9 3.1])
    ylim([0.9 3.1])
    axis square
    %         axis off
    ax = gca;

    if pattern == 2
        ax.Color = 'k';
    end

    ax.XColor = 'none';
    ax.YColor = 'none';
    set(ax, 'visible', 'off', 'dataaspectratio', [1 1 1]);
    hold off
    % Requires R2020a or later
    if option == 1
        %             exportgraphics(ax,sprintf('dot %i.png',pattern),'Resolution',120)
        saveas(ax,sprintf('dot %i.png',pattern))
        original_image = imread(sprintf('dot %i.png',pattern));

        original_image = reshape(original_image(:,:,1),size(original_image,1),size(original_image,2));
        normalised_image = original_image/max(max(original_image));

        [r, c] = find(normalised_image == 0);
        Centroids = round([mean(r), mean(c)]);
        crop_x = abs(Centroids(1)-512/2);
        crop_y = abs(Centroids(2)-512/2);

        crop_image = original_image(Centroids(1)-512/2+1:Centroids(1)+512/2,Centroids(2)-512/2+1:Centroids(2)+512/2);
        imwrite(crop_image,'dot black.png');
        crop_image1 = abs(255-crop_image);
        imwrite(crop_image1,'dot white.png');

        R_image = uint8(255*ones(512,512));
        space = length(R_image)/2 - length(R_image)/3;
        R_image(length(R_image)/2+space/2:end-space/2,:) = crop_image(length(R_image)/3:2*length(R_image)/3,:);
        imwrite(R_image,'dot black R.png');
        R_image1 = abs(255-R_image);
        imwrite(R_image1,'dot white R.png');

        R_image = uint8(255*ones(512,512));
        space = length(R_image)/2 - length(R_image)/3;
        R_image(space/2:length(R_image)/2-space/2,:) = crop_image(length(R_image)/3:2*length(R_image)/3,:);
        imwrite(R_image,'dot black L.png');
        R_image1 = abs(255-R_image);
        imwrite(R_image1,'dot white L.png');

    elseif option == 2
        saveas(ax,sprintf('triangle %i.png',pattern))
        original_image = imread(sprintf('triangle %i.png',pattern));

        original_image = reshape(original_image(:,:,1),size(original_image,1),size(original_image,2));
        normalised_image = original_image/max(max(original_image));

        [r, c] = find(normalised_image == 0);
        Centroids = round([mean(r), mean(c)]);
        crop_x = abs(Centroids(1)-512/2);
        crop_y = abs(Centroids(2)-512/2);

        crop_image = original_image(Centroids(1)-512/2+1:Centroids(1)+512/2,Centroids(2)-512/2+1:Centroids(2)+512/2);
        imwrite(crop_image,'triangle black.png');
        crop_image1 = abs(255-crop_image);
        imwrite(crop_image1,'triangle white.png');

        R_image = uint8(255*ones(512,512));
        space = length(R_image)/2 - length(R_image)/3;
        R_image(length(R_image)/2+space/2:end-space/2,:) = crop_image(length(R_image)/3:2*length(R_image)/3,:);
        imwrite(R_image,'triangle black R.png');
        R_image1 = abs(255-R_image);
        imwrite(R_image1,'triangle white R.png');

        R_image = uint8(255*ones(512,512));
        space = length(R_image)/2 - length(R_image)/3;
        R_image(space/2:length(R_image)/2-space/2,:) = crop_image(length(R_image)/3:2*length(R_image)/3,:);
        imwrite(R_image,'triangle black L.png');
        R_image1 = abs(255-R_image);
        imwrite(R_image1,'triangle white L.png');
    elseif option == 3
        saveas(ax,sprintf('square %i.png',pattern))
        original_image = imread(sprintf('square %i.png',pattern));

        original_image = reshape(original_image(:,:,1),size(original_image,1),size(original_image,2));
        normalised_image = original_image/max(max(original_image));

        [r, c] = find(normalised_image == 0);
        Centroids = round([mean(r), mean(c)]);
        crop_x = abs(Centroids(1)-512/2);
        crop_y = abs(Centroids(2)-512/2);

        crop_image = original_image(Centroids(1)-512/2+1:Centroids(1)+512/2,Centroids(2)-512/2+1:Centroids(2)+512/2);
        imwrite(crop_image,'square black.png');
        crop_image1 = abs(255-crop_image);
        imwrite(crop_image1,'square white.png');

        R_image = uint8(255*ones(512,512));
        space = length(R_image)/2 - length(R_image)/3;
        R_image(length(R_image)/2+space/2:end-space/2,:) = crop_image(length(R_image)/3:2*length(R_image)/3,:);
        imwrite(R_image,'square black R.png');
        R_image1 = abs(255-R_image);
        imwrite(R_image1,'square white R.png');

        R_image = uint8(255*ones(512,512));
        space = length(R_image)/2 - length(R_image)/3;
        R_image(space/2:length(R_image)/2-space/2,:) = crop_image(length(R_image)/3:2*length(R_image)/3,:);
        imwrite(R_image,'square black L.png');
        R_image1 = abs(255-R_image);
        imwrite(R_image1,'square white L.png');

    elseif option == 4
        saveas(ax,sprintf('star %i.png',pattern))
        original_image = imread(sprintf('star %i.png',pattern));
        original_image = reshape(original_image(:,:,1),size(original_image,1),size(original_image,2));
        normalised_image = original_image/max(max(original_image));

        [r, c] = find(normalised_image == 0);
        Centroids = round([mean(r), mean(c)]);
        crop_x = abs(Centroids(1)-512/2);
        crop_y = abs(Centroids(2)-512/2);

        crop_image = original_image(Centroids(1)-512/2+1:Centroids(1)+512/2,Centroids(2)-512/2+1:Centroids(2)+512/2);
        imwrite(crop_image,'star black.png');
        crop_image1 = abs(255-crop_image);
        imwrite(crop_image1,'star white.png');

        R_image = uint8(255*ones(512,512));
        space = length(R_image)/2 - length(R_image)/3;
        R_image(length(R_image)/2+space/2:end-space/2,:) = crop_image(length(R_image)/3:2*length(R_image)/3,:);
        imwrite(R_image,'star black R.png');
        R_image1 = abs(255-R_image);
        imwrite(R_image1,'star white R.png');

        R_image = uint8(255*ones(512,512));
        space = length(R_image)/2 - length(R_image)/3;
        R_image(space/2:length(R_image)/2-space/2,:) = crop_image(length(R_image)/3:2*length(R_image)/3,:);
        imwrite(R_image,'star black L.png');
        R_image1 = abs(255-R_image);
        imwrite(R_image1,'star white L.png');
    end
end
% end

% set(gca,'Color','k')

%% Dot patterns

color_patterns = [];
color_patterns{1} = ...
    {'w','k','w',...
    'w','w','k',...
    'k','w','w'};
color_patterns{2} = ...
    {'w','k','k',...
    'k','k','w',...
    'w','k','k'};
color_patterns{3} = ...
    {'w','k','w',...
    'w','w','k',...
    'w','k','w'};
color_patterns{4} = ...
    {'k','w','k',...
    'k','k','w',...
    'k','w','k'};
centers = [];
centers = ...
    [[1.333 1.333]; [2 1.333]; [2.666 1.333];...
    [1.333 2]; [2 2]; [2.666 2];...
    [1.333 2.666]; [2 2.666]; [2.666 2.666]];
% sz = [10 10 10 10 5000 10 10 10 10
sz = [5000];
% centers = [2 2];
% centers = ...
%     [[1 1]; [2 1];...
%     [1 2]; [2 2]]

option = 1;
% option = 2;
% option = 3;

% for option = 1:4
for pattern =  1:1
    for n = 1:size(centers,1)
        % viscircles(centers(n,:), radii,'Color',color_patterns2{n});
        if option == 1
            scatter(centers(n,1),centers(n,2),sz,'filled','MarkerFaceColor',color_patterns{pattern}{n});
        elseif option == 2
            scatter(centers(n,1),centers(n,2),sz,'^','filled','MarkerFaceColor',color_patterns{pattern}{n});
        elseif option == 3
            scatter(centers(n,1),centers(n,2),sz,'square','filled','MarkerFaceColor',color_patterns{pattern}{n});
        elseif option == 4
            scatter(centers(n,1),centers(n,2),sz,'pentagram','filled','MarkerFaceColor',color_patterns{pattern}{n});
        end
        %         xlim([-1 5])
        %         ylim([-1 5])

        hold on
    end
    xlim([0.9 3.1])
    ylim([0.9 3.1])
    axis square
    %         axis off
    ax = gca;

    if pattern == 2
        ax.Color = 'k';
    end

    ax.XColor = 'none';
    ax.YColor = 'none';
    set(ax, 'visible', 'off', 'dataaspectratio', [1 1 1]);
    hold off
    % Requires R2020a or later
    if option == 1
        exportgraphics(ax,sprintf('dot pattern white %i.png',pattern))
        %         saveas(ax,sprintf('dot pattern %i.png',pattern))
        original_image = imread(sprintf('dot pattern white %i.png',pattern));

        original_image = reshape(original_image(:,:,1),size(original_image,1),size(original_image,2));
        normalised_image = original_image/max(max(original_image));
        normalised_image_black = abs(255-normalised_image);
        imwrite(normalised_image_black,sprintf('dot pattern black %i.png',pattern));

        imagesc(normalised_image_black)
        axis square
        axis off
        colormap(bone)
        exportgraphics(gca,sprintf('dot pattern black %i.png',pattern),'ContentType','vector',...
            'BackgroundColor','black')
        %         saveas(gca,sprintf('dot pattern black %i.png',pattern))
        colormap(flip(bone))
        exportgraphics(gca,sprintf('dot pattern white %i.png',pattern),'ContentType','vector',...
            'BackgroundColor','none')
        %         saveas(gca,sprintf('dot pattern white %i.png',pattern))
    end
end
% end
