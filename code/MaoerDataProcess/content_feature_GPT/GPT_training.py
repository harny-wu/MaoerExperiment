# -*- coding: utf-8 -*-
# 先GPT小样本学习
# 后输入真实数据再得到结果
import csv
import os

# 使用 HTTP requests 请求调用 ChatGPT
import openai
import requests
import json


def save_result_file(out_path, out_list, is_save_as_csv):
    # 输出结果
    out_json_path = out_path + 'content_feature_GPT_result.json'
    print("共完成数据：", len(out_list), "条")
    with open(out_json_path, 'a', encoding='utf-8', errors='ignore') as f:
        json.dump(out_list, f, indent=4, ensure_ascii=False)
        # indent=4 参数，用于指定缩进的空格数,ensure_ascii表示是否用Unicode，false表示转化为UTF-8
    print('完成输出content_feature_GPT_result.json')

    if is_save_as_csv:
        # 解析json结果输出
        # Example：response_data = {'id': 'chatcmpl-8mkdDKBVzVtHdE92Y3qcizWwzimyA', 'object': 'chat.completion', 'created': 1706629687, 'model': 'gpt-3.5-turbo-0613',
        # 'choices': [{'index': 0, 'message': {'role': 'assistant', 'content': '本次学习结果如下：result={"标题":"偷偷藏不住","类型":"言情"}'}, 'logprobs': None, 'finish_reason': 'stop'}], 'usage': {'prompt_tokens': 1049, 'completion_tokens': 5, 'total_tokens': 1054}, 'system_fingerprint': None}
        json_result_out_list = []
        print("解析json输出结果文件")
        for result in out_list:
            # 获取 result 字符串
            result_string = result['choices'][0]['message']['content']
            # print(result_string)
            # 处理反斜杠转义字符
            result_string = result_string.replace('\\', '')
            # 解析 result 字符串为字典
            if "已完成学习" in result_string:
                continue
            if "result" in result_string:
                result_dict = eval(result_string.split('result=')[1])
            else:
                result_dict = json.loads(result_string)
            print(result_dict)
            json_result_out_list.append(result_dict)
            # # 解析 result 字符串为字典
            # result_dict = eval(result_string.split('result=')[1])
            # json_result_out_list.append(result_dict)

        # 将所有结果写入文件
        out_json_path = out_path + 'content_feature_GPT_result.csv'
        file_exists = os.path.isfile(out_json_path)
        with open(out_json_path, 'a', newline='') as file:
            writer = csv.writer(file)
            if not file_exists:  # 如果文件不存在，则写入标题行
                writer.writerow(['标题', '性向', '时代', '类型', '标签1', '标签2', '标签3', '标签4', '标签5'])
            for result_dict in json_result_out_list:
                title = result_dict['标题']
                genre = result_dict['性向']
                era = result_dict['时代']
                typ = result_dict['类型']
                tags = result_dict['标签']
                row = [title, genre, era, typ] + tags[:5]  # 只取前五个标签
                writer.writerow(row)

        print("结果已保存到文件content_feature_GPT_result.csv中")


# 反代理设置
url = "https://openkey.cloud/v1/chat/completions"
headers = {
  'Content-Type': 'application/json',
  # 填写OpenKEY生成的令牌/KEY，注意前面的 Bearer 要保留，并且和 KEY 中间有一个空格。
  'Authorization': 'Bearer sk-wXOPD351o4SFZAyr5a44085bDc0c480981D86dD1F87e6a21'
}

# 读取数据
path = '../content_feature_GPT/'
input_train_path = path + "content_feature_GPT_finetune_prompt.json"
input_test_path = path + 'content_feature_GPT_test_prompt.json'
with open(input_train_path, 'r', encoding='utf-8') as f:
    data = f.read()
    # 解析 JSON 数据
    train_data_list = json.loads(data)
# print(train_data[1]['messages'])
with open(input_test_path, 'r', encoding='utf-8') as f:
    data = f.read()
    test_data_list = json.loads(data)

train_out_put_list = []
test_out_put_list = []
# 小样本学习
for train_data in train_data_list:
# for i in range(0, len(train_data_list)):
# for i in range(0, 1):
#     train_data = train_data_list[i]
    data = {
        "model": "gpt-3.5-turbo",
        "messages": train_data['messages']
    }

    response = requests.post(url, headers=headers, json=data)
    train_out_put_list.append(response.json())
    # print("Status Code", response.status_code)
    # print("JSON Response ", response.json())
# if len(train_out_put_list)>0:
#     save_result_file(path, train_out_put_list, is_save_as_csv=False)

# 真实数据
# for test_data in test_data_list:
for i in range(0, len(test_data_list)):
# for i in range(0, 1):
    test_data = test_data_list[i]
    data = {
        "model": "gpt-3.5-turbo",
        "messages": test_data['messages']
    }

    response = requests.post(url, headers=headers, json=data)
    try:
        data = response.json()
        test_out_put_list.append(data)
        # 对返回的 JSON 数据进行处理
    except (json.decoder.JSONDecodeError, requests.exceptions.JSONDecodeError):
        print("无法解析返回的 JSON 数据,直接返回：", response)

    # 检查 test_out_put_list 长度是否达到 100
    if len(test_out_put_list) >= 100:
        save_result_file(path, test_out_put_list, is_save_as_csv=False)
        test_out_put_list = []
        print(i)
if len(test_out_put_list) > 0:
    save_result_file(path, test_out_put_list, is_save_as_csv=False)