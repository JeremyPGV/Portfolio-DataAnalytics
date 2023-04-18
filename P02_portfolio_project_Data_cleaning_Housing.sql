 --------------------------- /* Cleaning Data in SQL Queries */ ----------------------------


 ----------------------------Standardisation des formats de dates --------------------------

 SELECT SaleDate, CONVERT (Date, SaleDate)
 FROM PortfolioProject..Housing

 -- on veut changer le format de la colonne SaleDate
 UPDATE PortfolioProject..Housing 
 SET SaleDate = CONVERT(Date, SaleDate)

 -- Ca ne fonctionne pas, solution de contournement
 ALTER TABLE PortfolioProject..Housing
 ADD SaleDateConverted date;

 UPDATE PortfolioProject..Housing 
 SET SaleDateConverted = CONVERT(Date, SaleDate)

 SELECT SaleDateConverted, CONVERT (Date, SaleDate)
 FROM PortfolioProject..Housing


 ---------------------------- Renseigner les données relatives à l'adresse du bien --------------------------

 SELECT PropertyAddress
 FROM PortfolioProject..Housing
 Where PropertyAddress is null -- il y a bien des adress non renseignées

 -- On cherche donc un point de référence pour renseigner les adresses

 SELECT *
 FROM PortfolioProject..Housing
 --Where PropertyAddress is null 
 ORDER BY ParcelID

  -- On voit que plusieurs ParcelID ont une adresse commune alors on peut se baser sur les ParcelID pour
  -- Trouver les adresses manquantes
  -- Utilisation d'une jointure avec la table Housing et elle même

 SELECT a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) -- ISNULL(condition, conséquence)
 FROM PortfolioProject..Housing a
 JOIN PortfolioProject..Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID]<> b.[UniqueID] -- on ajoute cette condition pour être sûr de l'unicité de la ligne traitée
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..Housing a
JOIN PortfolioProject..Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID]<> b.[UniqueID]

-- On a bien enlever les noms d'adresse NULL


---------------------------- Décomposition de l'adresse en colonnes individuelles --------------------------

SELECT PropertyAddress
FROM PortfolioProject..Housing -- On remarque que le délimiteur est ',' qui sépare les adresses en 2 parties
--ORDER BY ParcelID

-- Séparation de l'adresse en 2 colonnes
-- On utilise SUBSTRING (Element dans lequel on fait la recherche,Position de l'élément que nous allons extraire,n°de pos du caractère)
-- CHARINDEX pour connaitre la position d'un caractère (-1 ou +1 pour prendre avant ou apres le délimiteur)

SELECT
SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS AddressP1, 
SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS AddressP2

FROM PortfolioProject..Housing

-- Ajout des colonnes à la table "Housing"
 ALTER TABLE PortfolioProject..Housing
 ADD PropertySplitAddress nvarchar(255);

 UPDATE PortfolioProject..Housing 
 SET PropertySplitAddress = SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE PortfolioProject..Housing
ADD PropertySplitCity nvarchar(255);

 UPDATE PortfolioProject..Housing 
 SET PropertySplitCity = SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


 SELECT*
 FROM PortfolioProject..Housing


-- Simplification du SUBSTRING

SELECT OwnerAddress --3 éléments à séparer
FROM PortfolioProject..Housing
WHERE OwnerAddress is not null


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)
FROM PortfolioProject..Housing
WHERE OwnerAddress is not null


-- Ajout des colonnes à la table "Housing"
ALTER TABLE PortfolioProject..Housing
ADD OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject..Housing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3)


ALTER TABLE PortfolioProject..Housing
ADD OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject..Housing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2)

ALTER TABLE PortfolioProject..Housing
ADD PropertySplitState nvarchar(255);

UPDATE PortfolioProject..Housing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)

SELECT*
FROM PortfolioProject..Housing





---------------------------- Changer le Y et N vers Yes et No dans le champ "Sold as vacant" --------------------------

SELECT DISTINCT(SoldAsVacant)
FROM PortfolioProject..Housing -- 4 types d'écriture dans la colone (Y/YES/N/NO)

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..Housing
GROUP by SoldAsVacant
Order BY 2

SELECT SoldAsVacant,
	CASE when SoldAsVacant ='Y' THEN 'Yes'
		 when SoldAsVacant ='N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM PortfolioProject..Housing
--where SoldAsVacant like 'N'

UPDATE PortfolioProject..Housing
SET SoldAsVacant = CASE when SoldAsVacant ='Y' THEN 'Yes'
		 when SoldAsVacant ='N' THEN 'No'
		 ELSE SoldAsVacant
		 END
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..Housing
GROUP by SoldAsVacant
Order BY 2


---------------------------- Enlever les doublons --------------------------
-- Indentification des doublons
WITH RowNUMCTE AS(
SELECT*
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID)
					row_num
FROM PortfolioProject..Housing
--ORDER BY ParcelID ne fonctionne pas donc utilisation CTE (Common Table Expression)
)
Select *
From RowNUMCTE
Where row_num > 1
Order by PropertyAddress

-- Suppression des doublons
WITH RowNUMCTE AS(
SELECT*
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID)
					row_num
FROM PortfolioProject..Housing
--ORDER BY ParcelID ne fonctionne pas donc utilisation CTE (Common Table Expression)
)
DELETE
From RowNUMCTE
Where row_num > 1



---------------------------- Suppression de colonnes non utilisées --------------------------

SELECT*
FROM PortfolioProject..Housing

ALTER TABLE PortfolioProject..Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress