%% Permutation
clc;
clear;

beha=xlsread('beha.xlsx');
brain=xlsread('brain.xlsx');
permutation_number=5000;
Bon_number=200;
r_value=[];
p_value=[];
p0_value=[];
for i=1:size(beha,2)
    for j=1:size(brain,2)
        x1=beha(1:length(beha),i);
        x2=brain(2:length(brain),j);
        [r,p0]=corr(x1,x2,"type","Pearson");
        p0=p0*Bon_number;
        if p0>0.05 || r<=0 
            continue;
        elseif p0<=0.05 && r>0
            r_per=[];
            for pp=1:permutation_number
                seq=randperm(length(x1));
                y=x1(seq,:);
                r_temp=corr(y,x2,"type","Spearman");
                r_per=[r_per,r_temp];
            end
            if r>0
                p=(length(find(r_per>r))+1)/(length(r_per)+1);
            elseif r<0
                p=(length(find(r_per<r))+1)/(length(r_per)+1);
            end

            if p<=0.05/Bon_number
                r_value(j,i+1)=r;
                r_value(j,1)=brain(1,j);
                p_value(j,i)=p*Bon_number;
                p0_value(j,i)=p0;
            elseif p>0.05/Bon_number
                continue;
            end
        end
    end
end
r_p0_p=[r_value,p0_value,p_value];

                    