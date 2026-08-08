CREATE DATABASE urban_real_estate;
USE urban_real_estate;

CREATE TABLE properties (
    property_id INT PRIMARY KEY AUTO_INCREMENT,
    price BIGINT,
    area INT,
    location VARCHAR(150),
    no_of_bedrooms INT,
    resale INT,
    maintenance_staff INT,
    gymnasium INT,
    swimming_pool INT,
    landscaped_gardens INT,
    jogging_track INT,
    rain_water_harvesting INT,
    indoor_games INT,
    shopping_mall INT,
    intercom INT,
    sports_facility INT,
    atm INT,
    club_house INT,
    school INT,
    security_24x7 INT,
    power_backup INT,
    car_parking INT,
    staff_quarter INT,
    city VARCHAR(50)
);
UPDATE properties SET city = 'Bangalore' WHERE city IS NULL;
UPDATE properties SET city = 'Mumbai' WHERE city IS NULL;
UPDATE properties SET city = 'Hyderabad' WHERE city IS NULL;
UPDATE properties SET city = 'Delhi' WHERE city IS NULL;
UPDATE properties SET city = 'Chennai' WHERE city IS NULL;
SELECT city, COUNT(*) AS total_properties 
FROM properties 
GROUP BY city 
ORDER BY total_properties DESC;

SELECT COUNT(*) AS grand_total FROM properties;
SELECT 
    MIN(price) AS min_price, 
    MAX(price) AS max_price,
    MIN(area) AS min_area,
    MAX(area) AS max_area,
    MIN(no_of_bedrooms) AS min_bhk,
    MAX(no_of_bedrooms) AS max_bhk
FROM properties;
SELECT 
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN area IS NULL THEN 1 ELSE 0 END) AS null_area,
    SUM(CASE WHEN location IS NULL THEN 1 ELSE 0 END) AS null_location
FROM properties;
ALTER TABLE properties
ADD COLUMN price_per_sqft DECIMAL(10,2),
ADD COLUMN bhk_type VARCHAR(20),
ADD COLUMN amenity_score INT,
ADD COLUMN price_category VARCHAR(20);
UPDATE properties
SET price_per_sqft = ROUND(price / NULLIF(area, 0), 2);
UPDATE properties
SET bhk_type = CONCAT(no_of_bedrooms, 'BHK');
UPDATE properties
SET amenity_score = 
    gymnasium + swimming_pool + landscaped_gardens + jogging_track +
    rain_water_harvesting + indoor_games + shopping_mall + intercom +
    sports_facility + atm + club_house + school + security_24x7 +
    power_backup + car_parking + staff_quarter;
UPDATE properties
SET price_category = CASE
    WHEN price < 5000000 THEN 'Low'
    WHEN price BETWEEN 5000000 AND 10000000 THEN 'Mid'
    WHEN price BETWEEN 10000001 AND 20000000 THEN 'Premium'
    ELSE 'Luxury'
END;
SELECT price, area, price_per_sqft, no_of_bedrooms, bhk_type, 
       amenity_score, price_category, city
FROM properties
LIMIT 10;
SELECT 
    city,
    COUNT(*) AS total_properties,
    ROUND(AVG(price)/100000, 2) AS avg_price_lakhs,
    ROUND(AVG(price_per_sqft), 2) AS avg_price_per_sqft,
    ROUND(MIN(price)/100000, 2) AS min_price_lakhs,
    ROUND(MAX(price)/100000, 2) AS max_price_lakhs
FROM properties
GROUP BY city
ORDER BY avg_price_per_sqft DESC;
SELECT 
    city,
    bhk_type,
    COUNT(*) AS total,
    ROUND(AVG(price)/100000, 2) AS avg_price_lakhs,
    ROUND(AVG(price_per_sqft), 2) AS avg_price_sqft
FROM properties
WHERE no_of_bedrooms BETWEEN 1 AND 5
GROUP BY city, bhk_type
ORDER BY city, bhk_type;
SELECT 
    city,
    price_category,
    COUNT(*) AS total_properties,
    ROUND(AVG(price_per_sqft), 2) AS avg_price_sqft
FROM properties
GROUP BY city, price_category
ORDER BY city, 
    FIELD(price_category, 'Low', 'Mid', 'Premium', 'Luxury');
 SELECT 
    city,
    location,
    COUNT(*) AS total_listings,
    ROUND(AVG(price_per_sqft), 2) AS avg_price_sqft,
    ROUND(AVG(amenity_score), 1) AS avg_amenities
FROM properties
GROUP BY city, location
HAVING COUNT(*) >= 10   -- filter areas with enough data
ORDER BY avg_price_sqft DESC
LIMIT 10;   
    WITH amenity_bucket AS (
    SELECT 
        city,
        CASE
            WHEN amenity_score <= 3 THEN 'Basic (0-3)'
            WHEN amenity_score BETWEEN 4 AND 7 THEN 'Standard (4-7)'
            WHEN amenity_score BETWEEN 8 AND 11 THEN 'Premium (8-11)'
            ELSE 'Luxury (12+)'
        END AS amenity_level,
        price_per_sqft
    FROM properties
)
SELECT 
    city,
    amenity_level,
    COUNT(*) AS total,
    ROUND(AVG(price_per_sqft), 2) AS avg_price_sqft
FROM amenity_bucket
GROUP BY city, amenity_level
ORDER BY city, 
    FIELD(amenity_level, 'Basic (0-3)', 'Standard (4-7)', 'Premium (8-11)', 'Luxury (12+)');
    
    SELECT 
    city,
    CASE WHEN resale = 1 THEN 'Resale' ELSE 'New' END AS property_type,
    COUNT(*) AS total,
    ROUND(AVG(price_per_sqft), 2) AS avg_price_sqft
FROM properties
GROUP BY city, resale
ORDER BY city, property_type;

