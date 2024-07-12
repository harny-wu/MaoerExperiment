if __name__ == '__main__':
    #
    get_sound_id_sql = """select t1.sound_id 
             from 
                lingyun_maoer_analysis_time.activeuser_submit_danmu_sound_with_drama_202211_202303 t1 
                join (select distinct sound_id from active_sound_exceed_avg) t2 
                on t1.sound_id=t2.sound_id 
             where group by t1.sound_id order by t1.sound_id
          """

    # 执行SQL，获得sound_id, 打印sound_id 数量，并展示前100 个 声音

    # input， 请输入想分析的sound_id


    # 先找到sound_id对应的活跃用户发的弹幕列表
    get_danmu_list_by_sound_sql = "select di.danmu_id,di.sound_id,di.user_id,di.danmu_info_stime_notransform,di.danmu_info_date,di.danmu_info_text from lingyun_maoer_analysis_time.activeuser_submit_danmu_sound_with_drama_202211_202303 as di where di.sound_id= %s GROUP BY danmu_id"

    # 执行SQL，获得sound_id, 打印sound_id 数量，并展示前 100条弹幕

    # input 请选择计算契合度的弹幕id



    # 获取周围的弹幕

    #
