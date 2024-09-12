#!/bin/bash
PSQL="psql --username=freecodecamp dbname=salon --tuples-only -c"

#echo name of salon
echo -e "\n~~~~~ MY SALON ~~~~~\n"

  #ask customer to select a service
  echo "Welcome to My Salon, how can I help you?"
SERVICE_MENU(){

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  #Get list of services
  SERVICES=$($PSQL "SELECT * FROM services")
  #display list of services
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
     echo "$SERVICE_ID) $NAME"
  done
  #Read the service_id
  read SERVICE_ID_SELECTED
   
  case $SERVICE_ID_SELECTED in
  [1-5])SET_APPOINTMENT;;
      *)SERVICE_MENU "I could not find that service. What would you like today?";;
  esac

}

SET_APPOINTMENT(){
  #Ask customer phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  #get customer name
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  #if name does not exist
  if [[ -z $CUSTOMER_NAME ]]
  then
     #Ask customer name
     echo -e "\nI don't have a record for that phone number, what's your name?"
     read CUSTOMER_NAME
     #Insert new record
     INSERT_CUS_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
  fi
  #Get service_name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  #ask customer to set appointment time.
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  #Get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  #Insert new record in appointment table
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
  #if recorded
   if [[ $INSERT_APPOINTMENT_RESULT == 'INSERT 0 1' ]]
   then
   #display message
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
   fi

}

SERVICE_MENU
