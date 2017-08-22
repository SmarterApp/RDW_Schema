-- Load extracted records from CSV

use legacy_load;

LOAD DATA FROM S3 's3://rdw-migrate/extract_dim_student.csv'
INTO TABLE dim_student
FIELDS TERMINATED BY ',' IGNORE 1 LINES
(student_rec_id, student_id, external_student_id, first_name, middle_name, last_name, birthdate, sex, group_1_id, group_1_text, group_2_id, group_2_text, group_3_id, group_3_text, group_4_id, group_4_text, group_5_id, group_5_text, group_6_id, group_6_text, group_7_id, group_7_text, group_8_id, group_8_text, group_9_id, group_9_text, group_10_id, group_10_text, @eth_derived, @eth_hsp, @eth_ami, @eth_asn, @eth_blk, @eth_pcf, @eth_wht, @eth_2om, @prg_iep, @prg_lep, @prg_504, @sts_ecd, @sts_mig, from_date, to_date, rec_status, batch_guid)
SET warehouse_load_id = 1,
  dmg_eth_derived := IF(@eth_derived IS NULL OR @eth_derived = '', NULL, @eth_derived),
  dmg_eth_hsp := @eth_hsp = 't',
  dmg_eth_ami := @eth_ami = 't',
  dmg_eth_asn := @eth_asn = 't',
  dmg_eth_blk := @eth_blk = 't',
  dmg_eth_pcf := @eth_pcf = 't',
  dmg_eth_wht := @eth_wht = 't',
  dmg_eth_2om := @eth_2om = 't',
  dmg_prg_iep := @prg_iep = 't',
  dmg_prg_lep := @prg_lep = 't',
  dmg_prg_504 := @prg_504 = 't',
  dmg_sts_ecd := @sts_ecd = 't',
  dmg_sts_mig := (CASE @sts_mig WHEN 't' THEN 1 WHEN 'f' THEN 0 ELSE NULL END);

# first run, without any conversions:
# Query OK, 2333216 rows affected, 65535 warnings (2 min 16.08 sec)
# Records: 2333216  Deleted: 0  Skipped: 0  Warnings: 30207520
# delete from dim_student;
# Query OK, 2333216 rows affected (1 min 27.78 sec)

# after conversions in place:
# Query OK, 2333216 rows affected (3 min 41.23 sec)
# Records: 2333216  Deleted: 0  Skipped: 0  Warnings: 0

