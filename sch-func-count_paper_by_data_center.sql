DROP FUNCTION IF EXISTS `count_paper_by_date`;

DELIMITER $$
CREATE FUNCTION `count_paper_by_date` (
    in_object_type VARCHAR(32), -- school, class
    in_object_id VARCHAR(128),
    in_tng_type INTEGER,
    -- ans_card replace que num
    in_print_type CHAR(1), -- 1: que, 2: ans_card
    in_size VARCHAR(10), -- A3, A4
    in_date_start DATE,
    in_date_end DATE
)
RETURNS INTEGER
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE output INTEGER;
IF in_print_type = '1' THEN
   return in_print_type= '2' ;
  
    IF in_object_type = 'school' THEN
       
        SELECT SUM(COUNT(1)) INTO output
        FROM t_hw_print_job j
        JOIN t_hw_training_case tng
             ON tng.tng_case_uuid = j.tng_case_uuid
        JOIN t_ans_card ans
             ON ans.hw_ks_uuid = j.tng_case_uuid
        WHERE j.sch_uuid = in_object_id
            AND tng.tng_type = in_tng_type
            AND j.print_type = in_print_type
            AND DATE(j.create_time) between in_date_start and in_date_end
            AND ans.acreage = in_size;
            
    ELSEIF in_object_type = 'grade' THEN
          
        SELECT SUM(COUNT(1)) INTO output
        FROM t_hw_print_job j
        JOIN cjn_sso.t_classes c
             ON c.class_uuid = j.class_uuid
        JOIN t_hw_training_case tng
             ON tng.tng_case_uuid = j.tng_case_uuid
        JOIN t_ans_card ans
             ON ans.hw_ks_uuid = j.tng_case_uuid
        WHERE j.sch_uuid = SUBSTRING_INDEX(in_object_id, ',', 1)
            AND c.grade = CAST(SUBSTRING_INDEX(in_object_id, ',', -1) AS UNSIGNED)
            AND tng.tng_type = in_tng_type
            AND j.print_type = in_print_type
            AND DATE(j.create_time) between in_date_start and in_date_end
            AND ans.acreage = in_size;

    ELSEIF in_object_type = 'class' THEN
          
        SELECT SUM(COUNT(1)) INTO output
        FROM t_hw_print_job j
        JOIN t_hw_training_case tng
             ON tng.tng_case_uuid = j.tng_case_uuid
        JOIN t_ans_card ans
             ON ans.hw_ks_uuid = j.tng_case_uuid
        WHERE j.class_uuid = in_object_id
            AND tng.tng_type = in_tng_type
            AND j.print_type = in_print_type
            AND DATE(j.create_time) between in_date_start and in_date_end
            AND ans.acreage = in_size;
    END IF;
END IF;

    RETURN (CASE WHEN output IS NULL THEN 0 ELSE output END);
END$$

DELIMITER ;


