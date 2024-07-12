#finetune.py
import os
import openai
openai.api_key = "填自己的key"
openai.FineTuningJob.create(training_file="粘贴刚刚的文件ID", model="gpt-3.5-turbo")