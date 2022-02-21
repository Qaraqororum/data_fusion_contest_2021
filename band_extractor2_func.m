function [bands,cloud_cell]=band_extractor2(path_to_tile,train_or_test)
    % Modificació de band extractor de cara a traure exemples d'imatges per
    % comparació amb veritat terreny. S'ha afegit l'output cloud_cell que
    % indica els píxels del groundtruth que estan plens de núvols
    
    % El funcionament és el mateix, s'ha suprimit el if que funciona amb
    % train_or_test
    patro1 = fullfile(path_to_tile, '*.tif');
    fitxers = dir(patro1);
    im = struct('tif', cell(1, 99), 'name', cell(1,99));

    for k = 1:length(fitxers)
        baseFileName = fitxers(k).name;
        fullFileName = fullfile(fitxers(k).folder, baseFileName);
        %fprintf(1, 'Carregant %s\n', fullFileName);

        if k==99
            im(k).tif = imread(fullFileName);
        	im(k).name = fitxers(k).name; 
        else
        im(k).tif = medfilt2(single(imread(fullFileName)),[3 3]);
        im(k).name = fitxers(k).name;
        end
    %     imshow(im(k).tif);  
    %     drawnow; 
    end

    [mask,ident]=mask_nubes(im,0,0,0,0,0);
    mask=(mask(:,:,2)+mask(:,:,7))==0;
    % bandes específiques per a resaltar el sol construit
    
    NDBI=(im(87).tif-im(86).tif)./(im(87).tif+im(86).tif);
    MNDWI=(im(84).tif-im(86).tif)./(im(84).tif+im(86).tif);
    NDVI=(im(86).tif-im(85).tif)./(im(86).tif+im(85).tif);
    NDMIR=(im(87).tif-im(88).tif)./(im(87).tif+im(88).tif);
    NDRB=(im(85).tif-im(83).tif)./(im(85).tif+im(83).tif);
    NDGB=(im(84).tif-im(83).tif)./(im(84).tif+im(83).tif);
    % mediana de les imatges per a obtindre major precisió
    dnb=median(cat(3,im(1).tif,im(2).tif,im(3).tif,im(4).tif,im(5).tif,im(6).tif,im(7).tif,im(8).tif,im(9).tif),3);
    VV=median(cat(3,im(92).tif,im(94).tif,im(96).tif,im(98).tif),3);
    lbands=cat(3,NDBI,MNDWI,NDVI,NDMIR,NDRB,NDGB);
    bands=zeros([800 800 8]); 
    bands(:,:,1)=dnb; bands(:,:,2:7)=lbands; 
    bands(:,:,8)=VV; %bands=medfilt2(bands,[3 3]);
   
    %Reescalem imatges a 16x16 i reservem  en cloud_cell les posicions dels píxels plens
    %de núvols
        %processem en cel·les pixels de validació
        bands=reescale_totruth(bands,mask); 
        % eliminem cel.les totalment nuboses sense pixels vàlids
        cloud_cell=cellfun(@isempty,bands);
        %bands(cloud_cell)=[];
end