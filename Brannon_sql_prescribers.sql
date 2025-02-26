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

--3. 
    --a. Which drug (generic_name) had the highest total drug cost?
    
	SELECT generic_name, SUM(total_drug_cost) AS drug_cost_sum
	FROM drug
	LEFT JOIN prescription
	USING(drug_name)
	WHERE total_drug_cost IS NOT NULL
	GROUP BY generic_name, total_drug_cost
	ORDER BY drug_cost_sum DESC;

--Pirfenidone had the highest total drug cost of $2,829,174.30.

    --b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

	SELECT generic_name, ROUND(SUM(total_drug_cost)/SUM(total_day_supply), 2) AS drug_cost_per_day
	FROM drug
	LEFT JOIN prescription
	USING(drug_name)
	WHERE total_drug_cost IS NOT NULL
	GROUP BY generic_name, total_drug_cost, total_day_supply
	ORDER BY drug_cost_per_day DESC;

--or

	SELECT generic_name, ROUND(SUM(total_drug_cost)/SUM(total_day_supply), 2) AS drug_cost_per_day
	FROM drug
	LEFT JOIN prescription
	USING(drug_name)
	WHERE total_drug_cost IS NOT NULL
	GROUP BY generic_name
	ORDER BY drug_cost_per_day DESC;

--IMMUN GLOB G(IGG)/GLY/IGA OV50 has the highest total cost per day at $7,141.11.

--4. 
    --a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 



    --b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.	