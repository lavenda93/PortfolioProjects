
  --Cleaning Data in SQL
  */


  Select *
  From [Nashville Housing Data for Data Cleaning]

-------------------------------------------------------------------------

-- Let's standardize the date Format

Select SaleDate, CONVERT(date, SaleDate)
  From [Nashville Housing Data for Data Cleaning]

------------------------------------------------------------------------

--Populating  Property Address data

Select *
  From [Nashville Housing Data for Data Cleaning]
--Where PropertyAddress IS NULL
order by ParcelID

  Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
  From [Nashville Housing Data for Data Cleaning] a
  Join [Nashville Housing Data for Data Cleaning] b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

Update a
SET propertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
From [Nashville Housing Data for Data Cleaning] a
  Join [Nashville Housing Data for Data Cleaning] b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

------------------------------------------------

--Breaking out Address into Individual Column (Address, City, State)


--PropertyAddress into Address and City

Select PropertyAddress 
  From [Nashville Housing Data for Data Cleaning]
--Where PropertyAddress IS NULL
--order by ParcelID

Select
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(propertyAddress)) as Address
From [Nashville Housing Data for Data Cleaning]


ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add PropertySplitAddress Nvarchar(255);


Update [Nashville Housing Data for Data Cleaning]
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add PropertySplitCity Nvarchar(255);


Update [Nashville Housing Data for Data Cleaning]
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(propertyAddress))



--Breaking the Owner Address into Address, City and State


Select OwnerAddress
From [Nashville Housing Data for Data Cleaning]

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From [Nashville Housing Data for Data Cleaning]



ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add OwnerSplitAddress Nvarchar(255);

Update [Nashville Housing Data for Data Cleaning]
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add OwnerSplitCity Nvarchar(255);

Update [Nashville Housing Data for Data Cleaning]
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add OwnerSplitState Nvarchar(255);

Update [Nashville Housing Data for Data Cleaning]
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

---------------------------------------------------------------------

--Change 0 and 1 to Yes and No in "Sold as"Vacant" field


Select Distinct(SoldAsVacant), count(soldasvacant)
From [Nashville Housing Data for Data Cleaning]
Group by SoldAsVacant
order by 2

--(SoldAsVacant Column was in 'bit'data type, so I converted it to varchar first

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ALTER  COLUMN SoldAsVacant varchar(255)


Select SoldAsVacant,
CASE when SoldAsVacant ='0' THEN 'No'
		when SoldAsVacant = '1' THEN 'Yes'
		ELSE SoldAsVacant
		END
From [Nashville Housing Data for Data Cleaning]


Update [Nashville Housing Data for Data Cleaning]
SET SoldAsVacant = CASE when SoldAsVacant ='0' THEN 'No'
		when SoldAsVacant = '1' THEN 'Yes'
		ELSE SoldAsVacant
		END



---------------------------------------------------------------------------

--Remove Duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY 
		UniqueID
		) row_num

From [Nashville Housing Data for Data Cleaning]
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
order by PropertyAddress



WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY 
		UniqueID
		) row_num

From [Nashville Housing Data for Data Cleaning]
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1




------------------------------------------------------------
--Delete unused columns



ALTER TABLE [Nashville Housing Data for Data Cleaning]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Nashville Housing Data for Data Cleaning]
DROP COLUMN SaleDate


Select *
  From [Nashville Housing Data for Data Cleaning]
