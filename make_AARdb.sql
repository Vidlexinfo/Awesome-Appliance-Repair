CREATE DATABASE AARdb
  DEFAULT CHARACTER SET utf8;

USE AARdb;


CREATE TABLE `customer` (
    `cid` mediumint NOT NULL auto_increment,
    `fname` varchar(20),
    `lname` varchar(20) NOT NULL,
    `address` varchar(30),
    `city` varchar(30),
    `state` char(2),
    `zip` mediumint,
    `phone` char(12),
    primary key(cid)
) ENGINE=InnoDB;


CREATE TABLE `users` (
    `uname` varchar(8) NOT NULL,
    `cid` mediumint,
    `role` varchar(20) NOT NULL,
    `pw` varchar(40) NOT NULL,
    primary key(uname),
    foreign key(cid) references customer(cid)
) ENGINE=InnoDB;

CREATE TABLE `jobs` (
    `j_ip` varchar(20),
    `j_port` mediumint,
    `j_id` mediumint NOT NULL AUTO_INCREMENT,
    `cid` mediumint,
    `make` varchar(30),
    `appliance` char(30),
    `appointment` date,
    `job_status` enum('pending','completed'),
    `description` varchar(140),
    PRIMARY KEY (j_id),
    foreign key(cid) references customer(cid)
) ENGINE=InnoDB;

ALTER TABLE jobs auto_increment=100;

insert into customer (fname,lname,address,city,state,zip,phone) values
    ('Mary', 'Brown', '4531 Hawthorn', 'Centerville', 'PA', '28634', '234-555-4399'),
    ('John', 'Smith', '6296 Plum', 'Arlington', 'AR', '22041', '809-555-7189'),
    ('Robert', 'Lambright', '1286 Willow', 'Salem', 'AR', '24226', '758-555-6579'),
    ('Chandra', 'Asam', '325 Spruce', 'Manchester', 'SD', '12204', '303-555-5006'),
    ('James', 'McNiel', '3575 Walnut', 'Jackson', 'NY', '66044', '412-555-2351'),
    ('Spencer', 'Nasem', '1826 Birch', 'Lexington', 'NJ', '04942', '671-555-6544'),
    ('Christian', 'Serda', '2122 Birch', 'Dover', 'NM', '30434', '858-555-5659'),
    ('Joseph', 'Crosley', '5081 Tulip', 'Greenville', 'NE', '96034', '516-555-2904'),
    ('Sandra', 'Edridge', '8917 Lilac', 'Franklin', 'RI', '17062', '972-555-9010'),
    ('Felipa', 'Elsey', '1685 Pawpaw', 'Greenville', 'LA', '04942', '813-555-4748'),
    ('Marsha', 'Mulhollen', '9335 Hazel', 'Newport', 'AZ', '89803', '614-555-6941'),
    ('Leslie', 'Balitas', '7638 Buckeye', 'Lexington', 'ND', '37079', '872-555-2202'),
    ('Mark', 'Gustison', '5383 Redbud', 'Auburn', 'NJ', '16375', '919-555-5086'),
    ('Teresa', 'Deutsch', '6362 Birch', 'Georgetown', 'MI', '96034', '709-555-6338'),
    ('Katelyn', 'Gerst', '3418 Aspen', 'Centerville', 'SD', '02163', '938-555-9142'),
    ('Wanda', 'Varnell', '9674 Fir', 'Burlington', 'ME', '28634', '573-555-2084'),
    ('Bree', 'Bjorklund', '5670 Catalpa', 'Jackson', 'NM', '24076', '947-555-5635'),
    ('Hank', 'Imming', '824 Catalpa', 'Jackson', 'VT', '66720', '682-555-8637'),
    ('Siu', 'Chong', '4916 Buckeye', 'Clinton', 'RI', '02904', '204-555-7901'),
    ('Michelle', 'Schartz', '2152 Cottonwood', 'Milford', 'TX', '98166', '268-555-6167'),
    ('Karie', 'Elldrege', '8450 Aspen', 'Marion', 'NC', '05152', '541-555-8377'),
    ('Jeffry', 'Bolte', '1083 Crabapple', 'Centerville', 'KS', '30434', '815-555-5037'),
    ('Dalia', 'Castle', '9560 Palm', 'Georgetown', 'IA', '02904', '816-555-9330'),
    ('Angel', 'Rodriquez', '4439 Tupelo', 'Dayton', 'KY', '22041', '970-555-9433'),
    ('Eleanor', 'Stevick', '1601 Birch', 'Auburn', 'OH', '85942', '289-555-8844'),
    ('Rita', 'Zulkowski', '2995 Alder', 'Dayton', 'PA', '22907', '850-555-6438'),
    ('Brian', 'Borsos', '1728 Filbert', 'Centerville', 'WA', '43119', '217-555-1776'),
    ('Hayden', 'Tourtellotte', '7306 Tupelo', 'Jackson', 'MN', '16375', '762-555-8919'),
    ('Astrid', 'Tardio', '225 Tamarack', 'Auburn', 'MT', '43119', '971-555-9385'),
    ('Agatha', 'Trench', '9593 Holly', 'Franklin', 'ND', '15642', '708-555-4531');

insert into jobs (j_ip,j_port,cid, make, appliance, appointment, job_status, description) values
    ('localhost',9229,1,'maytag','washer', null, 'pending', "outflow hoses leak"),
    ('localhost',9229,2,'GE','refrigerator', '2013-11-05', 'completed', "Ices up; won't defrost");

# notes

# for multiple column primary key, can't use autoincrement. Job Id's will be generated in the code.

# ALTER TABLE Orders
# ADD FOREIGN KEY (P_Id)
# REFERENCES Persons(P_Id)

# ALTER TABLE jobs add column tid mediumint, add foreign key(tid) references tech(tid);
# SELECT j.jid, c.cid, c.lname, j.make, j.appliance, j.job_status, j.appointment, j.description
# FROM jobs j, customer c
# WHERE j.cid = c.cid;

insert into jobs (j_ip,j_port,cid, make, appliance, appointment, job_status, description) values
    ('000.000.000.000',8080,3,'Maytag','Washer', null, 'pending', "outflow hoses leak"),
    ('000.000.000.000',8080,4,'GE','Refrigerator', '2013-11-01', 'completed', "Ices up; won't defrost"),
    ('000.000.000.000',8080,5,'Alessi','Teapot', null, 'pending', "explodes"),
    ('000.000.000.000',8080,6,'Amana','Range', '2013-11-02', 'completed', "oven heats unevenly"),
    ('000.000.000.000',8080,7,'Whirlpool','Refrigerator', '2013-11-03', 'pending', "Makes a rattling noise"),
    ('000.000.000.000',8080,8,'GE','Microwave', '2013-11-04', 'pending', "Sparks and smokes when I put forks in it"),
    ('000.000.000.000',8080,9,'Maytag','Drier', null, 'pending', "Never heats up"),
    ('000.000.000.000',8080,10,'Amana','Refrigerator', '2013-11-05', 'pending', "Temperature too low, can't adjust."),
    ('000.000.000.000',8080,11,'Samsung','Washer', null, 'pending', "Doesn't get my bear suit white"),
    ('000.000.000.000',8080,12,'Frigidaire','Refrigerator', '2013-11-06', 'completed', "Has a bad smell I can't get rid of."),
    ('000.000.000.000',8080,13,'In-Sink-Erator','Dispose-all', null, 'pending', "blades broken"),
    ('000.000.000.000',8080,14,'KitchenAid','Mixer', '2013-11-07', 'completed', "Blows my fuses"),
    ('000.000.000.000',8080,15,'Moulinex','Juicer', null, 'pending', "Won't start"),
    ('000.000.000.000',8080,16,'Viking','Range', '2013-11-08', 'completed', "Gas leak"),
    ('000.000.000.000',8080,17,'Aga','Range', null, 'pending', "burner cover is cracked"),
    ('000.000.000.000',8080,18,'Jennaire','Cooktop', '2013-11-09', 'completed', "Glass cracked"),
    ('000.000.000.000',8080,19,'Wolfe','Stove', null, 'pending', "Burners are uneven"),
    ('000.000.000.000',8080,20,'LG','Dehumidifier', '2013-11-10', 'pending', "Ices up when external temp is around freezing"),
    ('000.000.000.000',8080,21,'De’Longhi','Oil Space Heater', null, 'pending', "Smells bad"),
    ('000.000.000.000',8080,22,'Kenmore','Refrigerator', '2013-11-11', 'pending', "excessive vibration"),
    ('000.000.000.000',8080,23,'Maytag','Washer/Drier', null, 'pending', "outflow hoses leak"),
    ('000.000.000.000',8080,24,'GE','Refrigerator', '2013-11-12', 'pending', "Refrigerator light is defective"),
    ('000.000.000.000',8080,25,'Kenmore','Washer', null, 'pending', "Unbalanced spin cycle"),
    ('000.000.000.000',8080,26,'Cookmore','Outdoor Grill', '2013-11-13', 'pending', "Smoker box is stuck"),
    ('000.000.000.000',8080,27,'Kenmore','Water heater', null, 'pending', "Can't adjust temperature"),
    ('000.000.000.000',8080,28,'Sanyo','Minifridge', '2013-11-14', 'pending', "Makes a lot of noise"),
    ('000.000.000.000',8080,29,'Bosch','Dishwasher', null, 'pending', "leaves spots on my glases"),
    ('000.000.000.000',8080,30,'Whirlpool','Trash Compactor', '2013-11-15', 'pending', "leaking hydraulic fluid");
