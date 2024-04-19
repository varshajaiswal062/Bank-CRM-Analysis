Create Database Bank_loan_data;
use Bank_loan_data;

# Transforming the bank DOJ coulm name and chaning the data type to perfrom date operation on that column
Alter table Customerinfo rename column `Bank DOJ` to BANK_DOJ;

update customerinfo
set BANK_DOJ= STR_TO_DATE(BANK_DOJ,"%d-%m-%Y");

ALter table Customerinfo
modify BANK_DOJ date;

#--------------------------------------------------Subjective SQL Question--------------------------------------------------------------
# Q2
Select customerId from Customerinfo
where quarter(BANK_DOJ) = 4
order by EstimatedSalary desc
limit 5;

#Q3
Select AVG(NumOfProducts) as Average_number_of_products from bank_churn
where HasCrCard = 1;

#Q5
Select
AVG(bc.creditScore) as Avg_Credit_Score,
ec.ExitCategory
from bank_churn bc
JOIN Exitcustomer ec ON  bc.Exited= ec.ExitID
group by ec.ExitCategory;
 
 #Q6
 Select
 ci.GenderID,
 g.GenderCategory as Gender, 
 AVG(ci.EstimatedSalary) as AVG_Estimated_Salary,
 count(distinct case when bch.IsActiveMember=1 then ci.CustomerID else NULL end) as Count_of_Active_accounts
 from bank_churn bch 
 JOIN Customerinfo as ci ON bch.CustomerId=ci.CustomerId
 JOIN Gender as G on ci.genderID=g.GenderID
 group by genderID,g.GenderCategory
 order by AVG_Estimated_Salary desc;
 
 
 #Q7
 With Credit_Score_Segments AS
 (Select
 Exited,
 CustomerID,
	Case 	
		when CreditScore between 800 and 900 then "Excellent Credit"
		when CreditScore between 799 and 740 then "Very Good Credit"
		when CreditScore between 670 and 739 then "Good Credit"
        when CreditScore between 580 and 669 then "Fair Credit"
        else "Poor Credit"
		End	as Credit_segment
from bank_churn)

Select 
Credit_segment,
Count(*) as Total_accounts,
Count(distinct Case when Exited =1 then CustomerID else NULL end) as Total_exsited_customers,
Round((Sum(Exited)/Count(*))*100,2) as Exit_Rate
from Credit_Score_Segments
group by Credit_segment
order by Exit_rate desc
limit 1;






#Q8
 Select 
 ci.GeographyID,
 g.GeographyLocation,
 SUM(bch.IsActiveMember =1) as Count_Active_Customers
 from bank_churn bch 
 JOIN Customerinfo as ci ON bch.CustomerId=ci.CustomerId
 JOIN geography g ON ci.GeographyID=g.GeographyID
 where bch.Tenure>5
 Group by ci.GeographyID,g.GeographyLocation
 order by Count_Active_Customers desc;
 
 
 #Q11
Select
date_format(BANK_DOJ,"%Y") as ym,
Count(*) as  Count_Customers_joined
from customerinfo
group by ym
order by ym;

Select
date_format(BANK_DOJ,"%Y") as y,
date_format(BANK_DOJ,"%m") as ym,
Count(*) as  Count_Customers_joined
from customerinfo
group by y,ym
order by y,ym;


 
 #Q15
With Calculate AS ( 
select
g.GenderCategory as Gender,
go.GeographyID as GeographyID,
go.GeographyLocation as Geography,
avg(ci.EstimatedSalary) as Avg_income
from bank_churn bch 
JOIN Customerinfo as ci ON bch.CustomerId=ci.CustomerId
JOIN Gender g ON ci.GenderID=g.GenderID
JOIN Geography go ON ci.GeographyID=go.GeographyID
group by go.GeographyID,go.GeographyLocation,g.GenderCategory
)

Select 
Gender,
GeographyID,
Geography,
Avg_income,
rank() Over(Partition by Geography order by Avg_income desc) as Ranking
From Calculate
order by GeographyID,Geography;

 
 #Q16
 Select
Case 
	when ci.age between 18 and 30 then "18-30"
    when ci.age between 30 and 50 then "30-50"
    when ci.age >50 then "50+"
    Else "NULL"
END as Age_Bracket,
AVG(bch.Tenure) as AVG_Tenure
from bank_churn bch 
JOIN Customerinfo as ci ON bch.CustomerId=ci.CustomerId
where bch.Exited=1
Group by Age_Bracket
order by Age_Bracket;



#Q19
With Credit_Calculation AS 
(
select
Case 
	when CreditScore >=300 and CreditScore<=500 then "300-500"
	when CreditScore >= 501 and CreditScore<=700 then "501-700"
	when CreditScore >= 701 then "700+"
End as Credit_Score_Bucket,
Count(*) as Count_Of_Customers_Churned
from bank_churn
where Exited=1
Group by Credit_Score_Bucket
)
 Select 
 Credit_Score_Bucket,
 Count_Of_Customers_Churned,
 Rank() Over(Order by Count_Of_Customers_Churned desc) as Credit_rank 
 From Credit_Calculation;
 

 
#Q23
 Select *,
 (select ExitCategory from ExitCustomer where bc.Exited=ExitCustomer.ExitID) as ExitCategory
 from
 bank_churn as bc;
 
 #Q25
 Select 
 ci.CustomerId,
 ci.Surname as last_name,
 bc.IsActiveMember
 from Customerinfo as ci
 JOIN bank_churn bc ON ci.CustomerId=bc.CustomerId
 where ci.surname like '%on';
 
 
 #Q9- Objective questions
 Select 
 go.GeographyLocation,
 COUNT(bc.CustomerID),
 COUNT(case when bc.HasCrCard=1 then bc.HasCrCard end) as Has_Cr_Card,
 COUNT(case when bc.IsActiveMember=1 then bc.IsActiveMember end) as IsActiveMember,
 COUNT(case when bc.Exited=1 then bc.Exited end) as Exited,
 COUNT(case when bc.Exited=0 then bc.Exited end) as Retained
 from Bank_churn bc 
 JOIN Customerinfo ci ON bc.customerID=ci.customerID
 JOIN Geography go ON ci.GeographyID=go.GeographyID
 Group by go.GeographyLocation ;
 
 



