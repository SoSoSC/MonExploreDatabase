/*--Version 2, level 0
as all tables have been created locally from MonExplore 
during the data cleaning process for easy cleaning,
in this step, we don't retrieve data from MonExplore which may have
dirty data, instead we retrieve data from local tables 
which have been cleaned.
*/
/*
drop table TopicDIM_v2 purge;
drop table AddressDIM_v2 purge;
drop table PersonDIM_v2 purge;
drop table TopicProgramBridge_v2 purge;
drop table ProgramDIM_v2 purge;
drop table EventDIM_v2 purge;
drop table MediaDIM_v2 purge;
drop table VolunteerDIM_v2 purge;
drop table SubscrTimeDIM_v2 purge;
drop table RegisTimeDIM_v2 purge;
drop table AttendTimeDIM_v2 purge;

drop table InterestFACT_v2 purge;
drop table SubscrFACT_v2 purge;
drop table AttendFACT_v2 purge;
drop table RegisFACT_v2 purge;
*/
--create dimension tables
create table TopicDIM_v2 as
select * from Topic
order by topic_id;
select * from TopicDIM_v2;

create table AddressDIM_v2 as
select * from Address
order by address_id;
select * from AddressDIM_v2;

create table PersonDIM_v2 as
select person_id,person_name,person_age,person_phone,person_email,
person_job,person_marital_status,person_gender from Person
order by person_id;
select * from PersonDIM_v2;

create table TopicProgramBridge_v2 as
select distinct topic_id,program_id from program
order by topic_id,program_id;
select * from TopicProgramBridge_v2;

create table ProgramDIM_v2 as
select program_id,program_name,program_details,
program_fee,program_length,program_frequency from program
order by program_id;
select * from ProgramDIM_v2;

create table EventDIM_v2 as
select event_id,
to_char(event_start_date,'DD/MON/YYYY') as event_start_date,
to_char(event_end_date,'DD/MON/YYYY') as event_end_date,
event_size,event_location,event_cost from event
order by event_id;
select * from EventDIM_v2;

create table MediaDIM_v2 as
select * from media_channel
order by media_id;
select * from MediaDIM_v2;

create table VolunteerDIM_v2 as
select person_id,
to_char(vol_start_date,'DD/MON/YYYY') as vol_start_date,
to_char(vol_end_date,'DD/MON/YYYY') as vol_end_date,vol_description 
from volunteer
order by person_id,vol_start_date;
select * from VolunteerDIM_v2;

create table SubscrTimeDIM_v2 as
select subscription_id, 
to_char(subscription_date,'DD/MON/YYYY') as subscription_date 
from subscription
order by subscription_id;
select * from SubscrTimeDIM_v2;

create table RegisTimeDIM_v2 as
select reg_id as registration_id, 
to_char(reg_date,'DD/MON/YYYY') as registration_date 
from registration
order by reg_id;
select * from RegisTimeDIM_v2;

create table AttendTimeDIM_v2 as
select att_id as attendance_id, 
to_char(att_date,'DD/MON/YYYY') as attendance_date 
from attendance
order by att_id;
select * from AttendTimeDIM_v2;

--create fact tables
create table InterestFACT_v2 as
select
pi.topic_id,pi.person_id,p.address_id
from person_interest PI,person P
where PI.person_id = P.person_id
order by pi.topic_id,pi.person_id; 
select * from InterestFACT_v2;

create table SubscrFACT_v2 as
select
s.subscription_id,s.program_id,s.person_id,p.address_id
from subscription s,person p
where s.person_id = p.person_id
order by s.subscription_id,s.program_id,s.person_id; 
select * from SubscrFACT_v2;

create table AttendFACT_v2 as
select
a.att_id as attendence_id,a.event_id,a.person_id,p.address_id,
a.att_num_of_people_attended as num_of_people_attended,
a.att_donation_amount as Total_Donate
from attendance a,person p
where a.person_id = p.person_id
order by a.att_id,a.event_id,a.person_id; 
select * from AttendFACT_v2;

create table RegisFACT_v2 as
select
ri.reg_id as registration_id, ri.event_id,ri.media_id,
ri.person_id,p.address_id,
ri.reg_num_of_people_registered as num_of_people_registered
from registration ri, person p
where ri.person_id = p.person_id
order by ri.reg_id,ri.event_id,ri.media_id,ri.person_id; 
select * from RegisFACT_v2;
