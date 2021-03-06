USE [Kalyan_Temp]
GO
/****** Object:  StoredProcedure [dbo].[uspNameStandardization]    Script Date: 12/28/2016 4:40:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*-----------------------------------------------------------------------------------

Script Name:- Data Cleaning-Name
Created Date:- 27/04/2015
Created by :- Vikram Santhanam
Last Updated on:- 05/05/2015
Last Updated by : Vikram Santhanam
Script Description:- this script is used for 
			        1.Cleaning Name Field
					2.Standardizing the name field

Input Variables:- Database name,Source table Name, Primary key Identifier of source table,Column Name form Source table					
Version:- 1.5
-----------------------------------------------------------------------------------*/

--exec dbo.uspNameStandardization
ALTER procedure [dbo].[uspNameStandardization]
as 
/*----------------------Moving the name from raw data to destination table-----------------------*/
IF OBJECT_ID('dbo.temp_vs_NameCleaning_20161216', 'U') IS NOT NULL 
  DROP TABLE dbo.temp_vs_NameCleaning_20161216 ; 

Declare @Maxdate datetime

set @MaxDate=(select max([Billdate]) from [Kalyan_Temp].[dbo].[temp_vs_DailyDataCleaning_20161216])

SELECT distinct [CustomerCode] as 'ID' ,[CustomerName] 'Name',[CustomerName] 'Name_bk' ,isnull([SalesExecutiveCode],'NA')[SalesExecutiveCode]
,isnull([SalesExecutiveName],'NA')[SalesExecutiveName],
BillStore,[BillStore_State],Billdate
into [temp_vs_NameCleaning_20161216]  
FROM [Kalyan_Master].[dbo].[tbl_Master_Capillary_JuelTransInfo]
where  len([CustomerName])>2 and billdate>@Maxdate




/*-------------altering the newly created table to accomadate all the required fields-------------------*/


alter table [temp_vs_NameCleaning_20161216] 
add [Salutation] varchar(30),[Initial] varchar(10),[First] varchar(50)
,[Middle] varchar(50),[Middle 1] varchar(50),[Last] varchar(50),[No of Spaces] int,[cleaning process] varchar(50),
[type of error] varchar(500),CompanyName int,Relationship int,SpecialCharacters int, Profession int,Qualitfication int,Numerics int,
SalutationCount int, JunkName int, CelebrityName int,RepeatingName int,RepeatingNametemp varchar(100),TotalError int

--alter table [temp_vs_NameCleaning_20161216]
--drop column [Name_bk],[Salutation],[Initial] ,[First] ,[Middle] ,[Middle 1] ,[Last] ,[No of Spaces],[cleaning process],[type of error]


/*------------------------removing company details----------------------------------*/
--drop table [temp_vs_NameCleaningCompany_20161216]

IF OBJECT_ID('dbo.temp_vs_NameCleaningCompany_20161216', 'U') IS NOT NULL 
  DROP TABLE dbo.temp_vs_NameCleaningCompany_20161216 ; 

select * into [temp_vs_NameCleaningCompany_20161216] from [temp_vs_NameCleaning_20161216]
where  [name] like '%Pvt%' or [name] like '%Company%' or [name] like '%Engineering%' 
or [name] like '%Agency%' or [name] like '%Contractor%'or  [name] like '%ltd%' or [name] like '%Limited%' or [name] like '%Private%'
or [name] like '%Public%' or [name] like '%Firm%' or [name] like '%Imports%'or [name] like '%Exports%' or [name] like '%Builders%' 
 or [name] like '%Services%'or  [name] like '%Agency%' or  [name] like '%Developer%' or  [name] like '%Software%'or  [name] like '%Industry%' or  [name] like '%Industries%' or  [name] like '%Dealers%'
or  [name] like '%Construction%' or  [name] like '%Works%' or  [name] like '%Collection%'  or  [name] like '%School%' or  [name] like '%&Son%' or [name] like '%Promoters%' or [name] like 'M/S%'  or [name] like '%Nursing%Home%' 
or [name] like '%Project%' or [name] like '%Solutions%' or [name] like '%Shop%' or [name] like '%Digital%' or [name] like '%Printers%' or [name] like '%Business%' or [name] like '%Show%Room%' 
or [name] like '% Stall%' or [name] like '%proprietar%' or [name] like '%TRADERS%' 

update [temp_vs_NameCleaning_20161216]
set CompanyName=1
where  id in (select distinct id from [temp_vs_NameCleaningCompany_20161216])

delete from [temp_vs_NameCleaning_20161216]
where  id in (select id from [temp_vs_NameCleaningCompany_20161216])

drop table [temp_vs_NameCleaningCompany_20161216]

/*--------------------removing any special characters and numerics from the name----------------------*/


update [temp_vs_NameCleaning_20161216]
set Name_bk=REPLACE(Name_bk,SUBSTRING(Name_bk,CHARINDEX('(',Name_bk),(LEN(Name_bk)-1)),'')
,SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end
WHERE Name_bk LIKE '%(%' AND Name_bk NOT LIKE '%)%'

update [temp_vs_NameCleaning_20161216]
set Name_bk=REPLACE([Name],SUBSTRING(Name_bk,CHARINDEX('(',Name_bk),CHARINDEX(')',Name_bk)),'')
,SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end
WHERE Name_bk LIKE '%(%)%'

----removing junk names

update [temp_vs_NameCleaning_20161216] set JunkName=case when JunkName is null then 1 else JunkName+1 end where Name_bk like '%test%' or Name_bk like '%customer%'

---checking celebrity names

--create table dbo.tbl_Master_CelebrityNames( Name varchar(150))
--insert into  dbo.tbl_Master_CelebrityNames
--values ('Virat%Kohli'),('M%S%Dhoni'),('Rajnikant')

update [temp_vs_NameCleaning_20161216]
set CelebrityName=case when CelebrityName is null then 1 else CelebrityName+1 end 
from [temp_vs_NameCleaning_20161216] a inner join Kalyan_Master.dbo.tbl_Master_CelebrityNames b
on replace(a.Name_bk,' ','%') LIKE '%'+b.Name+ '%'



---removing the special characters

update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'!',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%!%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'@',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%@%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'#',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%#%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'$',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%$%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'&',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%&%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'*',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%*%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'(',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%(%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,')',' ') ,SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%)%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'-',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%-%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'+',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%+%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'=',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%=%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'{',' ') ,SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%{%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'}',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%}%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'[',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%[%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,']',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%]%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,':',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%:%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,';',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%;%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'/',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%/%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'?',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%?%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'.',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%..%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'.',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%.%.%.%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,',',' ') ,SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%,%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'>',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%>%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'<',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%<%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'`',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%`%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'~',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%~%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'"',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%"%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'''',' '),SpecialCharacters=case when SpecialCharacters is null then 1 else SpecialCharacters+1 end where Name_bk like '%''%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'.',' ') where Name_bk like '%.%'

---removing the excess spaces

update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'  ',' ')  where Name_bk like '%  %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'   ',' ')  where Name_bk like '%   %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'    ',' ')  where Name_bk like '%    %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'     ',' ')  where Name_bk like '%     %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'      ',' ')  where Name_bk like '%      %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'       ',' ')  where Name_bk like '%       %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'        ',' ')  where Name_bk like '%        %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'         ',' ')  where Name_bk like '%         %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'          ',' ')  where Name_bk like '%          %'

-----relationship splitting

update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('S O',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end where Name_bk like '% S O %'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('S O',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% S O%'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('SO',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% SO %'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('S 0',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% S 0 %'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('D O',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% D O %'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('D O',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% D O%'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('DO',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% DO %'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('D 0',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% D 0 %'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('W O',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% W O %'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('W O',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% W O%'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('WO',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% WO %'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('W 0',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% W 0 %'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('H O',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% H O %'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('H O',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% H O%'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('H 0',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% H 0 %'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('C O',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% C O %'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('C O',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% C O%'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('C 0',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% C 0 %'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('CO',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% CO %'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('F O',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% F O%'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('F O',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% F O%'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('F 0',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% F 0 %'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('Y O',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% Y O%'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('Y 0',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% Y 0 %'
update [temp_vs_NameCleaning_20161216] set Name_bk=substring(Name_bk,1,(charindex('V O',Name_bk,1))-1),Relationship=case when Relationship is null then 1 else Relationship+1 end  where Name_bk like '% V O%'

---removing the numerics
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'1',''),Numerics=case when Numerics is null then 1 else Numerics+1 end   where Name_bk like '%1%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'2',''),Numerics=case when Numerics is null then 1 else Numerics+1 end    where Name_bk like '%2%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'3',''),Numerics=case when Numerics is null then 1 else Numerics+1 end    where Name_bk like '%3%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'4',''),Numerics=case when Numerics is null then 1 else Numerics+1 end    where Name_bk like '%4%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'5',''),Numerics=case when Numerics is null then 1 else Numerics+1 end    where Name_bk like '%5%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'6',''),Numerics=case when Numerics is null then 1 else Numerics+1 end    where Name_bk like '%6%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'7',''),Numerics=case when Numerics is null then 1 else Numerics+1 end    where Name_bk like '%7%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'8',''),Numerics=case when Numerics is null then 1 else Numerics+1 end    where Name_bk like '%8%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'9',''),Numerics=case when Numerics is null then 1 else Numerics+1 end    where Name_bk like '%9%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'0',''),Numerics=case when Numerics is null then 1 else Numerics+1 end    where Name_bk like '%0%'


-----removing the salutations and moving it to salutation field

update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Dr CH',' ') ,Salutation='Dr CH' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end   where Name_bk like 'Dr CH %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Doctor',' ') ,Salutation='Dr' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end   where Name_bk like '% Doctor%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Dr Mr',' ') ,Salutation='Dr Mr' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end   where Name_bk like 'Dr Mr %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Dr Mrs',' '),Salutation='Dr Mrs',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Dr Mrs %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Dr Mr',' ') ,Salutation='Dr Mr' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end   where Name_bk like 'Dr Mr%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Dr Mrs',' '),Salutation='Dr Mrs',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Dr Mrs%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'DrMr',' ') ,Salutation='Dr Mr' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end   where Name_bk like 'DrMr %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'DrMrs',' '),Salutation='Dr Mrs' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end    where Name_bk like 'DrMrs %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Mr ',' '),Salutation='Mr',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end    where Name_bk like 'Mr %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Mrs',' '),Salutation='Mrs',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Mrs %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'MR ',' '),Salutation='Mr',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end    where Name_bk like 'Mr %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'MRS ',' '),Salutation='Mrs',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Mrs %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' MRS',' '),Salutation='Mrs' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end    where Name_bk like '% Mrs'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Miss',' '),Salutation='Miss' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end    where Name_bk like 'Miss %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Ms ',' '),Salutation='Ms',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Ms %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Smt ',' '),Salutation='Smt' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end    where Name_bk like 'Smt%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Chi ',' '),Salutation='Chi',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Chi %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Ch ',' '),Salutation='Ch',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Ch %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Dr ',' '),Salutation='Dr',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Dr %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' DR',' '),Salutation='Dr' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end    where Name_bk like '% Dr'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Shri ',' '),Salutation='Shri',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Shri %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Sri ',' '),Salutation='Sri',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Sri %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'FR ',' '),Salutation='Fr',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Fr %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'RevDr ',' '),Salutation='Rev Dr',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'RevDr %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Rev Dr ',' '),Salutation='Rev Dr' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end    where Name_bk like 'Rev Dr %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Rev ',' '),Salutation='Rev' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end    where Name_bk like 'Rev %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Very Rev ',' '),Salutation='Rev' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end    where Name_bk like 'Very Rev %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Pastor',' '),Salutation='Pastor'  ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end   where Name_bk like 'Pastor %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'ft',' '),Salutation='Ft'  ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end   where Name_bk like 'FT %'


---removing the excess spaces

update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'  ',' ')  where Name_bk like '%  %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'   ',' ')  where Name_bk like '%   %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'    ',' ')  where Name_bk like '%    %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'     ',' ')  where Name_bk like '%     %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'      ',' ')  where Name_bk like '%      %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'       ',' ')  where Name_bk like '%       %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'        ',' ')  where Name_bk like '%        %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'         ',' ')  where Name_bk like '%         %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'          ',' ')  where Name_bk like '%          %'



update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'SQD LDR',' ') ,Salutation=CASE when Salutation is not null then 'SQD LDR ' + Salutation else 'SQD LDR'  end,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like 'SQD LDR %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'SQD',' '),Salutation=CASE when Salutation is not null then 'SQD ' + Salutation else 'SQD'  end ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like 'SQD %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'L T CDR',' '),Salutation=CASE when Salutation is not null then 'LT CDR ' + Salutation else 'LT CDR'  end ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like 'L T CDR%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'LT CDR',' '),Salutation=CASE when Salutation is not null then 'LT CDR ' + Salutation else 'LT CDR'  end ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like 'LT CDR%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'LT',' ') ,Salutation=CASE when Salutation is not null then 'LT' + Salutation else 'LT'  end,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like 'LT %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'CDR',' '),Salutation=CASE when Salutation is not null then 'CDR ' + Salutation else 'CDR'  end ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% CDR%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'LTcol',' '),Salutation=CASE when Salutation is not null then 'LT Col ' + Salutation else 'LT Col'  end ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like 'LTcol%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'LT col',' '),Salutation=CASE when Salutation is not null then 'LT Col ' + Salutation else 'LT Col'  end ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like 'LT col%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'LT',' '),Salutation=CASE when Salutation is not null then 'LT ' + Salutation else 'LT'  end ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like 'LT%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'col',' '),Salutation=CASE when Salutation is not null then 'Col ' + Salutation else 'Col'  end ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% col%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Captain',' '),Salutation=CASE when Salutation is not null then 'Captain ' + Salutation else 'Captain'  end ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%Captain%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Capt',' ') ,Salutation=CASE when Salutation is not null then 'Captain ' + Salutation else 'Captain'  end,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%Capt%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'CPT',' ') ,Salutation=CASE when Salutation is not null then 'Captain ' + Salutation else 'Captain'  end ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%CPT%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'RTN PHF PP DR',' '),Salutation=CASE when Salutation is not null then 'RTN PHF PP DR ' + Salutation else 'RTN PHF PP DR'  end ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like 'RTN PHF PP DR%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'RTN PHF',' '),Salutation=CASE when Salutation is not null then 'RTN PHF ' + Salutation else 'RTN PHF'  end  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like 'RTN PHF%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'RTN PPF',' ') ,Salutation=CASE when Salutation is not null then 'RTN PPF ' + Salutation else 'RTN PPF'  end ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like 'RTN PPF%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'RTN PP',' ') ,Salutation=CASE when Salutation is not null then 'RTN PP ' + Salutation else 'RTN PP'  end ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like 'RTN PP%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'RTN',' ') ,Salutation=CASE when Salutation is not null then 'RTN ' + Salutation else 'RTN'  end,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like 'RTN %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' BRIG',' ') ,Salutation=CASE when Salutation is not null then 'Brig ' + Salutation else 'Brig'  end ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% BRIG%'

-----removing the professions 

update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'FAMILY',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% FAMILY%' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'POSTMASTER',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% POSTMASTER%' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'POST MASTER',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% POST MASTER%' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'POSTMAN',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% POSTMAN%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'POST MAN',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% POST MAN%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'S I of PC',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% S I of PC%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'SI of PC',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% SI of PC%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'S I of Police',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% S I of Police%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'SI of Police',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% SI of Police%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'IPS SUP DT OF POLICE',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% IPS SUP DT OF POLICE%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'R T O',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% R T O ' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'RTO',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% RTO' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'DRO',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% DRO' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'D R O',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% D R O' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'BUS SE',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% BUS SE' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'A L I G COLO',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% A L I G COLO' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'B R T E',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% B R T E%' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'T P T C',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% T P T C%' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'TPTC',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% TPTC%' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'T P TC',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% T P TC%' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M S E N T',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% M S E N T%' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'F D A',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% F D A' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'FDA',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% FDA' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'TVS',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% TVS'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'B A G C T',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% B A G C T'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'T N E P',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%T N E P%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'TNEP',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% TNEP%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'S I S',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% S I S'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'P W D',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% P W D'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'PWD',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% PWD'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'ex',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like 'EX %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'ex',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% EX%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M E A E',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% M E A E%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'B S F',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% B S F'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'BSF',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% BSF%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'C P R F',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%C P R F%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'C R P F',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% C R P F'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'CRPF',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%CRPF%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'T N S T C',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% T N S T C'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'TNSTC',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%TNSTC%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'ReTD',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%ReTD%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'RTED',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%RTED%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'RETIRED',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%RETIRED%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'RTD',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%RTD%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'B V SC A H',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%B V SC A H%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'B V SC',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% B V SC%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'B V S C',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% B V S C'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Professional',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Professional%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Professor',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Professor%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Profeser',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Profeser%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Proff',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Proff%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Prof',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% Prof %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'PROF',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like 'PROF%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'HONRY',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%HONRY%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'CPM',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% CPM%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' THE ',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% THE %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'MANAGING',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%MANAGING%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'PARTNER',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%PARTNER%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'ADVOCATE',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end    where Name_bk like '%ADVOCATE%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'LAWYER',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end    where Name_bk like '%LAWYER%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Adv',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end    where Name_bk like 'Adv %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Adv',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% Adv'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Adv',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end    where Name_bk like '% Adv %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'THEATRE',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%THEATRE%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M A L L B M L',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%M A L L B M L%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'MJF',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like 'MJF%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'MJF',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% MJF%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'I O B',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% I O B'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'IOB',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% IOB'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'IOB',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% IOB %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'I O B',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% I O B%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'IOC',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% IOC'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'I O C',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% I O C'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'IOC',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% IOC%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'I O C',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% I O C%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'nurse',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%nurse%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Teacher',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Teacher%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'inspector',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%inspector%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Army',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Army%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'manager',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%manager%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'ELECTRICIAN',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%ELECTRICIAN%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'ELECTRICITY',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%ELECTRICITY%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'PLUMBER',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%PLUMBER%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'CARPENTER',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%CARPENTER%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'CONDUCTER',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%CONDUCTER%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'CONDUCTOR',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%CONDUCTOR%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'SPECIALIST',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%SPECIALIST%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'electric',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%electric%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Board',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Board%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Police',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Police%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'superintendent',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%superintendent%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'sup',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% sup %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'electric',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%electric%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Board',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Board%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Police',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Police%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Maths',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Maths %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'English',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%English%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Science',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Science%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Software',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%SoftwarE%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Senior',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Senior%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'General',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%General%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' Jawan',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Jawan %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Director',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Director%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'President',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%President%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Chief',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Chief%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'OfficeR',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%OfficeR%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Office',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Office%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Engineer',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Engineer%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Engg',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Engg%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Student',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Student%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Assistant',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Assistant%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Asst',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Asst%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Major',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Major%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Minor',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Minor%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Collector',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Collector%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Social',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Social%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Representative',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Representative%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Medical Rep',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Medical Rep%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Advocate',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Advocate%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Driver',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Driver%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Principal',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Principal%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Pricipal',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Pricipal%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Sarpanch',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%Sarpanch%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Commissioner',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%Commissioner%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Agent',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% Agent%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'LIC',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% LIC'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'L I C',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% L I C'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Auto',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Auto%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Carpenter',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Carpenter%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Accountant',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Accountant%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Reporter',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Reporter%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Press',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Press%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Clerk',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Clerk%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Railway',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Railway%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Southern',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Southern%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'South',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% South %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Bank',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Bank %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'SRly',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%SRly%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Lecturer',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Lecturer%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Deputy',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Deputy%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Assist',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Assist%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'RTD',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% RTD'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Customer',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%Customer%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Chair',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Chair %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Person',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Person%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Chairman',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Chairman%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Street',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%Street%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'SUPD GR II',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%SUPD GR II%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'of',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% of %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'SUPD',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% SUPD%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Justice',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%Justice%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Judge',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%Judge%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Civil',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%Civil%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Criminal',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%Criminal%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Jail',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Jail%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Deptartment',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Deptartment%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Dept',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Dept%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Health',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Health%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Rama Temple',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Rama Temple%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Temple',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Temple%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Assit',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% Assit%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'FG OFFR',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%FG OFFR%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'OFFR',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%OFFR%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Lecture',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% Lecture%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Lecture',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% Lecture %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'IPS',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% IPS'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'IAS',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% IAS'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'IFS',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% IFS'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' I P S',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% I P S%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' I A S',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% I A S%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' I F S',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%I F S%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' SI',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% SI'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' S I',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% S I'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' TN EB',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% TN EB'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' TNEB',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%TNEB%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' T N E B',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%T N E B%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' AEE',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% AEE'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' D E O',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% D E O'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' D E O',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% D E O%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' DEO',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% DEO'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' E E O',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% E E O%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' D P O',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% D P O'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' B E M S',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% B E M S'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' D C E',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% D C E'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' BATC',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% BATC'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' S P M',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% S P M'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' BR Manager',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% BR Manager'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' Branch Manager',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% Branch Manager'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' VP',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% VP'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' Officer',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% Officer'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' SR',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% Sr %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' mgr',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%mgr%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' Vice',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% Vice %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' PC',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% PC'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' M V SC',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% M V SC'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'LIC AGEnt',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end    where Name_bk like '%LIC AGEnt%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'LIC AGE',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end    where Name_bk like '%LIC AGE%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'FCA ',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% FCA%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'F C A',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% F C A%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' BT',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% BT'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' HM',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% HM'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' HC',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% HC'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' BI',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% BI'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' QC',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% QC'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' TR',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% TR'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' ER',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% ER'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' TV',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% TV'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' JR',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% JR'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' CI',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% CI'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' CA',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% CA'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' SR',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% SR'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' AM',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% AM'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' EO',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% EO'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' PT',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% PT'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' SBI',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% SBI'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' RTD',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% RTD'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' VAO',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% VAO'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' H M',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% H M'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' TPBO',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% TPBO'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' EX',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% EX'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'EX',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% EX '
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'MLA',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% MLA %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'AGM',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% AGM %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'BSNL',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% BSNL %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'MTNL',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% MTNL % '
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' EX M C',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% EX m C'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' ASI',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% ASI'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'CDR ',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like 'CDR %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'WG CDR ',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like 'WG CDR %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'HOD',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% HOD %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' UG',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% UG'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M P H A M',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% M P H A M'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'NO',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% NO %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Fort',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%Fort%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'GODUR S B',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% GODUR S B %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'GODUR',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% GODUR %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'DNB GM',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%DNB GM%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'S M T C',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% S M T C %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'TPTC',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%TPTC%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' TP TC',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% TP TC %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'EX',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% EX %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' BSF',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% BSF %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' B S F',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% B S F %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' G P H C',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%G P H C%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' GPHC',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%GPHC%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' J A O',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%J A O%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' A C B',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%A C B%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' RTid',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%rtid%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' D S P',' ') ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '%D S P%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' S Rly',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% S Rly%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' T N S T C',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% T N S T C %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' B S M S',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%B S M S%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' Service Man',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%Service Man%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' ServiceMan',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%ServiceMan%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' COND',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% COND'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' T S T C',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% T S T C %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' B S N L',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% B S N L%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' BSNL',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% BSNL%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' V A O',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% V A O%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' Crime',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% Crime%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' Section',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%Section%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' D E E E D A C T',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% D E E E D A C T%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' V S S R',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% V S S R%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' G S R A',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% G S R A%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' K S D J',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% K S D J%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' TNHB',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% TNHB%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' T N H B',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% T N H B%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' BHEL',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% BHEL%' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' B H E L',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% B H E L%' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' S I of PC',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% S I of PC%' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' P E T',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% P E t' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' FAMILY',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '%FAMILY%' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'AAO',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% AAO' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'A A O',' ')  ,[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% A A O'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'RET',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end    where Name_bk like '% RET'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'RETD',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% RETD'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'G P J P',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% G P J P'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'GPJP',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end   where Name_bk like '% GPJP'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'LIC',' '),[Profession]=CASE when [Profession] is null then 1  else [Profession]+1 end  where Name_bk like '% LIC %'

---removing the excess spaces

update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'  ',' ')  where Name_bk like '%  %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'   ',' ')  where Name_bk like '%   %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'    ',' ')  where Name_bk like '%    %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'     ',' ')  where Name_bk like '%     %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'      ',' ')  where Name_bk like '%      %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'       ',' ')  where Name_bk like '%       %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'        ',' ')  where Name_bk like '%        %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'         ',' ')  where Name_bk like '%         %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'          ',' ')  where Name_bk like '%          %'


-----removing the abbrevations of degree,country,profession
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'BE MBA',' ') ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '%BE MBA%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'B E M B A',' ') ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '%B E M B A%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'B COM R I M P',' ')  ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end  where Name_bk like '%B COM R I M P' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'B A B E D',' ') ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '%B A B E D'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'B S C',' ') ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% B S C'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'BSC',' ') ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% BSC'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'BSC',' ') ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% BSC %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'BA BL',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% BA BL%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'BABL',' ') ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end  where Name_bk like '% BABL %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'MABL',' ') ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end  where Name_bk like '% MABL %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M A B L',' ') ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end  where Name_bk like '%M A B L%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'LLB',' ') ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end  where Name_bk like '%LLB%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'L L B',' ') ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end  where Name_bk like '% L L B%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M PHIL',' ') ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% M PHIL'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'MPHIL',' ') ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% MPHIL%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M PHIL',' ') ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% M PHIL %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'MA MED M P',' ')  ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end  where Name_bk like '%MA MED M P%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M B A',' ')  ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end  where Name_bk like '%M B A' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'MBA',' ')  ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end  where Name_bk like '%MBA'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'B B A',' ')  ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end  where Name_bk like '%B B A' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'BBA',' ')  ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end  where Name_bk like '%BBA'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' MBBS',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% MBBS%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'MBBS',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end  where Name_bk like '% M B B S%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' BE',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end  where Name_bk like '% BE'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' B ED',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end where Name_bk like '% B ED%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' Btech',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% Btech%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' B tech',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% B tech%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' FRCS',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% FRCS%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' US',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end  where Name_bk like '% US'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' UK',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end  where Name_bk like '% UK'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' MECH',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% MECH'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' ME',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% ME'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' Mtech',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% Mtech%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' M tech',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% M tech%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' Phd',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% Phd%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' BA',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end  where Name_bk like '% BA'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' BALLB',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% BALLB%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' BA LLB',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% BA LLB%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' BABL',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% BABL'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' BL',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% BL'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' M E',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% M E'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' MD',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% MD'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' B E',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% B E'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' B A',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% B A'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' MA',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% MA'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' BCom',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% BCom'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' B Com',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% B Com'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' MCom',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% MCom'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' M Com',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% M Com'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' Bsc',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% Bsc%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' B sc',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% B sc%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' B sc',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% B sc %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' B sc N',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% B sc N'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' Msc',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% Msc%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Msc',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% Msc %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Msc',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '%M sc%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M Com',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% M Com %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'MCom',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% M Com %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'B Com',' ') ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% B Com %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' B ED',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% B ED%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' BED',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% BED'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Msc',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% Msc %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Msc',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% M sc %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' M sc',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% M sc'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' MEd',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% MEd'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' M Ed',' ') ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% M ED'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' M Ed',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% M ED'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'CAIIB',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% CAIIB %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' BA BL',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% BA BL'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' BDS',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% BDS'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' B DS',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% B DS'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' B D S',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% B D S'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' M A',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% M A'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' B A',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% B A'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' MD DPM',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% MD DPM'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' MD',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% MD'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' M D',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% M D'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'MPhil',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% MPhil %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M Phil',' ') ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% M Phil%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'PHD',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% PHD %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'MBBS',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% MBBS %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M B B S',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% M B B S %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'BABL',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% BABL %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'B A B L',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% B A B L%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'PH D',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% PH D%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M A',' ') ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% M A %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M ED',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% M ED %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'MABL',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% MABL%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M A B L',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% M A B L%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M A M L',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% M A M L%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'C I D C',' ') ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% C I D C%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'CIDC',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% CIDC%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M B B S',' ') ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end   where Name_bk like '% M B B S%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'BABC',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% BABC%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'B A B C',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% B A B C%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'MBA',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% MBA'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M B A',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% M B A%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M Ped',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% M PED%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'B D S',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '%B D S'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'LLB',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% LLB'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'L L B',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% L L B'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'H S A',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% H S A'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'T V A TEX',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '%T V A TEX%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'T M C',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% T M C'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'RTD H I',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% RTD H I%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M D S',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% M D S'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'F C A',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% F C A'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'B C A',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% B C A'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'E G M',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% E G M'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M J F',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% M J F'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M PHARM',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% M PHARM'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'C P M',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% C P M'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'M D S',' '),[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end    where Name_bk like '% M D S'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'B H M S',' ')  ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end  where Name_bk like '%B H M S%' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'BHM S',' ')  ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end  where Name_bk like '% BHMS%' 
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'BHMS',' ')  ,[Qualitfication]=CASE when [Qualitfication] is null then 1  else [Qualitfication]+1 end  where Name_bk like '% BHMS' 

---removing the excess spaces

update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'  ',' ')  where Name_bk like '%  %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'   ',' ')  where Name_bk like '%   %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'    ',' ')  where Name_bk like '%    %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'     ',' ')  where Name_bk like '%     %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'      ',' ')  where Name_bk like '%      %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'       ',' ')  where Name_bk like '%       %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'        ',' ')  where Name_bk like '%        %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'         ',' ')  where Name_bk like '%         %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'          ',' ')  where Name_bk like '%          %'

---checking for saluatations again

update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Dr CH',' ') ,Salutation='Dr CH' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end   where Name_bk like 'Dr CH %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Doctor',' ') ,Salutation='Dr' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end   where Name_bk like '% Doctor%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Dr Mr',' ') ,Salutation='Dr Mr' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end   where Name_bk like 'Dr Mr %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Dr Mrs',' '),Salutation='Dr Mrs',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Dr Mrs %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Dr Mr',' ') ,Salutation='Dr Mr' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end   where Name_bk like 'Dr Mr%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Dr Mrs',' '),Salutation='Dr Mrs',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Dr Mrs%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'DrMr',' ') ,Salutation='Dr Mr' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end   where Name_bk like 'DrMr %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'DrMrs',' '),Salutation='Dr Mrs' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end    where Name_bk like 'DrMrs %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Mr ',' '),Salutation='Mr',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end    where Name_bk like 'Mr %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Mrs',' '),Salutation='Mrs',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Mrs %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'MR ',' '),Salutation='Mr',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end    where Name_bk like 'Mr %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'MRS ',' '),Salutation='Mrs',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Mrs %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' MRS',' '),Salutation='Mrs' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end    where Name_bk like '% Mrs'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Miss',' '),Salutation='Miss' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end    where Name_bk like 'Miss %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Ms ',' '),Salutation='Ms',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Ms %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Smt ',' '),Salutation='Smt' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end    where Name_bk like 'Smt%'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Chi ',' '),Salutation='Chi',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Chi %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Ch ',' '),Salutation='Ch',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Ch %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Dr ',' '),Salutation='Dr',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Dr %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,' DR',' '),Salutation='Dr' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end    where Name_bk like '% Dr'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Shri ',' '),Salutation='Shri',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Shri %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Sri ',' '),Salutation='Sri',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Sri %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'FR ',' '),Salutation='Fr',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'Fr %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'RevDr ',' '),Salutation='Rev Dr',SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end     where Name_bk like 'RevDr %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Rev Dr ',' '),Salutation='Rev Dr' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end    where Name_bk like 'Rev Dr %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Rev ',' '),Salutation='Rev' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end    where Name_bk like 'Rev %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Very Rev ',' '),Salutation='Rev' ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end    where Name_bk like 'Very Rev %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'Pastor',' '),Salutation='Pastor'  ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end   where Name_bk like 'Pastor %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'ft',' '),Salutation='Ft'  ,SalutationCount=case when SalutationCount is null then 1 else SalutationCount+1 end   where Name_bk like 'FT %'

-----remvoing the excess spaces after the earlier cleaning

update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'  ',' ')  where Name_bk like '%  %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'   ',' ')  where Name_bk like '%   %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'    ',' ')  where Name_bk like '%    %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'     ',' ')  where Name_bk like '%     %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'      ',' ')  where Name_bk like '%      %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'       ',' ')  where Name_bk like '%       %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'        ',' ')  where Name_bk like '%        %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'         ',' ')  where Name_bk like '%         %'
update [temp_vs_NameCleaning_20161216] set Name_bk=replace(Name_bk,'          ',' ')  where Name_bk like '%          %'

update [temp_vs_NameCleaning_20161216] set Name_bk=ltrim(rtrim(Name_bk))


---calculating the number of spaces to separate the names

update [temp_vs_NameCleaning_20161216]set [No of Spaces]=(SELECT LEN(Name_bk)-LEN(REPLACE(Name_bk, ' ', '')))


/*---------------------Splitting the name accordingly--------------*/


------where no of space =0

update [temp_vs_NameCleaning_20161216]set [First]=Name_bk,[cleaning process]='Done'  where [no of spaces]=0

------where no of space =1

update [temp_vs_NameCleaning_20161216]
set [First]=SUBSTRING(Name_bk, 1, CHARINDEX(' ', Name_bk) - 1),
[Last]=SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)) ,[cleaning process]='Done' 
where [No of spaces]=1 

update [temp_vs_NameCleaning_20161216]set [Initial]=Last,last='',[cleaning process]='Done'  where len([Last]) in (1)  and [Initial] is  null
update [temp_vs_NameCleaning_20161216]set [Initial]=First,First=last,last='',[cleaning process]='Done'  where len(First) in (1)  and [Initial] is  null

------where no of space =2

update [temp_vs_NameCleaning_20161216]
set [First]=SUBSTRING(Name_bk, 1, CHARINDEX(' ', Name_bk) - 1),
[Middle]=SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), 1, CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) - 1),
[last]= SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)),CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) +1,  LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))))
,[cleaning process]='Done' 
where [no of spaces]=2

update [temp_vs_NameCleaning_20161216]
set First=First+Middle+Last,middle='',last='',[cleaning process]='Done' where  len(last) in (1) and len(middle) in (1) and len(FIrst) in (1) and [no of spaces]=2

update [temp_vs_NameCleaning_20161216]
set Initial=Middle+Last,middle='',last='',[cleaning process]='Done' where  len(last) in (1) and len(middle) in (1)  and [no of spaces]=2

update [temp_vs_NameCleaning_20161216]
set Initial=Last,last=middle,middle='',[cleaning process]='Done' where  len(last) in (1)  and [no of spaces]=2

update [temp_vs_NameCleaning_20161216]
set Initial=First+Middle,First=last,last='',middle='',[cleaning process]='Done'  where   len(middle) in (1) and len(last)>3 and len(first)=1  and [no of spaces]=2

update [temp_vs_NameCleaning_20161216]
set Initial=First,First=Middle,middle='',[cleaning process]='Done'  where   len(first) in (1) and len(last)>3 and len(middle)>3  and [no of spaces]=2

update [temp_vs_NameCleaning_20161216]
set Initial=First,First=Middle,middle='' ,[cleaning process]='Done' where   len(first) in (1) and len(last)>3  and len(middle)<=3  and [no of spaces]=2

update [temp_vs_NameCleaning_20161216]
set Initial=First,First=Middle,middle='',[cleaning process]='Done'  where   len(first) in (1)  and [no of spaces]=2

update [temp_vs_NameCleaning_20161216]
set Initial=Initial+First,First=Last,middle='',Last='',[cleaning process]='Done'  where   len(first) in (1)  and [no of spaces]=2

-------where no of space =3

update [temp_vs_NameCleaning_20161216]
set [First]= SUBSTRING(Name_bk, 1, CHARINDEX(' ', Name_bk) - 1),
[Middle]=SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), 1, CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) - 1),
[Middle 1]=SUBSTRING(SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)))), 1, CHARINDEX(' ', SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))))) - 1) ,
[last]= SUBSTRING(SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)))), CHARINDEX(' ', SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))))) + 1, LEN(SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))))))
,[cleaning process]='Done' 
where  [no of spaces]=3

update [temp_vs_NameCleaning_20161216]
set Initial=First,[First]= [Middle],[Middle]=[Middle 1],[Middle 1]='',[cleaning process]='Done'  where  [no of spaces]=3 and len(first)=1  and initial is not null 


update [temp_vs_NameCleaning_20161216]
set Initial=Initial+First,[First]= [Middle],[Middle]='',[Middle 1]='',[cleaning process]='Done' where  [no of spaces]=3 and len(first)=1 and initial is not null


update [temp_vs_NameCleaning_20161216]
set Initial=Initial+First,[First]= Last,[Middle]='',[Middle 1]='',last='',[cleaning process]='Done' where  [no of spaces]=3 and len(first)=1  and initial is not null


update [temp_vs_NameCleaning_20161216]
set Initial=Middle+[Middle 1]+[Last],[Middle]='',[Middle 1]='',last='',[cleaning process]='Done' where  [no of spaces]=3 and len(last)=1 and len(middle)=1 and len([middle 1])=1 and initial is null

update [temp_vs_NameCleaning_20161216]
set Initial=[Middle 1]+[Last],[Middle]='',[Middle 1]='',last=middle ,[cleaning process]='Done' where [no of spaces]=3 and len(last)=1 and len([middle 1])=1  and initial is null

update [temp_vs_NameCleaning_20161216]
set Initial=[First]+middle+[Middle 1],
[Middle]='',[Middle 1]='',first=[Last],last='',[cleaning process]='Done'  where  [no of spaces]=3 and len(first)=1 and len(middle)=1 and len([middle 1])=1 and initial is null

update [temp_vs_NameCleaning_20161216]
set Initial=[First]+middle,
[Middle]='',[Middle 1]='',first=[Middle 1] ,[cleaning process]='Done' where  [no of spaces]=3 and len(first)=1 and len(middle)=1 and len([middle 1])>1 and initial is null

 update [temp_vs_NameCleaning_20161216]
set Initial=[First]+middle,
[Middle]='',[Middle 1]='',first=[last],last='',[cleaning process]='Done'  where  [no of spaces]=3 and len(first)=1 and len(middle)=1 and len([middle 1])=0 and initial is null

  
update [temp_vs_NameCleaning_20161216]
set Initial=[First]
,first=[middle],[Middle]=[Middle 1],[Middle 1]='',[cleaning process]='Done' where  [no of spaces]=3 and len(first)=1 and len(middle)>1 and len([middle 1])>1 and initial is null

-----where no of spaces=4


--drop table [NameCleaning_4spaces]

select * into [NameCleaning_4spaces] from [temp_vs_NameCleaning_20161216]
where  [no of spaces]=4

alter table [NameCleaning_4spaces] add [middle 2] varchar(100)


update [NameCleaning_4spaces]
set first=SUBSTRING(Name_bk, 1, CHARINDEX(' ', Name_bk) - 1) ,
middle=SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), 1, CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) - 1),
[Middle 1]=SUBSTRING(SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)))), 1, CHARINDEX(' ', SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))))) - 1),
[Middle 2]=SUBSTRING(SUBSTRING(SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)))), CHARINDEX(' ', SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))))) + 1, LEN(SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)))))), 1, CHARINDEX(' ', SUBSTRING(SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)))), CHARINDEX(' ', SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))))) + 1, LEN(SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))))))) - 1),
last=SUBSTRING(SUBSTRING(SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)))), CHARINDEX(' ', SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))))) + 1, LEN(SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)))))), CHARINDEX(' ', SUBSTRING(SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)))), CHARINDEX(' ', SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))))) + 1, LEN(SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))))))) + 1, LEN(SUBSTRING(SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)))), CHARINDEX(' ', SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))))) + 1, LEN(SUBSTRING(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk)), CHARINDEX(' ', SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))) + 1, LEN(SUBSTRING(Name_bk, CHARINDEX(' ', Name_bk) + 1, LEN(Name_bk))))))))
,[cleaning process]='Done'

update [NameCleaning_4spaces]
set initial=first+middle+[middle 1]+[middle 2],first=last,middle='',[middle 1]='',[middle 2]='',last='' ,[cleaning process]='Done'  where len(first)=1 and len(middle)=1 and len([middle 1])=1 and len([middle 2])=1  and initial is null

update [NameCleaning_4spaces]
set initial=first+middle+[middle 1],first=[middle 2] ,middle='',[middle 1]='',[middle 2]='',[cleaning process]='Done' where len(first)=1 and len(middle)=1 and len([middle 1])=1   and initial is null

update [NameCleaning_4spaces]
set initial=first+middle,first=[middle 1],middle=[middle 2],[middle 1]='',[middle 2]='',[cleaning process]='Done' where len(first)=1 and len(middle)=1    and initial is null

update [NameCleaning_4spaces]
set initial=first,first=[middle],middle=[middle 1],[middle 1]=[middle 2],[middle 2]='' ,[cleaning process]='Done' where len(first)=1    and initial is null

update [NameCleaning_4spaces]
set initial=middle+[middle 1]+[middle 2]+last,middle='',[middle 1]='',[middle 2]='',last='' ,[cleaning process]='Done'where len(last)=1 and len([middle 2])=1 and len([middle 1])=1 and  len([middle])=1  and initial is null


update [NameCleaning_4spaces]
set initial=[middle 1]+[middle 2]+last,last=middle,middle='',[middle 1]='',[middle 2]='',[cleaning process]='Done' where len(last)=1 and len([middle 2])=1 and len([middle 1])=1  and initial is null

update [NameCleaning_4spaces]
set initial=[middle 2]+last,last=[middle 1],[middle 1]='',[middle 2]='' ,[cleaning process]='Done'where len(last)=1 and len([middle 2])=1 and initial is null

update [NameCleaning_4spaces]
set initial=last,last=[middle 2],[middle 2]='',[cleaning process]='Done' where len(last)=1  and initial is null


update [temp_vs_NameCleaning_20161216]
set initial=b.initial,first=b.first,middle=b.middle,[middle 1]=b.[middle 1],last=b.last,[cleaning process]='Done'  from [temp_vs_NameCleaning_20161216]a inner join [NameCleaning_4spaces] b
on a.id=b.id
where a.[no of spaces]=4 and b.initial is not null

update [temp_vs_NameCleaning_20161216]
set initial=b.initial,first=b.first,middle=b.middle,[middle 1]=b.[middle 1]+' '+b.[middle 2],last=b.last  ,[cleaning process]='Done'  from [temp_vs_NameCleaning_20161216]a inner join [NameCleaning_4spaces] b
on a.id=b.id
where a.[no of spaces]=4 and b.initial is  null


drop table [NameCleaning_4spaces]

---changing locations basis length
UPDATE [dbo].[temp_vs_NameCleaning_20161216]
SET [INITIAL]=[FIRST],[FIRST]=[MIDDLE],MIDDLE=[MIDDLE 1],[MIDDLE 1]='',[cleaning process]='Done'
WHERE LEN([First])=2 AND LEN(MIDDLE)>1 AND LEN(LAST)>1 AND INITIAL IS NULL and first !='OM'


UPDATE [dbo].[temp_vs_NameCleaning_20161216]
SET [INITIAL]=[FIRST],[FIRST]=last,last='',[cleaning process]='Done'
WHERE LEN([First])=2 AND  LEN(LAST)>1 AND INITIAL IS NULL and [No of Spaces]=1

UPDATE [dbo].[temp_vs_NameCleaning_20161216]
SET [INITIAL]=[FIRST]+[MIDDLE],[FIRST]=[LAST],MIDDLE='',[MIDDLE 1]='',LAST='',[cleaning process]='Done'
WHERE LEN([First])=2 AND  LEN(LAST)>1 AND INITIAL IS NULL and [No of Spaces]=2 and first !='OM'

UPDATE [dbo].[temp_vs_NameCleaning_20161216]
SET [INITIAL]=[FIRST]+[MIDDLE],MIDDLE='',FIRST=[MIDDLE 1],[MIDDLE 1]='',LAST='',[cleaning process]='Done'
WHERE LEN([First])=2 AND  LEN(LAST)>1 AND INITIAL IS NULL and [No of Spaces]=3 and first !='OM'AND  LEN([MIDDLE 1])>1


UPDATE [dbo].[temp_vs_NameCleaning_20161216]
SET [INITIAL]=[FIRST],FIRST=MIDDLE,MIDDLE=[MIDDLE 1],[MIDDLE 1]='',[cleaning process]='Done'
WHERE LEN([First])=1 AND INITIAL IS NULL


UPDATE [dbo].[temp_vs_NameCleaning_20161216]
SET [INITIAL]=[FIRST],FIRST=LAST,MIDDLE='',[MIDDLE 1]='',LAST='',[cleaning process]='Done'
WHERE LEN([First])=1 

UPDATE [dbo].[temp_vs_NameCleaning_20161216]
SET [INITIAL]=LAST,LAST=[Middle 1],[MIDDLE 1]='',[cleaning process]='Done'
WHERE LEN(LAST)=1 AND INITIAL IS NULL



------checking for repeating names

select distinct id,(First+' '+[Middle]+' '+[Middle 1]+' '+Last) [Name_bk]
,(First+' '+[Middle]+' '+[Middle 1]+' '+Last) [Value],0 Repeating into #T from [temp_vs_NameCleaning_20161216]

update #T set Name_bk=replace(Name_bk,'  ',' '),Value=replace(Value,'  ',' ')   where Name_bk like '%  %'
update #T set Name_bk=replace(Name_bk,'   ',' '),Value=replace(Value,'  ',' ')   where Name_bk like '%   %'
update #T set Name_bk=replace(Name_bk,'    ',' ') ,Value=replace(Value,'  ',' ')  where Name_bk like '%    %'
update #T set Name_bk=replace(Name_bk,'     ',' '),Value=replace(Value,'  ',' ')   where Name_bk like '%     %'
update #T set Name_bk=replace(Name_bk,'      ',' '),Value=replace(Value,'  ',' ')   where Name_bk like '%      %'
update #T set Name_bk=replace(Name_bk,'       ',' '),Value=replace(Value,'  ',' ')   where Name_bk like '%       %'
update #T set Name_bk=replace(Name_bk,'        ',' '),Value=replace(Value,'  ',' ')   where Name_bk like '%        %'
update #T set Name_bk=replace(Name_bk,'         ',' '),Value=replace(Value,'  ',' ')   where Name_bk like '%         %'
update #T set Name_bk=replace(Name_bk,'          ',' '),Value=replace(Value,'  ',' ')   where Name_bk like '%          %'


update T
set Value = NewValue
from (
       select T1.ID,
              Value,
              stuff((select ' ' + T4.Value
                     from (
                            select T3.X.value('.', 'nvarchar(max)') as Value,
                                   row_number() over(order by T3.X) as rn
                            from T2.X.nodes(' x') as T3(X)
                          ) as T4
                     group by T4.Value
                     order by min(T4.rn)
                     for xml path(''), type).value('.',  'nvarchar(max)'), 1, 1, '') as NewValue
       from #T as T1
         cross apply (select cast('<x>'+replace(T1.Value, ' ', '</x><x>')+'</x>' as xml)) as T2(X)
     ) as T



update #T
set [Repeating]=1
where [Name_bk]!=Value


update [temp_vs_NameCleaning_20161216]
set RepeatingName=[Repeating]
from [temp_vs_NameCleaning_20161216] a inner join #T b
on a.id=b.id

drop table #T


---cleaning is required
update [temp_vs_NameCleaning_20161216] 
set [cleaning process]='Manual Checking Required'
WHERE [cleaning process] is null


---making all other values null

update [temp_vs_NameCleaning_20161216] set CompanyName=0 where CompanyName is null
update [temp_vs_NameCleaning_20161216] set Relationship=0 where Relationship is null
update [temp_vs_NameCleaning_20161216] set SpecialCharacters=0 where SpecialCharacters is null
update [temp_vs_NameCleaning_20161216] set Profession=0 where Profession is null
update [temp_vs_NameCleaning_20161216] set Qualitfication=0 where Qualitfication is null
update [temp_vs_NameCleaning_20161216] set Numerics=0 where Numerics is null
update [temp_vs_NameCleaning_20161216] set SalutationCount=0 where SalutationCount is null
update [temp_vs_NameCleaning_20161216] set JunkName=0 where JunkName is null
update [temp_vs_NameCleaning_20161216] set CelebrityName=0 where CelebrityName is null
update [temp_vs_NameCleaning_20161216] set RepeatingName=0 where RepeatingName is null

update [temp_vs_NameCleaning_20161216] 
set TotalError=(CompanyName+Relationship+SpecialCharacters+Profession+Qualitfication+Numerics+SalutationCount+JunkName+CelebrityName+RepeatingName)

