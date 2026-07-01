-- RIJAN

CREATE SEQUENCE seq_settings        START WITH 1000 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_retreat_setting START WITH 2000 INCREMENT BY 1 NOCACHE NOCYCLE;





CREATE TABLE settings (
    setting_id    NUMBER,
    setting_name  VARCHAR2(50),
    description   VARCHAR2(200),
    environments  VARCHAR2(50)
);

ALTER TABLE settings ADD CONSTRAINT pk_settings     PRIMARY KEY (setting_id);
ALTER TABLE settings ADD CONSTRAINT uq_settings_nm  UNIQUE      (setting_name);
ALTER TABLE settings ADD CONSTRAINT ck_settings_env CHECK (
    environments IN ('WOODLAND','COASTAL','URBAN','MOUNTAIN','RURAL')
);


CREATE TABLE retreat_setting (
    ret_setting_id    NUMBER,
    ret_setting_name  VARCHAR2(50),
    description       VARCHAR2(200),
    duration_days     NUMBER(3)
);

ALTER TABLE retreat_setting ADD CONSTRAINT pk_retreat_setting      PRIMARY KEY (ret_setting_id);
ALTER TABLE retreat_setting ADD CONSTRAINT uq_retreat_setting_nm   UNIQUE      (ret_setting_name);
ALTER TABLE retreat_setting ADD CONSTRAINT ck_retreat_setting_days CHECK       (duration_days > 0);


-- INSERT DATA


INSERT INTO settings VALUES (seq_settings.NEXTVAL, 'PINE RIDGE',    'DENSE PINE FOREST WITH COOL AIR AND NATURAL TRAILS',       'WOODLAND');
INSERT INTO settings VALUES (seq_settings.NEXTVAL, 'CLIFFSIDE BAY', 'DRAMATIC COASTAL CLIFF-TOP WITH PANORAMIC OCEAN VIEWS',     'COASTAL');
INSERT INTO settings VALUES (seq_settings.NEXTVAL, 'SUMMIT PEAK',   'HIGH-ALTITUDE MOUNTAIN SETTING WITH FRESH THIN AIR',        'MOUNTAIN');
INSERT INTO settings VALUES (seq_settings.NEXTVAL, 'VALE PASTURE',  'ROLLING RURAL COUNTRYSIDE WITH MEADOWS AND OPEN SKIES',     'RURAL');
INSERT INTO settings VALUES (seq_settings.NEXTVAL, 'CITY SANCTUARY','URBAN WELLNESS CENTRE SURROUNDED BY CITY ENERGY',           'URBAN');
COMMIT;

INSERT INTO retreat_setting VALUES (seq_retreat_setting.NEXTVAL, 'WELLBEING',  'HOLISTIC HEALTH AND MINDFULNESS FOCUSED RETREAT',    5);
INSERT INTO retreat_setting VALUES (seq_retreat_setting.NEXTVAL, 'DETOX',      'FULL CLEANSE PROGRAMME WITH SUPERVISED NUTRITION',   7);
INSERT INTO retreat_setting VALUES (seq_retreat_setting.NEXTVAL, 'FITNESS',    'HIGH-INTENSITY EXERCISE AND CONDITIONING PROGRAMME', 4);
INSERT INTO retreat_setting VALUES (seq_retreat_setting.NEXTVAL, 'SPIRITUAL',  'ENERGY HEALING, MEDITATION AND INNER GROWTH',        6);
INSERT INTO retreat_setting VALUES (seq_retreat_setting.NEXTVAL, 'CREATIVE',   'ART, JOURNALLING AND EXPRESSIVE THERAPY RETREAT',    3);
COMMIT;


-- PROCEDURE pr_add_setting



CREATE OR REPLACE PROCEDURE pr_add_setting (
    p_name  IN settings.setting_name%TYPE,
    p_desc  IN settings.description%TYPE,
    p_env   IN settings.environments%TYPE
)
IS
    e_invalid_env  EXCEPTION;
    v_id           settings.setting_id%TYPE;
BEGIN
    IF UPPER(p_env) NOT IN ('WOODLAND','COASTAL','URBAN','MOUNTAIN','RURAL') THEN
        RAISE e_invalid_env;
    END IF;

    v_id := seq_settings.NEXTVAL;

    INSERT INTO settings (setting_id, setting_name, description, environments)
    VALUES (v_id, UPPER(p_name), p_desc, UPPER(p_env));

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('SETTING ADDED. ID: ' || v_id || '  NAME: ' || UPPER(p_name));

EXCEPTION
    WHEN e_invalid_env THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: INVALID ENVIRONMENT VALUE -> ' || p_env);
        DBMS_OUTPUT.PUT_LINE('VALID VALUES: WOODLAND, COASTAL, URBAN, MOUNTAIN, RURAL');
        ROLLBACK;
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: SETTING NAME ALREADY EXISTS -> ' || p_name);
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('UNEXPECTED ERROR: ' || SQLERRM);
        ROLLBACK;
END pr_add_setting;
/

 --PROCEDURE pr_add_retreat_type

-- Sentence comment: pr_add_retreat_type inserts a new retreat_setting row with duration validation.
CREATE OR REPLACE PROCEDURE pr_add_retreat_type (
    p_name     IN retreat_setting.ret_setting_name%TYPE,
    p_desc     IN retreat_setting.description%TYPE,
    p_duration IN retreat_setting.duration_days%TYPE
)
IS
    e_bad_duration EXCEPTION;
    v_id           retreat_setting.ret_setting_id%TYPE;
BEGIN
    IF p_duration <= 0 THEN
        RAISE e_bad_duration;
    END IF;

    v_id := seq_retreat_setting.NEXTVAL;

    INSERT INTO retreat_setting (ret_setting_id, ret_setting_name, description, duration_days)
    VALUES (v_id, UPPER(p_name), p_desc, p_duration);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('RETREAT TYPE ADDED. ID: ' || v_id);

EXCEPTION
    WHEN e_bad_duration THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: DURATION MUST BE GREATER THAN ZERO.');
        ROLLBACK;
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: RETREAT TYPE NAME ALREADY EXISTS -> ' || p_name);
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('UNEXPECTED ERROR: ' || SQLERRM);
        ROLLBACK;
END pr_add_retreat_type;
/


--  SECTION 7 (Rijan): FUNCTION fn_get_environment


-- Sentence comment: fn_get_environment returns the environment string for a given setting_id.
CREATE OR REPLACE FUNCTION fn_get_environment (
    p_setting_id IN settings.setting_id%TYPE
)
RETURN settings.environments%TYPE
IS
    v_env settings.environments%TYPE;
BEGIN
    SELECT environments INTO v_env
    FROM   settings WHERE setting_id = p_setting_id;

    RETURN v_env;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('SETTING ' || p_setting_id || ' NOT FOUND.');
        RETURN NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR IN fn_get_environment: ' || SQLERRM);
        RETURN NULL;
END fn_get_environment;
/
===============================================================================
-- SULUV
===============================================================================
CREATE SEQUENCE seq_retreats START WITH 3000 INCREMENT BY 1 NOCACHE NOCYCLE;

--   OBJECT TYPES
CREATE OR REPLACE TYPE setting_type AS OBJECT (
    env_name     VARCHAR2(50),
    climate      VARCHAR2(50),
    description  VARCHAR2(200)
);
/


CREATE OR REPLACE TYPE facility_varray_type AS VARRAY(10) OF VARCHAR2(60);
/


--   SEQUENCE





-- TABLE DDL

CREATE TABLE retreat (
    retreat_id         NUMBER,
    retreat_name       VARCHAR2(100),
    max_capacity       NUMBER(4),
    setting_id         NUMBER,
    ret_setting_id     NUMBER,
    setting_info       setting_type,
    practices_offered  facility_varray_type
);

ALTER TABLE retreat ADD CONSTRAINT pk_retreat          PRIMARY KEY (retreat_id);
ALTER TABLE retreat ADD CONSTRAINT ck_retreat_capacity CHECK       (max_capacity > 0);
ALTER TABLE retreat ADD CONSTRAINT fk_s_retreat        FOREIGN KEY (setting_id)
    REFERENCES settings (setting_id);
ALTER TABLE retreat ADD CONSTRAINT fk_rs_retreat       FOREIGN KEY (ret_setting_id)
    REFERENCES retreat_setting (ret_setting_id);


--  INSERT DATA


INSERT INTO retreat VALUES (
    seq_retreats.NEXTVAL, 'FOREST HAVEN LODGE', 20, 1000, 2000,
    setting_type('WOODLAND', 'COOL AND TEMPERATE', 'ANCIENT PINE FOREST SETTING WITH MEDITATION TRAILS'),
    facility_varray_type('YOGA', 'MINDFULNESS', 'TIBETAN SINGING BOWLS', 'FOREST BATHING')
);
INSERT INTO retreat VALUES (
    seq_retreats.NEXTVAL, 'COASTAL CLEANSE RETREAT', 15, 1001, 2001,
    setting_type('COASTAL', 'MILD AND BREEZY', 'CLIFF-TOP RETREAT WITH OCEAN SUNRISE VIEWS'),
    facility_varray_type('DETOX JUICING', 'COLD WATER THERAPY', 'BREATHWORK', 'YOGA')
);
INSERT INTO retreat VALUES (
    seq_retreats.NEXTVAL, 'SUMMIT ENERGY CAMP', 12, 1002, 2002,
    setting_type('MOUNTAIN', 'CRISP AND INVIGORATING', 'HIGH-ALTITUDE CAMP FOR PEAK PERFORMANCE'),
    facility_varray_type('HIIT', 'CIRCUIT TRAINING', 'TRAIL RUNNING', 'YOGA')
);
INSERT INTO retreat VALUES (
    seq_retreats.NEXTVAL, 'VALE SPIRIT SANCTUARY', 10, 1003, 2003,
    setting_type('RURAL', 'WARM AND STILL', 'COUNTRYSIDE SANCTUARY FOR DEEP SPIRITUAL PRACTICE'),
    facility_varray_type('CRYSTALS', 'SOUND HEALING', 'MEDITATION', 'REIKI')
);
INSERT INTO retreat VALUES (
    seq_retreats.NEXTVAL, 'CITY MIND STUDIO', 25, 1004, 2004,
    setting_type('URBAN', 'CLIMATE CONTROLLED', 'MODERN URBAN STUDIO FOR CREATIVE WELLNESS'),
    facility_varray_type('ART THERAPY', 'JOURNALLING', 'MINDFULNESS', 'YOGA')
);
COMMIT;


--  PROCEDURE pr_add_retreat



CREATE OR REPLACE PROCEDURE pr_add_retreat (
    p_name       IN retreat.retreat_name%TYPE,
    p_capacity   IN retreat.max_capacity%TYPE,
    p_setting_id IN retreat.setting_id%TYPE,
    p_ret_setting_id    IN retreat.ret_setting_id%TYPE,
    p_env_name   IN VARCHAR2,
    p_climate    IN VARCHAR2,
    p_env_desc   IN VARCHAR2
)
IS
    e_bad_capacity EXCEPTION;
    v_id           retreat.retreat_id%TYPE;
BEGIN
    IF p_capacity <= 0 THEN
        RAISE e_bad_capacity;
    END IF;

    v_id := seq_retreats.NEXTVAL;

    INSERT INTO retreat (retreat_id, retreat_name, max_capacity, setting_id, ret_setting_id, setting_info)
    VALUES (
        v_id,
        UPPER(p_name),
        p_capacity,
        p_setting_id,
        p_ret_setting_id,
        setting_type(UPPER(p_env_name), UPPER(p_climate), p_env_desc)
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('RETREAT ADDED. ID: ' || v_id || '  NAME: ' || UPPER(p_name));

EXCEPTION
    WHEN e_bad_capacity THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: CAPACITY MUST BE GREATER THAN ZERO.');
        ROLLBACK;
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: REFERENCED SETTING OR TYPE NOT FOUND.');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('UNEXPECTED ERROR: ' || SQLERRM);
        ROLLBACK;
END pr_add_retreat;
/


--  FUNCTION fn_retreat_environment



CREATE OR REPLACE FUNCTION fn_retreat_environment (
    p_retreat_id IN retreat.retreat_id%TYPE
)
RETURN VARCHAR2
IS
    v_env VARCHAR2(50);
BEGIN
    SELECT r.setting_info.env_name INTO v_env
    FROM retreat r WHERE r.retreat_id = p_retreat_id;

    RETURN v_env;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'UNKNOWN';
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR IN fn_retreat_environment: ' || SQLERRM);
        RETURN NULL;
END fn_retreat_environment;
/


-- TRIGGER tr_retreat_bi


CREATE OR REPLACE TRIGGER tr_retreat_bi
BEFORE INSERT ON retreat
FOR EACH ROW
BEGIN
    :NEW.retreat_name := UPPER(:NEW.retreat_name);

    IF :NEW.max_capacity <= 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'MAX CAPACITY MUST BE GREATER THAN ZERO.');
    END IF;
END tr_retreat_bi;
/
====================================================================================
-- BISHRAM
====================================================================================
--  SEQUENCES
CREATE SEQUENCE seq_acc_styles     START WITH 4000 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_accommodations START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE;

--  TABLE DDL

CREATE TABLE accommodation_style (
    acc_style_id    NUMBER,
    acc_style_name  VARCHAR2(50),
    acc_description VARCHAR2(500)
);

ALTER TABLE accommodation_style ADD CONSTRAINT pk_acc_style    PRIMARY KEY (acc_style_id);
ALTER TABLE accommodation_style ADD CONSTRAINT uq_acc_style_nm UNIQUE      (acc_style_name);


CREATE TABLE accommodation (
    accommodation_id   NUMBER,
    acc_style_id       NUMBER,
    accommodation_name VARCHAR2(100),
    no_of_rooms        NUMBER(4),
    price_level        VARCHAR2(20),
    facilities         facility_varray_type
);

ALTER TABLE accommodation ADD CONSTRAINT pk_accommodation    PRIMARY KEY (accommodation_id);
ALTER TABLE accommodation ADD CONSTRAINT fk_as_accommodation FOREIGN KEY (acc_style_id)
    REFERENCES accommodation_style (acc_style_id);
ALTER TABLE accommodation ADD CONSTRAINT ck_acc_no_rooms     CHECK (no_of_rooms > 0);
ALTER TABLE accommodation ADD CONSTRAINT ck_acc_price_level  CHECK (
    price_level IN ('BUDGET','STANDARD','PREMIUM','LUXURY')
);

--  INSERT DATA

INSERT INTO accommodation_style VALUES (seq_acc_styles.NEXTVAL, 'GLAMPING TENT',    'LUXURY CANVAS TENT WITH HARDWOOD FLOORS AND REAL BED');
INSERT INTO accommodation_style VALUES (seq_acc_styles.NEXTVAL, 'WOODLAND LODGE',   'SELF-CONTAINED TIMBER LODGE NESTLED IN NATURAL SURROUNDINGS');
INSERT INTO accommodation_style VALUES (seq_acc_styles.NEXTVAL, 'COASTAL CABIN',    'WEATHERPROOFED CABIN WITH SEA VIEWS AND PRIVATE DECK');
INSERT INTO accommodation_style VALUES (seq_acc_styles.NEXTVAL, 'ECO DOME',         'GEODESIC DOME STRUCTURE WITH SUSTAINABLE MATERIALS AND SKY VIEW');
INSERT INTO accommodation_style VALUES (seq_acc_styles.NEXTVAL, 'STUDIO APARTMENT', 'COMPACT URBAN UNIT WITH KITCHENETTE AND MODERN FITTINGS');
COMMIT;

INSERT INTO accommodation VALUES (
    seq_accommodations.NEXTVAL, 4000, 'PINE GLAMPING TENT A', 4, 'PREMIUM',
    facility_varray_type('EN-SUITE', 'HEATED FLOORS', 'WIFI', 'KING BED')
);
INSERT INTO accommodation VALUES (
    seq_accommodations.NEXTVAL, 4001, 'OAK WOODLAND LODGE', 6, 'LUXURY',
    facility_varray_type('EN-SUITE', 'HOT TUB', 'FIREPLACE', 'WIFI', 'KITCHEN')
);
INSERT INTO accommodation VALUES (
    seq_accommodations.NEXTVAL, 4002, 'SEA VIEW COASTAL CABIN', 3, 'STANDARD',
    facility_varray_type('SHARED BATHROOM', 'SEA VIEW DECK', 'WIFI')
);
INSERT INTO accommodation VALUES (
    seq_accommodations.NEXTVAL, 4003, 'STARGAZER ECO DOME', 2, 'PREMIUM',
    facility_varray_type('SKYLIGHT ROOF', 'COMPOSTING TOILET', 'SOLAR LIGHTING')
);
INSERT INTO accommodation VALUES (
    seq_accommodations.NEXTVAL, 4004, 'CITY STUDIO UNIT B', 1, 'BUDGET',
    facility_varray_type('SHARED BATHROOM', 'KITCHENETTE', 'WIFI')
);
INSERT INTO accommodation VALUES (
    seq_accommodations.NEXTVAL, 4000, 'FOREST GLAMPING TENT B', 4, 'PREMIUM',
    facility_varray_type('EN-SUITE', 'WOOD BURNER', 'WIFI', 'TWIN BEDS')
);
COMMIT;

--   PROCEDURE pr_add_accommodation

CREATE OR REPLACE PROCEDURE pr_add_accommodation (
    p_style_id   IN accommodation.acc_style_id%TYPE,
    p_name       IN accommodation.accommodation_name%TYPE,
    p_rooms      IN accommodation.no_of_rooms%TYPE,
    p_price_lvl  IN accommodation.price_level%TYPE
)
IS
    e_bad_rooms   EXCEPTION;
    e_bad_price   EXCEPTION;
    v_id          accommodation.accommodation_id%TYPE;
    v_style_check NUMBER;
BEGIN
    IF p_rooms <= 0 THEN RAISE e_bad_rooms; END IF;

    IF UPPER(p_price_lvl) NOT IN ('BUDGET','STANDARD','PREMIUM','LUXURY') THEN
        RAISE e_bad_price;
    END IF;

    SELECT COUNT(*) INTO v_style_check
    FROM   accommodation_style WHERE acc_style_id = p_style_id;

    IF v_style_check = 0 THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ACC STYLE ID ' || p_style_id || ' DOES NOT EXIST.');
        RETURN;
    END IF;

    v_id := seq_accommodations.NEXTVAL;

    INSERT INTO accommodation (accommodation_id, acc_style_id, accommodation_name, no_of_rooms, price_level)
    VALUES (v_id, p_style_id, UPPER(p_name), p_rooms, UPPER(p_price_lvl));

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('ACCOMMODATION ADDED. ID: ' || v_id);

EXCEPTION
    WHEN e_bad_rooms  THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: NO_OF_ROOMS MUST BE GREATER THAN ZERO.');
        ROLLBACK;
    WHEN e_bad_price  THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: INVALID PRICE LEVEL -> ' || p_price_lvl);
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('UNEXPECTED ERROR: ' || SQLERRM);
        ROLLBACK;
END pr_add_accommodation;
/

--  FUNCTION fn_get_price_level

-- Sentence comment: fn_get_price_level returns the price level for an accommodation_id.
CREATE OR REPLACE FUNCTION fn_get_price_level (
    p_acc_id IN accommodation.accommodation_id%TYPE
)
RETURN accommodation.price_level%TYPE
IS
    v_level accommodation.price_level%TYPE;
BEGIN
    SELECT price_level INTO v_level
    FROM   accommodation WHERE accommodation_id = p_acc_id;

    RETURN v_level;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'NOT FOUND';
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR IN fn_get_price_level: ' || SQLERRM);
        RETURN NULL;
END fn_get_price_level;
/

--   TRIGGER tr_accommodation_biu


CREATE OR REPLACE TRIGGER tr_accommodation_biu
BEFORE INSERT OR UPDATE ON accommodation
FOR EACH ROW
BEGIN
    :NEW.accommodation_name := UPPER(:NEW.accommodation_name);
    :NEW.price_level        := UPPER(:NEW.price_level);

    IF INSERTING THEN
        IF :NEW.no_of_rooms <= 0 THEN
            RAISE_APPLICATION_ERROR(-20011, 'NO_OF_ROOMS MUST BE GREATER THAN ZERO.');
        END IF;
    END IF;

    IF UPDATING THEN
        IF :NEW.price_level NOT IN ('BUDGET','STANDARD','PREMIUM','LUXURY') THEN
            RAISE_APPLICATION_ERROR(-20012, 'INVALID PRICE LEVEL: ' || :NEW.price_level);
        END IF;
        DBMS_OUTPUT.PUT_LINE(
            'PRICE UPDATED: ' || :OLD.price_level || ' -> ' || :NEW.price_level ||
            ' FOR: ' || :OLD.accommodation_name
        );
    END IF;
END tr_accommodation_biu;
/

====================================================================================
-- Himanshu
====================================================================================

--   SEQUENCE

CREATE SEQUENCE seq_retreat_acc START WITH 6000 INCREMENT BY 1 NOCACHE NOCYCLE;

--   TABLE DDL


CREATE TABLE retreat_accommodation (
    retreat_acc_id     NUMBER,
    retreat_id         NUMBER,
    accommodation_id   NUMBER,
    units_available    NUMBER(4)   DEFAULT 1,
    date_added         DATE        DEFAULT SYSDATE
);

ALTER TABLE retreat_accommodation ADD CONSTRAINT pk_retreat_acc   PRIMARY KEY (retreat_acc_id);
ALTER TABLE retreat_accommodation ADD CONSTRAINT fk_r_retreat_acc FOREIGN KEY (retreat_id)
    REFERENCES retreat (retreat_id);
ALTER TABLE retreat_accommodation ADD CONSTRAINT fk_a_retreat_acc FOREIGN KEY (accommodation_id)
    REFERENCES accommodation (accommodation_id);
ALTER TABLE retreat_accommodation ADD CONSTRAINT ck_ra_units      CHECK (units_available > 0);
ALTER TABLE retreat_accommodation ADD CONSTRAINT uq_ra_link       UNIQUE (retreat_id, accommodation_id);

--   INSERT DATA

INSERT INTO retreat_accommodation (retreat_acc_id, retreat_id, accommodation_id, units_available, date_added)
VALUES (seq_retreat_acc.NEXTVAL, 3000, 5000, 8,  DATE '2026-01-10');

INSERT INTO retreat_accommodation (retreat_acc_id, retreat_id, accommodation_id, units_available, date_added)
VALUES (seq_retreat_acc.NEXTVAL, 3000, 5005, 6,  DATE '2026-01-10');

INSERT INTO retreat_accommodation (retreat_acc_id, retreat_id, accommodation_id, units_available, date_added)
VALUES (seq_retreat_acc.NEXTVAL, 3001, 5002, 10, DATE '2026-02-01');

INSERT INTO retreat_accommodation (retreat_acc_id, retreat_id, accommodation_id, units_available, date_added)
VALUES (seq_retreat_acc.NEXTVAL, 3001, 5003, 3,  DATE '2026-02-01');

INSERT INTO retreat_accommodation (retreat_acc_id, retreat_id, accommodation_id, units_available, date_added)
VALUES (seq_retreat_acc.NEXTVAL, 3002, 5000, 5,  DATE '2026-03-05');

INSERT INTO retreat_accommodation (retreat_acc_id, retreat_id, accommodation_id, units_available, date_added)
VALUES (seq_retreat_acc.NEXTVAL, 3002, 5001, 4,  DATE '2026-03-05');

INSERT INTO retreat_accommodation (retreat_acc_id, retreat_id, accommodation_id, units_available, date_added)
VALUES (seq_retreat_acc.NEXTVAL, 3003, 5003, 6,  DATE '2026-04-12');

INSERT INTO retreat_accommodation (retreat_acc_id, retreat_id, accommodation_id, units_available, date_added)
VALUES (seq_retreat_acc.NEXTVAL, 3004, 5004, 20, DATE '2026-05-20');

COMMIT;

--  PROCEDURE pr_link_accommodation


CREATE OR REPLACE PROCEDURE pr_link_accommodation (
    p_retreat_id       IN  retreat_accommodation.retreat_id%TYPE,
    p_accommodation_id IN  retreat_accommodation.accommodation_id%TYPE,
    p_units            IN  retreat_accommodation.units_available%TYPE,
    p_new_link_id     OUT  retreat_accommodation.retreat_acc_id%TYPE
)
IS
    e_bad_units   EXCEPTION;
    e_duplicate   EXCEPTION;
    v_cap         retreat.max_capacity%TYPE;
    v_used        NUMBER;
    v_check_dup   NUMBER;
BEGIN
    IF p_units <= 0 THEN RAISE e_bad_units; END IF;

    SELECT COUNT(*) INTO v_check_dup
    FROM   retreat_accommodation
    WHERE  retreat_id = p_retreat_id AND accommodation_id = p_accommodation_id;

    IF v_check_dup > 0 THEN RAISE e_duplicate; END IF;

    SELECT max_capacity INTO v_cap FROM retreat WHERE retreat_id = p_retreat_id;

    SELECT NVL(SUM(units_available), 0) INTO v_used
    FROM   retreat_accommodation WHERE retreat_id = p_retreat_id;

    IF (v_used + p_units) > v_cap THEN
        DBMS_OUTPUT.PUT_LINE('WARNING: UNITS WOULD EXCEED RETREAT CAPACITY OF ' || v_cap);
        DBMS_OUTPUT.PUT_LINE('CURRENT UNITS LINKED: ' || v_used || '  REQUESTED: ' || p_units);
    END IF;

    p_new_link_id := seq_retreat_acc.NEXTVAL;

    INSERT INTO retreat_accommodation (retreat_acc_id, retreat_id, accommodation_id, units_available)
    VALUES (p_new_link_id, p_retreat_id, p_accommodation_id, p_units);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('ACCOMMODATION LINKED. LINK ID: ' || p_new_link_id);

EXCEPTION
    WHEN e_bad_units  THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: UNITS MUST BE GREATER THAN ZERO.');
        ROLLBACK;
    WHEN e_duplicate  THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: THIS ACCOMMODATION IS ALREADY LINKED TO THIS RETREAT.');
        ROLLBACK;
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: RETREAT ID ' || p_retreat_id || ' NOT FOUND.');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('UNEXPECTED ERROR: ' || SQLERRM);
        ROLLBACK;
END pr_link_accommodation;
/

--  PROCEDURE pr_list_accommodations_by_retreat


CREATE OR REPLACE PROCEDURE pr_list_accommodations_by_retreat (
    p_retreat_id IN retreat.retreat_id%TYPE
)
IS
    CURSOR cur_retreat_accs IS
        SELECT a.accommodation_id,
               a.accommodation_name,
               ast.acc_style_name,
               a.price_level,
               a.no_of_rooms,
               ra.units_available,
               ra.date_added
        FROM   retreat_accommodation ra
               INNER JOIN accommodation       a   ON ra.accommodation_id = a.accommodation_id
               INNER JOIN accommodation_style ast ON a.acc_style_id      = ast.acc_style_id
        WHERE  ra.retreat_id = p_retreat_id
        ORDER  BY a.price_level, a.accommodation_name;

    v_rec         cur_retreat_accs%ROWTYPE;
    v_retreat_nm  retreat.retreat_name%TYPE;
    v_total_units NUMBER := 0;
    v_acc_count   NUMBER := 0;

BEGIN
    SELECT retreat_name INTO v_retreat_nm
    FROM   retreat WHERE retreat_id = p_retreat_id;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== ACCOMMODATIONS FOR: ' || v_retreat_nm || ' ===');
    DBMS_OUTPUT.PUT_LINE(
        RPAD('NAME',             28) ||
        RPAD('STYLE',            20) ||
        RPAD('PRICE',            10) ||
        RPAD('ROOMS', 7) ||
        RPAD('UNITS', 7) ||
        'DATE ADDED'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 90, '-'));

    OPEN cur_retreat_accs;
    WHILE TRUE LOOP
        FETCH cur_retreat_accs INTO v_rec;
        EXIT WHEN cur_retreat_accs%NOTFOUND;

        v_acc_count   := v_acc_count + 1;
        v_total_units := v_total_units + v_rec.units_available;

        DBMS_OUTPUT.PUT_LINE(
            RPAD(v_rec.accommodation_name, 28) ||
            RPAD(v_rec.acc_style_name,     20) ||
            RPAD(v_rec.price_level,        10) ||
            RPAD(TO_CHAR(v_rec.no_of_rooms), 7) ||
            RPAD(TO_CHAR(v_rec.units_available), 7) ||
            TO_CHAR(v_rec.date_added, 'DD-MON-YYYY')
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-', 90, '-'));
    DBMS_OUTPUT.PUT_LINE('ROWS FETCHED   : ' || cur_retreat_accs%ROWCOUNT);
    CLOSE cur_retreat_accs;

    DBMS_OUTPUT.PUT_LINE('TOTAL LISTINGS : ' || v_acc_count);
    DBMS_OUTPUT.PUT_LINE('TOTAL UNITS    : ' || v_total_units);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: RETREAT ID ' || p_retreat_id || ' NOT FOUND.');
    WHEN OTHERS THEN
        IF cur_retreat_accs%ISOPEN THEN CLOSE cur_retreat_accs; END IF;
        DBMS_OUTPUT.PUT_LINE('UNEXPECTED ERROR: ' || SQLERRM);
END pr_list_accommodations_by_retreat;
/

--  FUNCTION fn_count_accommodations

CREATE OR REPLACE FUNCTION fn_count_accommodations (
    p_retreat_id IN retreat.retreat_id%TYPE
)
RETURN NUMBER
IS
    v_count NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM   retreat_accommodation WHERE retreat_id = p_retreat_id;

    RETURN v_count;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR IN fn_count_accommodations: ' || SQLERRM);
        RETURN -1;
END fn_count_accommodations;
/

--   TRIGGER tr_retreat_accommodation_bi

-- Sentence comment: tr_retreat_accommodation_bi validates units and defaults date_added on insert.
CREATE OR REPLACE TRIGGER tr_retreat_accommodation_bi
BEFORE INSERT ON retreat_accommodation
FOR EACH ROW
BEGIN
    IF :NEW.date_added IS NULL THEN
        :NEW.date_added := SYSDATE;
    END IF;

    IF :NEW.units_available <= 0 THEN
        RAISE_APPLICATION_ERROR(-20013, 'UNITS_AVAILABLE MUST BE GREATER THAN ZERO.');
    END IF;
END tr_retreat_accommodation_bi;
/

=================================================================================
-- SAGAR
=================================================================================

--  SECTION 5: DATA EXTRACTION QUERIES


-- Query 1: INNER JOIN – retreats with their setting environment and type name
SELECT r.retreat_id,
       r.retreat_name,
       s.setting_name,
       s.environments,
       rs.ret_setting_name   AS retreat_type,
       r.max_capacity
FROM   retreat         r
       INNER JOIN settings        s  ON r.setting_id = s.setting_id
       INNER JOIN retreat_setting rs ON r.ret_setting_id    = rs.ret_setting_id
ORDER  BY r.retreat_name;

-- Query 2: INNER JOIN – accommodations with their style name
SELECT a.accommodation_id,
       a.accommodation_name,
       ast.acc_style_name,
       a.no_of_rooms,
       a.price_level
FROM   accommodation       a
       INNER JOIN accommodation_style ast ON a.acc_style_id = ast.acc_style_id
ORDER  BY a.price_level, a.accommodation_name;

-- Query 3: LEFT OUTER JOIN – all retreats with accommodation count (including 0)
SELECT r.retreat_name,
       s.environments,
       COUNT(ra.retreat_acc_id)        AS acc_options,
       NVL(SUM(ra.units_available), 0) AS total_units
FROM   retreat               r
       LEFT OUTER JOIN settings             s  ON r.setting_id = s.setting_id
       LEFT OUTER JOIN retreat_accommodation ra ON r.retreat_id = ra.retreat_id
GROUP  BY r.retreat_name, s.environments
ORDER  BY total_units DESC;

-- Query 4: AGGREGATE functions – rooms per price level
SELECT a.price_level,
       COUNT(*)                     AS acc_count,
       SUM(a.no_of_rooms)           AS total_rooms,
       ROUND(AVG(a.no_of_rooms), 1) AS avg_rooms,
       MIN(a.no_of_rooms)           AS min_rooms,
       MAX(a.no_of_rooms)           AS max_rooms
FROM   accommodation a
GROUP  BY a.price_level
ORDER  BY total_rooms DESC;

-- Query 5: GROUP BY with HAVING – retreat types with more than 1 day duration
SELECT rs.ret_setting_name,
       rs.duration_days,
       COUNT(r.retreat_id)  AS retreat_count,
       SUM(r.max_capacity)  AS total_capacity
FROM   retreat_setting  rs
       LEFT OUTER JOIN retreat r ON rs.ret_setting_id = r.ret_setting_id
GROUP  BY rs.ret_setting_name, rs.duration_days
HAVING rs.duration_days > 3
ORDER  BY rs.duration_days DESC;

-- Query 6: Built-in string functions on accommodation data
SELECT accommodation_id,
       UPPER(accommodation_name)                              AS name_upper,
       LOWER(price_level)                                    AS level_lower,
       LENGTH(accommodation_name)                            AS name_length,
       SUBSTR(accommodation_name, 1, 8)                      AS name_short,
       CONCAT(accommodation_name, ' [' || price_level || ']') AS name_label,
       TRIM(accommodation_name)                              AS name_trimmed
FROM   accommodation
ORDER  BY accommodation_id;

-- Query 7: Numeric built-in functions – capacity analysis
SELECT r.retreat_name,
       r.max_capacity,
       CEIL (r.max_capacity / 4)    AS groups_of_4_ceil,
       FLOOR(r.max_capacity / 4)    AS groups_of_4_floor,
       ROUND(r.max_capacity / 3, 1) AS groups_of_3_round,
       MOD  (r.max_capacity, 4)     AS remainder
FROM   retreat r
ORDER  BY r.max_capacity DESC;

-- Query 8: Object column dot notation – query setting_type sub-object directly
SELECT r.retreat_name,
       r.setting_info.env_name    AS env_name,
       r.setting_info.climate     AS climate,
       r.setting_info.description AS env_description
FROM   retreat r
WHERE  r.setting_info IS NOT NULL
ORDER  BY r.retreat_name;

-- Query 9: VARRAY column query – facilities per retreat
SELECT r.retreat_name,
       COLUMN_VALUE AS practice_offered
FROM   retreat r,
       TABLE(r.practices_offered)
ORDER  BY r.retreat_name, practice_offered;

-- Query 10: VARRAY column query – facilities per accommodation
SELECT a.accommodation_name,
       a.price_level,
       COLUMN_VALUE AS facility
FROM   accommodation a,
       TABLE(a.facilities)
ORDER  BY a.accommodation_name, facility;

-- Query 11: Full 6-table chain query
SELECT r.retreat_name,
       s.setting_name,
       s.environments,
       rs.ret_setting_name   AS programme_type,
       rs.duration_days,
       a.accommodation_name,
       ast.acc_style_name,
       a.price_level,
       ra.units_available
FROM   retreat                r
       INNER JOIN settings              s   ON r.setting_id       = s.setting_id
       INNER JOIN retreat_setting       rs  ON r.ret_setting_id          = rs.ret_setting_id
       INNER JOIN retreat_accommodation ra  ON r.retreat_id       = ra.retreat_id
       INNER JOIN accommodation         a   ON ra.accommodation_id = a.accommodation_id
       INNER JOIN accommodation_style   ast ON a.acc_style_id     = ast.acc_style_id
ORDER  BY r.retreat_name, a.price_level;

-- Query 12: UNION – all environment names from settings table and retreat object column
SELECT setting_name AS name, 'SETTINGS TABLE' AS source FROM settings
UNION
SELECT r.setting_info.env_name, 'OBJECT COLUMN' FROM retreat r WHERE r.setting_info IS NOT NULL;

-- Query 13: INTERSECT – accommodations linked to BOTH retreat 3000 AND retreat 3002
SELECT accommodation_id FROM retreat_accommodation WHERE retreat_id = 3000
INTERSECT
SELECT accommodation_id FROM retreat_accommodation WHERE retreat_id = 3002;

-- Query 14: MINUS – retreats with NO accommodation linked
SELECT retreat_id FROM retreat
MINUS
SELECT DISTINCT retreat_id FROM retreat_accommodation;

-- Query 15: TO_DATE, TO_CHAR, SYSDATE – accommodation age in days
SELECT ra.retreat_acc_id,
       r.retreat_name,
       a.accommodation_name,
       ra.date_added,
       TO_CHAR(ra.date_added, 'DD-MON-YYYY')  AS formatted_date,
       FLOOR(SYSDATE - ra.date_added)          AS days_linked,
       CEIL (SYSDATE - ra.date_added)          AS days_linked_ceil
FROM   retreat_accommodation ra
       INNER JOIN retreat       r ON ra.retreat_id       = r.retreat_id
       INNER JOIN accommodation a ON ra.accommodation_id = a.accommodation_id
ORDER  BY ra.date_added;


--  SECTION 10: ANONYMOUS PL/SQL TEST BLOCKS


SET SERVEROUTPUT ON;

-- Test Block 1: pr_add_setting valid and invalid environment
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- TEST BLOCK 1: pr_add_setting ---');
    pr_add_setting('LAKESIDE COVE', 'CALM LAKE SETTING WITH MORNING MIST', 'RURAL');
    pr_add_setting('BAD SETTING',   'SHOULD FAIL',                         'DESERT');
END;
/

-- Test Block 2: pr_add_retreat_type valid and zero-duration
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- TEST BLOCK 2: pr_add_retreat_type ---');
    pr_add_retreat_type('RECOVERY', 'GENTLE MOVEMENT AND REST FOCUSED RETREAT', 4);
    pr_add_retreat_type('BAD TYPE', 'SHOULD FAIL WITH ZERO DURATION',           0);
END;
/

-- Test Block 3: pr_add_retreat
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- TEST BLOCK 3: pr_add_retreat ---');
    pr_add_retreat('LAKESIDE RECOVERY LODGE', 18, 1000, 2000,
                   'WOODLAND', 'MILD AND DAMP', 'NEW LAKESIDE WOODLAND ADDITION');
END;
/

-- Test Block 4: pr_list_accommodations_by_retreat with explicit cursor output
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- TEST BLOCK 4: pr_list_accommodations_by_retreat ---');
    pr_list_accommodations_by_retreat(3000);
END;
/

-- Test Block 5: FOR loop – accommodation count per retreat
DECLARE
    v_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- TEST BLOCK 5: Accommodation counts per retreat (FOR loop) ---');
    FOR r IN (SELECT retreat_id, retreat_name FROM retreat ORDER BY retreat_id) LOOP
        v_count := fn_count_accommodations(r.retreat_id);
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r.retreat_name, 30) || ' => ' || v_count || ' accommodation(s) linked'
        );
    END LOOP;
END;
/

-- Test Block 6: WHILE loop – price level classification
DECLARE
    CURSOR cur_all_acc IS
        SELECT accommodation_id, accommodation_name, price_level FROM accommodation ORDER BY accommodation_id;
    v_acc  cur_all_acc%ROWTYPE;
    v_tier VARCHAR2(20);
    v_num  NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- TEST BLOCK 6: Price classification (WHILE loop) ---');
    OPEN cur_all_acc;
    WHILE TRUE LOOP
        FETCH cur_all_acc INTO v_acc;
        EXIT WHEN cur_all_acc%NOTFOUND;
        v_num := v_num + 1;

        IF    v_acc.price_level = 'LUXURY'   THEN v_tier := '*** TOP TIER ***';
        ELSIF v_acc.price_level = 'PREMIUM'  THEN v_tier := '** HIGH TIER **';
        ELSIF v_acc.price_level = 'STANDARD' THEN v_tier := '* MID TIER *';
        ELSE                                       v_tier := 'ENTRY LEVEL';
        END IF;

        DBMS_OUTPUT.PUT_LINE(v_num || '. ' || RPAD(v_acc.accommodation_name, 30) || v_tier);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('TOTAL ROWS FETCHED: ' || cur_all_acc%ROWCOUNT);
    CLOSE cur_all_acc;
END;
/

-- Test Block 7: fn_get_environment vs fn_retreat_environment comparison
DECLARE
    v_tbl_env VARCHAR2(50);
    v_obj_env VARCHAR2(50);
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- TEST BLOCK 7: fn_get_environment vs fn_retreat_environment ---');
    FOR r IN (SELECT retreat_id, retreat_name, setting_id FROM retreat ORDER BY retreat_id) LOOP
        v_tbl_env := fn_get_environment(r.setting_id);
        v_obj_env := fn_retreat_environment(r.retreat_id);
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r.retreat_name, 28) ||
            ' | TABLE: '  || NVL(v_tbl_env,'NULL') ||
            ' | OBJECT: ' || NVL(v_obj_env,'NULL')
        );
    END LOOP;
END;
/

-- Test Block 8: pr_link_accommodation with OUT parameter and duplicate test
DECLARE
    v_new_id retreat_accommodation.retreat_acc_id%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- TEST BLOCK 8: pr_link_accommodation ---');
    pr_link_accommodation(3004, 5001, 3, v_new_id);
    DBMS_OUTPUT.PUT_LINE('NEW LINK ID: ' || v_new_id);
    pr_link_accommodation(3004, 5001, 3, v_new_id);
END;
/

-- Test Block 9: tr_accommodation_biu UPDATE trigger
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- TEST BLOCK 9: tr_accommodation_biu UPDATE trigger ---');
    UPDATE accommodation SET price_level = 'LUXURY' WHERE accommodation_id = 5004;
    COMMIT;
    UPDATE accommodation SET price_level = 'EXCLUSIVE' WHERE accommodation_id = 5004;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('TRIGGER BLOCKED INVALID UPDATE: ' || SQLERRM);
        ROLLBACK;
END;
/

-- Test Block 10: Implicit cursor SQL%ROWCOUNT after bulk UPDATE
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- TEST BLOCK 10: Implicit cursor SQL%ROWCOUNT ---');
    UPDATE settings SET description = UPPER(description) WHERE description IS NOT NULL;
    DBMS_OUTPUT.PUT_LINE('ROWS UPDATED: ' || SQL%ROWCOUNT);
    COMMIT;
END;
/

DROP FUNCTION fn_get_environment;
DROP PROCEDURE pr_add_setting;
DROP PROCEDURE pr_add_retreat_type;
DROP TABLE retreat_setting;
DROP TABLE settings;
DROP SEQUENCE seq_settings;
DROP SEQUENCE seq_retreat_setting;  


DROP TRIGGER tr_retreat_bi;
DROP FUNCTION fn_retreat_environment;
DROP PROCEDURE pr_add_retreat;
DROP TABLE retreat;
DROP SEQUENCE seq_retreats;
DROP TYPE facility_varray_type;
DROP TYPE setting_type;

DROP TRIGGER tr_accommodation_biu;
DROP FUNCTION fn_get_price_level;
DROP PROCEDURE pr_add_accommodation;
DROP TABLE accommodation;
DROP TABLE accommodation_style;
DROP SEQUENCE seq_acc_styles;
DROP SEQUENCE seq_accommodations;


DROP TRIGGER tr_retreat_accommodation_bi;
DROP FUNCTION fn_count_accommodations;
DROP PROCEDURE pr_link_accommodation;
DROP PROCEDURE pr_list_accommodations_by_retreat;
DROP TABLE retreat_accommodation;
DROP SEQUENCE seq_retreat_acc;