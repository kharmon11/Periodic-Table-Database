#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

extract_element() {
  IFS='|' read -r ATOMIC_NUMBER SYMBOL NAME <<< $1 
}

get_element_info() {
  INPUT=$1
  INPUT_TYPE=$2
  ELEMENT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE $INPUT_TYPE='$INPUT'")
  if [[ -z $ELEMENT ]]
  then
    echo I could not find that element in the database.
  else
    extract_element "$ELEMENT"
    query_properties $ATOMIC_NUMBER $SYMBOL $NAME
  fi
}

query_properties() {
  ATOMIC_NUMBER=$1
  SYMBOL=$2
  NAME=$3

  PROPERTIES=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM properties INNER JOIN types ON properties.type_id = types.type_id WHERE atomic_number='$ATOMIC_NUMBER'")
  IFS='|' read -r ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS TYPE <<< $PROPERTIES

  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
}

process_input() {
  INPUT=$1
  # Determine if user submitted input
  if [[ -z $INPUT ]] 
  then
    echo Please provide an element as an argument.
  else
    # Check if input is an integer/Atomic Number
    if [[ "$INPUT" =~ ^[0-9]+$ ]]
    then
      ATOMIC_NUMBER=$INPUT
      get_element_info $INPUT "atomic_number"
    else
      # Check if input is 1 or 2 length string/(symbol)
      if [[ $INPUT =~ ^.{1,2}$ ]]
      then
        SYMBOL=$INPUT
        get_element_info $INPUT "symbol"
      # assume input is a name
      else
        NAME=$INPUT
        get_element_info $INPUT "name"
      fi
    fi
  fi
}

USER_INPUT=$1
process_input "$USER_INPUT"
