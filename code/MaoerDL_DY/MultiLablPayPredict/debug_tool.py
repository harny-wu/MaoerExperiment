import config


def less_sample(train_data_hash, data_hash):
    # 样本数大于5的user
    train_list = []
    more5 = 1
    for key in train_data_hash.keys():
        if train_data_hash[key].shape[0] >= 5:
            # print(f"{more5}: {ke>} data_hash size : {train_data_hash[key].shape}")
            more5 += 1
            train_list.append(int(key))
            if more5 > config.debug_sample_size:
                break

    val_list = []
    more5 = 1
    for key in data_hash.keys():
        if data_hash[key].shape[0] >= 5:
            # print(f"{more5}: {key} data_hash size : {train_data_hash[key].shape}")
            more5 += 1
            val_list.append(int(key))
            if more5 > config.debug_sample_size:
                break

    test_list = []
    more5 = 1
    for key in data_hash.keys():
        if data_hash[key].shape[0] >= 5:
            # print(f"{more5}: {key} data_hash size : {train_data_hash[key].shape}")
            more5 += 1
            test_list.append(int(key))
            if more5 > config.debug_sample_size:
                break

    return train_list, val_list, test_list
