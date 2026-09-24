-- Team 12 - Smart Blood Bank Management System
-- PostgreSQL Schema

-- 1. BLOOD_TYPE
CREATE TABLE blood_type (
    type_code VARCHAR(3) PRIMARY KEY,
    
    CONSTRAINT chk_blood_type
        CHECK (type_code IN (
            'A+', 'A-',
            'B+', 'B-',
            'AB+', 'AB-',
            'O+', 'O-'
        ))
);


-- 2. BLOOD_BANK
CREATE TABLE blood_bank (
    bank_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(150) NOT NULL,
    contact_number VARCHAR(15) UNIQUE
);


-- 3. DONOR
CREATE TABLE donor (
    donor_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(20),
    blood_type VARCHAR(3) NOT NULL,
    contact_number VARCHAR(15),
    email VARCHAR(100) UNIQUE,
    last_donation_date DATE,

    CONSTRAINT fk_donor_blood_type
        FOREIGN KEY (blood_type)
        REFERENCES blood_type(type_code),

    CONSTRAINT chk_donor_gender
        CHECK (gender IN ('Male', 'Female', 'Other'))
);


-- 4. RECIPIENT
CREATE TABLE recipient (
    recipient_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(20),
    blood_type_required VARCHAR(3) NOT NULL,
    contact_number VARCHAR(15),

    CONSTRAINT fk_recipient_blood_type
        FOREIGN KEY (blood_type_required)
        REFERENCES blood_type(type_code),

    CONSTRAINT chk_recipient_gender
        CHECK (gender IN ('Male', 'Female', 'Other'))
);


-- 5. BLOOD_UNIT
-- Composite Primary Key: (bank_id, unit_seq_no)
CREATE TABLE blood_unit (
    bank_id INTEGER NOT NULL,
    unit_seq_no INTEGER NOT NULL,
    blood_type VARCHAR(3) NOT NULL,
    component_type VARCHAR(50) NOT NULL,
    collection_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'available',

    CONSTRAINT pk_blood_unit
        PRIMARY KEY (bank_id, unit_seq_no),

    CONSTRAINT fk_blood_unit_bank
        FOREIGN KEY (bank_id)
        REFERENCES blood_bank(bank_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_blood_unit_blood_type
        FOREIGN KEY (blood_type)
        REFERENCES blood_type(type_code),

    CONSTRAINT chk_blood_unit_status
        CHECK (status IN (
            'available',
            'reserved',
            'issued',
            'expired'
        )),

    CONSTRAINT chk_blood_unit_dates
        CHECK (expiry_date > collection_date)
);


-- 6. DONATION
CREATE TABLE donation (
    donation_id INTEGER PRIMARY KEY,
    donor_id INTEGER NOT NULL,
    bank_id INTEGER NOT NULL,
    unit_seq_no INTEGER NOT NULL,
    donation_date DATE NOT NULL,
    volume_ml NUMERIC(6,2) NOT NULL,

    CONSTRAINT fk_donation_donor
        FOREIGN KEY (donor_id)
        REFERENCES donor(donor_id),

    CONSTRAINT fk_donation_blood_unit
        FOREIGN KEY (bank_id, unit_seq_no)
        REFERENCES blood_unit(bank_id, unit_seq_no),

    CONSTRAINT chk_donation_volume
        CHECK (volume_ml > 0)
);


-- 7. COMPATIBILITY
-- Composite Primary Key: (donor_type, recipient_type)
CREATE TABLE compatibility (
    donor_type VARCHAR(3) NOT NULL,
    recipient_type VARCHAR(3) NOT NULL,

    CONSTRAINT pk_compatibility
        PRIMARY KEY (donor_type, recipient_type),

    CONSTRAINT fk_compatibility_donor_type
        FOREIGN KEY (donor_type)
        REFERENCES blood_type(type_code),

    CONSTRAINT fk_compatibility_recipient_type
        FOREIGN KEY (recipient_type)
        REFERENCES blood_type(type_code)
);


-- 8. REQUEST
CREATE TABLE request (
    request_id INTEGER PRIMARY KEY,
    recipient_id INTEGER NOT NULL,
    bank_id INTEGER NOT NULL,
    unit_seq_no INTEGER,
    request_date DATE NOT NULL,
    quantity_required INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',

    CONSTRAINT fk_request_recipient
        FOREIGN KEY (recipient_id)
        REFERENCES recipient(recipient_id),

    CONSTRAINT fk_request_bank
        FOREIGN KEY (bank_id)
        REFERENCES blood_bank(bank_id),

    CONSTRAINT fk_request_blood_unit
        FOREIGN KEY (bank_id, unit_seq_no)
        REFERENCES blood_unit(bank_id, unit_seq_no),

    CONSTRAINT chk_request_quantity
        CHECK (quantity_required > 0),

    CONSTRAINT chk_request_status
        CHECK (status IN (
            'pending',
            'fulfilled',
            'cancelled'
        ))
);

