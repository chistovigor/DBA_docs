select 
N_MRC_ATM,                  -- код строки
C_NATM,                    -- номер ATM
C_ATM_SER_NUM,              -- Серийный номер ATM
C_MRC_CITY_FULL,            -- населенный пункт (N_MRC_CITY или C_CITY_NAME) - 
C_MRC_ADDR_FULL,            -- Полный адрес (без населенного пункта)
C_MRC_CMP_NAME,             -- название компании
C_ATM_TYPE,                 -- тип ATM (Walk-In, VIP, OTD)
CF_MRC_ATM_CASH_IN,         -- признак работы ATM c Cash-In (Y, N)
CF_MRC_ATM_EUR,             -- признак работы ATM c EUR (Y, N)
CF_MRC_ATM_USD,             -- признак работы ATM c USD (Y, N)
D_ATM_REG,                  -- дата регистрации мерчантов в Alpha/Prime
C_ATM_LOCATION_TYPE,        -- тип расположения
C_ATM_LOCATION_TYPE_DESC,   -- описание признака тип расположения
CF_ATM_AVAILABILITY,        -- время работы ATM
CF_ATM_ACCESSIBILITY,       -- доступ для клиентов
C_ATM_ACCESSIBILITY,        -- описание признака доступности для клиентов
CF_ATM_HANDICAP,            -- доступность для инвалидов
C_ATM_AVAILABILITY         -- описание признака время работы ATM
    FROM v_mrc_atm MA
WHERE MA.Cf_Mrc_Atm_Stat IN ('A')