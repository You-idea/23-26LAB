function y = aprior(gamma_hat)
	m = mean(gamma_hat);
  	s2 = var(gamma_hat);
  	y=(2*s2+m^2)/s2;
end

%{
公式 y = (2*s2 + m^2) / s2 计算的是 Gamma 分布的形状参数 a。
在 Gamma 分布中，通常用形状参数和尺度参数来描述先验分布的特性
Gamma 分布通常由两个参数定义：形状参数 a 和尺度参数 b。
在这个上下文中，aprior 函数计算了 a 参数。Gamma 分布的先验参数的选择有助于捕捉数据的变化和集中趋势。
具体来说，a 的计算方法反映了通过 gamma_hat 的均值和方差来确定 a 参数的策略，
这可能是在进行贝叶斯建模时用于指定先验分布的过程。
%}