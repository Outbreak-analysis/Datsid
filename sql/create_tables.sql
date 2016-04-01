CREATE TABLE disease (
	id INTEGER PRIMARY KEY ASC,
	parent_id INTEGER REFERENCES disease(id) ON DELETE CASCADE,
	name VARCHAR(128),
	ICD TEXT
);

CREATE TABLE disease_meta (
	id INTEGER PRIMARY KEY ASC,
	disease_id INTEGER REFERENCES disease(id) ON DELETE CASCADE,
	data TEXT
);

CREATE TABLE location (
	id INTEGER PRIMARY KEY ASC,
	parent_id INTEGER REFERENCES location(id) ON DELETE CASCADE,
	name VARCHAR(128),
	latitude DECIMAL(8,6),
	longitude	DECIMAL(9,6)
);

CREATE TABLE "table_epievent" (
	`epievent_id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`disease_id`	INTEGER,
	`location_id`	INTEGER,
	`eventdate`	TEXT,
	`reportdate`	TEXT,
	`count`	INTEGER,
	`eventtype`	TEXT,
	`eventtype2`	TEXT,
	`agemin`	INTEGER,
	`agemax`	INTEGER,
	`gender`	TEXT,
	`socialstruct`	TEXT,
	`synthetic`	INTEGER,
	`source`	TEXT,
	FOREIGN KEY(`disease_id`) REFERENCES `table_disease`(`disease_id`),
	FOREIGN KEY(`location_id`) REFERENCES `table_location`(`location_id`)
);

CREATE TABLE sources (
	id INTEGER PRIMARY KEY ASC,
	name VARCHAR(128) NOT NULL,
	md5sum INTEGER(32)
);

CREATE TABLE epievent (
	`epievent_id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`disease_id`	INTEGER,
	`location_id`	INTEGER,
	`eventdate`	TEXT,
	`reportdate`	TEXT,
	`count`	INTEGER,
	`eventtype`	TEXT,
	`eventtype2`	TEXT,
	`agemin`	INTEGER,
	`agemax`	INTEGER,
	`gender`	TEXT,
	`socialstruct`	TEXT,
	`synthetic`	INTEGER,
	`source`	TEXT,
	FOREIGN KEY(`disease_id`) REFERENCES `table_disease`(`disease_id`),
	FOREIGN KEY(`location_id`) REFERENCES `table_location`(`location_id`)
);