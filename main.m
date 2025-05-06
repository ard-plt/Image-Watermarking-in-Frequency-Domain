% To work with different frequency bands, select the desired region by modifying the 'watermarkPosition' below.
clc;
clear;
close all;

% Read original image and watermark
image = im2double(imread('landscape.jpg'));
watermark = im2double(imread('watermark.jpg'));

% Convert to grayscale if necessary
if size(image, 3) == 3
    image = rgb2gray(image);
end
if size(watermark, 3) == 3
    watermark = rgb2gray(watermark);
end

[rows, cols] = size(image);

% Resize watermark to 30% of image dimensions
wm_rows = round(rows * 0.3);
wm_cols = round(cols * 0.3);
resizedWatermark = imresize(watermark, [wm_rows, wm_cols]);

% Display image properties
[height, width, channels] = size(image);
fprintf('Image height: %d pixels\n', height);
fprintf('Image width: %d pixels\n', width);
fprintf('Channels: %d\n', channels);

[height, width, channels] = size(resizedWatermark);
fprintf('Watermark height: %d pixels\n', height);
fprintf('Watermark width: %d pixels\n', width);
fprintf('Channels: %d\n', channels);

% Position watermark in different frequency bands
wmPos1 = zeros(rows, cols); % low frequency
r1 = round(rows / 2 - wm_rows / 2);
c1 = round(cols / 2 - wm_cols / 2);
wmPos1(r1:r1+wm_rows-1, c1:c1+wm_cols-1) = resizedWatermark;

wmPos2 = zeros(rows, cols); % mid frequency
r2 = round(rows * 0.5);
c2 = round(cols * 0.5);
wmPos2(r2:r2+wm_rows-1, c2:c2+wm_cols-1) = resizedWatermark;

wmPos3 = zeros(rows, cols); % high frequency
wmPos3(1:wm_rows, 1:wm_cols) = resizedWatermark;

% Select watermark position here
watermarkPosition = wmPos1;   % low frequency
%watermarkPosition = wmPos2; % mid frequency
%watermarkPosition = wmPos3; % high frequency

% Apply FFT and add watermark
f = fft2(image);
fShifted = fftshift(f);
alpha = 0.1;
fWatermarked = fShifted + alpha * watermarkPosition;
fInverseShift = ifftshift(fWatermarked);
imageWatermarked = real(ifft2(fInverseShift));

% Display images and spectra
figure, imshow(image), title('Original Image');
figure, imshow(watermark), title('Watermark');
figure;
subplot(1, 2, 1), imshow(log(abs(fShifted) + 1), []), title('Original Spectrum');
subplot(1, 2, 2), imshow(log(abs(fWatermarked) + 1), []), title('Watermarked Spectrum');
figure;
imshow(imageWatermarked, []), title('Watermarked Image');

% Watermark extraction
fExtracted = fftshift(fft2(imageWatermarked));
recoveredWatermark = (fExtracted - fShifted) / alpha;
recoveredWatermark = mat2gray(abs(recoveredWatermark));

figure;
imshow(recoveredWatermark, []), title('Extracted Watermark');

% BONUS: Add watermark using FFT of the watermark itself
fft_wm = fft2(watermarkPosition);
fft_wm_shifted = fftshift(fft_wm);
bonus_f = fShifted + alpha * fft_wm_shifted;
bonus_unshifted = ifftshift(bonus_f);
bonusImage = real(ifft2(bonus_unshifted));

figure;
imshow(bonusImage, []), title('BONUS: Watermark Added via FFT of Watermark');
