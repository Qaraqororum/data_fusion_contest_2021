% Miguel Hortelano, Jose Luis García, Bertran Mollà Bononad
% Clasificador Conjunt per a PCs. S'ha afegit la secció CÀLCUL DE PCs
%%
clear, clc, close all
rand('seed',1234)
directorio = 'E:\master\AEI\Trabajo AEI\02-GRSS_competition_Detection_Settlements\concurs\Train\Tile';
addpath('E:\master\AEI\Trabajo AEI');

fout1 = 'E:\master\AEI\Trabajo AEI\Variables\ypred_knn_total';
fout2 = 'E:\master\AEI\Trabajo AEI\Variables\ypred_quad_total';
%fout3 = 'E:\master\AEI\Trabajo AEI\Variables\ypred_tree_total';
fout4 = 'E:\master\AEI\Trabajo AEI\Variables\ytest_total';

fout5 = 'E:\master\AEI\Trabajo AEI\Variables\scores_knn_total';
fout6 = 'E:\master\AEI\Trabajo AEI\Variables\scores_quad_total';
%fout7 = 'E:\master\AEI\Trabajo AEI\Variables\scores_tree_total';


%% Entrenament i validació creuada
Cknn=zeros([4 4 5]); clas1knn=zeros([1 1 5]); deltaknn=zeros([1 1 5]); prgknn=zeros([1 1 5]);
Cd=zeros([4 4 5]); clas1d=zeros([1 1 5]); deltad=zeros([1 1 5]); prgd=zeros([1 1 5]);
C_tree=zeros([4 4 5]); clas1_tree=zeros([1 1 5]); delta_tree=zeros([1 1 5]); prg_tree=zeros([1 1 5]);
tiles=ceil(randperm(60));

ypred_knn_total = [];
ypred_quad_total = [];
ytest_total = [];

scores_knn_total = [];
scores_quad_total = [];


% dividim les dades en 5 conjunts per a validació creuada
for j=[0 12 24 36 48]
    clear Xtest mats
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
    
    %% CÀLCUL DE PCs
    %Conjunt train
    t0=cputime;
    %Ús de pca per a trobar les components principals 3 de sentinel2, 3 de
    %LC08 i afegim una mediana temporal de DNB i una mediana temporal de
    %S1A
    [LC08co,LC08pc,LC08eig]=pca(Xtrain(:,3:13), 'NumComponents',3);
    [S2Aco,S2Apc,S2Aeig]=pca(Xtrain(:,14:25), 'NumComponents',3);
    VV=Xtrain(:,2);
    DNB=Xtrain(:,1);
    clear Xtrain
    Xtrain=cat(2,DNB,VV,LC08pc,S2Apc);
    clear DNB VV LC08pc S2Apc
    %Conjunt test: transformem les celes de test donades per
    %band_extractor, trobem les components principals i tornen a clavar-les
    %en les celes corresponents
    for i=1:length(Xtest)
       mats(i)=size(Xtest{i},1); 
    end
    xt=cell2mat(Xtest);
    [LC08co,LC08pc,LC08eig]=pca(xt(:,3:13), 'NumComponents',3);
    [S2Aco,S2Apc,S2Aeig]=pca(xt(:,14:25), 'NumComponents',3);
    VV=xt(:,2);
    DNB=xt(:,1);
    clear xt Xtest
    xtest=cat(2,DNB,VV,LC08pc,S2Apc);
    clear DNB VV LC08pc S2Apc
    Xtest= mat2cell(xtest,mats);
    deltaPC=cputime-t0;

    %% QUADRÀTIC
    t0=cputime;
    modelo = fitcdiscr(Xtrain,ytrain,'DiscrimType','quadratic','Prior','uniform');
    ypred_quad=zeros([length(ytest),1]);
    scores_quad=zeros([length(ytest),4]);
    for i=1:length(ytest)
        Xtest_array=cell2mat(Xtest(i));
        [z,v,a]=predict(modelo,Xtest_array);
        ypred_quad(i)=double(mode(z));
        scores_quad(i,:)=double(mode(v,1));
    end
    deltad(:,:,j/12+1)=cputime-t0;
    C=confusionmat(ytest,ypred_quad,'Order',[1 2 3 4]);% matriz de confusion
    figure,heatmap(C),title('discr sobre bandes'), ylabel('Real'),xlabel('Predit')
    prgd=sum(diag(C))/length(ytest);

    clas1d(:,:,j/12+1)=C(1,1)/length(find(ytest==1));
    Cd(:,:,j/12+1)=C;
    %plot_roc(ytest,scores_quad);
    
    
    %% K-NN
    t0=cputime;
    %modelo = fitcknn(Xtrain,ytrain,'Distance','chebychev','NumNeighbors',12);
    modelo = fitcknn(Xtrain,ytrain,'NumNeighbors',12,'Distance','chebychev');
    ypred_knn=zeros([length(ytest),1]); 
    scores_knn=zeros([length(ytest),4]);
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
    ypred_quad_total = cat(1,ypred_quad_total,ypred_quad);
    ytest_total = cat(1,ytest_total,ytest);
    
    
    scores_knn_total = cat(1,scores_knn_total,scores_knn);
    scores_quad_total = cat(1,scores_quad_total,scores_quad);
    
    j
end
 
save(fout1,'ypred_knn_total')
save(fout2,'ypred_quad_total')
save(fout4,'ytest_total')

save(fout5,'scores_knn_total')
save(fout6,'scores_quad_total')

save('PCknn','Cknn','clas1knn','prgknn','deltaknn')
save('PCdiscr','Cd','clas1d','prgd','deltad')

%%
function plot_roc(ytest,scores)
    [Xknn1,Yknn1]=perfcurve(ytest,scores(:,1),1);
    [Xknn2,Yknn2]=perfcurve(ytest,scores(:,2),2);
    [Xknn3,Yknn3]=perfcurve(ytest,scores(:,3),3);
    [Xknn4,Yknn4]=perfcurve(ytest,scores(:,4),4); 
    figure;hold on;
    plot(Xknn1,Yknn1,'k',Xknn2,Yknn2,'r',Xknn3,Yknn3,'b',Xknn4,Yknn4,'m');
    title('Corba ROC Classificador knn');
    xlabel('');ylabel('');
    xlabel('False positive rate');ylabel('True positive rate');
    legend('Classe 1','Classe 2','Classe 3','Classe 4');
    hold off;
end
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

    end

    [mask,ident]=mask_nubes(im,0,0,0,0,0);
    mask=(mask(:,:,2)+mask(:,:,7))==0;
    % bandes específiques per a resaltar el sol construit
    
%     NDBI=(im(87).tif-im(86).tif)./(im(87).tif+im(86).tif);
%     MNDWI=(im(84).tif-im(86).tif)./(im(84).tif+im(86).tif);
%     NDVI=(im(86).tif-im(85).tif)./(im(86).tif+im(85).tif);
%     NDMIR=(im(87).tif-im(88).tif)./(im(87).tif+im(88).tif);
%     NDRB=(im(85).tif-im(83).tif)./(im(85).tif+im(83).tif);
%     NDGB=(im(84).tif-im(83).tif)./(im(84).tif+im(83).tif);
    %S'extrauen el dia menys nuvolat de cada Sentinel2A i LC08
    LC08=cat(3,im(80).tif,im(81).tif,im(82).tif,im(83).tif,im(84).tif,im(85).tif,im(86).tif,im(87).tif,im(88).tif,im(89).tif,im(90).tif);
    S2A=cat(3,im(22).tif,im(23).tif,im(24).tif,im(25).tif,im(26).tif,im(27).tif,im(28).tif,im(29).tif,im(30).tif,im(31).tif,im(32).tif,im(33).tif);
    dnb=median(cat(3,im(1).tif,im(2).tif,im(3).tif,im(4).tif,im(5).tif,im(6).tif,im(7).tif,im(8).tif,im(9).tif),3);
    VV=median(cat(3,im(92).tif,im(94).tif,im(96).tif,im(98).tif),3);
    %lbands=cat(3,NDBI,MNDWI,NDVI,NDMIR,NDRB,NDGB);
    bands=zeros([800 800 25]); 
    bands(:,:,1)=dnb; 
    bands(:,:,2)=VV; 
    bands(:,:,3:13)=LC08;
    bands(:,:,14:25)=S2A; 
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
        bands=reshape(bands,[800*800,25]); bands=bands(find(mask==1),:);
        gt=reescale_truth(im(99).tif); 
        gt=reshape(gt,[800*800,1]);
        gt=gt(find(mask==1),:);
    end
end