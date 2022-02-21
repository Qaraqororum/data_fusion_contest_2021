clear, clc, close all;
rand('seed',1234)
directorio="E:\master\AEI\Trabajo AEI\02-GRSS_competition_Detection_Settlements\concurs\Train\Tile";
%% Llamamos a la funcion con varias bandas
%Programa de càlcul de la separabilitat espectral en el que s'ha
%implementat la la funció de càrrega amb els índexs d'interés
L2p=[2 2 2 2 2 2];
DFL2=Jefries(directorio,L2p);


%% Anàlisis de resultados
%Mejor separación clases L2P
L2Clases=zeros(2,4);
for i=2:4
    ind=max(DFL2(1,i,:));
    L2Clases(1,i)=i;
    L2Clases(2,i)=ind;
end
for i=1:length(L2p(:,1))
    mediaL2(i)=mean(DFL2(1,2:4,i));
end
%Mejor separación clases LC08
% LC08Clases=zeros(2,4);
% for i=2:4
%     ind=max(DFLC08(1,i,:));
%     LC08Clases(1,i)=i;
%     LC08Clases(2,i)=ind;
% end
% for i=1:length(LC08p(:,1))
%     mediaLC08(i)=mean(DFLC08(1,2:4,i));
% end
%%
save('Separacion_Indexos');
                        %% Seleccion de clases %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DF=Jefries(directorio,Ba)
%% Selección de clases
%tiles=1:10;
tiles=ceil(randperm(30));
Xtrain=[]; ytrain=[];

for i=tiles(1:4)
    file=strcat(directorio,num2str(i));
    [Xband,yband]=band_extractor(file,'train');
    Xtrain=[Xtrain;Xband]; ytrain=[ytrain;yband];
end

nan=isnan(Xtrain);
nan=sum(nan,2);
nan=find(nan==0);
Xtrain=Xtrain(nan,:);
ytrain=ytrain(nan);
%% Calcule variables de la distància de Bhattacharyya
%Càlcul de la mitjana de les distribucions, DNB no la contemple perque no
%és gaussiana i sabem que és útil
for k=1:4
    for i=1:8;
        gaus=fitdist(Xtrain(ytrain==k,i),'normal');
        Mu(i,k)=gaus.mu;
    end
end
clear gaus;
%Càlcul de les matrius de covariancia
% Xtrain=double(Xtrain(2:(length(Xtrain(:,1))-1),:));
% ytrain=ytrain(2:(length(ytrain(:,1))-1))';
Cova=zeros(8,8,4);
for k=1:4
    a=Xtrain(ytrain==k,1:8);
    Cova(:,:,k)=cov(a);
end
clear a;

%% Bucle de càlcul  de Bhattacharyya
DB=zeros(4,4);
for i=1:4
    for j=1:4
        sig=(Cova(:,:,i)+Cova(:,:,j))/2;
        if i==j
            DB(i,j)=NaN;
        else
            DB(i,j)=(1/8)*(Mu(:,i)-Mu(:,j))'*inv(sig)*(Mu(:,i)-Mu(:,j))+(1/2)*log(det(sig)/sqrt(det(Cova(:,:,i))*det(Cova(:,:,j))));
        end
    end
end
%Transformación a Jeffries
DF=2*(1-exp(-DB));
end

                    %% Carga de bandas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        %im(k).tif = single(imread(fullFileName));
        im(k).name = fitxers(k).name;
        end
    %     imshow(im(k).tif);  
    %     drawnow; 
    end

    [mask,ident]=mask_nubes_2(path_to_tile,0,0,0,0,0);
    mask=(mask(:,:,2)+mask(:,:,7))==0;
    % bandes específiques per a resaltar el sol construit
    
    NDBI=double((im(87).tif-im(86).tif)./(im(87).tif+im(86).tif));
    MNDWI=double((im(84).tif-im(86).tif)./(im(84).tif+im(86).tif));
    NDVI=double((im(86).tif-im(85).tif)./(im(86).tif+im(85).tif));
    NDMIR=double((im(87).tif-im(88).tif)./(im(87).tif+im(88).tif));
    NDRB=double((im(85).tif-im(83).tif)./(im(85).tif+im(83).tif));
    NDGB=double((im(84).tif-im(83).tif)./(im(84).tif+im(83).tif));
    % mediana de les imatges per a obtindre major precisió
    dnb=median(cat(3,im(1).tif,im(2).tif,im(3).tif,im(4).tif,im(5).tif,im(6).tif,im(7).tif,im(8).tif,im(9).tif),3);
    VV=median(cat(3,im(92).tif,im(94).tif,im(96).tif,im(98).tif),3);
    %lbands=cat(3,im(87).tif,im(86).tif,im(84).tif,im(85).tif,im(83).tif,im(88).tif);
    lbands=cat(3,NDBI,MNDWI,NDVI,NDMIR,NDRB,NDGB);

    bands=zeros([800 800 8]); 
    bands(:,:,1)=dnb; bands(:,:,3:8)=lbands; 
    bands(:,:,2)=VV; %bands=medfilt2(bands,[3 3]);
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