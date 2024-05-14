/*

Data Cleaning Through SQL

Skills Used: Converting Data Types, Joining Tables, Splitting Columns with SUBSTRING AND PARSENAME, 
			 Updating column values, Removing Duplicates Using CTE, Dropping Columns

*/



--Standardize Date Format
Select SaleDate, CONVERT(Date, SaleDate) as SaleDateConverted
From Portfolio..NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)



--Populate Property Address Data 
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, B.PropertyAddress) 
From Portfolio..NashvilleHousing a join Portfolio..NashvilleHousing b on a.ParcelID = b.ParcelID and a.UniqueID != b.UniqueID
Where a.PropertyAddress is Null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, B.PropertyAddress) 
From Portfolio..NashvilleHousing a join Portfolio..NashvilleHousing b on a.ParcelID = b.ParcelID and a.UniqueID != b.UniqueID
Where a.PropertyAddress is Null



--Separate Address into Individual Columns Using SUBSTRING
Select PropertyAddress
From Portfolio..NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From Portfolio..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashVilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashVilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



--Separating Owner Address into Individual Columns with PARSENAME (PARSENAME searches for periods so we have to change our commas)
Select OwnerAddress
From Portfolio..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From Portfolio..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashVilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashVilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashVilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



--Changing 0 and 1 to Yes and No in "Sold as Vacant" Column
ALTER TABLE NashvilleHousing
ALTER COLUMN SoldAsVacant nvarchar(10)

Select SoldAsVacant,
CASE When SoldAsVacant = 0 THEN 'No' 
	 When SoldAsVacant = 1 THEN 'Yes'
	 END
From Portfolio..NashVilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 0 THEN 'No' 
				   When SoldAsVacant = 1 THEN 'Yes'
				   END



--Remove Duplicates Using CTE
WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER By UniqueID) row_num
From Portfolio..NashVilleHousing)

DELETE
From RowNumCTE
Where row_num > 1



--Delete Unused Columns
Select * 
From Portfolio..NashvilleHousing

ALTER TABLE Portfolio..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict




