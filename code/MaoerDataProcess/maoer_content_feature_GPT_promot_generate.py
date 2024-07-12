# maoer内容特征提取，GPT3.5微调 pormot生成
# 输入：content_feature_GPT_finetune_dataset.xlsx
# 根据输入的表格，生成promot

# 官方数据格式：json文件  每段对话都由三部分组成：系统消息、用户消息和助手消息。
# {"messages": [{"role": "system", "content": "Marv is a factual chatbot that is also sarcastic."},
#               {"role": "user", "content": "What's the capital of France?"},
#               {"role": "assistant", "content": "Paris, as if everyone doesn't know that already."}]}

import pandas as pd
import json

# 文件读取
# 读取 Excel 文件中的工作表
path = './content_feature_GPT/'
input_file = path+'content_feature_GPT_finetune_dataset.xlsx'
output_file = path+'content_feature_GPT_finetune_prompt.json'
data = pd.read_excel(input_file, sheet_name='promot')
# 获取数据框的行数和列数
num_rows, num_cols = data.shape
prompt_list = []
for n in range(0, num_rows):
    # 获取第n行数据
    row = data.iloc[n].tolist()
    # 指定列名或列索引，获取对应的数值
    content_title = row[1]
    content_file_content = row[2]
    content_one_sentence = row[3]
    content_type = row[4].split('-')
    content_label = row[5].split()

    system_pre = '你是一个能分辨文本内容类型的助手。'
    user_pre = '请先学习以下任务，学习完后只需回复已完成学习,等待后续的任务即可。' \
               '下面将输入一段文本，这是来源于一些长或短的故事简介。根据输入的文本内容，判断这段文本所指的故事可能所属的性向分类、时代分类、故事类型及标签。' \
               '具体的性向分类有：言情,纯爱,无CP；' \
               '时代分类有：近代现代,古色古香,架空历史,幻想未来；' \
               '故事类型有：爱情,武侠,奇幻,仙侠,游戏,传奇,科幻,童话,惊悚,悬疑,剧情,轻小说,古典衍生,东方衍生,西方衍生,其他衍生,儿歌,散文,寓言,童谣；' \
               '标签有：甜文,爽文,情有独钟,穿越时空,穿书,强强,天作之合,系统,豪门世家,天之骄子,娱乐圈,成长,重生,都市,宫廷侯爵,种田文,快穿,年代文,无限流,升级流,业界精英,直播,' \
               '仙侠修真,幻想空间,灵异神怪,破镜重圆,先婚后爱,综漫,万人迷,星际,打脸,女强,励志,基建,逆袭,异能,校园,赛博朋克,日常,游戏网游,惊悚,电竞,团宠,追爱火葬场,美食,末世,' \
               'ABO,群像,悬疑推理,复仇虐渣,现代架空,美强惨,生子,灵气复苏,暗恋,萌宠,群像,废土,青梅竹马,玄学,相爱相杀,清穿,马甲文,正剧,综艺,机甲,虫族,朝堂,科举,宫斗。' \
               '根据上述四种分类的取值范围，判断文本所属的这四种分类结果。要求：每种分类都必须有答案输出,请勿给出取值范围外的结果；前三种是单选，第四种是多选且至少三个。' \
               '请给出明确的四种分类结果，以以下json形式作为输出，要求包含标题、性向、时代、类型、标签,' \
               '以下为输入文本的标题：{},输入文本为：'.format(content_title)
    # assistant_pre = '这段文本所属分类结果如下：【性向= {}；时代= {}；类型= {}；标签={}】'.format(content_type[0], content_type[1], content_type[2], content_label)
    assistant_pre = '''。输出结果为：result = {"标题": "%s","性向": "%s","时代": "%s","类型": "%s","标签": "%s"}''' % (
    content_title, content_type[0], content_type[1], content_type[2], content_label)
    system_content = system_pre
    user_content = user_pre + content_file_content
    user_one_sentence_content = user_pre + content_one_sentence
    assistant_content = assistant_pre

    # 创建字典
    prompt = {
        "messages": [
            # {"role": "system", "content": system_content},
            {"role": "user", "content": user_content + assistant_content},
            # {"role": "assistant", "content": assistant_content}
        ]
    }
    prompt_one_sentence = {
        "messages": [
            # {"role": "system", "content": system_content},
            {"role": "user", "content": user_one_sentence_content + assistant_content},
            # {"role": "assistant", "content": assistant_content}
        ]
    }
    prompt_list.append(prompt)
    prompt_list.append(prompt_one_sentence)

# 将数据写入 JSON 文件
with open(output_file, 'w') as f:
    json.dump(prompt_list, f, indent=4, ensure_ascii=False)  # indent=4 参数，用于指定缩进的空格数,ensure_ascii表示是否用Unicode，false表示转化为UTF-8
print('完成输出prompt.json')
