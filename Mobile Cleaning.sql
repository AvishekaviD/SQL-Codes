USE [Kalyan_Temp]
GO
/****** Object:  StoredProcedure [dbo].[usp_mobilecleaning]    Script Date: 12/28/2016 4:37:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-----------------------------------------------------------------------------------

Script Name:- Data Cleaning-Mobile
Created Date:- 28/03/2016
Created by :- Vikram Santhanam
Last Updated on:- 19/03/2016
Last Updated by : Vikram Santhanam
Script Description:- this script is used for 
                    1.Cleaning mobile numbers
                    2.Validating mobile numbers

Please ensure dependent repository files are copied to your database
Input Variables:- Database name,Source table Name, Primary key Identifier of source table,Column Name form Source table                                                                       
Version:- 1.6
-----------------------------------------------------------------------------------*/

--exec dbo.usp_mobilecleaning
ALTER procedure [dbo].[usp_mobilecleaning]
as

/*----------------------Moving the mobile from raw data to destination table-----------------------*/

truncate table [temp_vs_MobileCleaning_20160629]

insert into [temp_vs_MobileCleaning_20160629]([Mobile],[Mobile backup])
SELECT distinct [MobileNumber] 'Mobile',[MobileNumber] 'Mobile backup'
FROM  [Kalyan_Temp].[dbo].[Query]


--Drop table [temp_vs_MobileCleaning_20160629]

/*-----------cleaning the mobile field of special characters and alphabets for only those records which have special characters in them--------------------------*/


----removing special characters
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'[PP]',''),[Special Characters]='Y'  where Mobile like '%[PP]%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'!',''),[Special Characters]='Y'   where Mobile like '%!%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'@',''),[Special Characters]='Y'   where Mobile like '%@%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'#',''),[Special Characters]='Y'   where Mobile like '%#%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'$',''),[Special Characters]='Y'   where Mobile like '%$%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'&',''),[Special Characters]='Y'   where Mobile like '%&%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'*',''),[Special Characters]='Y'   where Mobile like '%*%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'(',''),[Special Characters]='Y'   where Mobile like '%(%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,')',''),[Special Characters]='Y'   where Mobile like '%)%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'-','') ,[Special Characters]='Y'  where Mobile like '%-%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'+',''),[Special Characters]='Y'   where Mobile like '%+%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'=',''),[Special Characters]='Y'   where Mobile like '%=%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'{','') ,[Special Characters]='Y'  where Mobile like '%{%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'}',''),[Special Characters]='Y'   where Mobile like '%}%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'[','') ,[Special Characters]='Y'  where Mobile like '%[%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,']','') ,[Special Characters]='Y'  where Mobile like '%]%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,':',''),[Special Characters]='Y'   where Mobile like '%:%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,';','') ,[Special Characters]='Y'  where Mobile like '%;%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'/',''),[Special Characters]='Y'   where Mobile like '%/%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'?','') ,[Special Characters]='Y'  where Mobile like '%?%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'.','') ,[Special Characters]='Y'  where Mobile like '%.%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,',','') ,[Special Characters]='Y'  where Mobile like '%,%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'>','') ,[Special Characters]='Y'  where Mobile like '%>%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'<','') ,[Special Characters]='Y'  where Mobile like '%<%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'`',''),[Special Characters]='Y'   where Mobile like '%`%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'~','') ,[Special Characters]='Y'  where Mobile like '%~%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'[','') ,[Special Characters]='Y'  where Mobile like '%[%'


----removing alphabets



update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'i','1'),[Alphabets]='Y'  where Mobile like '%[0-9]i[0-9]%' and len(Mobile) in (10) and left(mobile,1) in ('7','8','9')
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'i','1'),[Alphabets]='Y'  where Mobile like '%[0-9]i[0-9]%' and len(Mobile) in (11) and left(mobile,2) in ('07','08','09')
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'i','1'),[Alphabets]='Y'  where Mobile like '%[0-9]i[0-9]%' and len(Mobile) in (12) and left(mobile,3) in ('917','918','919')
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'i','1'),[Alphabets]='Y'  where Mobile like '%[0-9]i[0-9]%' and len(Mobile) in (14) and left(mobile,5) in ('00918','00919','00917')
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'i',''),[Alphabets]='Y'  where Mobile like '%i%' 

update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'o','0'),[Alphabets]='Y'  where Mobile like '%[0-9]o[0-9]%' and len(Mobile) in (10) and left(mobile,1) in ('7','8','9')
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'o','0'),[Alphabets]='Y'  where Mobile like '%[0-9]o[0-9]%' and len(Mobile) in (11) and left(mobile,2) in ('07','08','09','o7','o8','o9')
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'o','0'),[Alphabets]='Y'  where Mobile like '%[0-9]o[0-9]%' and len(Mobile) in (12) and left(mobile,3) in ('917','918','919')
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'o','0'),[Alphabets]='Y'  where Mobile like '%[0-9]o[0-9]%' and len(Mobile) in (14) and left(mobile,5) in ('00918','00919','00917','0o917','o0917','oo917','0o918','o0918','oo918','0o919','o0919','oo919')
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'o',''),[Alphabets]='Y'  where Mobile like '%o%' 



update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'a',''),[Alphabets]='Y'  where Mobile like '%a%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'b',''),[Alphabets]='Y'  where Mobile like '%b%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'c',''),[Alphabets]='Y'  where Mobile like '%c%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'d',''),[Alphabets]='Y'  where Mobile like '%d%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'e',''),[Alphabets]='Y'  where Mobile like '%e%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'f',''),[Alphabets]='Y'  where Mobile like '%f%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'g',''),[Alphabets]='Y'  where Mobile like '%g%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'h',''),[Alphabets]='Y'  where Mobile like '%h%'
--update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'i',''),[Alphabets]='Y'  where Mobile like '%i%' 
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'j',''),[Alphabets]='Y'  where Mobile like '%j%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'k',''),[Alphabets]='Y'  where Mobile like '%k%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'l',''),[Alphabets]='Y'  where Mobile like '%l%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'m',''),[Alphabets]='Y'  where Mobile like '%m%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'n',''),[Alphabets]='Y'  where Mobile like '%n%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'p',''),[Alphabets]='Y'  where Mobile like '%p%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'q',''),[Alphabets]='Y'  where Mobile like '%q%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'r',''),[Alphabets]='Y'  where Mobile like '%r%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'s',''),[Alphabets]='Y'  where Mobile like '%s%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'t',''),[Alphabets]='Y'  where Mobile like '%t%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'u',''),[Alphabets]='Y'  where Mobile like '%u%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'v',''),[Alphabets]='Y'  where Mobile like '%v%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'w',''),[Alphabets]='Y'  where Mobile like '%w%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'x',''),[Alphabets]='Y'  where Mobile like '%x%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'y',''),[Alphabets]='Y'  where Mobile like '%y%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'z',''),[Alphabets]='Y'  where Mobile like '%z%'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'Â',''),[Alphabets]='Y'  where Mobile like '%Â%'
update [temp_vs_MobileCleaning_20160629]    set Mobile=replace(Mobile,'Ã',''),[Alphabets]='Y'  where Mobile like '%Ã%'
update [temp_vs_MobileCleaning_20160629]    set Mobile=replace(Mobile,'ƒ',''),[Alphabets]='Y'  where Mobile like '%ƒ%'
update [temp_vs_MobileCleaning_20160629]    set Mobile=replace(Mobile,'¢',''),[Alphabets]='Y'  where Mobile like '%¢%'
update [temp_vs_MobileCleaning_20160629]    set Mobile=replace(Mobile,'€',''),[Alphabets]='Y'  where Mobile like '%€%'
update [temp_vs_MobileCleaning_20160629]    set Mobile=replace(Mobile,'š',''),[Alphabets]='Y'  where Mobile like '%š%'
update [temp_vs_MobileCleaning_20160629]    set Mobile=replace(Mobile,'¬',''),[Alphabets]='Y'  where Mobile like '%¬%'

----removing extra unnecessary spaces post cleaning the special characters and alphabets


update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,' ','') ,[Space]='Y' where Mobile like '% %'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'  ',''),[Space]='Y'  where Mobile like '%  %'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'   ',''),[Space]='Y'  where Mobile like '%   %'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'    ',''),[Space]='Y'  where Mobile like '%    %'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'     ',''),[Space]='Y'  where Mobile like '%     %'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'      ','') ,[Space]='Y' where Mobile like '%      %'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'       ',''),[Space]='Y'  where Mobile like '%       %'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'        ','') ,[Space]='Y' where Mobile like '%        %'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'         ','') ,[Space]='Y' where Mobile like '%         %'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'          ','') ,[Space]='Y' where Mobile like '%          %'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,'      ',''),[Space]='Y'  where Mobile like '%      %'
update [temp_vs_MobileCleaning_20160629]  set Mobile=replace(Mobile,' ',''),[Space]='Y'  where Mobile like '% %'

update [temp_vs_MobileCleaning_20160629]  set [Mobile]=ltrim(rtrim(Mobile))

/*----------------------determining the validity of the mobile numbers--------------------*/


----where length is invalid 

update [temp_vs_MobileCleaning_20160629]
set [Mobile Validity]='Invalid- As the length is equal to 0,1,2,3,4,5,9',[IsMobile?]=0
where len(Mobile) in (9,0,1,2,3,4,5)  and [Mobile Validity] is null

----where length is invalid 

update [temp_vs_MobileCleaning_20160629]
set [Mobile Validity]='Invalid- As the length is >14',[IsMobile?]=0
where len(Mobile) >14 and [Mobile Validity] is null


---------where numbers are recursive

update [temp_vs_MobileCleaning_20160629]
set [Mobile Validity]='Invalid- As the data is recursive number',[IsMobile?]=0
where Mobile like '%000000000%' or Mobile like '%222222222%' or  Mobile like '%111111111%'or  Mobile like '%333333333%' or  Mobile like '%444444444%'
or  Mobile like '%6666666666%' or  Mobile like '%5555555555%' or  Mobile like '%777777777%' or  Mobile like '%888888888%' or  Mobile like '%999999999%'
or  Mobile like '12345678%'
and [Mobile Validity] is null

-------where  length is 10 and starts with 9,7,8

update [temp_vs_MobileCleaning_20160629]
set [Mobile Validity]='Valid- As the length is 10 and starts with 9,7,8',[IsMobile?]=b.[IsMobile?],[Final Mobile]=right([Mobile],10)
from Kalyan_Temp.[dbo].[temp_vs_MobileCleaning_20160629] a
inner join Kalyan_Master.[dbo].[tbl_Master_Mobile_Vs_Landline_First_4_Digits_Final] b
on left(a.Mobile,4)=b.[First 4 digits]
where len(a.Mobile)=10   and [Mobile Validity] is null

------where length is 11 and starts with 09,07,08

update [temp_vs_MobileCleaning_20160629]
set [Mobile Validity]='Valid- As the length is 11 and starts with 09,07,08',[IsMobile?]=b.[IsMobile?]
,[Length Standardization]='Y',[Final Mobile]=right([Mobile],10)
from Kalyan_Temp.[dbo].[temp_vs_MobileCleaning_20160629] a
inner join Kalyan_Master.[dbo].[tbl_Master_Mobile_Vs_Landline_First_4_Digits_Final] b
on substring(a.Mobile,2,4)=b.[First 4 digits]
where len(a.Mobile)=11 and left(a.Mobile,1)='0'  and [Mobile Validity] is null 


-----where length is 12 and starts with 919,917,918

update [temp_vs_MobileCleaning_20160629]
set [Mobile Validity]='Valid- As the length is 12 and starts with 919,917,918',[IsMobile?]=b.[IsMobile?]
,[Length Standardization]='Y',[Final Mobile]=right([Mobile],10)
from Kalyan_Temp.[dbo].[temp_vs_MobileCleaning_20160629] a
inner join Kalyan_Master.[dbo].[tbl_Master_Mobile_Vs_Landline_First_4_Digits_Final] b
on substring(a.Mobile,3,4)=b.[First 4 digits]
where len(a.Mobile)=12  and left(a.Mobile,2)='91' and [Mobile Validity] is null 


-----where length is 14 and starts with 919,917,918

update [temp_vs_MobileCleaning_20160629]
set [Mobile Validity]='Valid- As the length is 14 and starts with 00919,00917,00918'
,[IsMobile?]=b.[IsMobile?],[Length Standardization]='Y',[Final Mobile]=right([Mobile],10)
from Kalyan_Temp.[dbo].[temp_vs_MobileCleaning_20160629] a
inner join Kalyan_Master.[dbo].[tbl_Master_Mobile_Vs_Landline_First_4_Digits_Final] b
on substring(a.Mobile,5,4)=b.[First 4 digits]
where len(a.Mobile)=14    and left(a.Mobile,4)='0091' and [Mobile Validity] is null 


------all other cases setting mobile valid to invalid

update [temp_vs_MobileCleaning_20160629]
set [Mobile Validity]='Invalid',[IsMobile?]=0--,[Final Mobile]=[Mobile]
where [IsMobile?] is null -- and [Mobile Validity] is null 







