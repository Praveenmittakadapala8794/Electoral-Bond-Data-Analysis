Use electoralbonddata;

SELECT * FROM bankdata;

SELECT * FROM bonddata;

SELECT * FROM donordata;

SELECT * FROM receiverdata;

/* 1. Find out how much donors spent on bonds */

SELECT d.Purchaser,SUM(b.Denomination) 
FROM donordata AS d
LEFT JOIN bonddata AS b
ON d.Unique_key = b.Unique_key
GROUP BY 1
ORDER BY 2 DESC;


-- 2. Find out total fund politicians got

SELECT r.PartyName,SUM(b.Denomination)
FROM receiverdata AS r
LEFT JOIN bonddata AS b
ON r.Unique_key = b.Unique_key
GROUP BY 1
ORDER BY 2 DESC;


-- 3. Find out the total amount of unaccounted money received by parties

SELECT r.PartyName, SUM(b.Denomination) AS total_unaccounted_money
FROM receiverdata AS r
LEFT JOIN donordata AS d
ON r.unique_key = d.unique_key
LEFT JOIN bonddata AS b
ON r.unique_key = b.unique_key
WHERE d.Unique_key IS NULL
GROUP BY 1
ORDER BY 2 DESC;


-- 4. Find year wise how much money is spend on bonds

SELECT (YEAR(PurchaseDate)),SUM(b.Denomination)
FROM bonddata AS b
INNER JOIN donordata AS d
ON b.Unique_key = d.Unique_key
GROUP BY 1
ORDER BY 1;

-- 5. In which month most amount is spent on bonds
WITH CTE AS(SELECT monthname(d.journalDate) spent_by_month,sum(b.Denomination) AS spent
FROM donordata AS d
LEFT JOIN bonddata AS b
ON d.Unique_key = b.Unique_key
GROUP BY 1
ORDER BY 2 DESC)
SELECT * FROM CTE
WHERE spent = (SELECT max(spent) FROM CTE);


-- 6. Find out which company bought the highest number of bonds.
WITH CTE AS
(SELECT Purchaser,count(Purchaser) AS highest_no_of_bonds
FROM donordata
GROUP BY Purchaser
ORDER BY 2 DESC)
SELECT Purchaser,highest_no_of_bonds
FROM CTE
WHERE highest_no_of_bonds = (SELECT max(highest_no_of_bonds)
FROM CTE);


-- 7. Find out which company spent the most on electoral bonds.

WITH CTE AS
(SELECT d.Purchaser, sum(b.Denomination) AS most_electoral_bonds
FROM donordata AS d
JOIN bonddata AS b
ON d.Unique_key = b.Unique_key
GROUP BY 1
ORDER BY 2 DESC)
SELECT * FROM CTE
WHERE most_electoral_bonds = (SELECT max(most_electoral_bonds)
FROM CTE);


-- 8. List companies which paid the least to political parties.
WITH CTE AS
(SELECT Purchaser,PartyName,sum(Denomination) AS least_paid
FROM donordata AS d
INNER JOIN receiverdata AS r
ON r.Unique_key = d.Unique_key
JOIN bonddata AS b
ON d.Unique_key = b.Unique_key
GROUP BY Purchaser,PartyName
ORDER BY 3 ASC)
SELECT * FROM CTE
LIMIT 5;


-- 9. Which political party received the highest cash?
WITH CTE AS
(SELECT r.PartyName,sum(b.Denomination) AS Highest_cash
FROM receiverdata AS r
LEFT JOIN bonddata AS b
ON r.Unique_key = b.Unique_key
GROUP BY 1
ORDER BY 2 DESC)
SELECT * FROM CTE
WHERE Highest_cash = (SELECT MAX(Highest_cash) FROM CTE);


-- 10. Which political party received the highest number of electoral bonds?
WITH CTE AS
(SELECT PartyName,count(Denomination) AS Highest_No_of_electoralbonds
FROM receiverdata AS r
JOIN bonddata AS b
ON r.Unique_key = b.Unique_key
GROUP BY 1
ORDER BY 2 DESC)
SELECT * FROM CTE
WHERE Highest_No_of_electoralbonds = (SELECT MAX(Highest_No_of_electoralbonds) FROM CTE);


-- 11. Which political party received the least cash?
WITH CTE AS
(SELECT r.PartyName,sum(Denomination) AS lowest_cash
FROM receiverdata AS r
LEFT JOIN bonddata AS b
ON r.Unique_key = b.Unique_key
GROUP BY 1
ORDER BY 2 ASC)
SELECT * FROM CTE
WHERE lowest_cash = (SELECT min(lowest_cash) FROM CTE);


-- 12. Which political party received the least number of electoral bonds?
WITH CTE AS
(SELECT PartyName,count(PayBranchCode) AS least_no_of_electoralbonds
FROM receiverdata
GROUP BY 1
ORDER BY 2 ASC)
SELECT * FROM CTE
WHERE least_no_of_electoralbonds = (SELECT min(least_no_of_electoralbonds) FROM CTE);


-- 13. Find the 2nd highest donor in terms of amount he paid?
WITH CTE_donor AS
(SELECT d.purchaser AS Purchaser,sum(b.Denomination) AS 2nd_highest_donor
FROM donordata AS d
LEFT JOIN bonddata AS b
ON d.Unique_key = b.Unique_key
GROUP BY 1
ORDER BY 2 DESC)
SELECT * FROM CTE_donor
WHERE 2nd_highest_donor = (SELECT max(2nd_highest_donor) FROM CTE_donor
WHERE 2nd_highest_donor < (SELECT max(2nd_highest_donor) FROM CTE_donor));


-- 14. Find the party which received the second highest donations?
WITH CTE_donations AS
(SELECT r.PartyName AS PN,sum(b.Denomination) AS 2nd_highest_donations
FROM receiverdata AS r
LEFT JOIN bonddata AS b
ON r.Unique_key = b.Unique_key
GROUP BY r.PartyName),
ranked_donations AS(SELECT PN,2nd_highest_donations,RANK() OVER(ORDER BY 2nd_highest_donations DESC) AS highest_donations
FROM CTE_donations)
SELECT * FROM ranked_donations
WHERE highest_donations = 2;


-- 15. Find the party which received the second highest number of bonds?
WITH CTE_receiver AS
(SELECT PartyName AS PN,count(PayBranchCode) AS  second_highest
FROM receiverdata
GROUP BY 1
ORDER BY 2 DESC)
SELECT PN,second_highest 
FROM CTE_receiver
WHERE second_highest = (SELECT max(second_highest) FROM CTE_receiver 
WHERE second_highest < (SELECT max(second_highest) FROM CTE_receiver));


-- 16. In which city were the most number of bonds purchased?
WITH CTE_mostbonds AS
(SELECT b.city,count(bd.Denomination) AS bond_count
FROM bankdata AS b
LEFT JOIN receiverdata AS r
ON b.branchCodeNo = r.PayBranchCode
LEFT JOIN bonddata AS bd
ON r.Unique_key = bd.Unique_key
GROUP BY 1
ORDER BY bond_count DESC)
SELECT * FROM CTE_mostbonds
WHERE bond_count = (SELECT max(bond_count) FROM CTE_mostbonds);


-- 17. In which city was the highest amount spent on electoral bonds?
WITH CTE_highest_spent AS
(SELECT b.city,sum(bd.Denomination) AS total_amount
FROM bankdata AS b
LEFT JOIN receiverdata AS r
ON b.branchCodeNo = r.PayBranchCode
LEFT JOIN bonddata AS bd
ON r.Unique_key = bd.Unique_key
GROUP BY b.city
ORDER BY total_amount DESC)
SELECT * FROM CTE_highest_spent
WHERE total_amount = (SELECT max(total_amount) FROM CTE_highest_spent);


-- 18. In which city were the least number of bonds purchased?
WITH CTE_least_bonds AS 
(SELECT b.city,count(bd.Denomination) AS least_count
FROM bankdata AS b
LEFT JOIN receiverdata AS r
ON b.branchCodeNo = r.PayBranchCode
LEFT JOIN bonddata AS bd
ON r.Unique_key = bd.Unique_key
GROUP BY b.city
ORDER BY 2 ASC)
SELECT * FROM CTE_least_bonds
WHERE least_count = (SELECT min(least_count) FROM CTE_least_bonds);


-- 19. In which city were the most number of bonds enchased?
WITH CTE_most_no_bonds AS
(SELECT b.city,max(bd.Denomination) AS bond_count
FROM bankdata AS b
LEFT JOIN receiverdata AS r
ON b.branchcodeno = r.PayBranchCode
LEFT JOIN bonddata AS bd
ON bd.Unique_key = r.Unique_key
LEFT JOIN donordata AS d
ON d.Unique_key = bd.Unique_key
WHERE d.Unique_key is NULL
GROUP BY b.city
ORDER BY bond_count DESC)
SELECT * FROM CTE_most_no_bonds
WHERE bond_count = (SELECT max(bond_count) FROM CTE_most_no_bonds);


-- 20. In which city were the least number of bonds enchased?
WITH CTE AS
(SELECT city,count(Unique_key) AS cnt
FROM bankdata AS b
JOIN receiverdata AS r
ON b.branchCodeNo = r.PayBranchCode
GROUP BY city
ORDER BY cnt ASC)
SELECT * FROM CTE
WHERE cnt = (SELECT min(cnt) FROM CTE);


-- 21. List the branches where no electoral bonds were bought; if none, mention it as null.
SELECT bd.Address
FROM bankdata AS bd
LEFT JOIN receiverdata AS r
ON bd.branchCodeNo = r.PayBranchCode
LEFT JOIN donordata AS d
ON  r.Unique_key = d.Unique_key
LEFT JOIN bonddata AS b
ON r.Unique_key = b.Unique_key
WHERE d.Unique_key IS NULL
GROUP BY bd.Address;


-- 22. Break down how much money is spent on electoral bonds for each year.
SELECT YEAR(d.purchasedate) as 'year_' ,sum(b.Denomination) as 'Total_money_spent_'
FROM bonddata AS b 
JOIN donordata AS d 
ON b.Unique_key=d.Unique_key
GROUP BY year_
ORDER BY `Total_money_spent_` DESC;


-- 23. Break down how much money is spent on electoral bonds for each year and provide the year and the amount. Provide valuesfor the highest and least year and amount.







-- 24. Find out how many donors bought the bonds but did not donate to any political party?
SELECT count(d.Unique_key) AS cnt
FROM donordata AS d
LEFT JOIN
receiverdata AS r
ON d.Unique_key = r.Unique_key
WHERE PartyName IS NULL;


-- 25. Find out the money that could have gone to the PM Office, assuming the above question assumption (Domain Knowledge)
SELECT sum(Denomination)
FROM bonddata AS b
LEFT JOIN donordata AS d
ON b.Unique_key = d.Unique_key
LEFT JOIN receiverdata AS r
ON b.Unique_key = r.Unique_key
WHERE r.PartyName IS NULL;


-- 26. Find out how many bonds don't have donors associated with them.
SELECT count(*)
FROM donordata AS d
RIGHT JOIN receiverdata AS r
ON d.Unique_key = r.Unique_key
WHERE d.Purchaser IS NULL;


-- 27. Pay Teller is the employee ID who either created the bond or redeemed it. So find the employee ID who issued the highest number of bonds.
WITH CTE AS
(SELECT PayTeller,count(Unique_key) AS uk
FROM donordata
GROUP BY 1
ORDER BY 2 DESC)
SELECT * FROM CTE
WHERE uk = (SELECT max(uk) FROM CTE);


-- 28. Find the employee ID who issued the least number of bonds.
WITH CTE AS
(SELECT PayTeller,count(Unique_key) AS least_bonds
FROM donordata
GROUP BY 1
ORDER BY 2 ASC)
SELECT * FROM CTE
WHERE least_bonds = (SELECT min(least_bonds) FROM CTE);


-- 29. Find the employee ID who assisted in redeeming or enchasing bonds the most.
WITH CTE AS
(SELECT PayTeller,sum(b.Denomination) AS most_enchasing
FROM donordata AS d
INNER JOIN bonddata AS b
ON d.Unique_key = b.Unique_key
GROUP BY 1
ORDER BY 2 DESC)
SELECT * FROM CTE
WHERE most_enchasing = (SELECT max(most_enchasing) FROM CTE);


-- 30. Find the employee ID who assisted in redeeming or enchasing bonds the least
WITH CTE AS
(SELECT PayTeller,sum(b.Denomination) AS least_enchasing
FROM donordata AS d
INNER JOIN bonddata AS b
ON d.Unique_key = b.Unique_key
GROUP BY 1
ORDER BY 2 ASC)
SELECT * FROM CTE
WHERE least_enchasing = (SELECT min(least_enchasing) FROM CTE);











-- 1. Tell me total how many bonds are created? 
SELECT count(*) AS total_bonds_created
FROM bonddata;


-- 2. Find the count of Unique Denominations provided by SBI?
SELECT count(distinct Denomination) AS SBI
FROM bonddata;


-- 3. List all the unique denominations that are available?
SELECT distinct Denomination AS SBI
FROM bonddata
ORDER BY 1 ASC;


-- 4. Total money received by the bank for selling bonds
SELECT sum(Denomination) AS selling
FROM bonddata;


-- 5. Find the count of bonds for each denominations that are created.
SELECT Denomination,count(Denomination)
FROM bonddata
GROUP BY Denomination
ORDER BY Denomination DESC;


-- 6. Find the count and Amount or Valuation of electoral bonds for each denominations.
SELECT Denomination,count(Denomination),sum(Denomination)
FROM bonddata AS b
GROUP BY Denomination
ORDER BY Denomination DESC;


-- 7. Number of unique bank branches where we can buy electoral bond?
SELECT distinct(count(city))
FROM bankdata;


-- 8. How many companies bought electoral bonds
SELECT count(distinct Unique_key)
FROM donordata;


-- 9. How many companies made political donations
SELECT count(distinct Purchaser)
FROM donordata;


-- 10. How many number of parties received donations
SELECT count(distinct PartyName)
FROM receiverdata;


-- 11. List all the political parties that received donations
SELECT distinct PartyName
FROM receiverdata;


-- 12. What is the average amount that each political party received
SELECT distinct PartyName, AVG(Denomination)
FROM receiverdata AS r
INNER JOIN bonddata AS b
ON r.Unique_key = b.Unique_key
GROUP BY PartyName;


-- 13. What is the average bond value produced by bank
SELECT AVG(b.Denomination) AS avg_bond_value
FROM bonddata AS b
INNER JOIN donordata AS d
ON b.Unique_key = d.Unique_key;

-- 14. List the political parties which have enchased bonds in different cities?
SELECT distinct r.PartyName,bd.city, count(b.Denomination) AS no_of_enchased
FROM receiverdata AS r
JOIN bonddata AS b
ON r.Unique_key = b.Unique_key
JOIN bankdata AS bd
ON b.Unique_key = r.Unique_key
GROUP BY 1,2;


-- 15. List the political parties which have enchased bonds in different cities and list the cities in which the bonds have enchased as well?
SELECT PartyName,city,count(b.Unique_key)
FROM receiverdata AS r
LEFT JOIN bonddata AS b
ON r.Unique_key = b.Unique_key
LEFT JOIN bankdata AS bd
ON bd.branchCodeNo = r.PayBranchCode
GROUP BY 1,2;
















