import json

import pandas as pd

from common import base_path, no_need_col, D, detect_file_encoding, data_name

if __name__ == '__main__':
    data = base_path + "0101_0131_all_feature_FS_divideType.csv"
    df = pd.read_csv(data, encoding=detect_file_encoding(data))
    idx_to_col = {}
    col_to_idx = {}
    idx = 0
    for col in df.columns:
        if col in no_need_col:
            df.drop(col, axis=1, inplace=True)
            continue
        if col in D:
            continue
        idx_to_col[idx] = col
        col_to_idx[col] = idx
        idx += 1

    json_str = json.dumps(idx_to_col, indent=4)
    with open('idx_to_col.json', 'w') as json_file:
        json_file.write(json_str)

    json_str = json.dumps(col_to_idx, indent=4)
    with open('col_to_idx.json', 'w') as json_file:
        json_file.write(json_str)
