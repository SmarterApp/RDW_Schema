-- Replace the UNIQUE INDEX on the translation table with a primary key

USE ${schemaName};

ALTER TABLE translation
  ADD PRIMARY KEY (namespace, label_code, language_code),
  DROP INDEX idx__translation__namespace_label_code_language_code;
