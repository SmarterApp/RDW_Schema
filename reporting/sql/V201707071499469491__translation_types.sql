# modify translation table columns per DWR-529

USE ${schemaName};

# Changing the type of the label column from varchar to text
ALTER TABLE translation MODIFY label text;
