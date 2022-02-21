function [mask,ident]=mask_nubes_2(path_to_tile,n_tile,output,varargin)
%Alguns programes usen esta versió del mascarat de núvols

%Versión 1. Añade selector de outputs, todas las máscaras de satélite o
%solamente las menos nubosas 
%Mascara de nubes: devuelve imagen de 1 y 0 con las zonas nubosas,
%sombreadas y de agua. Primero las de sentinel y depués las de sentinel
%   [mask,ident]=mask_median(path_to_tile,n_tile,plot,histograma1,histograma2)
%
%   mask=máscara binaria de nubes, ident-índeices de orden de las imágenes
%   con menos nubes en orden numérico ocnforme se listan en la carpeta
%
%   path_to_tile: camino hasta el fichero con las imágenes
%   n_tile: 
%   output: default (0) devuelve las máscaras de todos los días, 'menor'
%   devuelve la máscara con menor nubosidad de landsat y sentinel. Si 0,
%   ident es un vector nulo
%   plot: 1 si quieres ver las máscaras, 0 si no.
%   histogram1: 1 para ver los histogramas de las bandas de detección de
%   nubes, si no 0;
%   histogram2: 1 para ver los histogramas de sombra en landsat, si no 0.
%
%Notas: para landsat es preferible no utilizar las imágenes de índice 2, ya
%que presentan niebla, mucho más dificil de enmascarar.


patro1 = fullfile(path_to_tile, '*.tif');
fitxers = dir(patro1);
im = struct('tif', cell(1, 99), 'name', cell(1,99));

for k = 1:length(fitxers)
    baseFileName = fitxers(k).name;
    fullFileName = fullfile(fitxers(k).folder, baseFileName);
    %fprintf(1, 'Carregant %s\n', fullFileName);
    
    im(k).tif = medfilt2(single(imread(fullFileName)),[3 3]);
    im(k).name = fitxers(k).name;
%     imshow(im(k).tif);  
%     drawnow; 
end

varargin=cell2mat(varargin);
%% 1380 band sentinel
% 
% for i=1:1
%     no_cloud1=im(24+(i-1)*10).tif;
%     no_cloud1=reshape(no_cloud1,[800*800,1]);
%     for j=1:12
%         cloud=reshape(im(9+j).tif,[800*800,1]);
%         figure, plot(no_cloud1,cloud,'k.')
%         title(strcat("pol 1 y banda",num2str(j))); ylabel('S2'), xlabel('S1') 
%     end
%     
% end


%% 1380 band landsat mascara para landsat

%seleccionamos bandas en el SWIR para seleccionar nubes
w_band1=im(58).tif; w_band2=im(79).tif; w_band3=im(90).tif;
%juntamos información de bandas del visible y NIR para las sombras
shadow1=sqrt(im(61).tif.^2+im(62).tif.^2+im(63).tif.^2+im(65).tif.^2);
shadow2=sqrt(im(72).tif.^2+im(73).tif.^2+im(74).tif.^2+im(75).tif.^2);
shadow3=sqrt(im(83).tif.^2+im(84).tif.^2+im(85).tif.^2+im(86).tif.^2);

%establecemos umbrales y obtenemos las máscaras
mask_L81=medfilt2(uint8((w_band1>10800) + (shadow1<17000)  ),[5 5]);% ()
mask_L82=medfilt2(uint8((w_band2>5200 ) + (shadow2<18000)),[5 5]); %)
mask_L83=medfilt2(uint8((w_band3>5200) + (shadow3<17000)),[5 5]);%

if varargin(1)==1
    figure, title(num2str(n_tile));
    subplot(1,3,1), imshow(mask_L81,[0 1]), subplot(1,3,2), 
    imshow(mask_L82,[0 1]), subplot(1,3,3), imshow(mask_L83,[0 1]);
end

if varargin(2)==1
    figure
    subplot(1,3,1), histogram(w_band1), subplot(1,3,2), histogram(w_band2), subplot(1,3,3), histogram(w_band3);
end

if varargin(3)==1
    figure
    subplot(1,3,1), histogram(shadow1), subplot(1,3,2), histogram(shadow2), subplot(1,3,3), histogram(shadow3);
end




%% band seninel

% banda en SWIR para detectar nubes (humedad) zona de agua y sombras
w_band1=im(19).tif*0.0001; w_band2=im(31).tif*0.0001; w_band3=im(43).tif*0.0001; w_band4=im(55).tif*0.0001;

if varargin(2)==1
    figure
    subplot(2,2,1), histogram(w_band1,(0:0.05:1)), subplot(2,2,2), histogram(w_band2,(0:0.05:1)), 
    subplot(2,2,3), histogram(w_band3,(0:0.01:1)), subplot(2,2,4), histogram(w_band4,(0:0.01:1));
end

% seleccionamos umbrales
mask_S1=medfilt2(uint8((w_band1>0.41) + (w_band1<0.14)),[5 5]); mask_S2=medfilt2(uint8((w_band2>0.41) + (w_band2<0.14)),[5 5]);
mask_S4=medfilt2(uint8((w_band4>0.41) + (w_band4<0.14)),[5 5]); mask_S3=medfilt2(uint8((w_band3>0.41) + (w_band3<0.14)),[5 5]);

% banda en el visible combinación sensible a iluminación nocturna
w_band1=(im(11).tif+im(12).tif+im(13).tif)*0.0001; b=w_band1>0.4; confuse1=find(and(mask_S1==1,b==1));
w_band2=(im(24).tif+im(25).tif+im(26).tif)*0.0001; b=w_band1>0.4; confuse2=find(and(mask_S2==1,b==1));
w_band3=(im(36).tif+im(37).tif+im(38).tif)*0.0001; b=w_band1>0.4; confuse3=find(and(mask_S3==1,b==1));
w_band4=(im(48).tif+im(49).tif+im(50).tif)*0.0001; b=w_band1>0.4; confuse4=find(and(mask_S4==1,b==1));

% eliminamos de máscara de nubes aquellos píxeles que sean iluminación
% nocturna
mask_S1(confuse1)=0; mask_S2(confuse2)=0; mask_S3(confuse3)=0; mask_S4(confuse4)=0;

% filtrado de mediana
mask_S1=medfilt2(mask_S1,[5 5]); mask_S2=medfilt2(mask_S2,[5 5]);
mask_S4=medfilt2(mask_S4,[5 5]); mask_S3=medfilt2(mask_S3,[5 5]);

if varargin(1)==1
    figure
    subplot(2,2,1), imshow(mask_S1,[0 1]), subplot(2,2,2), imshow(mask_S2,[0 1]), 
    subplot(2,2,3), imshow(mask_S3,[0 1]), subplot(2,2,4), imshow(mask_S4,[0 1]);
end


mask=cat(3,mask_S1,mask_S2,mask_S3,mask_S4,mask_L81,mask_L82,mask_L83);
ident=[];

if output=='menor'
    select=[sum(sum(mask_L81)) sum(sum(mask_L82)) sum(sum(mask_L83))];
    [im,i]=min(select);
    select=[sum(sum(mask_S1)) sum(sum(mask_S2)) sum(sum(mask_S3)) sum(sum(mask_S4))];
    [im,j]=min(select);
    
    mask=cat(3,mask(:,:,j),mask(:,:,i+4));
    ident=[j,i];
end
%% experimentación con clasificadores
% for i=[10 22 34 46]
%     xtest=cat(3,im(i).tif,im(i+6).tif,im(i+2).tif,im(i+3).tif,im(i+4).tif,im(i+10).tif);
%     switch i
%         case 10
%             shadow1=reshape(shadow1,[800*800,1]);
%             c_indx=find(shadow1>2.600);
%             s_indx=find(shadow1<1.000);
%             u_indx=find(1.700<shadow1 & shadow1<2.300);
%             shadow1=reshape(shadow1,[800,800,1]);
%         case 22
%             shadow2=reshape(shadow2,[800*800,1]);
%             c_indx=find(shadow2>2.600);
%             s_indx=find(shadow2<1.000);
%             u_indx=find(1.700<shadow2 & shadow2<2.300);
%             shadow2=reshape(shadow2,[800,800,1]);
%         case 34
%             shadow3=reshape(shadow3,[800*800,1]);
%             c_indx=find(shadow3>2.600);
%             s_indx=find(shadow3<1.000);
%             u_indx=find(1.700<shadow3 & shadow3<2.300);
%             shadow3=reshape(shadow3,[800,800,1]);
%         case 46
%             shadow4=reshape(shadow4,[800*800,1]);
%             c_indx=find(shadow4>2.600);
%             s_indx=find(shadow4<1.000);
%             u_indx=find(1.700<shadow4 & shadow4<2.300);
%             shadow4=reshape(shadow4,[800,800,1]);
%     end
% 
%     ytrain=zeros([800 800]);
%     xtest=single(reshape(xtest,[800*800,6])); ytrain=reshape(ytrain,[800*800,1]);
%     
%     indx=cat(1,c_indx, s_indx, u_indx);
%     ytrain(c_indx)=3; ytrain(s_indx)=1; ytrain(u_indx)=2;
%     
%     xtrain=xtest(indx,:); ytrain=single(ytrain(indx));
%     
%     forest=fitcdiscr(xtrain',ytrain);
%     
%     mask_class=str2double(predict(forest,xtest'));
%     forest=fitcknn(xtrain,ytrain);
%     
%     mask_class=str2double(predict(forest,xtest));
%     
%     mask_class=reshape(mask_class,[800,800,1]);
%     mask_class(find(mask_class~=2))=1; mask_class(find(mask_class==2))=0;
%     
%     figure, imshow(mask_class,[0 1]);
% end

%% articulo TC4 y swir2 en landsat
% TC4=-0.8239*im(80).tif+0.0849*im(83).tif+0.4396*im(84).tif-0.058*im(85).tif+0.2013*im(81).tif-0.2773*im(82).tif;
% swir2=im(82).tif;
% 
% xtrain=cat(3,TC4,swir2); xtrain=reshape(xtrain,[800*800,2]);
% ytrain=reshape(mask_prueba3,[800*800,1]); indx=floor(rand(1000,1)*800*800);
% xtrain=xtrain(indx,:); ytrain=ytrain(indx);
% 
% model=fitcsvm(xtrain,ytrain);

% figure, title(num2str(n_tile));
% j=0;
% for i=[58 69 80]
%     TC4=-0.8239*im(i).tif+0.0849*im(i+3).tif+0.4396*im(i+4).tif-0.058*im(i+5).tif+0.2013*im(i+1).tif-0.2773*im(i+2).tif;
%     swir2=im(i+2).tif;
%     xtest=cat(3,TC4,swir2); xtest=reshape(xtest,[800*800,2]);
%     
%     mask=predict(model,xtest);
% 
%     mask=medfilt2(reshape(mask,[800 800]),[3 3]);
% 
%     j=j+1;
%     subplot(1,3,j);
%     imshow(mask,[0 1])
% end



