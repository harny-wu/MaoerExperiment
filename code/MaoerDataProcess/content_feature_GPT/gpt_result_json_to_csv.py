import csv
import json
import os
import re

path = '../content_feature_GPT/'
input_train_path = path + "content_feature_GPT_finetune_prompt.json"
input_test_path = path + 'content_feature_GPT_test_prompt.json'
input_gpt_result_path = path + 'content_feature_GPT_result.json'

with open(input_gpt_result_path, 'r', encoding='utf-8') as f:
    data = f.read()
    # 解析 JSON 数据
    json_result_list = json.loads(data)

json_result_out_list = []
print("解析json输出结果文件")
for result in json_result_list:
    # 获取 result 字符串
    result_string = result['choices'][0]['message']['content']
    # print(result_string)
    # 处理反斜杠转义字符
    result_string = result_string.replace('\\', '')
    print(result_string)
    match_pre = re.search(r"result\s*=\s*({.*})", result_string, re.DOTALL)
    match_pre_chinese = re.search(r"{(.*)}", result_string, re.DOTALL)
    # 解析 result 字符串为字典
    if "已完成学习" in result_string:
        continue
    elif match_pre:
        match = match_pre
        print(match)
        if match:
            result_string = match.group(1)
            print("提取的字典数据:", result_string)
            result_dict = json.loads(result_string)
        else:
            result_dict_temp = eval(result_string.split('result=')[1])
    elif match_pre_chinese:
        match = match_pre_chinese
        print(match)
        if match:
            result_string = '{'+match.group(1)+'}'
            print("提取的字典数据:", result_string)
            result_dict = json.loads(result_string)
        else:
            result_dict_temp = eval(result_string.split('结果=')[1])
    else:
        print("未解析成功", result_string)
        if ("无法根据" in result_string) or ("无法判断" in result_string) or ("无法提供" in result_string)\
            or ("为您提供帮助" in result_string) or ("无法准确推断" in result_string) or("不能直接执行您的请求" in result_string):
            continue
        match = match_pre
        if match:
            result_string = match.group(1)
            print("提取的字典数据:", result_string)
        # else:
        #     print("未找到匹配的字典数据")
        result_dict = json.loads(result_string)
    print(result_dict)

    json_result_out_list.append(result_dict)

# 将所有结果写入文件
out_json_path = path + 'content_feature_GPT_result.csv'

file_exists = os.path.isfile(out_json_path)
with open(out_json_path, 'a', newline='') as file:
    writer = csv.writer(file)
    if not file_exists:  # 如果文件不存在，则写入标题行
        writer.writerow(['标题', '性向', '时代', '类型', '标签1', '标签2', '标签3', '标签4', '标签5'])
    for result_dict in json_result_out_list:
        print(result_dict)
        title = result_dict['标题']
        genre = result_dict['性向']
        era = result_dict['时代']
        typ = result_dict['类型']
        tags = result_dict['标签']
        # row = [title, genre, era, typ] + tags[:5]  # 只取前五个标签
        row = [title, genre, era, typ] + [','.join(tags[:5])]  # 将 tags 列表转换为字符串后再进行拼接
        writer.writerow(row)

print("结果已保存到文件content_feature_GPT_result.csv中")
