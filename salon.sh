#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
   if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  echo -e "Welcome to My Salon, how can I help you?\n"
AVAILABLE_SERVICES=$($PSQL "select * from services")
echo "$AVAILABLE_SERVICES"| while IFS='|' read SERVICE_ID NAME
do 
  
  # Display the services in the required format
  echo "$SERVICE_ID) $NAME"
done

read SERVICE_ID_SELECTED
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
 then
    MAIN_MENU "That is not a valid salon service number."
 else
   SELECTED_SERVICE_AVAILABLE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
   if [[ -z $SELECTED_SERVICE_AVAILABLE ]]
    then
      MAIN_MENU "I could not find that service."
    else
     echo -e "\nWhat's your phone number?\n"
     read CUSTOMER_PHONE
     CUSTOMERS_PHONE_AVAILABLE=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
     if [[ -z $CUSTOMERS_PHONE_AVAILABLE ]]
     then
        echo -e "\nI don't have a record for that phone number, what's your name?\n"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
     fi
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SELECTED_SERVICE_AVAILABLE'")
      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?\n"
      read SERVICE_TIME
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES('$CUSTOMER_ID','$SELECTED_SERVICE_AVAILABLE', '$SERVICE_TIME')")
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
   fi
fi
}
MAIN_MENU

