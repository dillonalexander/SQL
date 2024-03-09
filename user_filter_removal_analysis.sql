
/*
Tasked with comparing filter removal behavior of users to inform design decisions. Do 
users remove single filter chips one at a time when trying to remove multiple filters, or
do they opt for the 'remove all' button to do it all at once. Not a straightforward question
as the events that trick filter removal can only tell us if a single filter or clear-all
was used -> If a user has 5 filters active and hits the remove-all button, that gets
recorded on a single line, but if the user removed each filter individually, that would be 5
records. This skews the analysis to present single filter removal as much more common if not 
considered in some way. Use below logic to assign a filter_removal_id that associates back to back single filter removals
into a single id, then a count distinct on that field will give us an accurate basis for comparison.
*/

WITH 
SEARCH_FILTER_EVENTS AS 
    (
    SELECT
    USER_ID,
    ANONYMOUS_ID,
    TIMESTAMP,
    CONTEXT_PAGE_URL,
    'Search Filter Applied' AS EVENT_TYPE,
    OBJECT_CONSTRUCT( --take large number of columns and collapse into single column (ideally already done). Also combining some columns like min and max related ones into a single larger node to reflect how the filter chips actually appear to users.
        'Accident Count', IFF(FILTER_ACCIDENT_COUNT_MAX IS NOT NULL OR FILTER_ACCIDENT_COUNT_MIN IS NOT NULL, OBJECT_CONSTRUCT(
          'Accident Count Min', FILTER_ACCIDENT_COUNT_MIN::STRING,
          'Accident Count Max', FILTER_ACCIDENT_COUNT_MAX::STRING
        ), NULL),
        'Airbags And Restraints', FILTER_AIRBAGS_AND_RESTRAINTS,
        'AutoGrade', IFF(FILTER_AUTOGRADE_MIN IS NOT NULL OR FILTER_AUTOGRADE_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'AutoGrade Min', FILTER_AUTOGRADE_MIN::STRING,
            'AutoGrade Max', FILTER_AUTOGRADE_MAX::STRING
        ), NULL),
        'Biohazard', FILTER_BIOHAZARD,
        'Body Type', FILTER_BODY_TYPE,
        'Brakes', FILTER_BRAKES,
        'CR Grade', IFF(FILTER_CR_GRADE_MIN IS NOT NULL OR FILTER_CR_GRADE_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'CR Grade Min', FILTER_CR_GRADE_MIN::STRING,
            'CR Grade Max', FILTER_CR_GRADE_MAX::STRING
        ), NULL),
        'Current Opening Bid', IFF(FILTER_CURRENT_OPENING_BID_MIN IS NOT NULL OR FILTER_CURRENT_OPENING_BID_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'Current Opening Bid Min', FILTER_CURRENT_OPENING_BID_MIN::STRING,
            'Current Opening Bid Max', FILTER_CURRENT_OPENING_BID_MAX::STRING
        ), NULL),
        'Door Count', IFF(FILTER_DOOR_COUNT_MIN IS NOT NULL OR FILTER_DOOR_COUNT_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'Door Count Min', FILTER_DOOR_COUNT_MIN::STRING,
            'Door Count Max', FILTER_DOOR_COUNT_MAX::STRING
        ), NULL),
        'Drivable', FILTER_DRIVABLE,
        'Drivetrain', FILTER_DRIVETRAIN,
        'Drivetrain Issue', FILTER_DRIVETRAIN_ISSUE,
        'Electrical Accessories', FILTER_ELECTRICAL_ACCESSORIES,
        'Engine Displacement', IFF(FILTER_ENGINE_DISPLACEMENT_MIN IS NOT NULL OR FILTER_ENGINE_DISPLACEMENT_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'Engine Displacement Min', FILTER_ENGINE_DISPLACEMENT_MIN::STRING,
            'Engine Displacement Max', FILTER_ENGINE_DISPLACEMENT_MAX::STRING
        ), NULL),
        'Engine Issue', FILTER_ENGINE_ISSUE,
        'Engine Oil', FILTER_ENGINE_OIL,
        'Engine Type', FILTER_ENGINE_TYPE,
        'Exhaust', FILTER_EXHAUST,
        'Exterior Color', FILTER_EXTERIOR_COLOR,
        'Exterior Cosmetic', FILTER_EXTERIOR_COSMETIC,
        'Exterior Rust', FILTER_EXTERIOR_RUST,
        'Fleet Use', FILTER_FLEET_USE,
        'Fluids', FILTER_FLUIDS,
        'Fuel Type', FILTER_FUEL_TYPE,
        'Glass', FILTER_GLASS,
        'Heating and AC', FILTER_HEATING_AND_AC,
        'Infotainment System', FILTER_INFOTAINMENT_SYSTEM,
        'Inspection Type', FILTER_INSPECTION_TYPE,
        'Interior Color', FILTER_INTERIOR_COLOR,
        'Interior Cosmetic', FILTER_INTERIOR_COSMETIC,
        'Interior Type', FILTER_INTERIOR_TYPE,
        'Keys', FILTER_KEYS,
        'Make', FILTER_MAKE,
        'Make Model Trim', FILTER_MAKE_MODEL_TRIM,
        'Model', FILTER_MODEL,
        'OBDII', FILTER_OBDII,
        'Odor', FILTER_ODOR,
        'Odometer', IFF(FILTER_ODOMETER_MIN IS NOT NULL OR FILTER_ODOMETER_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'Odometer Min', FILTER_ODOMETER_MIN::STRING,
            'Odometer Max', FILTER_ODOMETER_MAX::STRING
        ), NULL),
        'Odometer Discrepancy', FILTER_ODOMETER_DISCREPANCY,
        'Odometer Issue', FILTER_ODOMETER_ISSUE,
        'Open Bid', IFF(FILTER_OPEN_BID_MIN IS NOT NULL OR FILTER_OPEN_BID_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'Open Bid Min', FILTER_OPEN_BID_MIN::STRING,
            'Open Bid Max', FILTER_OPEN_BID_MAX::STRING
        ), NULL),
        'Owner Count', IFF(FILTER_OWNER_COUNT_MIN IS NOT NULL OR FILTER_OWNER_COUNT_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'Owner Count Min', FILTER_OWNER_COUNT_MIN::STRING,
            'Owner Count Max', FILTER_OWNER_COUNT_MAX::STRING
        ), NULL),
        'Pickup Location', FILTER_PICKUP_LOCATION,
        'Prior Paint', FILTER_PRIOR_PAINT,
        'Region', FILTER_REGION,
        'Seat Count', IFF(FILTER_SEAT_COUNT_MIN IS NOT NULL OR FILTER_SEAT_COUNT_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'Seat Count Min', FILTER_SEAT_COUNT_MIN::STRING,
            'Seat Count Max', FILTER_SEAT_COUNT_MAX::STRING
        ), NULL),
        'Site', FILTER_SITE,
        'State', FILTER_STATE,
        'Steering', FILTER_STEERING,
        'Structural Damage', FILTER_STRUCTURAL_DAMAGE,
        'Suspension', FILTER_SUSPENSION,
        'Title Issue Count', IFF(FILTER_TITLE_ISSUE_COUNT_MIN IS NOT NULL OR FILTER_TITLE_ISSUE_COUNT_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'Title Issue Count Min', FILTER_TITLE_ISSUE_COUNT_MIN::STRING,
            'Title Issue Count Max', FILTER_TITLE_ISSUE_COUNT_MAX::STRING
        ), NULL),
        'Transmission', FILTER_TRANSMISSION,
        'Trim', FILTER_TRIM,
        'Warning Lights', FILTER_WARNING_LIGHTS,
        'Watchlist', FILTER_WATCHLIST,
        'Wheels and Tires', FILTER_WHEELS_AND_TIRES,
        'Year', IFF(FILTER_YEAR_MIN IS NOT NULL OR FILTER_YEAR_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'Year Min', FILTER_YEAR_MIN::STRING,
            'Year Max', FILTER_YEAR_MAX::STRING
        ), NULL)
    )::STRING AS SEARCH_OPTIONS

    FROM db.SEARCH_FILTER_APPLIED_EVENTS

    UNION All

    SELECT
    USER_ID,
    ANONYMOUS_ID,
    TIMESTAMP,
    CONTEXT_PAGE_URL,
    'Search Filter Removed' AS EVENT_TYPE,
    OBJECT_CONSTRUCT(
        'Accident Count', IFF(FILTER_ACCIDENT_COUNT_MAX IS NOT NULL OR FILTER_ACCIDENT_COUNT_MIN IS NOT NULL, OBJECT_CONSTRUCT(
          'Accident Count Min', FILTER_ACCIDENT_COUNT_MIN::STRING,
          'Accident Count Max', FILTER_ACCIDENT_COUNT_MAX::STRING
        ), NULL),
        'Airbags And Restraints', FILTER_AIRBAGS_AND_RESTRAINTS,
        'AutoGrade', IFF(FILTER_AUTOGRADE_MIN IS NOT NULL OR FILTER_AUTOGRADE_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'AutoGrade Min', FILTER_AUTOGRADE_MIN::STRING,
            'AutoGrade Max', FILTER_AUTOGRADE_MAX::STRING
        ), NULL),
        'Biohazard', FILTER_BIOHAZARD,
        'Body Type', FILTER_BODY_TYPE,
        'Brakes', FILTER_BRAKES,
        'CR Grade', IFF(FILTER_CR_GRADE_MIN IS NOT NULL OR FILTER_CR_GRADE_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'CR Grade Min', FILTER_CR_GRADE_MIN::STRING,
            'CR Grade Max', FILTER_CR_GRADE_MAX::STRING
        ), NULL),
        'Current Opening Bid', IFF(FILTER_CURRENT_OPENING_BID_MIN IS NOT NULL OR FILTER_CURRENT_OPENING_BID_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'Current Opening Bid Min', FILTER_CURRENT_OPENING_BID_MIN::STRING,
            'Current Opening Bid Max', FILTER_CURRENT_OPENING_BID_MAX::STRING
        ), NULL),
        'Door Count', IFF(FILTER_DOOR_COUNT_MIN IS NOT NULL OR FILTER_DOOR_COUNT_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'Door Count Min', FILTER_DOOR_COUNT_MIN::STRING,
            'Door Count Max', FILTER_DOOR_COUNT_MAX::STRING
        ), NULL),
        'Drivable', FILTER_DRIVABLE,
        'Drivetrain', FILTER_DRIVETRAIN,
        'Drivetrain Issue', FILTER_DRIVETRAIN_ISSUE,
        'Electrical Accessories', FILTER_ELECTRICAL_ACCESSORIES,
        'Engine Displacement', IFF(FILTER_ENGINE_DISPLACEMENT_MIN IS NOT NULL OR FILTER_ENGINE_DISPLACEMENT_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'Engine Displacement Min', FILTER_ENGINE_DISPLACEMENT_MIN::STRING,
            'Engine Displacement Max', FILTER_ENGINE_DISPLACEMENT_MAX::STRING
        ), NULL),
        'Engine Issue', FILTER_ENGINE_ISSUE,
        'Engine Oil', FILTER_ENGINE_OIL,
        'Engine Type', FILTER_ENGINE_TYPE,
        'Exhaust', FILTER_EXHAUST,
        'Exterior Color', FILTER_EXTERIOR_COLOR,
        'Exterior Cosmetic', FILTER_EXTERIOR_COSMETIC,
        'Exterior Rust', FILTER_EXTERIOR_RUST,
        'Fleet Use', FILTER_FLEET_USE,
        'Fluids', FILTER_FLUIDS,
        'Fuel Type', FILTER_FUEL_TYPE,
        'Glass', FILTER_GLASS,
        'Heating and AC', FILTER_HEATING_AND_AC,
        'Infotainment System', FILTER_INFOTAINMENT_SYSTEM,
        'Inspection Type', FILTER_INSPECTION_TYPE,
        'Interior Color', FILTER_INTERIOR_COLOR,
        'Interior Cosmetic', FILTER_INTERIOR_COSMETIC,
        'Interior Type', FILTER_INTERIOR_TYPE,
        'Keys', FILTER_KEYS,
        'Make', FILTER_MAKE,
        'Make Model Trim', FILTER_MAKE_MODEL_TRIM,
        'Model', FILTER_MODEL,
        'OBDII', FILTER_OBDII,
        'Odor', FILTER_ODOR,
        'Odometer', IFF(FILTER_ODOMETER_MIN IS NOT NULL OR FILTER_ODOMETER_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'Odometer Min', FILTER_ODOMETER_MIN::STRING,
            'Odometer Max', FILTER_ODOMETER_MAX::STRING
        ), NULL),
        'Odometer Discrepancy', FILTER_ODOMETER_DISCREPANCY,
        'Odometer Issue', FILTER_ODOMETER_ISSUE,
        'Open Bid', IFF(FILTER_OPEN_BID_MIN IS NOT NULL OR FILTER_OPEN_BID_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'Open Bid Min', FILTER_OPEN_BID_MIN::STRING,
            'Open Bid Max', FILTER_OPEN_BID_MAX::STRING
        ), NULL),
        'Owner Count', IFF(FILTER_OWNER_COUNT_MIN IS NOT NULL OR FILTER_OWNER_COUNT_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'Owner Count Min', FILTER_OWNER_COUNT_MIN::STRING,
            'Owner Count Max', FILTER_OWNER_COUNT_MAX::STRING
        ), NULL),
        'Pickup Location', FILTER_PICKUP_LOCATION,
        'Prior Paint', FILTER_PRIOR_PAINT,
        'Region', FILTER_REGION,
        'Seat Count', IFF(FILTER_SEAT_COUNT_MIN IS NOT NULL OR FILTER_SEAT_COUNT_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'Seat Count Min', FILTER_SEAT_COUNT_MIN::STRING,
            'Seat Count Max', FILTER_SEAT_COUNT_MAX::STRING
        ), NULL),
        'Site', FILTER_SITE,
        'State', FILTER_STATE,
        'Steering', FILTER_STEERING,
        'Structural Damage', FILTER_STRUCTURAL_DAMAGE,
        'Suspension', FILTER_SUSPENSION,
        'Title Issue Count', IFF(FILTER_TITLE_ISSUE_COUNT_MIN IS NOT NULL OR FILTER_TITLE_ISSUE_COUNT_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'Title Issue Count Min', FILTER_TITLE_ISSUE_COUNT_MIN::STRING,
            'Title Issue Count Max', FILTER_TITLE_ISSUE_COUNT_MAX::STRING
        ), NULL),
        'Transmission', FILTER_TRANSMISSION,
        'Trim', FILTER_TRIM,
        'Warning Lights', FILTER_WARNING_LIGHTS,
        'Watchlist', FILTER_WATCHLIST,
        'Wheels and Tires', FILTER_WHEELS_AND_TIRES,
        'Year', IFF(FILTER_YEAR_MIN IS NOT NULL OR FILTER_YEAR_MAX IS NOT NULL, OBJECT_CONSTRUCT(
            'Year Min', FILTER_YEAR_MIN::STRING,
            'Year Max', FILTER_YEAR_MAX::STRING
        ), NULL)
    )::STRING AS SEARCH_OPTIONS

    FROM db.SEARCH_FILTER_REMOVED_EVENTS
    ),

SEARCH_FILTER_REMOVED_DETAIL AS 
    (   
    SELECT
    USER_ID,
    ANONYMOUS_ID,
    TIMESTAMP,
    CONTEXT_PAGE_URL,
    ARRAY_TO_STRING(OBJECT_KEYS(SEARCH_OPTIONS::VARIANT), ', ') AS SEARCH_OPTIONS_SIMPLIFIED,
    ARRAY_SIZE(OBJECT_KEYS(SEARCH_OPTIONS::VARIANT)) AS SEARCH_FILTER_COUNT,
    CASE 
        WHEN EVENT_TYPE = 'Search Filter Removed'
        THEN USER_ID || '-' || SUM(CASE WHEN EVENT_TYPE = 'Search Filter Applied' THEN 1 ELSE 0 END) OVER (PARTITION BY USER_ID ORDER BY TIMESTAMP)::STRING
        ELSE NULL
        END
    AS SEARCH_FILTER_REMOVED_ID

    FROM SEARCH_FILTER_REMOVED_EVENTS
    )

SELECT
USER_ID,
ANONYMOUS_ID,
TIMESTAMP,
CONTEXT_PAGE_URL,
SEARCH_OPTIONS_SIMPLIFIED,
SEARCH_FILTER_REMOVED_ID,
SUM(SEARCH_FILTER_COUNT) OVER (PARTITION BY SEARCH_FILTER_REMOVED_ID) AS TOTAL_FILTER_REMOVAL_SIZE,
CASE
    WHEN EVENT_TYPE = 'Search Filter Removed' 
    THEN CASE
            WHEN COUNT(*) OVER (PARTITION BY USER_ID, SEARCH_FILTER_REMOVED_ID) > 1 THEN 'Single Filter Removal - Grouped'
            WHEN SEARCH_FILTER_COUNT = 1 THEN 'Single Filter Removal - Independent'
            WHEN SEARCH_FILTER_COUNT > 1 THEN 'Clear All Removal'
            ELSE NULL
            END
    ELSE NULL
    END
AS SEARCH_FILTER_REMOVAL_METHOD

FROM SEARCH_FILTER_REMOVED_DETAIL

WHERE NOT (SEARCH_FILTER_COUNT = 1 AND SEARCH_OPTIONS_SIMPLIFIED = 'Watchlist') --watchlist toggling is not really a filter despite being sent with filter events
    AND SEARCH_FILTER_COUNT > 0 --from here, can run in an aggregation tool like Tableau if desired. If wanting to do analysis in SQL, can continue on with the assumption this is wrapped as a CTE named 'SEARCH_FILTER_REMOVED_CATEGORIES'


----------------------------------------------------------------

SELECT --To see proportion of behaviors (clear all vs single grouped) at different filter removal sizes
TOTAL_FILTER_REMOVAL_SIZE,
COUNT(DISTINCT SEARCH_FILTER_REMOVED_ID) AS TOTAL_FILTER_REMOVAL_DECISIONS,
COUNT(DISTINCT CASE WHEN SEARCH_FILTER_REMOVED_METHOD = 'Single Filter Removal - Independent' THEN SEARCH_FILTER_REMOVED_ID ELSE NULL END)/NULLIFZERO(COUNT(DISTINCT SEARCH_FILTER_REMOVED_ID)) * 100.0 AS SINGLE_INDEPENDENT_PERCENTAGE,
COUNT(DISTINCT CASE WHEN SEARCH_FILTER_REMOVED_METHOD = 'Single Filter Removal - Grouped' THEN SEARCH_FILTER_REMOVED_ID ELSE NULL END)/NULLIFZERO(COUNT(DISTINCT SEARCH_FILTER_REMOVED_ID)) * 100.0 AS SINGLE_GROUPED_PERCENTAGE,
COUNT(DISTINCT CASE WHEN SEARCH_FILTER_REMOVED_METHOD = 'Clear All Removal' THEN SEARCH_FILTER_REMOVED_ID ELSE NULL END)/NULLIFZERO(COUNT(DISTINCT SEARCH_FILTER_REMOVED_ID)) * 100.0 AS CLEAR_ALL_PERCENTAGE

FROM SEARCH_FILTER_REMOVED_CATEGORIES
GROUP BY TOTAL_FILTER_REMOVAL_SIZE

