/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

select name from Facilities
where membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */

select count(name) as no_of_free_facilities_for_members from Facilities
where membercost = 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

select facid, name, membercost, monthlymaintenance from Facilities
where membercost < (monthlymaintenance * 0.2)
and membercost > 0;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

select * from Facilities
where facid in (1, 5);

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

select name, monthlymaintenance,
case when monthlymaintenance > 100 then 'expensive'
else 'cheap' end as category
from Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

select firstname, surname from Members
where joindate = (select max(joindate) from Members);

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

select distinct concat_ws(' ', firstname, surname) as fullname, f.name as tennis_court
from Members as m
join Bookings as b
on m.memid = b.memid
join Facilities as f
on b.facid = f.facid
where f.name like 'Tennis%'
order by fullname;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

select f.name, concat_ws(' ', firstname, surname) as fullname,
case when m.memid = 0 then (f.guestcost * b.slots)
else (f.membercost * b.slots) end as cost
from Bookings as b
join Facilities as f
on b.facid = f.facid
join Members as m
on b.memid = m.memid
where date(starttime) = '2012-09-14'
and b.memid = 0
and (f.guestcost * b.slots) > 30
or date(starttime) = '2012-09-14'
and b.memid != 0
and (f.membercost * b.slots) > 30
order by cost desc;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

select f.name, concat_ws(' ', firstname, surname) as fullname,
case when m.memid = 0 then (f.guestcost * b.slots)
else (f.membercost * b.slots) end as cost
from Bookings as b
join Facilities as f
on b.facid = f.facid
join Members as m
on b.memid = m.memid
where date(starttime) = '2012-09-14'
and b.memid = 0
and (f.guestcost * b.slots) > 30
or date(starttime) = '2012-09-14'
and b.memid != 0
and (f.membercost * b.slots) > 30
order by cost desc;

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

select * from
(select f.name, (sum(membercost * slots) + sum(guestcost* slots)) as revenue
from Facilities as f
join Bookings as b 
on f.facid = b.facid
group by f.name) as subq
where revenue < 1000;

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

select m1.surname, m1.firstname, concat_ws(' ', m2.surname, m2.firstname) as recommender from Members m1, Members m2
where m2.memid = m1.recommendedby
order by m1.surname, m1.firstname;

/* Q12: Find the facilities with their usage by member, but not guests */

select f.name, count(b.facid) from Bookings as b
join Facilities as f
on b.facid = f.facid
where memid != 0
group by b.facid;

/* Q13: Find the facilities usage by month, but not guests */

select month(starttime), f.name, count(b.facid) from Bookings as b
join Facilities as f
on b.facid = f.facid
where memid != 0
group by month(starttime), f.name;