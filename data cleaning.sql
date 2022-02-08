/*
Cleaning Data in SQL Queries
*/


Select SaleDateFix
From NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

update NashvilleHousing
set SaleDateFix = CONVERT(date, SaleDate)

alter table NashvilleHousing
add SaleDateFix date

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


select *
from NashvilleHousing
where PropertyAddress is null


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from NashvilleHousing

select 
substring(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1) as newAdress,
substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress)) as newAdress2
from NashvilleHousing

update NashvilleHousing
set adress = substring(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1)

alter table NashvilleHousing
add adress nvarchar(255)

update NashvilleHousing
set city = substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress))

alter table NashvilleHousing
add city nvarchar(255)

select adress,city
from NashvilleHousing


select OwnerAddress
from NashvilleHousing

select
PARSENAME(REPLACE( OwnerAddress, ',','.') ,3),
PARSENAME(REPLACE( OwnerAddress, ',','.') ,2),
PARSENAME(REPLACE( OwnerAddress, ',','.') ,1)
from NashvilleHousing


update NashvilleHousing
set ownerSplitAdress = PARSENAME(REPLACE( OwnerAddress, ',','.') ,3)

alter table NashvilleHousing
add ownerSplitAdress nvarchar(255)

update NashvilleHousing
set ownerSplitCity = PARSENAME(REPLACE( OwnerAddress, ',','.') ,2)

alter table NashvilleHousing
add ownerSplitCity nvarchar(255)

update NashvilleHousing
set ownerSplitState = PARSENAME(REPLACE( OwnerAddress, ',','.') ,1)

alter table NashvilleHousing
add ownerSplitState nvarchar(255)

select *
from NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = 
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end


	
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with rowNumCTE as(
select *, ROW_NUMBER() over(
	partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	order by [UniqueID ]) row_num
from NashvilleHousing

)
select* from rowNumCTE
--where row_num > 1
order by PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


select *
from NashvilleHousing

alter table NashvilleHousing
drop column SaleDate
