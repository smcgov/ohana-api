--
-- PostgreSQL database dump
--

-- Dumped from database version 10.1
-- Dumped by pg_dump version 10.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


SET search_path = public, pg_catalog;

--
-- Name: fill_search_vector_for_location(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fill_search_vector_for_location() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
          declare
            location_organization record;
            location_services_keywords record;
            location_services_description record;
            location_services_name record;
            service_categories record;

          begin
            select name into location_organization from organizations where id = new.organization_id;

            select string_agg(keywords, ' ') as keywords into location_services_keywords from services where location_id = new.id;
            select description into location_services_description from services where location_id = new.id;
            select name into location_services_name from services where location_id = new.id;

            select string_agg(categories.name, ' ') as name into service_categories from locations
            JOIN services ON services.location_id = new.id
            JOIN categories_services ON categories_services.service_id = services.id
            JOIN categories ON categories.id = categories_services.category_id;

            new.tsv_body :=
              setweight(to_tsvector('pg_catalog.english', coalesce(new.name, '')), 'B')                  ||
              setweight(to_tsvector('pg_catalog.english', coalesce(new.description, '')), 'A')                ||
              setweight(to_tsvector('pg_catalog.english', coalesce(location_organization.name, '')), 'B')        ||
              setweight(to_tsvector('pg_catalog.english', coalesce(location_services_description.description, '')), 'A')  ||
              setweight(to_tsvector('pg_catalog.english', coalesce(location_services_name.name, '')), 'B')  ||
              setweight(to_tsvector('pg_catalog.english', coalesce(location_services_keywords.keywords, '')), 'B') ||
              setweight(to_tsvector('pg_catalog.english', coalesce(service_categories.name, '')), 'A');

            return new;
          end
          $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE addresses (
    id integer NOT NULL,
    location_id integer,
    city text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    country_code character varying(255),
    street_1 character varying(255),
    street_2 character varying(255),
    postal_code character varying(255),
    state_province character varying(255),
    address_1 character varying,
    address_2 character varying,
    country character varying
);


--
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE addresses_id_seq OWNED BY addresses.id;


--
-- Name: admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE admins (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    super_admin boolean DEFAULT false
);


--
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admins_id_seq OWNED BY admins.id;


--
-- Name: api_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE api_applications (
    id integer NOT NULL,
    user_id integer,
    name text,
    main_url text,
    callback_url text,
    api_token text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: api_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE api_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE api_applications_id_seq OWNED BY api_applications.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE categories (
    id integer NOT NULL,
    name text NOT NULL,
    taxonomy_id text NOT NULL,
    slug text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ancestry character varying(255)
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: categories_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE categories_services (
    category_id integer NOT NULL,
    service_id integer NOT NULL
);


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE contacts (
    id integer NOT NULL,
    location_id integer,
    name text NOT NULL,
    title text,
    email text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    organization_id integer,
    service_id integer,
    department character varying(255)
);


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contacts_id_seq OWNED BY contacts.id;


--
-- Name: friendly_id_slugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE friendly_id_slugs (
    id integer NOT NULL,
    slug character varying(255) NOT NULL,
    sluggable_id integer NOT NULL,
    sluggable_type character varying(40),
    created_at timestamp without time zone
);


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE friendly_id_slugs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE friendly_id_slugs_id_seq OWNED BY friendly_id_slugs.id;


--
-- Name: holiday_schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE holiday_schedules (
    id integer NOT NULL,
    location_id integer,
    service_id integer,
    closed boolean NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    opens_at time without time zone,
    closes_at time without time zone
);


--
-- Name: holiday_schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE holiday_schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: holiday_schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE holiday_schedules_id_seq OWNED BY holiday_schedules.id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE locations (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    accessibility text,
    admin_emails text[] DEFAULT '{}'::text[],
    ask_for text,
    description text,
    hours text,
    importance integer DEFAULT 1,
    kind text NOT NULL,
    latitude double precision,
    longitude double precision,
    languages text[] DEFAULT '{}'::text[],
    market_match boolean DEFAULT false,
    name text NOT NULL,
    payments text,
    products text,
    short_desc text,
    transportation text,
    slug text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    tsv_body tsvector,
    alternate_name character varying(255),
    virtual boolean DEFAULT false,
    active boolean DEFAULT true,
    email character varying(255),
    website character varying(255)
);


--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE locations_id_seq OWNED BY locations.id;


--
-- Name: mail_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE mail_addresses (
    id integer NOT NULL,
    location_id integer,
    attention text,
    city text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    country_code character varying(255),
    street_1 character varying(255),
    street_2 character varying(255),
    postal_code character varying(255),
    state_province character varying(255),
    address_1 character varying,
    address_2 character varying,
    country character varying
);


--
-- Name: mail_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mail_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mail_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mail_addresses_id_seq OWNED BY mail_addresses.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE organizations (
    id integer NOT NULL,
    name text NOT NULL,
    slug text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    alternate_name character varying(255),
    date_incorporated date,
    description text,
    email character varying(255),
    legal_status character varying(255),
    tax_id character varying(255),
    tax_status character varying(255),
    website character varying(255),
    funding_sources character varying(255)[] DEFAULT '{}'::character varying[],
    accreditations character varying(255)[] DEFAULT '{}'::character varying[],
    licenses character varying(255)[] DEFAULT '{}'::character varying[]
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organizations_id_seq OWNED BY organizations.id;


--
-- Name: phones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE phones (
    id integer NOT NULL,
    location_id integer,
    number text NOT NULL,
    department text,
    extension text,
    number_type text,
    vanity_number text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    organization_id integer,
    service_id integer,
    contact_id integer,
    country_prefix character varying(255)
);


--
-- Name: phones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE phones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: phones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE phones_id_seq OWNED BY phones.id;


--
-- Name: programs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE programs (
    id integer NOT NULL,
    organization_id integer,
    name character varying(255),
    alternate_name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: programs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE programs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: programs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE programs_id_seq OWNED BY programs.id;


--
-- Name: regular_schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE regular_schedules (
    id integer NOT NULL,
    weekday integer,
    opens_at time without time zone,
    closes_at time without time zone,
    service_id integer,
    location_id integer
);


--
-- Name: regular_schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE regular_schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: regular_schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE regular_schedules_id_seq OWNED BY regular_schedules.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE services (
    id integer NOT NULL,
    location_id integer,
    audience text,
    description text,
    eligibility text,
    fees text,
    how_to_apply text,
    name text,
    funding_sources text,
    service_areas text[] DEFAULT '{}'::text[],
    keywords text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    accepted_payments character varying(255)[] DEFAULT '{}'::character varying[],
    alternate_name character varying(255),
    email character varying(255),
    languages character varying(255)[] DEFAULT '{}'::character varying[],
    required_documents character varying(255)[] DEFAULT '{}'::character varying[],
    status character varying(255) DEFAULT 'active'::character varying,
    website character varying(255),
    wait_time character varying(255),
    program_id integer,
    interpretation_services text,
    application_process text
);


--
-- Name: services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE services_id_seq OWNED BY services.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY addresses ALTER COLUMN id SET DEFAULT nextval('addresses_id_seq'::regclass);


--
-- Name: admins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admins ALTER COLUMN id SET DEFAULT nextval('admins_id_seq'::regclass);


--
-- Name: api_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_applications ALTER COLUMN id SET DEFAULT nextval('api_applications_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts ALTER COLUMN id SET DEFAULT nextval('contacts_id_seq'::regclass);


--
-- Name: friendly_id_slugs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY friendly_id_slugs ALTER COLUMN id SET DEFAULT nextval('friendly_id_slugs_id_seq'::regclass);


--
-- Name: holiday_schedules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY holiday_schedules ALTER COLUMN id SET DEFAULT nextval('holiday_schedules_id_seq'::regclass);


--
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY locations ALTER COLUMN id SET DEFAULT nextval('locations_id_seq'::regclass);


--
-- Name: mail_addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mail_addresses ALTER COLUMN id SET DEFAULT nextval('mail_addresses_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations ALTER COLUMN id SET DEFAULT nextval('organizations_id_seq'::regclass);


--
-- Name: phones id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY phones ALTER COLUMN id SET DEFAULT nextval('phones_id_seq'::regclass);


--
-- Name: programs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY programs ALTER COLUMN id SET DEFAULT nextval('programs_id_seq'::regclass);


--
-- Name: regular_schedules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY regular_schedules ALTER COLUMN id SET DEFAULT nextval('regular_schedules_id_seq'::regclass);


--
-- Name: services id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY services ALTER COLUMN id SET DEFAULT nextval('services_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: api_applications api_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_applications
    ADD CONSTRAINT api_applications_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: friendly_id_slugs friendly_id_slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY friendly_id_slugs
    ADD CONSTRAINT friendly_id_slugs_pkey PRIMARY KEY (id);


--
-- Name: holiday_schedules holiday_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY holiday_schedules
    ADD CONSTRAINT holiday_schedules_pkey PRIMARY KEY (id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: mail_addresses mail_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY mail_addresses
    ADD CONSTRAINT mail_addresses_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: phones phones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY phones
    ADD CONSTRAINT phones_pkey PRIMARY KEY (id);


--
-- Name: programs programs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY programs
    ADD CONSTRAINT programs_pkey PRIMARY KEY (id);


--
-- Name: regular_schedules regular_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY regular_schedules
    ADD CONSTRAINT regular_schedules_pkey PRIMARY KEY (id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: categories_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX categories_name ON categories USING gin (to_tsvector('english'::regconfig, name));


--
-- Name: index_addresses_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_addresses_on_location_id ON addresses USING btree (location_id);


--
-- Name: index_admins_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admins_on_confirmation_token ON admins USING btree (confirmation_token);


--
-- Name: index_admins_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admins_on_email ON admins USING btree (email);


--
-- Name: index_admins_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admins_on_reset_password_token ON admins USING btree (reset_password_token);


--
-- Name: index_api_applications_on_api_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_api_applications_on_api_token ON api_applications USING btree (api_token);


--
-- Name: index_api_applications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_api_applications_on_user_id ON api_applications USING btree (user_id);


--
-- Name: index_categories_on_ancestry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_ancestry ON categories USING btree (ancestry);


--
-- Name: index_categories_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_categories_on_slug ON categories USING btree (slug);


--
-- Name: index_categories_services_on_category_id_and_service_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_categories_services_on_category_id_and_service_id ON categories_services USING btree (category_id, service_id);


--
-- Name: index_categories_services_on_service_id_and_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_categories_services_on_service_id_and_category_id ON categories_services USING btree (service_id, category_id);


--
-- Name: index_contacts_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_location_id ON contacts USING btree (location_id);


--
-- Name: index_contacts_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_organization_id ON contacts USING btree (organization_id);


--
-- Name: index_contacts_on_service_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_service_id ON contacts USING btree (service_id);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type ON friendly_id_slugs USING btree (slug, sluggable_type);


--
-- Name: index_friendly_id_slugs_on_sluggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_id ON friendly_id_slugs USING btree (sluggable_id);


--
-- Name: index_friendly_id_slugs_on_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_type ON friendly_id_slugs USING btree (sluggable_type);


--
-- Name: index_holiday_schedules_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_holiday_schedules_on_location_id ON holiday_schedules USING btree (location_id);


--
-- Name: index_holiday_schedules_on_service_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_holiday_schedules_on_service_id ON holiday_schedules USING btree (service_id);


--
-- Name: index_locations_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_active ON locations USING btree (active);


--
-- Name: index_locations_on_admin_emails; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_admin_emails ON locations USING gin (admin_emails);


--
-- Name: index_locations_on_languages; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_languages ON locations USING gin (languages);


--
-- Name: index_locations_on_latitude_and_longitude; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_latitude_and_longitude ON locations USING btree (latitude, longitude);


--
-- Name: index_locations_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_organization_id ON locations USING btree (organization_id);


--
-- Name: index_locations_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_locations_on_slug ON locations USING btree (slug);


--
-- Name: index_locations_on_tsv_body; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_tsv_body ON locations USING gin (tsv_body);


--
-- Name: index_mail_addresses_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mail_addresses_on_location_id ON mail_addresses USING btree (location_id);


--
-- Name: index_organizations_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organizations_on_slug ON organizations USING btree (slug);


--
-- Name: index_phones_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_phones_on_contact_id ON phones USING btree (contact_id);


--
-- Name: index_phones_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_phones_on_location_id ON phones USING btree (location_id);


--
-- Name: index_phones_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_phones_on_organization_id ON phones USING btree (organization_id);


--
-- Name: index_phones_on_service_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_phones_on_service_id ON phones USING btree (service_id);


--
-- Name: index_programs_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_programs_on_organization_id ON programs USING btree (organization_id);


--
-- Name: index_regular_schedules_on_closes_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_regular_schedules_on_closes_at ON regular_schedules USING btree (closes_at);


--
-- Name: index_regular_schedules_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_regular_schedules_on_location_id ON regular_schedules USING btree (location_id);


--
-- Name: index_regular_schedules_on_opens_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_regular_schedules_on_opens_at ON regular_schedules USING btree (opens_at);


--
-- Name: index_regular_schedules_on_service_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_regular_schedules_on_service_id ON regular_schedules USING btree (service_id);


--
-- Name: index_regular_schedules_on_weekday; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_regular_schedules_on_weekday ON regular_schedules USING btree (weekday);


--
-- Name: index_services_on_languages; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_services_on_languages ON services USING gin (languages);


--
-- Name: index_services_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_services_on_location_id ON services USING btree (location_id);


--
-- Name: index_services_on_program_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_services_on_program_id ON services USING btree (program_id);


--
-- Name: index_services_on_service_areas; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_services_on_service_areas ON services USING gin (service_areas);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: locations_email_with_varchar_pattern_ops; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locations_email_with_varchar_pattern_ops ON locations USING btree (email varchar_pattern_ops);


--
-- Name: locations_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locations_kind ON locations USING gin (to_tsvector('english'::regconfig, kind));


--
-- Name: locations_market_match_false; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locations_market_match_false ON locations USING btree (market_match) WHERE (market_match IS FALSE);


--
-- Name: locations_market_match_true; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locations_market_match_true ON locations USING btree (market_match) WHERE (market_match IS TRUE);


--
-- Name: locations_payments; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locations_payments ON locations USING gin (to_tsvector('english'::regconfig, payments));


--
-- Name: locations_products; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locations_products ON locations USING gin (to_tsvector('english'::regconfig, products));


--
-- Name: locations_website_with_varchar_pattern_ops; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locations_website_with_varchar_pattern_ops ON locations USING btree (website varchar_pattern_ops);


--
-- Name: organizations_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX organizations_name ON organizations USING gin (to_tsvector('english'::regconfig, name));


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: locations locations_search_content_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER locations_search_content_trigger BEFORE INSERT OR UPDATE ON locations FOR EACH ROW EXECUTE PROCEDURE fill_search_vector_for_location();


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20140328034023'),
('20140328034531'),
('20140328034754'),
('20140328035528'),
('20140328041648'),
('20140328041859'),
('20140328042108'),
('20140328042218'),
('20140328042359'),
('20140328043104'),
('20140328044447'),
('20140328052427'),
('20140402222453'),
('20140404220233'),
('20140505011725'),
('20140508030435'),
('20140508030926'),
('20140508031024'),
('20140508194831'),
('20140629181523'),
('20140630171418'),
('20141120172313'),
('20141120210007'),
('20141122030534'),
('20141125195452'),
('20141125195559'),
('20141125201017'),
('20141125202506'),
('20141125205056'),
('20141125210027'),
('20141125210144'),
('20141125210253'),
('20141125210416'),
('20141125213424'),
('20141125213525'),
('20141125213856'),
('20141125213938'),
('20141125214746'),
('20141125215019'),
('20141125215624'),
('20141126014531'),
('20141126015110'),
('20141126015321'),
('20141126015551'),
('20141126015654'),
('20141126015749'),
('20141126020150'),
('20141126023421'),
('20141127025419'),
('20141127025633'),
('20141127025735'),
('20141208165502'),
('20150107163352'),
('20150329222001'),
('20150329222833'),
('20150329230646'),
('20150329231859'),
('20180212023953');


