-- This file is a reference to replicate a freshly-provisioned database like most
-- database service providers - such as Heroku Postgres, for example.
--
-- Including these instructions as rails migrations does not seem to be a good fit.
CREATE EXTENSION hstore;
CREATE EXTENSION dblink;
CREATE DATABASE air_quality_development;
CREATE DATABASE air_quality_test;
