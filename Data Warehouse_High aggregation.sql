/*
Version 1, level 2
as all tables have been created locally from MonExplore 
during the data cleaning process for easy cleaning,
in this step, we don't retrieve data from MonExplore which may have
dirty data, instead we retrieve data from local tables 
which have been cleaned.
*/
--drop table
drop table agegroupDIM_v1 purge;
drop table partilocDIM_v1 purge;
drop table occupationDIM_v1 purge;
drop table maritalDIM_v1 purge;
drop table subscrtimeDIM_v1 purge;
drop table topicprogrambridge_v1 purge;
drop table programDIM_v1 purge;
drop table topicDIM_v1 purge;
drop table eventsizeDIM_v1 purge;
drop table mediaDIM_v1 purge;
drop table programlengthDIM_v1 purge;
drop table attendtimeDIM_v1 purge;
drop table registimeDIM_v1 purge;


-- create dimension table 
create table agegroupDIM_v1
(agegroup_id number(1), agegroup_name varchar2(50), agegroup_desc varchar2(50));

insert into agegroupDIM_v1 values (1,'Child','0-16 years old');
insert into agegroupDIM_v1 values (2,'Young-aged-adults','17-30 years old');
insert into agegroupDIM_v1 values (3,'Middle-aged-adults','31-45 years old');
insert into agegroupDIM_v1 values (4,'Old-aged-adults','over 45 years old');
select * from agegroupDIM_v1;

create table partilocDIM_v1 as
select address_postcode, address_suburb,address_state from address
order by address_postcode;
select * from partilocDIM_v1;

create table occupationDIM_v1
(occupation_id number(1), occupation_desc varchar(20));
insert into occupationDIM_v1 values (1, 'Student');
insert into occupationDIM_v1 values (2, 'Staff');
insert into occupationDIM_v1 values (3, 'Community');
select * from occupationDIM_v1;


create table maritalDIM_v1 as
select distinct person_marital_status as marital_id from person;
select * from maritalDIM_v1;

create table subscrtimeDIM_v1 as
select distinct to_char(subscription_date,'YYYYMM') as SubscrTimeID,
to_char(subscription_date,'MM') as Month,
to_char(subscription_date,'YYYY') as Year
from subscription
order by to_char(subscription_date,'YYYYMM');
select * from subscrtimeDIM_v1;

create table registimeDIM_v1 as
select distinct to_char(reg_date,'YYYYMM') as registimeID,
to_char(reg_date,'MM') as Month,
to_char(reg_date,'YYYY') as Year
from registration
order by to_char(reg_date,'YYYYMM');
select * from registimeDIM_v1;

create table attendtimeDIM_v1 as
select distinct to_char(att_date,'YYYYMM') as attendtimeID,
to_char(att_date,'MM') as Month,
to_char(att_date,'YYYY') as Year
from attendance
order by to_char(att_date,'YYYYMM');
select * from attendtimeDIM_v1;

create table topicprogrambridge_v1 as
select distinct topic_id,program_id from program
order by topic_id,program_id;
select * from topicprogrambridge_v1;

create table programDIM_v1 as
select program_id,program_name,program_details,
program_fee,program_frequency from program
order by program_id;
select * from programDIM_v1;

create table topicDIM_v1 as 
select * from topic
order by topic_id;
select * from topicDIM_v1;

create table eventsizeDIM_v1
(eventsize varchar(20), sizedesc varchar(50));
insert into eventsizeDIM_v1 values ('small event', 'less than 10 people');
insert into eventsizeDIM_v1 values ('medium event', 'between 11 and 30 people');
insert into eventsizeDIM_v1 values ('large event', 'more than 30 people');
select * from eventsizeDIM_v1;

create table mediaDIM_v1 as 
select * from media_channel
order by media_id;
select * from mediaDIM_v1;

create table programlengthDIM_v1
(programlength_id varchar(20), programlength_desc varchar(50));
insert into programlengthDIM_v1 values ('small', 'less than 3 sessions');
insert into programlengthDIM_v1 values ('medium', 'between 3 and 6 sessions');
insert into programlengthDIM_v1 values ('large', 'more than 6 sessions');
select * from programlengthDIM_v1;

--create interestfact_v1
create table tempinterestfact_v1 as
select pi.topic_id, p.person_age,a.address_postcode,p.person_job,p.person_marital_status
from person_interest pi,person p, address a
where pi.person_id = p.person_id
and p.address_id = a.address_id;

alter table tempinterestfact_v1
add (agegroup_id number(1));
update tempinterestfact_v1
set agegroup_id = 1
where person_age >= 0 and person_age <= 16;
update tempinterestfact_v1
set agegroup_id = 2
where person_age >= 17 and person_age <= 30;
update tempinterestfact_v1
set agegroup_id = 3
where person_age >= 31 and person_age <= 45;
update tempinterestfact_v1
set agegroup_id = 4
where person_age >= 46;

alter table tempinterestfact_v1
add (occupation_id number(1));
update tempinterestfact_v1
set occupation_id = 1
where person_job = 'Student';
update tempinterestfact_v1
set occupation_id = 2
where person_job = 'Staff';
update tempinterestfact_v1
set occupation_id = 3
where person_job not in ('Student', 'Staff');

select * from tempinterestfact_v1;

create table interestfact_v1 as
select topic_id,agegroup_id,address_postcode,occupation_id,
person_marital_status as maritalID,
count(*)as Num_of_people_interested
from tempinterestfact_v1
group by topic_id, agegroup_id,address_postcode,occupation_id,person_marital_status
order by topic_id;
select * from interestfact_v1;

--create SubscrFACT_v1
create table tempSubscrFACT_v1 as
select pr.topic_id, s.program_id,substr(pr.program_length,1,2) as program_length,
to_char(s.subscription_date,'YYYYMM') as SubscrTimeID,
p.person_age,a.address_postcode,p.person_job,p.person_marital_status
from subscription s, program pr,person p, address a
where s.person_id = p.person_id
and p.address_id = a.address_id
and s.program_id = pr.program_id;

alter table tempSubscrFACT_v1 
add (programlength_id varchar2(20));
update tempSubscrFACT_v1
set programlength_id = 'short'
where program_length < 3;
update tempSubscrFACT_v1
set programlength_id = 'medium'
where program_length >= 3 and program_length <= 6;
update tempSubscrFACT_v1
set programlength_id = 'long'
where program_length > 6;

alter table tempSubscrFACT_v1
add (agegroup_id number(1));
update tempSubscrFACT_v1
set agegroup_id = 1
where person_age >= 0 and person_age <= 16;
update tempSubscrFACT_v1
set agegroup_id = 2
where person_age >= 17 and person_age <= 30;
update tempSubscrFACT_v1
set agegroup_id = 3
where person_age >= 31 and person_age <= 45;
update tempSubscrFACT_v1
set agegroup_id = 4
where person_age >= 46;

alter table tempSubscrFACT_v1
add (occupation_id number(1));
update tempSubscrFACT_v1
set occupation_id = 1
where person_job = 'Student';
update tempSubscrFACT_v1
set occupation_id = 2
where person_job = 'Staff';
update tempSubscrFACT_v1
set occupation_id = 3
where person_job not in ('Student', 'Staff');

select * from tempSubscrFACT_v1;

create table SubscrFACT_v1 as
select topic_id,program_id,programlength_id,SubscrTimeID,agegroup_id,
address_postcode,occupation_id,
person_marital_status as maritalID, 
count(*) as Num_of_people_subscribed
from tempSubscrFACT_v1
group by topic_id,program_id,programlength_id,SubscrTimeID,agegroup_id,
address_postcode,occupation_id,
person_marital_status
order by topic_id,program_id,programlength_id,SubscrTimeID,agegroup_id,
address_postcode,occupation_id,
person_marital_status;
select * from SubscrFACT_v1;
--create AttendFACT_v1
create table tempAttendFACT_v1 as
select pr.topic_id, e.program_id,substr(pr.program_length,1,2) as program_length,e.event_size,
to_char(at.att_date,'YYYYMM') as attendtimeID,
p.person_age,a.address_postcode,p.person_job,p.person_marital_status,
at.ATT_NUM_OF_PEOPLE_ATTENDED as Num_of_people_attended,
at.ATT_DONATION_AMOUNT as Total_Donate
from attendance at,event e,program pr,person p, address a
where at.person_id = p.person_id
and p.address_id = a.address_id
and at.event_id = e.event_id
and e.program_id = pr.program_id;

alter table tempAttendFACT_v1 
add (programlength_id varchar2(20));
update tempAttendFACT_v1
set programlength_id = 'short'
where program_length < 3;
update tempAttendFACT_v1
set programlength_id = 'medium'
where program_length >= 3 and program_length <= 6;
update tempAttendFACT_v1
set programlength_id = 'long'
where program_length > 6;

alter table tempAttendFACT_v1
add (agegroup_id number(1));
update tempAttendFACT_v1
set agegroup_id = 1
where person_age >= 0 and person_age <= 16;
update tempAttendFACT_v1
set agegroup_id = 2
where person_age >= 17 and person_age <= 30;
update tempAttendFACT_v1
set agegroup_id = 3
where person_age >= 31 and person_age <= 45;
update tempAttendFACT_v1
set agegroup_id = 4
where person_age >= 46;

alter table tempAttendFACT_v1
add (occupation_id number(1));
update tempAttendFACT_v1
set occupation_id = 1
where person_job = 'Student';
update tempAttendFACT_v1
set occupation_id = 2
where person_job = 'Staff';
update tempAttendFACT_v1
set occupation_id = 3
where person_job not in ('Student', 'Staff');

alter table tempAttendFACT_v1
add (eventsize varchar(20));
update tempAttendFACT_v1
set eventsize = 'small event'
where event_size <= 10;
update tempAttendFACT_v1
set eventsize = 'medium event'
where event_size > 10 and event_size <= 30;
update tempAttendFACT_v1
set eventsize = 'large event'
where event_size > 30;

select * from tempAttendFACT_v1;

create table AttendFACT_v1 as
select topic_id,program_id,programlength_id,eventsize,attendtimeID,agegroup_id,
address_postcode,occupation_id,
person_marital_status as maritalID, 
sum(Num_of_people_attended)as Num_of_people_attended,
sum(Total_Donate) as Total_Donate
from tempAttendFACT_v1
group by topic_id,program_id,programlength_id,eventsize,attendtimeID,agegroup_id,
address_postcode,occupation_id,
person_marital_status
order by topic_id,program_id,programlength_id,eventsize,attendtimeID,agegroup_id,
address_postcode,occupation_id,
person_marital_status;
select * from AttendFACT_v1;

--RegisFACT
create table tempRegisFACT_v1 as
select pr.topic_id, e.program_id,substr(pr.program_length,1,2) as program_length,
e.event_size,
to_char(r.reg_date,'YYYYMM') as registimeID,
r.media_id,
p.person_age,a.address_postcode,p.person_job,p.person_marital_status,
r.REG_NUM_OF_PEOPLE_REGISTERED as Num_of_people_registered
from registration r, event e,program pr,person p, address a
where r.person_id = p.person_id
and p.address_id = a.address_id
and r.event_id = e.event_id
and e.program_id = pr.program_id;

alter table tempRegisFACT_v1 
add (programlength_id varchar2(20));
update tempRegisFACT_v1
set programlength_id = 'short'
where program_length < 3;
update tempRegisFACT_v1
set programlength_id = 'medium'
where program_length >= 3 and program_length <= 6;
update tempRegisFACT_v1
set programlength_id = 'long'
where program_length > 6;

alter table tempRegisFACT_v1
add (agegroup_id number(1));
update tempRegisFACT_v1
set agegroup_id = 1
where person_age >= 0 and person_age <= 16;
update tempRegisFACT_v1
set agegroup_id = 2
where person_age >= 17 and person_age <= 30;
update tempRegisFACT_v1
set agegroup_id = 3
where person_age >= 31 and person_age <= 45;
update tempRegisFACT_v1
set agegroup_id = 4
where person_age >= 46;

alter table tempRegisFACT_v1
add (occupation_id number(1));
update tempRegisFACT_v1
set occupation_id = 1
where person_job = 'Student';
update tempRegisFACT_v1
set occupation_id = 2
where person_job = 'Staff';
update tempRegisFACT_v1
set occupation_id = 3
where person_job not in ('Student', 'Staff');

alter table tempRegisFACT_v1
add (eventsize varchar(20));
update tempRegisFACT_v1
set eventsize = 'small event'
where event_size <= 10;
update tempRegisFACT_v1
set eventsize = 'medium event'
where event_size > 10 and event_size <= 30;
update tempRegisFACT_v1
set eventsize = 'large event'
where event_size > 30;

select * from tempRegisFACT_v1;

create table RegisFACT_v1 as
select topic_id,program_id,programlength_id,eventsize,registimeID,media_id,agegroup_id,
address_postcode,occupation_id,
person_marital_status as maritalID, 
sum(Num_of_people_registered)as Num_of_people_registered
from tempRegisFACT_v1
group by topic_id,program_id,programlength_id,eventsize,registimeID,media_id,agegroup_id,
address_postcode,occupation_id,
person_marital_status
order by topic_id,program_id,programlength_id,eventsize,registimeID,media_id,agegroup_id,
address_postcode,occupation_id,
person_marital_status;
select * from RegisFACT_v1;