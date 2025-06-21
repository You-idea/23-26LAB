%indices = batches{j};
%sdat = s_data(:,indices);
%ghat = gamma_hat(j,:);
%dhat = delta_hat(j,:);
% g.star is first row
% d.star is second row
function adjust = inteprior(sdat, ghat, dhat)
    gstar = [];
    dstar = [];
    r = size(sdat,1);
    for i = 1:r
        g = ghat;
        d = dhat;
        g(i)=[];
        d(i)=[];
        x = sdat(i,:);
        n = size(x,2);
        j = repmat(1,1,size(x,2));
        dat = repmat(x,size(g,2),1);
        resid2 = (dat-repmat(g',1,size(dat,2))).^2;
        sum2 = resid2 * j';
        LH = 1./(2*pi*d).^(n/2).*exp(-sum2'./(2.*d));
        gstar = [gstar sum(g.*LH)./sum(LH)];
        dstar = [dstar sum(d.*LH)./sum(LH)];
    end
    adjust = [gstar; dstar];
end

%{
这段代码定义了一个名为 inteprior 的函数，旨在根据输入的数据和参数计算调整值 gstar 和 dstar。具体步骤如下：
输入参数：函数接收三个参数：sdat（数据）、ghat（初始 gamma 参数）、dhat（初始 delta 参数）。
初始化：创建空数组 gstar 和 dstar 用于存储计算结果。
循环处理：对 sdat 的每一行进行迭代：
移除当前行的 ghat 和 dhat 中的对应元素。
将当前行数据 x 复制以便进行计算。
计算残差平方 resid2，并求和得到 sum2。
计算似然函数 LH，根据高斯分布公式。
使用加权平均公式计算新的 gstar 和 dstar。
输出结果：最终，函数返回一个包含 gstar 和 dstar 的矩阵。
整体上，这个函数用于根据给定的数据和参数动态调整 gamma 和 delta 值。
%}