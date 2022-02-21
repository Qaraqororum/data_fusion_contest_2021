function rgb_landsent(path_to_tile,n_tile)
% Funció que crea els dibuixos de RGB de les dades. En favor de la simplesa del codi
% no hem volgut afegir un paràmetre de saturació i es deixa a l'usuari
% l'edició manual dels paràmetres del contrast editant la pròpia funció


% CARREGA DE DADES
patro1 = fullfile(path_to_tile, '*.tif');
fitxers = dir(patro1);
im = struct('tif', cell(1, 99), 'name', cell(1,99)); % En tif tenim les matrius de les imatges i en name el nom de la imatge

for k = 1:length(fitxers)
    baseFileName = fitxers(k).name;
    fullFileName = fullfile(fitxers(k).folder, baseFileName);
    fprintf(1, 'Carregant %s\n', fullFileName);
    
    im(k).tif = imread(fullFileName);
    im(k).name = fitxers(k).name;
%     imshow(im(k).tif);  
%     drawnow; 
end

%% RGBs Sentinel 2A
  
rgb_s2_1 = cat(3,im(13).tif,im(12).tif,im(11).tif);
rgb_s2_2 = cat(3,im(25).tif,im(24).tif,im(23).tif);
rgb_s2_3 = cat(3,im(37).tif,im(36).tif,im(35).tif);
rgb_s2_4 = cat(3,im(49).tif,im(48).tif,im(47).tif);
    
rgb_s2_1 = mat2gray(rgb_s2_1);
rgb_s2_1 = imadjust(rgb_s2_1,stretchlim(rgb_s2_1,[0.01 0.99]),[]);

rgb_s2_2 = mat2gray(rgb_s2_2);
rgb_s2_2 = imadjust(rgb_s2_2,stretchlim(rgb_s2_2,[0.01 0.99]),[]);

rgb_s2_3 = mat2gray(rgb_s2_3);
rgb_s2_3 = imadjust(rgb_s2_3,stretchlim(rgb_s2_3,[0.10 0.80]),[]);

rgb_s2_4 = mat2gray(rgb_s2_4);
rgb_s2_4 = imadjust(rgb_s2_4,stretchlim(rgb_s2_4,[0.10 0.80]),[]);

figure
imagesc(rgb_s2_1)
axis 'off'
txt = ['Tile ',num2str(n_tile),' | Sentinel 2A (11-08-2020)'];
title(txt)
    
figure
imagesc(rgb_s2_2)
axis 'off'
txt = ['Tile ',num2str(n_tile),' | Sentinel 2A (16-08-2020)'];
title(txt)

figure
imagesc(rgb_s2_3)
axis 'off'
txt = ['Tile ',num2str(n_tile),' | Sentinel 2A (26-08-2020)'];
title(txt)

figure
imagesc(rgb_s2_4)
axis 'off'
txt = ['Tile ',num2str(n_tile),' | Sentinel 2A (31-08-2020)'];
title(txt)

%% RGBs Landsat 8 TM
rgb_l8_1 = cat(3,im(62).tif,im(61).tif,im(58).tif);
rgb_l8_2 = cat(3,im(73).tif,im(72).tif,im(69).tif);
rgb_l8_3 = cat(3,im(84).tif,im(83).tif,im(80).tif);
    
rgb_l8_1 = mat2gray(rgb_l8_1);
rgb_l8_1 = imadjust(rgb_l8_1,stretchlim(rgb_l8_1,[0.10 0.90]),[]);

rgb_l8_2 = mat2gray(rgb_l8_2);
rgb_l8_2 = imadjust(rgb_l8_2,stretchlim(rgb_l8_2,[0.01 0.99]),[]);

rgb_l8_3 = mat2gray(rgb_l8_3);
rgb_l8_3 = imadjust(rgb_l8_3,stretchlim(rgb_l8_3,[0.10 0.90]),[]);

figure
imagesc(rgb_l8_1)
axis 'off'
txt = ['Tile ',num2str(n_tile),' | Landsat 8 TM (29-07-2020)'];
title(txt)
    
figure
imagesc(rgb_l8_2)
axis 'off'
txt = ['Tile ',num2str(n_tile),' | Landsat 8 TM (14-08-2020)'];
title(txt)

figure
imagesc(rgb_l8_3)
axis 'off'
txt = ['Tile ',num2str(n_tile),' | Landsat 8 TM (30-08-2020)'];
title(txt)

end

