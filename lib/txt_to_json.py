import os
import json
import sys

proj_dir = os.path.dirname(os.path.abspath(__file__))
bakt_txt_path = proj_dir + sys.argv[1]
db_json_path = proj_dir + "/../assets/db_data.json"

db_data = {"bakterijas": [], "jautajumi": [], "atbildes": [], "bildes": []}
bakt_id = 0
jaut_id = 0
atb_id = 0
pic_id = 0


with open(bakt_txt_path, "r") as txt_file:
    bakt_sk = int(txt_file.readline())
    for i in range(bakt_sk):
        name = txt_file.readline().strip("\n")
        bio = txt_file.readline().strip("\n")
        patog_apr = txt_file.readline().strip("\n")
        slim_apr = txt_file.readline().strip("\n")
        db_data["bakterijas"].append({
            "id": bakt_id,
            "name": name,
            "matched": 0,
            "patogen_apr": patog_apr,
            "slimibas_apr": slim_apr,
            "patogen_apr_available": 0,
            "slimibas_apr_available": 0,
            "bio": bio,
            "convers_progress": 0
        })
        jaut_pics = txt_file.readline()
        jaut_sk = int(jaut_pics.split()[0])
        pic_sk = int(jaut_pics.split()[1])
        for j in range(jaut_sk):
            jaut = txt_file.readline().strip("\n")
            jaut_info = txt_file.readline().strip("\n")
            atb_sk = int(jaut_info.split()[0])
            jaut_type = jaut_info.split()[1]
            db_data["jautajumi"].append({
                "id": jaut_id,
                "type": jaut_type,
                "teikums": jaut,
                "bakterija": bakt_id
            })
            for k in range(atb_sk):
                atb = txt_file.readline().strip("\n")
                if atb.split(maxsplit=1)[0] == "*":
                    db_data["atbildes"].append({
                        "id": atb_id,
                        "teikums": atb.split(maxsplit=1)[1],
                        "pareizi": 1,
                        "jautajums": jaut_id
                    })
                else:
                    db_data["atbildes"].append({
                        "id": atb_id,
                        "teikums": atb,
                        "pareizi": 0,
                        "jautajums": jaut_id
                    })
                atb_id += 1
            jaut_id += 1
        for l in range(pic_sk):
            db_data["bildes"].append({
                "id": pic_id,
                "path": txt_file.readline().strip("\n"),
                "bakterija": bakt_id
            })
            pic_id += 1
        bakt_id += 1


with open(db_json_path, "w") as json_file:
    json.dump(db_data, json_file, indent=4, ensure_ascii=False)
