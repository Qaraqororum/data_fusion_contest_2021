clear;clf;close all;clc;

funcions='E:\master\AEI\Trabajo AEI';
addpath('E:\master\AEI\Trabajo AEI\02-GRSS_competition_Detection_Settlements\concurs\Train\Tile1');
path='E:\master\AEI\Trabajo AEI\02-GRSS_competition_Detection_Settlements\concurs\Train\Tile';
rand('seed',1234)
%% Train
%Programa de càrrega de dades i creació de CPs amb "iterador_pc"

tile_n=randperm(30);

 for tile_n=1:5
     [GrTr,L2Apc,LC08pc,S1Apc,DNBpc]=iterador_pc(path,funcions,tile_n);
     if tile_n==1
         GrTr_train=GrTr;
         L2A_train=L2Apc;
         LC08_train=LC08pc;
         S1A_train=S1Apc;
         DNB_train=DNBpc;
     else
        GrTr_train=cat(1,GrTr_train,GrTr);
        L2A_train=cat(1,L2A_train,L2Apc);
        LC08_train=cat(1,LC08_train,LC08pc);
        S1A_train=cat(1,S1A_train,S1Apc);
        DNB_train=cat(1,DNB_train,DNBpc); 
     end   
     tile_n
 end

 ytrain=GrTr_train;
 Xtrain=cat(2,L2A_train,LC08_train,S1A_train,DNB_train);
 clear GrTr_train LC08_train S1A_train DNB_train GrTr L2Apc L2A_train LC08pc S1Apc DNBpc;

 %Crida a la funció d'obtenció de la distància de Jeffreis-Matussita
 DF_PC=zeros(4,4);
 DF_PC=Jefries(Xtrain,ytrain);

 save('DF_PC.mat','DF_PC');

                        %% Seleccion de clases %%
                            % Mod per a PC %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DF=Jefries(Xtrain,ytrain)
%% Selección de clases
%% Calcule variables de la distància de Bhattacharyya
%Càlcul de la mitjana de les distribucions, DNB no la contemple perque no
%és gaussiana i sabem que és útil
for k=1:4
    for i=1:4;
        gaus=fitdist(Xtrain(ytrain==k,i),'normal');
        Mu(i,k)=gaus.mu;
    end
end
clear gaus;
%Càlcul de les matrius de covariancia
Cova=zeros(4,4,4);
for k=1:4
    a=Xtrain(ytrain==k,1:4);
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