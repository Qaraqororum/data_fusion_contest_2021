function [SNR_L2A,SNR_LC08,SNR_S1A] = snr(im,verbose)


% OUTPUTS: 
% Esta funció retorna els SNR del Sentinel 2A, Landsat 8 i Sentinel 1A
% en forma de matrius on cada fila és un dia i cada columna una banda

% INPUTS:
% Les imatges llegides en estructura 
% El paràmetre verbose serveix per fer plots (1 per a sí, 0 per a no)

% SEPAREM PER DATES
L2A1_2=reshape(cat(3,im(10:21).tif),[800*800,12]);
L2A2_2=reshape(cat(3,im(22:33).tif),[800*800,12]);
L2A3_2=reshape(cat(3,im(34:45).tif),[800*800,12]);
L2A4_2=reshape(cat(3,im(46:57).tif),[800*800,12]);

LC108_2=reshape(cat(3,im(58:68).tif),[800*800,11]);
LC208_2=reshape(cat(3,im(69:79).tif),[800*800,11]);
LC308_2=reshape(cat(3,im(80:90).tif),[800*800,11]);

S1A1_2 = reshape(cat(3,im(91:92).tif),[800*800,2]);
S1A2_2 = reshape(cat(3,im(93:94).tif),[800*800,2]);
S1A3_2 = reshape(cat(3,im(95:96).tif),[800*800,2]);
S1A4_2 = reshape(cat(3,im(97:98).tif),[800*800,2]);


% SNR DEL SENTINEL 2A
VAR_S = var(double(L2A1_2));
VAR_N = var(diff(double(L2A1_2)));
SNR_L2A_1 = 10*log10(VAR_S./VAR_N); 

VAR_S = var(double(L2A2_2));
VAR_N = var(diff(double(L2A2_2)));
SNR_L2A_2 = 10*log10(VAR_S./VAR_N); 

VAR_S = var(double(L2A3_2));
VAR_N = var(diff(double(L2A3_2)));
SNR_L2A_3 = 10*log10(VAR_S./VAR_N); 

VAR_S = var(double(L2A4_2));
VAR_N = var(diff(double(L2A4_2)));
SNR_L2A_4 = 10*log10(VAR_S./VAR_N); 

% CADA FILA ÉS UNA DATA
SNR_L2A = [SNR_L2A_1; SNR_L2A_2; SNR_L2A_3; SNR_L2A_4];


% SNR DEL LANDSAT 8
VAR_S = var(double(LC108_2));
VAR_N = var(diff(double(LC108_2)));
SNR_LC08_1 = 10*log10(VAR_S./VAR_N); 

VAR_S = var(double(LC208_2));
VAR_N = var(diff(double(LC208_2)));
SNR_LC08_2 = 10*log10(VAR_S./VAR_N); 

VAR_S = var(double(LC308_2));
VAR_N = var(diff(double(LC308_2)));
SNR_LC08_3 = 10*log10(VAR_S./VAR_N); 

SNR_LC08 = [SNR_LC08_1; SNR_LC08_2; SNR_LC08_3];


% SNR DEL SENTINEL 1
VAR_S = var(double(S1A1_2));
VAR_N = var(diff(S1A1_2));
SNR_S1A_1 = 10*log10(VAR_S./VAR_N); 

VAR_S = var(double(S1A2_2));
VAR_N = var(diff(double(S1A2_2)));
SNR_S1A_2 = 10*log10(VAR_S./VAR_N); 

VAR_S = var(double(S1A3_2));
VAR_N = var(diff(double(S1A3_2)));
SNR_S1A_3 = 10*log10(VAR_S./VAR_N); 

VAR_S = var(double(S1A4_2));
VAR_N = var(diff(double(S1A4_2)));
SNR_S1A_4 = 10*log10(VAR_S./VAR_N); 

SNR_S1A = [SNR_S1A_1; SNR_S1A_2; SNR_S1A_3; SNR_S1A_4];

if verbose
    
    % PLOTS SENTINEL 2A
    figure
    subplot(2,2,1)
    plot(SNR_L2A(1,:)),xlabel('Banda'),ylabel('SNR[dB]'),title('Sentinel 2A (11-08-2020)'),
    xticklabels({'B1','B2','B3','B4','B5','B6','B7','B8','B9','B11','B12','B8A'})
    
    subplot(2,2,2)
    plot(SNR_L2A(2,:)),xlabel('Banda'),ylabel('SNR[dB]'),title('Sentinel 2A (16-08-2020)'),
    xticklabels({'B1','B2','B3','B4','B5','B6','B7','B8','B9','B11','B12','B8A'})
    
    subplot(2,2,3)
    plot(SNR_L2A(3,:)),xlabel('Banda'),ylabel('SNR[dB]'),title('Sentinel 2A (26-08-2020)'),
    xticklabels({'B1','B2','B3','B4','B5','B6','B7','B8','B9','B11','B12','B8A'})
    
    subplot(2,2,4)
    plot(SNR_L2A(4,:)),xlabel('Banda'),ylabel('SNR[dB]'),title('Sentinel 2A (31-08-2020)'),
    xticklabels({'B1','B2','B3','B4','B5','B6','B7','B8','B9','B11','B12','B8A'})
    
    
    % PLOTS LANDSAT 8
    figure
    subplot(1,3,1)
    plot(SNR_LC08(1,:)),xlabel('Banda'),ylabel('SNR[dB]'),title('Landsat 8 (29-07-2020)'),
    xticklabels({'B1','B10','B12','B2','B3','B4','B5','B6','B7','B8','B9'})
    
    subplot(1,3,2)
    plot(SNR_LC08(2,:)),xlabel('Banda'),ylabel('SNR[dB]'),title('Landsat 8 (14-08-2020)'),
    xticklabels({'B1','B10','B12','B2','B3','B4','B5','B6','B7','B8','B9'})
    
    subplot(1,3,3)
    plot(SNR_LC08(3,:)),xlabel('Banda'),ylabel('SNR[dB]'),title('Landsat 8 (30-08-2020)'),
    xticklabels({'B1','B10','B12','B2','B3','B4','B5','B6','B7','B8','B9'})
    
    
    % PLOTS SENTINEL 1A
    figure
    subplot(2,2,1)
    plot(SNR_S1A(1,:)),xlabel('Canal'),ylabel('SNR[dB]'),title('Sentinel 1A (23-07-2020)'),
    xticklabels({'VH','VV'})
    
    subplot(2,2,2)
    plot(SNR_S1A(2,:)),xlabel('Canal'),ylabel('SNR[dB]'),title('Sentinel 1A (04-08-2020)'),
    xticklabels({'VH','VV'})
    
    subplot(2,2,3)
    plot(SNR_S1A(3,:)),xlabel('Canal'),ylabel('SNR[dB]'),title('Sentinel 1A (16-08-2020)'),
    xticklabels({'VH','VV'})
    
    subplot(2,2,4)
    plot(SNR_S1A(4,:)),xlabel('Canal'),ylabel('SNR[dB]'),title('Sentinel 1A (28-08-2020)'),
    xticklabels({'VH','VV'})
    
end   
    
end

