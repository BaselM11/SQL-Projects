/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM NashvilleHousing


--SHOW AND UPDATE COLUMNS DATA TYPES

SELECT COLUMN_NAME,DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='NashvilleHousing'


ALTER TABLE NashvilleHousing
ADD  SaleDateConverted datetime

UPDATE  NashvilleHousing
SET SaleDateConverted = CAST(SaleDate as datetime)


-- Populate Property Address data

SELECT *
From NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing as a
JOIN NashvilleHousing as b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL or b.PropertyAddress IS NULL
ORDER BY a.ParcelID

UPDATE a
SET a.PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing as a
JOIN NashvilleHousing as b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL or b.PropertyAddress IS NULL

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL


-- Breaking out PropertyAddress into Individual Columns (Address, City, State)

SELECT PropertyAddress
From NashvilleHousing


SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashVilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))



-- Breaking out PropertyAddress into Individual Columns (Address, City, State)

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255),OwnerSplitCity nvarchar(255),OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3),
OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2),
OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT SoldAsVacant ,Count(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No'
ELSE SoldAsVacant
END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No'
ELSE SoldAsVacant
END


-- Remove Duplicates


WITH DuplicateRow
AS(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference ORDER BY ParcelID) AS RowNum
FROM NashvilleHousing)
SELECT *
FROM DuplicateRow
WHERE RowNum>1


WITH DuplicateRow
AS(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference ORDER BY ParcelID) AS RowNum
FROM NashvilleHousing)
DELETE 
FROM DuplicateRow
WHERE RowNUM>1


SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference ORDER BY ParcelID) AS RowNum
FROM NashvilleHousing
ORDER BY RowNum


-- Delete Unused Columns
SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate