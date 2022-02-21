%% PROGRAMA PER A EXTRAURE UN TILE D'EXEMPLE
clear, clc, close all
rand('seed',1234)
%Definim en directorio 2 el Tile que volen classificar i en 1 la carpeta on
%estan tots els tiles
directorio2 = 'E:\master\AEI\Trabajo AEI\02-GRSS_competition_Detection_Settlements\concurs\Train\Tile9';
directorio = 'E:\master\AEI\Trabajo AEI\02-GRSS_competition_Detection_Settlements\concurs\Train\Tile';

addpath('E:\master\AEI\Trabajo AEI');
%% Entrenament i validació creuada
Cknn=zeros([4 4 5]); clas1knn=zeros([1 1 5]); deltaknn=zeros([1 1 5]); prgknn=zeros([1 1 5]);
Cd=zeros([4 4 5]); clas1d=zeros([1 1 5]); deltad=zeros([1 1 5]); prgd=zeros([1 1 5]);
C_tree=zeros([4 4 5]); clas1_tree=zeros([1 1 5]); delta_tree=zeros([1 1 5]); prg_tree=zeros([1 1 5]);
tiles=ceil(randperm(60));

ypred_knn_total = [];
ytest_total = [];

scores_knn_total = [];

% dividim les dades en 5 conjunts per a validació creuada
for j=[36]
    file=strcat(directorio,num2str(i));
    Xtrain=[]; ytrain=[]; Xtest={}; ytest=[];
    testiles=(j+1:1:j+12);
    traintiles=tiles; del=ismember(traintiles,tiles(testiles)); traintiles(del)=[];
    for i=tiles(traintiles)
        file=strcat(directorio,num2str(i));

        [Xband,yband]=band_extractor(file,"train");

        Xtrain=[Xtrain;Xband]; ytrain=[ytrain;yband];
    end
    
    for i=tiles(testiles)
        file=strcat(directorio,num2str(i));

        [Xband,yband]=band_extractor(file,"test");

        Xtest=[Xtest;Xband]; ytest=[ytest;yband];
    end

    %% K-NN
    t0=cputime;
    %modelo = fitcknn(Xtrain,ytrain,'Distance','chebychev','NumNeighbors',12);
    modelo = fitcknn(Xtrain,ytrain,'NumNeighbors',12,'Distance','chebychev');
    ypred_knn=zeros([length(ytest),1]); scores_knn=zeros([length(ytest),4]);
    for i=1:length(ytest)
        Xtest_array=cell2mat(Xtest(i));
        [z,v,a]=predict(modelo,Xtest_array);
        ypred_knn(i)=double(mode(z));
        scores_knn(i,:)=double(mode(v,1));
    end
    deltaknn(:,:,j/12+1)=cputime-t0;
    C=confusionmat(ytest,ypred_knn,'Order',[1 2 3 4]);% matriz de confusion
    figure,heatmap(C),title('K-nn sobre bandes'), ylabel('Real'),xlabel('Predit')
    prgknn(:,:,j/12+1)=sum(diag(C))/length(ytest);
    clas1knn(:,:,j/12+1)=C(1,1)/length(find(ytest==1));
    Cknn(:,:,j/12+1)=C;
   
    
    ypred_knn_total = cat(1,ypred_knn_total,ypred_knn);
    ytest_total = cat(1,ytest_total,ytest);
    
    
    scores_knn_total = cat(1,scores_knn_total,scores_knn);
  
    j
end
%% Band extractor esta definit apart en una funció
[Xband,cloud_cell]=band_extractor2(directorio2,'test');

    ypred_knn=zeros([256,1]); scores_knn=zeros([256,4]);
    for i=1:256
        if cloud_cell(i)==0
            Xtest_array=cell2mat(Xband(i));
            [z,v,a]=predict(modelo,Xtest_array);
            ypred_knn(i)=double(mode(z));
            scores_knn(i,:)=double(mode(v,1));
        elseif cloud_cell(i)==1
            ypred_knn(i)=0;
        end
    end
    figure
    imagesc(reshape(ypred_knn,[16,16]))
    clase1=ypred_knn==1;
    figure
    imagesc(reshape(clase1,[16,16]))
    nuvols=ypred_knn==0;
    nuvols=nuvols*2;
    pred=nuvols+clase1;
    figure
    imagesc(reshape(pred,[16,16]));
    colorbar('YTick',0:2,'YTickLabel',{'No classe','Classe 1','Núvol'})
    colormap([0 0 1; 1 0 0;1 1 0])
%% band extractor
    function [bands,gt]=band_extractor(path_to_tile,train_or_test)
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
    if train_or_test=="test"
        %processem en cel·les pixels de validació
        bands=reescale_totruth(bands,mask); 
        % eliminem cel.les totalment nuboses sense pixels vàlids
        cloud_cell=cellfun(@isempty,bands);
        bands(cloud_cell)=[];
        
        gt=zeros(256,1);
        for i=1:16
            for j=1:16
                gt(i*j,1)=im(99).tif(i,j);
            end
        end
        gt(cloud_cell)=[];
    elseif train_or_test=="train"
        bands=reshape(bands,[800*800,8]); bands=bands(find(mask==1),:);
        gt=reescale_truth(im(99).tif); 
        gt=reshape(gt,[800*800,1]);
        gt=gt(find(mask==1),:);
    end
end