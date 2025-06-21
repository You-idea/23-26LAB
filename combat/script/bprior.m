function y = bprior(gamma_hat)
	m = mean(gamma_hat);
  	s2 = var(gamma_hat);
  	y=(m*s2+m^3)/s2;
end

%{
Gamma 分布通常由两个参数定义：形状参数 a 和尺度参数 b。
在贝叶斯统计中，我们可能需要设置这些参数的先验分布。这个函数计算的是尺度参数 b 的先验值。
总的来说，bprior 函数为 Gamma 分布的尺度参数 b 提供了一个基于 gamma_hat 数据均值和方差的计算公式。
这种做法常见于为贝叶斯模型设置先验分布的过程中。
%}