CREATE TABLE "table_disease" (
	`disease_id`	INTEGER,
	`disease_name`	TEXT,
	`disease_ICD`	TEXT,
	`disease_type`	TEXT,
	`disease_subtype`	TEXT,
	`disease_subtype2`	TEXT,
	PRIMARY KEY(disease_id)
);

CREATE TABLE "table_location" (
	`location_id`	INTEGER,
	`country`	TEXT,
	`adminDiv1`	TEXT,
	`adminDiv2`	TEXT,
	`adminDiv3`	TEXT,
	`adminDiv4`	TEXT,
	`latitude`	TEXT,
	`longitude`	TEXT,
	PRIMARY KEY(location_id)
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

CREATE TABLE "tmp_epievent" (
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