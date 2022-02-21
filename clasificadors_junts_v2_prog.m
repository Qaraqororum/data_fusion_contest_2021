% Miguel Hortelano, Jose Luis García, Bertran Mollà Bononad
% Clasificador Conjunto
%%
clear, clc, close all
% Inicialitzem la llavor per poder reproduir resultats i especifiquem paths
rand('seed',1234)
directorio="E:\master\AEI\Trabajo AEI\02-GRSS_competition_Detection_Settlements\concurs\Train\Tile";
addpath('E:\master\AEI\Trabajo AEI');

fout1 = '/home/bertran/Documents/Master TD/AEI/Treball/Variables/ypred_knn_total';
fout2 = '/home/bertran/Documents/Master TD/AEI/Treball/Variables/ypred_quad_total';
% fout3 = '/home/bertran/Documents/Master TD/AEI/Treball/Variables/ypred_tree_total';
fout4 = '/home/bertran/Documents/Master TD/AEI/Treball/Variables/ytest_total';

fout5 = '/home/bertran/Documents/Master TD/AEI/Treball/Variables/scores_knn_total';
fout6 = '/home/bertran/Documents/Master TD/AEI/Treball/Variables/scores_quad_total';
% fout7 = '/home/bertran/Documents/Master TD/AEI/Treball/Variables/scores_tree_total';

fout8 = '/home/bertran/Documents/Master TD/AEI/Treball/Variables/Cknn';
fout9 = '/home/bertran/Documents/Master TD/AEI/Treball/Variables/clas1knn';
fout10 = '/home/bertran/Documents/Master TD/AEI/Treball/Variables/deltaknn';
fout11 = '/home/bertran/Documents/Master TD/AEI/Treball/Variables/prgknn';

fout12 = '/home/bertran/Documents/Master TD/AEI/Treball/Variables/Cd';
fout13 = '/home/bertran/Documents/Master TD/AEI/Treball/Variables/clas1d';
fout14 = '/home/bertran/Documents/Master TD/AEI/Treball/Variables/deltad';
fout15 = '/home/bertran/Documents/Master TD/AEI/Treball/Variables/prgd';


%% Entrenament i validació creuada: inicialitzem les variables de matriu de confusió, precisió de la classe 1, temps i OA dels diferents models
Cknn=zeros([4 4 5]); clas1knn=zeros([1 1 5]); deltaknn=zeros([1 1 5]); prgknn=zeros([1 1 5]);
Cd=zeros([4 4 5]); clas1d=zeros([1 1 5]); deltad=zeros([1 1 5]); prgd=zeros([1 1 5]);
% C_tree=zeros([4 4 5]); clas1_tree=zeros([1 1 5]); delta_tree=zeros([1 1 5]); prg_tree=zeros([1 1 5]);
tiles=ceil(randperm(60));

ypred_knn_total = [];
ypred_quad_total = [];
% ypred_tree_total = [];
ytest_total = [];

scores_knn_total = [];
scores_quad_total = [];
% scores_tree_total = [];


% Dividim les dades en 5 conjunts per a validació creuada
for j=[0 12 24 36 48]
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

        Xtest=[Xtest;Xband]; ytest=double([ytest;yband]);
    end
    
    
    %% QUADRÀTIC DE MÀXIMA VERSEMBLANÇA
    t0=cputime;
    modelo = fitcdiscr(Xtrain,ytrain,'DiscrimType','quadratic','Prior','uniform'); % Emprem classes equiprobables ja que dona millor resultat
    ypred_quad=zeros([length(ytest),1]); scores_quad=zeros([length(ytest),4]);
    for i=1:length(ytest)
        Xtest_array=cell2mat(Xtest(i));
        [z,v,a]=predict(modelo,Xtest_array);
        ypred_quad(i)=double(mode(z));
        scores_quad(i,:)=double(mode(v,1));
    end
    deltad(:,:,j/12+1)=cputime-t0;
    C=confusionmat(ytest,ypred_quad,'Order',[1 2 3 4]);% Matriu de confusió ---> forcem a què apareguen totes les classes
    figure,heatmap(C),title('discr sobre bandes'), ylabel('Real'),xlabel('Predit')
    prgd=sum(diag(C))/length(ytest);

    clas1d(:,:,j/12+1)=C(1,1)/length(find(ytest==1));
    Cd(:,:,j/12+1)=C;
    %plot_roc(ytest,scores_quad);
    
    
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
    %plot_roc(ytest,scores_knn);
    
    %% FIT TREE
%     t0=cputime;
%     %modelo = fitcknn(Xtrain,ytrain,'Distance','chebychev','NumNeighbors',12);
%     modelo = fitctree(Xtrain,ytrain,'Prior','uniform');
%     ypred_tree=zeros([length(ytest),1]); scores_tree=zeros([length(ytest),4]);
%     for i=1:length(ytest)
%         Xtest_array=cell2mat(Xtest(i));
%         [z,v,a]=predict(modelo,Xtest_array);
%         ypred_tree(i)=double(mode(z));
%         scores_tree(i,:)=double(mode(v,1));
%     end
%     delta_tree(:,:,j/12+1)=cputime-t0;
%     C=confusionmat(ytest,ypred_tree,'Order',[1 2 3 4]);% matriz de confusion
%     figure,heatmap(C),title('Arbre sobre bandes'), ylabel('Real'),xlabel('Predit')
%     prg_tree(:,:,j/12+1)=sum(diag(C))/length(ytest);
%     clas1_tree(:,:,j/12+1)=C(1,1)/length(find(ytest==1));
%     C_tree(:,:,j/12+1)=C;
%     %plot_roc(ytest,scores_tree);
    

% En aquestes variables anem emmagatzemant la informació de cada iteració    
    ypred_knn_total = cat(1,ypred_knn_total,ypred_knn);
    ypred_quad_total = cat(1,ypred_quad_total,ypred_quad);
%   ypred_tree_total = cat(1,ypred_tree_total,ypred_tree);
    ytest_total = cat(1,ytest_total,ytest);
    
    
    scores_knn_total = cat(1,scores_knn_total,scores_knn);
    scores_quad_total = cat(1,scores_quad_total,scores_quad);
%   scores_tree_total = cat(1,scores_tree_total,scores_tree);
    
    j
end

% Guardem les varibales per al seu anàlisi posterior
save(fout1,'ypred_knn_total')
save(fout2,'ypred_quad_total')
% save(fout3,'ypred_tree_total')
save(fout4,'ytest_total')

save(fout5,'scores_knn_total')
save(fout6,'scores_quad_total')
% save(fout7,'scores_tree_total')

save(fout8,'Cknn')
save(fout9,'clas1knn')
save(fout10,'deltaknn')
save(fout11,'prgknn')

save(fout12,'Cd')
save(fout13,'clas1d')
save(fout14,'deltad')
save(fout15,'prgd')

% figure
% bar(temps);
% xlabel('Classificador'), ylabel('Temps (s)')
% xticklabels({'Quad','K-NN','Quad (PCA)','K-NN (PCA)'})
% title('Temps de computació')


%% FUNCIÓ DE CÀRREGA DE DADES

function [bands,gt]=band_extractor(path_to_tile,train_or_test)
    patro1 = fullfile(path_to_tile, '*.tif');
    fitxers = dir(patro1);
    im = struct('tif', cell(1, 99), 'name', cell(1,99));
% Es carreguen les bandes del tile en qüestió
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
    % Bandes específiques per a resaltar el sol construit
    
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
        % Processem en cel·les pixels de validació
        bands=reescale_totruth(bands,mask); 
        % Eliminem cel.les totalment nuvoloses sense píxels vàlids
        cloud_cell=cellfun(@isempty,bands);
        bands(cloud_cell)=[];
        
%       gt=zeros(256,1); % zeros(16,16); 
        gt = reshape(im(99).tif,[256,1]);
%        for i=1:16
%            for j=1:16
%                gt(i*j,1)=im(99).tif(i,j);
%            end
%        end
        gt(cloud_cell)=[];
    elseif train_or_test=="train"
        bands=reshape(bands,[800*800,8]); bands=bands(find(mask==1),:);
        gt=reescale_truth(im(99).tif); 
        gt=reshape(gt,[800*800,1]);
        gt=gt(find(mask==1),:);
    end
end
