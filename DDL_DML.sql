CREATE DATABASE IF NOT EXISTS topdev;
USE topdev;

CREATE TABLE IF NOT EXISTS company
(
    id       SMALLINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name     VARCHAR(255) UNIQUE,
    logo     VARCHAR(255),
    industry VARCHAR(255),
    address  VARCHAR(1275)
);

CREATE TABLE IF NOT EXISTS job
(
    id          SMALLINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    title       VARCHAR(255),
    company_id  SMALLINT UNSIGNED,
    salary      VARCHAR(255),
    requirement VARCHAR(2550),
    workplace   VARCHAR(1275),
    position    VARCHAR(255),
    FOREIGN KEY (company_id) REFERENCES company (id)
);

CREATE TABLE IF NOT EXISTS job_benefit
(
    detail VARCHAR(510),
    job_id SMALLINT UNSIGNED,
    FOREIGN KEY (job_id) REFERENCES job (id),
    PRIMARY KEY (detail, job_id)
);

CREATE TABLE IF NOT EXISTS skill
(
    id         SMALLINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    skill_name VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS job_skill
(
    job_id   SMALLINT UNSIGNED,
    skill_id SMALLINT UNSIGNED,
    FOREIGN KEY (job_id) REFERENCES job (id),
    FOREIGN KEY (skill_id) REFERENCES skill (id),
    PRIMARY KEY (job_id, skill_id)
);

CREATE TABLE IF NOT EXISTS company_benefit
(
    detail     VARCHAR(510),
    company_id SMALLINT UNSIGNED,
    FOREIGN KEY (company_id) REFERENCES company (id),
    PRIMARY KEY (detail, company_id)
);

CREATE TABLE IF NOT EXISTS image
(
    url        VARCHAR(255),
    company_id SMALLINT UNSIGNED,
    FOREIGN KEY (company_id) REFERENCES company (id),
    PRIMARY KEY (url, company_id)
);

CREATE TABLE IF NOT EXISTS company_skill
(
    skill_id   SMALLINT UNSIGNED,
    company_id SMALLINT UNSIGNED,
    FOREIGN KEY (skill_id) REFERENCES skill (id),
    FOREIGN KEY (company_id) REFERENCES company (id),
    PRIMARY KEY (skill_id, company_id)
);

DELIMITER //
# Insert company if not exists, always return CompanyID
CREATE FUNCTION IF NOT EXISTS insertCompany(
    c_name VARCHAR(255),
    c_logo VARCHAR(255),
    c_industry VARCHAR(255),
    c_address VARCHAR(1275)
) RETURNS SMALLINT UNSIGNED
    DETERMINISTIC
BEGIN
    DECLARE company_id SMALLINT UNSIGNED;

    SELECT id INTO company_id FROM company WHERE company.name = c_name;
    IF company_id IS NULL THEN
        INSERT INTO company(name, logo, industry, address)
        VALUES (c_name, c_logo, c_industry, c_address);
        SET company_id = LAST_INSERT_ID();
    END IF;
    RETURN company_id;
END //
DELIMITER ;


DELIMITER //
CREATE FUNCTION IF NOT EXISTS insertJob(
    j_title VARCHAR(255),
    j_company_id SMALLINT UNSIGNED,
    j_salary VARCHAR(255),
    j_requirement VARCHAR(2550),
    j_workplace VARCHAR(1275),
    j_position VARCHAR(255)
) RETURNS SMALLINT UNSIGNED
BEGIN
    DECLARE job_id SMALLINT UNSIGNED;
    INSERT INTO job (title, company_id, salary, requirement, workplace, position)
    VALUES (j_title, j_company_id, j_salary, j_requirement, j_workplace, j_position);
    SET job_id = LAST_INSERT_ID();

    RETURN job_id;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE IF NOT EXISTS insertJobBenefit(
    IN b_detail VARCHAR(510),
    IN b_job_id SMALLINT UNSIGNED
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM job_benefit WHERE detail = b_detail AND job_id = b_job_id) THEN
        INSERT INTO job_benefit (detail, job_id) VALUES (b_detail, b_job_id);
    END IF;
END //
DELIMITER ;


DELIMITER //
CREATE FUNCTION IF NOT EXISTS insertSkill(
    s_skill_name VARCHAR(255)
) RETURNS SMALLINT UNSIGNED
BEGIN
    DECLARE skill_id SMALLINT UNSIGNED;

    SELECT id INTO skill_id FROM skill WHERE skill_name = s_skill_name;

    IF skill_id IS NULL THEN
        INSERT INTO skill (skill_name) VALUES (s_skill_name);
        SET skill_id = LAST_INSERT_ID();
    END IF;

    RETURN skill_id;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE IF NOT EXISTS insertJobSkill(
    IN js_job_id SMALLINT UNSIGNED,
    IN js_skill_id SMALLINT UNSIGNED
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM job_skill WHERE job_id = js_job_id AND skill_id = js_skill_id) THEN
        INSERT INTO job_skill (job_id, skill_id) VALUES (js_job_id, js_skill_id);
    END IF;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE IF NOT EXISTS insertCompanyBenefit(
    IN cb_detail VARCHAR(510),
    IN cb_company_id SMALLINT UNSIGNED
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM company_benefit WHERE detail = cb_detail AND company_id = cb_company_id) THEN
        INSERT INTO company_benefit (detail, company_id) VALUES (cb_detail, cb_company_id);
    END IF;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE IF NOT EXISTS insertImage(
    IN img_url VARCHAR(255),
    IN img_company_id SMALLINT UNSIGNED
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM image WHERE url = img_url AND company_id = img_company_id) THEN
        INSERT INTO image (url, company_id) VALUES (img_url, img_company_id);
    END IF;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE IF NOT EXISTS insertCompanySkill(
    IN cs_skill_id SMALLINT UNSIGNED,
    IN cs_company_id SMALLINT UNSIGNED
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM company_skill WHERE skill_id = cs_skill_id AND company_id = cs_company_id) THEN
        INSERT INTO company_skill (skill_id, company_id) VALUES (cs_skill_id, cs_company_id);
    END IF;
END //
DELIMITER ;












