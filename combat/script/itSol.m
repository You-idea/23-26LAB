function adjust = itSol(sdat,g_hat,d_hat,g_bar,t2,a,b, conv)
  g_old = g_hat;
  d_old = d_hat;
  change = 1;
  count = 0;
  n = size(sdat,2);
  while change>conv 
    g_new = postmean(g_hat,g_bar,n,d_old,t2);
    sum2  = sum(((sdat-g_new'*repmat(1,1,size(sdat,2))).^2)');
    d_new = postvar(sum2,n,a,b);

    change = max(max(abs(g_new-g_old)./g_old), max(abs(d_new-d_old)./d_old));
    g_old = g_new;
    d_old = d_new;
    count = count+1;
  end
  adjust = [g_new; d_new];
end


%{
这个函数 itSol 用于迭代地调整参数 g_hat 和 d_hat，直到它们的变化小于指定的收敛阈值 conv。
它首先用当前的 g_hat 计算新的后验均值 g_new，然后根据 g_new 计算误差平方和，
进而得到新的后验方差 d_new。在每次迭代中，函数会检查这些参数的相对变化，并更新旧值。
最终，返回的是调整后的 g_new 和 d_new。

收敛阈值（在这里是0.001）是一个用于控制迭代过程的参数，表示算法停止迭代的条件。
在你的函数中，它定义了在每次迭代中，
更新的参数（如回归系数 g_new 和方差 d_new）与前一次迭代的参数（g_old 和 d_old）之间的变化量。
%}