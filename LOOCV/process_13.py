#_12的分程序的基础上改进
# 啥也没有改那~

import numpy as np
import pandas as pd
from scipy.stats import pearsonr, spearmanr

def process_column(behadata_tota, beha_r, beha_p, sub_all_braindata, P_LIMIT, subnum):
    try:
        result_subs_index = np.zeros((subnum, 2))
        FC_index = pd.Series()
        # FC_index = pd.Series(dtype='object')
        for X in range(subnum):
        # for X in range(2):
            braindata_sele_tmp = sub_all_braindata

            for Y in np.setdiff1d(np.arange(subnum), X):
                index_remove = np.array([X, Y])
                sub_index_tmp = np.delete(np.arange(subnum), index_remove)

                braindata_sele = braindata_sele_tmp.values[sub_index_tmp, :]
                behadata_sele = behadata_tota.values.reshape(-1, 1)[sub_index_tmp, :]

                p_1 = np.apply_along_axis(lambda b: pearsonr(behadata_sele.flatten(), b)[1], 0, braindata_sele)
                index = np.where(p_1 < P_LIMIT)[0]
                braindata_sele_tmp = braindata_sele_tmp.iloc[:, index]
            FC_index_X = pd.Series(braindata_sele_tmp.columns.tolist())
            FC_index = pd.concat([FC_index, FC_index_X], axis=1)

            test_row = braindata_sele_tmp.iloc[X, :]
            rest_rows = braindata_sele_tmp.drop(index=X)
            r_2 = np.apply_along_axis(lambda b: pearsonr(test_row.values, b)[0], 0, rest_rows.values.T)
            r_2 = np.insert(r_2, X, 0, axis=0)
            max_index = np.argmax(r_2)
            result_subs_index[X] = [X, max_index]

            print(f'当前被试A：{X + 1}/{subnum}')

        FC_index = FC_index.iloc[:, 1:].values + 1
        indices_row = result_subs_index[:, 0].astype(int)
        indices_col = result_subs_index[:, 1].astype(int)
        r_3 = beha_r.values[indices_row, indices_col][:, np.newaxis]
        p_3 = beha_p.values[indices_row, indices_col][:, np.newaxis]
        result_subs_r_p = np.hstack((result_subs_index + 1, r_3, p_3))
        # 我在编写代码的过程中发现没有写入r和p的时候，r自动填充的1 p填充的3.50898235855500e-101
        # 且我还没有找到提前设置他们都是0的方法
        return result_subs_r_p, FC_index
    except Exception as e:
        print(f"Error processing column: {e}")
        raise