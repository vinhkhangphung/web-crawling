import mysql.connector
import requests
import json

API_ENDPOINT = "https://api.topdev.vn/td/v2/jobs?fields[job]=id,slug,title,salary,company,extra_skills,skills_" \
               "str,skills_arr,skills_ids,job_types_str,job_levels_str,job_levels_arr,job_levels_ids,addresses," \
               "status_display,detail_url,job_url,salary,published,refreshed,applied,candidate,requirements_arr," \
               "packages,benefits,content,features,is_free,is_basic,is_basic_plus,is_distinction&fields[company]=" \
               "slug,tagline,addresses,skills_arr,industries_arr,industries_str,image_cover,image_galleries," \
               "benefits&page=0&locale=en_US&ordering=jobs_new"
API_META = "https://api.topdev.vn/td/v2/jobs?page=1&locale=en_US&ordering=jobs_new"
START_PAGE = 1
LAST_PAGE = 0
DESTINATION = "api_json"


def find_last_page():
    global LAST_PAGE
    response = requests.get(API_META)
    LAST_PAGE = json.loads(response.text)["meta"]["last_page"]


def fetch():
    find_last_page()
    for pageCount in range(START_PAGE, LAST_PAGE + 1):
        response = requests.get(API_ENDPOINT.replace(f"page=0", f"page={pageCount}", 1))
        with open(f"{DESTINATION}/data_{pageCount}", "w", encoding="utf-8") as file:
            json.dump(json.loads(response.text), file, indent=4, ensure_ascii=False)


def process():
    conn = mysql.connector.connect(
        host="localhost",
        user="root",
        passwd="",
        database="topdev"
    )
    cursor = conn.cursor(buffered=True)

    for pageCount in range(START_PAGE, LAST_PAGE + 1):
        with open(f"api_json/data_{pageCount}", "r", encoding="utf-8") as file:
            parse = json.load(file)
            for job in parse["data"]:
                """insert company"""
                company_name = job["company"]["display_name"]
                company_logo = job["company"]["image_logo"]
                company_industry = job["company"]["industries_str"]
                company_address = "; ".join(job["company"]["addresses"]["full_addresses"])

                cursor.execute("SELECT insertCompany (%s, %s, %s, %s)",
                               (company_name, company_logo, company_industry, company_address))
                conn.commit()
                company_id = cursor.fetchone()[0]  # COMPANY ID FOR FURTHER USAGE

                """insert job"""
                job_title = job["title"]
                job_salary = job["salary"]["value"] if job["salary"]["value"] is not None else ""
                job_require = ";".join(job["requirements_arr"][0]["value"])
                job_address = ";".join(job["addresses"]["full_addresses"])
                job_level = job["job_levels_str"]  # JOB LEVEL
                cursor.execute("SELECT insertJob (%s, %s, %s, %s, %s, %s)",
                               (job_title, company_id, job_salary, job_require, job_address, job_level))
                conn.commit()
                job_id = cursor.fetchone()[0]

                """insert job-benefit"""
                for benefit in job["benefits"]:
                    job_benefit = benefit["value"]
                    cursor.callproc("insertJobBenefit", (job_benefit, job_id))
                    conn.commit()

                """insert company-benefit"""
                for benefit in job["company"]["benefits"]:
                    company_benefit = benefit["value"]
                    cursor.callproc("insertCompanyBenefit", (company_benefit, company_id))
                    conn.commit()

                """insert skills - JOB"""
                skill_array = []  # INCLUDE INSERT SKILL
                for skill in job["skills_arr"]:
                    cursor.execute("SELECT insertSkill (%s)", (skill,))
                    conn.commit()
                    skill_id = cursor.fetchone()[0]
                    skill_array.append(skill_id)

                """insert job-skill"""
                for sk_id in skill_array:
                    cursor.callproc("insertJobSkill", (job_id, sk_id))
                    conn.commit()

                """insert skills - COMPANY"""
                skill_array = []
                for skill in job["company"]["skills_arr"]:
                    cursor.execute("SELECT insertSkill (%s)", (skill,))
                    conn.commit()
                    skill_id = cursor.fetchone()[0]
                    skill_array.append(skill_id)

                """insert company-skills"""
                for sk_id in skill_array:
                    cursor.callproc("insertCompanySkill", (sk_id, company_id))
                    conn.commit()

                """insert image"""
                # print(job["company"]["image_cover"]) -- COVER IMAGE
                for image in job["company"]["image_galleries"]:
                    cursor.callproc("insertImage", (image["url"], company_id))
                    conn.commit()


if __name__ == '__main__':
    fetch()
    process()
