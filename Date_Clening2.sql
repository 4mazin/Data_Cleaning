-- Data Cleaning In SQL

select*
from Data_Cleaning_Project2..Nashwill_Housing



---------------------------------------------------------------------------------------------

--Standardizing Data (date format)

select Sale_Date_Converted , convert(date,SaleDate)
from Data_Cleaning_Project2..Nashwill_Housing

update Nashwill_Housing
set SaleDate = cast(SaleDate as date)

ALTER TABLE Nashwill_Housing
add Sale_Date_Converted date;

update Nashwill_Housing
set Sale_Date_Converted = CONVERT(date,SaleDate)
---------------------------------------------------------------------------------------------

--populating property address data

select *
from Nashwill_Housing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress , isnull(a.PropertyAddress, b.PropertyAddress)
from Nashwill_Housing a
JOIN Nashwill_Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

	UPDATE a
	set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
	from Nashwill_Housing a
JOIN Nashwill_Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
---------------------------------------------------------------------------------------------

--Breaking Out Address Into Individual Columns

select PropertyAddress
from Data_Cleaning_Project2..Nashwill_Housing

select 
substring(propertyaddress, 1, CHARINDEX(',' , PropertyAddress)-1) AS Address
, substring(propertyaddress, CHARINDEX(',' , PropertyAddress)+1 ,len(PropertyAddress))AS City
from Nashwill_Housing

ALTER TABLE Nashwill_Housing
add Property_Split_Address nvarchar(255);

update Nashwill_Housing
set Property_Split_Address = substring(propertyaddress, 1, CHARINDEX(',' , PropertyAddress)-1) 


ALTER TABLE Nashwill_Housing
alter column Property_Split_City nvarchar(255);

update Nashwill_Housing
set Property_Split_City = substring(propertyaddress, CHARINDEX(',' , PropertyAddress)+1 ,len(PropertyAddress))

select *
from Nashwill_Housing

select OwnerAddress
from Nashwill_Housing

select
PARSENAME(REPLACE(owneraddress,',' , '.'),3),
PARSENAME(REPLACE(owneraddress,',' , '.'),2),
PARSENAME(REPLACE(owneraddress,',' , '.'),1)
from Nashwill_Housing

ALTER TABLE Nashwill_Housing
add Owner_Split_Address nvarchar(255);

update Nashwill_Housing
set Owner_Split_Address = PARSENAME(REPLACE(owneraddress,',' , '.'),3) 


ALTER TABLE Nashwill_Housing
add  Owner_Split_City nvarchar(255);

update Nashwill_Housing
set Owner_Split_City = PARSENAME(REPLACE(owneraddress,',' , '.'),2)

ALTER TABLE Nashwill_Housing
add  Owner_Split_State nvarchar(255);

update Nashwill_Housing
set Owner_Split_State = PARSENAME(REPLACE(owneraddress,',' , '.'),1)


select *
from Nashwill_Housing
---------------------------------------------------------------------------------------------

--Changing "N" And "Y" To "YES" And "NO"

select distinct(SoldAsVacant), count(SoldAsVacant)
from Nashwill_Housing
group by SoldAsVacant
order by 2

select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from Nashwill_Housing

update	Nashwill_Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


---------------------------------------------------------------------------------------------
--Removing Duplicates

with row_numCTE AS(

select * , 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 order by Uniqueid
					) row_num
from Nashwill_Housing
--order by ParcelID
)
select* 
from row_numCTE
where row_num >1


---------------------------------------------------------------------------------------------
--Deleting Unused Columns

select*
from Nashwill_Housing

alter table Nashwill_Housing
drop column owneraddress , TaxDistrict , propertyaddress

alter table Nashwill_Housing
drop column SaleDate