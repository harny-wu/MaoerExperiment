import copy
import csv
import sys

from pymongo import MongoClient, cursor
import pymysql
from datetime import datetime
import numpy as np
import os
# env:python=3.7 tensorflow=1.15
# import pandas as pd15
# from sklearn.model_selection import train_test_split
import json
from scipy.spatial.distance import cosine


# def get_sentence_embedding_many(texts, tokenizer, model):
#     ret = []
#     i = 0
#     while i < len(texts):
#         token_ids_list = []
#         segment_ids_list = []
#         for text in texts[i:i + 150]:
#             token_ids, segment_ids = tokenizer.encode(text, maxlen=256)
#             token_ids_list.append(token_ids)
#             segment_ids_list.append(segment_ids)
#         generator = [sequence_padding(token_ids_list), sequence_padding(segment_ids_list)]
#         result = model.predict(generator)
#         ret.extend(result)
#         i += 150
#         # print('finish：', i / 150)
#     if len(ret) != len(texts):
#         print('error')
#
#     return [item[0] for item in ret]


def float_to_list(num):
    num_str = str(num)
    ret = [[digit] for digit in num_str]
    return ret


# def get_sentence_embedding_many(texts,tokenizer,model):
#     ret = []
#     i = 0
#     while i < len(texts):
#         token_ids_list = []
#         segment_ids_list = []
#         for text in texts[i:i+150]:
#             token_ids, segment_ids = tokenizer.encode(text, maxlen=256)
#             token_ids_list.append(token_ids)
#             segment_ids_list.append(segment_ids)
#         generator = [sequence_padding(token_ids_list), sequence_padding(segment_ids_list)]
#         result = model.predict(generator)
#         embedding = float_to_list(result)
#         ret.extend(embedding)
#         i += 150
#     if len(ret) != len(texts):
#         print('error')
#     return ret

# 计算前后15s的所有弹幕embedding
# data[sec]是一秒钟内所有弹幕
# def cal_danmu(start, end, data):
#     for sec in range(start, end):
#         if len(data[sec]) > 0:
#
#             # 计算弹幕的embedding
#             danmu_embedding = get_sentence_embedding_many([item[3] for item in data[sec]], danmu_tokenizer, danmu_model)
#             # append回去
#             for i in range(len(data[sec])):
#                 data[sec][i].append(danmu_embedding[i])
    # print(data)


# def get_involved(danmu_id, data):
#     ret = []
#     for sec, second_danmus in enumerate(data):
#         # [[[danmi 1, embedding],danmu2],[],[],[danmu3]]
#         for ind, curr_danmu in enumerate(second_danmus):
#             if curr_danmu[0] == danmu_id:
#                 cal_danmu(max(sec - 15, 0), min(sec + 16, len(data)), data)
#
#                 window_danmus = []
#                 # 前后15秒的弹幕
#                 for i in range(max(0, sec - 15), min(len(data), sec + 16)):
#                     for danmu_i in data[i]:
#                         if danmu_i[0] != danmu_id:
#                             window_danmus.append(danmu_i[4])
#                 if window_danmus == []:
#                     continue
#                 danmu_sim = []
#                 for danmu_emb in window_danmus:
#                     danmu_sim.append(1 - cosine(curr_danmu[4], danmu_emb))
#                 # 0.5*max + 0.5*mean danmu_sim
#                 ret.append((0.5 * max(danmu_sim) + 0.5 * sum(danmu_sim) / len(danmu_sim), len(window_danmus),
#                             len(curr_danmu[3])))
#     return ret


def get_danmu_second_list(sound_id):
    # # sql2 = "SELECT distinct di.danmu_id,di.sound_id,di.user_id,di.danmu_info_stime_notransform,di.danmu_info_text,embedding  FROM maoer_danmu_embedd as di where di.sound_id  = %s GROUP BY danmu_id"
    # # cursor.execute(sql2, (sound_id))
    # # results = cursor.fetchall()
    pipeline = [
        {"$match": {"sound_id": sound_id}},
        {"$group": {
            "_id": "$danmu_id",
            "danmu_id": {"$first": "$danmu_id"},
            "sound_id": {"$first": "$sound_id"},
            "user_id": {"$first": "$user_id"},
            "danmu_info_stime_notransform": {"$first": "$danmu_info_stime_notransform"},
            "danmu_info_text": {"$first": "$danmu_info_text"},
            "embedding": {"$push": "$embedding"}
        }},
        {"$project": {"_id": 0}}  # 禁用 _id 字段
    ]
    results = collection.aggregate(pipeline)
    print(results[0])

    max_stime = 0
    for row in results:
        if row[3] > max_stime:
            max_stime = row[3]
    danmu_second_list = [[] for i in range(int(max_stime) + 1)]
    for row in results:
        danmu_second_list[int(row[3])].append([row[0], row[1], row[2], row[4], row[5]])  # [time1,[danmu_info_1][danmu_info_1]]
    return danmu_second_list


# input
sound_start = input("请输入从第几个声音数开始：")
# 获取当前日期和时间
now = datetime.now()

# 连接到 MySQL 数据库
# 获取 MySQL 游标
conn = pymysql.connect(host='10.22.32.29',
                        user='root',
                        password='Server43214321',
                        database='maoer_data_analysis')
# 获取 MySQL 游标
cursor = conn.cursor()
print('maoer_data_analysis connect')
# 连接到 MongoDB 数据库
mongo_client = MongoClient('mongodb://localhost:27017/')
db = mongo_client['maoer_danmu']
collection = db['maoer_danmu_embedd']
print('maoer_danmu_embedd connect')

# 创建一个字典来存储结果
data_dict = {}
# 获取所有sound_id
# sql = "select sound_id FROM active_sound_with_activeuser2022"  #更新至20231031 第3415个音频 sound_id='1000876'
# sql = "select sound_id from active_sound_exceed_avg where sound_id>='1000876' group by sound_id "
# sql = "select sound_id from lingyun_maoer_analysis_time.activeuser_submit_danmu_sound_with_drama_202211_202303 where sound_id='1005222' group by sound_id" # 测试用
# 总声音：202211-202303期间所有活跃用户发表过弹幕的声音  2295528条弹幕 24059 个sound
# sql = "select sound_id from lingyun_maoer_analysis_time.activeuser_submit_danmu_sound_with_drama_202211_202303 where sound_id>'1005552' group by sound_id"
# 目前运行声音:202211-202303期间所有活跃用户发表过弹幕的活跃的声音 总共1308942条弹幕 8955个sound  未运行的8206个sound
sql = "select t1.sound_id from lingyun_maoer_analysis_time.activeuser_submit_danmu_sound_with_drama_202211_202303 t1 " \
      "join (select distinct sound_id from active_sound_exceed_avg) t2 on t1.sound_id=t2.sound_id " \
      " group by t1.sound_id order by t1.sound_id"
cursor.execute(sql)
sound_results = cursor.fetchall()
sum_sound = 0
print('共', len(sound_results), '个音频')

# 根据sound_id获取danmu_id   从sound_start开始计算
for i in range(int(sound_start), len(sound_results)):
    # for i in range(len(sound_results)):
    sound_id = sound_results[i]
    # 先找到sound_id对应的活跃用户发的弹幕列表
    sql1 = "select di.danmu_id,di.sound_id,di.user_id,di.danmu_info_stime_notransform,di.danmu_info_text from lingyun_maoer_analysis_time.activeuser_submit_danmu_sound_with_drama_202211_202303 as di where di.sound_id= %s GROUP BY danmu_id"
    cursor.execute(sql1, sound_id)
    activeuser_danmu_results = cursor.fetchall()
    print('sql1完成,活跃用户共：', len(activeuser_danmu_results), '条弹幕,sound_id= ', sound_id)

    sound_time_danmu = get_danmu_second_list(sound_id)
    now = datetime.now()
    current_time = now.strftime("%Y-%m-%d %H:%M:%S")
    print("sql2完成,当前时间：", current_time)

    if sound_time_danmu is None:
        print("****************************该音频需重新embedding，sound_id=", sound_id, "******************************")
        continue

    danmulist = []
    for j in range(0,len(activeuser_danmu_results)):
    # for activedanmu in activeuser_danmu_results:
        activedanmu = activeuser_danmu_results[j]
        danmu_time = int(activedanmu[3])  # 活跃用户danmu在sound中的时间
        danmu_id = activedanmu[0]  # 当前弹幕id
        #print('当前danmu_id：', danmu_id,'danmu_time_insound:',danmu_time)

        # 找到活跃用户弹幕在sound_id中对应的前后15s内所有弹幕
        # cal_danmu(max(danmu_time - 15, 0), min(danmu_time + 16, len(sound_time_danmu)), sound_time_danmu)
        # print('完成danmu：',danmu_id,'的周边弹幕embedd')
        # now = datetime.now()
        # current_time = now.strftime("%Y-%m-%d %H:%M:%S")
        # print("当前时间：", current_time)

        danmu_dict = []
        curr_danmu_embedd = []
        insert_data = []
        window_danmus = []
        # columns = [col[0] for col in cursor2.description]
        for k in range(max(0, danmu_time - 15), min(len(sound_time_danmu), danmu_time + 16)):
            for danmu_info in sound_time_danmu[k]:
                if danmu_id == danmu_info[0]:
                    curr_danmu_embedd = danmu_info[4]
                else:
                    window_danmus.append(danmu_info[4])
        if window_danmus == []:
            continue
        danmu_sim = []
        for danmu_emb in window_danmus:
            danmu_sim.append(1 - cosine(curr_danmu_embedd, danmu_emb))
        # 0.5*max + 0.5*mean danmu_sim
        one = (0.5 * max(danmu_sim) + 0.5 * sum(danmu_sim) / len(danmu_sim))
        two = max(danmu_sim)
        three = min(danmu_sim)
        four = sum(danmu_sim) / len(danmu_sim)
        five = sum(danmu_sim)
        six = len(danmu_sim)
        seven = len(activedanmu[4])
        insert_data.append((activedanmu[2], activedanmu[1], activedanmu[0], activedanmu[3],
                            one, two, three, four, five, six, seven))
        print('insert_data:', insert_data)

        # for k in range(0, len(danmu_results)):
        # for k in range(max(0, danmu_time - 15), min(len(sound_time_danmu), danmu_time + 16)):
        #     for danmu_info in sound_time_danmu[k]:
        #         row_dict = {
        #             'danmu_id': danmu_info[0],
        #             'sound_id': danmu_info[1],
        #             'user_id': danmu_info[2],
        #             'danmu_info_stime_notransform': float(k),
        #             'danmu_info_text': danmu_info[3],
        #             'embedding': danmu_info[4].tolist()
        #         }
        #         danmu_dict.append(row_dict)

        # 插入到mysql数据库
        # sql_insert = "INSERT INTO lingyun_maoer_analysis_time.supply_danmu_involved_activeuser_202211_202303 VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
        # cursor.execute(sql_insert, insert_data[0])
        # conn.commit()
        # now = datetime.now()
        # current_time = now.strftime("%Y-%m-%d %H:%M:%S")
        print('已完成第', (j+1), '个活跃用户弹幕,当前danmu_id:', danmu_id,',存入MySQL及MongoDB数据库, 当前时间', current_time)


    #print('已完成 ', sum_sound, ' 个音频danmu处理: ', sound_results[sum_sound])
    sum_sound += 1
    now = datetime.now()
    current_time = now.strftime("%Y-%m-%d %H:%M:%S")
    print('已完成 ', sum_sound, ' 个音频danmu处理: ', sound_results[sum_sound],'当前时间：', current_time)
    #print("当前时间：", current_time)
    i += 1
    print('--------------------------------------------------------------------------')

# 关闭 MySQL 游标和连接
cursor.close()
conn.close()

