#!/bin/bash

java -jar ./core/liquibase.jar --defaultsFile="dev.properties" --contexts="dev" update