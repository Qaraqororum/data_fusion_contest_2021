function [GrTr800_o,L2Apc,LC08pc,S1Apc,DNBpc]=iterador_pc(path,funcions,tile_n)
path=cat(2,path,num2str(tile_n));
addpath(path)
%Path de les rutines.
addpath(funcions);
%% lectura cosas
col=800;line=800;
c=0;    %c=1 plots c=0 no plots

%% Mascarado nubes y preselección L8, Sen1
output='menor';
[mask,ident]=mask_nubes_2(path,tile_n,output,0,0,0);
mask_Sen=mask(:,:,1);
mask_LC=mask(:,:,2);
mask_LC=reshape(mask_LC,[col*line,1]);
mask_Sen=reshape(mask_Sen,[col*line],1);
In_Sen=ident(1);
In_LC=ident(2);
mask=(mask_LC+mask_Sen)==0;
%% Lectura dels satèlits per separat i filtrat espacial de mediana

% Bucle lectura para DNB tile 1
File_DNB=fullfile(path, 'DNB_*');
DNB=dir(File_DNB);
DNBs=zeros(800,800,9);
for i=1:9
    DNBs(:,:,i) = medfilt2(imread(DNB(i).name),[3 3]);
end
DNBs=reshape(DNBs,[col*line,9]);
% Bucle lectura L2A
File_L2A=fullfile(path, 'L2A_*');
L2A=dir(File_L2A);
L2As=zeros(800,800,48);
for i=1:48
    L2As(:,:,i) = medfilt2(imread(L2A(i).name),[3 3]);
end

%Escogim el dia que ens indique la funció de mascarat de núvols
if In_Sen==1
    L2Ano_nuv=L2As(:,:,1:12);
elseif In_Sen==2
    L2Ano_nuv=L2As(:,:,13:24);
elseif In_Sen==3
    L2Ano_nuv=L2As(:,:,25:36);
elseif In_Sen==4
    L2Ano_nuv=L2As(:,:,37:48);
end

L2Ano_nuv=reshape(L2Ano_nuv,[col*line,12]);
% Bucle lectura  LC08
File_LC08=fullfile(path, 'LC08_*');
LC08=dir(File_LC08);
LC08s=zeros(800,800,33);
for i=1:33
    LC08s(:,:,i)=medfilt2(imread(LC08(i).name),[3 3]);
end

%Escogim el dia que ens indique la funció de mascarat de núvols
if In_LC==1
    LC08no_nuv=LC08s(:,:,1:11);
elseif In_LC==2
    LC08no_nuv=LC08s(:,:,12:22);
elseif In_LC==3
    LC08no_nuv=LC08s(:,:,23:33);
end

LC08no_nuv=reshape(LC08no_nuv,[col*line,11]);
% Bucle lectura  S1A
File_S1A=fullfile(path, 'S1A_*');
S1A=dir(File_S1A);
S1As=zeros(800,800,8);
for i=1:8
    S1As(:,:,i)=medfilt2(imread(S1A(i).name),[3 3]);
end
S1As=reshape(S1As,[col*line,8]);
% Lectura i reescalat de ground truth
File_GrTr=fullfile(path, 'ground*');
GrTr=dir(File_GrTr);
GrTrim=imread(GrTr(1).name);
GrTr800=reescale_truth(GrTrim);
GrTr800=reshape(GrTr800,[col*line,1]);
%% Mascarat de núvols
GrTr800_o=GrTr800(find(mask==1));
S1As_o=S1As(find(mask==1),:);
LC08no_nuv_o=LC08no_nuv(find(mask==1),:);
L2Ano_nuv_o=L2Ano_nuv(find(mask==1),:);
DNBs_o=DNBs(find(mask==1),:);
%% Obtenció de les CPs de cada satèlit
%DNB
n=1;
[DNBco,DNBpc,DNBeig] = pca(DNBs_o, 'NumComponents',n);
% L2A
n=3
[L2Aco,L2Apc,L2Aeig] = pca(L2Ano_nuv_o, 'NumComponents',n);
% LC08
n=3
[LC08co,LC08pc,LC08eig] = pca(LC08no_nuv_o, 'NumComponents',n);
%S1A (separe en VV y VH y faig pc als 4 dies
n=1;
[co,pc,eig] = pca(S1As_o(:,2:2:8), 'NumComponents',n);
S1Apc=pc;
[co,pc,eig] = pca(S1As_o(:,1:2:7), 'NumComponents',n);
S1Apc=cat(2,S1Apc,pc);
end


