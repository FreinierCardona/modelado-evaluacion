CREATE TABLE sch_security.user_status (
    user_status_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    status_code varchar(20) NOT NULL,
    status_name varchar(80) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_user_status_code UNIQUE (status_code),
    CONSTRAINT uq_user_status_name UNIQUE (status_name)
);

CREATE TABLE sch_security.security_role (
    security_role_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    role_code varchar(30) NOT NULL,
    role_name varchar(100) NOT NULL,
    role_description text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_security_role_code UNIQUE (role_code),
    CONSTRAINT uq_security_role_name UNIQUE (role_name)
);

CREATE TABLE sch_security.security_permission (
    security_permission_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    permission_code varchar(50) NOT NULL,
    permission_name varchar(120) NOT NULL,
    permission_description text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_security_permission_code UNIQUE (permission_code),
    CONSTRAINT uq_security_permission_name UNIQUE (permission_name)
);

CREATE TABLE sch_security.user_account (
    user_account_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    person_id uuid NOT NULL REFERENCES sch_identity.person(person_id),
    user_status_id uuid NOT NULL REFERENCES sch_security.user_status(user_status_id),
    username varchar(80) NOT NULL,
    password_hash varchar(255) NOT NULL,
    last_login_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_user_account_person UNIQUE (person_id),
    CONSTRAINT uq_user_account_username UNIQUE (username)
);

CREATE TABLE sch_security.user_role (
    user_role_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_account_id uuid NOT NULL REFERENCES sch_security.user_account(user_account_id),
    security_role_id uuid NOT NULL REFERENCES sch_security.security_role(security_role_id),
    assigned_at timestamptz NOT NULL DEFAULT now(),
    assigned_by_user_id uuid REFERENCES sch_security.user_account(user_account_id),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_user_role UNIQUE (user_account_id, security_role_id)
);

CREATE TABLE sch_security.role_permission (
    role_permission_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    security_role_id uuid NOT NULL REFERENCES sch_security.security_role(security_role_id),
    security_permission_id uuid NOT NULL REFERENCES sch_security.security_permission(security_permission_id),
    granted_at timestamptz NOT NULL DEFAULT now(),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_role_permission UNIQUE (security_role_id, security_permission_id)
);
