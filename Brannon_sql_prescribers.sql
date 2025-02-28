## Prescribers Database

--For this exericse, you'll be working with a database derived from the [Medicare Part D Prescriber Public Use File](https://www.hhs.gov/guidance/document/medicare-provider-utilization-and-payment-data-part-d-prescriber-0). More information about the data is contained in the Methodology PDF file. See also the included entity-relationship diagram.

--1. 
    --a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

	SELECT nppes_provider_first_name, npi, SUM(total_claim_count) AS max_claim_count
    FROM prescriber
    LEFT JOIN prescription
	USING(npi)
	WHERE total_claim_count IS NOT NULL
	GROUP BY nppes_provider_first_name,  npi
	ORDER BY max_claim_count DESC;

--Bruce had the highest total number of claims totaled over all drugs, with an npi of 1881634483 and a total number of 99,707 claims.	
	
	
    --b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims

SELECT nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, npi, SUM(total_claim_count) AS max_claim_count
    FROM prescriber
    LEFT JOIN prescription
	USING(npi)
	WHERE total_claim_count IS NOT NULL
	GROUP BY nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, npi
	ORDER BY max_claim_count DESC;

--The information provided in the table is name: Bruce Pendley, specialty: Family Practice, and total claims: 99,707

--2. 
    --a. Which specialty had the most total number of claims (totaled over all drugs)?
    SELECT specialty_description, SUM(total_claim_count) AS max_claim_count
    FROM prescriber
    LEFT JOIN prescription
	USING(npi)
	WHERE total_claim_count IS NOT NULL
	GROUP BY specialty_description
	ORDER BY max_claim_count DESC;

--Family Practice had the most total number of claims totaled over all drugs with an amount of 9,752,347
	
   --b. Which specialty had the most total number of claims for opioids?

   SELECT specialty_description, SUM(total_claim_count) AS max_claim_count
    FROM prescriber
    LEFT JOIN prescription
	USING(npi)
	WHERE total_claim_count IS NOT NULL 
	AND drug_name IN(
    SELECT drug_name
	FROM drug
	WHERE opioid_drug_flag = 'Y'
	)
	GROUP BY specialty_description
	ORDER BY max_claim_count DESC;

--Nurse Practitioner had the highest total number of claims for opioids with the amount of 900,845.

    --c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

	SELECT *
	FROM
	  (SELECT specialty_description, SUM(total_claim_count)
	   FROM prescriber
	   FULL JOIN prescription
	   USING(npi)
	   GROUP BY specialty_description)
	WHERE sum IS NULL;
--or--
	   SELECT specialty_description, SUM(total_claim_count)
	   FROM prescriber
	   FULL JOIN prescription
	   USING(npi)
	   GROUP BY specialty_description
	   HAVING SUM(total_claim_count) IS NULL;

--The specialty descriptions listed in the table from the query above are not associated with prescriptions in the prescription table.
	

    --d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?
 SELECT specialty_description, 100 * (opioid_claim_count/SUM(total_claim_count)) AS opioid_percentage
 FROM prescriber
 LEFT JOIN prescription
 USING(npi)
 WHERE opioid_claim_count IN
	(SELECT specialty_description, SUM(total_claim_count) AS opioid_claim_count
    FROM prescriber
    LEFT JOIN prescription
	USING(npi)
	WHERE total_claim_count IS NOT NULL 
	AND drug_name IN(
    SELECT drug_name
	FROM drug
	WHERE opioid_drug_flag = 'Y'
	)
	GROUP BY specialty_description)
GROUP BY specialty_description, opioid_claim_count, total_claim_count;

--3. 
    --a. Which drug (generic_name) had the highest total drug cost?
    
    SELECT generic_name, SUM(total_drug_cost) AS drug_cost_sum
	FROM drug
	LEFT JOIN prescription
	USING(drug_name)
	WHERE total_drug_cost IS NOT NULL
	GROUP BY generic_name, total_drug_cost
	ORDER BY drug_cost_sum DESC;

	SELECT generic_name, SUM(total_drug_cost) AS drug_cost_sum
	FROM drug
	LEFT JOIN prescription
	USING(drug_name)
	WHERE total_drug_cost IS NOT NULL
	GROUP BY generic_name
	ORDER BY drug_cost_sum DESC;

--INSULIN GLARGINE,HUM.REC.ANLOG had the highest total drug cost of $104,264,066.35.

    --b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**


	SELECT generic_name, ROUND(SUM(total_drug_cost)/SUM(total_day_supply), 2) AS drug_cost_per_day
	FROM drug
	LEFT JOIN prescription
	USING(drug_name)
	WHERE total_drug_cost IS NOT NULL
	GROUP BY generic_name
	ORDER BY drug_cost_per_day DESC;

--C1 ESTERASE INHIBITOR has the highest total cost per day at $3,495.22.

--4. 
    --a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 
		 
		 SELECT 
		    drug_name,
			CASE WHEN opioid_drug_flag = 'Y' AND antibiotic_drug_flag = 'N' THEN 'opioid'
		      WHEN antibiotic_drug_flag = 'Y' AND opioid_drug_flag = 'N'THEN 'antibiotic'
			  ELSE 'neither' END AS drug_type
         FROM drug;

    --b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
         
		 SELECT drug_type, SUM(total_drug_cost) AS money
	     FROM
		   (SELECT 
		    drug_name,
			total_drug_cost,
			CASE WHEN opioid_drug_flag = 'Y' AND antibiotic_drug_flag = 'N' THEN 'opioid'
		      WHEN antibiotic_drug_flag = 'Y' AND opioid_drug_flag = 'N'THEN 'antibiotic'
			  ELSE 'neither' END AS drug_type
            FROM drug
		    LEFT JOIN prescription
		    USING(drug_name)
		    WHERE total_drug_cost IS NOT NULL)
		 GROUP BY drug_type
		 ORDER BY money DESC;
--More was spent on opioids than antibiotics, with opioids at $104,852,352.13 and antibiotics at $34,718,108.59.

--5. 
    --a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

    SELECT COUNT(DISTINCT cbsa) AS cbsa_tn_count
	FROM cbsa
	WHERE cbsaname LIKE '%TN%';
	
--There are 10 distinct cbsa numbers in TN.
    --b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
    
	SELECT cbsaname, SUM(population) AS cbsa_population
    FROM population
	INNER JOIN cbsa
	USING(fipscounty)
	GROUP BY cbsa, cbsaname
	ORDER BY cbsa_population;

--The CBSA associated with Morristown, TN has the smallest combined population and the CBSA associated with Nashville-Davidson--Murfreesboro--Franklin, TN has the largest population.

	 
    --c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
    
	SELECT county, population
	FROM population
	INNER JOIN fips_county
	USING(fipscounty)
	WHERE fipscounty IN 
      (SELECT fipscounty
      FROM population
	  LEFT JOIN cbsa
	  USING(fipscounty)
	  WHERE cbsa IS NULL)
	ORDER BY population DESC
	LIMIT 1;

--Sevier county is the largest county in population that is not included in a CBSA with a population of 95,523.


--6. 
    --a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
    
	SELECT drug_name, sum_claims
	FROM
	   (SELECT drug_name, total_claim_count AS sum_claims
	    FROM prescription
	    GROUP BY drug_name, total_claim_count)
	WHERE sum_claims >= 3000;
	

    --b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

	SELECT 
	     drug_name,
		 sum_claims,
		 CASE WHEN opioid_drug_flag = 'Y' THEN 'Y'
		 ELSE 'N' END AS opioid
	FROM
	   (SELECT drug_name, total_claim_count AS sum_claims
	    FROM prescription
	    GROUP BY drug_name, total_claim_count)
	INNER JOIN drug
	USING(drug_name)
	WHERE sum_claims >= 3000
	GROUP BY drug_name, sum_claims, opioid_drug_flag;

    --c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

	SELECT 
	     drug_name,
		 sum_claims,
		 CASE WHEN opioid_drug_flag = 'Y' THEN 'Y'
		 ELSE 'N' END AS opioid,
		 nppes_provider_first_name,
		 nppes_provider_last_org_name
	FROM
	   (SELECT drug_name, total_claim_count AS sum_claims, nppes_provider_first_name, nppes_provider_last_org_name
	    FROM prescription
		RIGHT JOIN prescriber
		USING(npi)
	    GROUP BY drug_name, total_claim_count, nppes_provider_first_name, nppes_provider_last_org_name)
	INNER JOIN drug
	USING(drug_name)
	WHERE sum_claims >= 3000
	GROUP BY drug_name, sum_claims, opioid_drug_flag, nppes_provider_first_name, nppes_provider_last_org_name;


--7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

    --a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
    
	SELECT *
    FROM prescriber
	CROSS JOIN drug
	WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y';

    --b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

	SELECT npi, drug_name, total_claim_count AS claims_per_drug_prescriber
    FROM prescriber
	CROSS JOIN drug
	LEFT JOIN prescription
	USING(npi, drug_name)
	WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y';

	
	--c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

	SELECT npi, drug_name, COALESCE(total_claim_count, '0') AS claims_per_drug_prescriber
    FROM prescriber
	CROSS JOIN drug
	LEFT JOIN prescription
	USING(npi, drug_name)
	WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y';