###用lavaan工具包做链式中介。需要将数据准备好，不要被试序号，每一列的列名需要和代码中的对应。
###需要将所有的数据整理到一个excel表中。自变量和因变量在前，协变量和中介变量在后。
###本叫循环取脑区的数据，在多个脑区中随机取两个做M1和M2，先做一半，后将M1和M2的顺序倒置再做一遍。
###每个链式中介保存一个结果，最后所有的链式中介又保存一个大文件，可以直接导入excel进行数据筛选。

if (!require(lavaan)) {  
  install.packages("lavaan")  
  library(lavaan)  
}   
if (!require(readxl)) {  
  install.packages("readxl")  
  library(readxl)  
} 

rawdata <- read_excel("/cme-network-GPT.xlsx")
rawdata_col <- ncol(rawdata)

X_name <- "GPT"
X <- rawdata[[X_name]]

Y_name <- "SAS"
Y <- rawdata[[Y_name]]

age <- rawdata[, 3] 
Fedu <- rawdata[, 4]
Medu <- rawdata[, 5]
FD <- rawdata[, 6]
M <- as.data.frame(rawdata[, 7:rawdata_col])
M_col <- ncol(M)

comb_1 <- t(combn(M_col, 2))
comb_2 <- t(apply(comb_1, 1, rev))
all_comb <- rbind(comb_1, comb_2)
data <- data.frame(X = X, Y = Y, age = age, Fedu = Fedu, Medu = Medu, FD = FD)

output_folder <- "/R-result/GPT/"
if (!dir.exists(output_folder)) {  
  dir.create(output_folder, recursive = TRUE)  
}  

result_file <- paste0(output_folder, "reho-GPT-network-result.txt")
file_conn_1 <- file(result_file, "w")
cat("X ","Y ","M_1 ","M_2 ", file = file_conn_1)
cat("+ ","+ ","+ ","+ ","a1 ","+ ","Estimate  Std.Err  z-value  P(>|z|) ci.lower ci.upper ", file = file_conn_1)
cat("+ ","+ ","+ ","+ ","a2 ","+ ","Estimate  Std.Err  z-value  P(>|z|) ci.lower ci.upper ", file = file_conn_1)
cat("+ ","+ ","+ ","+ ","d21 ","+ ","Estimate  Std.Err  z-value  P(>|z|) ci.lower ci.upper ", file = file_conn_1)
cat("+ ","+ ","+ ","+ ","c1 ","+ ","Estimate  Std.Err  z-value  P(>|z|) ci.lower ci.upper ", file = file_conn_1)
cat("+ ","+ ","+ ","+ ","b1 ","+ ","Estimate  Std.Err  z-value  P(>|z|) ci.lower ci.upper ", file = file_conn_1)
cat("+ ","+ ","+ ","+ ","b2 ","+ ","Estimate  Std.Err  z-value  P(>|z|) ci.lower ci.upper ", file = file_conn_1)
cat("+ ","+ ","+ ","+ ","indirect1 ","+ ","Estimate  Std.Err  z-value  P(>|z|) ci.lower ci.upper ", file = file_conn_1)
cat("+ ","+ ","+ ","+ ","indirect2 ","+ ","Estimate  Std.Err  z-value  P(>|z|) ci.lower ci.upper ", file = file_conn_1)
cat("+ ","+ ","+ ","+ ","ie ","+ ","Estimate  Std.Err  z-value  P(>|z|) ci.lower ci.upper ", file = file_conn_1)
cat("+ ","+ ","+ ","+ ","total ","+ ","Estimate  Std.Err  z-value  P(>|z|) ci.lower ci.upper","\n", file = file_conn_1)

for (i in seq_len(nrow(all_comb))) {
M_1_index <- all_comb[i, 1]
M_2_index <- all_comb[i, 2]

M_1_name <- colnames(M)[M_1_index]
M_2_name <- colnames(M)[M_2_index]
  
output_file <- paste0(output_folder, M_1_name, "_and_", M_2_name, ".txt")
file_conn_2 <- file(output_file, "w")

cat("X column name:", X_name, "\n", file = file_conn_2)
cat("Y column name:", Y_name, "\n", file = file_conn_2) 
cat("M_1 column name:", M_1_name, "\n", file = file_conn_2)
cat("M_2 column name:", M_2_name, "\n", file = file_conn_2)
  
print("========================================================")
print(paste("M_1:", M_1_name))
print(paste("M_2:", M_2_name))
print(paste("当前行索引:", i, "，总行数:", nrow(all_comb)))  

M_1 <-M[, M_1_index]
M_2 <-M[, M_2_index]
  
data$M_1 <- as.numeric(M_1)
data$M_2 <- as.numeric(M_2)

cat("模型开始","\n")

model <- ' M_1 ~ a1*X +cov1_m1*age+cov2_m1*Fedu+cov3_m1*Medu+cov4_m1*FD
                  M_2 ~ a2*X + d21*M_1 +cov1_m2*age+cov2_m2*Fedu+cov3_m2*Medu+cov4_m2*FD
                  Y ~ c1*X + b1*M_1 + b2*M_2 +cov1_sas*age+cov2_sas*Fedu+cov3_sas*Medu+cov4_sas*FD
                  indirect1 := a1*b1                 
                  indirect2 := a2*b2
                  ie := a1*d21*b2
                  total := c1 + (a1*d21*b2) + (a1*b1) + (a2*b2)
                 '
cat("校正开始","\n")

fit <- sem(model, data = data,se= "bootstrap", bootstrap= 1000)

parameters <- parameterEstimates(fit)

string = parameters[,1:4]
parameters_string <- capture.output(print(string))

num_1 <- data.frame(lapply(parameters, function(x) as.numeric(as.character(x))))
num = num_1[,5:10]
num$G <- ""  
parameters_num <- capture.output(print(num))

combined_data <- cbind(parameters_string, parameters_num)
  
write.table(combined_data, file = file_conn_2, sep = " ", row.names = FALSE)
close(file_conn_2)

cat(X_name,Y_name,M_1_name,M_2_name," ", file = file_conn_1)
cat(parameters_string[2]," ",file = file_conn_1)
cat(parameters_num[2],file = file_conn_1)
cat(parameters_string[7]," ",file = file_conn_1)
cat(parameters_num[7],file = file_conn_1)
cat(parameters_string[8]," ",file = file_conn_1)
cat( parameters_num[8],file = file_conn_1)
cat(parameters_string[13]," ",file = file_conn_1)
cat(parameters_num[13],file = file_conn_1)
cat(parameters_string[14]," ",file = file_conn_1)
cat(parameters_num[14],file = file_conn_1)
cat(parameters_string[15]," ",file = file_conn_1)
cat(parameters_num[15],file = file_conn_1)
cat(parameters_string[38]," ",file = file_conn_1)
cat(parameters_num[38],file = file_conn_1)
cat(parameters_string[39]," ",file = file_conn_1)
cat(parameters_num[39],file = file_conn_1)
cat(parameters_string[40]," ",file = file_conn_1)
cat(parameters_num[40],file = file_conn_1)
cat(parameters_string[41]," ",file = file_conn_1)
cat(parameters_num[41],"\n",file = file_conn_1)
  
cat("结果已成功写入到文件:", output_file, "\n")
}

close(file_conn_1)
