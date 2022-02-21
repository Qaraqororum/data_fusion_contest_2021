function imout=reescale_totruth(imin,mask)
%Entrada imin: imatge a reescalar
%        imout: imatge reescalada
    [I,J,z]=size(imin);
    dim=[16 16];
    
    gap=[50 50];
    
    imout=cell(256,1); count=1;
    for i=1:16
        for j=1:16
            %crea quadrats de 800/16 píxels d'on es tria el valor de
            %mediana, si es para imagen de clasificación mejor hace la moda
            mold=imin(gap(1)*(i-1)+1:gap(1)*i,gap(2)*(j-1)+1:gap(2)*j,:);
            mask_mold=mask(gap(1)*(i-1)+1:gap(1)*i,gap(2)*(j-1)+1:gap(2)*j);
            mold=reshape(mold,[50*50,z]); mask_mold=reshape(mask_mold,[50*50,1]);
            mold=mold(find(mask_mold==1),:);
            imout(count,1)={mold};
            count=count+1;
        end
    end
end