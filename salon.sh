#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  #List services
  SERVICES=$($PSQL "select * from services;")

  if [[ -z $SERVICES ]] 
  then
    echo "Sorry, There's no available services right now."
  else
    echo "$SERVICES" | while read SERVICE_ID BAR NAME 
    do
      echo "$SERVICE_ID) $NAME"
    done
  fi
  
  read SERVICE_ID_SELECTED
  # Check if the choosen service id exist 
  SERVICE_ID=$($PSQL "select service_id from services where service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID ]]
  then 
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    #getting service name
    SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")
    echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^   *|   *$//g' ), $(echo $CUSTOMER_NAME | sed -r 's/^   *|   *$//g' )?"
    read SERVICE_TIME

    #getting customer id
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
    #insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^   *|   *$//g' ) at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^   *|   *$//g' )."
  fi

}

MAIN_MENU