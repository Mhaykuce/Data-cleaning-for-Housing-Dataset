SELECT *
FROM NashvilleHousing

--Data Cleaning for Nashville Housing Dataset

--Standardize the date
SELECT SaleDate, CONVERT (DATE, Saledate) Sale_Date
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD Sale_Date DATE

UPDATE NashvilleHousing
SET Sale_Date = CAST (SaleDate AS DATE)


--Populate the address (especially the rows with null values)
	-- For us to populate the null values, we have to check for a reference point. 
	--i.e check for a character of the property e.g I.D that is common with both properties
	--and another character that distinguishes them. Then populate the rows with null values,
	--with the corresponding address.

SELECT NH_A.ParcelID, NH_A.PropertyAddress, NH_B.ParcelID, NH_B.PropertyAddress, ISNULL (NH_A.PropertyAddress, NH_B.PropertyAddress)
FROM NashvilleHousing AS NH_A
JOIN NashvilleHousing AS NH_B
ON NH_A.ParcelID = NH_B.ParcelID
AND NH_A.[UniqueID ] <> NH_B.[UniqueID ]
WHERE NH_A.PropertyAddress is null

UPDATE NH_A
SET PropertyAddress = ISNULL (NH_A.PropertyAddress, NH_B.PropertyAddress)
FROM NashvilleHousing AS NH_A
JOIN NashvilleHousing AS NH_B
ON NH_A.ParcelID = NH_B.ParcelID
AND NH_A.[UniqueID ] <> NH_B.[UniqueID ]
WHERE NH_A.PropertyAddress is null

--Populate the owner's address
SELECT Property_Address, Owner_Address, ISNULL (Owner_Address,Property_Address) AS Owner__address
FROM NashvilleHousing
WHERE Owner_Address IS NULL

UPDATE NashvilleHousing
SET Owner_Address = ISNULL (Owner_Address,Property_Address)


--Populate the owner's City
SELECT City, ISNULL (Owner_City, City)
FROM NashvilleHousing
WHERE Owner_City IS NULL

UPDATE NashvilleHousing
SET Owner_City = ISNULL (Owner_City, City)


-- Populate the null values in the OwnerName column using the Owner_address as reference point
-- i.e if two properties has the same owner's address, it basically means that they are owned by the same person.
-- so we populate the null row in the Onwer's name with the corresponding value of the owner's address.

select T1.OwnerName, T2.OwnerName, T1.Owner_Address, T2.Owner_Address
from NashvilleHousing T1
join NashvilleHousing T2
on T1.Owner_Address = T2.Owner_Address
where T1.OwnerName is null and T2.OwnerName is not null


UPDATE T1
SET T1.OwnerName = T2.OwnerName
FROM NashvilleHousing T1
join NashvilleHousing T2
on T1.Owner_Address = T2.Owner_Address
where T1.OwnerName is null and T2.OwnerName is not null

--Populate the Owner_state

select  case 
when Owner_City = ' NASHVILLE' then 'TN'
when Owner_City = ' OLD HICKORY' then 'TN'
when Owner_City = ' WHITES CREEK' then 'NY'
when Owner_City = ' MOUNT JULIET' then 'TN'
when Owner_City = ' JOELTON' then 'TN'
when Owner_City = ' GOODLETTSVILLE' then 'TN'
when Owner_City = ' ANTIOCH' then 'CA'
when Owner_City = ' BELLEVUE' then 'WA'
when Owner_City = ' FRANKLIN' then 'TN'
when Owner_City = ' MADISON' then 'WI'
when Owner_City = ' NOLENSVILLE' then 'TN'
when Owner_City = ' HERMITAGE' then 'PA'
when Owner_City = ' BRENTWOOD' then 'CA'
else  Owner_city
end
from NashvilleHousing

--updating the table
UPDATE NashvilleHousing
SET Owner_state = case 
when Owner_City = ' NASHVILLE' then 'TN'
when Owner_City = ' OLD HICKORY' then 'TN'
when Owner_City = ' WHITES CREEK' then 'NY'
when Owner_City = ' MOUNT JULIET' then 'TN'
when Owner_City = ' JOELTON' then 'TN'
when Owner_City = ' GOODLETTSVILLE' then 'TN'
when Owner_City = ' ANTIOCH' then 'CA'
when Owner_City = ' BELLEVUE' then 'WA'
when Owner_City = ' FRANKLIN' then 'TN'
when Owner_City = ' MADISON' then 'WI'
when Owner_City = ' NOLENSVILLE' then 'TN'
when Owner_City = ' HERMITAGE' then 'PA'
when Owner_City = ' BRENTWOOD' then 'CA'
else  Owner_city
end
from NashvilleHousing


--Standardize the Address (breakup the address)
--Property address
SELECT 
	PARSENAME (REPLACE(PropertyAddress, ',','.'), 2),
	PARSENAME (REPLACE(PropertyAddress, ',','.'), 1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD Property_Address nvarchar(255)

UPDATE NashvilleHousing
SET Property_Address = PARSENAME (REPLACE(PropertyAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
ADD City nvarchar(255)

UPDATE NashvilleHousing
SET City = PARSENAME (REPLACE(PropertyAddress, ',','.'), 1)


-- Break-up owner address
SELECT 
	PARSENAME (REPLACE(OwnerAddress, ',','.'), 3),
	PARSENAME (REPLACE(OwnerAddress, ',','.'), 2),
	PARSENAME (REPLACE(OwnerAddress, ',','.'), 1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD Owner_Address nvarchar(255)

UPDATE NashvilleHousing
SET Owner_Address = PARSENAME (REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
ADD Owner_City nvarchar(255)

UPDATE NashvilleHousing
SET Owner_City = PARSENAME (REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
ADD Owner_state nvarchar(255)

UPDATE NashvilleHousing
SET Owner_state = PARSENAME (REPLACE(OwnerAddress, ',','.'), 1)



--Removing Duplicates 
	--In looking for duplicates, we choose columns that if perhaps any two rows has the same values, then it must be a duplicate.
	--And we can do this by using a CTE because we will query the result set.

WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY 
	ParcelID, 
	PropertyAddress, 
	SaleDate, 
	LegalReference 
	ORDER BY UniqueID) Row_Num
FROM NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE Row_Num > 1
ORDER BY [UniqueID ]

--DELETE
DELETE
FROM RowNumCTE
WHERE Row_Num > 1


--Standardize text formats
--Checking the preferred value which is the one with the highest number
SELECT DISTINCT (SoldAsVacant), COUNT (SoldasVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant


--Re-organise the values in the rows using case stetements
SELECT SoldAsVacant,
	CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
		 WHEN SoldasVacant = 'N' THEN 'No'
	ELSE SoldasVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
		 WHEN SoldasVacant = 'N' THEN 'No'
	ELSE SoldasVacant
	END


--DELETE IRRELEVANT COLUMN
ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict