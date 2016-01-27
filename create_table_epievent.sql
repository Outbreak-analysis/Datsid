CREATE TABLE `table_epievent_tmp`(
	`epievent_id`	INTEGER,
	`eventdate`	TEXT,
	`reportdate`	TEXT,
	`count`	INTEGER,
	`eventtype`	TEXT,
	`eventtype2`	TEXT,
	`agemin`	INTEGER,
	`agemax`	NUMERIC,
	`gender`	TEXT,
	`socialstruct`	TEXT,
	`disease_id`	INTEGER,
	`location_id`	INTEGER,
	`synthetic`	INTEGER,
	PRIMARY KEY(epievent_id),
	FOREIGN KEY(disease_id) REFERENCES table_disease(disease_id),
	FOREIGN KEY(location_id) REFERENCES table_location(location_id)
	);