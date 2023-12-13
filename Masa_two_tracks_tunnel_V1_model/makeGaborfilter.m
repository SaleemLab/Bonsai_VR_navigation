function [gaborFilterA, gaborFilterB, filtOut, smthFiltOut, peak1, peak2, smod] = makeGaborfilter(allImages, sf, gauss_win, x, ori,plotTag)
% [filtOut, smthFiltOut] = makeSillyGabor(allImages, sfreq, gauss_win, x, ori)
% default values:
%     sfreq = 10
%     gauss_win = 100;
%     x = 2000;
%     ori = 0;

if nargin<2
    sf = 0.03;
end
if nargin<3
    %     gauss_win = 100;
    gauss_win = 80;
end
if nargin<4
    x = 2000;
end
if nargin<5
    ori = 0;
end


if nargin<6
    plotTag = 0;
end

sfreq = sf*75;

%% Make the quadrature filters
sinewave = sin(0:(2*pi*sfreq/479):(sfreq)*2*pi);

sinewave = repmat(sinewave, 480, 1);
coswave = cos(0:(2*pi*sfreq/479):(sfreq)*2*pi);
coswave = repmat(coswave, 480, 1);

sinewave = imrotate(sinewave, ori, 'crop');
coswave = imrotate(coswave, ori, 'crop');

fullSin = zeros(480,1920);
fullSin(:,x-239:x+240) = sinewave;
fullCos = zeros(480,1920);
fullCos(:,x-239:x+240) = coswave;

window = fspecial('gaussian', 480, gauss_win);
fullImage = zeros(480,1920);
fullImage(:,x-239:x+240) = window;
% imagesc(fullImage)

gaborFilterA = fullImage.*fullSin;
gaborFilterB = fullImage.*fullCos;
gaborFilterA = gaborFilterA./max(gaborFilterA(:));
gaborFilterB = gaborFilterB./max(gaborFilterB(:));

if plotTag
    subplot(221)
    imagesc(gaborFilterA, [-1 1]); colormap(gray)
    axis equal; axis off
    subplot(223)
    imagesc(gaborFilterB, [-1 1]); colormap(gray)
    title('Gabor')
    axis equal; axis off
end
%% Filter the images through
a = reshape(gaborFilterA, 1, [])*(squeeze(reshape(allImages, size(allImages,1), 1, [])))';
b = reshape(gaborFilterB, 1, [])*(squeeze(reshape(allImages, size(allImages,1), 1, [])))';
filtOut = sqrt(a.^2 + b.^2);

filtOut = filtOut./max(filtOut);
smthFiltOut = filtOut;
smthFiltOut(isnan(filtOut)) = 0;
smthFiltOut = fastsmooth(smthFiltOut,3,3);

if plotTag
    subplot(222);
    plot(filtOut, 'linewidth',2);
    title('Quadrature pair')
    subplot(224);
    plot(smthFiltOut, 'linewidth',2);
    title('Smoothed Gabor Response')
    xlabel('Position (cm)')
    ylabel('Response (a.u.)')
end

[peak_respond1, peakPos1] = max(smthFiltOut);
peak1 = [peakPos1 peak_respond1];

if peakPos1<41
    [peak_respond2,peakPos2] = max(smthFiltOut((peakPos1+40-5):(peakPos1+40+5)));
elseif peakPos1>45 
     [peak_respond2,peakPos2] = max(smthFiltOut((peakPos1-40-5):(peakPos1-40+5)));
else
     [peak_respond2,peakPos2] = max(smthFiltOut(1:(peakPos1-40+5)));
end

peak2 = [peakPos2 peak_respond2];

% Spatial modultion defined as preferred segment respond minus non–preferred segment respond, divided by their sum
smod = abs(peak_respond1 - peak_respond2)/(peak_respond1 + peak_respond2);


end