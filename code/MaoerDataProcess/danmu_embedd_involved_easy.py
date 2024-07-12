import copy
import csv
import sys

from pymongo import MongoClient, cursor
import pymysql
from datetime import datetime, timedelta
# from transformers import BertTokenizer, BertModel
import torch

import numpy as np
import pandas as pd
import os

# env:python=3.7 tensorflow=1.15
os.environ['TF_KERAS'] = '1'
from bert4keras.backend import keras
from bert4keras.tokenizers import Tokenizer
from bert4keras.models import build_transformer_model
from bert4keras.snippets import sequence_padding
from bert4keras.snippets import open
import tensorflow as tf
import pandas as pd15
from sklearn.model_selection import train_test_split
import json
from scipy.spatial.distance import cosine


def get_sentence_embedding_many(texts, tokenizer, model):
    ret = []
    i = 0
    while i < len(texts):
        token_ids_list = []
        segment_ids_list = []
        for text in texts[i:i + 150]:
            token_ids, segment_ids = tokenizer.encode(text, maxlen=256)
            token_ids_list.append(token_ids)
            segment_ids_list.append(segment_ids)
        generator = [sequence_padding(token_ids_list), sequence_padding(segment_ids_list)]
        result = model.predict(generator)
        ret.extend(result)
        i += 150
        # print('finish：', i / 150)
    if len(ret) != len(texts):
        print('error')

    return [item[0] for item in ret]


def float_to_list(num):
    num_str = str(num)
    ret = [[digit] for digit in num_str]
    return ret


# 计算前后15s的所有弹幕embedding
# data[sec]是一秒钟内所有弹幕
def cal_danmu(start, end, data):
    for sec in range(start, end):
        if len(data[sec]) > 0:
            print(f"当前时间：{sec}, 弹幕数量 :{len(data)}")
            # 计算弹幕的embedding
            danmu_embedding = get_sentence_embedding_many([item[4] for item in data[sec]], danmu_tokenizer, danmu_model)
            # append回去
            for i in range(len(data[sec])):
                print(f"        {data[sec]}")
                data[sec][i].append(danmu_embedding[i])


def get_danmu_second_list(sound_id):
    sql2 = "SELECT distinct di.danmu_id,di.sound_id,di.user_id,di.danmu_info_stime_notransform,di.danmu_info_date,di.danmu_info_text  FROM maoer.danmu_info as di where di.sound_id  = %s GROUP BY danmu_id"
    cursor2.execute(sql2, (sound_id))
    results = cursor2.fetchall()
    max_stime = 0
    for row in results:
        if row[3] > max_stime:
            max_stime = row[3]
    danmu_second_list = [[] for _ in range(int(max_stime) + 1)]
    for row in results:
        danmu_second_list[int(row[3])].append([row[0], row[1], row[2], row[4], row[5]])  # [time1,[danmu_info_1][danmu_info_1]]
    return danmu_second_list


# input
sound_start = input("请输入从第几个声音数开始：")
# 获取当前日期和时间
now = datetime.now()

# 连接到 MySQL 数据库
# conn = pymysql.connect(host='10.22.32.29',
#                      user='maoer',
#                      password='2rOiLE8Zj8R7exeyKEqIU4x9',
#                      database='maoer')
conn = pymysql.connect(host='10.22.32.29',
                       user='root',
                       password='Server43214321',
                       database='maoer')
# 获取 MySQL 游标
cursor = conn.cursor()
print('maoer connect')
conn2 = pymysql.connect(host='10.22.32.29',
                        user='root',
                        password='Server43214321',
                        database='maoer_data_analysis')
# 获取 MySQL 游标
cursor2 = conn2.cursor()
print('maoer_data_analysis connect')
# 连接到 MongoDB 数据库
mongo_client = MongoClient('mongodb://localhost:27017/')
db = mongo_client['maoer_danmu']
collection = db['maoer_danmu_embedd']
print('maoer_danmu_embedd connect')
# 初始化 BERT 模型
danmu_config_path = './bert_model/chinese_roberta_wwm_ext_L-12_H-768_A-12_danmu/bert_config.json'
danmu_checkpoint_path = './bert_model/chinese_roberta_wwm_ext_L-12_H-768_A-12_danmu/bert_model.ckpt'
danmu_dict_path = './bert_model/chinese_roberta_wwm_ext_L-12_H-768_A-12_danmu/vocab.txt'

# 加载预训练模型和分词器
danmu_tokenizer = Tokenizer(danmu_dict_path, do_lower_case=True)
danmu_model = build_transformer_model(
    danmu_config_path,
    checkpoint_path=None,
    model='nezha',
    ignore_invalid_weights=True,
    return_keras_model=True
)
danmu_model.load_weights(danmu_checkpoint_path)


# 创建一个字典来存储结果
data_dict = {}
# 获取所有sound_id
# 目前运行声音:202211-202303期间所有活跃用户发表过弹幕的活跃的声音 总共1308942条弹幕 8955个sound  未运行的8206个sound
sql = """select t1.sound_id 
         from 
            lingyun_maoer_analysis_time.activeuser_submit_danmu_sound_with_drama_202211_202303 t1 
            join (select distinct sound_id from active_sound_exceed_avg) t2 
            on t1.sound_id=t2.sound_id 
         where group by t1.sound_id order by t1.sound_id
        """

cursor2.execute(sql)
sound_results = cursor2.fetchall()

# sound_not_exist = [27308, 85179, 124219, 126061, 159594, 211400, 347682, 355870, 426686, 533527, 537351, 546042, 548085, 548135, 554613, 554680, 554720, 554725, 555087, 555867, 565729, 580574, 713620, 890463, 893535, 894161, 894788, 896140, 898519, 900340, 900414, 900427, 901096, 901586, 902089, 902217, 903124, 903318, 905786, 905833, 911958, 913611, 917953, 918029, 918754, 919567, 923165, 923603, 924225, 924340, 925583, 926934, 926940, 929023, 929175, 929545, 929618, 930419, 930534, 931055, 931261, 932924, 933007, 934086, 934111, 934900, 935140, 937616, 937624, 937638, 937669, 937710, 939429, 939785, 939920, 939973, 940397, 941901, 943137, 945602, 946406, 948343, 948350, 948691, 949314, 952280, 953075, 959115, 961554, 962266, 962309, 964554, 965723, 966255, 966744, 966930, 967598, 967690, 969280, 973306, 973439, 973686, 976360, 978159, 980518, 981517, 984899, 985660, 985693, 986574, 987351, 998781, 998787]
# sound_results = sound_not_exist
sum_sound = 0
print('共', len(sound_results), '个音频')

# 根据sound_id获取danmu_id   从sound_start开始计算
for i in range(int(sound_start), len(sound_results)):
    # for i in range(len(sound_results)):
    # if i >= 1400:
    #     break
    sound_id = sound_results[i]
    # 先找到sound_id对应的活跃用户发的弹幕列表
    sql1 = "select di.danmu_id,di.sound_id,di.user_id,di.danmu_info_stime_notransform,di.danmu_info_date,di.danmu_info_text from lingyun_maoer_analysis_time.activeuser_submit_danmu_sound_with_drama_202211_202303 as di where di.sound_id= %s GROUP BY danmu_id"
    cursor.execute(sql1, sound_id)
    activeuser_danmu_results = cursor.fetchall()
    print('sql1完成,活跃用户共：', len(activeuser_danmu_results), '条弹幕,sound_id= ', sound_id)

    sound_time_danmu = get_danmu_second_list(sound_id)
    now = datetime.now()
    current_time = now.strftime("%Y-%m-%d %H:%M:%S")
    print("sql2完成,当前时间：", current_time)

    danmulist = []
    insert_data = []
    for j in range(0, len(activeuser_danmu_results)):
    # for activedanmu in activeuser_danmu_results:
        activedanmu = activeuser_danmu_results[j]
        danmu_time = int(activedanmu[3])  # 活跃用户danmu在sound中的时间
        danmu_time_submit_date = activedanmu[4]  # 活跃用户danmu发表的日期具体时间
        danmu_id = activedanmu[0]  # 当前弹幕id
        #print('当前danmu_id：', danmu_id,'danmu_time_insound:',danmu_time)

        # 找到活跃用户弹幕在sound_id中对应的前后15s内所有弹幕
        cal_danmu(max(danmu_time - 15, 0), min(danmu_time + 16, len(sound_time_danmu)), sound_time_danmu)

        # 新时间窗保存
        danmu_dict = []
        curr_danmu_embedd = []
        before_8s_window_danmus, before_15s_window_danmus, after_8s_window_danmus, after_15s_window_danmus = [], [], [], []
        start_time = max(0, danmu_time - 15)
        end_time = min(len(sound_time_danmu), danmu_time + 16)
        for k in range(start_time, end_time):
            for danmu_info in sound_time_danmu[k]:
                if danmu_id == danmu_info[0]:
                    curr_danmu_embedd = danmu_info[5]
                else:
                    # 判断时间窗内弹幕的发表时间是否在本弹幕之前 之后则剔除
                    if danmu_info[3] <= danmu_time_submit_date:
                        if k <= danmu_time:  # 在当前弹幕之前
                            if k >= danmu_time - 8:  # 8s内
                                before_8s_window_danmus.append(danmu_info[5])
                            else:  # 大于8秒小于15s内
                                before_15s_window_danmus.append(danmu_info[5])
                        else:  # 在当前弹幕之后
                            if k <= danmu_time + 8:  # 8s内
                                after_8s_window_danmus.append(danmu_info[5])
                            else:  # 大于8秒小于15s内
                                after_15s_window_danmus.append(danmu_info[5])
                        # window_danmus.append(danmu_info[4])
                    else:  # 如果在之后15s内，则判断发表时间是否在对应时间窗内，是则加上
                        if k > danmu_time:
                            if danmu_info[3] <= (danmu_time_submit_date + timedelta(seconds=k - danmu_time)):
                                if k <= danmu_time + 8:  # 8s内
                                    after_8s_window_danmus.append(danmu_info[5])
                                else:  # 大于8秒小于15s内
                                    after_15s_window_danmus.append(danmu_info[5])
                            # if danmu_info[3] <= (danmu_time_submit_date + timedelta(seconds=k-danmu_time)):
                            #     window_danmus.append(danmu_info[4])
        if all(not danmu_list for danmu_list in
               [before_8s_window_danmus, before_15s_window_danmus, after_8s_window_danmus, after_15s_window_danmus]):
            # print("*******************时间窗内弹幕为空,当前danmu_id:", danmu_id)
            continue
        # if len(curr_danmu_embedd) == 0:
        #     print("*******************当前活跃用户弹幕未获取到,当前danmu_id:", danmu_id)
        #     continue
        # *************这里的15s表示大于8s小于15s的部分！！！！！！！！！！！！！！！！！！
        before_8s_danmu_sim, before_15s_danmu_sim, after_8s_danmu_sim, after_15s_danmu_sim = [], [], [], []
        sum_before_8s, max_before_8s, min_before_8s, len_before_8s = 0, 0, 0, 0
        sum_before_15s, max_before_15s, min_before_15s, len_before_15s = 0, 0, 0, 0
        sum_after_8s, max_after_8s, min_after_8s, len_after_8s = 0, 0, 0, 0
        sum_after_15s, max_after_15s, min_after_15s, len_after_15s = 0, 0, 0, 0
        if before_8s_window_danmus:
            for danmu_emb in before_8s_window_danmus:
                before_8s_danmu_sim.append(1 - cosine(curr_danmu_embedd, danmu_emb))
            sum_before_8s = sum(before_8s_danmu_sim)
            max_before_8s = max(before_8s_danmu_sim)
            min_before_8s = min(before_8s_danmu_sim)
            len_before_8s = len(before_8s_danmu_sim)
            print(f"len(before_8s_danmu_sim):{len(before_8s_danmu_sim)}, sum_before_8s:{sum_before_8s}, "
                  f"max_before_8s:{max_before_8s}, min_before_8s:{min_before_8s}, len_before_8s :{len_before_8s}")
        if before_15s_window_danmus:
            for danmu_emb in before_15s_window_danmus:
                before_15s_danmu_sim.append(1 - cosine(curr_danmu_embedd, danmu_emb))
            sum_before_15s = sum(before_15s_danmu_sim)
            max_before_15s = max(before_15s_danmu_sim)
            min_before_15s = min(before_15s_danmu_sim)
            len_before_15s = len(before_15s_danmu_sim)
            print(f"len(before_15s_danmu_sim):{len(before_15s_danmu_sim)}, sum_before_15s:{sum_before_8s}, "
                  f"max_before_15s:{max_before_15s}, min_before_15s:{min_before_15s}, len_before_15s :{len_before_15s}")
        if after_8s_window_danmus:
            for danmu_emb in after_8s_window_danmus:
                after_8s_danmu_sim.append(1 - cosine(curr_danmu_embedd, danmu_emb))
            sum_after_8s = sum(after_8s_danmu_sim)
            max_after_8s = max(after_8s_danmu_sim)
            min_after_8s = min(after_8s_danmu_sim)
            len_after_8s = len(after_8s_danmu_sim)
            print(f"len(after_8s_danmu_sim):{len(after_8s_danmu_sim)}, sum_after_8s:{sum_after_8s}, "
                  f"max_after_8s:{max_after_8s}, min_after_8s:{min_after_8s}, len_after_8s :{len_after_8s}")
        if after_15s_window_danmus:
            for danmu_emb in after_15s_window_danmus:
                after_15s_danmu_sim.append(1 - cosine(curr_danmu_embedd, danmu_emb))
            sum_after_15s = sum(after_15s_danmu_sim)
            max_after_15s = max(after_15s_danmu_sim)
            min_after_15s = min(after_15s_danmu_sim)
            len_after_15s = len(after_15s_danmu_sim)
            print(f"(len(after_15s_danmu_sim):{len(after_15s_danmu_sim)}, sum_after_15s:{sum_after_15s}, "
                  f"max_after_15s:{max_after_15s}, min_after_15s:{min_after_15s}, len_after_15s :{len_after_15s}")
        danmu_len = len(activedanmu[5])
        insert_data.append((activedanmu[2], activedanmu[1], activedanmu[0], activedanmu[3],
                            sum_before_8s, max_before_8s, min_before_8s, len_before_8s, sum_before_15s,
                            max_before_15s, min_before_15s, len_before_15s,
                            sum_after_8s, max_after_8s, min_after_8s, len_after_8s, sum_after_15s, max_after_15s,
                            min_after_15s, len_after_15s, danmu_len))
        # print('insert_data:', insert_data)

        # 存入MongoDB数据库
        for k in range(max(0, danmu_time - 15), min(len(sound_time_danmu), danmu_time + 16)):
            for danmu_info in sound_time_danmu[k]:
                row_dict = {
                    'danmu_id': danmu_info[0],
                    'sound_id': danmu_info[1],
                    'user_id': danmu_info[2],
                    'danmu_info_stime_notransform': float(k),
                    'danmu_info_text': danmu_info[4],
                    'embedding': danmu_info[5].tolist()
                }
                danmu_dict.append(row_dict)

        # 将数据存储到 MongoDB 数据库
        collection.insert_many(danmu_dict)

        now = datetime.now()
        current_time = now.strftime("%Y-%m-%d %H:%M:%S")
        print('已记录第', (j + 1), '个活跃用户弹幕,当前danmu_id:', danmu_id, ', 当前时间', current_time)
        # #当数据大于300则直接存储
        # if len(activeuser_danmu_results)>=300:
        #     sql_insert = "INSERT INTO lingyun_maoer_analysis_time.danmu_involved_activeuser_202211_202303 VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
        #     cursor2.executemany(sql_insert, insert_data[-1])
        #     conn2.commit()
        #     now = datetime.now()
        #     current_time = now.strftime("%Y-%m-%d %H:%M:%S")
        #     print('已完成活跃用户弹幕存储, 当前时间', current_time)

    # if len(activeuser_danmu_results)<300:
        #先插入一个临时结果文件 避免数据库断连
    if len(insert_data) > 150:
        filename = 'temp_danmu_involved_result_output.csv'
        df = pd.DataFrame(insert_data)
        df.to_csv(filename, index=False, header=False)
        # with open(filename, "wb") as f:
        #     writer = csv.writer(f)
        #     writer.writerows(insert_data)

    # 插入到mysql数据库
    # sql_insert = "INSERT INTO lingyun_maoer_analysis_time.danmu_involved_activeuser_202211_202303 VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
    sql_insert = "INSERT INTO lingyun_maoer_analysis_time.danmu_involved_activeuser_202211_202303_allinfo VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
    cursor2.executemany(sql_insert, insert_data)
    conn2.commit()
    now = datetime.now()
    current_time = now.strftime("%Y-%m-%d %H:%M:%S")
    print('已完成活跃用户弹幕存储, 当前时间', current_time)


    #print('已完成 ', sum_sound, ' 个音频danmu处理: ', sound_results[sum_sound])
    sum_sound += 1
    now = datetime.now()
    current_time = now.strftime("%Y-%m-%d %H:%M:%S")
    print('已完成 ', sum_sound, ' 个音频danmu处理，当前sound_id： ', sound_id,'当前时间：', current_time)
    #print("当前时间：", current_time)
    i += 1
    print('--------------------------------------------------------------------------')

# 关闭 MySQL 游标和连接
cursor.close()
conn.close()
cursor2.close()
conn2.close()
