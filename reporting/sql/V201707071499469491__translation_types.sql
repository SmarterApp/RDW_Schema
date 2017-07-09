# modify translation table columns per DWR-529

USE ${schemaName};

#Increasing the size of the columns, but need to shrink the size of the prefix of lable_code that gets indexed
ALTER TABLE translation MODIFY label text, 
	MODIFY label_code varchar(256), 
	DROP INDEX idx__translation__namespace_label_code_language_code,
	ADD UNIQUE INDEX idx__translation__namespace_label_code_language_code (namespace, label_code(241), language_code);
