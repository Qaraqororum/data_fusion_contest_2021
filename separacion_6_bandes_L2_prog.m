clear, clc, close all
rand('seed',1234)
directorio="E:\master\AEI\Trabajo AEI\02-GRSS_competition_Detection_Settlements\concurs\Train\Tile";
%% Llamamos a la funcion con varias bandas
%Agafa el dia menys nuvolat de Sentinel2A i  calcula totes les possibles
%combinacions de bandes en L2P
L2=22:1:33;
L2p=combntns(L2,6);
DFL2=zeros(4,4,length(L2p(:,1)));
%Crida a la funció i emmagatzamament dels resultats en un vector de matriu
for i=1:length(L2p(:,1))
    DFL2(:,:,i)=Jefries(directorio,L2p(i,:));
    i
end
%% Anàlisis de resultados
%Mejor separación clases L2P 
L2Clases=zeros(2,4);
%S'emmagatzema la millor distancia de cada classe
for i=2:4
    ind=max(DFL2(1,i,:));
    L2Clases(1,i)=i;
    L2Clases(2,i)=ind;
end
%S'emmagatzema la millor distancia mitja i el index per a cercar la
%combinació
for i=1:length(L2p(:,1))
    mediaL2(i)=mean(DFL2(1,2:4,i));
end
%%
save('Separacion_6B_Polarimetric');
                        %% Seleccion de clases %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DF=Jefries(directorio,Ba)
%% Selección de clases
%tiles=1:10;
tiles=ceil(randperm(30));
Xtrain=[]; ytrain=[];

for i=tiles(1:4)
    file=strcat(directorio,num2str(i));
    [Xband,yband]=band_extractor(file,'train',Ba);
     Xtrain=[Xtrain;Xband]; ytrain=[ytrain;yband];
end

%% Calcule variables de la distància de Bhattacharyya
%Càlcul de la mitjana de les distribucions, DNB no la contemple perque no
%és gaussiana i sabem que és útil
for k=1:4
    for i=1:9;
        gaus=fitdist(Xtrain(ytrain==k,i),'normal');
        Mu(i,k)=gaus.mu;
    end
end
clear gaus;
%Càlcul de les matrius de covariancia
Cova=zeros(9,9,4);
for k=1:4
    a=Xtrain(ytrain==k,1:9);
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
function [bands,gt]=band_extractor(path_to_tile,train_or_test,Ba)
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

    [mask,ident]=mask_nubes(path_to_tile,0,0,0,0,0);
    mask=(mask(:,:,2)+mask(:,:,7))==0;
    % bandes específiques per a resaltar el sol construit
    lbands=cat(3,im(Ba(1)).tif,im(Ba(2)).tif,im(Ba(3)).tif,im(Ba(4)).tif,im(Ba(5)).tif,im(Ba(6)).tif)*0.0001;
    %sbands=cat(3,im(Ba(4)).tif,im(Ba(5)).tif,im(Ba(6)).tif)*0.0001;
    S1AVV=median(cat(3,im(91).tif,im(93).tif,im(95).tif,im(97).tif),3);
    S1AVH=median(cat(3,im(92).tif,im(94).tif,im(96).tif,im(98).tif),3);
    S1A=cat(3,S1AVV,S1AVH);
    % mediana de les imatges per a obtindre major precisió
    dnb=median(cat(3,im(1).tif,im(2).tif,im(3).tif,im(4).tif,im(5).tif,im(6).tif,im(7).tif,im(8).tif,im(9).tif),3);
    
    bands=zeros([800 800 9]); 
    bands(:,:,1)=dnb; bands(:,:,2:7)=lbands; bands(:,:,8:9)=S1A;
   % bands(:,:,2:4)=sbands; %bands=medfilt2(bands,[3 3]);
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
        bands=reshape(bands,[800*800,9]); 
        bands=bands(find(mask==1),:);
        gt=reescale_truth(im(99).tif); 
        gt=reshape(gt,[800*800,1]);
        gt=gt(find(mask==1),:);
    end
end