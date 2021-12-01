--we assume dirty data can appear in any table 
--thus create tables locally for easy cleaning.
create table topic as 
select * from monexplore.topic;
create table program as 
select * from MonExplore.program;
create table event as 
select * from MonExplore.event;
create table media_channel as 
select * from MonExplore.media_channel;
create table event_marketing as 
select * from MonExplore.event_marketing;
create table newperson as 
select * from MonExplore.person;
create table volunteer as 
select * from MonExplore.volunteer;
create table address as 
select * from MonExplore.address;
create table participant as 
select * from MonExplore.participant;
create table follow_up as 
select * from MonExplore.follow_up;
create table person_interest as 
select * from MonExplore.person_interest;
create table newsubscription as 
select * from MonExplore.subscription;
create table attendance as 
select * from MonExplore.attendance;
create table registration as 
select * from MonExplore.registration;
--end of create
--1. Duplicate record in table MonExplore.SUBSCRIPTION  
--1.1 explore
select subscription_id, count(*)
from MonExplore.SUBSCRIPTION
group by subscription_id
having count(*) > 1;
--examine before cleaning
select subscription_id, count(*)
from MonExplore.SUBSCRIPTION 
group by subscription_id
order by count(*) desc;
--or
select * from MonExplore.SUBSCRIPTION 
where subscription_id = 'SU021' or subscription_id = 'SU243'
ORDER BY subscription_id;
--1.2 cleaning
create table subscription as
select distinct *
from MonExplore.SUBSCRIPTION;
--examine after cleaning
select subscription_id, count(*)
from subscription
group by subscription_id
order by count(*) desc;
--or
select subscription_id, count(*)
from SUBSCRIPTION
group by subscription_id
having count(*) > 1;
--2.1 explore
select person_id,count (*) 
from MONEXPLORE.person
group by person_id
having count(*) > 1;
--2.2 cleanning
create table person as
select distinct * 
from Monexplore.person;

select person_id,count (*) 
from person
group by person_id
having count(*) > 1;
-- 2 end

--3.1 explore
select count(*)
from MONEXPLORE.event
where event_size < 0;

select *
from MONEXPLORE.event
where event_size < 0;
--3.2 cleaning

--create table event as 
--select * from MonExplore.event;

delete  
from event
where event_size < 0;
-- after cleaning
select count(*)
from event
where event_size < 0;
-- end of 3
select count(*)
from MONEXPLORE.event
where event_cost < 0;
-- 
describe topic;
-- 4.1 explore
select count(*)
from Monexplore.attendance
where att_donation_amount < 0;

select *
from Monexplore.attendance
where att_donation_amount < 0;
--cleanning

--create table attendance as 
--select * from MonExplore.attendance;

delete 
from attendance
where att_donation_amount < 0;

select count(*)
from attendance
where att_donation_amount < 0;
--end of 4
-- 5.1 exp
select *
from Monexplore.event
where program_id not in
  (select program_id
   from program);
--cleaning

--create table event as 
--select * from MonExplore.event;

delete 
from event
where program_id not in
  (select program_id
   from program);
--after
select *
from event
where program_id not in
  (select program_id
   from program);
--6 explore
select *
from Monexplore.volunteer
where person_id not in
  (select person_id
   from person);

--cleaning

--create table volunteer as 
--select * from MonExplore.volunteer;

delete
from volunteer
where person_id not in
  (select person_id
   from person);
   
--after
select *
from volunteer
where person_id not in
  (select person_id
   from person);
-- 7.1 explore
select *
from Monexplore.event
where to_date(event_start_date)> to_date(event_end_date);

--cleaning

--create table event as 
--select * from MonExplore.event;

delete
from event
where to_date(event_start_date)> to_date(event_end_date);
--after
select *
from event
where to_date(event_start_date)> to_date(event_end_date);
-- end of 7
--explore 8.1
select *
from Monexplore.volunteer
where to_date(vol_start_date) > to_date(vol_end_date);
--cleaning

--create table volunteer as 
--select * from MonExplore.volunteer;

delete
from volunteer
where to_date(vol_start_date) > to_date(vol_end_date);

select *
from volunteer
where to_date(vol_start_date) > to_date(vol_end_date);
--end of 8

select *
from Monexplore.address
where address_id not in
  (select address_id
  from Monexplore.person);
  
select *
from Monexplore.program
where topic_id not in
  (select topic_id
  from Monexplore.topic);
--  9.1 explore
select *
from(
select a.att_id, a.att_date, e.event_start_date, e.event_end_date
from Monexplore.attendance a, Monexplore.event e
where a.event_id = e.event_id)
where to_date(att_date) > to_date(event_end_date);
--clean
delete
from attendance
where att_id in
(
select att_id
from(
select a.att_id, a.att_date, e.event_start_date, e.event_end_date
from Monexplore.attendance a, Monexplore.event e
where a.event_id = e.event_id)
where to_date(att_date) > to_date(event_end_date));
--after
select *
from(
select a.att_id, a.att_date, e.event_start_date, e.event_end_date
from attendance a, event e
where a.event_id = e.event_id)
where to_date(att_date) > to_date(event_end_date);
--end of 9

-- 10.1 explore
select * 
from Monexplore.media_channel
where media_id is null;
--cleaning

--create table media_channel as 
--select * from MonExplore.media_channel;

delete 
from media_channel
where media_id is null;
--after
select * 
from media_channel
where media_id is null;

--end of 10

   



