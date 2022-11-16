
# 1) How many olympics games have been held ?

SELECT COUNT(DISTINCT Games) AS Nbre_Jeu_Olympic
FROM athlete_events ae 

# 2) List down all Olympics games held so far?

SELECT DISTINCT Games AS Jeu_Olympic
FROM athlete_events ae 
ORDER BY Year

# 3 Mention the total no of nations who participated in each olympics game?

SELECT Games,  COUNT(DISTINCT NOC) AS Nbre_Nation
FROM athlete_events ae 
GROUP BY Games
ORDER BY Year

# Which year saw the highest and lowest no of countries participating in olympics?

-- Méthode 1 Union ALL ;
(
SELECT Year , COUNT(DISTINCT NOC) AS Nbre_Nation
FROM athlete_events ae 
GROUP BY Year
ORDER BY Nbre_Nation LIMIT 1
)
UNION ALL
(
SELECT Year , COUNT(DISTINCT NOC) AS Nbre_Nation
FROM athlete_events ae 
GROUP BY Year
ORDER BY Nbre_Nation DESC LIMIT 1
)


-- Méthode 2 Sous-requête ;

with t1 as( SELECT Year , COUNT(DISTINCT NOC) AS Nbre_Nation
FROM athlete_events ae 
GROUP BY Year 
)
select * from t1
where Nbre_Nation =(select min(Nbre_Nation) from t1) or 
Nbre_Nation = (select max(Nbre_Nation) from t1) 

-- Méthode 2 avec IN  ;
with t1 as( SELECT Year , COUNT(DISTINCT NOC) AS Nbre_Nation
FROM athlete_events ae 
GROUP BY Year 
)
select * from t1
where Nbre_Nation in ((select min(Nbre_Nation) from t1) , 
(select max(Nbre_Nation) from t1) )

# Which nation has participated in all of the olympic games?

WITH ctt AS
(
SELECT Games, NOC AS Nation
FROM athlete_events ae 
GROUP BY Games, Nation
ORDER BY Year
)

,
Nbre_OG AS 

(SELECT COUNT(DISTINCT Games) AS Nbre_Jeu_Olympic
FROM athlete_events ae )

SELECT Nation
, SUM(CASE WHEN 1 = 1 THEN 1 ELSE 0 END) AS Nbre_Participation
, ROUND  (100* SUM(CASE WHEN 1 = 1 THEN 1 ELSE 0 END) / (SELECT Nbre_OG.Nbre_Jeu_Olympic FROM Nbre_OG ) , 2 ) AS Taux_Participation
-- je compte le nbre de participation / par le nombre total de eu olympic comme dans la question 1

FROM ctt
GROUP BY Nation
HAVING Taux_Participation = 100

# Identify the sport which was played in all summer olympics.

WITH ctt AS
(
SELECT Games, Sport AS Sport
FROM athlete_events ae
WHERE Season = 'Summer'
GROUP BY Games, Sport
ORDER BY Year
)

,
Nbre_OG AS 

(SELECT COUNT(DISTINCT Games) AS Nbre_Jeu_Olympic_Summer
FROM athlete_events ae 
WHERE Season = 'Summer')

SELECT Sport
, SUM(CASE WHEN 1 = 1 THEN 1 ELSE 0 END) AS Nbre_Participation_Sport_Summer
, ROUND  (100* SUM(CASE WHEN 1 = 1 THEN 1 ELSE 0 END) / (SELECT Nbre_OG.Nbre_Jeu_Olympic_Summer FROM Nbre_OG ) , 2 ) AS Taux_Participation_Sport_Summer
-- je compte le nbre de participation / par le nombre total de eu olympic comme dans la question 1

FROM ctt
GROUP BY Sport
HAVING Taux_Participation_Sport_Summer = 100





# Which Sports were just played only once in the olympics ?

WITH ctt AS
(
SELECT Games, Sport AS Sport
FROM athlete_events ae
GROUP BY Games, Sport
ORDER BY Year
)

,
Nbre_OG AS 

(SELECT COUNT(DISTINCT Games) AS Nbre_Jeu_Olympic
FROM athlete_events ae 
)

SELECT Sport
, SUM(CASE WHEN 1 = 1 THEN 1 ELSE 0 END) AS Nbre_Participation_Sport
, ROUND  (100* SUM(CASE WHEN 1 = 1 THEN 1 ELSE 0 END) / (SELECT Nbre_OG.Nbre_Jeu_Olympic FROM Nbre_OG ) , 2 ) AS Taux_Participation_Sport

FROM ctt
GROUP BY Sport
HAVING Nbre_Participation_Sport = 1


# Fetch the total no of sports played in each olympic games.

WITH t1 

as (
SELECT  DISTINCT Games, Sport AS Sport
FROM athlete_events ae
-- GROUP BY Games
ORDER BY Year
)

SELECT t1.Games
,SUM(CASE WHEN 1 = 1 THEN 1 ELSE 0 END) AS Nbre_Sport
FROM t1
GROUP BY  t1.Games


# Fetch details of the oldest athletes to win a gold medal.

WITH t1 as 
(
SELECT *
FROM athlete_events ae
WHERE ae.Medal = 'Gold' and ae.Age != 'NA'
ORDER BY Year 
)

SELECT t1.Name
, t1.ID
, t1.Sport
, t1.Age
, t1.Year AS Année_Médaille

FROM t1
WHERE t1.Age = (SELECT MAX(t1.Age) FROM t1)
ORDER BY Age DESC


# Find the Ratio of male and female athletes participated in all olympic games.

WITH t1

as 
(
SELECT Games, Sex,  COUNT(Sex) AS Nbre_Participants
FROM athlete_events ae
GROUP BY Games ,  Sex
ORDER BY Year
)
, t2

as 

(
SELECT Games,  COUNT(Sex) AS Nbre_Participants_Totaux
FROM athlete_events ae
GROUP BY Games 
ORDER BY Year
)

SELECT t2.Games
, t2.Nbre_Participants_Totaux
,t1.Sex
, t1.Nbre_Participants
, ROUND( 100* t1.Nbre_Participants / t2.Nbre_Participants_Totaux ,2 )   AS Taux_par_sex
FROM t2
LEFT JOIN t1 

ON t1.Games = t2.Games

-- WHERE t1.Sex = 'F'
-- ORDER BY Taux_par_sex DESC 





# Fetch the top 5 athletes who have won the most gold medals.

SELECT  Name,  COUNT(Medal) AS Nbre_Médaille
FROM athlete_events ae
 WHERE Medal = 'Gold'
-- WHERE Medal != 'NA'
GROUP BY Name
ORDER BY Nbre_Médaille DESC LIMIT 5

# Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

SELECT  Name,  COUNT(Medal) AS Nbre_Médaille
FROM athlete_events ae
-- WHERE Medal = 'Gold'
WHERE Medal != 'NA'
GROUP BY Name
ORDER BY Nbre_Médaille DESC LIMIT 7

# I don't want to discriminate the 2 others who won 13 medals !!! 

# Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

SELECT  ae.NOC
, nr.region AS Pays
,  COUNT(ae.Medal) AS Nbre_Médaille
FROM athlete_events ae

LEFT JOIN noc_regions nr
ON nr.NOC = ae.NOC

WHERE Medal != 'NA'

GROUP BY NOC
ORDER BY Nbre_Médaille DESC LIMIT 5


# List down total gold, silver and broze medals won by each country.

SELECT  ae.NOC
, nr.region AS Pays
, ae.Medal
,  COUNT(ae.Medal) AS Nbre_Médaille
FROM athlete_events ae

LEFT JOIN noc_regions nr
ON nr.NOC = ae.NOC

WHERE Medal != 'NA'

GROUP BY ae.NOC, Pays, ae.Medal
ORDER BY Pays, ae.Medal 

# List down total gold, silver and broze medals won by each country corresponding to each olympic games.

SELECT  ae.NOC
, nr.region AS Pays
, ae.Games
, ae.Medal
,  COUNT(ae.Medal) AS Nbre_Médaille
FROM athlete_events ae

LEFT JOIN noc_regions nr
ON nr.NOC = ae.NOC

WHERE Medal != 'NA'

GROUP BY ae.Games,ae.NOC, Pays, ae.Medal
ORDER BY Pays, ae.Medal 



# Identify which country won the most gold, most silver and most bronze medals in each olympic games.


WITH b 
as 

(

WITH a 
as (
SELECT  ae.NOC
, nr.region AS Pays
, ae.Games
, ae.Medal
,  COUNT(ae.Medal) AS Nbre_Médaille
FROM athlete_events ae

LEFT JOIN noc_regions nr
ON nr.NOC = ae.NOC

WHERE Medal != 'NA'

GROUP BY ae.Games,ae.NOC, Pays, ae.Medal
ORDER BY Pays, ae.Medal 
)
SELECT 
a.Games
,a.Pays
, a.Medal
, a.Nbre_Médaille
, RANK () OVER (PARTITION BY  a.Games, a.Medal ORDER BY Nbre_Médaille DESC) AS Classement_Médaille

FROM a


)


SELECT *

FROM b

WHERE b.Classement_Médaille = 1


# Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.


WITH b 
as 

(

WITH a 
as (
SELECT  ae.NOC
, nr.region AS Pays
, ae.Games
, ae.Medal
,  COUNT(ae.Medal) AS Nbre_Médaille
FROM athlete_events ae

LEFT JOIN noc_regions nr
ON nr.NOC = ae.NOC

WHERE Medal != 'NA'

GROUP BY ae.Games,ae.NOC, Pays, ae.Medal
ORDER BY Pays, ae.Medal 
)
SELECT 
a.Games
,a.Pays
, a.Medal
, a.Nbre_Médaille
, RANK () OVER (PARTITION BY  a.Games, a.Medal ORDER BY Nbre_Médaille DESC) AS Classement_Médaille
,  RANK () OVER (PARTITION BY  a.Games ORDER BY Nbre_Médaille DESC) AS Classement_Médaille_Total
FROM a


)


SELECT *

FROM b

WHERE 
b.Classement_Médaille = 1
 
AND

b.Classement_Médaille_Total = 1



# Which countries have never won gold medal but have won silver/bronze medals?

SELECT  ae.NOC
, nr.region AS Pays

, SUM(CASE WHEN ae.Medal = 'Gold' Then 1 else 0 END) AS Nbre_Médaille_Or
, SUM(CASE WHEN ae.Medal = 'Argent' Then 1 else 0 END) AS Nbre_Médaille_Argent
, SUM(CASE WHEN ae.Medal = 'Bronze' Then 1 else 0 END) AS Nbre_Médaille_Bronze

FROM athlete_events ae

LEFT JOIN noc_regions nr
ON nr.NOC = ae.NOC


GROUP BY ae.NOC, Pays
HAVING Nbre_Médaille_Or = 0 and (Nbre_Médaille_Argent > 0 OR Nbre_Médaille_Bronze > 0 )
ORDER BY Pays



# Pour vérifier


SELECT  ae.NOC
, nr.region AS Pays
, ae.Medal

, COUNT(ae.Medal) As Nbre_Médaille

FROM athlete_events ae

LEFT JOIN noc_regions nr
ON nr.NOC = ae.NOC

WHERE ae.Medal != 'NA'

-- AND nr.region = 'Morocco' 

GROUP BY ae.NOC, Pays , ae.Medal

ORDER BY Pays

# Question personnelle

SELECT  ae.NOC
, nr.region AS Pays
, ae.Medal
, ae.Name
, ae.Year
, ae.Sport



FROM athlete_events ae

LEFT JOIN noc_regions nr
ON nr.NOC = ae.NOC

WHERE ae.Medal != 'NA'

 AND nr.region = 'Morocco' 
 
 AND ae.Name LIKE 'Hicham%'
 
 ORDER BY ae.Year DESC







# In which Sport/event, India has won highest medals.

SELECT DISTINCT ae.NOC
, nr.region AS Pays
, ae.Medal
, ae.Year
, ae.Sport



FROM athlete_events ae

LEFT JOIN noc_regions nr
ON nr.NOC = ae.NOC

WHERE ae.Medal = 'Gold'

 AND nr.region = 'India' 
 
 ORDER BY ae.Year DESC

# Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.
 
 SELECT 
 ae.Games
 ,ae.NOC
, nr.region AS Pays
, ae.Medal

, ae.Year
, ae.Sport
, SUM(CASE WHEN ae.Medal != 'NA' Then 1 else 0 END) AS Nbre_Médaille_Total_Cette_année



FROM athlete_events ae

LEFT JOIN noc_regions nr
ON nr.NOC = ae.NOC

WHERE ae.Medal = 'Gold'

 AND nr.region = 'India' 
 
 AND ae.Sport ='Hockey'
 
 GROUP by 
  ae.Games
 ,ae.NOC
, nr.region
, ae.Medal

, ae.Year
, ae.Sport
 ORDER BY ae.Year DESC
