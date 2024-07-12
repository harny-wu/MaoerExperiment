# maoer内容特征提取，GPT3.5微调 pormot生成
# 输入：content_feature_GPT_finetune_dataset.xlsx
# 根据输入的表格，生成promot

# 官方数据格式：json文件
# {   "act": "担任雅思写作考官",
#     "prompt": "我希望你假定自己是雅思写作考官，根据雅思评判标准，按我给你的雅思考题和对应答案给我评分，并且按照雅思写作评分细则给出打分依据。此外，请给我详细的修改意见并写出满分范文。第一个问题是：It is sometimes argued that too many students go to university, while others claim that a university education should be a universal right.Discuss both sides of the argument and give your own opinion.对于这个问题，我的答案是：In some advanced countries, it is not unusual for more than 50% of young adults to attend college or university. Critics, however, claim that many university courses are worthless and young people would be better off gaining skills in the workplace. In this essay, I will examine both sides of this argument and try to reach a conclusion.There are several reasons why young people today believe they have the right to a university education. First, growing prosperity in many parts of the world has increased the number of families with money to invest in their children’s future. At the same time, falling birthrates mean that one- or two-child families have become common, increasing the level of investment in each child. It is hardly surprising, therefore, that young people are willing to let their families support them until the age of 21 or 22. Furthermore, millions of new jobs have been created in knowledge industries, and these jobs are typically open only to university graduates.However, it often appears that graduates end up in occupations unrelated to their university studies. It is not uncommon for an English literature major to end up working in sales, or an engineering graduate to retrain as a teacher, for example. Some critics have suggested that young people are just delaying their entry into the workplace, rather than developing professional skills.请依次给到我以下内容：具体分数及其评分依据、文章修改意见、满分范文。\n"
#   }

import pandas as pd
import json

# 文件读取
# 读取 Excel 文件中的工作表
path = '/Users/ly/Desktop/工作/大论文/数据/maoer_feature_deal_code/content_feature_GPT/'
input_file = path + 'content_feature_GPT_finetune_dataset.xlsx'
output_file = path + 'content_feature_GPT_finetune_prompt.json'
data = pd.read_excel(input_file, sheet_name='promot')
# 获取数据框的行数和列数
num_rows, num_cols = data.shape
prompt_list = []
for n in range(0, num_rows):
    # 获取第n行数据
    row = data.iloc[n].tolist()
    # 指定列名或列索引，获取对应的数值
    # title_column = first_row['标题']
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
    assistant_pre = '''。输出结果为：result = {"标题": "%s","性向": "%s","时代": "%s","类型": "%s","标签": "%s"}''' % (content_title, content_type[0], content_type[1], content_type[2], content_label)
    system_content = system_pre
    user_content = user_pre + content_file_content
    user_one_sentence_content = user_pre + content_one_sentence
    assistant_content = assistant_pre

    # 创建字典
    prompt = {
        "act": system_content,
        "prompt": user_content + assistant_content
    }
    prompt_one_sentence = {
        "act": system_content,
        "prompt": user_one_sentence_content + assistant_content
    }
    prompt_list.append(prompt)
    prompt_list.append(prompt_one_sentence)

    # result = {
    #     "标题": content_title,
    #     "性向": content_type[0],
    #     "时代": content_type[1],
    #     "类型": content_type[2],
    #     "标签": content_label
    # }

# 将数据写入 JSON 文件
with open(output_file, 'w') as f:
    json.dump(prompt_list, f, indent=4,
              ensure_ascii=False)  # indent=4 参数，用于指定缩进的空格数,ensure_ascii表示是否用Unicode，false表示转化为UTF-8
print('完成输出prompt.json')
